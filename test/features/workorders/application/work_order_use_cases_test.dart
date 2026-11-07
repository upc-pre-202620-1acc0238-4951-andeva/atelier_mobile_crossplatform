import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/add_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/approve_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/attach_intake_photo_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/cancel_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/open_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/reject_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/reject_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/submit_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WorkOrderRepository {}

Matcher _invalid(String field) => throwsA(
  isA<InvalidWorkOrderInputException>().having((e) => e.field, 'field', field),
);

void main() {
  late _MockRepository repository;
  const id = WorkOrderId('wo1');
  final negative = Decimal.parse('-1');
  final photo = File('foto.jpg');

  setUpAll(() => registerFallbackValue(photo));

  setUp(() => repository = _MockRepository());

  test('solo PAID y CANCELED son cerradas; solo HIGH no se envía', () {
    expect(WorkOrderStatus.values.where((e) => e.isClosed), [
      WorkOrderStatus.paid,
      WorkOrderStatus.canceled,
    ]);
    expect(ProposalSeverity.values.where((e) => !e.isSubmittable), [
      ProposalSeverity.high,
    ]);
  });

  test('OpenWorkOrder valida kilometraje y diagnóstico', () async {
    final useCase = OpenWorkOrderUseCase(repository: repository);

    await expectLater(
      useCase.execute(
        const NewWorkOrder(vehicleId: 'v', customerId: 'c', mileageIn: -1),
      ),
      _invalid('mileageIn'),
    );
    await expectLater(
      useCase.execute(
        NewWorkOrder(
          vehicleId: 'v',
          customerId: 'c',
          mileageIn: 0,
          diagnosticSummary: 'x' * 2001,
        ),
      ),
      _invalid('diagnosticSummary'),
    );
    verifyZeroInteractions(repository);
  });

  test('UpdateWorkOrder admite nulos y rechaza lo inválido', () async {
    final useCase = UpdateWorkOrderUseCase(repository: repository);
    await expectLater(
      useCase.execute(id, mileageIn: -1),
      _invalid('mileageIn'),
    );
    await expectLater(
      useCase.execute(id, diagnosticSummary: 'x' * 2001),
      _invalid('diagnosticSummary'),
    );

    when(() => repository.update(id)).thenAnswer(
      (_) async => const WorkOrder(
        id: id,
        branchId: 'b',
        vehicleId: 'v',
        customerId: 'c',
      ),
    );
    await useCase.execute(id);
    verify(() => repository.update(id)).called(1);
  });

  test('las tareas exigen descripción al crear y precio no negativo', () async {
    final add = AddWorkOrderTaskUseCase(repository: repository);
    await expectLater(
      add.execute(id, const NewWorkOrderTask(serviceId: 's', description: ' ')),
      _invalid('description'),
    );
    await expectLater(
      add.execute(
        id,
        NewWorkOrderTask(serviceId: 's', description: 'x', price: negative),
      ),
      _invalid('price'),
    );

    final update = UpdateWorkOrderTaskUseCase(repository: repository);
    await expectLater(
      update.execute(
        id,
        const TaskId('t'),
        WorkOrderTaskChanges(description: 'x' * 1001),
      ),
      _invalid('description'),
    );
    await expectLater(
      update.execute(
        id,
        const TaskId('t'),
        WorkOrderTaskChanges(price: negative),
      ),
      _invalid('price'),
    );
  });

  test('AttachIntakePhoto limita la descripción', () async {
    await expectLater(
      AttachIntakePhotoUseCase(repository: repository)
          .execute(id, photo, description: 'x' * 501),
      _invalid('description'),
    );
  });

  group('SubmitProposal', () {
    late SubmitProposalUseCase useCase;

    setUp(() => useCase = SubmitProposalUseCase(repository: repository));

    test('sin foto, con HIGH o sin descripción no encola', () async {
      await expectLater(
        useCase.execute(
          id,
          description: 'x',
          severity: ProposalSeverity.low,
          photo: null,
        ),
        _invalid('photo'),
      );
      await expectLater(
        useCase.execute(
          id,
          description: 'x',
          severity: ProposalSeverity.high,
          photo: photo,
        ),
        _invalid('severity'),
      );
      await expectLater(
        useCase.execute(
          id,
          description: ' ',
          severity: ProposalSeverity.low,
          photo: photo,
        ),
        _invalid('description'),
      );
      verifyZeroInteractions(repository);
    });

    test('válida llega al repositorio', () async {
      when(
        () => repository.submitProposal(
          id,
          description: 'x',
          severity: ProposalSeverity.critical,
          photo: any(named: 'photo'),
        ),
      ).thenAnswer((_) async {});

      await useCase.execute(
        id,
        description: 'x',
        severity: ProposalSeverity.critical,
        photo: photo,
      );

      verify(
        () => repository.submitProposal(
          id,
          description: 'x',
          severity: ProposalSeverity.critical,
          photo: any(named: 'photo'),
        ),
      ).called(1);
    });
  });

  test('ApproveProposal valida montos y notas', () async {
    final useCase = ApproveProposalUseCase(repository: repository);
    ProposalApproval approval({
      Decimal? finalPrice,
      Decimal? laborHours,
      String? notes,
    }) {
      return ProposalApproval(
        serviceId: 's',
        finalPrice: finalPrice ?? Decimal.one,
        laborHours: laborHours ?? Decimal.one,
        notes: notes,
      );
    }

    await expectLater(
      useCase.execute(id, 'p', approval(finalPrice: negative)),
      _invalid('finalPrice'),
    );
    await expectLater(
      useCase.execute(id, 'p', approval(laborHours: negative)),
      _invalid('laborHours'),
    );
    await expectLater(
      useCase.execute(id, 'p', approval(notes: 'x' * 1001)),
      _invalid('notes'),
    );
  });

  test('rechazar y cancelar exigen motivo', () async {
    await expectLater(
      RejectProposalUseCase(repository: repository).execute(id, 'p', ' '),
      _invalid('customerNotes'),
    );
    await expectLater(
      RejectQuotationUseCase(repository: repository).execute(id, ' '),
      _invalid('reason'),
    );
    await expectLater(
      CancelWorkOrderUseCase(repository: repository).execute(id, 'x' * 1001),
      _invalid('reason'),
    );
  });
}
