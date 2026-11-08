import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';

/// US37 E1–E3 (`invoicing:invoices:issue_sunat`). Sin líneas o con una descripción genérica:
/// `lines` (H26). Factura sin RUC de 11 dígitos: `taxId`. Sin serie activa del tipo:
/// `MissingFiscalSeriesException`. No duplica la venta tras un timeout (H28).
class IssueVoucherUseCase {
  final CashierRepository repository;

  const IssueVoucherUseCase({required this.repository});

  Future<IssueOutcome> execute(VoucherDraft draft) async {
    if (draft.lines.isEmpty || draft.lines.any((l) => l.needsDescription)) {
      throw const InvalidCashierInputException('lines');
    }
    final info = draft.customerInfo;
    if (draft.type == VoucherType.factura &&
        (info.documentType != FiscalDocumentType.ruc ||
            !CashierValidation.isRuc(info.taxId.trim()))) {
      throw const InvalidCashierInputException('taxId');
    }
    final series = (await repository.getBranchSeries())
        .where((s) => s.active && s.type == draft.type)
        .firstOrNull;
    if (series == null) throw const MissingFiscalSeriesException();
    return repository.issue(draft, series.serie);
  }
}
