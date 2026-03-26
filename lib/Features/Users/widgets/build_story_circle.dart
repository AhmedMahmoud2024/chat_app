import 'package:chat_app/Features/Users/data/models/story_model.dart';
import 'package:chat_app/Features/Users/widgets/story_content_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuildStoryCircle extends StatelessWidget {
final StoryModel story;
  const BuildStoryCircle({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
  return GestureDetector(
  onTap: () {
  if(story.images.isNotEmpty){
    Navigator.push(context, MaterialPageRoute(builder: (context) => StoryContentView(
        story: story,
        //urls:story.images,
      //  name:story.username, 
      ),));
  }
  },
  child: Padding(padding: EdgeInsets.symmetric(horizontal: 8),
  child: Column(
    children: [
  Container(
    padding: EdgeInsets.all(2),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.blue,width: 2),

      
    ),
    child: CircleAvatar(
      radius: 28,
      backgroundImage:( story.images !=null && story.images.isNotEmpty ? NetworkImage(story.images.last) : null),
      child: (story.images ==null || story.images.isEmpty) ? Icon(Icons.person,color: Colors.white,): null,
 ),
  ),
  FutureBuilder(future: FirebaseFirestore.instance.collection('users').doc(story.userId).get(),
  
   builder:(context,snapshot){
    if(snapshot.hasData && snapshot.data!.exists){
      var userData= snapshot.data!.data() as Map<String,dynamic>;
      String username = userData['username'] ?? 'User';
      return Text(username,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,);
    }
    return Text('User',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,);
   } 
  
   )
  // Text(FirebaseAuth.instance.currentUser?.displayName ?? 'User',style: TextStyle(color: Colors.black),)
    ],
  ),
  
));
}
  }
