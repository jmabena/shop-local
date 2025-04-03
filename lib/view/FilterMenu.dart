import 'package:flutter/material.dart';

class FilterMenu extends StatelessWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;
  final List<String> items;

  const FilterMenu({super.key, required this.onItemSelected, required this.selectedIndex, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white54,
        border: Border.all(width: 1 , color: Colors.black),
        borderRadius: BorderRadius.circular(15)
      ),
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onItemSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10 , horizontal: 0),
              child: Text(
                items[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.blue, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
