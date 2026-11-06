import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/local_change_notifier.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el aviso del worker relee la sesión y sincroniza en la UI', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final session = SessionManager();
    var sessionNotices = 0;
    session.addListener(() => sessionNotices++);
    var syncs = 0;

    LocalChangeNotifier.listenInUi(database, session, sync: () => syncs++);
    LocalChangeNotifier.notifyUi();

    for (var i = 0; i < 200 && syncs == 0; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(syncs, 1);
    expect(sessionNotices, 1);
  });
}
