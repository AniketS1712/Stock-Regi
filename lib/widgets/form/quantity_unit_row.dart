import 'package:flutter/material.dart';
import 'package:stock_register/enum/unit_type.dart';
import 'package:stock_register/widgets/form/form_text_field.dart';

class QuantityUnitRow extends StatelessWidget {
  final TextEditingController quantityController;
  final UnitType selectedUnit;
  final void Function(UnitType?) onChanged;
  final FocusNode? focusNode;
  final VoidCallback? onSubmitted;
  final String? Function(String?)? validator;

  const QuantityUnitRow({
    super.key,
    required this.quantityController,
    required this.selectedUnit,
    required this.onChanged,
    this.focusNode,
    this.onSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: FormTextField(
            controller: quantityController,
            focusNode: focusNode,
            hint: 'e.g., 100',
            keyboardType: TextInputType.number,
            validator:
                validator ??
                (value) {
                  if (value == null || value.isEmpty) return 'Enter quantity';
                  if (double.tryParse(value) == null) {
                    return 'Enter valid number';
                  }
                  return null;
                },
            textInputAction: onSubmitted != null
                ? TextInputAction.next
                : TextInputAction.done,
            onFieldSubmitted: (_) {
              if (onSubmitted != null) onSubmitted!();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<UnitType>(
            value: selectedUnit,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Unit",
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              isDense: true,
            ),
            items: UnitType.values
                .map(
                  (unit) =>
                      DropdownMenuItem(value: unit, child: Text(unit.label)),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
