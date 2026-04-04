import 'dart:convert';

import 'package:chat_app/Core/Network/call_service.dart';
import 'package:chat_app/Core/Network/socket_service.dart';
import 'package:chat_app/Features/Audio%20Calls/widgets/call_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:http/http.dart' as http;

class AudioCallScreen extends StatefulWidget {
  final String channelName;
  final String remoteUserName;

   AudioCallScreen({super.key, required this.channelName, required this.remoteUserName});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  bool _isMuted=false;
  bool _isSpeaker=true;
 /* 
  Future<void> initializeCall()async{  
      SocketService.connect(myUserId: FirebaseAuth.instance.currentUser!.uid);
     Future.delayed(Duration(seconds: 1),(){
        if(SocketService.socket.connected){
          print('socket connected successfully');
       SocketService.socket.emit('test-connection',{
  'message':'Hello From My Flutter chat App!'
  });  
     SocketService.socket.on('test-response',(data){
      print('Received response from server: $data');
     });
   ////////////// listen to incoming call events
        SocketService.socket.on('incoming-call',(data)async{
         var callConfig= CallKitParams(
          id: data['channelId'],
          nameCaller: data['callerName'],
          type: 1,
          extra: <String,dynamic>{
            'userId':data['callerId'],
          }
         );

         await FlutterCallkitIncoming.showCallkitIncoming(callConfig);
        });
        }else{
          print('socket is still connecting');
        }
     });
    
 await  CallService().requestPermissions();
await  CallService().joinCall(widget.channelName);
  }
  */
@override
  void initState( ) {
     super.initState();
  CallService().initializeCall(widget.channelName);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF1A1A1A), 
      body: SafeArea(child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 80,
            ),
          ),
          SizedBox(height: 20,),
          Text(widget.remoteUserName,
          style: const TextStyle(
            color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold
          ),
          ),
          Text('Connecting',style: TextStyle(
            color: Colors.white70,
            fontSize: 16
          ),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CallButton(
                icon:_isMuted ?Icons.mic_off :Icons.mic,
                color:_isMuted ? Colors.white :Colors.white24,
                iconColor: _isMuted ? Colors.black : Colors.white,
                onPressed:(){
                  setState(() {
                    _isMuted=! _isMuted;
                    
                  });
                }
              ),
                CallButton(
                icon:Icons.call_end,
                color:Colors.red,
                iconColor: Colors.white,size:70,
                onPressed:(){
                  Navigator.pop(context);
                }
              ),
                CallButton(
                icon:_isSpeaker ?Icons.volume_up :Icons.volume_down,
                color:_isSpeaker ? Colors.white :Colors.white24,
                iconColor: _isSpeaker ? Colors.black : Colors.white,
                onPressed:(){
                  setState(() {
                    _isSpeaker=! _isSpeaker;
                  });
                }
              ),
            ],
          )
        
        ],
      )),
    );
  }
}