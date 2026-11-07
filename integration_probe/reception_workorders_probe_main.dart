import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:atelier_mobile_crossplatform/core/config/app_config.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/local_change_notifier.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_worker.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/affiliate_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/find_vehicle_by_plate_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/get_customer_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/lookup_affiliation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/mark_appointment_arrived_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_company_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_individual_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/search_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/affiliation_lookup.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/add_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/approve_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/attach_intake_photo_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/cancel_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/complete_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/download_quotation_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_branch_mechanics_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_part_movements_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_profitability_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_service_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/notify_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_pending_intake_photos_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_pending_proposals_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/open_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/reject_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/send_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/start_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/submit_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

const _order = WorkOrderId('rw1');

/// Prueba del paso 6 con worker y compresión reales, contra `tool/sync_mock_server.dart`. No se publica.
@pragma('vm:entry-point')
void probeDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('PROBE worker arranca $task');
    setupDependencies();
    final ok = await runSyncTask();
    debugPrint('PROBE worker termina ok=$ok');
    return ok;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  final session = getIt<SessionManager>();
  await session.clearIfReinstalled();
  final database = getIt<AppDatabase>();
  await database.customSelect('SELECT 1').get();
  await Workmanager().initialize(probeDispatcher);
  await getIt<ConnectivityObserver>().start();
  LocalChangeNotifier.listenInUi(
    database,
    session,
    sync: getIt<SyncProcessor>().runDetached,
  );

  if (await session.getSession() == null) {
    final seed = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/control/session'),
    );
    await session.save(
      AuthenticatedUserDto.fromJson(jsonDecode(utf8.decode(seed.bodyBytes))),
    );
    await session.updateAssignment('probe-branch', 'probe-shift');
    debugPrint('PROBE sesión sembrada');
  }

  getIt<ObservePendingIntakePhotosUseCase>().execute(_order).listen((rows) {
    for (final row in rows) {
      final path = row.localFilePath;
      debugPrint(
        'PROBE foto ${row.status} archivo=${path != null && File(path).existsSync()} '
        'descripcion=${row.description}',
      );
    }
    debugPrint('PROBE fotos pendientes=${rows.length}');
  });
  getIt<ObservePendingProposalsUseCase>().execute(_order).listen((rows) {
    for (final row in rows) {
      final path = row.localFilePath;
      debugPrint(
        'PROBE propuesta ${row.status} archivo=${path != null && File(path).existsSync()} '
        'severidad=${row.severity?.value}',
      );
    }
    debugPrint('PROBE propuestas pendientes=${rows.length}');
  });
  getIt<PendingOperationDao>().watchForUser('probe-user').listen((rows) {
    for (final row in rows) {
      debugPrint(
        'PROBE cola ${row.type} ${row.status} depende=${row.dependsOn != null} '
        'intentos=${row.attempts} error=${row.lastErrorMessage}',
      );
    }
    debugPrint('PROBE cola total=${rows.length}');
  });

  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _button('En linea', _online),
              _button('Sin red', _offline),
              _button('Capturar', _capture),
              _button('Ver', _show),
            ],
          ),
        ),
      ),
    ),
  );
}

void _check(String name, bool passed, [Object? detail]) {
  debugPrint('PROBE ${passed ? 'OK' : 'FALLA'} $name ${detail ?? ''}');
}

Future<void> _expectApiError(
  String name,
  int status,
  Future<void> Function() call,
) async {
  try {
    await call();
    _check(name, false, 'no falló');
  } on ApiException catch (e) {
    _check(name, e.httpStatus == status, '${e.httpStatus} "${e.message}"');
  }
}

String get _today => BusinessTime.limaDate(DateTime.now());

Future<void> _online() async {
  await _reception();
  await _arrival();
  await _workOrder();
  debugPrint('PROBE en linea terminado');
}

Future<void> _reception() async {
  final find = getIt<FindVehicleByPlateUseCase>();
  final known = await find.execute(' rcp 123 ');
  _check(
    'placa normalizada con titular',
    known?.vehicle.id == 'rv1' && known?.owner?.displayName == 'Ana Pérez',
    known?.owner?.displayName,
  );
  _check('primer ingreso 404', await find.execute('NUEVA1') == null);

  final customers = getIt<SearchCustomersUseCase>();
  final found = await customers.execute('Ana');
  _check('buscar cliente', found.single.id == 'rc1');
  final owned = await getIt<GetCustomerVehiclesUseCase>().execute('rc1');
  _check('vehiculos del cliente', owned.length == 2, owned.length);

  final individual = await getIt<RegisterIndividualCustomerUseCase>().execute(
    NewIndividualCustomer(
      firstName: 'Juan',
      lastName: 'Ríos',
      taxId: _unique(8),
      email: '  ',
    ),
  );
  _check('alta persona', individual.displayName == 'Juan Ríos');
  final company = await getIt<RegisterCompanyCustomerUseCase>().execute(
    NewCompanyCustomer(companyName: 'Transportes SAC', taxId: _unique(11)),
  );
  _check('alta empresa', company.type == CustomerType.company);
  final plate = 'N${_unique(5)}';
  final vehicle = await getIt<RegisterVehicleUseCase>().execute(
    NewVehicle(
      plate: plate.toLowerCase(),
      brand: 'Kia',
      model: 'Soul',
      engineType: EngineType.electric,
      customerId: individual.id,
    ),
  );
  _check('alta vehiculo', vehicle.plate == plate, vehicle.plate);
  await _expectApiError('placa repetida con su message', 409, () async {
    await getIt<RegisterVehicleUseCase>().execute(
      NewVehicle(
        plate: plate,
        brand: 'Kia',
        model: 'Soul',
        engineType: EngineType.electric,
      ),
    );
  });

  final lookup = getIt<LookupAffiliationUseCase>();
  _check(
    'ya es cliente',
    (await lookup.execute('ana@correo.pe')).nextStep ==
        AffiliationStep.alreadyCustomer,
  );
  _check(
    'walk-in',
    (await lookup.execute('nadie@correo.pe')).nextStep ==
        AffiliationStep.registerWalkIn,
  );
  final account = await lookup.execute('app@correo.pe');
  _check(
    'cuenta afiliable',
    account.nextStep == AffiliationStep.affiliate &&
        account.vehicles.single.plate == 'APP789',
  );
  final affiliated = await getIt<AffiliateCustomerUseCase>().execute(
    'app@correo.pe',
    _unique(8),
  );
  final linked = await getIt<GetCustomerVehiclesUseCase>().execute(
    affiliated.id,
  );
  _check('afiliar vincula', linked.single.plate == 'APP789');
}

Future<void> _arrival() async {
  await getIt<RefreshAppointmentsUseCase>().execute(_today);
  final rows = await getIt<ObserveAppointmentsUseCase>().execute(_today).first;
  _check(
    'agenda con placa y cliente',
    rows.single.plate == 'CIT456' && rows.single.customerName == 'Ana Pérez',
    '${rows.single.plate} ${rows.single.customerName}',
  );

  final result = await getIt<MarkAppointmentArrivedUseCase>().execute('ra1');
  // El servidor crea la orden a los 1,5 s: con tres intentos a 1 s de distancia aparece.
  _check(
    'llegada encuentra la orden retardada (H10)',
    result is WorkOrderReady,
    result.runtimeType,
  );
  if (result is WorkOrderReady) {
    final completed = await getIt<UpdateWorkOrderUseCase>().execute(
      result.workOrderId,
      mileageIn: 32000,
      diagnosticSummary: 'Combustible: 1/2. Cambio de aceite',
    );
    _check(
      'completar orden de la cita (H34)',
      completed.mileageIn == 32000 &&
          completed.diagnosticSummary == 'Combustible: 1/2. Cambio de aceite',
      completed.diagnosticSummary,
    );
  }
}

Future<void> _workOrder() async {
  await getIt<RefreshBranchWorkOrdersUseCase>().execute();
  final list = await getIt<ObserveBranchWorkOrdersUseCase>().execute().first;
  final cached = list.firstWhere((o) => o.id == _order);
  _check(
    'lista sin PAID, con placa y cliente',
    list.every((o) => !(o.status?.isClosed ?? true)) &&
        cached.plate == 'RCP123' &&
        cached.customerName == 'Ana Pérez',
    list.map((o) => '${o.id.value}:${o.status?.value}').join(' '),
  );

  await _expectApiError('abrir con orden abierta', 409, () async {
    await getIt<OpenWorkOrderUseCase>().execute(
      const NewWorkOrder(vehicleId: 'rv1', customerId: 'rc1', mileageIn: 1),
    );
  });

  final services = await getIt<GetServiceCatalogUseCase>().execute();
  _check(
    'catalogo',
    services.single.basePrice?.amount == Decimal.parse('80.5'),
  );
  final mechanics = await getIt<GetBranchMechanicsUseCase>().execute();
  _check(
    'mecanicos activos',
    mechanics.single.membershipId == 'probe-membership',
  );

  var detail = await getIt<GetWorkOrderDetailUseCase>().execute(_order);
  _check(
    'detalle con kilometraje y diagnostico',
    detail.workOrder.mileageIn == 45000,
    detail.workOrder.diagnosticSummary,
  );

  detail = await getIt<AddWorkOrderTaskUseCase>().execute(
    _order,
    NewWorkOrderTask(
      serviceId: 'srv1',
      description: '  Cambio de aceite ',
      mechanicId: mechanics.single.membershipId,
      price: Decimal.parse('100'),
    ),
  );
  _check(
    'tarea recalcula IGV',
    detail.workOrder.totalAmount?.amount == Decimal.parse('118') &&
        detail.workOrder.taxAmount?.amount == Decimal.parse('18'),
    detail.workOrder.totalAmount?.amount,
  );
  detail = await getIt<UpdateWorkOrderTaskUseCase>().execute(
    _order,
    detail.tasks.single.id,
    WorkOrderTaskChanges(price: Decimal.parse('200')),
  );
  _check(
    'editar tarea recalcula',
    detail.workOrder.totalAmount?.amount == Decimal.parse('236'),
    detail.workOrder.totalAmount?.amount,
  );

  final pdf = await getIt<DownloadQuotationPdfUseCase>().execute(_order);
  _check('PDF en disco', pdf.existsSync() && pdf.lengthSync() > 0, pdf.path);
  _check(
    'enviar proforma',
    await getIt<SendQuotationUseCase>().execute(_order) == 'ana@correo.pe',
  );

  try {
    await getIt<SubmitProposalUseCase>().execute(
      _order,
      description: 'x',
      severity: ProposalSeverity.high,
      photo: await _generatedPhoto(),
    );
    _check('HIGH no se envia', false, 'no falló');
  } on InvalidWorkOrderInputException catch (e) {
    _check('HIGH no se envia', e.field == 'severity');
  }

  final movements = await getIt<GetPartMovementsUseCase>().execute(_order);
  _check('movimientos', movements.single.returnedQuantity == Decimal.one);
  final profit = await getIt<GetProfitabilityUseCase>().execute(_order);
  _check(
    'rentabilidad negativa',
    profit.partsGrossProfit == Decimal.parse('-12.5'),
  );

  final started = await getIt<StartWorkOrderUseCase>().execute(_order);
  _check('iniciar', started.status == WorkOrderStatus.inProgress);
  await _expectApiError('iniciar dos veces', 422, () async {
    await getIt<StartWorkOrderUseCase>().execute(_order);
  });
  final completed = await getIt<CompleteWorkOrderUseCase>().execute(_order);
  _check('completar', completed.status == WorkOrderStatus.completed);

  final draft = await getIt<OpenWorkOrderUseCase>().execute(
    const NewWorkOrder(vehicleId: 'rv-libre', customerId: 'rc1', mileageIn: 5),
  );
  final canceled = await getIt<CancelWorkOrderUseCase>().execute(
    draft.id,
    ' Cliente desiste ',
  );
  final after = await getIt<ObserveBranchWorkOrdersUseCase>().execute().first;
  _check(
    'cancelar saca de la cache',
    canceled.status == WorkOrderStatus.canceled &&
        after.every((o) => o.id != draft.id),
  );
}

Future<void> _offline() async {
  final refresh = getIt<RefreshBranchWorkOrdersUseCase>();
  final before = await getIt<ObserveBranchWorkOrdersUseCase>().execute().first;
  try {
    await refresh.execute();
    _check('refresh sin red', false, 'no falló');
  } on NetworkException {
    _check('refresh sin red', true);
  }
  final cached = await getIt<ObserveBranchWorkOrdersUseCase>().execute().first;
  _check(
    'cache visible sin red',
    cached.length == before.length,
    before.length,
  );

  final known = await getIt<FindVehicleByPlateUseCase>().execute('RCP123');
  _check(
    'placa sin red, de la cache',
    known?.vehicle.id == 'rv1' && known?.owner?.id == 'rc1',
  );
  final local = await getIt<SearchCustomersUseCase>().execute('Pérez');
  _check('buscar sin red', local.any((c) => c.id == 'rc1'), local.length);

  final queue = getIt<PendingOperationDao>().watchForUser('probe-user');
  final queued = (await queue.first).length;
  try {
    await getIt<StartWorkOrderUseCase>().execute(_order);
    _check('accion en linea sin red', false, 'no falló');
  } on NetworkException {
    _check('accion en linea sin red', true);
  }
  _check('no se encola', (await queue.first).length == queued);
  debugPrint('PROBE sin red terminado');
}

/// Imagen real generada aquí: pasa por la misma compresión y subida que una de la cámara.
Future<File> _generatedPhoto() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 2400, 1200),
    ui.Paint()..color = const ui.Color(0xFF336699),
  );
  final image = await recorder.endRecording().toImage(2400, 1200);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  final directory = await getTemporaryDirectory();
  final file = File(
    '${directory.path}/probe_${DateTime.now().microsecondsSinceEpoch}.png',
  );
  return file.writeAsBytes(png!.buffer.asUint8List());
}

Future<void> _capture() async {
  await getIt<AttachIntakePhotoUseCase>().execute(
    _order,
    await _generatedPhoto(),
    description: 'Golpe en la puerta',
  );
  await getIt<SubmitProposalUseCase>().execute(
    _order,
    description: 'Pastillas gastadas',
    severity: ProposalSeverity.critical,
    photo: await _generatedPhoto(),
    suggestedServiceId: 'srv1',
  );
  debugPrint('PROBE foto y propuesta capturadas');
}

Future<void> _show() async {
  final detail = await getIt<GetWorkOrderDetailUseCase>().execute(_order);
  debugPrint('PROBE fotos en el backend=${detail.intakeImages.length}');
  debugPrint('PROBE propuestas en el backend=${detail.proposals.length}');
  for (final proposal in detail.proposals) {
    debugPrint(
      'PROBE propuesta ${proposal.severity?.value} ${proposal.mechanicId} ${proposal.imageUrl}',
    );
  }
  if (detail.proposals.isEmpty) return;
  final first = detail.proposals.first;
  _check(
    'avisar propuesta',
    await getIt<NotifyProposalUseCase>().execute(_order, first.id) ==
        'ana@correo.pe',
  );
  final rejected = await getIt<RejectProposalUseCase>().execute(
    _order,
    first.id,
    ' No por ahora ',
  );
  _check('rechazar propuesta', rejected.status == ProposalStatus.rejected);
  if (detail.proposals.length < 2) return;
  final approved = await getIt<ApproveProposalUseCase>().execute(
    _order,
    detail.proposals[1].id,
    ProposalApproval(
      serviceId: 'srv1',
      finalPrice: Decimal.parse('50'),
      laborHours: Decimal.parse('1.5'),
    ),
  );
  _check(
    'aprobar propuesta crea la tarea',
    approved.tasks.length == detail.tasks.length + 1,
    approved.workOrder.totalAmount?.amount,
  );
}

/// Documento o placa sin repetir entre ejecuciones contra el mismo servidor.
String _unique(int digits) {
  final value = DateTime.now().microsecondsSinceEpoch.toString();
  return value.substring(value.length - digits);
}

Widget _button(String label, Future<void> Function() onTap) {
  return Expanded(
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          try {
            await onTap();
          } on Object catch (e) {
            debugPrint(
              'PROBE FALLA excepcion en "$label": ${e.runtimeType} $e',
            );
          }
        },
        child: Text(label),
      ),
    ),
  );
}
