import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';

/// Fecha del taller (America/Lima) a partir de un instante UTC del backend (docs/api/README.md):
/// `dd/MM/yyyy`. Lima es UTC−5 todo el año ([BusinessTime.limaOffset]).
extension LimaDateFormat on DateTime {
  String formatLimaDate() {
    final lima = toUtc().add(BusinessTime.limaOffset);
    final day = lima.day.toString().padLeft(2, '0');
    final month = lima.month.toString().padLeft(2, '0');
    final year = lima.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }
}
