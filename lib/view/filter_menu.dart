import 'package:flutter/material.dart';
import '../models/categories_model.dart';

class FilterMenu extends StatelessWidget {
  final Function(int, String) onItemSelected;
  final int selectedIndex;
  final List<CategoryModel> categories;

  const FilterMenu({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    // The total number of items is the categories count plus one for "All"
    final totalItems = categories.length + 1;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white54,
        border: Border.all(width: 1, color: Colors.black),
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(totalItems, (index) {
          // If index is 0, we display the "All" option. Otherwise, display the category name.
          final String title = index == 0 ? "All" : categories[index - 1].name;
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onItemSelected(index, title),
            child: Container(
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              margin:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                title,
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