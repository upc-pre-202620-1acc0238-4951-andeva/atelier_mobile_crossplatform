import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/navigation/main_tab.dart';

class MainUiState {
  /// La sesión vigente; `null` al salir. De ella salen las baldosas de "Módulos".
  final Session? session;
  final List<MainTab> tabs;

  /// La pestaña a la vista (siempre una de [tabs] si hay alguna).
  final MainTab? selected;

  /// La barra añade al final el slot "Módulos", que abre la hoja universal de módulos.
  final bool showModules;

  /// Acción principal del botón circular de 64 dp a la derecha de la cápsula, decidida por permiso.
  final BarPrimaryAction primaryAction;

  /// Operaciones sin sincronizar del usuario; van como contador en "Módulos".
  final int pendingCount;

  const MainUiState({
    this.session,
    this.tabs = const [],
    this.selected,
    this.showModules = true,
    this.primaryAction = BarPrimaryAction.none,
    this.pendingCount = 0,
  });

  int get selectedIndex => selected == null ? -1 : tabs.indexOf(selected!);

  MainUiState copyWith({
    Session? session,
    bool clearSession = false,
    List<MainTab>? tabs,
    MainTab? selected,
    bool clearSelected = false,
    bool? showModules,
    BarPrimaryAction? primaryAction,
    int? pendingCount,
  }) {
    return MainUiState(
      session: clearSession ? null : session ?? this.session,
      tabs: tabs ?? this.tabs,
      selected: clearSelected ? null : selected ?? this.selected,
      showModules: showModules ?? this.showModules,
      primaryAction: primaryAction ?? this.primaryAction,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }
}
