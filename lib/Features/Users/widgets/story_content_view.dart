import 'package:chat_app/Features/Users/data/models/story_model.dart';
import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

class StoryContentView extends StatefulWidget{
 final StoryModel story ;
 // final List<String> urls ;
 // final String name ;

  StoryContentView({super.key,required this.story});

  @override
  State<StoryContentView> createState() => _StoryContentViewState();
}

class _StoryContentViewState extends State<StoryContentView> {
  final StoryController controller = StoryController();

@override
  void dispose() {
   controller.dispose();
    super.dispose();
   
  }

  @override
  Widget build(BuildContext context) {
    if(widget.story.images==null || widget.story.images.isEmpty){
      return Scaffold(
        appBar: AppBar(title: Text(widget.story.username),),
        body: Center(child: Text('No story available'),),
      );
    }
  final StoryController controller = StoryController();
 
List<StoryItem> storyItems=widget.story.images.map((url) {
  return StoryItem.pageImage(
    url: url, 
    controller: controller,
    caption: Text(widget.story.username,style: TextStyle(color: Colors.white,fontSize: 18),)
    ); 
}).toList();

   return Scaffold(
body: StoryView(storyItems:storyItems
    ,
    onComplete: () {
      Navigator.pop(context);
    }, controller: controller,
    )
    
   );
  }
}