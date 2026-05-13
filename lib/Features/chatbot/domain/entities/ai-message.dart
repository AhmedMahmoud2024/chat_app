class AIMessage{
  final String text;
  final bool isUser;
  final DateTime time;
  AIMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}