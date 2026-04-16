import 'package:equatable/equatable.dart';

class CallLogEntity  extends Equatable{
 final String callId;
  final String callerId;
  final String calleeId;//
  final String callerName;
  final String calleeName;
  final String callerAvatar;
  final String calleeAvatar;
  final String status; // 'missed', 'completed', 'declined'
  final String callType; // 'audio', 'video'
  final int duration; // in seconds
  final DateTime startTime;

  const CallLogEntity({
    required this.callId,
   required this.callerName,
    required this.status,
     required this.startTime, 
     required this.callerId,
      required this.calleeId, 
      required this.calleeName,
       required this.callerAvatar,
        required this.calleeAvatar,
         required this.callType,
          required this.duration
          });
  @override
  // TODO: implement props
  List<Object?> get props => [callId,callerName,calleeName,status,startTime,callType,calleeAvatar,calleeId,duration];

}