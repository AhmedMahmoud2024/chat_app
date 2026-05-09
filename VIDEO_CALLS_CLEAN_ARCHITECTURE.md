# Video Calls Feature Refactoring - Clean Architecture Implementation

## Overview
The Video Calls feature has been refactored to follow the **Clean Architecture Pattern** using **BLoC state management**, following the same pattern established in your project. The business logic from `video_service` has been successfully extracted and reorganized into layers.

---

## Architecture Layers

### 1. **Domain Layer** (`lib/Features/Video Calls/domain/`)
The domain layer contains the business logic and is independent of any framework.

#### Entities
- **`call_entity.dart`**: Core domain model representing a video call
  - `callId`: Unique identifier for the call
  - `participantName`: Name of the call participant
  - `isVideoEnabled`: Video state flag
  - `isAudioEnabled`: Audio state flag

#### Repositories (Abstractions)
- **`video_call_repository.dart`**: Abstract interface defining video call operations
  ```dart
  abstract class VideoCallRepository {
    Future<void> initializeCall(String userId, String userName, String token);
    Future<Call> createAndJoinCall(String callId, List<String> memberIds);
    Future<void> leaveCall();
    Future<void> toggleCamera(bool isEnabled);
    Future<void> toggleMic(bool isEnabled);
  }
  ```

#### Use Cases
Each use case represents a single business operation:
- **`initialize_call_usecase.dart`**: Initializes the Stream client with user credentials
- **`create_and_join_call_usecase.dart`**: Creates and joins a video call
- **`toggle_camera_usecase.dart`**: Toggles camera on/off
- **`toggle_mic_usecase.dart`**: Toggles microphone on/off
- **`leave_call_usecase.dart`**: Leaves the current call

All use cases extend `UseCase<Type, Params>` from `Core/Utils/usecase_base.dart` and return `Either<Failure, Success>` for functional error handling.

---

### 2. **Data Layer** (`lib/Features/Video Calls/data/`)
The data layer implements repositories and provides data sources (Firebase, API, external services).

#### Data Sources
- **`stream_manager_data_source.dart`**: 
  - Abstract interface for Stream service operations
  - Implementation: `StreamManagerDataSourceImpl`
  - Contains the core video_service logic for Stream client management
  - Handles initialization and call operations with proper logging

#### Models
- **`call_user_model.dart`**: 
  - Data model extending Stream's `User` class
  - Bridges between domain entities and Stream SDK
  - Methods: `fromCallEntity()`, `toEntity()` for conversion

#### Repositories Implementation
- **`video_call_repository_impl.dart`**: 
  - Implements the domain repository interface
  - Delegates operations to `StreamManagerDataSource`
  - Acts as a facade between domain and data layers

---

### 3. **Presentation Layer** (`lib/Features/Video Calls/presentation/`)
The presentation layer handles UI and state management using BLoC.

#### BLoC (State Management)
- **`video_call_event.dart`**: Events triggered by the UI
  - `InitializeCallEvent`
  - `CreateAndJoinCallEvent`
  - `ToggleCameraEvent`
  - `ToggleMicEvent`
  - `LeaveCallEvent`

- **`video_call_state.dart`**: States representing UI states
  - `VideoCallInitial`
  - `VideoCallInitializing`
  - `VideoCallInitialized`
  - `VideoCallJoined`
  - `VideoCallLoading`
  - `VideoCallError`
  - `CameraToggled`
  - `MicToggled`
  - `VideoCallEnded`

- **`video_call_bloc.dart`**: 
  - Main BLoC class managing all video call operations
  - Injects all use cases via constructor
  - Event handlers convert events to states
  - Comprehensive logging for debugging

#### Screens
- **`video_call_screen.dart`**: 
  - Complete refactored UI screen using BLoC pattern
  - Replaces the old `video_calls.dart` in `video_service`
  - Features:
    - Token fetching from Firebase
    - Call initialization and joining
    - Camera and microphone toggle controls
    - Error handling with retry logic
    - Call ending functionality

---

## Core Utilities

### Base Classes
- **`Core/Utils/failures.dart`**: 
  - `Failure`: Abstract base class for all error types
  - `FirebaseFailure`, `NetworkFailure`, `ServerFailure`, `ValidationFailure`, `CacheFailure`

- **`Core/Utils/usecase_base.dart`**:
  - `UseCase<Type, Params>`: Abstract base for all use cases
  - `NoParams`: Used for use cases with no parameters

---

## Dependency Injection Setup

### Service Locator Configuration
Updated `Core/service_locator.dart` with Video Calls feature registration:

```dart
// Data Sources
sl.registerLazySingleton<StreamManagerDataSource>(
  () => StreamManagerDataSourceImpl(),
);

// Repositories
sl.registerLazySingleton<VideoCallRepository>(
  () => VideoCallRepositoryImpl(dataSource: sl()),
);

// Use Cases
sl.registerLazySingleton(() => InitializeCallUsecase(repository: sl()));
sl.registerLazySingleton(() => CreateAndJoinCallUsecase(repository: sl()));
sl.registerLazySingleton(() => ToggleCameraUsecase(repository: sl()));
sl.registerLazySingleton(() => ToggleMicUsecase(repository: sl()));
sl.registerLazySingleton(() => LeaveCallUsecase(repository: sl()));

// BLoC
sl.registerFactory(
  () => VideoCallBloc(
    initializeCallUsecase: sl(),
    createAndJoinCallUsecase: sl(),
    toggleCameraUsecase: sl(),
    toggleMicUsecase: sl(),
    leaveCallUsecase: sl(),
  ),
);
```

---

## Usage in Your App

### Wrapping Screen with BLoC
```dart
BlocProvider(
  create: (context) => sl<VideoCallBloc>(),
  child: const VideoCallScreen(
    callId: 'call_123',
    memberIds: ['user1', 'user2'],
  ),
)
```

### Alternative: Using in Widget Tree
```dart
context.read<VideoCallBloc>().add(
  InitializeCallEvent(
    userId: userId,
    userName: userName,
    token: token,
  ),
);
```

---

## Flow Diagram

```
UI (VideoCallScreen)
    ↓ (triggers event)
BLoC (VideoCallBloc)
    ↓ (calls)
Use Cases (Initialize, CreateJoin, etc.)
    ↓ (uses)
Repository (VideoCallRepositoryImpl)
    ↓ (delegates to)
Data Source (StreamManagerDataSourceImpl)
    ↓ (uses)
External Services (Stream Video SDK, Firebase)
```

---

## Key Improvements Over Original Code

1. **Separation of Concerns**: Business logic separated from UI
2. **Testability**: Each layer can be tested independently with mocked dependencies
3. **Reusability**: Use cases and repositories can be used across the app
4. **Maintainability**: Clear structure makes changes easier
5. **Scalability**: Easy to add new features following the same pattern
6. **Error Handling**: Standardized error handling with `Either` pattern
7. **Logging**: Comprehensive logging throughout for debugging
8. **State Management**: Proper state management with BLoC prevents UI issues

---

## Required Pubspec Dependencies

✅ Already in your `pubspec.yaml`:
- `flutter_bloc: ^9.1.1`
- `get_it: ^9.2.1`
- `dartz: ^0.10.1`
- `equatable: ^2.0.8`
- `stream_video_flutter: ^1.3.1`

---

## Next Steps

1. **Replace old `video_calls.dart` usage**: 
   - Import and use `VideoCallScreen` from the new presentation layer instead

2. **Add BLoC Provider**: 
   - Wrap screens with `BlocProvider` to inject the BLoC

3. **Testing**: 
   - Write unit tests for use cases
   - Write BLoC tests for state transitions
   - Mock the data source for testing

4. **Additional Features**: 
   - Add screen sharing if needed
   - Add participant list management
   - Add call statistics/quality indicators

---

## Troubleshooting

### "Stream client not initialized" Error
- Ensure `InitializeCallEvent` is triggered before any call operations
- Check that token is properly fetched from VideoService

### State not updating
- Verify BLoC is properly provided in widget tree
- Check that events are being added to the BLoC
- Look at debug logs for any errors

### App crashes during call
- Check log output for detailed error messages
- Ensure all members in `memberIds` exist
- Verify Firebase authentication is working

---

## Architecture Summary

This refactoring maintains the core video_service functionality while organizing it into layers following the **Clean Code Architecture Pattern** you've established. All business logic from `video_service/video_calls.dart` has been extracted and properly distributed across domain, data, and presentation layers for better code organization and maintainability.
