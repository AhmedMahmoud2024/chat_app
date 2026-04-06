import 'package:chat_app/Core/Network/video_service.dart';
import 'package:chat_app/Features/video%20service/managers/stream_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
class VideoCalls extends StatefulWidget {
  const VideoCalls({super.key});

  @override
  State<VideoCalls> createState() => _VideoCallsState();
}

class _VideoCallsState extends State<VideoCalls> {
void startVideoCall(BuildContext context ,String callId,
List<String>members)async{
  final currentUser= FirebaseAuth.instance.currentUser;
  final token = await VideoService.getStreamToken(currentUser!.uid);
  if(token!=null){
 await StreamManager.init(FirebaseAuth.instance.currentUser!.uid, FirebaseAuth.instance.currentUser!.displayName ?? 'User Name',token 
 );

  final call = StreamManager.streamClient.makeCall(callType: StreamCallType.defaultType(), id: callId);
await call.getOrCreate(memberIds: members);
Navigator.push(context, MaterialPageRoute(builder: (context)=>StreamCallContainer(
  call: call,
  
callContentWidgetBuilder:(context,call){
return StreamCallContent(call: call);
}

)
)
);  
  }else{
    print('Token has not get by flutter yet');
  }

}
@override
  void initState() {
    // TODO: implement initState
    
    startVideoCall(context, 'callId', ['member1','member2']);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Video Calls Screen')),
    );

}
}