import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_local/view/product_page.dart';
import 'package:shop_local/view/seller_page.dart';
import '../controller/deals_controller.dart';
import '../controller/seller_controller.dart';
import '../model/deals_model.dart';
import '../model/product_model.dart';
import '../model/seller_model.dart';
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

    //context.read<DealsController>().fetchAllDeals();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      context.read<DealsController>().fetchAllDeals();
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<DealsController>().fetchAllDeals();
  }
  @override
  void dispose() {
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Deals & Promotions')),
      body: Consumer<DealsController>(
        builder: (context, dealsController, child) {
          ;
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
          leading: NetworkImageWithFallback(
            imageUrl: deal.isStoreWide ? deal.storeImage : deal.productImage,
            fallbackAsset: 'assets/images/fruits.jpg',
            builder: (imageProvider) => Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: deal.isStoreWide ? BoxShape.circle : BoxShape.rectangle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          title: Text(deal.title),
          subtitle:
          deal.isStoreWide
              ? Text('Store-wide deal at ${deal.storeName}')
              : Text('${deal.discountPercentage}% off!'),
          onTap: () async {
            if (deal.isStoreWide) {

              // Navigate to Store Page
              final sellerStream = context.read<SellerController>().getSellerInfo(deal.storeId);
              sellerStream.first.then((sellerData) async {

                final result = await Navigator.push(context, MaterialPageRoute(
                  builder: (context) => SellerPage(sellerData: sellerData),

                ));
                if (result == true && mounted) {
                  context.read<DealsController>().fetchAllDeals();
                }
                setState(() {

                  context.read<DealsController>().fetchAllDeals();
                });
              });

            } else {
              // Navigate to Product Details/add to cart

              final product = await context.read<SellerController>().getSellerProduct(deal.storeId, deal.productId);

              await Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProductPage(productData: product,deal: deal)));

            }
          },
        );
      },
    );
  }
}
