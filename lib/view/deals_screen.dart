import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/deals_controller.dart';
import '../models/deals_model.dart';

class DealsPage extends StatelessWidget {
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
              return ListTile(
                leading: deal.isStoreWide
                    ? Image.network(deal.storeImage!, width: 50, height: 50, fit: BoxFit.cover)
                    : Image.network(deal.productImage!, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(deal.title),
                subtitle: deal.isStoreWide
                    ? Text('Store-wide deal at ${deal.storeName}')
                    : Text('${deal.discountPercentage}% off!'),
                onTap: () {
                  if (deal.isStoreWide) {
                    // Navigate to Store Page
                  } else {
                    // Navigate to Product Details
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
