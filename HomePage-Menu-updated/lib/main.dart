import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop_local/controller/Authetication_Phase.dart';
// import '../view/login_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //final firestore = FirebaseFirestore.instance;

  // await seedCategories(firestore);
  // await seedStories(firestore);
  // await seedTopRates(firestore);
  runApp(const ShopLocalApp());
}
class ShopLocalApp extends StatelessWidget {
  const ShopLocalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopLocalApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      home: const AuthGate(),
    );
  }
}

//        SEED DATA


// Add Categories DATA
Future<void> seedCategories(FirebaseFirestore firestore) async {
  final categories = [
    {'id': '1005', 'name': 'Food', 'createdAt': Timestamp.now()},
    {'id': '1006', 'name': 'Clothing', 'createdAt': Timestamp.now()},
    {'id': '1007', 'name': 'School Supplies', 'createdAt': Timestamp.now()},
    {'id': '1008', 'name': 'Tools', 'createdAt': Timestamp.now()},
  ];

  for (var category in categories) {
    await firestore.collection('categories').doc(category['id'] as String?).set(category);
  }
}

// Add Stores Data
Future<void> seedStories(FirebaseFirestore firestore) async {
  final stories = [
    {
      'id': '250031',
      'imageUrl': "https://firebasestorage.googleapis.com/v0/b/shoplocal-e4903.firebasestorage.app/o/images%2Fstories%2Fstories01.png?alt=media&token=503981d5-5329-46e3-9e1f-d75f75fd24e2",
      'categoryId': '1008',
      'createdAt': Timestamp.now(),
    },
    {
      'id': '250032',
      'imageUrl': "https://firebasestorage.googleapis.com/v0/b/shoplocal-e4903.firebasestorage.app/o/images%2Fstories%2Fstories02.png?alt=media&token=dce4bbc1-205d-4cc8-8e8d-c45803360b07",
      'categoryId': '1006',
      'createdAt': Timestamp.now(),
    },
    {
      'id': '250033',
      'imageUrl': "https://firebasestorage.googleapis.com/v0/b/shoplocal-e4903.firebasestorage.app/o/images%2Fstories%2FStores03.jpg?alt=media&token=027365c7-4eab-4fb1-b05a-5785595458b8",
      'categoryId': '1007',
      'createdAt': Timestamp.now(),
    },
    {
      'id': '250034',
      'imageUrl': "https://firebasestorage.googleapis.com/v0/b/shoplocal-e4903.firebasestorage.app/o/images%2Fstories%2FStores04.jpg?alt=media&token=eedb537b-5f7c-4c48-9cf4-5e3392755fa3",
      'categoryId': '1007',
      'createdAt': Timestamp.now(),
    },
    {
      'id': '250035',
      'imageUrl': "https://firebasestorage.googleapis.com/v0/b/shoplocal-e4903.firebasestorage.app/o/images%2Fstories%2Ffood01.jpg?alt=media&token=b5b1333c-1ce5-426e-9851-aa7735723842",
      'categoryId': '1005',
      'createdAt': Timestamp.now(),
    },
    {
      'id': '250036',
      'imageUrl': "https://firebasestorage.googleapis.com/v0/b/shoplocal-e4903.firebasestorage.app/o/images%2Fstories%2Ffood02.jpg?alt=media&token=43896186-446a-410c-9a97-78feb9ba3f44",
      'categoryId': '1005',
      'createdAt': Timestamp.now(),
    },
  ];

  for (var story in stories) {
    await firestore.collection('stories').doc(story['id'] as String?).set(story);
  }
}

// Add TopRate DATA
Future<void> seedTopRates(FirebaseFirestore firestore) async {
  final topRates = [
    {
      'id': '200252',
      'imageUrl': "https://firebasestorage.googleapis.com/v0/b/shoplocal-e4903.firebasestorage.app/o/images%2FtopRates%2Fone.png?alt=media&token=09ab7297-9b7e-4cb2-9c8c-9225bfe00ea0",
      'createdAt': Timestamp.now(),
    },
    {
      'id': '200253',
      'imageUrl': "https://firebasestorage.googleapis.com/v0/b/shoplocal-e4903.firebasestorage.app/o/images%2FtopRates%2FTwo.png?alt=media&token=446fc68b-aa7e-4f97-9471-5d5b1fae9361",
      'createdAt': Timestamp.now(),
    },
    {
      'id': '200254',
      'imageUrl': "https://firebasestorage.googleapis.com/v0/b/shoplocal-e4903.firebasestorage.app/o/images%2FtopRates%2FtopRates03.jpg?alt=media&token=9ffb869c-1e54-4d57-b9e9-ec7e217415df",
      'createdAt': Timestamp.now(),
    },
    {
      'id': '200255',
      'imageUrl': "https://firebasestorage.googleapis.com/v0/b/shoplocal-e4903.firebasestorage.app/o/images%2FtopRates%2FtopRates04.jpg?alt=media&token=7c58d154-3bcd-4b8d-b5c2-a53cc8b02fbd",
      'createdAt': Timestamp.now(),
    },
  ];

  for (var topRate in topRates) {
    await firestore.collection('topRates').doc(topRate['id'] as String?).set(topRate);
  }
}
