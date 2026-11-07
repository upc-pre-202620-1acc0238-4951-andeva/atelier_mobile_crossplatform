import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/mark_appointment_arrived_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_dao.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_profitability_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/submit_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    setupDependencies();
    getIt.unregister<AppDatabase>();
    getIt.registerLazySingleton<AppDatabase>(
      () => AppDatabase(NativeDatabase.memory()),
      dispose: (database) => database.close(),
    );
  });

  tearDown(() => getIt.reset());

  test('el registry, que también usa el worker, tiene ambos handlers', () {
    final registry = getIt<OperationHandlerRegistry>();

    expect(registry.find('ATTACH_INTAKE_IMAGE'), isNotNull);
    expect(registry.find('SUBMIT_PROPOSAL'), isNotNull);
  });

  test('resuelve repositorios y lo que se movió desde tasks', () {
    expect(getIt<ReceptionRepository>(), isNotNull);
    expect(getIt<WorkOrderRepository>(), isNotNull);
    expect(getIt<VehicleDao>(), isNotNull);
    expect(getIt<TaskRepository>(), isNotNull);
  });

  test('resuelve los casos de uso, incluido el que cruza features', () {
    expect(getIt<MarkAppointmentArrivedUseCase>(), isNotNull);
    expect(getIt<SubmitProposalUseCase>(), isNotNull);
    expect(getIt<GetProfitabilityUseCase>(), isNotNull);
  });

  test('cada caso de uso de las dos features está registrado', () {
    int count(String path) =>
        Directory(path)
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('_use_case.dart'))
            .length;

    expect(count('lib/features/reception/application'), 13);
    expect(count('lib/features/workorders/application'), 27);

    int registered(String path) =>
        RegExp(r'registerLazySingleton<\w+UseCase>')
            .allMatches(File(path).readAsStringSync())
            .length;

    expect(
      registered(
        'lib/features/reception/infrastructure/di/reception_dependencies.dart',
      ),
      13,
    );
    expect(
      registered(
        'lib/features/workorders/infrastructure/di/workorders_dependencies.dart',
      ),
      27,
    );
  });

  test('domain no importa Flutter, http, Drift, get_it ni plugins', () {
    final imports = RegExp(
      r'''^\s*(import|export)\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );
    final domainOfFeature = RegExp(
      r'^package:atelier_mobile_crossplatform/features/\w+/domain/',
    );
    for (final folder in ['reception', 'workorders']) {
      final files = Directory('lib/features/$folder/domain')
          .listSync(recursive: true)
          .whereType<File>();
      expect(files, isNotEmpty);
      for (final file in files) {
        for (final match in imports.allMatches(file.readAsStringSync())) {
          final uri = match.group(2)!;
          final allowed =
              uri.startsWith('dart:') ||
              domainOfFeature.hasMatch(uri) ||
              uri.startsWith(
                'package:atelier_mobile_crossplatform/core/domain/',
              ) ||
              uri == 'package:decimal/decimal.dart' ||
              !uri.startsWith('package:');
          expect(allowed, isTrue, reason: '${file.path} importa $uri');
        }
      }
    }
  });
}
