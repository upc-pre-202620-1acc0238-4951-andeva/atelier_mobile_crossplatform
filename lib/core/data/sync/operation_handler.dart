import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';

/// Envía un tipo de operación de la cola. El núcleo no conoce endpoints de features: cada una
/// registra el suyo en [OperationHandlerRegistry]. Si tiene éxito, refresca su caché.
abstract class OperationHandler {
  Future<OperationResult> send(PendingOperationEntity operation);
}

sealed class OperationResult {
  const OperationResult();

  /// Clasifica una llamada. [alreadyApplied] indica qué errores cuentan como "ya aplicada"
  /// según la tabla de tipos de docs/06-offline-sync.md §3.
  static Future<OperationResult> from(
    Future<void> Function() call, {
    bool Function(ApiException error)? alreadyApplied,
  }) async {
    try {
      await call();
      return const Applied();
    } on ApiException catch (e) {
      if (alreadyApplied?.call(e) ?? false) return const Applied();
      if (e.httpStatus == 401) return const Unauthorized();
      if (e.httpStatus >= 500 || e.httpStatus == 408 || e.httpStatus == 429) {
        return Retry(httpStatus: e.httpStatus, code: e.code, message: e.message);
      }
      return Failed(httpStatus: e.httpStatus, code: e.code, message: e.message);
    } on NetworkException catch (e) {
      return Retry(message: e.message);
    }
  }
}

/// 2xx o "ya aplicada": se borra.
final class Applied extends OperationResult {
  const Applied();
}

/// 5xx, timeout o sin red: vuelve a PENDING con backoff.
final class Retry extends OperationResult {
  final int? httpStatus;
  final String? code;
  final String? message;

  const Retry({this.httpStatus, this.code, this.message});
}

/// Regla de negocio (otro 4xx): FAILED con el `message` del backend.
final class Failed extends OperationResult {
  final int? httpStatus;
  final String? code;
  final String? message;

  const Failed({this.httpStatus, this.code, this.message});
}

/// 401 tras intentar renovar: queda PENDING y la vuelta se detiene.
final class Unauthorized extends OperationResult {
  const Unauthorized();
}

/// Explícito, no un `Map` inyectado como en Android: `setupDependencies()` corre también en el
/// worker, y solo se construye el handler que se va a usar.
class OperationHandlerRegistry {
  final _factories = <String, OperationHandler Function()>{};

  void register(String type, OperationHandler Function() factory) {
    _factories[type] = factory;
  }

  OperationHandler? find(String type) => _factories[type]?.call();
}
