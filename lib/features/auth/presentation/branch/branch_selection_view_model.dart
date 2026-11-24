import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_selectable_branches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/select_branch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/skip_branch_choice_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/branch/branch_selection_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

class BranchSelectionViewModel extends ChangeNotifier {
  final GetSelectableBranchesUseCase getBranchesUseCase;
  final SelectBranchUseCase selectBranchUseCase;
  final SkipBranchChoiceUseCase skipBranchChoiceUseCase;
  final ObserveSessionUseCase? observeSessionUseCase;

  BranchSelectionViewModel({
    required this.getBranchesUseCase,
    required this.selectBranchUseCase,
    required this.skipBranchChoiceUseCase,
    this.observeSessionUseCase,
  }) {
    load();
  }

  bool _disposed = false;

  BranchSelectionUiState _state = const BranchSelectionUiState();
  BranchSelectionUiState get state => _state;

  /// `GET /branches`. Preselecciona la sucursal asignada en la sesión o la primera sede disponible.
  Future<void> load() async {
    _update(_state.copyWith(isLoading: true, clearError: true));
    final sessionBranchId = await _sessionBranchId();
    try {
      final branches = await getBranchesUseCase.execute();
      final assigned = sessionBranchId != null && branches.any((b) => b.id == sessionBranchId)
          ? sessionBranchId
          : null;
      final keepId = _state.selectedId;
      final keep = keepId != null && branches.any((b) => b.id == keepId) ? keepId : null;
      _update(
        _state.copyWith(
          isLoading: false,
          branches: branches,
          assignedBranchId: assigned,
          clearAssigned: assigned == null,
          selectedId: keep ?? assigned ?? (branches.isEmpty ? null : branches.first.id),
        ),
      );
    } catch (e) {
      _update(_state.copyWith(isLoading: false, error: toUiText(e)));
    }
  }

  Future<String?> _sessionBranchId() async {
    final observe = observeSessionUseCase;
    if (observe == null) return null;
    try {
      return (await observe.execute().first)?.branchId;
    } on Exception catch (e) {
      log('No se pudo leer la sede de la sesión: $e', name: 'BranchSelectionViewModel');
      return null;
    }
  }

  void onSelect(String branchId) {
    if (_state.isSaving) return;
    _update(_state.copyWith(selectedId: branchId));
  }

  Future<void> onContinue() async {
    final current = _state;
    final branchId = current.selected?.id;
    if (branchId == null || !current.canContinue) return;
    _update(current.copyWith(isSaving: true));
    try {
      await selectBranchUseCase.execute(branchId);
      _update(_state.copyWith(isSaving: false, done: true));
    } catch (e) {
      _update(_state.copyWith(isSaving: false, error: toUiText(e)));
    }
  }

  /// "Elegir después": entra sin sede, como hasta ahora, y no se vuelve a preguntar.
  Future<void> onSkip() async {
    if (_state.isSaving) return;
    _update(_state.copyWith(isSaving: true));
    try {
      await skipBranchChoiceUseCase.execute();
      _update(_state.copyWith(isSaving: false, done: true));
    } catch (e) {
      _update(_state.copyWith(isSaving: false, error: toUiText(e)));
    }
  }

  void _update(BranchSelectionUiState state) {
    if (_disposed) return; // Una respuesta puede llegar con la pantalla ya cerrada.
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
