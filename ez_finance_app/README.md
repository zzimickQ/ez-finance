# EZ Finance App

A production-ready Flutter application with Clean Architecture, implementing local-first data synchronization with remote backend.

## 🚀 Architecture Overview

This application follows **Clean Architecture** principles with **local-first** data synchronization strategy:

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Auth Bloc   │  │ Profile Bloc │  │ Home Screen  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │    User      │  │   Profile    │  │  Use Cases   │  │
│  │   Entity     │  │   Entity     │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Local Source │  │Remote Source │  │ Repository   │  │
│  │  (Drift DB)  │  │    (Dio)     │  │   Impl       │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    Local Database                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Users      │  │  Profiles    │  │ Sync Queue   │  │
│  │   Table      │  │   Table      │  │   Table      │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart          # Dio HTTP client
│   │   ├── api_endpoints.dart       # API endpoint constants
│   │   └── api_interceptor.dart     # Auth & logging interceptors
│   ├── database/
│   │   ├── app_database.dart        # Drift database
│   │   ├── tables/                 # Database tables
│   │   └── daos/                   # Data Access Objects
│   ├── error/
│   │   ├── failures.dart           # Failure classes
│   │   └── exceptions.dart         # Exception classes
│   ├── network/
│   │   └── network_info.dart       # Connectivity checker
│   ├── router/
│   │   ├── app_router.dart         # go_router configuration
│   │   └── route_names.dart        # Route constants
│   ├── sync/
│   │   └── sync_manager.dart       # Background sync orchestrator
│   └── theme/
│       └── app_theme.dart          # Material theme config
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── profile/
│   │   └── ... (same structure)
│   └── home/
│       └── ... (same structure)
├── injection_container.dart        # GetIt DI setup
├── app.dart                       # MaterialApp
└── main.dart                      # Entry point
```

## 🛠️ Technology Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| **flutter_bloc** | ^9.1.1 | State management |
| **go_router** | ^17.2.0 | Navigation & routing |
| **dio** | ^5.9.2 | HTTP client |
| **drift** | ^2.32.1 | Local SQLite database |
| **drift_flutter** | ^0.3.0 | Drift Flutter integration |
| **flutter_secure_storage** | ^10.0.0 | Secure token storage |
| **get_it** | ^9.2.1 | Dependency injection |
| **connectivity_plus** | ^7.1.0 | Network status |
| **uuid** | ^4.5.3 | UUID generation |
| **equatable** | ^2.0.8 | Value equality |

## 🔄 Local-First Sync Strategy

### Data Flow

**Write Operations:**
```
User Action → Local DB (immediate) → SyncQueue → Background Sync → Remote
     ↓
   Instant UI update (optimistic)
```

**Read Operations:**
```
Local DB (instant) → UI → Background Fetch → Merge (if needed)
```

### Sync Manager Features

- ✅ Automatic background sync when online
- ✅ Pending operations queue with retry logic
- ✅ Conflict resolution (last-write-wins)
- ✅ Network status awareness
- ✅ Sync status indicators

## 📱 Features Implemented

### ✅ Authentication
- Welcome screen
- Login with email/password
- Form validation
- Token storage (JWT & Session)
- Auto-login check on app start
- Logout functionality

### ✅ Profile Management
- View profile details
- Edit profile (name, phone, address, DOB)
- Profile picture placeholder
- Real-time sync status
- Pull-to-refresh
- Optimistic UI updates

### ✅ Home Dashboard
- Bottom navigation bar
- Dashboard tab (placeholder)
- Profile tab
- Logout from dashboard

### ✅ Core Infrastructure
- Clean Architecture structure
- Dependency Injection with GetIt
- Route guards with go_router
- Error handling & exceptions
- Network connectivity monitoring
- Background sync orchestration

## 🎯 API Endpoints

The app is configured to connect to: `http://localhost:3000/`

| Feature | Method | Endpoint |
|---------|--------|----------|
| Login | POST | `/api/auth/login` |
| Logout | POST | `/api/auth/logout` |
| Refresh Token | POST | `/api/auth/refresh` |
| Current User | GET | `/api/auth/me` |
| Get Profile | GET | `/api/user/profile` |
| Update Profile | PUT | `/api/user/profile` |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.11.4
- Dart SDK ^3.11.4

### Installation

```bash
# Navigate to project directory
cd ez_finance_app

# Get dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Build for Production

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# iOS build
flutter build ios --release
```

## 📋 Configuration

### Update API Base URL
Edit `lib/core/api/api_endpoints.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com/';
```

### Database
The app uses Drift with SQLite. Database is automatically created on first run.

### Authentication
The app supports both JWT and Session-based authentication:
- **JWT**: Access token stored in `access_token` key
- **Session**: Session token stored in `session_token` key

## 🎨 Theme

The app uses Material Design 3 with dynamic theming:
- Light theme (default)
- Dark theme (based on system setting)

## 📝 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🐛 Known Issues

- Print statements in production code (marked as info warnings)
- EncryptedSharedPreferences deprecation warning (non-breaking)

## 📚 Documentation

For detailed documentation on each component:
- [Clean Architecture Guide](docs/clean_architecture.md)
- [Sync Strategy](docs/sync_strategy.md)
- [API Documentation](docs/api.md)

## 🤝 Contributing

1. Follow Clean Architecture principles
2. Use BLoC for state management
3. Add proper error handling
4. Write unit tests for use cases
5. Update this README when adding features

## 📄 License

Private - All rights reserved
