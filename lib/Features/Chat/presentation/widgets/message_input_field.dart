import 'package:chat_app/Features/Chat/domain/entities/message_entity.dart';
import 'package:chat_app/Features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageInputField extends StatefulWidget {
final String receiverId;
final String chatRoomId;
  const MessageInputField({super.key,required this.receiverId,required this.chatRoomId});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
 final TextEditingController _controller=TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,vertical: 4
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,blurRadius: 4
          ),
        ]
      ),
      child: Row(
        children: [
          Expanded(child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Write Your message',
              border: InputBorder.none
            ),
          )
          ),
          IconButton(onPressed: (){
         if(_controller.text.trim().isNotEmpty){
          final String currentUserId=FirebaseAuth.instance.currentUser!.uid;
          final message = MessageEntity(
            messageId: '',
             text: _controller.text.trim(), 
             senderId:currentUserId ,
              recevierId: widget.receiverId,
               dateTime: DateTime.now(),
                isMe: true
                );
                context.read<ChatBloc>().add(SendMessageEvent(message));
                _controller.clear();
         }
          }, icon: const Icon(Icons.send,color: Colors.blueAccent,))
        ],
      ),
    );
  }
}