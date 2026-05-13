import 'package:chat_app/Features/chatbot/domain/entities/ai-message.dart';

abstract class AIChatbotState {}
class AiChatbotInitialState extends AIChatbotState{
  final List<AIMessage> messages;
  final bool isLoading ;
  AiChatbotInitialState({required this.messages,this.isLoading=false});
}