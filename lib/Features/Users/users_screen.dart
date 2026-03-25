import 'package:chat_app/Core/Network/story_service.dart';
import 'package:chat_app/Features/Auth/presentation/Chat/chat_screen.dart';
import 'package:chat_app/Features/Users/data/models/story_model.dart';
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
                      if(index==0) return _buildAddButton();
                      return _buildStoryCircule(stories[index-1]);
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

Widget _buildAddButton(){
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
            child: _isUploading ? CircularProgressIndicator(strokeWidth: 2,): Icon(Icons.add,color: Colors.blue,),
              
          ),
        ],
      ),
      Text('Your Story',style: TextStyle(fontSize: 12),)
    ],
  ),
 ) ;
}

// ignore: strict_top_level_inference
Widget _buildStoryCircule(stories) {
return GestureDetector(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => StoryContentView(
        url:stories.imageUrl,
        name:stories.username,
      ),));
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
      backgroundImage:( stories.imageUrl !=null && stories.imageUrl.isNotEmpty ? NetworkImage(stories.imageUrl) : null),
      child: (stories.imageUrl ==null || stories.imageUrl.isEmpty) ? Icon(Icons.person,color: Colors.white,): null,
      /*
        stories.imageUrl.isEmpty ? Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
           fit: BoxFit.cover,
            image: NetworkImage(stories.imageUrl))
        ),
        
      ) :CircularProgressIndicator()
     */
     // backgroundImage: NetworkImage(stories.imageUrl !=null && stories.imageUrl.isNotEmpty ? stories.imageUrl : ''),
    //  child: stories.imageUrl ==null || stories.imageUrl.isEmpty ? Icon(Icons.person,color: Colors.white,): null,
    ),
  ),
  
    ],
  ),
));
}


}

class StoryContentView extends StatelessWidget{
  final String url ;
  final String name ;
  final StoryController controller = StoryController();
  StoryContentView({required this.url,required this.name});
  
  @override
  Widget build(BuildContext context) {
  final StoryController controller = StoryController();
   return Scaffold(
body: StoryView(storyItems:[ StoryItem.pageImage(
  url: url,
   controller: controller,
   caption: Text(name),
    ),],
    onComplete: () {
      Navigator.pop(context);
    }, controller: controller,
    )
    
   );
  }
}

