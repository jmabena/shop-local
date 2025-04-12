import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shop_local/controller/user_controller.dart';
import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userController = UserController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final String userEmail = FirebaseAuth.instance.currentUser!.email!;
  late String chatId;

  String _generateChatId(String userId, String peerId) {
    return userId.compareTo(peerId) < 0
        ? '${userId}_$peerId'
        : '${peerId}_$userId';
  }

  String getChatIdFromMessageOrPeer({Message? message, required String peerId}) {
    if (message != null) {
      return _generateChatId(message.senderId, message.receiverId);
    }
    return _generateChatId(userId, peerId);
  }


  Future<void> sendMessage(
      String receiverId,
      String receiverEmail,
      String messageText,
      XFile? image,
      Message? message,
      ) async {
    String? imageUrl;

    // Determine the chatId based on whether this is a new conversation or a reply.
    chatId = getChatIdFromMessageOrPeer(
      message: message,
      peerId: receiverId,
    );

    // Upload image if attached
    if (image != null) {
      final firebaseStorageRef =
      FirebaseStorage.instance.ref().child('images/$userId/${image.name}');
      try {
        final uploadTask = await firebaseStorageRef.putFile(File(image.path));
        if (uploadTask.state == TaskState.success) {
          imageUrl = await firebaseStorageRef.getDownloadURL();
        }
      } catch (e) {
        throw "Failed to upload image: $e";
      }
    }

    // Determine sender/receiver based on existing message
    late String senderId;
    late String senderEmail;
    late String finalReceiverId;
    late String finalReceiverEmail;

    if (message == null) {
      // New conversation
      senderId = userId;
      senderEmail = userEmail;
      finalReceiverId = receiverId;
      finalReceiverEmail = receiverEmail;
    } else {
      // Existing conversation: keep roles consistent
      if (userId == message.senderId) {
        senderId = userId;
        senderEmail = userEmail;
        finalReceiverId = message.receiverId;
        finalReceiverEmail = message.receiverEmail;
      } else {
        senderId = userId;
        senderEmail = userEmail;
        finalReceiverId = message.senderId;
        finalReceiverEmail = message.senderEmail;
      }
    }

    Message newMessage = Message(
      senderId: senderId,
      senderEmail: senderEmail,
      receiverId: finalReceiverId,
      receiverEmail: finalReceiverEmail,
      chatId: chatId,
      text: messageText,
      timestamp: Timestamp.now(),
      imageUrl: imageUrl,
    );

    await _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());
  }



  getMessages(String peerId, String senderId) {
    final chatId = _generateChatId(peerId, senderId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Message.fromMap(doc)).toList());
  }

  Stream<List<Message>> getUserConversations(String userId) {
    final senderStream = FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    final receiverStream = FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Rx.combineLatest2(
      senderStream,
      receiverStream,
          (QuerySnapshot senderSnapshot, QuerySnapshot receiverSnapshot) {
        final senderMessages = senderSnapshot.docs
            .map((doc) => Message.fromMap(doc))
            .toList();

        final receiverMessages = receiverSnapshot.docs
            .map((doc) => Message.fromMap(doc))
            .toList();

        // Merge the two lists and sort by timestamp descending
        final allMessages = [...senderMessages, ...receiverMessages]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        // Group messages by chatId to get unique conversations.
        final Map<String, Message> conversationMap = {};
        for (Message message in allMessages) {
          // We assume chatId is unique per conversation.
          // If we already have a message for this chatId, we keep the one with the latest timestamp.
          if (!conversationMap.containsKey(message.chatId) ||
              message.timestamp.toDate().isAfter(conversationMap[message.chatId]!.timestamp.toDate())) {
            conversationMap[message.chatId] = message;
          }
        }

        // Convert the map values to a list and sort it.
        final dedupedMessages = conversationMap.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return dedupedMessages;
      },
    );
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