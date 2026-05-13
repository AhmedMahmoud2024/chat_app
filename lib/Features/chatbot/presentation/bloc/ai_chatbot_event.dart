abstract class AIChatbotEvent {}
class AiChatbotSendMessageEvent extends AIChatbotEvent{
  final String message;
  AiChatbotSendMessageEvent({required this.message});
}