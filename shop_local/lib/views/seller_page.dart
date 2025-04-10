import 'package:flutter/material.dart';
import 'package:shop_local/controller/cart_controller.dart';
import 'package:shop_local/views/network_image_builder.dart';
import 'package:shop_local/views/product_page.dart';
import '../controller/deals_controller.dart';
import '../controller/seller_controller.dart';
import '../controller/user_controller.dart';
import '../model/deals_model.dart';
import '../model/product_model.dart';
import '../model/seller_model.dart';
import 'cart_icon_widget.dart';

class SellerPage extends StatefulWidget {
  final SellerModel sellerData;
  const SellerPage({super.key, required this.sellerData});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final  _searchController = TextEditingController();
  final userController = UserController();
  final dealsController = DealsController();
  final sellerController = SellerController();
  String _query = '';
  List<Deal>? _productDeals;
  List<Deal>? _storeDeals;
  bool _isLoadingDeals = false;



  @override
  void initState() {
    super.initState();
    // Listen for changes in the search field and update the query.
    _getDeals();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }
  Future<void> _getDeals() async {
    setState(() {
      _isLoadingDeals = true;
    });
    _productDeals = await dealsController.getProductDeals(widget.sellerData.sellerId);
    _storeDeals = await dealsController.getStoreDeals(widget.sellerData.sellerId);
    setState(() {
      _isLoadingDeals = false;

    });
  }

  bool isProductInDeals(ProductModel product) {
    if (_productDeals == null) return false;
    return _productDeals!.any((deal) => deal.productId == product.productId);
  }

  Deal getDealForProduct(ProductModel product) {
    if (_productDeals == null) throw Exception('Deals not loaded');
    return _productDeals!.firstWhere((deal) => deal.productId == product.productId);
  }

  // Filters products based on the query.
  List<ProductModel> _filterProducts (List<ProductModel> products) {
    if (_query.isEmpty) return products;
    return products.where((product) {
      final productName = product.productName.toLowerCase().contains(_query.toLowerCase());
      return productName;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        actions: [
          CartIconWithBadge(cartController: CartController(),),
        ],
      ),
      body: Expanded(
        child: Padding(
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
              // Display store deals if available
              if (_storeDeals != null && _storeDeals!.isNotEmpty)
                Center(child: Text(_storeDeals!.first.condition!,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: Colors.grey),),),

              SizedBox(height: 10),
              // Display product deals if available
              StreamBuilder(
                stream: sellerController.getSellerProducts(widget.sellerData.sellerId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if(_isLoadingDeals){
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    final productInfo = snapshot.data!;
                    // Filter products based on the search query
                    final filteredProducts = _filterProducts(productInfo);
                    return _buildProductInfoSection(filteredProducts);
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
            Deal? deal = isProductInDeals(product) ? getDealForProduct(product) : null;
            double finalPrice = product.productPrice;
            if (deal != null && deal.discountPercentage != null) {
              finalPrice = product.productPrice - (product.productPrice * (deal.discountPercentage! / 100));

            }
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ProductPage(productData: product,deal: deal)));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImageWithFallback(imageUrl: product.productUrl!, fallbackAsset: 'assets/bg.jpg'),
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
                      isProductInDeals(product) ? RichText(
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImageWithFallback(imageUrl: widget.sellerData.picUrl, fallbackAsset: 'assets/images/bg.jpg'),
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