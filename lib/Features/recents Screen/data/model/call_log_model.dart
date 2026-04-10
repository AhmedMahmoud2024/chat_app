class CallLogModel {
  final String callId;
  final String callerId;
  final String receiverId;
  final String callerName;
  final String calleeName;
  final String callerAvatar;
  final String calleeAvatar;
  final String status; // 'missed', 'completed', 'declined'
  final String callType; // 'audio', 'video'
  final int duration; // in seconds
  final DateTime startTime;

  CallLogModel({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.calleeName,
    required this.callerAvatar,
    required this.calleeAvatar,
    required this.status,
    required this.callType,
    required this.duration,
    required this.startTime, required this.callerName,
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) {
    return CallLogModel(
      callId: json['callId'] ?? '',
      callerId: json['callerId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      callerName: json['callerName'] ?? '',
      calleeName: json['calleeName'] ?? '',
      callerAvatar: json['callerAvatar'] ?? '',
      calleeAvatar: json['calleeAvatar'] ?? '',
      status: json['status'] ?? 'completed',
      callType: json['callType'] ?? 'audio',
      duration: json['duration'] ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['time'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callId': callId,
      'callerName': callerName,
      'calleeName': calleeName,
      'callerAvatar': callerAvatar,
      'calleeAvatar': calleeAvatar,
      'status': status,
      'callType': callType,
      'duration': duration,
      'startTime': startTime.toIso8601String(),
    };
  }
}