
import 'dart:async';
import 'dart:developer';

import 'package:chat_app/Core/Network/call_service.dart';
import 'package:chat_app/Features/Audio%20Calls/data/managers/audio_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

/// Custom audio-only call UI that hides video and shows only audio controls
class AudioOnlyCallContent extends StatefulWidget {
  final Call call;
  final String remoteUserName;
  final String callId;

  const AudioOnlyCallContent({super.key, 
    required this.call,
    required this.remoteUserName,
    required this.callId,
  });

  @override
  State<AudioOnlyCallContent> createState() => _AudioOnlyCallContentState();
}

class _AudioOnlyCallContentState extends State<AudioOnlyCallContent> {
  late DateTime _callStartTime;
  int _elapsedSeconds = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _callStartTime = DateTime.now();
    
    // Start timer to update elapsed time
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = DateTime.now().difference(_callStartTime).inSeconds;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Format elapsed time as hh:mm:ss
  String _formatElapsedTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Save call log when ending the call
  Future<void> _endCallAndSaveLog() async {
    final callDuration = DateTime.now().difference(_callStartTime).inSeconds;
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      // Determine call status (for now, assume completed)
      final status = 'completed'; // Could be 'missed' or 'declined' based on logic
      
      // Save to MongoDB via Node.js backend
      final success = await CallService().saveCallLog(
        callId: widget.callId,
        callerId: currentUser.uid,
        calleeId: 'remote_user_id', // TODO: Get actual remote user ID
        callerName: currentUser.displayName ?? 'Unknown',
        calleeName: widget.remoteUserName,
        status: status,
        callType: 'audio',
        duration: callDuration,
      );
      
      log('[AudioCallScreen] Call log ${success ? 'saved' : 'failed to save'}');
    }
    
    // Leave the call
    await AudioManager.instance.leaveCall();
    
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Audio-only UI (no video)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    widget.remoteUserName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Connected',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Display elapsed time
                  Text(
                    _formatElapsedTime(_elapsedSeconds),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            // Audio controls at bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Microphone toggle
                    FloatingActionButton(
                      heroTag: 'mic',
                      backgroundColor: Colors.white,
                      onPressed: () {
                        widget.call.setMicrophoneEnabled(enabled: true);
                      },
                      child: const Icon(
                        Icons.mic,
                        color: Colors.black,
                      ),
                    ),
                    // End call
                    FloatingActionButton(
                      heroTag: 'EndCall',
                      backgroundColor: Colors.red,
                      onPressed: _endCallAndSaveLog,
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                      ),
                    ),
                    // Speaker toggle
                    FloatingActionButton(
                      heroTag: 'speaker',
                      backgroundColor: Colors.white,
                      onPressed: () {
                        log('[AudioCall] Speaker toggled');
                      },
                      child: const Icon(
                        Icons.volume_up,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
