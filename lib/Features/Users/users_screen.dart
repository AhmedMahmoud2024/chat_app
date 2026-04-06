import 'package:chat_app/Core/Network/story_service.dart';
import 'package:chat_app/Features/Chat/chat_screen.dart';
import 'package:chat_app/Features/Users/data/models/story_model.dart';
import 'package:chat_app/Features/Users/widgets/build_add_button.dart';
import 'package:chat_app/Features/Users/widgets/build_story_circle.dart';
import 'package:chat_app/Features/Users/widgets/story_content_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final StoryController controller=StoryController();
  bool _isUploading=false;
  @override
  Widget build(BuildContext context) {
   final currentUserId=FirebaseAuth.instance.currentUser!.uid;
   
    return  Scaffold(
      appBar:AppBar(
        title: Text('Users'),
        leading: IconButton(onPressed: () async{
          await FirebaseAuth.instance.signOut();
        }, icon: Icon(Icons.logout)),
      ) ,
      body: Column(
        children: [
             Container(
                height: 120,
                child: StreamBuilder<List<StoryModel>>(
                  stream: StoryService().getStories(),
                   builder: (context,snapshot){
                   final stories=snapshot.data ?? [];
                   return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemCount: stories.length+1,
                    itemBuilder: (context,index){
                      if(index==0) return BuildAddButton(isUploading: _isUploading);
                      return BuildStoryCircle(story: stories[index-1]);
                    }); 
                   }
                   ),
                ),
              Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').
              where(FieldPath.documentId,isNotEqualTo: currentUserId)
              .snapshots()
              ,
              builder: (context, snapshot) {
                if(snapshot.connectionState== ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount:snapshot.data!.docs.length ,
                  itemBuilder:(context,index){
                    final userData =snapshot.data?.docs[index].data() as Map<String,dynamic>;
                    final receiverId = snapshot.data?.docs[index].id;
                      final userName = userData['name'].toString();
                      final userEmail = userData['email'].toString();
                   return ListTile(
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>ChatScreen(
                       receiverId:receiverId ?? '' ,
                        receiverName: userName,
                      )));
                    },
                    leading: CircleAvatar(
                      child:  Icon(Icons.person),
                    ),
                    title: Text(userName),
                    subtitle: Text(userEmail),
                   
                   );
                  } ,
                  );
              }
              
                ),
          ),
        ],
      )
    );
  }
}



