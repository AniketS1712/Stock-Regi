import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/models/stock_model.dart';
import 'package:stock_register/providers/production_provider.dart';
import 'package:stock_register/providers/stock_provider.dart';
import 'package:stock_register/widgets/form/form_label.dart';
import 'package:stock_register/widgets/form/form_text_field.dart';
import 'package:stock_register/widgets/form/submit_button.dart';
import 'package:stock_register/widgets/glass_card.dart';

class StockForm extends StatefulWidget {
  final StockModel? stock;
  final Function(StockModel)? onSubmit;
  final String? batchNumber;

  const StockForm({super.key, this.stock, this.onSubmit, this.batchNumber});

  @override
  State<StockForm> createState() => _StockFormState();
}

class _StockFormState extends State<StockForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _sizeController;
  late TextEditingController _quantityController;
  late TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    final stock = widget.stock;
    _nameController = TextEditingController(text: stock?.name ?? '');
    _sizeController = TextEditingController(text: stock?.size ?? '');
    _quantityController = TextEditingController(
      text: stock?.quantity.toString() ?? '',
    );
    _colorController = TextEditingController(text: stock?.color ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _quantityController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final stock = StockModel(
      id: widget.stock?.id ?? '',
      name: _nameController.text.trim(),
      size: _sizeController.text.trim(),
      quantity: double.tryParse(_quantityController.text.trim()) ?? 0,
      color: _colorController.text.trim(),
    );

    final stockProvider = context.read<StockProvider>();
    final productionProvider = context.read<ProductionProvider>();

    try {
      if (widget.stock == null) {
        await stockProvider.addStock(stock);
      }

      if (widget.batchNumber != null) {
        await productionProvider.markAsCompleted(widget.batchNumber!);
      }

      widget.onSubmit?.call(stock);
      if (mounted) Navigator.pop(context,true);
    } catch (e) {
      debugPrint('Stock submit error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: white.withAlpha(190),
        elevation: 2,
        title: const Text(
          'Stock Entry',
          style: TextStyle(color: deepBrown, fontWeight: FontWeight.w600),
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
                      // ✅ Show Batch Number if passed
                      if (widget.batchNumber != null) ...[
                        Text(
                          "Batch: ${widget.batchNumber}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: night,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      const FormLabel('Stock Name'),
                      FormTextField(
                        controller: _nameController,
                        hint: 'e.g., T-shirt',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter stock name' : null,
                      ),
                      const SizedBox(height: 16),
                      const FormLabel('Size'),
                      FormTextField(
                        controller: _sizeController,
                        hint: 'e.g., M, L, XL',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter size' : null,
                      ),
                      const SizedBox(height: 16),
                      const FormLabel('Quantity'),
                      FormTextField(
                        controller: _quantityController,
                        hint: 'e.g., 100',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter quantity' : null,
                      ),
                      const SizedBox(height: 16),
                      const FormLabel('Color'),
                      FormTextField(
                        controller: _colorController,
                        hint: 'e.g., Red',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter color' : null,
                      ),
                      const SizedBox(height: 32),
                      SubmitButton(onPressed: _submit),
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
