import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService{
 static late IO.Socket socket;
 
static void connect( {required String myUserId}){
 socket = IO.io('http://192.168.0.105:3000',<String,dynamic>{
'transports':['websocket'],
'autoConnect':true
 });
 socket.onConnect((_){
  log('Connected to Node Js server');
  socket.emit('store-user',myUserId);
 });

 socket.onDisconnect((_)=>{
  log('disconnected from Node Js server')
 });
 }
  
}