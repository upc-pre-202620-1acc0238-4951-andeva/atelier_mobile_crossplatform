import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_selection_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum _AppointmentSheetMode { actions, reschedule, cancel }

/// Hoja inferior de gestión de cita (US11 + agenda completa):
/// Confirmar (`PENDING`), Registrar llegada (`H10`), Reprogramar (fecha/hora) y Cancelar (motivo).
class AppointmentActionsSheet extends StatefulWidget {
  final Appointment appointment;
  final VehicleSearchUiState state;
  final VoidCallback onConfirmAppointment;
  final VoidCallback onMarkArrived;
  final void Function(String dateText, String timeText) onReschedule;
  final ValueChanged<String> onCancelAppointment;
  final VoidCallback onDismiss;

  const AppointmentActionsSheet({
    super.key,
    required this.appointment,
    required this.state,
    required this.onConfirmAppointment,
    required this.onMarkArrived,
    required this.onReschedule,
    required this.onCancelAppointment,
    required this.onDismiss,
  });

  @override
  State<AppointmentActionsSheet> createState() => _AppointmentActionsSheetState();
}

class _AppointmentActionsSheetState extends State<AppointmentActionsSheet> {
  _AppointmentSheetMode _mode = _AppointmentSheetMode.actions;
  late String _rescheduleDate = BusinessTime.limaDate(widget.appointment.scheduledAt);
  late String _rescheduleTime = formatLimaTime(widget.appointment.scheduledAt);
  String _cancelReason = '';

  @override
  void didUpdateWidget(AppointmentActionsSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appointment.id != widget.appointment.id) {
      _mode = _AppointmentSheetMode.actions;
      _rescheduleDate = BusinessTime.limaDate(widget.appointment.scheduledAt);
      _rescheduleTime = formatLimaTime(widget.appointment.scheduledAt);
      _cancelReason = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appointment = widget.appointment;
    final state = widget.state;
    final busy = state.arrivingId != null || state.updatingAppointmentId != null;
    final isPending = appointment.status == AppointmentStatus.pending;
    final canMutate = state.canMarkArrival && state.isOnline && !busy;
    final updating = state.updatingAppointmentId == appointment.id;
    final error = state.error;

    final title = switch (_mode) {
      _AppointmentSheetMode.actions => strings.receptionAppointmentActionsTitle,
      _AppointmentSheetMode.reschedule => strings.receptionAppointmentRescheduleBtn,
      _AppointmentSheetMode.cancel => strings.receptionAppointmentCancelBtn,
    };

    final actions = <Widget>[
      if (!state.isOnline) const AtelierRequiresConnection(),
      ...switch (_mode) {
        _AppointmentSheetMode.actions => [
          if (isPending)
            AtelierButton(
              text: strings.receptionAppointmentConfirmBtn,
              onClick: widget.onConfirmAppointment,
              style: AtelierButtonStyle.tonal,
              enabled: canMutate,
              loading: updating,
              icon: Icons.check_circle_outline,
            ),
          AtelierButton(
            text: strings.receptionArriveConfirm,
            onClick: widget.onMarkArrived,
            enabled: canMutate,
            loading: state.arrivingId == appointment.id,
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: AtelierButton(
                  text: strings.receptionAppointmentRescheduleBtn,
                  onClick: () => setState(() => _mode = _AppointmentSheetMode.reschedule),
                  style: AtelierButtonStyle.outlined,
                  enabled: canMutate,
                  icon: Icons.schedule_outlined,
                ),
              ),
              Expanded(
                child: AtelierButton(
                  text: strings.receptionAppointmentCancelBtn,
                  onClick: () => setState(() => _mode = _AppointmentSheetMode.cancel),
                  style: AtelierButtonStyle.destructive,
                  enabled: canMutate,
                ),
              ),
            ],
          ),
          AtelierButton(
            text: strings.commonCancel,
            onClick: widget.onDismiss,
            style: AtelierButtonStyle.text,
            enabled: !busy,
          ),
        ],
        _AppointmentSheetMode.reschedule => [
          AtelierButton(
            text: strings.receptionAppointmentRescheduleConfirm,
            onClick: () => widget.onReschedule(_rescheduleDate, _rescheduleTime),
            enabled: canMutate && _rescheduleDate.trim().isNotEmpty && _rescheduleTime.trim().isNotEmpty,
            loading: updating,
          ),
          AtelierButton(
            text: strings.commonBack,
            onClick: () => setState(() => _mode = _AppointmentSheetMode.actions),
            style: AtelierButtonStyle.text,
            enabled: !busy,
          ),
        ],
        _AppointmentSheetMode.cancel => [
          AtelierButton(
            text: strings.receptionAppointmentCancelConfirm,
            onClick: () => widget.onCancelAppointment(_cancelReason),
            style: AtelierButtonStyle.destructiveFilled,
            enabled: canMutate && _cancelReason.trim().isNotEmpty,
            loading: updating,
          ),
          AtelierButton(
            text: strings.commonBack,
            onClick: () => setState(() => _mode = _AppointmentSheetMode.actions),
            style: AtelierButtonStyle.text,
            enabled: !busy,
          ),
        ],
      },
    ];

    final plate = appointment.plate;
    return AtelierBottomSheet(
      title: title,
      actions: actions,
      content: [
        if (plate != null) Align(alignment: Alignment.centerLeft, child: AtelierPlate(plate: plate, size: PlateSize.l)),
        Text(
          appointment.customerName ?? strings.receptionAppointmentNoCustomer,
          style: context.text.titleMedium!.copyWith(color: context.scheme.onSurface),
        ),
        Text(
          [
            strings.receptionArriveTime(formatLimaTime(appointment.scheduledAt)),
            if (appointment.reason != null) appointment.reason!,
          ].join(' · '),
          style: context.text.bodyMedium!.copyWith(color: context.atelier.inkSecondary),
        ),
        switch (_mode) {
          _AppointmentSheetMode.actions => const SizedBox.shrink(),
          _AppointmentSheetMode.reschedule => DateTimeQuickPicker(
            dateText: _rescheduleDate,
            timeText: _rescheduleTime,
            enabled: !busy,
            isError: false,
            onDateChange: (value) => setState(() => _rescheduleDate = value),
            onTimeChange: (value) => setState(() => _rescheduleTime = value),
          ),
          _AppointmentSheetMode.cancel => AtelierTextField(
            label: strings.receptionAppointmentCancelReasonLabel,
            value: _cancelReason,
            onValueChange: (value) => setState(() => _cancelReason = value),
            enabled: !busy,
            placeholder: strings.receptionAppointmentCancelReasonHint,
            textInputAction: TextInputAction.done,
          ),
        },
        if (error != null)
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

/// Hoja inferior para agendar una nueva cita (`POST /appointments`, `APPOINTMENTS_CREATE`).
class CreateAppointmentSheet extends StatelessWidget {
  final CreateAppointmentForm form;
  final List<Customer> customers;
  final bool isOnline;
  final UiText? error;
  final ValueChanged<String> onCustomerQueryChange;
  final ValueChanged<Customer> onSelectCustomer;
  final VoidCallback onClearCustomer;
  final ValueChanged<String> onSelectVehicle;
  final ValueChanged<int> onQuickDate;
  final ValueChanged<String> onDateChange;
  final ValueChanged<String> onTimeChange;
  final ValueChanged<String> onDurationChange;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const CreateAppointmentSheet({
    super.key,
    required this.form,
    required this.customers,
    required this.isOnline,
    required this.error,
    required this.onCustomerQueryChange,
    required this.onSelectCustomer,
    required this.onClearCustomer,
    required this.onSelectVehicle,
    required this.onQuickDate,
    required this.onDateChange,
    required this.onTimeChange,
    required this.onDurationChange,
    required this.onReasonChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  List<Customer> get _filteredCustomers {
    final q = form.customerQuery.trim().toLowerCase();
    final list = q.isEmpty
        ? customers
        : customers
              .where(
                (c) => c.displayName.toLowerCase().contains(q) || (c.taxId?.toLowerCase().contains(q) ?? false),
              )
              .toList();
    return list.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final selectedCustomer = form.selectedCustomer;
    final label = context.text.titleSmall!.copyWith(color: context.atelier.inkSecondary);
    final durationInvalid = form.invalidField == 'estimatedDurationMinutes';
    final currentError = error;
    return AtelierBottomSheet(
      title: strings.receptionCreateAppointmentTitle,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.receptionAppointmentScheduleBtn,
          onClick: onConfirm,
          enabled:
              isOnline &&
              !form.isSaving &&
              selectedCustomer != null &&
              form.selectedVehicleId != null &&
              form.dateText.trim().isNotEmpty &&
              form.timeText.trim().isNotEmpty,
          loading: form.isSaving,
        ),
        AtelierButton(
          text: strings.commonCancel,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !form.isSaving,
        ),
      ],
      content: [
        Text(strings.receptionAppointmentCustomerLabel, style: label),
        if (selectedCustomer == null) ...[
          AtelierTextField(
            label: strings.receptionAppointmentSelectCustomer,
            value: form.customerQuery,
            onValueChange: onCustomerQueryChange,
            enabled: !form.isSaving,
            textInputAction: TextInputAction.search,
          ),
          for (final customer in _filteredCustomers)
            AtelierSelectionCard(
              title: customer.displayName,
              subtitle: customer.taxId,
              selected: false,
              enabled: !form.isSaving,
              onClick: () => onSelectCustomer(customer),
            ),
        ] else ...[
          AtelierSelectionCard(
            title: selectedCustomer.displayName,
            subtitle: selectedCustomer.taxId,
            selected: true,
            enabled: !form.isSaving,
            onClick: onClearCustomer,
          ),
          Text(strings.receptionAppointmentVehicleLabel, style: label),
          if (form.isLoadingVehicles)
            const AtelierListRow(title: 'Vehículo', subtitle: 'Cargando', plate: 'BKL482', loading: true)
          else if (form.vehicles.isEmpty)
            Text(
              strings.receptionAppointmentNoVehicles,
              style: context.text.bodyMedium!.copyWith(color: context.atelier.inkSecondary),
            )
          else
            for (final vehicle in form.vehicles)
              AtelierSelectionCard(
                title: [vehicle.plate, vehicle.brand, vehicle.model].join(' · '),
                subtitle: vehicle.year?.toString(),
                selected: vehicle.id == form.selectedVehicleId,
                enabled: !form.isSaving,
                onClick: () => onSelectVehicle(vehicle.id),
              ),
        ],
        DateTimeQuickPicker(
          dateText: form.dateText,
          timeText: form.timeText,
          enabled: !form.isSaving,
          isError: form.invalidField == 'scheduledAt',
          onDateChange: onDateChange,
          onTimeChange: onTimeChange,
          onQuickDate: onQuickDate,
        ),
        AtelierTextField(
          label: strings.receptionAppointmentDurationLabel,
          value: form.durationText,
          onValueChange: onDurationChange,
          enabled: !form.isSaving,
          isError: durationInvalid,
          errorText: durationInvalid ? strings.receptionAppointmentInvalidDuration : null,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        AtelierTextField(
          label: strings.receptionAppointmentReasonLabel,
          value: form.reason,
          onValueChange: onReasonChange,
          enabled: !form.isSaving,
          placeholder: strings.receptionAppointmentReasonHint,
          textInputAction: TextInputAction.done,
        ),
        if (currentError != null)
          AtelierBanner(message: currentError.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

/// Fecha y hora de la cita como texto (`AAAA-MM-DD`, `HH:MM`) con atajos Hoy/Mañana cuando [onQuickDate] existe.
class DateTimeQuickPicker extends StatelessWidget {
  final String dateText;
  final String timeText;
  final bool enabled;
  final bool isError;
  final ValueChanged<String> onDateChange;
  final ValueChanged<String> onTimeChange;
  final ValueChanged<int>? onQuickDate;

  const DateTimeQuickPicker({
    super.key,
    required this.dateText,
    required this.timeText,
    required this.enabled,
    required this.isError,
    required this.onDateChange,
    required this.onTimeChange,
    this.onQuickDate,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final quick = onQuickDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (quick != null)
          Row(
            spacing: 8,
            children: [
              FilterChip(
                selected: false,
                onSelected: enabled ? (_) => quick(0) : null,
                shape: plateShape,
                label: Text(strings.receptionAppointmentTodayChip),
                avatar: const Icon(Icons.check, size: 18),
              ),
              FilterChip(
                selected: false,
                onSelected: enabled ? (_) => quick(1) : null,
                shape: plateShape,
                label: Text(strings.receptionAppointmentTomorrowChip),
              ),
            ],
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Expanded(
              flex: 12,
              child: AtelierTextField(
                label: strings.receptionAppointmentDateLabel,
                value: dateText,
                onValueChange: onDateChange,
                placeholder: '2026-11-23',
                isError: isError,
                enabled: enabled,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
            ),
            Expanded(
              flex: 8,
              child: AtelierTextField(
                label: strings.receptionAppointmentTimeLabel,
                value: timeText,
                onValueChange: onTimeChange,
                placeholder: '10:00',
                isError: isError,
                enabled: enabled,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Hoja inferior para editar correo y teléfono del cliente (`PUT /customers/{id}/contact`).
class EditCustomerContactSheet extends StatelessWidget {
  final EditContactForm form;
  final bool isOnline;
  final UiText? error;
  final ValueChanged<String> onEmailChange;
  final ValueChanged<String> onPhoneChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const EditCustomerContactSheet({
    super.key,
    required this.form,
    required this.isOnline,
    required this.error,
    required this.onEmailChange,
    required this.onPhoneChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final currentError = error;
    return AtelierBottomSheet(
      title: strings.receptionEditContactTitle,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.receptionEditContactSave,
          onClick: onConfirm,
          enabled: isOnline && !form.isSaving,
          loading: form.isSaving,
        ),
        AtelierButton(
          text: strings.commonCancel,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !form.isSaving,
        ),
      ],
      content: [
        Text(form.customerName, style: context.text.titleMedium!.copyWith(color: context.scheme.onSurface)),
        AtelierTextField(
          label: strings.receptionEditContactEmailLabel,
          value: form.email,
          onValueChange: onEmailChange,
          leadingIcon: Icons.mail_outline,
          enabled: !form.isSaving,
          isError: form.invalidField == 'email',
          errorText: form.invalidField == 'email' ? strings.receptionFieldEmail : null,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        AtelierTextField(
          label: strings.receptionEditContactPhoneLabel,
          value: form.phone,
          onValueChange: onPhoneChange,
          leadingIcon: Icons.phone_outlined,
          enabled: !form.isSaving,
          isError: form.invalidField == 'phone',
          errorText: form.invalidField == 'phone' ? strings.receptionFieldPhone : null,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
        ),
        if (currentError != null)
          AtelierBanner(message: currentError.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}
