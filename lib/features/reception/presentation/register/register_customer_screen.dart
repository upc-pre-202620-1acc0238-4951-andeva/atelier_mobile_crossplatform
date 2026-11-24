import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/register/register_customer_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/register/register_customer_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// US11 E2 y US44 E2: alta presencial del cliente y su vehículo. En línea: sin red el botón queda deshabilitado.
class RegisterCustomerScreen extends StatefulWidget {
  final RegisterCustomerArgs? args;

  /// Solo para pruebas: si no se pasa, la pantalla crea el suyo con `get_it` y lo libera.
  final RegisterCustomerViewModel? viewModel;

  const RegisterCustomerScreen({super.key, this.args, this.viewModel});

  @override
  State<RegisterCustomerScreen> createState() => _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState extends State<RegisterCustomerScreen> {
  late final RegisterCustomerViewModel _viewModel =
      widget.viewModel ?? getIt<RegisterCustomerViewModel>(param1: widget.args);
  Object? _lastError;
  bool _doneHandled = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onState);
  }

  void _onState() {
    final state = _viewModel.state;
    final haptics = rememberAtelierHaptics();
    if (state.done && !_doneHandled) {
      _doneHandled = true;
      haptics.confirm();
      Navigator.of(context).maybePop();
    }
    if (state.error != null && !identical(state.error, _lastError)) haptics.reject();
    _lastError = state.error;
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onState);
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => RegisterCustomerContent(
        state: vm.state,
        onBack: () => Navigator.of(context).maybePop(),
        actions: RegisterCustomerActions(
          onKindChange: vm.onKindChange,
          onFirstNameChange: vm.onFirstNameChange,
          onLastNameChange: vm.onLastNameChange,
          onCompanyNameChange: vm.onCompanyNameChange,
          onTaxIdChange: vm.onTaxIdChange,
          onEmailChange: vm.onEmailChange,
          onPhoneChange: vm.onPhoneChange,
          onPlateChange: vm.onPlateChange,
          onBrandChange: vm.onBrandChange,
          onModelChange: vm.onModelChange,
          onEngineTypeChange: vm.onEngineTypeChange,
          onVinChange: vm.onVinChange,
          onYearChange: vm.onYearChange,
          onSubmit: vm.onSubmit,
        ),
      ),
    );
  }
}

class RegisterCustomerActions {
  final ValueChanged<CustomerType> onKindChange;
  final ValueChanged<String> onFirstNameChange;
  final ValueChanged<String> onLastNameChange;
  final ValueChanged<String> onCompanyNameChange;
  final ValueChanged<String> onTaxIdChange;
  final ValueChanged<String> onEmailChange;
  final ValueChanged<String> onPhoneChange;
  final ValueChanged<String> onPlateChange;
  final ValueChanged<String> onBrandChange;
  final ValueChanged<String> onModelChange;
  final ValueChanged<EngineType> onEngineTypeChange;
  final ValueChanged<String> onVinChange;
  final ValueChanged<String> onYearChange;
  final VoidCallback onSubmit;

  static void _noop1(Object? _) {}
  static void _noop() {}

  const RegisterCustomerActions({
    this.onKindChange = _noop1,
    this.onFirstNameChange = _noop1,
    this.onLastNameChange = _noop1,
    this.onCompanyNameChange = _noop1,
    this.onTaxIdChange = _noop1,
    this.onEmailChange = _noop1,
    this.onPhoneChange = _noop1,
    this.onPlateChange = _noop1,
    this.onBrandChange = _noop1,
    this.onModelChange = _noop1,
    this.onEngineTypeChange = _noop1,
    this.onVinChange = _noop1,
    this.onYearChange = _noop1,
    this.onSubmit = _noop,
  });
}

class RegisterCustomerContent extends StatelessWidget {
  final RegisterCustomerUiState state;
  final VoidCallback onBack;
  final RegisterCustomerActions actions;

  const RegisterCustomerContent({super.key, required this.state, required this.onBack, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final customerEnabled = !state.isSaving && !state.customerLocked;
    final vehicleEnabled = !state.isSaving;
    final company = state.kind == CustomerType.company;
    final presetName = state.presetCustomerName;
    final error = state.error;
    final plateInvalid = state.invalidField == 'plate';

    return Scaffold(
      body: Column(
        children: [
          AtelierTopBar(
            title: presetName != null ? strings.receptionFormVehicleTitle : strings.registerCustomerTitle,
            onBack: onBack,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.sm,
                Spacing.md,
                Spacing.sm + FloatingBarInset.of(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.md,
                children: [
                  if (!state.canRegister) AtelierNoPermissionState(text: strings.receptionNoPermission),
                  if (state.customerLocked)
                    AtelierBanner(
                      message: presetName != null
                          ? strings.registerVehicleForCustomerBanner(presetName)
                          : strings.registerCustomerSavedPendingVehicle,
                      icon: Icons.info_outline,
                      kind: BannerKind.info,
                    ),
                  if (presetName == null) ...[
                    AtelierSectionHeader(title: strings.registerCustomerSectionCustomer),
                    AtelierSurface(
                      tier: SurfaceTier.card,
                      shape: cardLargeShape,
                      contentPadding: const EdgeInsets.all(Spacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Spacing.sm,
                        children: [
                          Row(
                            spacing: Spacing.sm,
                            children: [
                              Expanded(
                                child: _Choice(
                                  text: strings.registerCustomerIndividual,
                                  selected: !company,
                                  enabled: customerEnabled,
                                  onClick: () => actions.onKindChange(CustomerType.individual),
                                ),
                              ),
                              Expanded(
                                child: _Choice(
                                  text: strings.registerCustomerCompany,
                                  selected: company,
                                  enabled: customerEnabled,
                                  onClick: () => actions.onKindChange(CustomerType.company),
                                ),
                              ),
                            ],
                          ),
                          if (company)
                            _field(
                              label: strings.registerCustomerCompanyName,
                              value: state.companyName,
                              onChange: actions.onCompanyNameChange,
                              enabled: customerEnabled,
                              field: 'companyName',
                              error: strings.receptionFieldCompanyName,
                              capitalization: TextCapitalization.words,
                            )
                          else ...[
                            _field(
                              label: strings.registerCustomerFirstName,
                              value: state.firstName,
                              onChange: actions.onFirstNameChange,
                              enabled: customerEnabled,
                              field: 'firstName',
                              error: strings.receptionFieldFirstName,
                              capitalization: TextCapitalization.words,
                            ),
                            _field(
                              label: strings.registerCustomerLastName,
                              value: state.lastName,
                              onChange: actions.onLastNameChange,
                              enabled: customerEnabled,
                              field: 'lastName',
                              error: strings.receptionFieldLastName,
                              capitalization: TextCapitalization.words,
                            ),
                          ],
                          _field(
                            label: company ? strings.registerCustomerTaxIdCompany : strings.registerCustomerTaxIdPerson,
                            value: state.taxId,
                            onChange: actions.onTaxIdChange,
                            enabled: customerEnabled,
                            field: 'taxId',
                            error: company ? strings.receptionFieldTaxIdCompany : strings.receptionFieldTaxIdPerson,
                            keyboardType: TextInputType.number,
                          ),
                          _field(
                            label: strings.registerCustomerEmail,
                            value: state.email,
                            onChange: actions.onEmailChange,
                            enabled: customerEnabled,
                            field: 'email',
                            error: strings.receptionFieldEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _field(
                            label: strings.registerCustomerPhone,
                            value: state.phone,
                            onChange: actions.onPhoneChange,
                            enabled: customerEnabled,
                            field: 'phone',
                            error: strings.receptionFieldPhone,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                  ],
                  AtelierSectionHeader(title: strings.registerCustomerSectionVehicle),
                  AtelierSurface(
                    tier: SurfaceTier.card,
                    shape: cardLargeShape,
                    contentPadding: const EdgeInsets.all(Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.sm,
                      children: [
                        AtelierPlateField(
                          label: strings.registerVehiclePlate,
                          value: state.plate,
                          onValueChange: actions.onPlateChange,
                          enabled: vehicleEnabled,
                          isError: plateInvalid,
                          errorText: plateInvalid ? strings.receptionFieldPlate : null,
                          imeAction: TextInputAction.next,
                        ),
                        _field(
                          label: strings.registerVehicleBrand,
                          value: state.brand,
                          onChange: actions.onBrandChange,
                          enabled: vehicleEnabled,
                          field: 'brand',
                          error: strings.receptionFieldBrand,
                          capitalization: TextCapitalization.words,
                        ),
                        _field(
                          label: strings.registerVehicleModel,
                          value: state.model,
                          onChange: actions.onModelChange,
                          enabled: vehicleEnabled,
                          field: 'model',
                          error: strings.receptionFieldModel,
                          capitalization: TextCapitalization.words,
                        ),
                        AtelierSectionHeader(title: strings.registerVehicleEngine),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: Spacing.sm,
                          children: [
                            for (var i = 0; i < EngineType.values.length; i += 2)
                              Row(
                                spacing: Spacing.sm,
                                children: [
                                  for (final engine in EngineType.values.skip(i).take(2))
                                    Expanded(
                                      child: _Choice(
                                        text: _engineLabel(strings, engine),
                                        selected: state.engineType == engine,
                                        enabled: vehicleEnabled,
                                        onClick: () => actions.onEngineTypeChange(engine),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                        _field(
                          label: strings.registerVehicleVin,
                          value: state.vin,
                          onChange: (value) => actions.onVinChange(value.toUpperCase()),
                          enabled: vehicleEnabled,
                          field: 'vin',
                          error: strings.receptionFieldVin,
                          capitalization: TextCapitalization.characters,
                        ),
                        _field(
                          label: strings.registerVehicleYear,
                          value: state.year,
                          onChange: actions.onYearChange,
                          enabled: vehicleEnabled,
                          field: 'year',
                          error: strings.receptionFieldYear,
                          keyboardType: TextInputType.number,
                          action: TextInputAction.done,
                          formatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: context.scheme.surface,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(height: 1, thickness: 1, color: context.scheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.sm,
                      children: [
                        if (error != null)
                          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
                        if (!state.isOnline) const AtelierRequiresConnection(),
                        AtelierButton(
                          text: state.customerLocked
                              ? strings.registerCustomerRetryVehicle
                              : strings.registerCustomerSubmit,
                          onClick: actions.onSubmit,
                          enabled: state.canSubmit,
                          loading: state.isSaving,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String value,
    required ValueChanged<String> onChange,
    required bool enabled,
    required String field,
    required String error,
    TextInputType? keyboardType,
    TextInputAction action = TextInputAction.next,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
  }) {
    final invalid = state.invalidField == field;
    return AtelierTextField(
      label: label,
      value: value,
      onValueChange: onChange,
      enabled: enabled,
      isError: invalid,
      errorText: invalid ? error : null,
      keyboardType: keyboardType,
      textInputAction: action,
      textCapitalization: capitalization,
      inputFormatters: formatters,
    );
  }

  static String _engineLabel(AppLocalizations strings, EngineType engine) => switch (engine) {
    EngineType.gasoline => strings.engineGasoline,
    EngineType.diesel => strings.engineDiesel,
    EngineType.electric => strings.engineElectric,
    EngineType.hybrid => strings.engineHybrid,
  };
}

/// Opción de una elección corta (tipo de cliente, motor): la elegida va rellena y con marca, no solo con color.
class _Choice extends StatelessWidget {
  final String text;
  final bool selected;
  final bool enabled;
  final VoidCallback onClick;

  const _Choice({required this.text, required this.selected, required this.enabled, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: AtelierButton(
        text: text,
        onClick: onClick,
        style: selected ? AtelierButtonStyle.tonal : AtelierButtonStyle.outlined,
        enabled: enabled,
        icon: selected ? Icons.check : null,
      ),
    );
  }
}
