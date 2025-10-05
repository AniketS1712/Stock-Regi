import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/enum/unit_type.dart';
import 'package:stock_register/models/production_model.dart';
import 'package:stock_register/models/production_material_model.dart';
import 'package:stock_register/providers/production_provider.dart';
import 'package:stock_register/providers/raw_material_provider.dart';
import 'package:stock_register/utils/date_picker_util.dart';
import 'package:stock_register/widgets/form/date_picker_field.dart';
import 'package:stock_register/widgets/form/form_label.dart';
import 'package:stock_register/widgets/form/form_text_field.dart';
import 'package:stock_register/widgets/form/quantity_unit_row.dart';
import 'package:stock_register/widgets/form/submit_button.dart';
import 'package:stock_register/widgets/glass_card.dart';

class ProductionForm extends StatefulWidget {
  final Function(ProductionModel)? onSubmit;

  const ProductionForm({super.key, this.onSubmit});

  @override
  State<ProductionForm> createState() => _ProductionFormState();
}

class _ProductionFormState extends State<ProductionForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _batchController;
  late FocusNode _batchFocus;

  DateTime _selectedDate = DateTime.now();

  final List<ProductionMaterialModel> _materials = [];
  final List<TextEditingController> _materialQtyControllers = [];
  final List<FocusNode> _materialFocusNodes = [];

  @override
  void initState() {
    super.initState();
    _batchController = TextEditingController(
      text: "BATCH-${DateTime.now().millisecondsSinceEpoch}",
    );
    _batchFocus = FocusNode();
    _addMaterial();
  }

  @override
  void dispose() {
    _batchController.dispose();
    _batchFocus.dispose();
    for (var c in _materialQtyControllers) {
      c.dispose();
    }
    for (var f in _materialFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _addMaterial() {
    setState(() {
      _materials.add(
        ProductionMaterialModel(
          materialName: '',
          materialType: '',
          materialColor: '',
          quantityUsed: 0,
          unit: UnitType.kg,
        ),
      );
      _materialQtyControllers.add(TextEditingController());
      _materialFocusNodes.add(FocusNode());
    });
  }

  void _removeMaterial(int index) {
    setState(() {
      _materials.removeAt(index);
      _materialQtyControllers.removeAt(index).dispose();
      _materialFocusNodes.removeAt(index).dispose();
    });
  }

  void _syncMaterialsFromControllers() {
    for (int i = 0; i < _materials.length; i++) {
      final qty = double.tryParse(_materialQtyControllers[i].text.trim()) ?? 0;
      _materials[i] = _materials[i].copyWith(quantityUsed: qty);
    }
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

    _syncMaterialsFromControllers();

    if (_materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one material")),
      );
      return;
    }

    for (int i = 0; i < _materials.length; i++) {
      final m = _materials[i];
      if (m.materialName.trim().isEmpty ||
          m.materialType.trim().isEmpty ||
          m.materialColor.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Material ${i + 1}: Fill all details")),
        );
        return;
      }
      if (m.quantityUsed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Material ${i + 1}: Quantity must be > 0")),
        );
        return;
      }
    }

    final production = ProductionModel(
      id: '',
      batchNumber: _batchController.text.trim(),
      startDate: _selectedDate,
      endDate: null,
      materialsUsed: _materials,
      status: "in-progress",
    );

    final productionProvider = context.read<ProductionProvider>();
    try {
      await productionProvider.addProduction(production);
      widget.onSubmit?.call(production);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed: $e")));
    }
  }

  Widget _buildMaterialCard(
    int index,
    List<String> availableMaterials,
    List<String> types,
    List<String> colors,
  ) {
    final material = _materials[index];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildDropdown(
            value:
                material.materialName.isNotEmpty &&
                    availableMaterials.contains(material.materialName)
                ? material.materialName
                : null,
            hint: "Select material",
            items: availableMaterials,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _materials[index] = _materials[index].copyWith(
                    materialName: val,
                    materialType: '-',
                    materialColor: '-',
                  );
                });
              }
            },
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value:
                material.materialType.isNotEmpty &&
                    types.contains(material.materialType)
                ? material.materialType
                : null,
            hint: "Select type",
            items: types,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _materials[index] = _materials[index].copyWith(
                    materialType: val,
                    materialColor: '-',
                  );
                });
              }
            },
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value:
                material.materialColor.isNotEmpty &&
                    colors.contains(material.materialColor)
                ? material.materialColor
                : null,
            hint: "Select color",
            items: colors,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _materials[index] = _materials[index].copyWith(
                    materialColor: val,
                  );
                });
              }
            },
          ),
          const SizedBox(height: 8),
          QuantityUnitRow(
            quantityController: _materialQtyControllers[index],
            selectedUnit: material.unit,
            onChanged: (val) {
              if (val != null) {
                setState(
                  () =>
                      _materials[index] = _materials[index].copyWith(unit: val),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _removeMaterial(index),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  DropdownButtonFormField<String> _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawMaterialProvider = context.watch<RawMaterialProvider>();
    final availableMaterials = rawMaterialProvider.availableMaterials;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: white.withAlpha(190),
        elevation: 2,
        title: const Text(
          'Production Entry',
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
                      const FormLabel('Batch Number'),
                      FormTextField(
                        controller: _batchController,
                        focusNode: _batchFocus,
                        hint: 'Unique batch ID',
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter batch number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const FormLabel('Start Date'),
                      DatePickerField(
                        selectedDate: _selectedDate,
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 16),
                      const FormLabel('Raw Materials Used'),
                      Column(
                        children: List.generate(_materials.length, (index) {
                          final types = rawMaterialProvider.getTypesFor(
                            _materials[index].materialName,
                          );
                          final colors = rawMaterialProvider.getColorsFor(
                            _materials[index].materialName,
                            _materials[index].materialType,
                          );
                          return _buildMaterialCard(
                            index,
                            availableMaterials,
                            types,
                            colors,
                          );
                        }),
                      ),
                      TextButton(
                        onPressed: _addMaterial,
                        child: const Text('+ Add Material'),
                      ),
                      const SizedBox(height: 32),
                      SubmitButton(onPressed: _submit, text: "Save Production"),
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
