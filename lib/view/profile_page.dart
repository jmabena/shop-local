import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_local/controller/user_controller.dart';
import 'package:shop_local/view/seller_profile.dart';
import 'dart:io';

import '../models/user_model.dart';

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
  final address = TextEditingController();
  final city = TextEditingController();
  final postalCode = TextEditingController();
  final organizationName = TextEditingController();
  final licenseNumber = TextEditingController();

  final UserController userController = UserController();

  @override
  void dispose() {
    // Dispose controllers
    address.dispose();
    city.dispose();
    postalCode.dispose();
    organizationName.dispose();
    licenseNumber.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showAccountTypeDialog(bool isBuyer) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(isBuyer ? 'Buyer Details' : 'Seller Details'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Common Fields
                    _buildImagePicker(setStateDialog),
                    _buildTextField('Address', Icons.location_on, address),
                    _buildTextField('City', Icons.location_city, city),
                    _buildTextField('Postal Code', Icons.markunread_mailbox, postalCode),
                    // Seller-specific Fields
                    if (!isBuyer) ...[
                      _buildTextField('License Number', Icons.assignment, licenseNumber),
                    ],
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
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    _saveUser(isBuyer);
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

  Widget _buildTextField(String label, IconData icon, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? '$label is required' : null,
    );
  }

  Widget _buildImagePicker(StateSetter setStateDialog) {
    return Column(
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
    );
  }

  void _showSuccessMessage(bool isBuyer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isBuyer ? 'Buyer' : 'Seller'} profile created successfully!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetForm() {
    address.clear();
    city.clear();
    postalCode.clear();
    licenseNumber.clear();
    setState(() => _selectedImage = null);
    _formKey.currentState?.reset();
  }

  void _deleteAccount(UserModel userData) async{
    try{
      if (userData.accountType == 'seller') {
        await userController.deleteSellerInfo(userData.id!);
        await userController.deleteSellerProducts(userData.id!);
      }
      await userController.deleteUser(userData.id!);
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
  void _saveUser(bool isBuyer) async {
    final user = FirebaseAuth.instance.currentUser!;
    String? imageUrl;

    /*
    if (_selectedImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user.uid}.jpg');
      await ref.putFile(_selectedImage!);
      imageUrl = await ref.getDownloadURL();
    }
    */

    final userModel = UserModel(
      id: user.uid,
      accountType: isBuyer ? 'buyer' : 'seller',
      address: address.text,
      city: city.text,
      postalCode: postalCode.text,
      licenseNumber: isBuyer ? null : licenseNumber.text,
      photoUrl: imageUrl,
    );

    try {
      await userController.saveUser(userModel);
      _showSuccessMessage(isBuyer);
      _resetForm();
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
        stream: userController.getCurrentUser(),
        builder: (context, snapshot) {
          // If data exists, assume the profile has been created
          if (snapshot.hasData) {
            UserModel userData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: userData.photoUrl != null
                          ? NetworkImage(userData.photoUrl!)
                          : null,
                      child: userData.photoUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(firebaseUser.email ?? 'No email provided',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 40),

                    // Display the user profile information
                    if (userData.accountType == 'seller')
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
          } else {
            // Profile not created yet, show account type selection buttons
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: firebaseUser.photoURL != null
                        ? NetworkImage(firebaseUser.photoURL!)
                        : null,
                    child: firebaseUser.photoURL == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(firebaseUser.email ?? 'No email provided',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 40),
                  const Text('Select Account Type',
                      style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _AccountTypeButton(
                        icon: Icons.shopping_cart,
                        label: 'Buyer',
                        onPressed: () => _showAccountTypeDialog(true),
                      ),
                      _AccountTypeButton(
                        icon: Icons.store,
                        label: 'Seller',
                        onPressed: () => _showAccountTypeDialog(false),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class _AccountTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _AccountTypeButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 30),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
