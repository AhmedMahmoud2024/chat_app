# Migration Guide: From Old video_service to New Clean Architecture

## Summary of Changes

The Video Calls feature has been completely refactored following the clean architecture pattern. Here's what's been created:

### New Directory Structure

```
lib/Features/Video Calls/
├── domain/
│   ├── entities/
│   │   └── call_entity.dart (Enhanced with Equatable)
│   ├── repository/
│   │   └── video_call_repository.dart (Abstract interface - UPDATED)
│   └── usecases/
│       ├── initialize_call_usecase.dart (NEW)
│       ├── create_and_join_call_usecase.dart (NEW)
│       ├── toggle_camera_usecase.dart (NEW)
│       ├── toggle_mic_usecase.dart (NEW)
│       └── leave_call_usecase.dart (NEW)
├── data/
│   ├── dataSources/
│   │   └── stream_manager_data_source.dart (REFACTORED - contains video_service logic)
│   ├── models/
│   │   └── call_user_model.dart (NEW)
│   └── repositories/
│       └── video_call_repository_impl.dart (NEW)
└── presentation/
    └── bloc/
        ├── video_call_event.dart (NEW)
        ├── video_call_state.dart (NEW)
        └── video_call_bloc.dart (NEW)
    └── screens/
        └── video_call_screen.dart (NEW - use instead of old video_calls.dart)
```

### Core Utilities (NEW)
```
lib/Core/Utils/
├── failures.dart (NEW)
└── usecase_base.dart (NEW)
```

### Updated Files
- `lib/Core/service_locator.dart` - Added Video Calls registration

---

## Migration Steps

### Step 1: Remove Old video_service Feature (Optional)
The old `lib/Features/video_ service/video_calls.dart` can be safely removed as all logic is now in:
- `lib/Features/Video Calls/presentation/screens/video_call_screen.dart`
- `lib/Features/Video Calls/data/dataSources/stream_manager_data_source.dart`

### Step 2: Update Imports

**OLD:**
```dart
import 'package:chat_app/Features/video_%20service/video_calls.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => VideoCalls(...)),
);
```

**NEW:**
```dart
import 'package:chat_app/Features/Video%20Calls/presentation/screens/video_call_screen.dart';
import 'package:chat_app/Core/service_locator.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => sl<VideoCallBloc>(),
      child: const VideoCallScreen(
        callId: callId,
        memberIds: memberIds,
      ),
    ),
  ),
);
```

### Step 3: Ensure Service Locator is Initialized

In your `main.dart`, make sure `setupServiceLocator()` is called:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();  // or await init() depending on function name
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}
```

### Step 4: Update Any References to Stream Manager

**OLD:**
```dart
await StreamManager.init(userId, userName, token);
final call = StreamManager.streamClient.makeCall(...);
```

**NEW:**
Uses automatic BLoC management - no manual calls needed. The BLoC handles initialization:

```dart
// Add initialization event
context.read<VideoCallBloc>().add(
  InitializeCallEvent(
    userId: userId,
    userName: userName,
    token: token,
  ),
);

// Listen to state changes
BlocListener<VideoCallBloc, VideoCallState>(
  listener: (context, state) {
    if (state is VideoCallJoined) {
      // Call is ready
    }
  },
  child: Container(),
);
```

---

## Code Mapping: Old → New

### Video Call Initialization

**BEFORE (video_service):**
```dart
class _VideoCallsState extends State<VideoCalls> {
  @override
  void initState() {
    super.initState();
    _initializeVideoCall();
  }

  Future<void> _initializeVideoCall() async {
    final token = await VideoService.getStreamToken(currentUser.uid);
    await StreamManager.init(userId, userName, token);
    final call = StreamManager.streamClient.makeCall(...);
  }
}
```

**AFTER (Clean Architecture):**
```dart
class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  void initState() {
    super.initState();
    _initializeVideoCall();
  }

  Future<void> _initializeVideoCall() async {
    final token = await VideoService.getStreamToken(currentUser.uid);
    
    context.read<VideoCallBloc>().add(
      InitializeCallEvent(
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'User',
        token: token,
      ),
    );
  }
}
```

### Camera Toggle

**BEFORE:**
```dart
// Manual call handling
await call.setCameraEnabled(enabled: !_isCameraEnabled);
```

**AFTER:**
```dart
// BLoC manages it
context.read<VideoCallBloc>().add(
  ToggleCameraEvent(isEnabled: !_isCameraEnabled),
);
```

---

## Benefits of the New Architecture

| Aspect | Before | After |
|--------|--------|-------|
| **Code Organization** | Mixed in single file | Separated into layers |
| **Testing** | Hard to test | Easy to mock and test |
| **Reusability** | Not reusable | Highly reusable |
| **Error Handling** | Try-catch blocks | Unified Failure handling |
| **State Management** | setState | BLoC with proper states |
| **Maintainability** | Difficult | Clear and maintainable |
| **Logging** | Basic | Comprehensive with proper levels |

---

## Common Issues & Solutions

### Issue: "Stream client not initialized" Error
**Solution**: Ensure `InitializeCallEvent` is added to BLoC before `CreateAndJoinCallEvent`

```dart
// Correct order
context.read<VideoCallBloc>().add(InitializeCallEvent(...));
Future.delayed(Duration(milliseconds: 500), () {
  context.read<VideoCallBloc>().add(CreateAndJoinCallEvent(...));
});
```

### Issue: UI not updating after state change
**Solution**: Ensure screen is wrapped with BLoC provider

```dart
BlocProvider(
  create: (context) => sl<VideoCallBloc>(),
  child: VideoCallScreen(...),
)
```

### Issue: Multiple state emissions
**Solution**: BLoC states are managed properly. If seeing duplicate states, check log output for debugging

---

## Removed Classes/Files

You can safely remove or deprecate:
- `lib/Features/video_ service/video_calls.dart` (old implementation)
- `lib/Features/video_ service/managers/stream_manager.dart` (logic moved to data source)
- Direct `StreamManager` usage throughout the app

---

## Testing the New Implementation

### Unit Test Example
```dart
test('InitializeCallUsecase returns success when repository succeeds', () async {
  // Arrange
  final mockRepository = MockVideoCallRepository();
  final usecase = InitializeCallUsecase(repository: mockRepository);
  
  when(mockRepository.initializeCall(any, any, any))
      .thenAnswer((_) async => {});

  // Act
  final result = await usecase.call(InitializeCallParams(...));

  // Assert
  expect(result, const Right(null));
  verify(mockRepository.initializeCall(any, any, any)).called(1);
});
```

### BLoC Test Example
```dart
blocTest<VideoCallBloc, VideoCallState>(
  'emits [VideoCallInitializing, VideoCallInitialized] when InitializeCallEvent is added',
  build: () {
    when(mockUsecase.call(any))
        .thenAnswer((_) async => const Right(null));
    return bloc;
  },
  act: (bloc) => bloc.add(InitializeCallEvent(...)),
  expect: () => [
    const VideoCallInitializing(),
    const VideoCallInitialized(userId: 'test-user'),
  ],
);
```

---

## Performance Considerations

- **BLoC Caching**: States are cached, reducing redundant computations
- **Lazy Singleton Pattern**: Data sources and repositories are lazy-loaded
- **Factory Pattern for BLoC**: Each screen gets its own BLoC instance (good isolation)

---

## Next Enhancement Ideas

1. **Call History**: Add use case to save/retrieve call history
2. **Participant List**: Add feature to show active participants
3. **Call Quality**: Add metrics for connection quality
4. **Recording**: Add call recording capability
5. **Screen Sharing**: Extend with screen sharing support

---

## Support & Debugging

All new code includes comprehensive logging prefixed with class names:
- `[VideoCallBloc]` - BLoC operations
- `[VideoCallScreen]` - Screen operations
- `[StreamManagerDataSource]` - Data source operations

Enable logging in `main.dart`:
```dart
Bloc.observer = AppBlocObserver();
```

Check debug output for `[VideoCall*]` prefix to trace execution flow.
