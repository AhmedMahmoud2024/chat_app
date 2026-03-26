import 'package:chat_app/Core/Network/story_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuildAddButton extends StatelessWidget {
 final bool isUploading ;
  const BuildAddButton({super.key, required this.isUploading});

  @override
  Widget build(BuildContext context) {
     return GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap:() async{
    await StoryService().uploadStory(
      userId: FirebaseAuth.instance.currentUser!.uid,
      username: FirebaseAuth.instance.currentUser!.displayName ?? '',
    );
  },
    child: Column(
    children: [
      Stack(
        alignment: Alignment.bottomRight,

        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            child: isUploading ? CircularProgressIndicator(strokeWidth: 2,): Icon(Icons.add,color: Colors.blue,),
              
          ),
        ],
      ),
      Text('Your Story',style: TextStyle(fontSize: 12),)
    ],
  ),
 ) ;
  }
}