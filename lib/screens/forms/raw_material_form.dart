import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/enum/unit_type.dart';
import 'package:stock_register/models/raw_material_model.dart';
import 'package:stock_register/providers/raw_material_provider.dart';
import 'package:stock_register/utils/date_picker_util.dart';
import 'package:stock_register/widgets/form/form_label.dart';
import 'package:stock_register/widgets/form/form_text_field.dart';
import 'package:stock_register/widgets/form/quantity_unit_row.dart';
import 'package:stock_register/widgets/form/date_picker_field.dart';
import 'package:stock_register/widgets/form/submit_button.dart';
import 'package:stock_register/widgets/glass_card.dart';

class RawMaterialForm extends StatefulWidget {
  final RawMaterialModel? rawMaterial;
  final Function(RawMaterialModel)? onSubmit;

  const RawMaterialForm({super.key, this.rawMaterial, this.onSubmit});

  @override
  State<RawMaterialForm> createState() => _RawMaterialFormState();
}

class _RawMaterialFormState extends State<RawMaterialForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _typeController;
  late TextEditingController _colorController;
  late TextEditingController _supplierController;
  late TextEditingController _priceController;
  UnitType _selectedUnit = UnitType.kg;
  DateTime _selectedDate = DateTime.now();

  late FocusNode _nameFocus;
  late FocusNode _quantityFocus;
  late FocusNode _typeFocus;
  late FocusNode _colorFocus;
  late FocusNode _supplierFocus;
  late FocusNode _priceFocus;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.rawMaterial?.materialName ?? '');
    _quantityController = TextEditingController(
        text: widget.rawMaterial?.materialQuantity.toString() ?? '');
    _typeController =
        TextEditingController(text: widget.rawMaterial?.materialType ?? '');
    _colorController =
        TextEditingController(text: widget.rawMaterial?.materialColor ?? '');
    _supplierController =
        TextEditingController(text: widget.rawMaterial?.materialSupplier ?? '');
    _priceController = TextEditingController(
        text: widget.rawMaterial?.totalPrice.toString() ?? '');
    _selectedUnit = widget.rawMaterial?.materialUnit ?? UnitType.kg;
    _selectedDate = widget.rawMaterial?.purchaseDate ?? DateTime.now();

    _nameFocus = FocusNode();
    _quantityFocus = FocusNode();
    _typeFocus = FocusNode();
    _colorFocus = FocusNode();
    _supplierFocus = FocusNode();
    _priceFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _quantityFocus.dispose();
    _typeFocus.dispose();
    _colorFocus.dispose();
    _supplierFocus.dispose();
    _priceFocus.dispose();

    _nameController.dispose();
    _quantityController.dispose();
    _typeController.dispose();
    _colorController.dispose();
    _supplierController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await DatePickerUtil.pickDate(
      context: context,
      initialDate: _selectedDate,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final rawMaterial = RawMaterialModel(
      id: widget.rawMaterial?.id ?? '',
      materialName: _nameController.text.trim(),
      materialUnit: _selectedUnit,
      materialQuantity: double.parse(_quantityController.text.trim()),
      materialType: _typeController.text.trim().isEmpty
          ? '-'
          : _typeController.text.trim(),
      materialColor: _colorController.text.trim().isEmpty
          ? '-'
          : _colorController.text.trim(),
      purchaseDate: _selectedDate,
      materialSupplier: _supplierController.text.trim(),
      totalPrice: double.parse(_priceController.text.trim()),
    );

    final provider = context.read<RawMaterialProvider>();

    try {
      if (widget.rawMaterial == null) {
        await provider.addPurchase(rawMaterial);
      } else {
        await provider.updatePurchase(rawMaterial);
      }

      widget.onSubmit?.call(rawMaterial);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving raw material: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
          'Add Raw Material',
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
              padding: const EdgeInsets.fromLTRB(8, 96, 8, 32),
              child: GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormLabel('Material Name'),
                      FormTextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_quantityFocus);
                        },
                        hint: 'e.g., Iron Rods',
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter material name' : null,
                      ),
                      const SizedBox(height: 16),

                      const FormLabel('Quantity & Unit'),
                      QuantityUnitRow(
                        quantityController: _quantityController,
                        selectedUnit: _selectedUnit,
                        focusNode: _quantityFocus,
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedUnit = value);
                        },
                        onSubmitted: () {
                          FocusScope.of(context).requestFocus(_typeFocus);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter quantity';
                          final qty = double.tryParse(value);
                          if (qty == null || qty <= 0) return 'Enter a valid positive quantity';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const FormLabel('Material Type (optional)'),
                      FormTextField(
                        controller: _typeController,
                        focusNode: _typeFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_colorFocus);
                        },
                        hint: 'e.g., Cotton',
                      ),
                      const SizedBox(height: 16),

                      const FormLabel('Material Color (optional)'),
                      FormTextField(
                        controller: _colorController,
                        focusNode: _colorFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_supplierFocus);
                        },
                        hint: 'e.g., red, white',
                      ),
                      const SizedBox(height: 16),

                      const FormLabel('Supplier'),
                      FormTextField(
                        controller: _supplierController,
                        focusNode: _supplierFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocus);
                        },
                        hint: 'e.g., ABC Suppliers',
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter supplier' : null,
                      ),
                      const SizedBox(height: 16),

                      const FormLabel('Purchase Date'),
                      DatePickerField(
                        selectedDate: _selectedDate,
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 16),

                      const FormLabel('Total Price Paid'),
                      FormTextField(
                        controller: _priceController,
                        focusNode: _priceFocus,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        keyboardType: TextInputType.number,
                        hint: 'e.g., 5000',
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter total price';
                          if (double.tryParse(value) == null) return 'Enter a valid number';
                          return null;
                        },
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
