import 'package:flutter/material.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/models/current_raw_material_model.dart';
import 'package:stock_register/utils/string_capitalize.dart';

class RawMaterialGroupHeader extends StatelessWidget {
  final CurrentRawMaterialModel material;
  final double totalQty;
  final double totalPrice;
  final bool isExpanded;
  final VoidCallback onToggle;

  const RawMaterialGroupHeader({
    super.key,
    required this.material,
    required this.totalQty,
    required this.totalPrice,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: whisteria.withAlpha(40),
        child: const Icon(Icons.inventory_2, color: night),
      ),
      title: Text(
        capitalize(material.materialName),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: night,
        ),
      ),
      subtitle: Text(
        "$totalQty ${material.materialUnit.name} • ₹${totalPrice.toStringAsFixed(2)}",
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
      trailing: IconButton(
        icon: AnimatedRotation(
          duration: const Duration(milliseconds: 250),
          turns: isExpanded ? 0.5 : 0,
          child: const Icon(Icons.expand_more, color: night),
        ),
        onPressed: onToggle,
      ),
    );
  }
}
