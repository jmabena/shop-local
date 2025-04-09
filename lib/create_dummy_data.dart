import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seller_model.dart';
import '../models/product_model.dart';
import '../models/deals_model.dart';
import 'dart:math';

class DummyDataGenerator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  Future<void> generateDummyData() async {
    List<String> sellerIds = [];
    List<String> productIds = [];
    // sellerIds = await _firestore.collection('sellers').get().then((querySnapshot) {
    //   return querySnapshot.docs.map((doc) => doc.id).toList();
    // });
    // for (String sellerId in sellerIds) {
    //   productIds.addAll(await _firestore.collection('sellers').doc(sellerId).collection('products').get().then((querySnapshot)
    //   {
    //     return querySnapshot.docs.map((doc) => doc.id).toList();
    //   }));
    //   }


    // Generate Sellers
    for (int i = 0; i < 5; i++) {
      String sellerId = _firestore.collection('sellers').doc().id;
      sellerIds.add(sellerId);
      final sellerData = SellerModel(
        sellerId: '',
        logoUrl: 'https://source.unsplash.com/200x200/?store,logo&sig=$i',
        picUrl: 'https://source.unsplash.com/600x400/?store&sig=$i',
        organizationName: 'Store $i',
        organizationType: 'Retail',
        organizationDesc: 'A great store for products.',
        hasDeal: false,
        licenseNumber: '123456789$i',
      );
      await _firestore.collection('sellers').doc(sellerId).set(sellerData.toMap());
      // await _firestore.collection('sellers').doc(sellerId).set({
      //   'sellerId': sellerId,
      //   'logoUrl': 'https://source.unsplash.com/200x200/?store,logo&sig=$i',
      //   'picUrl': 'https://source.unsplash.com/600x400/?store&sig=$i',
      //   'organizationName': 'Store $i',
      //   'organizationType': 'Retail',
      //   'organizationDesc': 'A great store for products.',
      //   'hasDeal': false, // Initially false, updated later
      // });
    }

    // Generate Products
    for (String sellerId in sellerIds) {
      for (int j = 0; j < 5; j++) {
        String productId = _firestore.collection('sellers').doc(sellerId).collection('products').doc().id;
        productIds.add(productId);
        final productData = ProductModel(
          productId: '',
          productUrl: 'https://picsum.photos/200/300?random=${_random.nextInt(1000)}',
          productName: 'Product $j',
          productPrice: _random.nextInt(100) + 10.0, // Random price
          productDesc: 'This is product $j.',
          sellerId: sellerId,
          hasDeal: false, // Initially false, updated later
        );
        await _firestore.collection('sellers').doc(sellerId).collection('products').doc(productId).set(productData.toMap());

        // await _firestore.collection('products').doc(productId).set({
        //   'productId': productId,
        //   'productUrl': 'https://picsum.photos/200/300?random=${_random.nextInt(1000)}',
        //   'productName': 'Product $j',
        //   'productPrice': _random.nextInt(100) + 10.0, // Random price
        //   'productDesc': 'This is product $j.',
        //   'sellerId': sellerId,
        //   'hasDeal': false, // Initially false, updated later
        // });
      }
    }

    // Generate Deals (Some Storewide, Some Product-Specific)
    for (String sellerId in sellerIds) {
      bool hasStoreDeal = _random.nextBool();
      if (hasStoreDeal) {
        // Create a store-wide deal
        print('creating deal for seller $sellerId');
        SellerModel seller = SellerModel.fromMap((await _firestore.collection('sellers').doc(sellerId).get()).data() as Map<String, dynamic>, sellerId);

        var dealData = await _firestore.collection('deals').add({
          'title': '${seller.organizationName} Promotion!',
          'storeId': sellerId,
          'isStoreWide': true,
          'discountPercentage': _random.nextInt(20) + 5.0, // 5-25% off
          'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: _random.nextInt(10) + 5))),
          'storeName': seller.organizationName,
          'storeImage': seller.picUrl,

        });
        DocumentSnapshot dealSnapshot = await dealData.get();
        Deal deal = Deal.fromMap(dealSnapshot.data() as Map<String, dynamic>, dealSnapshot.id);

        await _firestore.collection('sellers').doc(sellerId).collection('deals').doc(dealData.id).set({
          'isStoreWide' : deal.isStoreWide,
          'expiryDate' : deal.expiryDate,
        });

        await _firestore.collection('sellers').doc(sellerId).update({'hasDeal': true});
      }

    }
    for (String sellerId in sellerIds) {
      bool hasProductDeal = _random.nextBool();
      if (hasProductDeal) {
        for(String productId in productIds){
          bool hasDeal = _random.nextBool();
          if(hasDeal){
            String? currentsellerId = (await _firestore.collection('sellers').doc(sellerId).get()).id;
            print('current seller id is $currentsellerId');
            if (currentsellerId != '') {
              if(currentsellerId == sellerId){
                DocumentSnapshot productSnapshot = await _firestore.collection('sellers').doc(sellerId).collection('products').doc(productId).get();
                print('product snapshot is $productSnapshot');
                if (productSnapshot.exists) {
                  ProductModel product = ProductModel.fromMap(productSnapshot.data() as Map<String, dynamic>, productSnapshot.id);
                  var dealData = await _firestore.collection('deals').add({
                    'title': '${product.productName} Discount!',
                    'storeId': sellerId,
                    'productId': productId,
                    'isStoreWide': false,
                    'discountPercentage': _random.nextInt(30) + 10.0, // 10-40% off
                    'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: _random.nextInt(10) + 3))),
                    'productImage': product.productUrl,
                  });
                  DocumentSnapshot dealSnapshot = await dealData.get();
                  Deal deal = Deal.fromMap(dealSnapshot.data() as Map<String, dynamic>, dealSnapshot.id);
                  await _firestore.collection('sellers').doc(sellerId).collection('deals').doc(dealData.id).set({
                    'isStoreWide' : deal.isStoreWide,
                    'expiryDate' : deal.expiryDate,
                  });
                  await _firestore.collection('sellers').doc(sellerId).update({'hasDeal': true});
                  await _firestore.collection('sellers').doc(sellerId).collection('products').doc(productId).update({'hasDeal': true});
                }

                //ProductModel product = ProductModel.fromMap(await _firestore.collection('sellers').doc(sellerId).collection('products').doc(productId).get());
                print('creating deal for product $productId');


              }
            }
          }
        }
      }
    }

    // Assign some product-specific deals
    // for (String productId in productIds.sublist(0, productIds.length ~/ 2)) {
    //
    //   String? sellerId = (await _firestore.collection('sellers').doc(seller).get()).data()?['sellerId'];
    //   if (sellerId != null) {
    //     await _firestore.collection('deals').add({
    //       'title': 'Limited Time Offer!',
    //       'storeId': sellerId,
    //       'productId': productId,
    //       'isStoreWide': false,
    //       'discountPercentage': _random.nextInt(30) + 10.0, // 10-40% off
    //       'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: _random.nextInt(10) + 3))),
    //     });
    //
    //     // Mark the product as having a deal
    //     await _firestore.collection('products').doc(productId).update({'hasDeal': true});
    //     await _firestore.collection('sellers').doc(sellerId).update({'hasDeal': true});
    //   }
    // }
  }
}
