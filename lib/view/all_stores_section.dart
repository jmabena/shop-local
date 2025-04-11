import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_local/view/seller_page.dart';

import '../controller/deals_controller.dart';
import '../controller/seller_controller.dart';
import '../model/seller_model.dart';
import 'network_image_builder.dart';

class AllStoresSection extends StatelessWidget {
  final List<SellerModel> seller;

  const AllStoresSection({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "All Stores", // Fixed typo from "Stories" to "Stores"
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: seller.length,
          itemBuilder: (context, index) {
            var sellerData = seller[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SellerPage(sellerData: sellerData),

                ));
              },
              child: _buildStoreItem(sellerData),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStoreItem(SellerModel data) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NetworkImageWithFallback(
              imageUrl: data.picUrl,
              fallbackAsset: 'assets/images/fruits.jpg',
              builder: (imageProvider) =>
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  data.organizationName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                 Text(
                  data.organizationDesc,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}