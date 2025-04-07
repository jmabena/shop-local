import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../Model/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final String userEmail = FirebaseAuth.instance.currentUser!.email!;

  String _generateChatId(String userId, String peerId) {
    return userId.compareTo(peerId) < 0
        ? '${userId}_$peerId'
        : '${peerId}_$userId';
  }

  Future<void> sendMessage(
      DocumentSnapshot peer, String message, XFile? image) async {
    String? imageUrl;
    final chatId = _generateChatId(userId, peer.id);

    if (image != null) {
      // if images collection does not exist, create it

      final firebaseStorageRef =
          FirebaseStorage.instance.ref().child('images/$userId/${image.name}');

      try {
        final uploadTask = await firebaseStorageRef.putFile(File(image.path));
        if (uploadTask.state == TaskState.success) {
          imageUrl = await firebaseStorageRef.getDownloadURL();
          print("<Image Uploaded Successfully> Image URL: $imageUrl");
        }
      } catch (e) {
        print("Failed to upload image: $e");
      }
    }

    // create a new message object
    Message newMessage = Message(
      senderId: userId,
      senderEmail: userEmail,
      receiverId: peer.id,
      receiverEmail: peer['email'],
      chatId: chatId,
      text: message,
      timestamp: Timestamp.now(),
      imageUrl: imageUrl, // This will be null if _image is null.
    );

    // add the message to the chat_messages collection
    await _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  getMessages(DocumentSnapshot<Object?> peer) {
    final chatId = _generateChatId(userId, peer.id);

    return _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc)).toList());
  }
}
