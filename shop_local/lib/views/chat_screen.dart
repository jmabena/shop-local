import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message.dart';
import '../models/seller_model.dart';
import '../models/user_model.dart';
import 'message_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/message_controller.dart';

class ChatScreen extends StatefulWidget {
  final Message? message;
  final dynamic peer;

  const ChatScreen({super.key, required this.peer, this.message});

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  // final FirebaseMessagingService _messagingService = FirebaseMessagingService();
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ChatService _chatService;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
  }


  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }


  @override
  Widget build(BuildContext context) {
    _chatService = ChatService();

    final peer = widget.peer;
    String receiverId;
    String receiverEmail;

    if (peer is SellerModel) {
      receiverEmail = peer.organizationName;
      receiverId = peer.sellerId!;
    } else if (peer is UserModel) {
      receiverEmail = peer.email;
      receiverId = peer.uid!;
    } else {
      receiverEmail = "Unknown";
      receiverId = "unknown";
    }

    final titleText = "Chat with: $receiverEmail";

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Text(
            "Logged In As: ${currentUser?.email}",
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: _chatService.getMessages(receiverId, currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      //print("All messages snapshot error: ${snapshot.error}");
                      return Center(
                          child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse:
                      true,
                      // This will make the latest messages appear at the bottom.
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isSent =
                            message.senderId == _auth.currentUser!.uid;
                        return MessageWidget(
                            message: message, isSent: isSent);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 4.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            onPressed: _pickImageFromGallery,
                            icon: Icon(Icons.photo),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: _pickImageFromCamera,
                          ),
                        ),
                        // display the image if it is not null
                        if (_image != null)
                          Image.file(
                            File(_image!.path),
                            height: 100,
                            width: 100,
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () async {
                              await _chatService.sendMessage(
                                receiverId,
                                receiverEmail,
                                _messageController.text,
                                _image,
                                widget.message,
                              );
                              _messageController.clear();
                              setState(() {
                                _image = null;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}