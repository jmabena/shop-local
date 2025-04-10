import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_local/models/message.dart'; // Make sure you have this
import 'package:shop_local/controller/seller_controller.dart';

import '../controller/message_controller.dart';
import '../controller/user_controller.dart';
import '../models/seller_model.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final sellerController = SellerController();
    final userController = UserController();
    final chatService = ChatService();

    // Fetch the current user
    Future<dynamic> getPeerUser(String peerId) async {
      final sellerUser = await sellerController.getSellerInfoOnce(peerId);
      if (sellerUser != null) {
        return sellerUser;
      }
      return await userController.getUserById(peerId);
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: StreamBuilder<List<Message>>(
        stream: chatService.getUserConversations(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No conversations yet'));
          }

          final messages = snapshot.data!;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];

              // Determine the peer: if current user is sender, then peerId is receiver; otherwise, it's sender.
              final peerId = currentUser.uid == message.senderId
                  ? message.receiverId
                  : message.senderId;

              return FutureBuilder<dynamic>(
                future: getPeerUser(peerId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text("Loading..."));
                  }
                  if (snapshot.hasError) {
                    return ListTile(title: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData) {
                    return const ListTile(title: Text("No data"));
                  }

                  final peerUser = snapshot.data;
                  String titleText;

                  if (peerUser is SellerModel) {
                    // Use organization name if available
                    titleText = peerUser.organizationName;
                  } else if (peerUser is UserModel) {
                    titleText = peerUser.email;
                  } else {
                    titleText = "Unknown";
                  }

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(titleText),
                    subtitle: Text(message.text),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            // Pass the peerUser accordingly; you may need to convert it
                            peer: peerUser, // Ensure ChatScreen accepts the appropriate type
                            message: message,
                          ),
                        ),
                      );
                    },
                  );
                },
              );


            },
          );
        },
      ),
    );
  }
}
