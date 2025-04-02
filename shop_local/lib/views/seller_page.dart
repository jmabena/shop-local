import 'package:flutter/material.dart';
import 'package:shop_local/model/seller_model.dart';
import 'package:shop_local/views/product_page.dart';
import '../controller/user_controller.dart';
import '../model/product_model.dart';
import 'order_page.dart';

class SellerPage extends StatefulWidget {
  final SellerModel sellerData;
  const SellerPage({super.key, required this.sellerData});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final  _searchController = TextEditingController();
  final userController = UserController();
  String _query = '';


  @override
  void initState() {
    super.initState();
    // Listen for changes in the search field and update the query.
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
            buildHeader(context),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(widget.sellerData.organizationDesc,
                style: TextStyle(fontSize: 16),),
            ),
            SizedBox(height: 10),
            StreamBuilder(
              stream: userController.getSellerProducts(widget.sellerData.sellerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final productInfo = snapshot.data!;
                  return _buildProductInfoSection(productInfo);
                } else {
                  // If no products are found, show a message.
                  return Center(
                    child: Text('This seller has no products yet.'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoSection(List<ProductModel> productInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSection("Products"),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: productInfo.length,
          itemBuilder: (context, index) {
            final product = productInfo[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ProductPage(productData: product,)));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/berries.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 100,
                    width: 100,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text('${product.productPrice}', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(product.productName),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  Widget buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage('assets/fruits.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.sellerData.organizationName,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search',
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                        icon: Icon(Icons.clear)
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
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
}
