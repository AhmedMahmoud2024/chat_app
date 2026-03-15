import 'package:chat_app/Features/Auth/presentation/Chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

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
      body: StreamBuilder<QuerySnapshot>(
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
                final userName = userData['name'];
                final userEmail = userData['email'];
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
        
    )
    );
  }
}