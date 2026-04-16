
import 'dart:developer';

import 'package:chat_app/Features/recents%20Screen/domain/entities/call_log_entity.dart';

class CallLogModel {
  final String callId;
  final String callerId;
  final String calleeId;
  final String callerName;
  final String calleeName;
  final String callerAvatar;
  final String calleeAvatar;
  final String status; // 'missed', 'completed', 'declined'
  final String callType; // 'audio', 'video'
  final int duration; // in seconds
  final DateTime startTime;
  final DateTime endTime; // nullable
  final DateTime createdAt; // parsed from API
  final String? type; // optional extra type

  CallLogModel({
    required this.callId,
    required this.callerId,
    required this.calleeId,
   required  this.callerName,
   required this.calleeName,
  required  this.callerAvatar,
  required  this.calleeAvatar,
    required this.status,
    required this.callType,
    required this.duration,
    required this.startTime,
required this.endTime,
    required this.createdAt,
    this.type,
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) {
    try {
      return CallLogModel(
        callId: json['_id']?.toString() ?? '',
        callerId: json['callerId']?.toString() ?? '',
        calleeId: json['receiverId']?.toString() ?? '',
        callerName: json['callerName']?.toString()??'' ,
        calleeName: json['receiverName']?.toString()??'',
        callerAvatar: json['callerAvatar']?? "",
        calleeAvatar: json['calleeAvatar'] ?? "",
        status: json['status']?.toString() ?? 'completed',
        callType: json['callType']?.toString() ?? 'audio',
        type: json['type']?.toString()??'',
        duration: (json['duration'] ?? 0) is int
            ? json['duration']
            : int.tryParse(json['duration'].toString()) ?? 0,
        startTime: DateTime.parse(json['startTime']),
     endTime:  json['endTime']!=null ? DateTime.parse((json['endTime']).toString()): DateTime.now()  ,
        createdAt: DateTime.parse(json['createdAt']),
      );
    } catch (e) {
      log('Mapping Error inside CallLogModel : $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': callId,
      'callerId': callerId,
      'receiverId': calleeId,
      'callerName': callerName,
      'receiverName': calleeName,
      'callerAvatar': callerAvatar,
      'calleeAvatar': calleeAvatar,
      'status': status,
      'callType': callType,
      'type': type,
      'duration': duration,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

CallLogEntity toEntity(){
return CallLogEntity(
  callId: callId,
 callerName: callerName, 
status: status, 
startTime: startTime,
 callerId: callerId,
 calleeId: calleeId,
 calleeName: calleeName, 
callerAvatar: callerAvatar,
 calleeAvatar: calleeAvatar, 
callType: callType, 
duration: duration);
}
}


/*
import 'dart:developer';

class CallLogModel {
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
 final String timeStamp ;
  final String type ;
  final DateTime? endTime ;
  CallLogModel({
    required this.callId,
    required this.callerId,
    required this.calleeId,
    required this.calleeName,
    required this.callerAvatar,
    required this.calleeAvatar,
    required this.status,
    required this.callType,
    required this.duration,
    required this.startTime, 
    required this.callerName,
    required this.timeStamp,
    required this.type,
     this.endTime 
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) {
         try{
    return CallLogModel(
      callId: json['_id']?.toString()  ?? '' ,
      callerId: json['callerId']?.toString()  ?? '',
      calleeId: json['receiverId']?.toString() ?? 'Unknown',
      callerName: json['callerName'] ?? 'User:${json['callerId']?.toString().substring(0,4)?? ''}', 
      //                     ?? json['senderName'] ?? 'unKnown' ,
      calleeName: json['receiverName'] ?? 'User',
      callerAvatar: json['callerAvatar'] ?? '',
      calleeAvatar: json['calleeAvatar'] ?? '',
      status: json['status']?.toString() ?? 'completed',
      callType: json['callType']?.toString() ?? 'incomming',
      type: json['type']?.toString() ?? 'audio',
      duration: json['duration'] ?? 0,
      //?.toString() ?? '0',
   //   type:json['type'] ?? 'incomig',
       endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
   timeStamp:json['createdAt']?.toString() ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['time'])
          : DateTime.now(),
     
    );
   }catch(e){
 log('Mapping Error inside callLogModel :$e');
 rethrow;
      }
  }

  Map<String, dynamic> toJson() {
    return {
      'callId': callId,   
      'callerId': callerId,
      'receiverId':calleeId,
      'callerName': callerName,
      'calleeName': calleeName,
      'callerAvatar': callerAvatar,
      'calleeAvatar': calleeAvatar,
      'status': status,
      'callType': callType,
      'duration': duration,
      'startTime': startTime.toIso8601String() ,
    };
  }
}
*/