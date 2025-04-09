import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

Future<String> uploadImage(File file, String path) async {
  final storageRef = FirebaseStorage.instance.ref().child(path);
  await storageRef.putFile(file);
  return await storageRef.getDownloadURL();
}
