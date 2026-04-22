import 'package:chat_app/Core/service_locator.dart';
import 'package:chat_app/Features/Audio%20Calls/screens/audio_call_screen.dart';
import 'package:chat_app/Features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/Features/Chat/presentation/widgets/message_input_field.dart';
import 'package:chat_app/Features/Chat/presentation/widgets/messages_list_widget.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/screens/recents_screen_clean.dart';
import 'package:chat_app/Features/video_%20service/video_calls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreenClean extends StatefulWidget {
  final String chatRoomId;
 final String receiverId;  
 final String receiverName;
 const  ChatScreenClean({super.key,required this.chatRoomId, required this.receiverId, required this.receiverName});

  @override
  State<ChatScreenClean> createState() => _ChatScreenCleanState();
}

class _ChatScreenCleanState extends State<ChatScreenClean> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:(context)=>sl<ChatBloc>()..add(WatchMessagesEvent(chatRoomId: widget.chatRoomId)),
      child:BlocBuilder<ChatBloc,ChatState>(
        builder: (context, state) {
          
        return Scaffold(
        appBar: AppBar(
          title:  Text(widget.receiverName,style: TextStyle(color: Colors.black),),
          elevation: 1,
          actions: [
                IconButton(
             icon:Icon(Icons.phone) ,
            onPressed: (){
    // startVideoCallAction();
     // callUser(widget.receiverId);
 //     Permission.microphone.request();
        Navigator.push(context,MaterialPageRoute(builder: (context)=>AudioCallScreen(
          callId: 'audio-${widget.receiverId}-${DateTime.now().millisecondsSinceEpoch}',
          memberIds: [widget.receiverId],
           remoteUserName: 
           widget.receiverName)));
          },
          ),
          IconButton(
             icon:Icon(Icons.video_call) ,
            onPressed: (){
      //        startVideoCallAction();
        Navigator.push(context,MaterialPageRoute(builder: (context)=>
        VideoCalls(
          callId: 'video-${widget.receiverId}-${DateTime.now().millisecondsSinceEpoch}',
          memberIds: [widget.receiverId],
        )
           )
           );
          },
          ),
            IconButton(
             icon:Icon(Icons.history) ,
            onPressed: (){
        Navigator.push(context,MaterialPageRoute(builder: (context)=>
      RecentsScreenClean()
     
           ));
          },
          ),
          ],
        ),
        body: Column(
          children: [
            MessagesListWidget(),
              MessageInputField(receiverId:widget.receiverId , chatRoomId: widget.chatRoomId,),
          ],
        ),
      );
      } 
      )
  
    );

  }
}