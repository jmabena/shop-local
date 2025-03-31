import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'all_stores_section.dart';
import 'FilterMenu.dart';
import 'top_rates_section.dart';


class HomePage extends StatefulWidget {
  final void Function(bool isDark) onThemeChanged;

  const HomePage({super.key , required this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  final List<String> _allItems = ["Item 1", "Item 2", "Item 3", "Item 4"];
  List<String> _filteredItems = [];

  final List<String> menuItems = ["Food", "Clothing", "School Supplies", "Wine"];


  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    widget.onThemeChanged(_isDarkMode);
  }



  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_allItems);
  }

  void _filterItems(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems = _allItems.where((item) => item.contains("$index")).toList();
      }
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children:[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),

                    ),
                    child: Icon(Icons.person, size: 60, color: Colors.white,)
                  ),

                  const SizedBox(height: 5),
                  const Text(
                    'Arshia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
              onTap: () {},
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
            const SizedBox(height: 20),
            // Constrain horizontal lists with fixed height
            // Adjust based on your needs
            TopRatesSection(),
            const SizedBox(height: 20),
            AllStoresSection()
          ],
        ),
      ),
    );
  }
}