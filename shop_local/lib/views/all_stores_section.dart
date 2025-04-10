import 'package:flutter/material.dart';
import 'package:shop_local/model/seller_model.dart';
import 'package:shop_local/views/seller_page.dart';

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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              data.picUrl, // Placeholder image
              height: 180, // Fixed image height
              fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(data.logoUrl),
                ),
              ),
              // Wrap the Column in Expanded so that it knows its width constraints
              Expanded(
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