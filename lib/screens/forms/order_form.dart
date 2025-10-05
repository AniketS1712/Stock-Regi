import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/enum/unit_type.dart';
import 'package:stock_register/models/orders_model.dart';
import 'package:stock_register/models/stock_model.dart';
import 'package:stock_register/providers/order_provider.dart';
import 'package:stock_register/providers/stock_provider.dart';
import 'package:stock_register/utils/date_picker_util.dart';
import 'package:stock_register/widgets/form/form_label.dart';
import 'package:stock_register/widgets/form/form_text_field.dart';
import 'package:stock_register/widgets/form/submit_button.dart';
import 'package:stock_register/widgets/glass_card.dart';

class OrdersForm extends StatefulWidget {
  final OrdersModel? order;
  final Function(OrdersModel)? onSubmit;

  const OrdersForm({super.key, this.order, this.onSubmit});

  @override
  State<OrdersForm> createState() => _OrdersFormState();
}

class _OrdersFormState extends State<OrdersForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _buyerNameController;
  late TextEditingController _quantityController;
  DateTime _selectedDate = DateTime.now();
  UnitType _selectedUnit = UnitType.kg;

  // Cascading stock selection
  StockModel? _selectedStockName;
  String? _selectedColor;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    _buyerNameController = TextEditingController(
      text: widget.order?.buyerName ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.order?.quantity.toString() ?? '',
    );
    _selectedDate = widget.order?.orderDate ?? DateTime.now();
    _selectedUnit = widget.order?.unit ?? UnitType.kg;

    if (widget.order != null) {
      final stockProvider = context.read<StockProvider>();
      _selectedStockName = stockProvider.currentStock.firstWhere(
        (s) => s.name == widget.order!.stockName,
        orElse: () => StockModel(
          id: '',
          name: widget.order!.stockName,
          color: '',
          size: '',
          quantity: 0,
        ),
      );

      _selectedColor = widget.order!.stockColor;
      _selectedSize = widget.order!.stockSize;
    }
  }

  @override
  void dispose() {
    _buyerNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await DatePickerUtil.pickDate(
      context: context,
      initialDate: _selectedDate,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStockName == null ||
        _selectedColor == null ||
        _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select complete stock details')),
      );
      return;
    }

    final ordersProvider = context.read<OrdersProvider>();
    final quantity =
        double.tryParse(_quantityController.text.trim()) ?? double.nan;

    if (quantity.isNaN || quantity <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid quantity')));
      return;
    }

    // Find the stock ID for selected combination
    final stockProvider = context.read<StockProvider>();
    final matchedStock = stockProvider.currentStock.firstWhere(
      (s) =>
          s.name == _selectedStockName!.name &&
          s.color == _selectedColor &&
          s.size == _selectedSize,
      orElse: () => StockModel(
        id: '',
        name: _selectedStockName!.name,
        color: _selectedColor!,
        size: _selectedSize!,
        quantity: 0,
      ),
    );

    final order = OrdersModel(
      id: widget.order?.id ?? '',
      buyerName: _buyerNameController.text.trim(),
      orderDate: _selectedDate,
      quantity: quantity,
      unit: _selectedUnit,
      stockName: _selectedStockName!.name,
      stockId: matchedStock.id,
      stockColor: _selectedColor!,
      stockSize: _selectedSize!,
    );

    try {
      if (widget.order == null) {
        await ordersProvider.addOrder(order);
      }

      widget.onSubmit?.call(order);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Order submit error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  List<String> getAvailableColors(List<StockModel> stocks) {
    if (_selectedStockName == null) return [];
    return stocks
        .where((s) => s.name == _selectedStockName!.name)
        .map((s) => s.color)
        .toSet()
        .toList();
  }

  List<String> getAvailableSizes(List<StockModel> stocks) {
    if (_selectedStockName == null || _selectedColor == null) return [];
    return stocks
        .where(
          (s) =>
              s.name == _selectedStockName!.name && s.color == _selectedColor,
        )
        .map((s) => s.size)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();
    final stockItems = stockProvider.currentStock;
    final dateFormatter = DateFormat.yMMMd();

    final availableColors = getAvailableColors(stockItems);
    final availableSizes = getAvailableSizes(stockItems);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: white.withAlpha(190),
        elevation: 2,
        title: Text(
          widget.order == null ? 'Add Order' : 'Edit Order',
          style: const TextStyle(color: deepBrown, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: night),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cream.withAlpha(230),
                      whisteria.withAlpha(200),
                      cream.withAlpha(230),
                    ],
                    stops: const [0.05, 0.7, 0.9],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 128, 8, 32),
              child: GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Buyer Name
                      const FormLabel('Buyer Name'),
                      FormTextField(
                        controller: _buyerNameController,
                        hint: 'e.g., John Doe',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter buyer name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Order Date
                      const FormLabel('Order Date'),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: white.withAlpha(80),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Text(
                            dateFormatter.format(_selectedDate),
                            style: const TextStyle(color: night),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stock Name
                      const FormLabel('Stock Name'),
                      DropdownButtonFormField<StockModel>(
                        value: _selectedStockName,
                        items: stockItems
                            .map((s) => s.name)
                            .toSet()
                            .map(
                              (name) => DropdownMenuItem<StockModel>(
                                value: stockItems.firstWhere(
                                  (s) => s.name == name,
                                ),
                                child: Text(name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedStockName = val;
                            _selectedColor = null;
                            _selectedSize = null;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: white.withAlpha(80),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            v == null ? 'Select stock name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Stock Color
                      const FormLabel('Stock Color'),
                      DropdownButtonFormField<String>(
                        value: _selectedColor,
                        items: availableColors
                            .map(
                              (color) => DropdownMenuItem(
                                value: color,
                                child: Text(color),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedColor = val;
                            _selectedSize = null;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: white.withAlpha(80),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            v == null ? 'Select stock color' : null,
                      ),
                      const SizedBox(height: 16),

                      // Stock Size
                      const FormLabel('Stock Size'),
                      DropdownButtonFormField<String>(
                        value: _selectedSize,
                        items: availableSizes
                            .map(
                              (size) => DropdownMenuItem(
                                value: size,
                                child: Text(size),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _selectedSize = val),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: white.withAlpha(80),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            v == null ? 'Select stock size' : null,
                      ),
                      const SizedBox(height: 16),

                      // Quantity
                      const FormLabel('Quantity'),
                      FormTextField(
                        controller: _quantityController,
                        hint: 'e.g., 250',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter quantity' : null,
                      ),
                      const SizedBox(height: 16),

                      // Unit
                      const FormLabel('Unit'),
                      DropdownButtonFormField<UnitType>(
                        value: _selectedUnit,
                        items: UnitType.values
                            .map(
                              (unit) => DropdownMenuItem<UnitType>(
                                value: unit,
                                child: Text(unit.label),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedUnit = val);
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: white.withAlpha(80),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      SubmitButton(
                        onPressed: _submit,
                        text: widget.order == null
                            ? "Add Order"
                            : "Update Order",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
