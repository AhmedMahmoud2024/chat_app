
import 'dart:async';
import 'package:chat_app/Features/Chat/domain/entities/message_entity.dart';
import 'package:chat_app/Features/Chat/domain/usecases/get_messages_use_case.dart';
import 'package:chat_app/Features/Chat/domain/usecases/send_message_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent,ChatState>{
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  StreamSubscription? _messageSubscription ;

   ChatBloc({
    required this.getMessagesUseCase,
     required this.sendMessageUseCase,
   }):super(ChatInitial()){
 
   on<WatchMessagesEvent>(_onWatchMessages);
   on<OnMessagesUpdatedEvent>(_onMessagesUpdated);
    
   on<SendMessageEvent>(_onSendMessages);
  
   }
   
   Future<void> _onWatchMessages(
    final WatchMessagesEvent event,
    Emitter<ChatState> emit
   )async{
   emit(ChatLoading());
   //await _messageSubscription?.cancel(); 
   
  // _messageSubscription=getMessagesUseCase(event.chatRoomId).
  await emit.forEach(getMessagesUseCase(event.chatRoomId),
  onData: (result)=> result.fold(
    (failure)=>ChatError('Fail to load message')
    , (messages)=>ChatLoaded(messages)
    )
  );
  /*
  ,
   listen(
   (either){
    either.fold(
    (failure)=>add(OnMessagesUpdatedEvent(const [])),
    (messages)=>add(OnMessagesUpdatedEvent(messages))
    );
   }
   );
  */
   }
  
   Future<void> _onMessagesUpdated(
    final OnMessagesUpdatedEvent event,
    Emitter<ChatState> emit
   )async{
     emit(ChatLoaded(event.messages));

   }
Future<void> _onSendMessages(
    final SendMessageEvent event,
    Emitter<ChatState> emit
)async{
final result = await sendMessageUseCase(event.message);
result.fold(
 (failure)=>emit(const ChatError("Failed to send message")),
 (_)=>{

 }
);
}

@override
Future<void> close(){
  _messageSubscription?.cancel();
  return super.close();
}
}