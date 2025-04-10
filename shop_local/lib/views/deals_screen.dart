import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_local/controller/seller_controller.dart';
import 'package:shop_local/views/seller_page.dart';
import '../controller/deals_controller.dart';
import '../model/deals_model.dart';
import '../model/seller_model.dart';
import 'network_image_builder.dart';

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  SellerModel? seller;
  final SellerController _sellerController = SellerController();


  void _getSellerInfo(Deal deal) async {
    seller = await _sellerController.getSellerInfoOnce(deal.storeId!);
  }

  @override
  Widget build(BuildContext context) {
    final dealsController = Provider.of<DealsController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Deals & Promotions')),
      body: StreamBuilder<List<Deal>>(
        stream: dealsController.fetchDeals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No deals available.'));
          }

          final dealsList = snapshot.data!;
          return ListView.builder(
            itemCount: dealsList.length,
            itemBuilder: (context, index) {
              final deal = dealsList[index];
              return buildDealCard(context, deal);
            },
          );
        },
      ),
    );
  }

  Widget buildDealCard(BuildContext context, Deal deal) {
    _getSellerInfo(deal);
    return ListTile(
      leading: deal.isStoreWide
          ? Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImageWithFallback(imageUrl: deal.storeImage, fallbackAsset: 'assets/images/fruits.jpg'),
              fit: BoxFit.cover,
            ),
          )
      )
          : Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImageWithFallback(imageUrl: deal.productImage!, fallbackAsset: 'assets/images/fruits.jpg'),
              fit: BoxFit.cover,
            )
          )
      ),
      title: Text(deal.title),
      subtitle: deal.isStoreWide
          ? Text('Store-wide deal at ${deal.storeName}')
          : Text('${deal.discountPercentage}% off!'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerPage(sellerData: seller!),
          ),
        );
      },
    );
  }
}