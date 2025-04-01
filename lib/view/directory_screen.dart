import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../controller/news_controller.dart';
import 'news_screen.dart';

class BusinessDirectoryPage extends StatefulWidget {
  @override
  _BusinessDirectoryPageState createState() => _BusinessDirectoryPageState();
}

class _BusinessDirectoryPageState extends State<BusinessDirectoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Position? _currentPosition;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  double _selectedDistance = 10.0; // in km
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Businesses'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BusinessSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _getBusinessesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading businesses'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No businesses found'));
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var business = snapshot.data!.docs[index];
                          return _buildBusinessCard(business);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search businesses...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: ['All', 'Food', 'Retail', 'Services', 'Art']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Distance: ${_selectedDistance.round()} km'),
                    Slider(
                      value: _selectedDistance,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      onChanged: (value) {
                        setState(() {
                          _selectedDistance = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider<NewsController>(
                    create: (context) => NewsController(),
                    child: NewsPage(),
                  ),
                ),
              );
            },
            child: Text('News'),
          )
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Stream<QuerySnapshot> _getBusinessesStream() {
    Query query = _firestore.collection('businesses');

    if (_searchQuery.isNotEmpty) {
      query = query.where('searchKeywords', arrayContains: _searchQuery);
    }

    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    if (_currentPosition != null) {
      // This would require GeoFirestore or similar for proper distance queries
      // Simplified for example purposes
      query = query.orderBy('name');
    }

    return query.snapshots();
  }

  Widget _buildBusinessCard(DocumentSnapshot business) {
    Map<String, dynamic> data = business.data() as Map<String, dynamic>;
    double distance = _currentPosition != null
        ? Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              data['location'].latitude,
              data['location'].longitude) /
            1000
        : 0.0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusinessDetailPage(businessId: business.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: data['imageUrl'] ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.store),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      data['category'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${distance.toStringAsFixed(1)} km away',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          data['rating']?.toStringAsFixed(1) ?? '0.0',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class BusinessSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('businesses')
          .where('searchKeywords', arrayContains: query.toLowerCase())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var business = snapshot.data!.docs[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  business['imageUrl'] ?? '',
                ),
              ),
              title: Text(business['name']),
              subtitle: Text(business['category']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessDetailPage(businessId: business.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class BusinessDetailPage extends StatelessWidget {
  final String businessId;

  const BusinessDetailPage({required this.businessId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('businesses').doc(businessId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Business not found'));
          }
          
          var business = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business details implementation would go here
                // (image, name, description, products, etc.)
              ],
            ),
          );
        },
      ),
    );
  }
}