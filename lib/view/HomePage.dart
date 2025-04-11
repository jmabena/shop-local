import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:shop_local/model/story.dart';

import '../model/category.dart';
import '../services/FirebaseService.dart';
import 'AllStoresSection.dart';
import 'FilterMenu.dart';
import 'TopRatesSection.dart';
import 'messageScreen.dart';
import 'profile_page.dart';
import 'news_screen.dart';


class HomePage extends StatefulWidget {
  final void Function(bool isDark) onThemeChanged;

  const HomePage({super.key , required this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseService _firebaseService = FirebaseService();
  List<Category> categories = [];
  int selectedIndex = 0;
  bool _isDarkMode = false;
  final List<Story> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  List<Story> _searchResults = [];
  bool _showSuggestions = false;
  String? userEmail = FirebaseAuth.instance.currentUser?.email;


  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    widget.onThemeChanged(_isDarkMode);
  }

 Future<void> _logout() async {
  try {
    await FirebaseAuth.instance.signOut();
    // Navigate back to login screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }}


  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadItems();
  }
  void _loadCategories() async {
    categories = await _firebaseService.getCategories();
    setState(() {});
  }
  void _filterItems(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  void _loadItems() async {
    final stories = await _firebaseService.getAllStories();
    setState(() {
      _filteredItems.addAll(stories.map((s) => Story(id: s.id , imageUrl: s.imageUrl , categoryId: s.categoryId , title: s.title)));
    });
  }


  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _showSuggestions = false;
      });
      return;
    }

    final results = _filteredItems
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _searchResults = results;
      _showSuggestions = results.isNotEmpty;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer:Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
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
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/defaultUserImage.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),
                   Text(
                     userEmail ?.split('@').first ?? 'User',
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
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) =>  ProfileScreen()));},
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) =>  HomeScreen()));},
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('News & Updates'),
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) =>  NewsPage()));},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
    appBar: AppBar(

        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    FilterMenu(
                      selectedIndex: selectedIndex,
                      onItemSelected: _filterItems,
                      items: ['All', ...categories.map((c) => c.name).toList()],
                    ),

                    FutureBuilder(
                      future: _firebaseService.getTopRates(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return TopRatesSection(topRates: snapshot.data!);
                      },
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder(
                      future: selectedIndex == 0
                          ? _firebaseService.getAllStories()
                          : _firebaseService.getStoriesByCategory(
                          categories[selectedIndex - 1].id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return AllStoresSection(stories: snapshot.data!);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_showSuggestions)
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _searchResults[index].imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image),
                          ),
                        ),
                        title: Text(_searchResults[index].title),
                        onTap: () {
                          _searchController.text = _searchResults[index].title;
                          _onSearchChanged(_searchResults[index].title);
                          setState(() => _showSuggestions = false);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );

  }
}
