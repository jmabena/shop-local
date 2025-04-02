import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_local/controller/user_controller.dart';

import '../models/product_model.dart';
import '../models/seller_model.dart';
import '../models/user_model.dart';

class SellerProfileScreen extends StatefulWidget {
  final UserModel user;
  const SellerProfileScreen({super.key, required this.user});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final UserController _userController = UserController();

  // Controllers for additional seller info fields
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _businessDescriptionController = TextEditingController();

  // Controllers to add product details
  final TextEditingController _productPrice = TextEditingController();
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _productDesc = TextEditingController();

  // File variables for images
  File? _businessLogo;
  File? _businessPicture;
  File? _productImage;

  @override
  void dispose() {
    _businessTypeController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _productPrice.dispose();
    _productName.dispose();
    _productDesc.dispose();
    super.dispose();
  }

  Future<void> _pickBusinessLogo() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _businessLogo = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickProductImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _productImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBusinessPicture() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _businessPicture = File(pickedFile.path);
      });
    }
  }

  /// Opens a dialog to add additional seller information
  void _showAddInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Seller Information"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Business Logo Picker
                Row(
                  children: [
                    // If a logo has been selected, show it; otherwise, show a placeholder icon.
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: _businessLogo != null ? FileImage(_businessLogo!) : null,
                      child: _businessLogo == null ? const Icon(Icons.image) : null,
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: _pickBusinessLogo,
                      child: const Text("Pick Logo"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Business Picture Picker
                Row(
                  children: [
                    TextButton(
                      onPressed: _pickBusinessPicture,
                      child: const Text("Pick Business Pic"),
                    ),
                    const SizedBox(width: 10),
                    // Show a preview of the business picture if selected
                    _businessPicture != null
                        ? Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_businessPicture!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                        : const Icon(Icons.image, size: 50),
                  ],
                ),
                const SizedBox(height: 20),
                // Business Type Field
                _buildTextField('Name of Business', _businessNameController),
                _buildTextField('Type of Business', _businessTypeController),
                _buildTextField('Business Description', _businessDescriptionController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear inputs if needed
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate that the required fields are not empty.
                if (_businessNameController.text.isEmpty || _businessTypeController.text.isEmpty ||
                    _businessDescriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields")),
                  );
                  return;
                }
                await _addSellerInformation();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Product Information"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Product Picture Picker
                Row(
                  children: [
                    TextButton(
                      onPressed: _pickProductImage,
                      child: const Text("Pick Business Pic"),
                    ),
                    const SizedBox(width: 10),
                    // Show a preview of the business picture if selected
                    _productImage != null
                        ? Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_productImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                        : const Icon(Icons.image, size: 50),
                  ],
                ),
                const SizedBox(height: 20),
                // Business Type Field
                TextField(
                  controller: _productName,
                  decoration: const InputDecoration(
                    labelText: "Name of Product",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _productPrice,
                  decoration: const InputDecoration(
                    labelText: "Product Price",
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                // Business Description Field
                TextField(
                  controller: _productDesc,
                  decoration: const InputDecoration(
                    labelText: "Product Description",
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear inputs if needed
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate that the required fields are not empty.
                if (_productPrice.text.isEmpty ||
                    _productName.text.isEmpty || _productDesc.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields")),
                  );
                  return;
                }
                await _addProductInformation();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) => value!.isEmpty ? '$label is required' : null,
    );
  }

  Future<void> _addProductInformation() async {
    try {
      String? pictureUrl;

      if (_productImage != null) {
        final ref = _storage.ref().child('images/${widget.user.id}/${DateTime
            .now()
            .millisecondsSinceEpoch}_$_productImage');
        await ref.putFile(_productImage!);
        pictureUrl = await ref.getDownloadURL();
      }

      final productInfo = ProductModel(
        productUrl: pictureUrl,
        productName: _productName.text,
        productPrice: double.parse(_productPrice.text),
        productDesc: _productDesc.text,
        sellerId: widget.user.id!,
      );
      await _userController.addSellerProduct(productInfo, userId);
      // Optionally clear the fields after successful addition:
      _productName.clear();
      _productPrice.clear();
      _productDesc.clear();
      setState(() {
        _productImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product information added successfully")),
      );
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding product info: $e")),
      );
    }
  }

  /// Uploads images to Firebase Storage (if selected) and then saves the seller information
  Future<void> _addSellerInformation() async {
    try {
      // Upload images if available
      String? logoUrl;
      String? pictureUrl;

      if (_businessLogo != null) {
        final ref = _storage.ref().child('seller_logos').child('${widget.user.id}_logo.jpg');
        await ref.putFile(_businessLogo!);
        logoUrl = await ref.getDownloadURL();
      }
      if (_businessPicture != null) {
        final ref = _storage.ref().child('seller_pictures').child('${widget.user.id}_business.jpg');
        await ref.putFile(_businessPicture!);
        pictureUrl = await ref.getDownloadURL();
      }

      // Create the seller model data
      final sellerInfo = SellerModel(
        sellerId: widget.user.id!,
        logoUrl: logoUrl,
        picUrl: pictureUrl,
        organizationName: _businessNameController.text,
        organizationType: _businessTypeController.text,
        organizationDesc: _businessDescriptionController.text,
      );

      await _userController.saveSellerInfo(sellerInfo);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seller information added successfully")),
      );

      // Optionally clear the fields after successful addition:
      _businessNameController.clear();
      _businessTypeController.clear();
      _businessDescriptionController.clear();
      setState(() {
        _businessLogo = null;
        _businessPicture = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding seller info: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Organization Info from the user model
          Text("License Number: ${widget.user.licenseNumber}"),
          const SizedBox(height: 20),
          // Conditionally display seller information if it exists.
          StreamBuilder<SellerModel?>(
            stream: _userController.getSellerInfo(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (snapshot.hasData && snapshot.data != null) {
                final sellerInfo = snapshot.data!;
                return _buildSellerInfoSection(sellerInfo);
              } else {
                // If no seller info is found, show the Add Information button.
                return Center(
                  child: ElevatedButton.icon(
                    onPressed: _showAddInfoDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Information"),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfoSection(SellerModel sellerInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*
        // Business Logo
        CircleAvatar(
          radius: 60,
          backgroundImage: sellerInfo.logoUrl != null
          ? NetworkImage(sellerInfo.logoUrl!) : null,
        ),
        const SizedBox(height: 20),
        // Business Picture
        Image.network(sellerInfo.picUrl != null ? sellerInfo.picUrl! : ''),
        const SizedBox(height: 20),
         */
        // Business Name
        Text("Business Name: ${sellerInfo.organizationName}"),
        const SizedBox(height: 10),
        // Business Type
        Text("Business Type: ${sellerInfo.organizationType}"),
        const SizedBox(height: 10),
        // Business Description
        Text("Description: ${sellerInfo.organizationDesc}"),
        const SizedBox(height: 20),
        // Button to edit seller information
        ElevatedButton(
          onPressed: _showAddInfoDialog,
          child: const Text("Edit Information"),
        ),
        ElevatedButton(
          onPressed: _showAddProductDialog,
          child: const Text("Add Products"),
        ),
      ],
    );
  }
}
