import 'dart:convert';

import 'package:chat_app/Core/Network/call_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CallScreen extends StatefulWidget {
  final String channelName;
  final String remoteUserName;

   CallScreen({super.key, required this.channelName, required this.remoteUserName});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted=false;
  bool _isSpeaker=true;
  
  Future<void> initializeCall()async{
 await  CallService().requestPermissions();
await  CallService().joinCall(widget.channelName);
  }
@override
  void initState( ) {
     super.initState();
     initializeCall();
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
              buildCallButton(
                icon:_isMuted ?Icons.mic_off :Icons.mic,
                color:_isMuted ? Colors.white :Colors.white24,
                iconColor: _isMuted ? Colors.black : Colors.white,
                onPressed:(){
                  setState(() {
                    _isMuted=! _isMuted;
                    
                  });
                }
              ),
                buildCallButton(
                icon:Icons.call_end,
                color:Colors.red,
                iconColor: Colors.white,size:70,
                onPressed:(){
                  Navigator.pop(context);
                }
              ),
                buildCallButton(
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

  Widget buildCallButton(
    {
      required IconData icon,
      required Color color,
      required Color iconColor,
      required VoidCallback onPressed,
      double size = 55
    }
  ){
    return RawMaterialButton(onPressed: onPressed,
    shape: const CircleBorder(),
    fillColor: color,
    constraints: BoxConstraints.tightFor(
      width: size,height: size
    ),
    child: Icon(icon,color: iconColor,size: size*5,),
    );
  }
}