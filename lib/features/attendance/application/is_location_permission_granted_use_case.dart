import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_permission_checker.dart';

class IsLocationPermissionGrantedUseCase {
  final LocationPermissionChecker checker;

  const IsLocationPermissionGrantedUseCase({required this.checker});

  Future<bool> execute() => checker.isGranted();
}
