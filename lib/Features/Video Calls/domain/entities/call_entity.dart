import 'package:equatable/equatable.dart';

class CallEntity extends Equatable {
  final String callId;
  final String participantName;
  final bool isVideoEnabled;
  final bool isAudioEnabled;

  const CallEntity({
    required this.callId,
    required this.participantName,
    this.isVideoEnabled = true,
    this.isAudioEnabled = true,
  });

  @override
  List<Object?> get props => [
    callId,
    participantName,
    isVideoEnabled,
    isAudioEnabled,
  ];
}