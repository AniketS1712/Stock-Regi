import 'package:flutter/material.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/models/current_raw_material_model.dart';
import 'package:stock_register/utils/string_capitalize.dart';

class RawMaterialGroupExpanded extends StatelessWidget {
  final List<CurrentRawMaterialModel> materials;

  const RawMaterialGroupExpanded({super.key, required this.materials});

  @override
  Widget build(BuildContext context) {
    final maxHeight = 200.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: whisteria.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: materials.length,
          separatorBuilder: (_, __) =>
              Divider(color: night.withAlpha(50), thickness: 0.8, height: 12),
          itemBuilder: (context, i) {
            final m = materials[i];
            return Row(
              children: [
                const Icon(Icons.circle, size: 8, color: night),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${capitalize(m.materialType)} • ${capitalize(m.materialColor)}",
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                Text(
                  "${m.availableQuantity} ${m.materialUnit.name} • ₹${m.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: night,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
