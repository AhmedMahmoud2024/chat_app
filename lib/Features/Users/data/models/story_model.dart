import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel{
  // story model which will  be stored in database (story id ,userId ,username ,image url ,createdat)
  final String id;
  final String userId;
  final String username;
  final String imageUrl;
  final DateTime createdAt ;

  StoryModel({required this.id, required this.userId, required this.username, required this.imageUrl, required this.createdAt});
   // method return firebase object to dart object using factory pattern  
 factory StoryModel.fromMap(Map<String,dynamic>map,String id){
 return StoryModel(
 //left is my dart object ,right is firebase object
   id: id,
   userId: map['userId'] ?? '',
    username: map['username'] ?? '',
     imageUrl: map['imageUrl']?? '', 
    createdAt:( map['createdAt'] as Timestamp).toDate()
     );
 
}
    // to json send my dart object to firebase instance
 Map<String,dynamic>   toMap(){
return{
 'userId':userId,
 'username':username,
  'imageUrl':imageUrl,
  'createdAt':FieldValue.serverTimestamp(),

};
    }
}