/// Permiso atómico del claim `permissions`. La UI se habilita por permiso, nunca por rol
/// (docs/02-roles-and-permissions.md).
extension type const Permission(String value) {
  // IAM
  static const branchesRead = Permission('iam:branches:read');
  static const membersRead = Permission('iam:members:read');

  // HR
  static const attendanceClockIn = Permission('hr:attendance:clock_in');
  static const attendanceClockOut = Permission('hr:attendance:clock_out');
  static const attendanceReadOwn = Permission('hr:attendance:read_own');
  static const attendanceAuditAll = Permission('hr:attendance:audit_all');
  static const shiftsRead = Permission('hr:shifts:read');
  static const justificationsCreate = Permission('hr:justifications:create');
  static const justificationsApprove = Permission('hr:justifications:approve');

  // CRM
  static const customersRead = Permission('crm:customers:read');
  static const customersCreate = Permission('crm:customers:create');
  static const vehiclesRead = Permission('crm:vehicles:read');
  static const vehiclesCreate = Permission('crm:vehicles:create');
  static const appointmentsRead = Permission('crm:appointments:read');
  static const appointmentsUpdate = Permission('crm:appointments:update');

  // Operations
  static const workOrdersRead = Permission('operations:work_orders:read');
  static const workOrdersCreate = Permission('operations:work_orders:create');
  static const workOrdersUpdate = Permission('operations:work_orders:update');
  static const workOrdersCancel = Permission('operations:work_orders:cancel');
  static const inspectionsUploadPhotos = Permission(
    'operations:inspections:upload_photos',
  );
  static const proposalsCreate = Permission('operations:proposals:create');
  static const proposalsNotify = Permission('operations:proposals:notify');
  static const proposalsResolve = Permission('operations:proposals:resolve');
  static const quotationsRead = Permission('operations:quotations:read');
  static const quotationsSend = Permission('operations:quotations:send');
  static const quotationsApprove = Permission('operations:quotations:approve');
  static const tasksRead = Permission('operations:tasks:read');
  static const tasksTrackTime = Permission('operations:tasks:track_time');
  static const tasksUploadPhotos = Permission('operations:tasks:upload_photos');
  static const tasksHoldRequest = Permission('operations:tasks:hold_request');
  static const tasksHoldValidate = Permission('operations:tasks:hold_validate');
  static const tasksComplete = Permission('operations:tasks:complete');
  static const tasksChargeParts = Permission('operations:tasks:charge_parts');
  static const baysRead = Permission('operations:bays:read');
  static const baysReassign = Permission('operations:bays:reassign');
  static const vehicleHandoverExecute = Permission(
    'operations:vehicle_handover:execute',
  );
  static const servicesRead = Permission('operations:services:read');

  // Inventory
  static const partsRead = Permission('inventory:parts:read');
  static const batchesRead = Permission('inventory:batches:read');
  static const batchesRestore = Permission('inventory:batches:restore');
  static const batchesReceive = Permission('inventory:batches:receive');
  static const purchaseOrdersRead = Permission(
    'inventory:purchase_orders:read',
  );
  static const alertsRead = Permission('inventory:alerts:read');
  static const alertsResolve = Permission('inventory:alerts:resolve');

  // IoT
  static const devicesRead = Permission('iot:devices:read');
  static const installationsManage = Permission('iot:installations:manage');
  static const telemetryIngest = Permission('iot:telemetry:ingest');
  static const faultsRead = Permission('iot:faults:read');
  static const faultsResolve = Permission('iot:faults:resolve');
  static const healthReportsGenerate = Permission(
    'iot:health_reports:generate',
  );
  static const healthReportsRead = Permission('iot:health_reports:read');
  static const predictiveAlertsRead = Permission('iot:alerts:read');
  static const predictiveAlertsAcknowledge = Permission(
    'iot:alerts:acknowledge',
  );

  // Invoicing
  static const invoicesRead = Permission('invoicing:invoices:read');
  static const invoicesIssueSunat = Permission('invoicing:invoices:issue_sunat');
  static const paymentsCreate = Permission('invoicing:payments:create');
  static const exitPassesIssue = Permission('invoicing:exit_passes:issue');
  static const cashflowExportPdf = Permission('invoicing:cashflow:export_pdf');
  static const fiscalConfigManage = Permission(
    'invoicing:fiscal_config:manage',
  );
}
