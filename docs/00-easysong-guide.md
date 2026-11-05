# Guía técnica de arquitectura y estándares: EasySong Mobile (Flutter)

Esta guía documenta cómo está construido [`easysong-mobile-flutter`](https://github.com/upc-pre-202620-1acc0238-4951/easysong-mobile-flutter), el proyecto Flutter del profesor. Es el equivalente de la guía de *EasySneaker Mobile* que usamos para Android y sirve como referencia del **estilo del curso**.

Aquí se describe lo que hay en el repo del profesor, no lo que hará Atelier. La adaptación a Atelier está en [05-flutter-architecture.md](05-flutter-architecture.md).

> Revisado en el commit `efb6b2f`. El código está copiado del repo, sin imports. Lo añadido son las rutas en la primera línea de cada bloque; los recortes están marcados con `…`.

---

## 1. Visión general y filosofía arquitectónica

La misma idea que en EasySneaker: **Clean Architecture**, organización **Feature-First** y conceptos de **DDD**. Cambian las herramientas: interfaz con widgets de Flutter y **Material 3**, y dependencias resueltas con `get_it`.

```text
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│   (Pages, ViewModels con ChangeNotifier, UiState, Navigator)    │
└───────────────────────────────┬─────────────────────────────────┘
                                │ usa
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      APPLICATION LAYER                          │
│                 (UseCases con método execute)                   │
└───────────────────────────────┬─────────────────────────────────┘
                                │ orquesta
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                             │
│            (Entidades, Repositorios abstractos)                 │
└───────────────────────────────▲─────────────────────────────────┘
                                │ implementa (DIP)
┌───────────────────────────────┴─────────────────────────────────┐
│                     INFRASTRUCTURE LAYER                        │
│       (Api con http, DTOs, DAOs con sqflite, RepositoryImpl)    │
└─────────────────────────────────────────────────────────────────┘
```

**Regla de dependencia:** `domain` no importa nada de Flutter, `http` ni `sqflite`. En el repo, `song.dart` y `song_repository.dart` solo importan otros archivos de dominio.

### De EasySneaker (Android) a EasySong (Flutter)

| Concepto | EasySneaker · Android | EasySong · Flutter |
| --- | --- | --- |
| UI | Jetpack Compose | Widgets + Material 3 |
| Pantalla | `HomeScreen` (`@Composable`) | `HomePage` (`StatelessWidget`) |
| Inyección de dependencias | Hilt (módulos y `@Inject`) | `get_it` (un archivo con registros) |
| ViewModel | `ViewModel` + `@HiltViewModel` | `ChangeNotifier` |
| Estado observable | `StateFlow` + `collectAsStateWithLifecycle()` | `notifyListeners()` + `ListenableBuilder` |
| Mutar estado | `_uiState.update { it.copy(...) }` | `_state = _state.copyWith(...)` + `notifyListeners()` |
| Caso de uso | `operator fun invoke` | método `execute` |
| HTTP | Retrofit (interfaz con anotaciones) + Gson | `http` (clase `Api` a mano) + `fromJson` |
| Servicio remoto | `ProductService` | `SongApi` |
| Base de datos local | Room (`@Entity`, `@Dao`) | `sqflite` (SQL a mano en un `Dao`) |
| Navegación | Navigation Compose type-safe | `Navigator.push` + `MaterialPageRoute` |
| Asíncrono | `suspend fun` | `Future` + `async`/`await` |
| Errores | `Result<T>` | Excepciones + `try`/`catch` en el ViewModel |

---

## 2. Gestión de dependencias

Un solo archivo: `pubspec.yaml`. No hay catálogo de versiones ni configuración por módulo.

```yaml
# pubspec.yaml
name: easy_song
description: "A new Flutter project."
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.13.5

dependencies:
  flutter:
    sdk: flutter
  http: ^1.6.0
  get_it: ^9.3.0
  sqflite: ^2.4.5
  path: ^1.9.1
  flutter_launcher_icons: ^0.14.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/images/
```

| Paquete | Para qué |
| --- | --- |
| `http` | Llamadas REST |
| `get_it` | Localizador de servicios (inyección de dependencias) |
| `sqflite` + `path` | Base SQLite y ruta del archivo |
| `flutter_launcher_icons` | Genera los íconos de la app (`flutter_launcher_icons.yaml`) |
| `flutter_lints` | Reglas del analizador |

Deliberadamente **no** usa generación de código ni librerías de estado: ni `retrofit`, `dio`, `json_serializable`, `freezed`, `provider`, `bloc`, `riverpod` o `go_router`. Todo se escribe a mano con lo que da Flutter.

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - android/**
    - ios/**
```

---

## 3. Estructura de carpetas

```text
lib/
├── main.dart                          # setupDependencies() + runApp + tema
│
├── core/                              # Código común y transversal
│   ├── app_database.dart              # Abre sqflite y crea las tablas
│   ├── theme.dart                     # MaterialTheme generado (Material Theme Builder)
│   └── di/
│       └── dependency_injection.dart  # getIt y todos los registros
│
└── features/
    ├── auth/
    │   └── presentation/
    │       └── login_page.dart
    │
    ├── favorites/
    │   ├── application/
    │   │   ├── get_favorites_use_case.dart
    │   │   └── toggle_favorite_use_case.dart
    │   ├── domain/
    │   │   └── favorite_repository.dart
    │   ├── infrastructure/
    │   │   ├── favorite_dao.dart
    │   │   └── favorite_repository_impl.dart
    │   └── presentation/
    │       └── favorites_page.dart
    │
    ├── home/
    │   ├── application/
    │   │   └── get_songs_use_case.dart
    │   ├── domain/
    │   │   ├── song.dart
    │   │   └── song_repository.dart
    │   ├── infrastructure/
    │   │   ├── remote/
    │   │   │   ├── song_api.dart
    │   │   │   └── song_dto.dart
    │   │   └── song_repository_impl.dart
    │   └── presentation/
    │       ├── home_page.dart
    │       ├── home_ui_state.dart
    │       ├── home_view_model.dart
    │       ├── song_card.dart
    │       └── song_detail_page.dart
    │
    ├── main/
    │   └── main_page.dart             # Scaffold + NavigationBar
    │
    └── onboarding/
        └── presentation/
            └── onboarding_page.dart
```

Solo existen las plataformas `android/` e `ios/`. Fuera de `lib/` están `assets/images/`, `assets/icons/` y `flutter_launcher_icons.yaml`.

---

## 4. Convenciones de nomenclatura

**Archivos en `snake_case`**, una clase pública por archivo salvo en `theme.dart`.

| Elemento | Convención | Ejemplo en el proyecto |
| :--- | :--- | :--- |
| Import | Ruta absoluta del paquete | `package:easy_song/features/home/domain/song.dart` |
| Entidades de dominio | Sustantivo | `Song` en `song.dart` |
| Repositorio (contrato) | `abstract class [Modelo]Repository` | `SongRepository`, `FavoriteRepository` |
| Repositorio (implementación) | `[Modelo]RepositoryImpl implements …` | `SongRepositoryImpl` |
| Casos de uso | Verbo + modelo + `UseCase`, método `execute` | `GetSongsUseCase`, `ToggleFavoriteUseCase` |
| Cliente HTTP | `[Modelo]Api` | `SongApi` |
| DTO | `[Modelo]Dto` con `factory fromJson` | `SongDto` |
| DAO | `[Modelo]Dao` | `FavoriteDao` |
| Estado de UI | `[Pantalla]UiState` con `copyWith` | `HomeUiState` |
| ViewModel | `[Pantalla]ViewModel extends ChangeNotifier` | `HomeViewModel` |
| Pantalla | `[Pantalla]Page` | `HomePage`, `LoginPage`, `SongDetailPage` |
| Componente | Sustantivo, junto a la pantalla | `SongCard` |
| Parámetros | Con nombre y `required` | `SongCard({required this.song, …})` |

El proyecto usa dos formas de constructor, según cuándo se escribió cada archivo. Las dos valen en Dart 3.13:

```dart
const GetSongsUseCase({required this.repository});   // forma clásica
const new({required this.repository});               // forma nueva, la más reciente en el repo
```

---

## 5. Patrones de codificación capa por capa

### 5.1. Capa de dominio

Clases inmutables, sin anotaciones y sin lógica de frameworks:

```dart
// features/home/domain/song.dart
class Song {
  final int id;
  final String title;
  final String artist;
  final String image;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.image,
  });
}
```

El contrato devuelve `Future` y no envuelve el resultado: si algo falla, lanza una excepción.

```dart
// features/home/domain/song_repository.dart
abstract class SongRepository {
  Future<List<Song>> getSongs();
}
```

EasySong no tiene Value Objects como `Money` o `ProductId`: es más pequeño que EasySneaker.

### 5.2. Capa de aplicación

Un caso de uso por acción. Recibe el repositorio por constructor y expone `execute`:

```dart
// features/home/application/get_songs_use_case.dart
class GetSongsUseCase {
  final SongRepository repository;

  const GetSongsUseCase({required this.repository});

  Future<List<Song>> execute() async {
    return await repository.getSongs();
  }
}
```

Puede contener una regla de negocio:

```dart
// features/favorites/application/toggle_favorite_use_case.dart
class ToggleFavoriteUseCase {
  final FavoriteRepository repository;
  const new({required this.repository});

  Future<void> execute(int id, bool isFavorite) {
    if (isFavorite) {
      return repository.removeFavorite(id);
    }
    return repository.addFavorite(id);
  }
}
```

### 5.3. Capa de infraestructura

#### Cliente HTTP y DTOs

```dart
// features/home/infrastructure/remote/song_api.dart
class SongApi {
  final String url =
      'https://songapi-fcbahjbha7dabkan.eastus-01.azurewebsites.net/api/songs';

  Future<List<SongDto>> getSongs() async {
    final Uri uri = Uri.parse(url);

    final http.Response response = await http.get(uri);

    if (response.statusCode == HttpStatus.ok) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List jsons = json['results'];

      return jsons.map((e) => SongDto.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load songs');
    }
  }
}

// features/home/infrastructure/remote/song_dto.dart
class SongDto {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String image;

  const new({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.image,
  });

  factory SongDto.fromJson(Map<String, dynamic> json) {
    return SongDto(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      image: json['image'],
    );
  }
}
```

#### Persistencia local con `sqflite`

La base se abre una vez y se crea con SQL. El DAO usa el `Database` directamente:

```dart
// core/app_database.dart
class AppDatabase {
  Future<Database>? _database;

  Future<Database> get database => _database ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final path = join(await getDatabasesPath(), 'easysong_db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('create table favorites (id integer primary key)');
    },);
  }
}

// features/favorites/infrastructure/favorite_dao.dart
class FavoriteDao {
  final Database database;

  const new({required this.database});

  Future<List<int>> getFavorites() async {
    final List maps = await database.query('favorites');
    return maps.map((map) => map['id'] as int).toList();
  }

  Future<void> addFavorite(int id) async {
    await database.insert('favorites', {
      'id': id,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeFavorite(int id) async {
    await database.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }
}
```

#### Repositorio

Convierte DTO → dominio. En EasySong, las canciones no se guardan localmente: **no hay offline-first**, a diferencia de EasySneaker.

```dart
// features/home/infrastructure/song_repository_impl.dart
class SongRepositoryImpl implements SongRepository {
  final SongApi api;

  const new({required this.api});

  @override
  Future<List<Song>> getSongs() async {
    final List<SongDto> dtos = await api.getSongs();

    return dtos
        .map(
          (e) =>
              Song(id: e.id, title: e.title, artist: e.artist, image: e.image),
        )
        .toList();
  }
}
```

#### Inyección de dependencias con `get_it`

Un único archivo, de abajo hacia arriba: base → DAO → repositorio → caso de uso → ViewModel. Se registra el **contrato** como tipo y la implementación como valor; eso equivale al `@Binds` de Hilt.

```dart
// core/di/dependency_injection.dart
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  getIt.registerSingletonAsync<Database>(
    () async => await getIt<AppDatabase>().database,
  );

  getIt.registerLazySingleton<FavoriteDao>(
    () => FavoriteDao(database: getIt<Database>()),
  );

  getIt.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(dao: getIt<FavoriteDao>()),
  );

  getIt.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(repository: getIt<FavoriteRepository>()),
  );

  // … SongApi, SongRepository, GetSongsUseCase, ToggleFavoriteUseCase

  getIt.registerLazySingleton<HomeViewModel>(
    () => HomeViewModel(
      useCase: getIt<GetSongsUseCase>(),
      getFavoritesUseCase: getIt<GetFavoritesUseCase>(),
      toggleFavoriteUseCase: getIt<ToggleFavoriteUseCase>(),
    ),
  );
}
```

### 5.4. Capa de presentación

#### Estado de UI

Clase inmutable con valores por defecto y `copyWith` escrito a mano:

```dart
// features/home/presentation/home_ui_state.dart
class HomeUiState {
  final List<Song> songs;
  final List<int> favoriteSongIds;
  final bool isLoading;
  final String? errorMessage;

  const HomeUiState({
    this.songs = const [],
    this.favoriteSongIds = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HomeUiState copyWith({
    List<Song>? songs,
    List<int>? favoriteSongIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeUiState(
      songs: songs ?? this.songs,
      favoriteSongIds: favoriteSongIds ?? this.favoriteSongIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

#### ViewModel

`ChangeNotifier` con el estado privado y un getter público. Cada cambio reemplaza el estado y avisa a la vista:

```dart
// features/home/presentation/home_view_model.dart
class HomeViewModel extends ChangeNotifier {
  final GetSongsUseCase useCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  HomeViewModel({
    required this.useCase,
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  }) {
    loadSongs();
  }

  HomeUiState _state = HomeUiState();
  HomeUiState get state => _state;

  List<Song> get favoriteSongs => _state.songs
            .where((song) => _state.favoriteSongIds.contains(song.id))
            .toList();

  Future<void> loadSongs() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final List<Song> songs = await useCase.execute();
      final List<int> favoriteSongIds = await getFavoritesUseCase.execute();
      _state = _state.copyWith(
        songs: songs,
        favoriteSongIds: favoriteSongIds,
        errorMessage: null,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
    notifyListeners();
  }
}
```

#### Pantalla

La página recibe el ViewModel por constructor y se redibuja con `ListenableBuilder`:

```dart
// features/home/presentation/home_page.dart
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.viewModel});
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        if (viewModel.state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: viewModel.state.songs.length,
          itemBuilder: (context, index) {
            final Song song = viewModel.state.songs[index];
            return SongCard(
              song: song,
              isFavorite: viewModel.isFavorite(song.id),
              onToggleFavorite: () {
                viewModel.toggleFavorite(song.id);
              },
            );
          },
        );
      },
    );
  }
}
```

Los componentes reciben datos y callbacks; no conocen al ViewModel (`SongCard` recibe `song`, `isFavorite` y `onToggleFavorite`). El estado puramente visual, como ocultar la contraseña en `LoginPage`, vive en un `StatefulWidget` con `setState`.

### 5.5. Navegación

`Navigator` imperativo, sin rutas con nombre. Los argumentos son parámetros del constructor, así que ya están tipados:

```dart
// Abrir un detalle (features/home/presentation/song_card.dart)
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SongDetailPage(song: song)),
);

// Cambiar de flujo sin poder volver (onboarding → login → main)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => MainPage()),
);
```

Las pestañas no usan rutas: `MainPage` guarda el índice con `setState` y muestra la página de una lista.

```dart
// features/main/main_page.dart
class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  late final List<Widget> pages = [
    HomePage(viewModel: getIt<HomeViewModel>()),
    FavoritesPage(viewModel: getIt<HomeViewModel>()),
    Text("Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        destinations: [ /* NavigationDestination por pestaña */ ],
      ),
    );
  }
}
```

### 5.6. Tema

`core/theme.dart` es la salida de **Material Theme Builder**: una clase `MaterialTheme` con todos los `ColorScheme` (claro, oscuro y contraste medio y alto). Se aplica en la raíz:

```dart
// main.dart
void main() {
  setupDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = TextTheme();
    return MaterialApp(
      theme: MaterialTheme(textTheme).light(),
      darkTheme: MaterialTheme(textTheme).dark(),
      debugShowCheckedModeBanner: false,
      home: OnboardingPage(),
    );
  }
}
```

Los íconos son los de Material (`Icons.home`). En los widgets, colores y textos salen de `Theme.of(context)`.

---

## 6. Guía paso a paso: cómo construir un feature

El profesor no lo documenta: este orden se deduce del código, tomando Favoritos, el ejemplo más completo:

1. **Dominio:** la entidad, si hace falta, y `abstract class FavoriteRepository`.
2. **Infraestructura:** tabla en `AppDatabase`, `FavoriteDao`, y `Api` + `Dto` si hay red. Luego `FavoriteRepositoryImpl`.
3. **Aplicación:** un `UseCase` por acción, con `execute`.
4. **Inyección:** registrar todo en `setupDependencies()`.
5. **Presentación:** `UiState`, `ViewModel` y `Page` con `ListenableBuilder`. Si el flujo ya tiene ViewModel se puede extender: Favoritos reutiliza `HomeViewModel`.
6. **Navegación:** agregar la página a `pages` y su `NavigationDestination` en `MainPage`, o abrirla con `Navigator.push`.

---

## 7. Patrones clave y límites del ejemplo

1. **Inversión de dependencias:** Page → ViewModel → UseCase → `abstract class`; la implementación vive en infraestructura.
2. **`get_it`:** un punto de registro, con el contrato como tipo y la implementación como valor.
3. **Estado:** privado, inmutable, reemplazado con `copyWith` y avisado con `notifyListeners()`.
4. **Sin generación de código:** DTOs, `copyWith` y SQL se escriben a mano.
5. **Navegación directa:** `Navigator.push` con la página y sus parámetros.

EasySong es un ejemplo de clase. Estos detalles funcionan en la demo, pero **no se deben copiar** a una app real como Atelier:

| Detalle en el repo | Por qué falla al crecer | Qué hacemos en Atelier |
| --- | --- | --- |
| `copyWith(errorMessage: null)` no borra el error: `null ?? this.errorMessage` conserva el anterior | Un error viejo sigue visible después de un reintento exitoso | Parámetro `clearError` ([05](05-flutter-architecture.md) §5.4) |
| `addFavorite` y `removeFavorite` del repositorio no hacen `await` al DAO | `toggleFavorite` vuelve a leer antes de que termine la escritura y un error de la base se pierde | Siempre `await` (o devolver el `Future`) |
| `registerSingletonAsync<Database>` sin esperar `allReady()` | `getIt<Database>()` falla si se pide antes de que abra la base | Drift abre la base de forma perezosa: basta un `registerLazySingleton` |
| Todos los ViewModels son singletons | Con varias cuentas, el siguiente usuario vería los datos del anterior; un detalle no puede tener un ViewModel por `id` | `registerFactory` y `dispose` al cerrar la página |
| Sin `dispose` en el ViewModel | Fugas al escuchar `Stream`s | `dispose` cancela las suscripciones |
| `errorMessage` no se muestra en ninguna pantalla | El usuario ve una lista vacía cuando falla la red | Estado de error en cada página |
| `flutter_launcher_icons` en `dependencies` | Es una herramienta y se empaqueta sin necesidad | Va en `dev_dependencies` |
| `flutter_launcher_icons.yaml` genera `web`, `windows` y `macos` con rutas de ejemplo (`path/to/image.png`) | El proyecto no tiene esas plataformas | Solo `android` e `ios` |
