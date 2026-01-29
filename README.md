# Task Manager App - Flutter Technical Assessment

A well-architected task management application built with Flutter, following Clean Architecture principles and modern development practices.

## Features

- ✅ User Authentication (Login with DummyJSON API)
- ✅ Task Management (View, Add, Edit, Delete)
- ✅ Pagination for efficient data loading
- ✅ Secure session persistence
- ✅ Local caching for offline access
- ✅ Dark mode support with theme persistence
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
│   ├── settings/             # Settings feature
│   │   ├── data/             # Theme preferences
│   │   └── presentation/     # Theme management
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

## Architectural Decisions

### 1. Clean Architecture
**Decision**: Implemented Clean Architecture with three distinct layers
- **Reasoning**: Ensures testability, maintainability, and independence from frameworks
- **Trade-off**: More boilerplate, but better long-term scalability

### 2. Repository Pattern with Either Type
**Decision**: Used fpdart's Either type for error handling instead of try-catch
- **Reasoning**: Functional approach forces explicit error handling at every layer
- **Benefit**: No silent failures, compile-time error handling verification

### 3. Separate Data Sources (Remote + Local)
**Decision**: Split data sources into remote and local with repository as coordinator
- **Reasoning**: Supports offline-first strategy and clear separation of concerns
- **Implementation**: Repository decides whether to fetch from network or cache

### 4. BLoC for State Management
**Decision**: Chose BLoC over Provider, Riverpod, or GetX
- **Reasoning**: Well-established pattern, excellent testability, reactive by nature
- **Benefit**: Clear separation between business logic and UI

### 5. Manual Dependency Injection
**Decision**: Manual DI in main.dart instead of get_it or injectable
- **Reasoning**: Simpler for smaller apps, no code generation overhead
- **Trade-off**: More verbose but more explicit and easier to trace

### 6. GoRouter with Authentication Guards
**Decision**: GoRouter with redirect logic for authentication
- **Reasoning**: Type-safe navigation, built-in deep linking support
- **Benefit**: Declarative routing with automatic authentication checks

### 7. Pagination with Cumulative Loading
**Decision**: Accumulate paginated data in BLoC instead of replacing it
- **Reasoning**: Better UX with infinite scroll, maintains scroll position
- **Implementation**: PaginatedResponseModel with metadata tracking

## State Management

The app uses **BLoC (Business Logic Component) pattern** for state management, providing:

### Benefits
- **Predictable State**: Unidirectional data flow
- **Separation of Concerns**: Business logic separated from UI
- **Testability**: Easy to test state transitions
- **Reactive**: Stream-based architecture

### Implementation Details

#### AuthenticationBloc
- **States**: Initial, Loading, Authenticated, Unauthenticated, LoginSuccess, LoginError, LogoutSuccess
- **Events**: LoginEvent, CheckAuthenticationStatusEvent, LogoutEvent, GetCurrentUserEvent
- **Features**:
  - Session persistence check on app startup
  - Automatic token management
  - Cached user data handling

#### TodosBloc
- **States**: Initial, Loading, LoadingMore, Loaded, OperationLoading, AddedSuccess, UpdatedSuccess, DeletedSuccess, Error
- **Events**: LoadTodosEvent, AddTodoEvent, UpdateTodoEvent, DeleteTodoEvent, LoadCachedTodosEvent
- **Features**:
  - Pagination with cumulative data loading
  - Optimistic UI updates
  - Local cache fallback on errors
  - Separate operation states to prevent list refresh on CRUD operations

#### ThemeCubit
- **States**: ThemeState with themeMode (light/dark/system) and loading status
- **Features**:
  - Theme mode persistence using local storage
  - System theme support (follows device settings)
  - Seamless theme switching with reactive UI updates
  - Lightweight Cubit for simpler state management

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

The application has comprehensive test coverage across all layers following best practices.

### Running Tests

```bash
# Run all tests
flutter test

# Run feature-specific tests
flutter test test/features/todos/
flutter test test/features/authentication/

# Run with coverage
flutter test --coverage
```

### Test Suite Overview

**Total: 76 tests** covering all layers of the application

#### Authentication Feature Tests (41 tests)
- **Remote Data Source (5 tests)**: API calls, parameter handling
- **Local Data Source (19 tests)**: Token storage, user caching, credentials management
- **Repository (11 tests)**: Business logic, error handling, data flow
- **BLoC (14 tests)**: State transitions, authentication flows, error scenarios

#### Todos Feature Tests (35 tests)
- **Remote Data Source (6 tests)**: CRUD operations, pagination
- **Local Data Source (4 tests)**: Cache management, empty state handling
- **Repository (12 tests)**: Data synchronization, error handling
- **BLoC (14 tests)**: State management, pagination logic, CRUD operations

### Testing Approach

- **Fixture-based testing**: JSON fixtures for consistent test data
- **Mocktail**: Type-safe mocking with fallback values
- **bloc_test**: Specialized BLoC testing utilities
- **Either pattern testing**: Functional error handling verification
- **Edge case coverage**: Nulls, exceptions, network errors

## Challenges & Solutions

### 1. Dynamic Token Management
**Challenge**: Network provider needs to inject auth tokens dynamically after login
**Solution**: 
- Implemented callback-based token updates in NetworkProvider
- Repository calls `onTokenUpdate` after successful login
- All subsequent API calls automatically include the token

### 2. Pagination State Management
**Challenge**: Managing cumulative pagination data without losing previous items
**Solution**:
- Created PaginatedResponseModel with metadata (page, size, total, hasNext)
- BLoC maintains `_currentTodos` list and merges with new pages
- Used List.from() to prevent mutation of shared list references in tests
- Separate LoadingMore state to show loading indicator while preserving existing items

### 3. Offline-First Architecture
**Challenge**: App should work with cached data when offline
**Solution**:
- Repository tries network first, falls back to cache on error
- Local data source methods return Either types for consistent error handling
- Error states can include cached data for graceful degradation

### 4. Test Data Isolation
**Challenge**: Tests were sharing mutable list references causing cross-test pollution
**Solution**:
- Used helper functions to create fresh data for each test (getTodosList(), getPaginatedResponse())
- Made TodosLoadingMore pass List.from() instead of direct reference
- Repository and BLoC always create copies when assigning lists

### 5. Type-Safe Mocking with Mocktail
**Challenge**: Mocktail requires fallback values for non-nullable types
**Solution**:
- Created Fake implementations (FakeUser, FakeLoginCredentials, FakeTodoItem)
- Registered fallback values in setUpAll() for all tests
- Ensured type safety while maintaining test simplicity

### 6. Async Operations in BLoC Error Handling
**Challenge**: BLoC fold() wasn't awaiting async callbacks, causing emit-after-completion errors
**Solution**:
- Changed from fold() to match() for proper async/await support
- Made both success and error branches async
- Fixed nested async operations in error handling (checking cache on API failure)

### 7. Session Persistence
**Challenge**: User should stay logged in across app restarts
**Solution**:
- Check authentication status on app startup in splash screen
- Store tokens in secure storage, user data in shared preferences
- Automatic navigation based on authentication state

### 8. Partial Update Support for Todos
**Challenge**: API supports partial updates, need to send only changed fields
**Solution**:
- Repository updateTodo accepts optional parameters
- Only includes non-null values in request body
- Tests verify partial updates work correctly

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
- `bloc_test` - BLoC testing utilities
- `mocktail` - Type-safe mocking framework

## Code Quality

- ✅ Clean Architecture principles
- ✅ SOLID principles
- ✅ DRY code
- ✅ Comprehensive error handling
- ✅ Type safety with sound null safety
- ✅ 76 comprehensive unit tests
- ✅ Fixture-based testing approach
- ✅ Functional error handling with Either

## Additional Features & Improvements

### Enhanced Features
1. **Dark Mode Support**: Complete theme system with light, dark, and system modes
   - Theme-aware color scheme throughout the app
   - Persistent theme preference using local storage
   - Easy theme switching via settings dialog
   - All colors use theme-based values for automatic adaptation
2. **Comprehensive Error States**: Error UI with cached data fallback when network fails
3. **Loading States Granularity**: Separate states for initial loading vs. pagination loading vs. operation loading
4. **Optimistic Updates**: CRUD operations don't refresh the entire list, maintaining user's scroll position
5. **Session Timeout Handling**: Automatic logout on 401 errors with navigation to login
6. **Username Trimming**: Automatic whitespace removal from login inputs
7. **Custom Expiration**: Support for custom token expiration time in login

### Code Quality Improvements
1. **Fixture-Based Testing**: JSON fixtures for consistent test data across all test suites
2. **Test Helper Utilities**: Reusable FixtureHelper for loading test data
3. **Comprehensive Test Coverage**: 76 tests covering all layers (data sources, repositories, BLoC)
4. **Type-Safe Error Handling**: Either pattern used consistently across all layers
5. **Const Constructors**: Extensive use of const for better performance
6. **Code Organization**: Clear feature-based folder structure following Clean Architecture

### Developer Experience
1. **Clear Separation of Concerns**: Each layer has a single responsibility
2. **Testable Architecture**: Easy to mock and test any component in isolation
3. **Functional Error Handling**: No exceptions thrown, all errors handled explicitly
4. **Self-Documenting Code**: Clear naming conventions and interfaces
5. **Build Runner Integration**: Automatic code generation for mappers

### Performance Optimizations
1. **Pagination**: Loads data in chunks to reduce memory footprint
2. **List Copying Strategy**: Strategic use of List.from() to prevent mutations
3. **Const Constructors**: Throughout UI for widget reusability
4. **Cached Data**: Reduces unnecessary network calls
5. **Lazy Loading**: Data loaded only when needed

## Testing Strategy

### Test Structure
All tests follow a consistent pattern:
- **Arrange**: Set up test data and mocks
- **Act**: Execute the operation being tested
- **Assert**: Verify the outcome

### Test Categories
1. **Unit Tests**: Individual functions and methods
2. **Integration Tests**: Repository layer with multiple data sources
3. **BLoC Tests**: State transition verification with bloc_test
4. **Edge Cases**: Null handling, empty states, error scenarios

## Important Notes

### DummyJSON API Limitations
The DummyJSON API simulates backend operations but doesn't persist data permanently:
- Created/updated/deleted todos are simulated responses
- Data will not persist across sessions or between different users
- The API returns realistic responses for testing purposes

### Future Improvements
- [ ] Integration tests for UI flows
- [ ] Widget tests for key screens
- [ ] CI/CD pipeline with automated testing
- [ ] Code coverage reporting
- [ ] Performance profiling and optimization
- [ ] Accessibility improvements
- [ ] Internationalization (i18n)

---

**Architecture**: Clean Architecture  
**State Management**: BLoC Pattern  
**Framework**: Flutter 3.10.1+  
**Test Coverage**: 76 tests across all layers
