import 'package:flutter/material.dart';
import 'package:shop_local/AllStoresSection.dart';
import 'FilterMenu.dart';
import 'TopRatesSection.dart';


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
                      border: Border.all(color: Colors.white, width: 2), // اضافه کردن بوردر سفید

                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/defaultUserImage.png", // مسیر عکس لوکال
                        fit: BoxFit.cover,
                      ),
                    ),
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
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {},
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
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const SizedBox(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilterMenu(
            selectedIndex: _selectedIndex,
            onItemSelected: _filterItems,
            items: menuItems,
          ),

          // Expanded(
          //   child: ListView.builder(
          //     itemCount: _filteredItems.length,
          //     itemBuilder: (context, index) {
          //       return ListTile(title: Text(_filteredItems[index]));
          //     },
          //   ),
          // ),
          TopRatesSection(),
          const SizedBox(height: 20,),
         AllStoresSection()
        ],
      ),
    );
  }
}