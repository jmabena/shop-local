import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/cart_controller.dart';

class OrderPage extends StatefulWidget {

  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late CartController cartController;
  @override
  Widget build(BuildContext context) {
    cartController = Provider.of<CartController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Summary"),
        backgroundColor: Colors.white,
        elevation: 10,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded( // Wrap the ListView in Expanded to give it a bounded height
              child:
              StreamBuilder(
                stream: cartController.getCartEntries(),
                builder: (context, snapshot) {
                  final products = snapshot.data;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (snapshot.hasData && products != null) {
                    // Calculate total amount
                    final totalAmount = products.fold<double>(
                      0.0,
                          (sum, item) => sum + (item['product'].productPrice * item['count']),
                    );

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final item = products[index];
                              return ListTile(
                                title: Text(item['product'].productName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Price: \$${item['product'].productPrice}'),
                                    Text('Quantity: ${item['count']}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () async {
                                        await cartController.removeOneFromCart(item['product'].productId);
                                        setState(() {}); // Refresh UI
                                      },
                                    ),
                                    Text(
                                      '\$${(item['product'].productPrice * item['count']).toStringAsFixed(2)}',
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () async {
                                        await cartController.addToCart(item['product']);
                                        setState(() {}); // Refresh UI
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("\$${totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        SizedBox(height: 50),
                        buildPaymentMethod(),
                        SizedBox(height: 20),
                        buildConfirmButton(context, products),
                      ],
                    );
                  } else {
                    return const Center(child: Text("No items in cart."));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Credit Card **** 1234"),
              Icon(Icons.payment, color: Colors.black54),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildConfirmButton(BuildContext context, List products) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (products.isEmpty) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("No items in cart."),
                  content: Text(""),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("OK"),
                    ),
                  ],
                );
              },
            );
            return;
          }
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Order Confirmed"),
                content: Text("Thank you for your purchase!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      cartController.deleteAllCartEntries();
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
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
          "Confirm Order",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
