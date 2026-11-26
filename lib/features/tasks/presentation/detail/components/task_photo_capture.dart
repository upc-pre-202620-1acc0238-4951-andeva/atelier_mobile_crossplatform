import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/evidence_kind.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Elige una foto ya tomada. Cancelar no hace nada; si el sistema niega el acceso se llama a [onDenied].
Future<void> pickGalleryPhoto({
  required void Function(File file) onCaptured,
  required void Function() onDenied,
}) async {
  try {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) onCaptured(File(picked.path));
  } on PlatformException catch (error) {
    if (error.code == 'photo_access_denied') {
      onDenied();
    } else {
      rethrow;
    }
  }
}

/// US28 E1/E2: tipo de foto (desmontaje o montaje) y nota opcional antes de tomarla. Funciona sin red.
class EvidenceCaptureSheet extends StatelessWidget {
  final EvidenceCaptureForm form;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<EvidenceKind> onKindChange;
  final ValueChanged<String> onNoteChange;
  final ValueChanged<File> onCaptured;
  final VoidCallback onDenied;
  final VoidCallback onDismiss;
  final TakePhoto takePhoto;
  final TakePhoto pickPhoto;

  const EvidenceCaptureSheet({
    super.key,
    required this.form,
    required this.isSaving,
    required this.invalidField,
    required this.error,
    required this.onKindChange,
    required this.onNoteChange,
    required this.onCaptured,
    required this.onDenied,
    required this.onDismiss,
    this.takePhoto = takeCameraPhoto,
    this.pickPhoto = pickGalleryPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = this.error;
    return AtelierBottomSheet(
      title: strings.tasksSeg2EvidenceSection,
      actions: [
        AtelierButton(
          text: strings.tasksSeg2EvidenceTakePhoto,
          onClick: () => takePhoto(onCaptured: onCaptured, onDenied: onDenied),
          minHeight: 56,
          enabled: !isSaving,
          loading: isSaving,
          icon: Icons.photo_camera_outlined,
        ),
        AtelierButton(
          text: strings.tasksSeg2EvidencePickGallery,
          onClick: () => pickPhoto(onCaptured: onCaptured, onDenied: onDenied),
          style: AtelierButtonStyle.outlined,
          minHeight: 56,
          enabled: !isSaving,
          icon: Icons.photo_library_outlined,
        ),
        AtelierButton(
          text: strings.proposalsCancel,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !isSaving,
        ),
      ],
      content: [
        Text(
          strings.tasksSeg2EvidenceKindLabel,
          style: context.text.titleSmall?.copyWith(color: context.atelier.inkSecondary),
        ),
        AtelierSegmentedControl<EvidenceKind>(
          options: EvidenceKind.values,
          selected: form.kind,
          onSelect: onKindChange,
          label: (kind) => switch (kind) {
            EvidenceKind.disassembly => strings.tasksSeg2EvidenceDisassembly,
            EvidenceKind.assembly => strings.tasksSeg2EvidenceAssembly,
          },
        ),
        AtelierTextField(
          label: strings.tasksSeg2EvidenceNoteLabel,
          value: form.note,
          onValueChange: onNoteChange,
          enabled: !isSaving,
          placeholder: strings.tasksSeg2EvidenceNoteHint,
          isError: invalidField == 'description',
          errorText: invalidField == 'description' ? strings.tasksSeg2EvidenceFieldError : null,
          textInputAction: TextInputAction.done,
        ),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}
