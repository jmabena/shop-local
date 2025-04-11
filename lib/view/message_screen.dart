import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../controller/user_controller.dart';
import '../view/chat_screen.dart';
// import '../controller/chat_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserController>(context, listen: false).fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Redirect the user to the login screen after signing out.
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Consumer<UserController>(
        builder: (context, userController, child) {
          if (userController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final usersWithEmail = userController.usersWithEmail;

          final filteredUsers = usersWithEmail.entries
              .where((entry) =>
          entry.key != FirebaseAuth.instance.currentUser!.uid)
              .toList();
          if (filteredUsers.isEmpty) {
            return const Center(child: Text('No other users found.'));
          }

          return ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final entry = filteredUsers[index];
              final userId = entry.key;
              final userEmail = entry.value;
              return ListTile(
                title: Text(userEmail),
                subtitle: Text(userId),
                onTap: () {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get()
                      .then((value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(
                              peer: value,
                            ),
                      ),
                    );
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}


// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final chatService = ChatService();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Messages'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               Navigator.of(context).pushReplacementNamed('/login');
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: chatService.getUserChats(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(child: Text('Something went wrong'));
//           }
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final chats = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final chat = chats[index];
//               // Extract the other participant's ID (not current user)
//               final participants = List<String>.from(chat['participants']);
//               final otherUserId = participants.firstWhere(
//                 (id) => id != FirebaseAuth.instance.currentUser!.uid,
//               );

//               // You'll need to fetch the other user's details
//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(otherUserId)
//                     .get(),
//                 builder: (context, userSnapshot) {
//                   if (!userSnapshot.hasData) {
//                     return const ListTile(
//                       title: Text('Loading...'),
//                     );
//                   }
//                   final user = userSnapshot.data!;

//                   return ListTile(
//                     title: Text(user['email']),
//                     subtitle: Text('Last message preview...'), // Add actual last message
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ChatScreen(
//                             peer: user,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
