import 'package:flutter/material.dart';
import '../controller/deals_controller.dart';
import '../models/deals_model.dart';

class CreateDealPage extends StatefulWidget {
  @override
  _CreateDealPageState createState() => _CreateDealPageState();
}

class _CreateDealPageState extends State<CreateDealPage> {
  final DealsController _dealsController = DealsController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  DateTime _expiryDate = DateTime.now();
  bool _isStoreWide = false;
  String? _selectedProductId;
  String? _storeName = "Sample Store";
  String? _storeImage = "https://example.com/logo.png";

  void _submitDeal() {
    Deal deal = Deal(
      id: '',
      title: _titleController.text,
      storeName: _isStoreWide ? _storeName : null,
      storeImage: _isStoreWide ? _storeImage : null,
      productId: _isStoreWide ? null : _selectedProductId,
      discountPercentage: _isStoreWide ? null : double.tryParse(_discountController.text),
      condition: _isStoreWide ? _conditionController.text : null,
      isStoreWide: _isStoreWide,
      expiryDate: _expiryDate,
    );

    _dealsController.addDeal(deal).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deal Created!')));
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Deal")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: "Deal Title")),
            SwitchListTile(
              title: Text("Is Store-Wide Deal?"),
              value: _isStoreWide,
              onChanged: (value) => setState(() => _isStoreWide = value),
            ),
            if (!_isStoreWide)
              TextField(controller: _discountController, decoration: InputDecoration(labelText: "Discount (%)")),
            if (_isStoreWide)
              TextField(controller: _conditionController, decoration: InputDecoration(labelText: "Condition (e.g., Spend \$50)")),
            ElevatedButton(
              onPressed: _submitDeal,
              child: Text("Create Deal"),
            ),
          ],
        ),
      ),
    );
  }
}
