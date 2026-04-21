import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable{
  final String messageId;
  final String text;
  final String senderId;
  final String recevierId;
  final DateTime dateTime;
  final bool isMe ;

const  MessageEntity({required this.messageId, 
  required this.text,
   required this.senderId,
    required this.recevierId,
     required this.dateTime,
      required this.isMe
      });
      
        @override
        List<Object?> get props => [messageId,senderId,recevierId,text,isMe];

}