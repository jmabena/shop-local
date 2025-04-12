import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_local/views/network_image_builder.dart';
import 'package:shop_local/views/product_page.dart';
import '../controller/deals_controller.dart';
import '../controller/seller_controller.dart';
import '../models/deals_model.dart';
import '../models/product_model.dart';
import '../models/seller_model.dart';
import 'cart_icon_widget.dart';
import 'chat_screen.dart';

class SellerPage extends StatefulWidget {
  final SellerModel sellerData;
  const SellerPage({super.key, required this.sellerData});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final  _searchController = TextEditingController();
  String _query = '';
  final currentUser = FirebaseAuth.instance.currentUser;
  // List<Deal>? _deals;
  //bool _isLoadingDeals = false;



  @override
  void initState() {
    super.initState();
    // Listen for changes in the search field and update the query.
    //_getDeals();
    context.read<DealsController>().fetchStoreDeals(widget.sellerData.sellerId);
    context.read<SellerController>().fetchSellerProducts(widget.sellerData.sellerId);
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<DealsController>().fetchStoreDeals(widget.sellerData.sellerId);
    context.read<SellerController>().fetchSellerProducts(widget.sellerData.sellerId);
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filterProducts (List<ProductModel> products) {
    if (_query.isEmpty) return products;
    return products.where((product) {
      final productName = product.productName.toLowerCase().contains(_query.toLowerCase());
      return productName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        actions: [
          CartIconWithBadge(),
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
            Consumer2<DealsController, SellerController>(
                builder: (context, dealsController, sellerController, child) {
                  if (dealsController.isLoading || sellerController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if(sellerController.products.isEmpty){
                    return const Center(child: Text("No products found"));
                  }
                  List<ProductModel> productInfo = sellerController.products;
                  if (_query.isNotEmpty) {
                    productInfo = _filterProducts(productInfo);
                  }
                  return _buildProductInfoSection(productInfo,dealsController.deals);
                }
            ),
          ],
        ),
      ),
      floatingActionButton: currentUser!.uid != widget.sellerData.sellerId ? FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => ChatScreen(peer: widget.sellerData)));
        },
        child: Icon(Icons.chat_bubble),
      ) : null,
    );
  }

  Widget _buildProductInfoSection(List<ProductModel> productInfo, List<Deal> deals) {
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
            Deal? deal = deals.any((deal) => deal.productId == product.productId) ? deals.firstWhere((deal) => deal.productId == product.productId) : null;
            double finalPrice = product.productPrice;
            if (deal != null && deal.discountPercentage != null) {
              finalPrice = product.productPrice - (product.productPrice * (deal.discountPercentage! / 100));

            }
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ProductPage(productData: product,deal: deal)));
                setState(() {});
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetworkImageWithFallback(
                    imageUrl: product.productUrl,
                    fallbackAsset: 'assets/fruits.jpg',
                    builder: (imageProvider) =>
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          height: 100,
                          width: 100,
                        ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      deals.any((deal) => deal.productId == product.productId) ?RichText(
                        text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: '${product.productPrice}', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
                              ),
                              TextSpan(text: '  '),
                              TextSpan(
                                text: '$finalPrice', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ]
                        ),
                      ) :
                      Text('${product.productPrice}', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(product.productName,overflow: TextOverflow.ellipsis,),
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
        NetworkImageWithFallback(
          imageUrl: widget.sellerData.picUrl,
          fallbackAsset: 'assets/bg.jpg',
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
        )
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