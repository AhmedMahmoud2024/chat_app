import 'dart:convert';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chat_app/Features/Audio%20Calls/call_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class CallService{
  late RtcEngine engine;
  String appId = 'fecc7bbac27a41c098b942c99d287b60';
Future<void> requestPermissions()async{
Map<Permission,PermissionStatus> status= await [
  Permission.microphone
].request();
if(status[Permission.microphone]!.isGranted){
  log('mic is ok,connecting know');
  initAgora();
}else{
  log('connection refused');
}
}
//initialize Agora engine
Future<void>  initAgora()async{
engine= createAgoraRtcEngine();
await engine.initialize(RtcEngineContext(appId: appId));
 await engine.enableAudio(); //enable sound
//add event handler to listen & know who enterd ,who left the call 
 engine.registerEventHandler(RtcEngineEventHandler(
  onJoinChannelSuccess: (RtcConnection connection,int elapsed){
  print('join channel success ${connection.channelId} uid:${connection.localUid}');
  },
  onUserJoined: (RtcConnection connection ,int remoteUid,int elapsed){
 print('second user joined ${connection.channelId} uid:$remoteUid');
  },
  onUserOffline: (connection, remoteUid, reason) {
    print('second user has ended the call');
  },
 )
 );
 
  }
 Future<void> joinCall(String channelName)async{
  String tempToken = '007eJxTYJDpnXnn6sryA9uur5Xd1yWU1rr8zINwXa76CUecAs0k3nxUYEhLTU42T0pKTDYyTzQxTDawtEiyNDFKtrRMMbIwTzIzCP9zNLMhkJHB6MJ/BkYoBPFZGJIzEksYGAD7HCIW';
  await engine.joinChannel(token: tempToken, channelId: channelName, uid: 0,
   options: const ChannelMediaOptions(
    clientRoleType: ClientRoleType.clientRoleBroadcaster,
    channelProfile: ChannelProfileType.channelProfileCommunication
   ));
  }
 Future<void>  leaveCall()async{
await engine.leaveChannel();
  }
Future<void> sendCallNatification(
  String recieverToken,
  String callerName,
  String channelName
)async{
 const String serverKey='eMqIWQbGTTmEYI95i-OLoj:APA91bEK_obzYN1VCGNhd2LF87GbXA8EjQuxRfjmkzCX-bkXfKHBVFWdwnWfOQUyxLMUqTRL_4AdvGIIaUuQTPTWv6LEdkiEsQ5TFGMuwej7BExNIPh611w';
 String uri='https://fcm.googleapis.com/fcm/send';
 try{
 await http.post(
  Uri.parse(uri),
  headers: <String,String>{
   'Content-Type':'application/json',
   'Authorization':'key=$serverKey'
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

void listenToCallEvents(BuildContext context){
FlutterCallkitIncoming.onEvent.listen((event){
switch (event!.event){
  case Event.actionCallAccept:
  String channelId= event.body['extra']['channelId'];
    Navigator.push(context, MaterialPageRoute(builder: (context)=>CallScreen(channelName: 
    channelId, remoteUserName: '', 
    )
    )
    );
  case Event.actionCallDecline :
   break;
  default: break;
}
});
}

}

