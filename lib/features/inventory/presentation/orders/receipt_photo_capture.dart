import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Abre la cámara del sistema y entrega la foto del comprobante de compra (US34 E2). Mismo contrato que la captura
/// de fotos de órdenes de trabajo, copiado aquí para que `inventory` no importe otra feature.
typedef TakeReceiptPhoto = Future<void> Function({
  required void Function(File file) onCaptured,
  required void Function() onDenied,
});

/// `image_picker` pide `CAMERA` si falta; si se niega lanza `camera_access_denied` y se llama a [onDenied].
/// Cancelar la cámara no hace nada.
Future<void> takeReceiptPhoto({
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
