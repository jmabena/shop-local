import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_local/view/network_image_builder.dart';

import '../controller/cart_controller.dart';
import '../controller/deals_controller.dart';
import '../controller/user_controller.dart';
import '../models/deals_model.dart';
import '../models/product_model.dart';
import 'create_deal_page.dart';
import 'order_page.dart';

class ProductPage extends StatefulWidget {
  final ProductModel productData;
  final Deal? deal;
  const ProductPage({super.key, required this.productData, this.deal});

  @override
  State<ProductPage> createState() => _ProductPageState();

}

class _ProductPageState extends State<ProductPage> {
   final CartController cartController = CartController();


   @override
   void initState() {
     super.initState();
   }

  @override
  Widget build(BuildContext context) {
     final firebaserUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage()));
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: ListView(
          children: [
            buildProductImage(widget.productData),
            SizedBox(height: 10),
            buildDescriptionBox(widget.productData),
            SizedBox(height: 10),
            //buildSection("Frequently bought together"),
            //buildFrequentlyBoughtGrid(),
            SizedBox(height: 20),
            firebaserUser?.uid == widget.productData.sellerId ? buildCreateDealButton() : buildOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget buildProductImage(ProductModel product) {
    return NetworkImageWithFallback(
      imageUrl: product.productUrl,
      fallbackAsset: 'assets/images/fruits.jpg',
      builder: (imageProvider) =>
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
            height: 200,
            width: 100,
            child: Center(
              child: Text(
                product.productName,
                style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
    );

  }

  Widget buildDescriptionBox(ProductModel product) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(product.productDesc),
    );

  }

  Widget buildSection(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildFrequentlyBoughtGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/fruits.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 100,
                width: 100,
              ),
              SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Item name", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Price"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildOrderButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          try {
            final currentUser = FirebaseAuth.instance.currentUser;
            String sellerId = widget.productData.sellerId;
            if (currentUser == null) {
              // Handle user not logged in
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("You must be logged in to place an order.")),
              );
              return;
            }

            if (currentUser.uid == sellerId) {
              // Show error if the user is the seller
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Sellers cannot purchase their own products.")),
              );
              return;
            }
            // Call the controller method to add the product to the cart.
            double finalPrice = widget.productData.productPrice;
            if (widget.deal != null && widget.deal?.discountPercentage != null) {
              double? discount;
              widget.deal?.discountPercentage != null ? discount = widget.deal?.discountPercentage : 0;
              if (discount != null) {
                finalPrice = widget.productData.productPrice - (widget.productData.productPrice * (discount / 100));
              }
            }
            ProductModel product = ProductModel(
              productId: widget.productData.productId,
              productUrl: widget.productData.productUrl,
              productName: widget.productData.productName,
              productPrice: finalPrice,
              productDesc: widget.productData.productDesc,
              sellerId: widget.productData.sellerId,
              hasDeal: widget.productData.hasDeal,

            );
            await cartController.addToCart(product);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Product added to cart successfully!"), duration: Duration(seconds: 1)),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error adding to cart: $e")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          "Place Order",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
  buildCreateDealButton(){
     return Center(
       child: ElevatedButton(
         onPressed: () async {
           try {
             await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateDealPage(product: widget.productData,sellerId: widget.productData.sellerId)));
             Navigator.pop(context);
           }catch(e){
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text("Error creating deal: $e")),
             );
           }
         },
         style: ElevatedButton.styleFrom(
           backgroundColor: Colors.black,
           padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(30),
           ),
         ),
         child: Text(
           "Create Deal",
           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
         ),

       )
     );
  }
}
