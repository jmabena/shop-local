import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_local/controller/user_controller.dart';
import 'dart:io';

import 'package:shop_local/model/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;
  late bool _isBuyer;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  String? photoUrl;
  String? id;
  late String accountType;
  final address = TextEditingController();
  final city = TextEditingController();
  final postalCode = TextEditingController();
  final organizationName = TextEditingController();
  final organizationDescription = TextEditingController();
  final organizationType = TextEditingController();
  final licenseNumber = TextEditingController();
  final DateTime createdAt = DateTime.now();
  final DateTime updatedAt = DateTime.now();
  final UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    _isBuyer = true;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage =  File(image.path);
      });
    }
  }

  void _showAccountTypeDialog(bool isBuyer) {
    accountType = isBuyer ? 'buyer' : 'seller';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isBuyer ? 'Buyer Details' : 'Seller Details'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Common Fields
                    _buildImagePicker(setState),
                    _buildTextField('Address', Icons.location_on, address),
                    _buildTextField('City', Icons.location_city, city),
                    _buildTextField('Postal Code', Icons.markunread_mailbox, postalCode),

                    // Seller-specific Fields
                    if (!isBuyer) ...[
                      _buildTextField('Organization Name', Icons.business, organizationName),
                      _buildTextField('Organization Description',
                          Icons.description, organizationDescription, maxLines: 3),
                      _buildTextField('Organization Type', Icons.category, organizationType),
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
                    // Handle form submission
                    Navigator.pop(context);
                    _saveUser(isBuyer);
                  }
                },
                child: Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField( String label, IconData icon, TextEditingController controller,
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

  Widget _buildImagePicker(StateSetter setState) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: _selectedImage != null
              ? FileImage(_selectedImage!)
              : null,
          child: _selectedImage == null
              ? Icon(Icons.camera_alt, size: 40)
              : null,
        ),
        TextButton(
          onPressed: _pickImage,
          child: Text(_selectedImage == null
              ? 'Add Profile Image'
              : 'Change Image'),
        ),
      ],
    );
  }

  void _showSuccessMessage(bool isBuyer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isBuyer ? 'Buyer' : 'Seller'} profile created successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetForm() {
    address.clear();
    city.clear();
    postalCode.clear();
    organizationName.clear();
    organizationDescription.clear();
    organizationType.clear();
    licenseNumber.clear();
    setState(() => _selectedImage = null);
    _formKey.currentState?.reset();
  }

  void _saveUser(bool isBuyer) async{
    final user = FirebaseAuth.instance.currentUser!;
    String? imageUrl;

    // Upload image if selected
    /* if (_selectedImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user.uid}.jpg');
      await ref.putFile(_selectedImage!);
      imageUrl = await ref.getDownloadURL();
    }*/

    final userModel = UserModel(
      id: user.uid,
      accountType: isBuyer ? 'buyer' : 'seller',
      address: address.text,
      city: city.text,
      postalCode: postalCode.text,
      organizationName: isBuyer ? null : organizationName.text,
      organizationDescription: isBuyer ? null : organizationDescription.text,
      organizationType: isBuyer ? null : organizationType.text,
      licenseNumber: isBuyer ? null : licenseNumber.text,
      photoUrl: imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    try{
      await userController.saveUser(userModel);
      _showSuccessMessage(isBuyer);
      _resetForm();
      Navigator.pop(context);
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: user == null
          ? Center(child: Text('Please sign in'))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? Icon(Icons.person, size: 60)
                  : null,
            ),
            SizedBox(height: 20),
            Text(user.email ?? 'No email provided',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 40),
            Text('Select Account Type',
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AccountTypeButton(
                  icon: Icons.shopping_cart,
                  label: 'Buyer',
                  onPressed: () => _showAccountTypeDialog(_isBuyer),
                ),
                _AccountTypeButton(
                  icon: Icons.store,
                  label: 'Seller',
                  onPressed: () => _showAccountTypeDialog(!_isBuyer),
                ),
              ],
            ),
          ],
        ),
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
      label: Text(label, style: TextStyle(fontSize: 18)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}