
import 'package:chat_app/Core/Network/video_service.dart';
import 'package:chat_app/Features/video%20service/model/call_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stream_video/stream_video.dart' ;
class StreamManager {
  static  StreamVideo? _client ;
  static StreamVideo get streamClient {
    if(_client==null){
       throw Exception('Stream client not initialized. Call StreamManager.init() first.');
       }
    return _client!;}

 static Future<void> init (
  String userId ,String userName,String jwt
 )async{
  final currentUser= FirebaseAuth.instance.currentUser;
 if(currentUser!=null){
  final String ? streamToken=await VideoService.getStreamToken(currentUser.uid);
  if(streamToken!=null){
    await StreamManager.init(userId, userName, jwt);
  print('My token is : $jwt');
  final  token = await VideoService.getStreamToken(jwt);
 if(token==null) throw Exception('Failed to get stream token');
//make user stream
final user=CallUserModel(id: userId, name: userName, image: 'https://getstream.io/random_png/?id=$userId'); 
//User(id: userId, name: userName, avatarUrl: 'https://getstream.io/random_png/?id=$userId');
  final api = dotenv.env['STREAM_API_KEY'] ?? '';
  _client= StreamVideo(api, user: user,userToken: token );
  await _client!.connect();
  }

 }

  }
void startCall(String callId,List<String>memberIds)async{
 final call = await   streamClient.makeCall(callType: StreamCallType.defaultType(), id: callId);
 await call.getOrCreate(memberIds: memberIds);
 
}
}
