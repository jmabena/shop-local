import 'package:flutter/material.dart';
import 'package:shop_local/views/order_page.dart';

class ProductPage extends StatefulWidget {
  final String productName;
  const ProductPage({super.key, required this.productName});

  @override
  State<ProductPage> createState() => _ProductPageState();

}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: ListView(
          children: [
            buildProductImage(widget.productName),
            SizedBox(height: 10),
            buildDescriptionBox(widget.productName),
            SizedBox(height: 10),
            buildSection("Frequently bought together"),
            buildFrequentlyBoughtGrid(),
            SizedBox(height: 20),
            buildOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget buildProductImage(String productName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage('assets/$productName.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      height: 200,
      width: 100,
    );
  }

  Widget buildDescriptionBox(String productName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text("$productName, nature's little bursts of joy, bring a symphony of flavours to your palate. With their bright red hue and luscious texture, they offer a refreshing and delightful treat"),
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
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderPage())
          );
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
}
