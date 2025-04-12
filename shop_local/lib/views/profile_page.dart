import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop_local/controller/user_controller.dart';
import 'dart:io';
import 'package:shop_local/models/user_model.dart';
import 'package:shop_local/views/seller_profile.dart';

import '../controller/seller_controller.dart';
import 'network_image_builder.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  String? photoUrl;


  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showAddProfileImageDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Add Profile Image'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                      child: _selectedImage == null ? const Icon(Icons.camera_alt, size: 40) : null,
                    ),
                    TextButton(
                      onPressed: _pickImage,
                      child: Text(_selectedImage == null ? 'Add Profile Image' : 'Change Image'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_selectedImage != null) {
                    Navigator.pop(context);
                    _saveUserProfileImage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select an image'),
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile Image added successfully!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  void _deleteAccount(UserModel userData) async{
    try{
      if (userData.userType == 'seller') {
        await context.read<SellerController>().deleteSellerInfo(userData.uid!);
        await context.read<SellerController>().deleteSellerProducts(userData.uid!);
      }
      await context.read<UserController>().deleteUser(userData.uid!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account deleted successfully'),
        ),
      );
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
  void _saveUserProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    String? imageUrl;

    if (_selectedImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_profile_images')
          .child('${user!.uid}.jpg');
      await ref.putFile(_selectedImage!);
      imageUrl = await ref.getDownloadURL();
    }

    try {
      if (imageUrl != null) {
        await context.read<UserController>().saveProfileImage(imageUrl);
        _showSuccessMessage();
      }
      setState(() {}); // trigger a rebuild to update the UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: firebaseUser == null
          ? const Center(child: Text('Please sign in'))
          : StreamBuilder<UserModel>(
        stream: context.read<UserController>().getCurrentUser(firebaseUser.uid),
        builder: (context, snapshot) {
          // If data exists, assume the profile has been created
          if (snapshot.hasData) {
            UserModel userData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showAddProfileImageDialog,
                        child: NetworkImageWithFallback(
                          imageUrl: userData.photoUrl,
                          fallbackWidget: const Icon(Icons.person, size: 60),
                          builder: (imageProvider) => CircleAvatar(
                            backgroundImage: imageProvider,
                            radius: 60,
                          ),
                        ),
                    ),
                    const SizedBox(height: 20),
                    Text(firebaseUser.email ?? 'No email provided',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 40),

                    // Display the user profile information
                    if (userData.userType == 'seller')
                      SellerProfileScreen(user: userData,),

                    Text('Mailing address', style: TextStyle(fontSize: 18),),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Address'),
                      subtitle: Text(userData.address),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_city),
                      title: const Text('City'),
                      subtitle: Text(userData.city),
                    ),
                    ListTile(
                      leading: const Icon(Icons.markunread_mailbox),
                      title: const Text('Postal Code'),
                      subtitle: Text(userData.postalCode),
                    ),
                    ElevatedButton(
                        onPressed: () => _deleteAccount(userData),
                        child: Text(
                          "Delete Account",
                        ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            // While loading, show a progress indicator
            return const Center(child: CircularProgressIndicator());
          }
        }
      ),
    );
  }
}

