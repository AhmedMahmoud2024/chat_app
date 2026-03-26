import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

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