import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/Core/Network/video_service.dart';
import 'package:chat_app/Features/Video%20Calls/presentation/bloc/video_call_bloc.dart';
import 'package:chat_app/Features/Video%20Calls/presentation/bloc/video_call_event.dart';
import 'package:chat_app/Features/Video%20Calls/presentation/bloc/video_call_state.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final List<String> memberIds;

  const VideoCallScreen({
    super.key,
    required this.callId,
    required this.memberIds,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isCameraEnabled = true;
  bool _isMicEnabled = true;

  @override
  void initState() {
    super.initState();
    log('[VideoCallScreen] initState: Initializing video call for callId=${widget.callId}');
  //  _initializeVideoCall();
  }

  /// Initialize video call by fetching token and starting BLoC events
  Future<void> _initializeVideoCall() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      log('[VideoCallScreen] Fetching Stream token for userId: ${currentUser.uid}');

      // Get Stream token
      final token = await VideoService.getStreamToken(currentUser.uid);
      if (token == null) {
        throw Exception('Failed to fetch Stream token after max retries');
      }

      log('[VideoCallScreen] Token obtained, initializing video call');

      if (mounted) {
        // Trigger initialize call event
        context.read<VideoCallBloc>().add(
          InitializeCallEvent(
            userId: currentUser.uid,
            userName: currentUser.displayName ?? 'User',
            token: token,
          ),
        );

        // After initialization, create and join call
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.read<VideoCallBloc>().add(
              CreateAndJoinCallEvent(
                callId: widget.callId,
                memberIds: widget.memberIds,
              ),
            );
          }
        });
      }
    } catch (e, stackTrace) {
      log('[VideoCallScreen] Error during initialization: $e\nStackTrace: $stackTrace');
      if (mounted) {
        _showErrorDialog('Failed to initialize video call: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Call Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeVideoCall(); // Retry
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    log('[VideoCallScreen] dispose: Cleaning up video call');
    // Leave call when disposing
    if (mounted) {
      context.read<VideoCallBloc>().add(const LeaveCallEvent());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoCallBloc, VideoCallState>(
      listener: (context, state) {
        if (state is VideoCallError) {
          log('[VideoCallScreen] Video call error: ${state.message}');
          _showErrorDialog(state.message);
        } else if (state is VideoCallEnded) {
          log('[VideoCallScreen] Video call ended, navigating back');
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<VideoCallBloc, VideoCallState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Video Call'),
              elevation: 0,
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(VideoCallState state) {
    // Loading and initializing states
    if (state is VideoCallInitializing || state is VideoCallLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              state is VideoCallInitializing
                  ? 'Initializing call...'
                  : 'Connecting to call...',
            ),
          ],
        ),
      );
    }

    // Error state
    if (state is VideoCallError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeVideoCall,
              child: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    // Call joined state - show call UI
    if (state is VideoCallJoined) {
      return _buildCallUI(state.call);
    }

    // Default state
    return _buildDefaultUI();
  }

  Widget _buildCallUI(Call call) {
    return Stack(
      children: [
        // Call container
        StreamCallContainer(
          call: call,
          callContentWidgetBuilder: (context, call) {
            return StreamCallContent(call: call);
          },
        ),
        // Control buttons
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Toggle Camera Button
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isCameraEnabled = !_isCameraEnabled;
                    });
                    context.read<VideoCallBloc>().add(
                      ToggleCameraEvent(isEnabled: _isCameraEnabled),
                    );
                  },
                  backgroundColor:
                      _isCameraEnabled ? Colors.blue : Colors.red,
                  child: Icon(
                    _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
                  ),
                ),
                const SizedBox(width: 16),
                // Toggle Mic Button
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isMicEnabled = !_isMicEnabled;
                    });
                    context.read<VideoCallBloc>().add(
                      ToggleMicEvent(isEnabled: _isMicEnabled),
                    );
                  },
                  backgroundColor: _isMicEnabled ? Colors.blue : Colors.red,
                  child: Icon(
                    _isMicEnabled ? Icons.mic : Icons.mic_off,
                  ),
                ),
                const SizedBox(width: 16),
                // End Call Button
                FloatingActionButton(
                  onPressed: () {
                    context.read<VideoCallBloc>().add(const LeaveCallEvent());
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_call, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Ready to make a video call'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeVideoCall,
            child: const Text('Start Call'),
          ),
        ],
      ),
    );
  }
}
