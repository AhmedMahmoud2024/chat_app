import 'package:chat_app/Features/chatbot/presentation/bloc/ai_chatbot_bloc.dart';
import 'package:chat_app/Features/chatbot/presentation/bloc/ai_chatbot_state.dart';
import 'package:chat_app/Features/chatbot/presentation/widgets/ai_chat_bubble.dart';
import 'package:chat_app/Features/chatbot/presentation/widgets/ai_message_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiChatbotScreen extends StatelessWidget {
  const AiChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title:Text('Welcome to AI ChatBot'),
      ),
        body:BlocBuilder<AiChatbotBloc, AIChatbotState>(
          builder:(context,state){
            if(state is AiChatbotInitialState){
              return Column(children: [
                Expanded(child: ListView.builder(
                  reverse:true,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[state.messages.length-1-index];
                    return AiChatBubble(message: message.text);
                  },
                ),
                ),
                if(state.isLoading)
                  CircularProgressIndicator(),
                  AiMessageInputField(),
              ],
              );
            }
            return Container();
          }
          )
    );
  }
}