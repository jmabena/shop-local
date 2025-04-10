import 'package:flutter/material.dart';
import '../controller/cart_controller.dart';
import 'order_page.dart';

class CartIconWithBadge extends StatelessWidget {
  final CartController cartController;

  const CartIconWithBadge({super.key, required this.cartController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: cartController.getCartItemCount(),
      builder: (context, snapshot) {
        final itemCount = snapshot.data ?? 0;

        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPage()),
                );
              },
            ),
            if (itemCount > 0)
              Positioned(
                right: 1,
                top: 1,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
