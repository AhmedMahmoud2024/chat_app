import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/Core/Utils/usecase_base.dart';
import 'package:chat_app/Features/Video%20Calls/domain/usecases/initialize_call_usecase.dart';
import 'package:chat_app/Features/Video%20Calls/domain/usecases/create_and_join_call_usecase.dart';
import 'package:chat_app/Features/Video%20Calls/domain/usecases/toggle_camera_usecase.dart';
import 'package:chat_app/Features/Video%20Calls/domain/usecases/toggle_mic_usecase.dart';
import 'package:chat_app/Features/Video%20Calls/domain/usecases/leave_call_usecase.dart';
import 'video_call_event.dart';
import 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final InitializeCallUsecase initializeCallUsecase;
  final CreateAndJoinCallUsecase createAndJoinCallUsecase;
  final ToggleCameraUsecase toggleCameraUsecase;
  final ToggleMicUsecase toggleMicUsecase;
  final LeaveCallUsecase leaveCallUsecase;

  VideoCallBloc({
    required this.initializeCallUsecase,
    required this.createAndJoinCallUsecase,
    required this.toggleCameraUsecase,
    required this.toggleMicUsecase,
    required this.leaveCallUsecase,
  }) : super(const VideoCallInitial()) {
    on<InitializeCallEvent>(_onInitializeCall);
    on<CreateAndJoinCallEvent>(_onCreateAndJoinCall);
    on<ToggleCameraEvent>(_onToggleCamera);
    on<ToggleMicEvent>(_onToggleMic);
    on<LeaveCallEvent>(_onLeaveCall);
  }

  Future<void> _onInitializeCall(
    InitializeCallEvent event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      emit(const VideoCallInitializing());
      log('[VideoCallBloc] Initializing call for userId: ${event.userId}');

      final result = await initializeCallUsecase.call(
        InitializeCallParams(
          userId: event.userId,
          userName: event.userName,
          token: event.token,
        ),
      );

      result.fold(
        (failure) {
          log('[VideoCallBloc] Failed to initialize call: ${failure.message}');
          emit(VideoCallError(message: failure.message));
        },
        (_) {
          log('[VideoCallBloc] Call initialized successfully');
          emit(VideoCallInitialized(userId: event.userId));
        },
      );
    } catch (e, stackTrace) {
      log('[VideoCallBloc] Error during initialization: $e\nStackTrace: $stackTrace');
      emit(VideoCallError(message: e.toString()));
    }
  }

  Future<void> _onCreateAndJoinCall(
    CreateAndJoinCallEvent event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      emit(const VideoCallLoading());
      log('[VideoCallBloc] Creating and joining call: ${event.callId}');

      final result = await createAndJoinCallUsecase.call(
        CreateAndJoinCallParams(
          callId: event.callId,
          memberIds: event.memberIds,
        ),
      );

      result.fold(
        (failure) {
          log('[VideoCallBloc] Failed to create/join call: ${failure.message}');
          emit(VideoCallError(message: failure.message));
        },
        (call) {
          log('[VideoCallBloc] Call created and joined successfully');
          emit(VideoCallJoined(call: call));
        },
      );
    } catch (e, stackTrace) {
      log('[VideoCallBloc] Error creating/joining call: $e\nStackTrace: $stackTrace');
      emit(VideoCallError(message: e.toString()));
    }
  }

  Future<void> _onToggleCamera(
    ToggleCameraEvent event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      log('[VideoCallBloc] Toggling camera to: ${event.isEnabled}');

      final result = await toggleCameraUsecase.call(
        ToggleCameraParams(isEnabled: event.isEnabled),
      );

      result.fold(
        (failure) {
          log('[VideoCallBloc] Failed to toggle camera: ${failure.message}');
          emit(VideoCallError(message: failure.message));
        },
        (_) {
          log('[VideoCallBloc] Camera toggled successfully');
          emit(CameraToggled(isEnabled: event.isEnabled));
        },
      );
    } catch (e, stackTrace) {
      log('[VideoCallBloc] Error toggling camera: $e\nStackTrace: $stackTrace');
      emit(VideoCallError(message: e.toString()));
    }
  }

  Future<void> _onToggleMic(
    ToggleMicEvent event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      log('[VideoCallBloc] Toggling mic to: ${event.isEnabled}');

      final result = await toggleMicUsecase.call(
        ToggleMicParams(isEnabled: event.isEnabled),
      );

      result.fold(
        (failure) {
          log('[VideoCallBloc] Failed to toggle mic: ${failure.message}');
          emit(VideoCallError(message: failure.message));
        },
        (_) {
          log('[VideoCallBloc] Mic toggled successfully');
          emit(MicToggled(isEnabled: event.isEnabled));
        },
      );
    } catch (e, stackTrace) {
      log('[VideoCallBloc] Error toggling mic: $e\nStackTrace: $stackTrace');
      emit(VideoCallError(message: e.toString()));
    }
  }

  Future<void> _onLeaveCall(
    LeaveCallEvent event,
    Emitter<VideoCallState> emit,
  ) async {
    try {
      log('[VideoCallBloc] Leaving call');

      final result = await leaveCallUsecase.call(NoParams());

      result.fold(
        (failure) {
          log('[VideoCallBloc] Failed to leave call: ${failure.message}');
          emit(VideoCallError(message: failure.message));
        },
        (_) {
          log('[VideoCallBloc] Call ended successfully');
          emit(const VideoCallEnded());
        },
      );
    } catch (e, stackTrace) {
      log('[VideoCallBloc] Error leaving call: $e\nStackTrace: $stackTrace');
      emit(VideoCallError(message: e.toString()));
    }
  }
}
