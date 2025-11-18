---
description: Repository Information Overview
alwaysApply: true
---

# TimeBoxer Information

## Summary
TimeBoxer is a Flutter-based time management application that integrates calendar and timeboxing features into a unified daily planner view. It supports task management, time blocking templates, and Firebase integration for authentication and data storage.

## Structure
The project follows standard Flutter architecture with:
- **lib/**: Main application code organized into models, providers, screens, services, and widgets
- **android/**, **ios/**, **linux/**, **macos/**, **windows/**: Platform-specific configurations and build files
- **test/**: Widget tests
- **web/**: Web platform assets and configuration

## Language & Runtime
**Language**: Dart  
**Version**: SDK ^3.9.2  
**Build System**: Flutter  
**Package Manager**: pub (Dart package manager)

## Dependencies
**Main Dependencies**:
- flutter: SDK
- flutter_riverpod: ^3.0.3 (State management)
- uuid: ^4.5.2 (Unique identifiers)
- intl: ^0.20.2 (Internationalization)
- hive: ^2.2.3 (Local database)
- hive_flutter: ^1.1.0 (Flutter integration for Hive)
- path_provider: ^2.1.5 (File system paths)
- fl_chart: ^1.1.1 (Charts and graphs)
- table_calendar: ^3.2.0 (Calendar widget)
- firebase_core: ^4.2.1 (Firebase core)
- firebase_auth: ^6.1.2 (Firebase authentication)
- cloud_firestore: ^6.1.0 (Firebase Firestore)

**Development Dependencies**:
- flutter_test: SDK
- flutter_lints: ^6.0.0 (Linting rules)
- hive_generator: ^2.0.1 (Hive code generation)

## Build & Installation
```bash
# Install dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run the application
flutter run
```

## Testing
**Framework**: flutter_test (Flutter's built-in testing framework)  
**Test Location**: test/  
**Naming Convention**: *_test.dart  
**Configuration**: analysis_options.yaml (includes flutter_lints)  
**Run Command**:
```bash
flutter test
```