import 'package:stream_video_flutter/stream_video_flutter.dart';

class CallUserModel extends User {
  final String id;
  final String name;
  final String image;

  CallUserModel({
    required this.id,
    required this.name,
    required this.image,
    
  }):super(
    info: UserInfo(id: id,image: image,name: name),
   
  );
}