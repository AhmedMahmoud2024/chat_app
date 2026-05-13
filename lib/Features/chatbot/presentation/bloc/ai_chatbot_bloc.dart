import 'package:chat_app/Features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/Features/chatbot/data/datasource/gemini_remote_data_source.dart';
import 'package:chat_app/Features/chatbot/domain/entities/ai-message.dart';
import 'package:chat_app/Features/chatbot/presentation/bloc/ai_chatbot_event.dart';
import 'package:chat_app/Features/chatbot/presentation/bloc/ai_chatbot_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiChatbotBloc  extends Bloc<AIChatbotEvent,AIChatbotState>{
  final GeminiRemoteDataSource _dataSource;
  final List<AIMessage>_messages=[];
  AiChatbotBloc(this._dataSource):super(
    AiChatbotInitialState(messages: [])){
    on<AiChatbotSendMessageEvent>((event, emit) async{
      _messages.add(AIMessage(text: event.message,isUser:true,time:DateTime.now()));
      emit(AiChatbotInitialState(messages: List.from(_messages),isLoading:true));
      try{
        final responseText= await _dataSource.getResponse(event.message);
        _messages.add(AIMessage(text: responseText,isUser:false,time:DateTime.now()));
        emit(AiChatbotInitialState(messages: List.from(_messages),isLoading:false));
      } catch (e) {
        _messages.add(AIMessage(text: 'Connection error occurred',isUser:false,time:DateTime.now()));
        emit(AiChatbotInitialState(messages: List.from(_messages),isLoading:false));
      }
    },);
  }
}