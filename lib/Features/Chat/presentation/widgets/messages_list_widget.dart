import 'package:chat_app/Features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/Features/Chat/presentation/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesListWidget  extends StatelessWidget{
  const MessagesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
 return BlocBuilder<ChatBloc,ChatState>(builder: (context,state){
    if(state is ChatLoading){
      return const Center(child:  CircularProgressIndicator(),);
    }else if(state is ChatLoaded){
     if(state.messages.isEmpty){
      return Expanded(child: const Center(child: 
      Text('Start Conversation now...'),));
     }
     return  Expanded(
       child: ListView.builder(
        reverse: true,
        itemCount: state.messages.length,
       
        itemBuilder: (context,index){
        final message = state.messages[index];
       return  ChatBubble(message:message);
        }
        ),
     );
    }else if(state is ChatError){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message,style: const TextStyle(
              color: Colors.red
            ),),
             TextButton(onPressed: (){

            }, child: 
            Text('Retry')
            )
          ],
        ),
      );
    }
    return const SizedBox();
 }
 );
  }

}