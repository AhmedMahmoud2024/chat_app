import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
   ChatScreen({required this.receiverName, required this.receiverId});
  final String receiverName, receiverId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
    TextEditingController _messageController = TextEditingController();

    final  _scrollController = ScrollController();

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
   
   @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  String _getChatId(){
    final ids =[widget.receiverId,currentUserId];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _sendMessage()async{
    if(_messageController.text.trim().isEmpty) return;
    final message= _messageController.text.trim();
    _messageController.clear();
    try{
  final chatId= _getChatId();
  await FirebaseFirestore.instance
  .collection('chats').doc(chatId)
  .collection('messages')
  .add({
  'text':message,
  'resceiverId':widget.receiverId,
  'senderId':currentUserId,
  'timestamp':FieldValue.serverTimestamp(),
  });
    }catch(e){

    }
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold();
  }
}