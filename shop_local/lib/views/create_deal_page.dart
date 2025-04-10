import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_local/controller/seller_controller.dart';
import 'package:shop_local/models/seller_model.dart';
import '../controller/deals_controller.dart';
import '../models/deals_model.dart';
import '../models/product_model.dart';
import 'package:intl/intl.dart';

class CreateDealPage extends StatefulWidget {
  final ProductModel product;
  const CreateDealPage({super.key, required this.product});

  @override
  _CreateDealPageState createState() => _CreateDealPageState();
}

class _CreateDealPageState extends State<CreateDealPage> {
  final SellerController _sellerController = SellerController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  DateTime _expiryDate = DateTime.now();
  bool _isStoreWide = false;
  SellerModel? seller;
  String? _storeName;
  String? _storeImage;

  @override
  void initState() {
    super.initState();
    _getSellerInfo();
  }

  void _getSellerInfo() async {
    seller = await _sellerController.getSellerInfoOnce(widget.product.sellerId);
    if (seller != null) {
      setState(() {
        _storeName = seller!.organizationName;
        _storeImage = seller!.picUrl;
      });
    }
  }
  void _submitDeal() {
    Deal deal = Deal(
      id: '',
      title: _titleController.text,
      storeName: _isStoreWide ? _storeName : null,
      storeImage: _isStoreWide ? _storeImage : null,
      productImage: _isStoreWide ? null : widget.product.productUrl,
      productId: _isStoreWide ? null : widget.product.productId,
      discountPercentage: _isStoreWide ? null : double.tryParse(_discountController.text),
      condition: _isStoreWide ? _conditionController.text : null,
      isStoreWide: _isStoreWide,
      storeId: widget.product.sellerId,
      expiryDate: _expiryDate,
    );

    context.read<DealsController>().addDeal(deal,widget.product.productId,widget.product.sellerId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deal Created!')));
      Navigator.pop(context);
    });
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _expiryDate) {
      setState(() {
        _expiryDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _expiryDate.hour,
          _expiryDate.minute,
        );
      });
    }
  }
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expiryDate),
    );
    if (pickedTime != null) {
      setState(() {
        _expiryDate = DateTime(
          _expiryDate.year,
          _expiryDate.month,
          _expiryDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
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
            ListTile(
              title: Text('Expiry Date & Time'),
              subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(_expiryDate)),
              onTap: () async {
                await _selectDate(context);
                await _selectTime(context);
              },
            ),
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