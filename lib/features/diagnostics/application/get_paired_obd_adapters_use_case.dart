import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_link.dart';

class GetPairedObdAdaptersUseCase {
  final ObdAdapterProvider provider;

  const GetPairedObdAdaptersUseCase({required this.provider});

  Future<List<ObdAdapter>> execute() => provider.pairedAdapters();
}
