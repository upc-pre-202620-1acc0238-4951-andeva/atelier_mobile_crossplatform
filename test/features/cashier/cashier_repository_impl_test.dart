import 'dart:async';
import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../support/step9_test_env.dart';

const _vouchers = 'GET /api/v1/invoicing/vouchers/work-order/wo1';
const _issue = 'POST /api/v1/invoicing/vouchers';
const _voucher = 'GET /api/v1/invoicing/vouchers/v1';
const _pay = 'POST /api/v1/invoicing/payments';

VoucherDraft _draft() {
  return VoucherDraft(
    workOrderId: 'wo1',
    customerId: 'c1',
    type: VoucherType.boleta,
    customerInfo: const CustomerFiscalInfo(
      documentType: FiscalDocumentType.dni,
      taxId: '12345678',
      legalName: 'Ana',
    ),
    currency: Money.pen,
    lines: [
      VoucherLineDraft(
        itemType: VoucherItemType.service,
        itemId: 'srv1',
        description: 'Mantenimiento',
        quantity: Decimal.one,
        unitPriceWithIgv: Decimal.parse('118'),
      ),
    ],
  );
}

Decimal _d(String value) => Decimal.parse(value);

void main() {
  late Step9TestEnv env;

  setUp(() async {
    env = await Step9TestEnv.create();
    await env.signIn(
      permissions: const [
        Permission.invoicesRead,
        Permission.invoicesIssueSunat,
        Permission.paymentsCreate,
      ],
    );
  });
  tearDown(() => env.close());

  group('emitir (H28)', () {
    test('si la orden ya tiene una venta vigente no emite otra', () async {
      env.responses[_vouchers] = (_) => json([
        voucherJson(id: 'nc', type: '07'),
        voucherJson(id: 'old', status: 'VOIDED'),
        voucherJson(),
      ]);
      final outcome = await env.cashier.issue(_draft(), 'B001');
      expect(
        outcome,
        isA<AlreadyIssued>().having((o) => o.voucherId, 'id', 'v1'),
      );
      expect(env.requested('POST', '/api/v1/invoicing/vouchers'), isEmpty);
    });

    test('si no puede comprobar, no emite', () async {
      env.responses[_vouchers] = offline;
      await expectLater(
        env.cashier.issue(_draft(), 'B001'),
        throwsA(isA<NetworkException>()),
      );
      expect(env.requested('POST', '/api/v1/invoicing/vouchers'), isEmpty);
    });

    test('envía la serie, el código SUNAT y el precio con IGV', () async {
      env.responses[_vouchers] = (_) => json([]);
      env.responses[_issue] = (request) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['voucherType'], '03');
        expect(body['serie'], 'B001');
        expect(body['branchId'], 'b1');
        expect((body['lines'] as List).single['unitPriceWithIgv'], 118);
        return json(voucherJson(), 201);
      };
      final outcome = await env.cashier.issue(_draft(), 'B001');
      expect(outcome, isA<Issued>());
      final cached = await env.cashier.observeWorkOrderVouchers('wo1').first;
      expect(cached.single.pendingBalance, _d('118'));
    });

    test(
      'timeout que sí creó el comprobante: Issued, sin reintentar',
      () async {
        var created = false;
        env.responses[_vouchers] = (_) => json(created ? [voucherJson()] : []);
        env.responses[_issue] = (request) {
          created = true;
          throw TimeoutException('lento');
        };
        final outcome = await env.cashier.issue(_draft(), 'B001');
        expect(outcome, isA<Issued>());
        expect(
          env.requested('POST', '/api/v1/invoicing/vouchers'),
          hasLength(1),
        );
      },
    );

    test('timeout sin comprobante creado: el error original', () async {
      env.responses[_vouchers] = (_) => json([]);
      env.responses[_issue] = timeout;
      await expectLater(
        env.cashier.issue(_draft(), 'B001'),
        throwsA(isA<NetworkException>()),
      );
    });

    test(
      'cuerpo ilegible y la relectura también falla: el error original',
      () async {
        var reads = 0;
        env.responses[_vouchers] = (_) =>
            ++reads == 1 ? json([]) : http.Response('<html>', 502);
        env.responses[_issue] = (_) => http.Response('<html>', 201);
        await expectLater(
          env.cashier.issue(_draft(), 'B001'),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('2xx sin cuerpo y aparece el comprobante: Issued', () async {
      var created = false;
      env.responses[_vouchers] = (_) => json(created ? [voucherJson()] : []);
      env.responses[_issue] = (_) {
        created = true;
        return http.Response('', 204);
      };
      expect(await env.cashier.issue(_draft(), 'B001'), isA<Issued>());
    });

    test('un 502 de SUNAT se devuelve tal cual, sin releer', () async {
      env.responses[_vouchers] = (_) => json([]);
      env.responses[_issue] = (_) => apiError(502, 'SUNAT no responde');
      await expectLater(
        env.cashier.issue(_draft(), 'B001'),
        throwsA(isA<ApiException>().having((e) => e.httpStatus, 'status', 502)),
      );
      expect(
        env.requested('GET', '/api/v1/invoicing/vouchers/work-order/wo1'),
        hasLength(1),
      );
    });

    test(
      'respuesta sin montos: relee por id y, si tampoco, IssuedPendingDetails',
      () async {
        env.responses[_vouchers] = (_) => json([]);
        env.responses[_issue] = (_) => json(voucherJson(pending: null), 201);
        env.responses[_voucher] = offline;
        final outcome = await env.cashier.issue(_draft(), 'B001');
        expect(
          outcome,
          isA<IssuedPendingDetails>().having((o) => o.voucherId, 'id', 'v1'),
        );
      },
    );

    test('dos emisiones a la vez mandan un solo POST', () async {
      var created = false;
      final gate = Completer<void>();
      env.responses[_vouchers] = (_) => json(created ? [voucherJson()] : []);
      env.responses[_issue] = (_) async {
        await gate.future;
        created = true;
        return json(voucherJson(), 201);
      };
      final first = env.cashier.issue(_draft(), 'B001');
      final second = env.cashier.issue(_draft(), 'B001');
      await pumpEventQueue();
      gate.complete();
      expect(await first, isA<Issued>());
      expect(await second, isA<AlreadyIssued>());
      expect(env.requested('POST', '/api/v1/invoicing/vouchers'), hasLength(1));
    });
  });

  group('cobrar (H28)', () {
    test('valida monto y referencia antes de llamar', () async {
      await expectLater(
        env.cashier.registerPayment(
          'v1',
          _d('10.005'),
          PaymentMethod.cash,
          null,
        ),
        throwsA(
          isA<InvalidCashierInputException>().having(
            (e) => e.field,
            'f',
            'amount',
          ),
        ),
      );
      await expectLater(
        env.cashier.registerPayment(
          'v1',
          _d('10'),
          PaymentMethod.cash,
          'x' * 101,
        ),
        throwsA(
          isA<InvalidCashierInputException>().having(
            (e) => e.field,
            'f',
            'transactionReference',
          ),
        ),
      );
      expect(env.requests, isEmpty);
    });

    test('no cobra más que el saldo del comprobante, ni uno anulado, ni otra moneda', () async {
      env.responses[_voucher] = (_) => json(voucherJson(pending: 50));
      await expectLater(
        env.cashier.registerPayment('v1', _d('60'), PaymentMethod.cash, null),
        throwsA(
          isA<InvalidCashierInputException>().having(
            (e) => e.field,
            'f',
            'amount',
          ),
        ),
      );
      env.responses[_voucher] = (_) => json(voucherJson(status: 'VOIDED'));
      await expectLater(
        env.cashier.registerPayment('v1', _d('10'), PaymentMethod.cash, null),
        throwsA(
          isA<InvalidCashierInputException>().having(
            (e) => e.field,
            'f',
            'status',
          ),
        ),
      );
      env.responses[_voucher] = (_) => json(voucherJson(currency: 'EUR'));
      await expectLater(
        env.cashier.registerPayment('v1', _d('10'), PaymentMethod.cash, null),
        throwsA(
          isA<InvalidCashierInputException>().having(
            (e) => e.field,
            'f',
            'currency',
          ),
        ),
      );
      expect(env.requested('POST', '/api/v1/invoicing/payments'), isEmpty);
    });

    test('éxito: devuelve el comprobante releído', () async {
      var paid = false;
      env.responses[_voucher] = (_) => json(
        paid
            ? voucherJson(paid: 118, pending: 0, paymentStatus: 'PAID')
            : voucherJson(),
      );
      env.responses[_pay] = (request) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['currency'], 'PEN');
        expect(body['transactionReference'], 'OP-1');
        paid = true;
        return json({
          'id': 'p1',
          'voucherId': 'v1',
          'amount': 118,
          'currency': 'PEN',
        }, 201);
      };
      final result = await env.cashier.registerPayment(
        'v1',
        _d('118'),
        PaymentMethod.yape,
        '  OP-1 ',
      );
      expect(result.paymentStatus, VoucherPaymentStatus.paid);
    });

    test('un 4xx se devuelve con su message', () async {
      env.responses[_voucher] = (_) => json(voucherJson());
      env.responses[_pay] = (_) => apiError(409, 'Excede el saldo');
      await expectLater(
        env.cashier.registerPayment('v1', _d('10'), PaymentMethod.cash, null),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'm', 'Excede el saldo'),
        ),
      );
    });

    for (final (name, responder) in <(String, AsyncResponder)>[
      ('timeout', timeout),
      ('5xx', (_) => apiError(503)),
      ('2xx sin cuerpo', (_) => http.Response('', 204)),
      ('cuerpo ilegible', (_) => http.Response('<html>', 201)),
    ]) {
      test('$name: resultado desconocido, sin reintentar', () async {
        env.responses[_voucher] = (_) => json(voucherJson());
        env.responses[_pay] = responder;
        await expectLater(
          env.cashier.registerPayment('v1', _d('10'), PaymentMethod.cash, null),
          throwsA(isA<PaymentOutcomeUnknownException>()),
        );
        expect(
          env.requested('POST', '/api/v1/invoicing/payments'),
          hasLength(1),
        );
      });
    }

    test(
      'cobro hecho pero la relectura falla: resultado desconocido',
      () async {
        var reads = 0;
        env.responses[_voucher] = (request) =>
            ++reads == 1 ? json(voucherJson()) : offline(request);
        env.responses[_pay] = (_) => json({'id': 'p1', 'amount': 10}, 201);
        await expectLater(
          env.cashier.registerPayment('v1', _d('10'), PaymentMethod.cash, null),
          throwsA(isA<PaymentOutcomeUnknownException>()),
        );
      },
    );

    test(
      'dos cobros a la vez: un solo POST y el segundo ve el saldo nuevo',
      () async {
        var paid = false;
        final gate = Completer<void>();
        env.responses[_voucher] = (_) => json(
          paid
              ? voucherJson(paid: 118, pending: 0, paymentStatus: 'PAID')
              : voucherJson(),
        );
        env.responses[_pay] = (_) async {
          await gate.future;
          paid = true;
          return json({'id': 'p1', 'amount': 118}, 201);
        };
        final first = env.cashier.registerPayment(
          'v1',
          _d('118'),
          PaymentMethod.cash,
          null,
        );
        final second = env.cashier.registerPayment(
          'v1',
          _d('118'),
          PaymentMethod.cash,
          null,
        );
        await pumpEventQueue();
        gate.complete();
        expect((await first).paymentStatus, VoucherPaymentStatus.paid);
        await expectLater(
          second,
          throwsA(
            isA<InvalidCashierInputException>().having(
              (e) => e.field,
              'f',
              'amount',
            ),
          ),
        );
        expect(
          env.requested('POST', '/api/v1/invoicing/payments'),
          hasLength(1),
        );
      },
    );
  });

  group('series y caja', () {
    test(
      'serie que no corresponde al tipo o correlativo negativo, sin llamar',
      () async {
        await expectLater(
          env.cashier.configureSeries(VoucherType.factura, 'B001', null),
          throwsA(
            isA<InvalidCashierInputException>().having(
              (e) => e.field,
              'f',
              'serie',
            ),
          ),
        );
        await expectLater(
          env.cashier.configureSeries(VoucherType.factura, 'F001', -1),
          throwsA(
            isA<InvalidCashierInputException>().having(
              (e) => e.field,
              'f',
              'initialCorrelative',
            ),
          ),
        );
        expect(env.requests, isEmpty);
      },
    );

    test('configura con el código del tipo; 409 con su message', () async {
      env.responses['POST /api/v1/invoicing/series-configurations'] =
          (request) {
            expect(jsonDecode(request.body)['voucherType'], '01');
            return apiError(409, 'Serie ya registrada');
          };
      await expectLater(
        env.cashier.configureSeries(VoucherType.factura, 'F001', 0),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'm',
            'Serie ya registrada',
          ),
        ),
      );
    });

    test('caja diaria de la sede; los medios desconocidos se omiten', () async {
      env.responses['GET /api/v1/invoicing/payments/branch/b1/daily'] =
          (request) {
            expect(request.url.queryParameters['date'], '2026-11-06');
            return json({
              'totalCollected': 150.5,
              'currency': 'PEN',
              'breakdownByMethod': {'CASH': 100, 'CRYPTO': 50.5},
              'payments': [],
            });
          };
      final summary = await env.cashier.getDailyCashSummary('2026-11-06');
      expect(summary.totalCollected.amount, _d('150.5'));
      expect(summary.byMethod.keys, [PaymentMethod.cash]);
      expect(summary.date, '2026-11-06');
    });

    test('sin sede falla sin llamar', () async {
      await env.signIn(
        permissions: const [Permission.invoicesRead],
        branchId: null,
      );
      await env.session.updateAssignment(null, null);
      await expectLater(
        env.cashier.getBranchSeries(),
        throwsA(isA<MissingBranchException>()),
      );
    });
  });

  group('entrega (workorders)', () {
    test('pagar y entregar sacan la orden de la caché; el pase sin pagar da el 422', () async {
      env.responses['POST /api/v1/work-orders/wo1/mark-as-paid'] = (_) =>
          json(workOrderJson(status: 'PAID'));
      env.responses['GET /api/v1/work-orders/wo1/exit-pass/pdf'] = (_) =>
          apiError(422, 'La orden no está pagada');
      final paid = await env.workOrders.markAsPaid(WorkOrderId('wo1'));
      expect(paid.status?.value, 'PAID');
      expect(await env.db.workOrderDao.findById('wo1'), isNull);
      await expectLater(
        env.workOrders.downloadExitPass(WorkOrderId('wo1')),
        throwsA(isA<ApiException>().having((e) => e.httpStatus, 's', 422)),
      );
    });
  });
}
