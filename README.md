# Task Manager App - Flutter Technical Assessment

A well-architected task management application built with Flutter, following Clean Architecture principles and modern development practices.

## Features

- ✅ User Authentication (Login with DummyJSON API)
- ✅ Task Management (View, Add, Edit, Delete)
- ✅ Pagination for efficient data loading
- ✅ Secure session persistence
- ✅ Local caching for offline access
- ✅ Clean Architecture implementation
- ✅ State management with Bloc/Cubit
- ✅ Protected routing with GoRouter

## Project Setup

### Prerequisites

- Flutter SDK (3.10.1 or higher)
- Dart SDK
- IDE (VS Code or Android Studio)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd todo_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate mapper files for dart_mappable:
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

### Test Credentials

Use the following credentials to log in:
- **Username**: `emilys`
- **Password**: `emilyspass`

## Project Structure

The project follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/                      # Shared/core functionality
│   ├── data/
│   │   ├── models/           # Shared models (PaginatedResponse)
│   │   └── repositories/     # Base repository with error handling
│   ├── network/              # Network layer
│   │   ├── network_provider.dart    # Dio HTTP client
│   │   ├── endpoints.dart           # API endpoints
│   │   └── error/                   # Error handling
│   └── session/
│       └── session_manager.dart     # Session state management
│
├── features/                  # Feature modules
│   ├── authentication/        # Auth feature
│   │   ├── data/             # Data layer
│   │   │   ├── datasources/  # Remote & Local data sources
│   │   │   ├── models/       # Data models
│   │   │   └── repositories/ # Repository implementation
│   │   ├── domain/           # Domain layer
│   │   │   └── repositories/ # Repository interface
│   │   └── presentation/     # Presentation layer
│   │       ├── bloc/         # State management
│   │       └── views/        # UI screens
│   │
│   └── todos/                # Todos feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── global/                    # App-wide resources
│   ├── routes/               # Routing configuration
│   └── theme/                # Theme and styling
│
└── main.dart                 # App entry point & DI setup
```

## Architecture

### Clean Architecture Layers

1. **Domain Layer** - Business logic and entities
2. **Data Layer** - Data management (API + Cache)
3. **Presentation Layer** - UI and state management

### Key Design Patterns

- **Repository Pattern**: Abstracts data sources
- **Bloc Pattern**: Predictable state management
- **Dependency Injection**: Manual DI in main.dart
- **Either Type (fpdart)**: Functional error handling

## State Management

The app uses **Bloc pattern** for state management with clear separation:

- **AuthenticationBloc**: Login, logout, session management
- **TodosBloc**: CRUD operations, pagination

## Routing & Navigation

Uses **GoRouter** with:
- Authentication guards
- Protected routes
- Type-safe navigation

## Data Persistence

- **Secure Storage**: Auth tokens (flutter_secure_storage)
- **Local Cache**: Todos and user data (shared_preferences)

## API Integration

Integrates with **DummyJSON API**:
- Authentication endpoints
- Todos CRUD operations
- Pagination support

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Test Coverage

- ✅ Authentication logic
- ✅ Todo CRUD operations
- ✅ Bloc state transitions
- ✅ Error handling
- ✅ Input validation

## Challenges & Solutions

1. **State Management**: Implemented Bloc with clear state transitions
2. **Token Management**: NetworkProvider with dynamic token injection
3. **Pagination**: Skip/limit with local caching
4. **Offline Support**: Local-first approach with API sync
5. **Type Safety**: dart_mappable for serialization

## Dependencies

### Core
- `flutter_bloc` - State management
- `go_router` - Routing
- `fpdart` - Functional programming

### Network & Storage
- `dio` - HTTP client
- `flutter_secure_storage` - Secure storage
- `shared_preferences` - Local cache

### Serialization
- `dart_mappable` - JSON serialization

### Testing
- `bloc_test` - Bloc testing
- `mockito` - Mocking

## Code Quality

- ✅ Clean Architecture principles
- ✅ SOLID principles
- ✅ DRY code
- ✅ Comprehensive error handling
- ✅ Type safety
- ✅ Unit tests

## Additional Notes

**Note about DummyJSON API**: The DummyJSON API simulates backend operations but doesn't persist data permanently. Created/updated/deleted todos are simulated and will not persist across sessions.

---

**Architecture**: Clean Architecture  
**State Management**: Bloc Pattern  
**Framework**: Flutter 3.10.1
