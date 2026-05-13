import 'package:chat_app/Features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/Features/chatbot/presentation/bloc/ai_chatbot_bloc.dart';
import 'package:chat_app/Features/chatbot/presentation/bloc/ai_chatbot_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiMessageInputField extends StatefulWidget {
  const AiMessageInputField({super.key});

  @override
  State<AiMessageInputField> createState() => _AiMessageInputFieldState();
}

class _AiMessageInputFieldState extends State<AiMessageInputField> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final message = _controller.text.trim();
              if (message.isNotEmpty) {
                context.read<AiChatbotBloc>().add(AiChatbotSendMessageEvent(message: message));
                // Handle sending the message
                _controller.clear();
              }
            },
          ),
        ],
    )
    );
  }

}