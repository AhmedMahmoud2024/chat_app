class CallLogModel {
  final String callerName;
  final String status;
  final DateTime time ;

  CallLogModel({required this.callerName, required this.status, required this.time});
  factory CallLogModel.fromJson(Map<String, dynamic> json) {
    return CallLogModel(
      callerName: json['callerName'] ?? '',
      status: json['status'] ?? '',
      time: DateTime.parse(json['time'] ?? DateTime.now().toString()),
    );
  }
}