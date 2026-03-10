# Preview 5: Complete MVVM Architecture Guide - Spotify Clone App

## Table of Contents

1. [Introduction](#introduction)
2. [MVVM Architecture Deep Dive](#mvvm-architecture-deep-dive)
3. [Understanding AuthViewModel](#understanding-authviewmodel)
4. [Auth Remote Repository vs Local Repository](#auth-remote-repository-vs-local-repository)
5. [User Model Explained](#user-model-explained)
6. [Complete App Flow](#complete-app-flow)
7. [How to Use AuthViewModel in Widgets/Screens](#how-to-use-authviewmodel-in-widgetsscreens)
8. [Data Flow Architecture](#data-flow-architecture)
9. [Step-by-Step Implementation Guide](#step-by-step-implementation-guide)
10. [Common Patterns and Best Practices](#common-patterns-and-best-practices)
11. [Troubleshooting and Common Issues](#troubleshooting-and-common-issues)

---

## Introduction

This document provides a comprehensive, detailed explanation of the Spotify Clone Flutter application's architecture. By the end of this document, you will have a complete understanding of:

- What MVVM architecture is and how it works
- The role and structure of AuthViewModel
- The difference between Auth Remote Repository and Auth Local Repository
- How the User Model works
- How data flows through the application
- How to properly use AuthViewModel in your widgets and screens

This is a deep-dive technical document designed to help you understand every aspect of the codebase and how to extend it.

---

## MVVM Architecture Deep Dive

### What is MVVM?

**MVVM (Model-View-ViewModel)** is an architectural pattern that separates an application into three main components:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         MVVM Architecture                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│    ┌─────────────┐         ┌─────────────┐         ┌─────────────┐   │
│    │    View     │◄───────►│  ViewModel  │◄───────►│    Model    │   │
│    │  (UI Layer) │         │ (Business   │         │  (Data      │   │
│    │             │         │   Logic)    │         │  Layer)     │   │
│    └─────────────┘         └─────────────┘         └─────────────┘   │
│                                                                         │
│    - Flutter Widgets    - State Management      - Data Models         │
│    - Screens           - Repository Calls       - API Responses       │
│    - User Input        - Data Transformation    - JSON Parsing       │
│    - Display Logic     - Validation              - Business Rules     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Why MVVM for Flutter?

Flutter is already reactive - when state changes, the UI rebuilds automatically. MVVM works perfectly with this paradigm because:

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Testability**: ViewModels can be tested independently without UI
3. **Maintainability**: Changes in one layer don't affect others
4. **Reusability**: ViewModels can be reused across different views
5. **Scalability**: Easy to add new features without breaking existing code

### Components of MVVM in This Project

#### 1. Model Layer (Data)

The Model layer represents the data and business logic. In this project:

```dart
// Location: lib/features/auth/model/user_model.dart

class UserModel {
  final String email;
  final String name;
  final String id;
  final String? token;

  UserModel({
    required this.email,
    required this.name,
    required this.id,
    required this.token,
  });
}
```

The Model:
- Is a plain Dart class (data carrier)
- Contains no UI or display logic
- Handles data serialization (JSON)
- Defines data structure

#### 2. View Layer (UI)

The View layer displays data and handles user interactions:

```dart
// Location: lib/features/auth/view/pages/signup_page.dart

class SignUpPage extends ConsumerStatefulWidget {
  // This is the View - it displays UI and captures user input
}
```

The View:
- Is composed of Flutter widgets
- Captures user input
- Calls ViewModel methods for actions
- Rebuilds when state changes
- Contains NO business logic

#### 3. ViewModel Layer (Business Logic)

The ViewModel acts as a bridge between Model and View:

```dart
// Location: lib/features/auth/viewmodel/auth_viewmodel.dart

@riverpod
class AuthViewModel extends _$AuthViewModel {
  // This is the ViewModel - handles business logic
}
```

The ViewModel:
- Manages application state
- Contains business logic
- Calls repositories for data
- Transforms data for the View
- Handles validation

---

## Understanding AuthViewModel

### What is AuthViewModel?

`AuthViewModel` is a **Riverpod Notifier** that manages the authentication state of the application. It serves as the central hub for all authentication-related operations.

### Complete Code Breakdown

```dart
// lib/features/auth/viewmodel/auth_viewmodel.dart

import 'package:client/features/auth/model/user_model.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/auth/repositories/auth_remote_repositories.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  // These are the dependencies - injected via Riverpod
  _authRemoteRepositories late AuthRemoteRepositories;
  late AuthLocalRepository _authLocalRepository;

  @override
  AsyncValue<UserModel>? build() {
    // This runs when the provider is first created
    // It sets up dependencies and returns initial state
    _authRemoteRepositories = ref.watch(authRemoteRepositoriesProvider);
    _authLocalRepository = ref.watch(authLocalRepositoriesProvider);

    return null; // Initial state - no user logged in
  }

  // Method to initialize SharedPreferences
  Future<void> initSharedPrefrences() async {
LocalRepository.init();
  }

  //    await _auth Method to sign up a new user
  Future<void> signUpuser({
    required String name,
    required String email,
    required String password,
  }) async {
    // 1. Set loading state
    state = const AsyncValue.loading();

    // 2. Call remote repository
    final res = await _authRemoteRepositories.signup(
      name: name,
      email: email,
      password: password,
    );

    // 3. Handle the result using pattern matching
    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(
        l.message,
        StackTrace.current,
      ),
      Right(value: final r) => state = AsyncValue.data(r),
    };

    print(val);
  }

  // Method to sign in an existing user
  Future<void> signInUser({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final res = await _authRemoteRepositories.login(
      email: email,
      password: password,
    );

    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(
        l.message,
        StackTrace.current,
      ),
      Right(value: final r) => _loginSuccess(r), // Special handling for login
    };

    print(val);
  }

  // Private method to handle successful login
  AsyncValue<UserModel>? _loginSuccess(UserModel user) {
    // Save token to local storage
    _authLocalRepository.setToken(user.token);
    return state = AsyncValue.data(user);
  }

  // Method to get logged in user data
  Future<UserModel?> getData() async {
    state = const AsyncValue.loading();

    // Get token from local storage
    final token = _authLocalRepository.getToken();

    if (token != null) {
      // If token exists, fetch user data
      final res = await _authRemoteRepositories.getLoggedInUser(token);

      final val = switch (res) {
        Left(value: final l) => state = AsyncValue.error(
          l.message,
          StackTrace.current,
        ),
        Right(value: final r) => state = AsyncValue.data(r),
      };

      return val.value;
    }
    return null;
  }
}
```

### What is AsyncValue<UserModel>?

`AsyncValue<UserModel>` is a Riverpod type that represents the state of an asynchronous operation. It can be in one of three states:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      AsyncValue<UserModel> States                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐ │
│  │     Loading      │    │      Data        │    │      Error       │ │
│  │                  │    │    (Success)     │    │                  │ │
│  └──────────────────┘    └──────────────────┘    └──────────────────┘ │
│                                                                         │
│  state =                state =                  state =               │
│  AsyncValue.loading()  AsyncValue.data(user)   AsyncValue.error(      │
│                                                    error,              │
│                                                    stackTrace           │
│                                                  )                     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Why Use AuthViewModel?

1. **State Management**: It manages the authentication state across the app
2. **Single Source of Truth**: All auth-related logic is in one place
3. **Reactive Updates**: The UI automatically updates when state changes
4. **Dependency Injection**: Dependencies are injected via Riverpod

---

## Auth Remote Repository vs Local Repository

This is a crucial concept to understand. The app has TWO separate repositories for authentication:

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Repository Pattern Architecture                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│    ┌─────────────────────────────────────────────────────────────────┐  │
│    │                        ViewModel Layer                          │  │
│    │                    (AuthViewModel)                              │  │
│    └─────────────────────────────┬───────────────────────────────────┘  │
│                                  │                                       │
│           ┌──────────────────────┼──────────────────────┐              │
│           │                      │                      │              │
│           ▼                      ▼                      ▼              │
│    ┌─────────────┐     ┌─────────────────┐     ┌─────────────────┐      │
│    │    View     │     │ AuthRemoteRepo  │     │ AuthLocalRepo   │      │
│    │   Layer    │     │   (API Calls)   │     │  (Storage)      │      │
│    └─────────────┘     └────────┬────────┘     └────────┬────────┘      │
│                                 │                      │                │
│                                 ▼                      ▼                │
│                        ┌─────────────────┐     ┌─────────────────┐      │
│                        │  Backend API   │     │ SharedPreferences│      │
│                        │ (FastAPI)     │     │ (Local Storage) │      │
│                        └─────────────────┘     └─────────────────┘      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Auth Remote Repository

**File**: [`lib/features/auth/repositories/auth_remote_repositories.dart`](lib/features/auth/repositories/auth_remote_repositories.dart)

The Remote Repository handles **all communication with the backend server**. This includes:

- Making HTTP requests
- Sending user credentials
- Receiving user data
- Handling API errors

```dart
class AuthRemoteRepositories {
  // 1. SIGN UP - Creates a new user account
  Future<Either<AppFailure, UserModel>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    // Make HTTP POST request to /auth/signup
    final response = await http.post(
      Uri.parse('${ServerConstant.serverURL}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    // Parse response
    final resBodyMap = json.decode(response.body) as Map<String, dynamic>;

    // Check for errors
    if (response.statusCode != 201) {
      return Left(AppFailure(resBodyMap['detail'].toString()));
    }

    // Return success with user data
    return Right(UserModel.fromMap(resBodyMap));
  }

  // 2. LOGIN - Authenticates existing user
  Future<Either<AppFailure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    // Make HTTP POST request to /auth/login
    final response = await http.post(
      Uri.parse('${ServerConstant.serverURL}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final resBodyMap = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      return Left(AppFailure(resBodyMap['detail'].toString()));
    }

    // Return user data with token
    return Right(
      UserModel.fromMap(resBodyMap["user"]).copyWith(token: resBodyMap["token"]),
    );
  }

  // 3. GET LOGGED IN USER - Fetches current user data using token
  Future<Either<AppFailure, UserModel>> getLoggedInUser(String token) async {
    // Make HTTP GET request with authentication token
    final response = await http.get(
      Uri.parse('${ServerConstant.serverURL}/auth/'),
      headers: {'x-auth-token': token},
    );

    final resBodyMap = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      return Left(AppFailure(resBodyMap['detail'].toString()));
    }

    return Right(UserModel.fromMap(resBodyMap["user"]));
  }
}
```

**When to use AuthRemoteRepository:**
- User signs up
- User logs in
- Fetching user profile data
- Any operation that requires server communication

---

### Auth Local Repository

**File**: [`lib/features/auth/repositories/auth_local_repository.dart`](lib/features/auth/repositories/auth_local_repository.dart)

The Local Repository handles **local storage** on the device. This includes:

- Storing authentication tokens
- Reading stored tokens
- Managing persistent data

```dart
class AuthLocalRepository {
  late SharedPreferences _sharedPreferences;

  // 1. Initialize SharedPreferences (must be called before using)
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // 2. Save token to local storage
  void setToken(String? token) {
    if (token != null) {
      _sharedPreferences.setString('X-auth-token', token);
    }
  }

  // 3. Get token from local storage
  String? getToken() {
    return _sharedPreferences.getString('X-auth-token');
  }
}
```

**When to use AuthLocalRepository:**
- After successful login (save token)
- On app startup (check if user is logged in)
- Any operation that needs to persist data locally

---

### Why Have Both Repositories?

```
┌─────────────────────────────────────────────────────────────────────────┐
│                  Why Two Repositories?                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  AUTH REMOTE REPOSITORY                    AUTH LOCAL REPOSITORY       │
│  ──────────────────────────                ─────────────────────────  │
│                                                                         │
│  • Communication with server              • Local data storage         │
│  • API calls                              • Token management           │
│  • Data from server                       • User preferences           │
│  • Network required                       • Works offline              │
│  • Slower (network latency)               • Fast (instant access)     │
│                                                                         │
│  EXAMPLES:                                     EXAMPLES:                │
│  • "Register new user"                      • "Save login token"        │
│  • "Get user profile"                       • "Check if user logged in" │
│  • "Login with credentials"                 • "Store theme preference" │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## User Model Explained

**File**: [`lib/features/auth/model/user_model.dart`](lib/features/auth/model/user_model.dart)

The UserModel is a data class that represents a user in the system:

```dart
class UserModel {
  // All fields that come from the backend
  final String email;      // User's email address
  final String name;       // User's display name
  final String id;         // Unique identifier
  final String? token;     // Authentication token (optional)

  // Constructor with required parameters
  UserModel({
    required this.email,
    required this.name,
    required this.id,
    required this.token,
  });
}
```

### Why is UserModel Important?

1. **Type Safety**: Strongly typed user data throughout the app
2. **Serialization**: Easy conversion to/from JSON
3. **Immutability**: Can be safely shared across the app
4. **Validation**: Can add validation methods

### JSON Serialization Methods

The UserModel includes several methods for JSON handling:

```dart
// Convert to Map (for JSON encoding)
Map<String, dynamic> toMap() {
  return <String, dynamic>{
    'email': email,
    'name': name,
    'id': id,
  };
}

// Create from Map (for JSON decoding)
factory UserModel.fromMap(Map<String, dynamic> map) {
  return UserModel(
    email: map['email'] ?? "",
    name: map['name'] ?? "",
    id: map['id'] ?? "",
    token: map['token'] ?? "",
  );
}

// Convert to JSON string
String toJson() => json.encode(toMap());

// Create from JSON string
factory UserModel.fromJson(String source) =>
    UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
```

### copyWith Method

```dart
// Create a copy with modified fields
UserModel copyWith({
  String? email,
  String? name,
  String? id,
  String? token,
}) {
  return UserModel(
    email: email ?? this.email,
    name: name ?? this.name,
    id: id ?? this.id,
    token: token ?? this.token,
  );
}

// Usage example:
// Original: UserModel(email: "a@b.com", name: "John", id: "1", token: null)
// After:    user.copyWith(token: "abc123")
// Result:   UserModel(email: "a@b.com", name: "John", id: "1", token: "abc123")
```

---

## Complete App Flow

### Application Startup Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      Application Startup Flow                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. main() called                                                      │
│      │                                                                  │
│      ▼                                                                  │
│  2. WidgetsFlutterBinding.ensureInitialized()                         │
│      │  (Prepares Flutter for async operations)                        │
│      ▼                                                                  │
│  3. ProviderContainer created                                          │
│      │  (Creates Riverpod container for DI)                            │
│      ▼                                                                  │
│  4. authViewModelProvider.notifier.initSharedPrefrences()              │
│      │  (Initializes local storage)                                    │
│      ▼                                                                  │
│  5. authViewModelProvider.notifier.getData()                           │
│      │  (Checks for existing token and fetches user)                   │
│      ▼                                                                  │
│  6. runApp() with UncontrolledProviderScope                            │
│      │  (Starts the app with Riverpod)                                 │
│      ▼                                                                  │
│  7. MyApp.build() → MaterialApp → SignUpPage                          │
│      (App is now running)                                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Sign Up Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            Sign Up Flow                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  USER ACTION: User fills form and taps "Sign Up" button                │
│      │                                                                  │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ SignUpPage (UI Layer)                                           │   │
│  │                                                                 │   │
│  │ 1. User fills name, email, password fields                      │   │
│  │ 2. User taps "Sign Up" button                                   │   │
│  │ 3. formKey.currentState!.validate() checks form                │   │
│  │ 4. ref.read(authViewModelProvider.notifier).signUpuser()      │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│      │                                                                  │
│      │ ref.read(...).signUpuser(name, email, password)               │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ AuthViewModel (Business Logic Layer)                            │   │
│  │                                                                 │   │
│  │ 1. state = AsyncValue.loading()  ← UI shows loader            │   │
│  │ 2. Calls _authRemoteRepositories.signup(...)                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│      │                                                                  │
│      │ await _authRemoteRepositories.signup(name, email, password)  │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ AuthRemoteRepositories (Data Layer - Remote)                   │   │
│  │                                                                 │   │
│  │ 1. Creates HTTP POST request                                   │   │
│  │ 2. Sends to http://127.0.0.1:8000/auth/signup                  │   │
│  │ 3. Backend processes request                                    │   │
│  │ 4. Returns JSON response                                        │   │
│  │ 5. Returns Either<AppFailure, UserModel>                       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│      │                                                                  │
│      │ Either<AppFailure, UserModel>                                 │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ AuthViewModel handles response                                   │   │
│  │                                                                 │   │
│  │ switch (res) {                                                  │   │
│  │   Left(error) → state = AsyncValue.error(error)                │   │
│  │   Right(user) → state = AsyncValue.data(user)                  │   │
│  │ }                                                               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│      │                                                                  │
│      │ state updated (UI rebuilds automatically)                    │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ SignUpPage listens to state changes                             │   │
│  │                                                                 │   │
│  │ ref.listen(authViewModelProvider, (prev, next) {               │   │
│  │   next.when(                                                   │   │
│  │     data: (user) {                                             │   │
│  │       showSnackbar("Account created!");                       │   │
│  │       Navigator.push(context, SigninPage.route());            │   │
│  │     },                                                          │   │
│  │     error: (error) {                                           │   │
│  │       showSnackbar(error.toString());                         │   │
│  │     },                                                          │   │
│  │     loading: () { }                                            │   │
│  │   });                                                          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  USER SEES: Success message and navigation to login page               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Sign In Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            Sign In Flow                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  USER ACTION: User enters email/password and taps "Sign In"           │
│      │                                                                  │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ SigninPage (UI Layer)                                           │   │
│  │                                                                 │   │
│  │ 1. User fills email, password fields                           │   │
│  │ 2. User taps "Sign In" button                                   │   │
│  │ 3. formKey.currentState!.validate() checks form                │   │
│  │ 4. ref.read(authViewModelProvider.notifier).signInUser()     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│      │                                                                  │
│      │ ref.read(...).signInUser(email, password)                    │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ AuthViewModel                                                   │   │
│  │                                                                 │   │
│  │ 1. state = AsyncValue.loading()                                │   │
│  │ 2. Calls _authRemoteRepositories.login(...)                    │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│      │                                                                  │
│      │ await _authRemoteRepositories.login(email, password)        │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ AuthRemoteRepositories                                         │   │
│  │                                                                 │   │
│  │ 1. HTTP POST to /auth/login                                    │   │
│  │ 2. Backend validates credentials                               │   │
│  │ 3. Returns user data + token                                   │   │
│  │ 4. Returns Either<AppFailure, UserModel>                       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│      │                                                                  │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ AuthViewModel handles response                                   │   │
│  │                                                                 │   │
│  │ Right(user) → _loginSuccess(user)                              │   │
│  │     │                                                            │   │
│  │     └──► _authLocalRepository.setToken(user.token)             │   │
│  │          │  (Token saved to SharedPreferences)                 │   │
│  │          ▼                                                      │   │
│  │     state = AsyncValue.data(user)                               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│      │                                                                  │
│      ▼                                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ SigninPage listens and shows success                            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  RESULT: User is logged in with token stored locally                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## How to Use AuthViewModel in Widgets/Screens

### Step 1: Import Required Packages

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
```

### Step 2: Use ConsumerWidget or ConsumerStatefulWidget

**Option A: ConsumerWidget (for stateless widgets)**

```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Your widget code here
  }
}
```

**Option B: ConsumerStatefulWidget (for widgets with local state)**

```dart
class MyWidget extends ConsumerStatefulWidget {
  const MyWidget({super.key});

  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  // Your state code here
}
```

### Step 3: Watch State Changes

Use `ref.watch()` to listen to state changes:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Watch the entire state
  final authState = ref.watch(authViewModelProvider);
  
  // OR watch a specific part (more efficient)
  final isLoading = ref.watch(
    authViewModelProvider.select((val) => val?.isLoading == true),
  );
  
  return // your UI;
}
```

### Step 4: Call ViewModel Methods

Use `ref.read()` to call methods:

```dart
AuthGradientButton(
  fnHandler: () async {
    // Call the signUpuser method
    await ref.read(authViewModelProvider.notifier).signUpuser(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );
  },
  text: "Sign Up",
)
```

### Step 5: Listen to State Changes

Use `ref.listen()` to react to state updates:

```dart
ref.listen(authViewModelProvider, (prev, next) {
  next?.when(
    data: (user) {
      // Success - navigate to home
      showSnackbar(context, 'Welcome ${user?.name}!');
    },
    error: (error, stack) {
      // Error - show error message
      showSnackbar(context, error.toString());
    },
    loading: () {
      // Loading - already handled by isLoading
    },
  );
});
```

### Complete Example: SignUpPage

```dart
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils/utils.dart';
import 'package:client/features/auth/view/pages/signin_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/features/auth/view/widgets/custom_field.dart';
import 'package:client/features/auth/view/widgets/loader.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpPage extends ConsumerStatefulWidget {
  // Route method for navigation
  static MaterialPageRoute route() => MaterialPageRoute(
    builder: (context) => SignUpPage(),
  );

  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  // Text controllers for form fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Clean up controllers when widget is disposed
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch loading state using select (more efficient)
    final isLoading = ref.watch(
      authViewModelProvider.select((val) => val?.isLoading == true),
    );

    // Listen to state changes
    ref.listen(authViewModelProvider, (prev, next) {
      next?.when(
        data: (data) {
          showSnackbar(context, 'Account created. Please login!');
          Navigator.push(context, SigninPage.route());
        },
        error: (error, st) {
          showSnackbar(context, error.toString());
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? CustomLoader()  // Show loader when loading
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sign up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 44,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Name field
                    CustomField(
                      hintText: "Name",
                      controller: nameController,
                    ),
                    const SizedBox(height: 20),

                    // Email field
                    CustomField(
                      hintText: "Email",
                      controller: emailController,
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    CustomField(
                      hintText: "Password",
                      controller: passwordController,
                      isObscure: true,
                    ),
                    const SizedBox(height: 20),

                    // Sign Up button - calls ViewModel method
                    AuthGradientButton(
                      fnHandler: () async {
                        if (formKey.currentState!.validate()) {
                          await ref
                              .read(authViewModelProvider.notifier)
                              .signUpuser(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text,
                              );
                        }
                      },
                      text: "Sign Up",
                    ),

                    const SizedBox(height: 20),
                    
                    // Navigation link
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, SigninPage.route());
                      },
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            TextSpan(text: "Already have an account? "),
                            TextSpan(
                              text: "Sign In",
                              style: TextStyle(
                                color: Pallete.gradient2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
```

---

## Data Flow Architecture

### Complete Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Complete Data Flow Architecture                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                          PRESENTATION LAYER                          │  │
│  │                        (Flutter Widgets)                             │  │
│  │                                                                      │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │  │
│  │  │  SignUpPage │  │ SignInPage  │  │  HomePage   │  │  Profile   │ │  │
│  │  │             │  │             │  │             │  │    Page    │ │  │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬─────┘ │  │
│  │         │                │                │                │        │  │
│  │         │ ref.watch()   │ ref.watch()   │ ref.watch()   │        │  │
│  │         │ ref.listen()  │ ref.listen()  │ ref.listen()  │        │  │
│  │         │ ref.read()   │ ref.read()   │ ref.read()   │        │  │
│  │         ▼                ▼                ▼                ▼        │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                       │                                     │
│                                       │ calls methods                        │
│                                       ▼                                     │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                          BUSINESS LOGIC LAYER                        │  │
│  │                       (ViewModels / Notifiers)                       │  │
│  │                                                                      │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │                    AuthViewModel                                │  │  │
│  │  │                                                                  │  │  │
│  │  │  • Manages auth state (AsyncValue<UserModel>)                  │  │  │
│  │  │  • Handles sign up, sign in, get user data                     │  │  │
│  │  │  • Calls repositories                                           │  │  │
│  │  │  • Transforms data for UI                                       │  │  │
│  │  │                                                                  │  │  │
│  │  │  state = AsyncValue.loading()                                  │  │  │
│  │  │  state = AsyncValue.data(user)                                 │  │  │
│  │  │  state = AsyncValue.error(message)                             │  │  │
│  │  └────────────────────────────┬────────────────────────────────────┘  │  │
│  │                               │                                        │  │
│  │                               │ uses                                   │  │
│  │            ┌──────────────────┼──────────────────┐                     │  │
│  │            ▼                  ▼                  ▼                     │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐       │  │
│  │  │ AuthRemoteRepo  │  │ AuthLocalRepo   │  │ Other Providers │       │  │
│  │  │                 │  │                 │  │                 │       │  │
│  │  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘       │  │
│  └───────────┼────────────────────┼────────────────────┼─────────────────┘  │
│              │                    │                    │                     │
│              │ calls              │ accesses           │                     │
│              ▼                    ▼                    ▼                     │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                            DATA LAYER                                 │  │
│  │              (Repositories & Data Sources)                          │  │
│  │                                                                      │  │
│  │  ┌──────────────────────────┐  ┌────────────────────────────────┐   │  │
│  │  │   AuthRemoteRepositories │  │    AuthLocalRepository        │   │  │
│  │  │                          │  │                                │   │  │
│  │  │  • HTTP POST /signup     │  │  • SharedPreferences.set()    │   │  │
│  │  │  • HTTP POST /login     │  │  • SharedPreferences.get()     │   │  │
│  │  │  • HTTP GET /user       │  │                                │   │  │
│  │  │                          │  │                                │   │  │
│  │  │  Returns:                │  │  Returns:                       │   │  │
│  │  │  Either<AppFailure,     │  │  String? (token)                │   │  │
│  │  │       UserModel>        │  │                                │   │  │
│  │  └────────────┬───────────┘  └─────────────┬────────────────────┘   │  │
│  └───────────────┼─────────────────────────────┼─────────────────────────┘  │
│                  │                             │                            │
│                  │ makes HTTP request          │ accesses storage           │
│                  ▼                             ▼                            │
│  ┌──────────────────────────┐  ┌────────────────────────────────────────┐   │
│  │      Backend Server     │  │      Local Device Storage              │   │
│  │   (FastAPI/Python)      │  │     (SharedPreferences)                │   │
│  │                          │  │                                        │   │
│  │  • Validates user        │  │  • Stores X-auth-token                 │   │
│  │  • Creates user          │  │  • Persists across app restarts       │   │
│  │  • Returns JWT token    │  │  • Fast access                         │   │
│  │                          │  │                                        │   │
│  └──────────────────────────┘  └────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Implementation Guide

### Adding a New Feature: Forgot Password

Here's how you would add a forgot password feature using the same architecture:

#### Step 1: Add Method to Remote Repository

```dart
// lib/features/auth/repositories/auth_remote_repositories.dart

Future<Either<AppFailure, bool>> forgotPassword({
  required String email,
}) async {
  try {
    final response = await http.post(
      Uri.parse('${ServerConstant.serverURL}/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      return Left(AppFailure('Failed to send reset email'));
    }

    return const Right(true);
  } catch (e) {
    return Left(AppFailure(e.toString()));
  }
}
```

#### Step 2: Add Method to ViewModel

```dart
// lib/features/auth/viewmodel/auth_viewmodel.dart

Future<void> forgotPassword({
  required String email,
}) async {
  state = const AsyncValue.loading();

  final res = await _authRemoteRepositories.forgotPassword(email: email);

  final val = switch (res) {
    Left(value: final l) => state = AsyncValue.error(l.message, StackTrace.current),
    Right(value: final r) => state = const AsyncValue.data(null),
  };
}
```

#### Step 3: Create UI Page

```dart
// lib/features/auth/view/pages/forgot_password_page.dart

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authViewModelProvider.select((val) => val?.isLoading == true),
    );

    ref.listen(authViewModelProvider, (prev, next) {
      next?.when(
        data: (_) => showSnackbar(context, 'Reset email sent!'),
        error: (e, _) => showSnackbar(context, e.toString()),
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomField(
                      hintText: "Enter your email",
                      controller: emailController,
                    ),
                    const SizedBox(height: 20),
                    AuthGradientButton(
                      fnHandler: () {
                        if (formKey.currentState!.validate()) {
                          ref
                              .read(authViewModelProvider.notifier)
                              .forgotPassword(email: emailController.text);
                        }
                      },
                      text: "Send Reset Link",
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
```

---

## Common Patterns and Best Practices

### 1. Handling Loading States

```dart
// Watch loading state efficiently using select
final isLoading = ref.watch(
  authViewModelProvider.select((value) => value?.isLoading == true),
);

// Use in UI
body: isLoading ? CustomLoader() : YourWidget(),
```

### 2. Handling Errors

```dart
// Listen to state changes
ref.listen(authViewModelProvider, (previous, next) {
  next.when(
    data: (data) => // Handle success
    error: (error, stack) => showSnackbar(context, error.toString()),
    loading: () => // Handle loading
  );
});
```

### 3. Using select() for Performance

```dart
// BAD: Rebuilds on any state change
final authState = ref.watch(authViewModelProvider);

// GOOD: Only rebuilds when isLoading changes
final isLoading = ref.watch(
  authViewModelProvider.select((val) => val?.isLoading == true),
);

// GOOD: Only rebuilds when user name changes
final userName = ref.watch(
  authViewModelProvider.select((val) => val?.value?.name),
);
```

### 4. Navigation Based on Auth State

```dart
// In main.dart or your router
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  await container.read(authViewModelProvider.notifier).initSharedPrefrences();
  final user = await container.read(authViewModelProvider.notifier).getData();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(userIsLoggedIn: user != null),
    ),
  );
}
```

### 5. Protecting Routes

```dart
// Create an auth-aware router
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.location == '/signin' || 
                          state.location == '/signup';
      
      if (!isLoggedIn && !isAuthRoute) {
        return '/signin';
      }
      return null;
    },
    routes: [
      // Define routes
    ],
  );
});
```

---

## Troubleshooting and Common Issues

### Issue 1: Provider Not Found

**Problem**: `ProviderNotFoundException`

**Solution**: 
- Ensure `ProviderScope` wraps your app in `main.dart`
- Check that providers are properly annotated with `@riverpod`

```dart
void main() {
  runApp(
    ProviderScope(  // ← This must wrap your app
      child: MyApp(),
    ),
  );
}
```

### Issue 2: Circular Dependency

**Problem**: Providers depend on each other in a loop

**Solution**: 
- Use `ref.watch` carefully in `build()` methods
- Avoid calling providers that depend on each other in initialization

### Issue 3: Memory Leaks

**Problem**: Providers not being disposed

**Solution**:
- Use `autoDispose` providers when appropriate
- Always dispose controllers in `dispose()` method

```dart
@override
void dispose() {
  controller.dispose();  // Don't forget!
  super.dispose();
}
```

### Issue 4: State Not Updating

**Problem**: UI doesn't rebuild when state changes

**Solution**:
- Make sure you're using `ref.watch()` in the `build()` method
- Check that you're not creating new instances unnecessarily

### Issue 5: Token Not Saved

**Problem**: Login works but token not persisted

**Solution**:
- Ensure `initSharedPrefrences()` is called before using local repo
- Check that `setToken()` is called after successful login

---

## Summary

### Key Takeaways

1. **MVVM Architecture**: Separates concerns into Model (data), View (UI), and ViewModel (business logic)

2. **AuthViewModel**: 
   - Manages authentication state using `AsyncValue<UserModel>`
   - Contains methods for sign up, sign in, and getting user data
   - Uses Riverpod for state management

3. **Auth Remote Repository**:
   - Handles all server communication via HTTP
   - Returns `Either<AppFailure, UserModel>` for error handling

4. **Auth Local Repository**:
   - Handles local storage using SharedPreferences
   - Stores and retrieves authentication tokens

5. **User Model**:
   - Plain Dart class representing user data
   - Includes JSON serialization methods

6. **Using in Widgets**:
   - Use `ConsumerWidget` or `ConsumerStatefulWidget`
   - Watch state with `ref.watch()`
   - Call methods with `ref.read().notifier`
   - Listen to changes with `ref.listen()`

### File Locations Reference

```
lib/
├── main.dart                                    # App entry point
├── core/
│   ├── constants/
│   │   └── server_constant.dart                 # Server URL config
│   ├── failure/
│   │   └── failure.dart                         # Error class
│   └── theme/
│       ├── app_pallete.dart                     # Colors
│       └── theme.dart                           # Theme config
└── features/
    └── auth/
        ├── model/
        │   └── user_model.dart                  # User data model
        ├── repositories/
        │   ├── auth_remote_repositories.dart   # API calls
        │   └── auth_local_repository.dart       # Local storage
        ├── view/
        │   ├── pages/
        │   │   ├── signin_page.dart             # Login UI
        │   │   └── signup_page.dart             # Register UI
        │   └── widgets/
        │       ├── auth_gradient_button.dart   # Custom button
        │       ├── custom_field.dart            # Custom input
        │       └── loader.dart                  # Loading widget
        └── viewmodel/
            └── auth_viewmodel.dart              # Auth state management
```

---

## Next Steps

To continue developing this application:

1. **Add Home Feature**: Create the home page with music player UI
2. **Implement Music Streaming**: Add audio playback functionality
3. **Add Playlists**: Implement playlist management
4. **User Profile**: Create profile editing features
5. **Error Handling**: Improve error messages and edge cases

---

*Generated on: 2026-03-10*
*Part of: Spotify Clone Project*
*Build By Awais Mumtaz*
