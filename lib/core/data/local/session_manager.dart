import 'dart:async';
import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/data/local/jwt_claims.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_store.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/domain/plan.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sesión del usuario. Claves de docs/06-offline-sync.md §5. No guarda nada en memoria:
/// el worker, en otro motor, puede cambiarla en cualquier momento.
class SessionManager extends ChangeNotifier implements SessionStore {
  static const _token = 'token';
  static const _refreshToken = 'refresh_token';
  static const _tokenExpiresAt = 'token_expires_at';
  static const _userId = 'user_id';
  static const _email = 'email';
  static const _fullName = 'full_name';
  static const _tenantId = 'tenant_id';
  static const _tenantName = 'tenant_name';
  static const _membershipId = 'membership_id';
  static const _permissions = 'permissions';
  static const _branchId = 'branch_id';
  static const _shiftId = 'shift_id';
  static const _selectedBranchId = 'selected_branch_id';
  static const _branchChoicePending = 'branch_choice_pending';
  static const _planTier = 'plan_tier';
  static const _planStatus = 'plan_status';
  static const _planAccessGranted = 'plan_access_granted';
  static const _iotTelemetryEnabled = 'iot_telemetry_enabled';
  static const _aiDiagnosticsEnabled = 'ai_diagnostics_enabled';
  static const _installed = 'installed';

  /// Todo menos [_installed]: si se borrara, el siguiente arranque cerraría la sesión nueva.
  static const _sessionKeys = {
    _tokenExpiresAt,
    _userId,
    _email,
    _fullName,
    _tenantId,
    _tenantName,
    _membershipId,
    _permissions,
    _branchId,
    _shiftId,
    _selectedBranchId,
    _branchChoicePending,
    _planTier,
    _planStatus,
    _planAccessGranted,
    _iotTelemetryEnabled,
    _aiDiagnosticsEnabled,
  };

  final FlutterSecureStorage secure;
  final SharedPreferencesAsync preferences;

  SessionManager({
    this.secure = const FlutterSecureStorage(
      iOptions: IOSOptions(
        // El worker debe poder leerlo con el teléfono bloqueado.
        accessibility: KeychainAccessibility.first_unlock,
      ),
    ),
    SharedPreferencesAsync? preferences,
  }) : preferences = preferences ?? SharedPreferencesAsync();

  /// El Keychain de iOS sobrevive a desinstalar la app: sin la marca, se limpia.
  Future<void> clearIfReinstalled() async {
    if (await preferences.getBool(_installed) == true) return;
    await secure.deleteAll();
    await preferences.setBool(_installed, true);
  }

  @override
  Future<String?> getAuthToken() => secure.read(key: _token);

  @override
  Future<String?> getRefreshToken() => secure.read(key: _refreshToken);

  @override
  Future<int?> getTokenExpiresAt() => preferences.getInt(_tokenExpiresAt);

  @override
  Future<String?> getUserId() => preferences.getString(_userId);

  /// `null` cuando no hay sesión: AppRoot vuelve al login.
  Future<Session?> getSession() async {
    if (await getAuthToken() == null) return null;
    final data = await preferences.getAll(allowList: _sessionKeys);
    final userId = data[_userId] as String?;
    if (userId == null) return null;

    final tier = data[_planTier] as String?;
    final assignedBranch = data[_branchId] as String?;
    final selectedBranch = data[_selectedBranchId] as String?;
    return Session(
      userId: userId,
      email: data[_email] as String? ?? '',
      fullName: data[_fullName] as String? ?? '',
      tenantId: data[_tenantId] as String? ?? '',
      tenantName: data[_tenantName] as String? ?? '',
      membershipId: data[_membershipId] as String?,
      permissions: ((data[_permissions] as List?)?.cast<String>() ?? const [])
          .toSet(),
      plan: tier == null
          ? null
          : Plan(
              tier: tier,
              status: data[_planStatus] as String? ?? '',
              accessGranted: data[_planAccessGranted] as bool? ?? true,
              iotTelemetryEnabled: data[_iotTelemetryEnabled] as bool? ?? true,
              aiDiagnosticsEnabled:
                  data[_aiDiagnosticsEnabled] as bool? ?? true,
            ),
      branchId: assignedBranch ?? selectedBranch,
      shiftId: data[_shiftId] as String?,
      needsBranchChoice:
          data[_branchChoicePending] == true &&
          assignedBranch == null &&
          selectedBranch == null,
    );
  }

  /// Sesión actual y sus cambios. Relee en cada aviso; de dos lecturas seguidas vale la última. Si el
  /// almacenamiento seguro falla emite `null`, como `AppRoot`.
  Stream<Session?> watchSession() {
    return Stream.multi((controller) {
      var lastRead = 0;
      Future<void> read() async {
        final current = ++lastRead;
        Session? session;
        try {
          session = await getSession();
        } on Exception catch (e) {
          log('No se pudo leer la sesión: $e', name: 'SessionManager');
        }
        if (current == lastRead) controller.add(session);
      }

      addListener(read);
      controller.onCancel = () {
        lastRead = -1; // Una lectura en curso ya no tiene a quién avisar.
        removeListener(read);
      };
      read();
    });
  }

  /// Resultado de [query] para lo que [key] toma de la sesión. Cambia de consulta solo cuando
  /// cambia la clave, y deja de escuchar la anterior.
  Stream<T> switchOn<K, T>(
    K Function(Session? session) key,
    Stream<T> Function(K key) query,
  ) {
    return Stream.multi((controller) {
      StreamSubscription<T>? rows;
      final keys = watchSession().map(key).distinct().listen((current) {
        unawaited(rows?.cancel());
        rows = query(current).listen(controller.add, onError: controller.addError);
      }, onError: controller.addError);
      controller.onCancel = () async {
        await keys.cancel();
        await rows?.cancel();
      };
    });
  }

  /// Guarda la respuesta de sign-in, google-sign-in, invitations/accept o refresh.
  /// El token va al final: si el sistema mata al motor a mitad de camino, queda el
  /// `refresh_token` nuevo, que aún permite renovar. Al revés se perdería la sesión.
  @override
  Future<void> save(AuthenticatedUserDto user) async {
    final expiresAt = JwtClaims.expiresAtMillis(user.token);
    if (expiresAt != null) {
      await preferences.setInt(_tokenExpiresAt, expiresAt);
    } else {
      await preferences.remove(_tokenExpiresAt);
    }
    await preferences.setString(_userId, user.userId);
    await preferences.setString(_email, user.email);
    await preferences.setString(_fullName, user.fullName ?? '');
    await preferences.setStringList(_permissions, user.permissions ?? const []);
    final tenant = user.activeTenant;
    if (tenant != null) {
      await preferences.setString(_tenantId, tenant.id);
      await preferences.setString(_tenantName, tenant.name ?? '');
    }
    final membershipId = user.membershipId;
    if (membershipId != null) {
      await preferences.setString(_membershipId, membershipId);
    }
    await _savePlan(user.plan);

    await secure.write(key: _refreshToken, value: user.refreshToken);
    await secure.write(key: _token, value: user.token);
    notifyListeners();
  }

  /// Sede y turno de `GET /hr/employees/membership/{membershipId}`. Con sede asignada ya no hay
  /// nada que elegir; sin ella, la elegida a mano se conserva (un 404 posterior no la borra).
  Future<void> updateAssignment(String? branchId, String? shiftId) async {
    await _setOrRemove(_branchId, branchId);
    await _setOrRemove(_shiftId, shiftId);
    if (branchId != null) {
      await preferences.remove(_selectedBranchId);
      await preferences.remove(_branchChoicePending);
    }
    notifyListeners();
  }

  /// El login no encontró perfil laboral (H33): se ofrece elegir sede una vez. Lleva un valor y
  /// no es solo "marcar" para que no sobreviva una marca de un login que no llegó a guardarse.
  Future<void> setBranchChoicePending(bool pending) async {
    if (pending) {
      await preferences.setBool(_branchChoicePending, true);
    } else {
      await preferences.remove(_branchChoicePending);
    }
    notifyListeners();
  }

  /// Sede elegida a mano. No toca `branch_id`, que se reescribe con cada lectura del perfil.
  Future<void> selectBranch(String branchId) async {
    await preferences.setString(_selectedBranchId, branchId);
    await preferences.remove(_branchChoicePending);
    notifyListeners();
  }

  /// "Elegir después": se entra sin sede y no se vuelve a ofrecer en esta sesión.
  Future<void> dismissBranchChoice() => setBranchChoicePending(false);

  @override
  Future<void> clear() async {
    await secure.delete(key: _token);
    await secure.delete(key: _refreshToken);
    await preferences.clear(allowList: _sessionKeys);
    notifyListeners();
  }

  /// El worker cambió la sesión en otro motor: quien escucha debe volver a leerla.
  void reload() => notifyListeners();

  Future<void> _savePlan(SessionPlanDto? plan) async {
    if (plan == null) {
      await preferences.remove(_planTier);
      await preferences.remove(_planStatus);
      await preferences.remove(_planAccessGranted);
      await preferences.remove(_iotTelemetryEnabled);
      await preferences.remove(_aiDiagnosticsEnabled);
      return;
    }
    await preferences.setString(_planTier, plan.tier ?? '');
    await preferences.setString(_planStatus, plan.status ?? '');
    await preferences.setBool(_planAccessGranted, plan.accessGranted);
    await preferences.setBool(_iotTelemetryEnabled, plan.iotTelemetryEnabled);
    await preferences.setBool(_aiDiagnosticsEnabled, plan.aiDiagnosticsEnabled);
  }

  Future<void> _setOrRemove(String key, String? value) {
    return value == null
        ? preferences.remove(key)
        : preferences.setString(key, value);
  }
}
