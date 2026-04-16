import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/Core/Network/socket_service.dart';
import 'package:chat_app/Features/recents%20Screen/data/model/call_log_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_callkit_incoming/entities/android_params.dart';
//import 'package:flutter_callkit_incoming/entities/call_event.dart';
//import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
//import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:http/http.dart' as http;

/// @deprecated Use AudioManager for audio calls instead
/// This service previously handled Agora RTC calls but has been migrated to Stream Video
class CallService {
  /// Track listeners for cleanup to prevent memory leaks
  final Map<String, StreamSubscription?> _listeners = {};
  bool _isInitialized = false;
Future<void> sendCallNatification(
  String recieverToken,
  String callerName,
  String channelName
)async{

 String uri='https://fcm.googleapis.com/fcm/send';
 try{
 await http.post(
  Uri.parse(uri),
  headers: <String,String>{
   'Content-Type':'application/json',
   'Authorization':'key=${String.fromEnvironment('SERVER_KEY')}'
  },
  body: jsonEncode(
    <String,dynamic>{
      'notification':<String,dynamic>{
        'body':'calling.....$callerName',
        'title':'new comming call',
        'android_channel_id':'calls_channel'
      },
      'priority':'high',
      'data':<String,dynamic>{
        'click_action':'FLUTTER_NOTIFICATION_CLICK',
        'type':'call',
        'channelName':channelName,
        'callerName':callerName,
        'to':recieverToken
      }
    }
  )

 );
 }catch(e){
print(e.toString());
 }
} 
/*
 Future<void> showIncomingCall(
 Map<String,dynamic>data
)async{
String uuid= const Uuid().v4(); //random id for each call
CallKitParams params=CallKitParams(
  id:uuid,
  nameCaller: data['callerName'] ?? 'unknown caller',
  appName: 'Chat App',
  type: 0,
  textAccept: 'Response',
  textDecline: 'refused',
  extra: <String,dynamic>{
    'channelId':data['channelId'],
    'token':data['token']
  },
  android: const AndroidParams(
    isCustomNotification: true,
    isShowLogo: false,
    ringtonePath: 'system_ringtone_default',
    backgroundColor: '#09121C',
    actionColor: '#4CAF50'
  )
);
await FlutterCallkitIncoming.showCallkitIncoming(params);
}
*/
/*
void listenToCallEvents(BuildContext context){
FlutterCallkitIncoming.onEvent.listen((event){
switch (event!.event){
  case Event.actionCallAccept:
    try {
      final callId = event.body['extra']['channelId'] ?? const Uuid().v4();
      final callerName = event.body['callerName'] ?? 'Unknown';
      final callerId = event.body['extra']['callerId'] ?? '';
      
      log('[CallService] Accepting audio call - callId: $callId, caller: $callerName');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioCallScreen(
            callId: callId,
            memberIds: callerId.isNotEmpty ? [callerId] : [],
            remoteUserName: callerName,
          ),
        ),
      );
    } catch (e) {
      log('[CallService] Error accepting call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting call: $e')),
      );
    }
  case Event.actionCallDecline:
    log('[CallService] Call declined by user');
    break;
  default:
    break;
}
});
}
*/

/// Initialize socket for incoming call notifications
/// Audio calls are now handled by AudioManager (Stream Video SDK)
Future<void> initializeCall(String channelId) async {
  log('[CallService] Initializing incoming call handler for channel: $channelId');
  
  try {
    // Connect to Socket.IO server
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    log('[CallService] Connecting to Node.js server...');
    SocketService.connect(myUserId: currentUser.uid);
    
    // Wait for socket connection with timeout
    int retries = 0;
    const maxRetries = 5;
    
    while (!SocketService.isConnected && retries < maxRetries) {
      await Future.delayed(const Duration(milliseconds: 500));
      retries++;
    }
    
    if (!SocketService.isConnected) {
      throw Exception('Failed to connect to Node.js server after $maxRetries attempts');
    }
    
    log('[CallService] Socket connected successfully');
    
    // Register listeners using SocketService for proper cleanup
    SocketService.on('test-response', (data) {
      log('[CallService] Received test response: $data');
    });
    /*
    SocketService.on('incoming-call', (data) async {
      log('[CallService] Incoming audio call received: ${data['callerName']}');
      
      var callConfig = CallKitParams(
        id: data['channelId'] ?? const Uuid().v4(),
        nameCaller: data['callerName'] ?? 'Unknown',
        type: 0,
        extra: <String, dynamic>{
          'callerId': data['callerId'],
          'channelId': data['channelId'],
          'callerName': data['callerName'],
        },
      );
      
      try {
        await FlutterCallkitIncoming.showCallkitIncoming(callConfig);
        log('[CallService] Incoming call notification displayed');
      } catch (e) {
        log('[CallService] Error showing incoming call notification: $e');
      }
    });
    */
    // Send test connection message
    SocketService.emit('test-connection', {
      'message': 'Hello From My Flutter chat App!',
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _isInitialized = true;
    log('[CallService] Incoming call handler initialized successfully');
  } catch (e, stackTrace) {
    log('[CallService] Error initializing call handler: $e\nStackTrace: $stackTrace');
    rethrow;
  }
}


/// Fetch call logs from MongoDB via Node.js backend
/// Supports pagination with page and limit parameters
Future<List<CallLogModel>> fetchLogs(String myUser, {int page = 1, int limit = 20}) async {
  try {
    final uri = "http://192.168.0.106:3000/api/calls/history/$myUser?page=$page&limit=$limit";
    log('[CallService] Fetching call logs from: $uri');
    
    final response = await http.get(Uri.parse(uri));
    
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> callsList = jsonData['data'] ?? [];
      
      log('[CallService] Successfully fetched ${callsList.length} call logs');
      
      return callsList.map((log) => CallLogModel.fromJson(log)).toList();
    } else {
      log('[CallService] Error fetching logs - Status: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    log('[CallService] Error fetching call logs: $e');
    return [];
  }
}

/// Save a new call log to MongoDB
Future<bool> saveCallLog({
  required String callId,
  required String callerId,
  required String calleeId,
  required String callerName,
  required String calleeName,
  String callerAvatar = '',
  String calleeAvatar = '',
  required String status, // 'missed', 'completed', 'declined'
  String callType = 'audio', // 'audio' or 'video'
  required int duration, // in seconds
}) async {
  try {
    final uri = "http://192.168.0.106:3000/api/calls/save";
    
    final body = jsonEncode(
      
      {
      'callId': callId,
      'callerId': callerId,
      'receiverId': calleeId,
      'callerName': callerName,
      'calleeName': calleeName,
      'callerAvatar': callerAvatar,
      'calleeAvatar': calleeAvatar,
      'status': status,
      'callType': callType,
      'duration': duration,
      'startTime':DateTime.now().toIso8601String()
    }
    );
    
    log('[CallService] Saving call log to MongoDB: $body');
    
    final response = await http.post(
      Uri.parse(uri),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    
    if (response.statusCode == 201) {
      log('[CallService] Call log saved successfully');
      return true;
    } else {
      log('[CallService] Error saving call log - Status: ${response.statusCode}, Body: ${response.body}');
      return false;
    }
  } catch (e) {
    log('[CallService] Error saving call log: $e');
    return false;
  }
}

/// Delete a call log from MongoDB
Future<bool> deleteCallLog(String callId) async {
  try {
    final uri = "http://192.168.0.106:3000/api/calls/$callId";
    
    log('[CallService] Deleting call log: $callId');
    
    final response = await http.delete(Uri.parse(uri));
    
    if (response.statusCode == 200) {
      log('[CallService] Call log deleted successfully');
      return true;
    } else {
      log('[CallService] Error deleting call log - Status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    log('[CallService] Error deleting call log: $e');
    return false;
  }
}  

/// Cleanup all listeners to prevent memory leaks
void cleanup() {
  log('[CallService] Cleaning up listeners...');
  for (final listener in _listeners.values) {
    listener?.cancel();
  }
  _listeners.clear();
  log('[CallService] Listeners cleaned up');
}

/// Get status string for debugging
String getStatus() {
  return '''
[CallService Status]
Initialized: $_isInitialized
Active Listeners: ${_listeners.length}
  ''';
}
}

