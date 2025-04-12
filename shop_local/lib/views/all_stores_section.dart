import 'package:flutter/material.dart';
import 'package:shop_local/views/seller_page.dart';
import '../models/seller_model.dart';
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
                    builder: (context) => SellerPage(sellerData: sellerData,)));
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
            fallbackAsset: 'assets/fruits.jpg',
            builder: (imageProvider) =>
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 180,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: NetworkImageWithFallback(
                      imageUrl: data.logoUrl,
                      fallbackWidget: const Icon(Icons.logo_dev),
                      builder: (imageProvider) =>
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: imageProvider,
                          ),
                    )
                ),
              ),
              // Wrap the Column in Expanded so that it knows its width constraints
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.organizationName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data.organizationDesc,
                        style: const TextStyle(color: Colors.grey),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}