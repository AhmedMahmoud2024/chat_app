/*
import 'package:chat_app/Core/Network/video_service.dart';
import 'package:chat_app/Features/video%20service/model/call_user_model.dart';
import 'package:flutter/material.dart';
import 'package:stream_video/stream_video.dart' 
class StreamManager {
  static late StreamVideo? _client ;
  static StreamVideo get client => client!;

 static Future<void> init (
  String userId ,String userName,String jwt
 )async{
 final token = await VideoService.getStreamToken(jwt);
 if(token==null) throw Exception('Failed to get stream token');
//make user stream
final user= User1(id: userId, name: userName, avatarUrl: 'https://getstream.io/random_png/?id=$userId');

  _client= StreamVideo('apiKey', user: user,userToken: token);
  await _client!.connect();
  }
void startCall(String callId,List<String>memberIds)async{
 final call = await   client.makeCall(callType: StreamCallType.defaultType(), id: callId);
 await call.getOrCreate(memberIds: memberIds);
 
}
}
*/