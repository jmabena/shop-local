import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_local/view/network_image_builder_with_widget.dart';
import '../controller/deals_controller.dart';
import '../controller/seller_controller.dart';
import '../controller/user_controller.dart';
import '../models/seller_model.dart';
import '../models/user_model.dart';
import 'FilterMenu.dart';
import 'deals_screen.dart';
import 'network_image_builder.dart';
import 'order_page.dart';
import 'profile_page.dart';
import 'all_stores_section.dart';


class HomePage extends StatefulWidget {
  final void Function(bool isDark) onThemeChanged;

  const HomePage({super.key , required this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDarkMode = false;
  List<String> _filteredItems = [];
  int _selectedIndex = 0;

  // Setting up the controllers
  final SellerController sellerController = SellerController();
  final UserController userController = UserController();

  final List<String> menuItems = ["Food", "Clothing", "School Supplies", "Wine"];


  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    widget.onThemeChanged(_isDarkMode);
  }

  void _filterItems(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _filteredItems = List.from(_filteredItems);
      } else {
        _filteredItems = _filteredItems.where((item) => item.contains("$index")).toList();
      }
    });
  }

  Widget _buildSellerInfoBanner(List<SellerModel> seller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        //TopRatesSection(seller: seller),
        const SizedBox(height: 20),
        AllStoresSection(seller: seller),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children:[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: StreamBuilder<UserModel>(
                stream: userController.getCurrentUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  // If the document doesn't exist or data is null:
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text("User profile not found"));
                  }
                  UserModel userData = snapshot.data!;
                  print(userData);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageOrFallbackWidget(
                        imageUrl: userData.photoUrl,
                        fallbackAsset: null,
                        fallbackWidget: const Icon(Icons.person, size: 60),
                        builder: (imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: 40,
                        ),
                      ),

                      const SizedBox(height: 5),
                      Text(
                        firebaseUser?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {Navigator.pushReplacementNamed(context, '/home');},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('News & Updates'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider<DealsController>(
                      create: (context) => DealsController(),
                      child: DealsPage(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: SizedBox(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
            },
          ),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterMenu(
              selectedIndex: _selectedIndex,
              onItemSelected: _filterItems,
              items: menuItems,
            ),
            // Add Stream Builder for seller info
            StreamBuilder(
              stream: sellerController.getAllSellersStream(),
              builder: (context, sellerSnapshot) {
                if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (sellerSnapshot.hasError) {
                  return Center(child: Text("Error: ${sellerSnapshot.error}"));
                }
                if (!sellerSnapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final seller = sellerSnapshot.data!;
                return _buildSellerInfoBanner(seller);
              },
            ),
          ],
        ),
      ),
    );
  }
}