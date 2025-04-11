import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message.dart';
import 'message_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/chat_service.dart';

class ChatScreen extends StatefulWidget {
  // final String peerEmail;
  final DocumentSnapshot peer;

  ChatScreen({required this.peer});

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat With: ${widget.peer['email']}"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20.0),
          child: Text(
            "Logged In As: ${currentUser?.email}",
            style: TextStyle(color: Colors.white),
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
                  stream: _chatService.getMessages(widget.peer),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print("All messages snapshot error: ${snapshot.error}");
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse:
                      true, // This will make the latest messages appear at the bottom.
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isSent =
                            message.senderId == _auth.currentUser!.uid;
                        return MessageWidget(message: message, isSent: isSent);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                                widget.peer,
                                _messageController.text,
                                _image,
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
