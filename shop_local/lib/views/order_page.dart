import 'package:flutter/material.dart';
import 'package:shop_local/model/product_model.dart';

import '../controller/user_controller.dart';

class OrderPage extends StatefulWidget {

  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final userController = UserController();
  @override
  Widget build(BuildContext context) {
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
              child: StreamBuilder(
                stream: userController.getCartEntries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        return ListTile(
                          title: Text(item['product'].productName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price: \$${item['product'].productPrice}'),
                              Text('Quantity: ${item['count']}'),
                            ],
                          ),
                          trailing: Text('\$${item['product'].productPrice * item['count']}'),
                        );
                      },
                    );
                  } else {
                    // If no items are in the cart, show a message.
                    return const Center(child: Text("No items in cart."));
                  }
                },
              ),
            ),
            SizedBox(height: 50),
            buildPaymentMethod(),
            SizedBox(height: 20),
            buildConfirmButton(context),
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

  Widget buildTotalAmount(Map<String, dynamic> item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("\$${item['product'].productPrice * item['count']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildConfirmButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Order Confirmed"),
                content: Text("Thank you for your purchase!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      userController.deleteAllCartEntries();
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

