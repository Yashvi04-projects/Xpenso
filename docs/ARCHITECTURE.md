# Xpenso Architecture & Design

## Overview
Xpenso is a modern expense tracking application built with **Flutter**, designed to help users manage their personal finances with ease and style.

## Technical Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider (MVVM Pattern)
- **Backend & Auth**: Firebase (Firestore, Firebase Auth)
- **UI Design**: Custom theming with Material 3 support
- **Architecture**: Clean Architecture inspired (Feature-based separation)

## Architecture Pattern
The application follows a **Feature-First** directory structure combined with **Clean Architecture** principles and **MVVM** (Model-View-ViewModel) for the presentation layer.

### 1. Layers
- **Presentation Integration**: UI Widgets (`Pages`, `Widgets`) subscribe to `Providers` (ViewModels).
- **Domain Layer**: Contains `Entities` (POJOs) and `Repositories` (Interfaces). This layer is independent of data sources.
- **Data Layer**: Implements `Repositories` and connects to `DataSources` (Firebase/Firestore).

### 2. Dependency Injection
`provider` package is used for Dependency Injection (DI) and State Management.
- `MultiProvider` in `main.dart` initializes all repositories and providers.
- `ProxyProvider` is used to inject dependencies (like `AuthRepository` into `ExpenseRepository`).

## Directory Structure
```
lib/
├── config/             # Routes, Themes, etc.
├── core/               # Constants, Utils, Shared Widgets
├── features/           # Feature-based modules
│   ├── auth/
│   ├── dashboard/
│   ├── expenses/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── ...
└── main.dart           # App Entry Point & DI Setup
```

## Key Design Features
- **Reactive UI**: Updates automatically via StreamSubscriptions from repositories.
- **Optimistic Updates**: UI updates immediately for better UX (e.g., toggling balance visibility).
- **Service Layer**: `ExpenseService` encapsulates business logic involving multiple repositories.

## For CV / Resume
**Project Description**: Developed a feature-rich expense tracker using Flutter and Firebase. Implemented MVVM architecture with Provider for efficient state management. Designed a responsive UI with dark mode support, real-time Firestore updates, and local notifications.
**Key Skills**: Flutter, Dart, Firebase (Auth/Firestore), Provider, Clean Architecture, Async Programming, UI/UX Design.
