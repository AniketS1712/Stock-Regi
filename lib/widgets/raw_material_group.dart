import 'package:flutter/material.dart';
import 'package:stock_register/models/current_raw_material_model.dart';
import 'package:stock_register/widgets/raw_material_group_expanded.dart';
import 'package:stock_register/widgets/raw_material_group_header.dart';

class RawMaterialGroup extends StatelessWidget {
  final String groupKey;
  final List<CurrentRawMaterialModel> materials;
  final bool isExpanded;
  final VoidCallback onToggle;

  const RawMaterialGroup({
    super.key,
    required this.groupKey,
    required this.materials,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final totalQty = materials.fold<double>(
      0,
      (sum, m) => sum + m.availableQuantity,
    );
    final totalPrice = materials.fold<double>(
      0,
      (sum, m) => sum + m.totalPrice,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          RawMaterialGroupHeader(
            material: materials.first,
            totalQty: totalQty,
            totalPrice: totalPrice,
            isExpanded: isExpanded,
            onToggle: onToggle,
          ),
          if (isExpanded) RawMaterialGroupExpanded(materials: materials),
        ],
      ),
    );
  }
}
