import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/submit_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_errors.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_id.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/branch.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_provider.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements AttendanceRepository {}

class _MockLocation extends Mock implements LocationProvider {}

void main() {
  const branch = Branch(
    id: 'b1',
    name: 'Sede',
    latitude: -12.0464,
    longitude: -77.0428,
    geofenceRadiusMeters: 100,
    isActive: true,
  );
  const inside = DeviceLocation(
    latitude: -12.0464,
    longitude: -77.0428,
    accuracyMeters: 10,
    isMock: false,
  );

  late _MockRepository repository;
  late _MockLocation provider;
  late ClockInUseCase clockIn;

  setUpAll(() => registerFallbackValue(inside));

  setUp(() {
    repository = _MockRepository();
    provider = _MockLocation();
    clockIn = ClockInUseCase(repository: repository, locationProvider: provider);
    when(
      () => repository.clockIn(any(), any(), any()),
    ).thenAnswer((_) async => const Queued());
    when(() => repository.findBranch('b1')).thenAnswer((_) async => branch);
    when(() => provider.currentLocation()).thenAnswer((_) async => inside);
  });

  test('sin sede o sin turno no pide la ubicación', () async {
    await expectLater(
      clockIn.execute(null, 's1'),
      throwsA(isA<MissingAssignmentException>()),
    );
    await expectLater(
      clockIn.execute('b1', ' '),
      throwsA(isA<MissingAssignmentException>()),
    );
    verifyNever(() => provider.currentLocation());
  });

  test('sin permiso o sin fix sube la excepción y no marca', () async {
    when(
      () => provider.currentLocation(),
    ).thenThrow(const LocationPermissionDeniedException());
    await expectLater(
      clockIn.execute('b1', 's1'),
      throwsA(isA<LocationPermissionDeniedException>()),
    );
    verifyNever(() => repository.clockIn(any(), any(), any()));
  });

  test('con precisión peor que 50 m no marca', () async {
    when(() => provider.currentLocation()).thenAnswer(
      (_) async => const DeviceLocation(
        latitude: -12.0464,
        longitude: -77.0428,
        accuracyMeters: 51,
        isMock: false,
      ),
    );
    await expectLater(
      clockIn.execute('b1', 's1'),
      throwsA(
        isA<LocationTooInaccurateException>().having(
          (e) => e.accuracyMeters,
          'precisión',
          51,
        ),
      ),
    );
    verifyNever(() => repository.clockIn(any(), any(), any()));
  });

  test('dentro de la geocerca marca e informa la distancia', () async {
    final result = await clockIn.execute('b1', 's1');

    expect(result.outcome, isA<Queued>());
    expect(result.geofence!.isInside, isTrue);
    expect(result.isMockLocation, isFalse);
  });

  test('fuera de la geocerca o simulada avisa, pero decide el backend', () async {
    when(() => provider.currentLocation()).thenAnswer(
      (_) async => const DeviceLocation(
        latitude: -12.0600,
        longitude: -77.0428,
        accuracyMeters: 10,
        isMock: true,
      ),
    );

    final result = await clockIn.execute('b1', 's1');

    verify(() => repository.clockIn('b1', 's1', any())).called(1);
    expect(result.geofence!.isInside, isFalse);
    expect(result.isMockLocation, isTrue);
  });

  test('sin la sede en caché marca igual, sin aviso de geocerca', () async {
    when(() => repository.findBranch('b1')).thenAnswer((_) async => null);

    final result = await clockIn.execute('b1', 's1');

    verify(() => repository.clockIn('b1', 's1', any())).called(1);
    expect(result.geofence, isNull);
  });

  test('un descargo inválido no llega al repositorio', () async {
    final useCase = SubmitJustificationUseCase(repository: repository);

    await expectLater(
      useCase.execute(AttendanceId('a1'), '   '),
      throwsA(isA<InvalidJustificationException>()),
    );
    verifyNever(() => repository.submitJustification(AttendanceId('a1'), any()));
  });
}
