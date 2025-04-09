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


// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import '../Model/message.dart';

// class ChatService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   String get userId => _auth.currentUser!.uid;
//   String get userEmail => _auth.currentUser!.email!;

//   // Generate consistent chat room ID
//   String _generateChatId(String userId, String peerId) {
//     return userId.compareTo(peerId) < 0
//         ? '${userId}_$peerId'
//         : '${peerId}_$userId';
//   }

//   // Send a new message (text or image)
//   Future<void> sendMessage(
//       DocumentSnapshot peer, String message, XFile? image) async {
//     String? imageUrl;
//     final chatId = _generateChatId(userId, peer.id);

//     // Handle image upload if present
//     if (image != null) {
//       try {
//         final firebaseStorageRef =
//             FirebaseStorage.instance.ref().child('images/$userId/${image.name}');
//         final uploadTask = await firebaseStorageRef.putFile(File(image.path));
//         if (uploadTask.state == TaskState.success) {
//           imageUrl = await firebaseStorageRef.getDownloadURL();
//         }
//       } catch (e) {
//         print("Failed to upload image: $e");
//         throw Exception("Failed to upload image");
//       }
//     }

//     // Create message object
//     Message newMessage = Message(
//       senderId: userId,
//       senderEmail: userEmail,
//       receiverId: peer.id,
//       receiverEmail: peer['email'],
//       chatId: chatId,
//       text: message,
//       timestamp: Timestamp.now(),
//       imageUrl: imageUrl,
//     );

//     // Update chat room metadata
//     await _firestore.collection('chat_rooms').doc(chatId).set({
//       'participants': [userId, peer.id],
//       'lastMessage': message,
//       'lastMessageTime': Timestamp.now(),
//       'lastMessageSender': userId,
//     }, SetOptions(merge: true));

//     // Add the actual message
//     await _firestore
//         .collection('chat_rooms')
//         .doc(chatId)
//         .collection('messages')
//         .add(newMessage.toMap());
//   }

//   // Get all chats where current user is a participant
//   Stream<QuerySnapshot> getUserChats() {
//     return _firestore
//         .collection('chat_rooms')
//         .where('participants', arrayContains: userId)
//         .orderBy('lastMessageTime', descending: true)
//         .snapshots();
//   }

//   // Get messages for a specific chat
//   Stream<List<Message>> getMessages(DocumentSnapshot peer) {
//     final chatId = _generateChatId(userId, peer.id);
    
//     return _firestore
//         .collection('chat_rooms')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) =>
//             snapshot.docs.map((doc) => Message.fromMap(doc)).toList());
//   }

//   // Get user details by ID
//   Future<DocumentSnapshot> getUserDetails(String userId) {
//     return _firestore.collection('users').doc(userId).get();
//   }

//   // Mark messages as read
//   Future<void> markMessagesAsRead(String chatId) async {
//     final messages = await _firestore
//         .collection('chat_rooms')
//         .doc(chatId)
//         .collection('messages')
//         .where('receiverId', isEqualTo: userId)
//         .where('isRead', isEqualTo: false)
//         .get();

//     final batch = _firestore.batch();
//     for (var doc in messages.docs) {
//       batch.update(doc.reference, {'isRead': true});
//     }
//     return batch.commit();
//   }
// }