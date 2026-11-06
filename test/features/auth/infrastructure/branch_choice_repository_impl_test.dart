import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/branch/branch_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/branch_choice_repository_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../core/support/fake_session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionManager session;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    session = SessionManager();
  });

  BranchChoiceRepositoryImpl repository(MockClientHandler handler) {
    return BranchChoiceRepositoryImpl(
      api: BranchApi(
        client: ApiClient(
          client: MockClient(handler),
          baseUrl: 'https://api.test',
        ),
      ),
      session: session,
    );
  }

  test('lista las activas con nombre, ordenadas', () async {
    final options = await repository((request) async {
      expect(request.url.path, '/api/v1/branches');
      return http.Response(
        jsonEncode([
          {
            'id': '1',
            'name': ' surco ',
            'geofenceRadiusMeters': 80,
            'isActive': true,
          },
          {'id': '2', 'name': 'Inactiva', 'isActive': false},
          {'id': '3', 'name': '   ', 'isActive': true},
          {'id': '4', 'name': 'Ate'},
        ]),
        200,
      );
    }).availableBranches();

    expect(options.map((e) => e.id), ['4', '1']);
    expect(options.last.name, 'surco');
    expect(options.last.geofenceRadiusMeters, 80);
    expect(options.first.geofenceRadiusMeters, isNull);
  });

  test('elegir y omitir cambian la sesión', () async {
    final repo = repository((_) async => http.Response('[]', 200));
    await session.setBranchChoicePending(true);
    await session.save(
      AuthenticatedUserDto.fromJson(jsonDecode(sessionJson())),
    );
    expect((await session.getSession())!.needsBranchChoice, isTrue);

    await repo.selectBranch('b1');

    final chosen = await session.getSession();
    expect(chosen!.branchId, 'b1');
    expect(chosen.needsBranchChoice, isFalse);

    await session.clear();
    await session.setBranchChoicePending(true);
    await session.save(
      AuthenticatedUserDto.fromJson(jsonDecode(sessionJson())),
    );

    await repo.skipBranchChoice();

    final skipped = await session.getSession();
    expect(skipped!.branchId, isNull);
    expect(skipped.needsBranchChoice, isFalse);
  });
}
