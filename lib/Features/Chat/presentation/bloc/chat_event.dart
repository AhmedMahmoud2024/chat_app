
part of 'chat_bloc.dart';

 abstract class ChatEvent extends Equatable{
 
 const ChatEvent();
 
 @override
 List<Object> get props=>[];
}

class WatchMessagesEvent extends ChatEvent{
  final String chatRoomId ;

const  WatchMessagesEvent({required this.chatRoomId}); 
 @override
 List<Object> get props=>[chatRoomId];
}

class OnMessagesUpdatedEvent  extends ChatEvent {
  final List<MessageEntity> messages;
  const OnMessagesUpdatedEvent(this.messages);
 
   @override
   List<Object> get props=>[messages];
}
class SendMessageEvent extends ChatEvent {
  final MessageEntity message ;
  const SendMessageEvent(this.message);
   
    @override
    List<Object> get props=>[message];
}