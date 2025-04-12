import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controller/cart_controller.dart';
import '../controller/seller_controller.dart';
import '../controller/user_controller.dart';
import '../models/seller_model.dart';
import '../models/user_model.dart';
import 'cart_icon_widget.dart';
import 'filter_menu.dart';
import 'deals_screen.dart';
import 'message_screen.dart';
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
  String _query = '';
  final  _searchController = TextEditingController();
  int _selectedIndex = 0;
  List<SellerModel> sellers = [];
  List<SellerModel> _filteredSellers = [];

  // Setting up the controllers
  final SellerController sellerController = SellerController();
  final UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    // Listen for changes in the search field and update the query.
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    widget.onThemeChanged(_isDarkMode);
  }

  // Filters businesses based on the query.
  List<SellerModel> _filterBusinesses(List<SellerModel> businesses) {
    if (_query.isEmpty) return businesses;
    return businesses.where((business) {
      final businessName = business.organizationName.toLowerCase().contains(_query.toLowerCase());
      final businessType =
      business.organizationType.toLowerCase().contains(_query.toLowerCase());
      return businessName || businessType;
    }).toList();
  }

  void _filterItems(int index, String title) {
    setState(() {
      _selectedIndex = index;
      if (index == 0 || title == "All") {
        _filteredSellers =  sellers;
      } else {
        _filteredSellers = sellers.where((seller) {
          return seller.organizationType == title;
        }).toList();
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
     // backgroundColor: _isDarkMode ? Colors.black : Colors.white,
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
                stream: userController.getCurrentUser(firebaseUser!.uid),
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
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: userData.photoUrl != ''
                            ? NetworkImage(userData.photoUrl!)
                            : null,
                        child: userData.photoUrl == ''
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),

                      const SizedBox(height: 5),
                      Text(
                        userData.email,
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MessageScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('Deals & Offers'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DealsPage(),
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
            controller: _searchController,
            decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                    }
                )
                    : null,
                filled: true,
                fillColor: _isDarkMode ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                )
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
        ),
        actions: [
          CartIconWithBadge(cartController: CartController(),),
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
            StreamBuilder(
                stream: sellerController.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final categories = snapshot.data!;
                  return FilterMenu(
                    selectedIndex: _selectedIndex,
                    onItemSelected: _filterItems,
                    categories: categories,
                  );
                }
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
                sellers = sellerSnapshot.data!;

                // Filter the sellers based on the search query
                final filteredSellers = _query.isEmpty ? _filteredSellers.isEmpty ? sellers : _filteredSellers : _filterBusinesses(sellers);
                return _buildSellerInfoBanner(filteredSellers);
              },
            ),
          ],
        ),
      ),
    );
  }
}

