import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/Features/Users/data/models/story_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class StoryService {
  final FirebaseFirestore _db =FirebaseFirestore.instance;
  final FirebaseStorage _storage=FirebaseStorage.instance;
final String apiKey= '6db475c1d7d3d7633adaa4455990366d';
  // we need 2 functions one for uploading story ,other for get story
 Future<void> uploadStory({
  required String userId,
  required String username
 }
 ) async{
try{
 final Picker= ImagePicker();
 final pickedFile =await Picker.pickImage(source: ImageSource.gallery,imageQuality: 70);
 if(pickedFile !=null){
   File imageFile=File(pickedFile.path);
  String fileName = 'stories/${DateTime.now().millisecondsSinceEpoch}.jpg';
 // convert image into base64 text 
 List<int> imagesBytes= await imageFile.readAsBytes();
 String based64Image = base64Encode(imagesBytes);
 // send upload request into imgbb website 
 var response = await http.post(Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'), body: {
   'image': based64Image
 });
 if(response.statusCode==200){
  var data =jsonDecode(response.body);
   String downloadUrl= data['data']['url']; //imge direct url
  
  final userStoryRef= FirebaseFirestore.instance.collection('stories').doc(userId);
 //save story data into firebase firestore
  await userStoryRef.update({
 'userId':userId,
 'username':username,
 'images':FieldValue.arrayUnion([downloadUrl]),
  'createdAt':FieldValue.serverTimestamp(),
});
  log('upload successfully in imgbb');
  SetOptions(merge: true);
 }
 }else{
  log('Error uploading story: ');
 } 
 }catch(e){
    log('Error uploading story: $e');
  }
}

  //get story function
 Stream<List<StoryModel>> getStories(){
 DateTime yesterday = DateTime.now().subtract(Duration(hours: 24));
 return _db.collection('stories').where('createdAt',isGreaterThan: yesterday).orderBy('createdAt',descending: true).snapshots()
 .map((snapshot)=>snapshot.docs.map((doc)=>StoryModel.fromMap(doc.data(),doc.id)).toList());
  }



}