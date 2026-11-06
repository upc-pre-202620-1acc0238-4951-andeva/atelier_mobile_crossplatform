import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/refresh_attendance_use_case.dart';
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
  });
  tearDown(() => getIt.reset());

  /// Lo que corre también el worker, con la base en memoria: la real abre un archivo.
  void setup() {
    setupDependencies();
    getIt.unregister<AppDatabase>();
    getIt.registerLazySingleton<AppDatabase>(
      () => AppDatabase(NativeDatabase.memory()),
      dispose: (database) => database.close(),
    );
  }

  // Sin handler, la operación queda PENDING sin aviso.
  test('el worker encuentra los tres handlers de asistencia', () {
    setup();
    final registry = getIt<OperationHandlerRegistry>();

    expect(registry.find('CLOCK_IN'), isNotNull);
    expect(registry.find('CLOCK_OUT'), isNotNull);
    expect(registry.find('SUBMIT_JUSTIFICATION'), isNotNull);
  });

  test('los casos de uso se pueden resolver', () {
    setup();

    expect(getIt<ClockInUseCase>(), isNotNull);
    expect(getIt<RefreshAttendanceUseCase>(), isNotNull);
  });
}
