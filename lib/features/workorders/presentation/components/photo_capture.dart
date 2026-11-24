import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Abre la cámara del sistema y entrega el archivo (`PhotoCapture` de Android, US13 y US14). Quien lo recibe
/// lo comprime y lo encola (`PhotoCapture` de `core/media`); el archivo queda en la caché del sistema.
typedef TakePhoto = Future<void> Function({
  required void Function(File file) onCaptured,
  required void Function() onDenied,
});

/// `image_picker` pide `CAMERA` si falta; si se niega lanza `camera_access_denied` y se llama a [onDenied].
/// Cancelar la cámara no hace nada.
Future<void> takeCameraPhoto({
  required void Function(File file) onCaptured,
  required void Function() onDenied,
}) async {
  try {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) onCaptured(File(picked.path));
  } on PlatformException catch (error) {
    if (error.code == 'camera_access_denied') {
      onDenied();
    } else {
      rethrow;
    }
  }
}
