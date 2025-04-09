import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/deals_controller.dart';
import '../models/deals_model.dart';
import 'network_image_builder.dart';

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DealsController>().fetchAllDeals();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Deals & Promotions')),
      body: Consumer<DealsController>(
        builder: (context, dealsController, child) {
          return buildDealsList(dealsController);
        },
      ),
    );
  }
  Widget buildDealsList(DealsController dealsController) {
    if (dealsController.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    final dealsList = dealsController.deals;
    if (dealsList.isEmpty) {
      return Center(child: Text('No deals available'));
    }
    return ListView.builder(
      itemCount: dealsList.length,
      itemBuilder: (context, index) {
        final deal = dealsList[index];
        return ListTile(
          leading:
          deal.isStoreWide
              ? Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImageWithFallback(
                  imageUrl: deal.storeImage,
                  fallbackAsset: 'assets/images/fruits.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          )
              : Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImageWithFallback(
                  imageUrl: deal.productImage!,
                  fallbackAsset: 'assets/images/fruits.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(deal.title),
          subtitle:
          deal.isStoreWide
              ? Text('Store-wide deal at ${deal.storeName}')
              : Text('${deal.discountPercentage}% off!'),
          onTap: () {
            if (deal.isStoreWide) {
              // Navigate to Store Page
            } else {
              // Navigate to Product Details/add to cart
            }
          },
        );
      },
    );
  }
}
