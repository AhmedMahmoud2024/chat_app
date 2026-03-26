import 'package:chat_app/Features/Users/data/models/story_model.dart';
import 'package:chat_app/Features/Users/widgets/story_content_view.dart';
import 'package:flutter/material.dart';

class BuildStoryCircle extends StatelessWidget {
final StoryModel story;
  const BuildStoryCircle({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
  return GestureDetector(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => StoryContentView(
        url:story.imageUrl,
        name:story.username,
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
      backgroundImage:( story.imageUrl !=null && story.imageUrl.isNotEmpty ? NetworkImage(story.imageUrl) : null),
      child: (story.imageUrl ==null || story.imageUrl.isEmpty) ? Icon(Icons.person,color: Colors.white,): null,
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
     // backgroundImage: NetworkImage(story.imageUrl !=null && story.imageUrl.isNotEmpty ? story.imageUrl : ''),
    //  child: story.imageUrl ==null || story.imageUrl.isEmpty ? Icon(Icons.person,color: Colors.white,): null,
    ),
  ),
  
    ],
  ),
));
}
  }
