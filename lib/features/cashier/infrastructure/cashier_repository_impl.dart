import 'dart:async';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/tenant/tenant_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/tenant/tenant_dtos.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/tenant_fiscal_profile.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/cashier_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/local/voucher_dao.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/remote/cashier_api.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/remote/cashier_dtos.dart';
import 'package:decimal/decimal.dart';

/// H28: emitir y cobrar no son idempotentes en el backend. Se serializa por orden (emitir) y por
/// comprobante (cobrar) dentro del proceso, y se relee antes y después del `POST`. Otro dispositivo
/// solo queda cubierto por la relectura previa.
class CashierRepositoryImpl implements CashierRepository {
  final CashierApi api;
  final VoucherDao voucherDao;
  final SessionManager session;
  final TenantApi? tenantApi;
  final PdfDownloader? pdfDownloader;
  final DateTime Function() now;

  final _issueLocks = KeyedLock();
  final _paymentLocks = KeyedLock();

  CashierRepositoryImpl({
    required this.api,
    required this.voucherDao,
    required this.session,
    this.tenantApi,
    this.pdfDownloader,
    this.now = DateTime.now,
  });

  @override
  Future<IssueOutcome> issue(VoucherDraft draft, String serie) async {
    final branchId = await _branchId();
    return _issueLocks.run(
      draft.workOrderId,
      () => _issueOnce(draft, serie, branchId),
    );
  }

  Future<IssueOutcome> _issueOnce(
    VoucherDraft draft,
    String serie,
    String branchId,
  ) async {
    final workOrderId = draft.workOrderId;
    // Si no se puede comprobar, no se emite.
    final existing = (await api.getWorkOrderVouchers(workOrderId))
        .where((dto) => dto.isActiveSaleDto)
        .firstOrNull;
    if (existing != null) {
      await _cacheHeader(existing, workOrderId);
      return AlreadyIssued(existing.toDomain());
    }

    final ElectronicVoucherDto? issued;
    try {
      issued = await api.issueVoucher(draft.toRequest(branchId, serie));
    } on ApiException {
      rethrow; // 4xx y 5xx (502 de SUNAT incluido) tal cual: el backend respondió que no.
    } catch (error, stackTrace) {
      // Timeout, sin red o cuerpo ilegible: pudo haberse creado.
      return _recoverIssue(workOrderId, error, stackTrace);
    }
    if (issued == null) {
      return _recoverIssue(
        workOrderId,
        const FormatException('Respuesta vacía del servidor'),
        StackTrace.current,
      );
    }
    return _issuedOutcome(issued, workOrderId);
  }

  /// Relee la orden: si aparece una venta vigente es la que se creó; si no, o si la relectura falla,
  /// el error original.
  Future<IssueOutcome> _recoverIssue(
    String workOrderId,
    Object error,
    StackTrace stackTrace,
  ) async {
    ElectronicVoucherDto? created;
    try {
      created = (await api.getWorkOrderVouchers(workOrderId))
          .where((dto) => dto.isActiveSaleDto)
          .firstOrNull;
    } catch (_) {
      created = null;
    }
    if (created == null) Error.throwWithStackTrace(error, stackTrace);
    return _issuedOutcome(created, workOrderId);
  }

  /// Ya emitido: nunca falla. Si la respuesta no se puede mapear, relee por id.
  Future<IssueOutcome> _issuedOutcome(
    ElectronicVoucherDto dto,
    String workOrderId,
  ) async {
    await _cacheHeader(dto, workOrderId);
    try {
      return Issued(dto.toDomain());
    } catch (_) {
      try {
        return Issued(await _readVoucher(dto.id));
      } catch (_) {
        return IssuedPendingDetails(dto.id);
      }
    }
  }

  @override
  Future<List<Voucher>> refreshWorkOrderVouchers(String workOrderId) async {
    final dtos = await api.getWorkOrderVouchers(workOrderId);
    final syncedAt = now().millisecondsSinceEpoch;
    await voucherDao.replaceWorkOrder(workOrderId, [
      for (final dto in dtos) ?dto.toEntity(workOrderId, syncedAt),
    ]);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Stream<List<VoucherSummary>> observeWorkOrderVouchers(String workOrderId) {
    return voucherDao
        .watchByWorkOrder(workOrderId)
        .map((rows) => [for (final row in rows) ?row.toSummary()]);
  }

  @override
  Future<Voucher> getVoucher(String id) => _readVoucher(id);

  @override
  Future<List<Voucher>> getVouchers({
    VoucherType? type,
    VoucherStatus? status,
    String? from,
    String? to,
  }) async {
    final branchId = await _branchId();
    final dtos = await api.getVouchers(
      branchId: branchId,
      voucherType: type?.code,
      status: status?.value,
      from: from,
      to: to,
    );
    final vouchers = dtos.map((dto) => dto.toDomain()).toList();
    for (final dto in dtos) {
      if (dto.workOrderId case final workOrderId?) {
        await _cacheHeader(dto, workOrderId);
      }
    }
    return vouchers;
  }

  @override
  Future<Voucher> voidVoucher(String voucherId, String reason) async {
    final trimmed = reason.trim();
    if (!CashierValidation.isValidReason(trimmed)) {
      throw const InvalidCashierInputException('reason');
    }
    final dto = await api.voidVoucher(
      voucherId,
      VoidVoucherRequestDto(reason: trimmed),
    );
    if (dto.workOrderId case final workOrderId?) {
      await _cacheHeader(dto, workOrderId);
    }
    return dto.toDomain();
  }

  @override
  Future<Voucher> issueCreditNote({
    required Voucher referenceVoucher,
    required String serie,
    required String reason,
    required Decimal amount,
  }) async {
    final trimmedReason = reason.trim();
    if (!CashierValidation.isValidReason(trimmedReason)) {
      throw const InvalidCashierInputException('reason');
    }
    if (!CashierValidation.isValidMoneyAmount(
      amount,
      max: referenceVoucher.totalAmount.amount,
    )) {
      throw const InvalidCashierInputException('amount');
    }
    final trimmedSerie = serie.trim().toUpperCase();
    if (!CashierValidation.isCreditNoteSeries(trimmedSerie, referenceVoucher.type)) {
      throw const InvalidCashierInputException('serie');
    }
    if (!referenceVoucher.activeSale ||
        referenceVoucher.status == VoucherStatus.draft) {
      throw const InvalidCashierInputException('status');
    }
    final customerId = referenceVoucher.customerId;
    if (customerId == null) {
      throw const InvalidCashierInputException('customerId');
    }
    final branchId = await _branchId();

    final normalizedAmount = amount.round(scale: 2);
    final fullMatch =
        normalizedAmount == referenceVoucher.totalAmount.amount &&
        referenceVoucher.lines.isNotEmpty &&
        referenceVoucher.lines.every(
          (line) =>
              line.description.trim().isNotEmpty &&
              line.unitPrice != null &&
              line.unitPrice! >= CashierValidation.minAmount &&
              line.quantity >= CashierValidation.minAmount,
        );

    String truncate(String value) =>
        value.length > CashierValidation.maxLineDescriptionLength
            ? value.substring(0, CashierValidation.maxLineDescriptionLength)
            : value;

    final lines = fullMatch
        ? [
            for (final line in referenceVoucher.lines)
              VoucherLineRequestDto(
                description: truncate(line.description),
                itemType: (line.itemType ?? VoucherItemType.service).value,
                quantity: line.quantity,
                unitPriceWithIgv: line.unitPrice!,
                itemId: line.itemId,
              ),
          ]
        : [
            VoucherLineRequestDto(
              description: truncate(trimmedReason),
              itemType: VoucherItemType.service.value,
              quantity: Decimal.one,
              unitPriceWithIgv: normalizedAmount,
            ),
          ];

    final dto = await api.issueCreditNote(
      IssueCreditNoteRequestDto(
        branchId: branchId,
        customerId: customerId,
        lines: lines,
        reason: trimmedReason,
        reasonDescription: trimmedReason,
        referenceVoucherId: referenceVoucher.id,
        serie: trimmedSerie,
      ),
    );
    if (dto.workOrderId case final workOrderId?) {
      await _cacheHeader(dto, workOrderId);
    }
    return dto.toDomain();
  }

  @override
  Future<File> downloadVoucherDocument(String url, String fileNamePrefix) {
    final downloader = pdfDownloader;
    if (downloader == null) {
      throw StateError('PdfDownloader no configurado en CashierRepositoryImpl');
    }
    return downloader.downloadDocument(
      fileNamePrefix,
      () => api.downloadDocument(url),
    );
  }

  @override
  Future<Voucher> registerPayment(
    String voucherId,
    Decimal amount,
    PaymentMethod method,
    String? transactionReference,
  ) async {
    final reference = transactionReference?.trim();
    final cleanReference = reference == null || reference.isEmpty
        ? null
        : reference;
    if (!CashierValidation.isPaymentAmount(amount)) {
      throw const InvalidCashierInputException('amount');
    }
    if ((cleanReference?.length ?? 0) > CashierValidation.maxReferenceLength) {
      throw const InvalidCashierInputException('transactionReference');
    }
    final branchId = await _branchId();
    return _paymentLocks.run(
      voucherId,
      () => _payOnce(voucherId, amount, method, cleanReference, branchId),
    );
  }

  Future<Voucher> _payOnce(
    String voucherId,
    Decimal amount,
    PaymentMethod method,
    String? reference,
    String branchId,
  ) async {
    final voucher = await _readVoucher(voucherId);
    if (!voucher.activeSale) throw const InvalidCashierInputException('status');
    // El saldo sale del comprobante, nunca de la orden (H26).
    if (amount > voucher.pendingBalance.amount) {
      throw const InvalidCashierInputException('amount');
    }
    final currency = voucher.currency;
    if (currency != Money.pen && currency != Money.usd) {
      throw const InvalidCashierInputException('currency');
    }

    try {
      final payment = await api.registerPayment(
        RegisterPaymentRequestDto(
          amount: amount,
          branchId: branchId,
          currency: currency!,
          paymentMethod: method.value,
          voucherId: voucherId,
          transactionReference: reference,
        ),
      );
      if (payment == null) {
        throw const FormatException('Respuesta vacía del servidor');
      }
    } on ApiException catch (error) {
      // El backend lo rechazó: su `message`.
      if (error.httpStatus < 500) rethrow;
      await _refreshQuietly(voucherId);
      throw PaymentOutcomeUnknownException(error);
    } catch (error) {
      await _refreshQuietly(voucherId);
      throw PaymentOutcomeUnknownException(error);
    }

    try {
      return await _readVoucher(voucherId);
    } catch (error) {
      throw PaymentOutcomeUnknownException(error);
    }
  }

  @override
  Future<List<Payment>> getVoucherPayments(String voucherId) async {
    final dtos = await api.getVoucherPayments(voucherId);
    return dtos.map((dto) => dto.toDomain(Money.pen)).toList();
  }

  @override
  Future<DailyCashSummary> getDailyCashSummary(String date) async {
    final branchId = await _branchId();
    return (await api.getDaily(branchId, date)).toDomain(date);
  }

  @override
  Future<List<FiscalSeries>> getBranchSeries() async {
    final branchId = await _branchId();
    final dtos = await api.getBranchSeries(branchId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<FiscalSeries> configureSeries(
    VoucherType type,
    String serie,
    int? initialCorrelative,
  ) async {
    final cleanSerie = serie.trim();
    final validSerie = type == VoucherType.notaCredito
        ? CashierValidation.isCreditNoteSeries(cleanSerie)
        : CashierValidation.isSeriesFor(type, cleanSerie);
    if (!validSerie) {
      throw const InvalidCashierInputException('serie');
    }
    if (initialCorrelative != null && initialCorrelative < 0) {
      throw const InvalidCashierInputException('initialCorrelative');
    }
    final branchId = await _branchId();
    final dto = await api.configureSeries(
      ConfigureSeriesRequestDto(
        branchId: branchId,
        serie: cleanSerie,
        voucherType: type.code,
        initialCorrelative: initialCorrelative,
      ),
    );
    return dto.toDomain();
  }

  @override
  Future<void> setSeriesActive(String id, bool active) {
    return api.setSeriesActive(id, active);
  }

  @override
  Future<TenantFiscalProfile> getTenantFiscalProfile() async {
    final tenants = tenantApi ?? (throw StateError('TenantApi no configurado en CashierRepositoryImpl'));
    return _saveTenantName(_toProfile(await tenants.getCurrent()));
  }

  @override
  Future<TenantFiscalProfile> updateTenantFiscalProfile(String name, String legalName) async {
    final trimmedName = name.trim();
    final trimmedLegalName = legalName.trim();
    if (trimmedName.isEmpty || trimmedName.length > CashierValidation.maxTenantNameLength) {
      throw const InvalidCashierInputException('tenantName');
    }
    if (trimmedLegalName.isEmpty || trimmedLegalName.length > CashierValidation.maxTenantLegalNameLength) {
      throw const InvalidCashierInputException('tenantLegalName');
    }
    final tenants = tenantApi ?? (throw StateError('TenantApi no configurado en CashierRepositoryImpl'));
    final dto = await tenants.updateCurrent(
      UpdateTenantProfileRequestDto(name: trimmedName, legalName: trimmedLegalName),
    );
    return _saveTenantName(_toProfile(dto));
  }

  TenantFiscalProfile _toProfile(TenantDto dto) => TenantFiscalProfile(
    id: dto.id,
    name: dto.name ?? '',
    legalName: dto.legalName ?? '',
    taxId: dto.taxId ?? '',
    status: dto.status,
  );

  /// El nombre comercial también se ve en la sesión (Perfil); de mejor esfuerzo.
  Future<TenantFiscalProfile> _saveTenantName(TenantFiscalProfile profile) async {
    if (profile.name.isNotEmpty) {
      try {
        await session.updateTenantName(profile.name);
      } catch (_) {}
    }
    return profile;
  }

  Future<String> _branchId() async {
    final current = await session.getSession();
    if (current == null) throw StateError('Sin sesión');
    return current.branchId ?? (throw const MissingBranchException());
  }

  Future<Voucher> _readVoucher(String id) async {
    final dto = await api.getVoucher(id);
    if (dto.workOrderId case final workOrderId?) {
      await _cacheHeader(dto, workOrderId);
    }
    return dto.toDomain();
  }

  /// Solo para dejar la caché al día tras un cobro incierto: su resultado no importa.
  Future<void> _refreshQuietly(String voucherId) async {
    try {
      await _readVoucher(voucherId);
    } catch (_) {}
  }

  /// De mejor esfuerzo: un fallo de la caché no cambia el resultado de emitir o cobrar.
  Future<void> _cacheHeader(
    ElectronicVoucherDto dto,
    String workOrderId,
  ) async {
    try {
      final row = dto.toEntity(workOrderId, now().millisecondsSinceEpoch);
      if (row != null) await voucherDao.upsert(row);
    } catch (_) {}
  }
}

/// Una cola de `Future` por clave: la segunda operación espera a la primera. La entrada se borra al
/// terminar la última, así que el mapa no crece.
class KeyedLock {
  final _tails = <String, Future<void>>{};

  Future<T> run<T>(String key, Future<T> Function() action) async {
    final previous = _tails[key];
    final done = Completer<void>();
    final tail = done.future;
    _tails[key] = tail;
    try {
      if (previous != null) await previous;
      return await action();
    } finally {
      done.complete();
      if (identical(_tails[key], tail)) _tails.remove(key);
    }
  }
}
