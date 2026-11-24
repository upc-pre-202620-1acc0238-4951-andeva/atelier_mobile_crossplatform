import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_option.dart';

class BranchSelectionUiState {
  final bool isLoading;
  final List<BranchOption> branches;
  final String? selectedId;
  final String? assignedBranchId;
  final bool isSaving;
  final UiText? error;

  /// Un solo uso: la elección (o "después") quedó guardada y se puede entrar a la app.
  final bool done;

  const BranchSelectionUiState({
    this.isLoading = true,
    this.branches = const [],
    this.selectedId,
    this.assignedBranchId,
    this.isSaving = false,
    this.error,
    this.done = false,
  });

  BranchOption? get selected {
    for (final branch in branches) {
      if (branch.id == selectedId) return branch;
    }
    return null;
  }

  bool get canContinue => selected != null && !isSaving && !isLoading;

  BranchSelectionUiState copyWith({
    bool? isLoading,
    List<BranchOption>? branches,
    String? selectedId,
    String? assignedBranchId,
    bool clearAssigned = false,
    bool? isSaving,
    UiText? error,
    bool clearError = false, // copyWith(error: null) no borraría el error
    bool? done,
  }) {
    return BranchSelectionUiState(
      isLoading: isLoading ?? this.isLoading,
      branches: branches ?? this.branches,
      selectedId: selectedId ?? this.selectedId,
      assignedBranchId: clearAssigned ? null : assignedBranchId ?? this.assignedBranchId,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : error ?? this.error,
      done: done ?? this.done,
    );
  }
}
