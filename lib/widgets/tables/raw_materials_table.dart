import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/providers/raw_material_provider.dart';
import 'package:stock_register/utils/string_capitalize.dart';
import 'package:stock_register/widgets/tables/dashboard_table.dart';

class RawMaterialTable extends StatelessWidget {
  const RawMaterialTable({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RawMaterialProvider>();
    final items = provider.purchases;

    final rows = items.map((m) {
      return DataRow(
        cells: [
          DataCell(Text(capitalize(m.materialName))),
          DataCell(Text(capitalize(m.materialType))),
          DataCell(Text(capitalize(m.materialColor))),
          DataCell(Text(m.materialQuantity.toString() + m.materialUnit.name)),
          DataCell(Text(m.purchaseDate.toLocal().toString().split(' ')[0])),
          DataCell(Text(capitalize(m.materialSupplier))),
          DataCell(Text("₹${m.totalPrice.toStringAsFixed(2)}")),
        ],
      );
    }).toList();

    return DashboardTable(
      columns: const [
        DataColumn(label: Text("Name")),
        DataColumn(label: Text("Type")),
        DataColumn(label: Text("Color")),
        DataColumn(label: Text("Quantity")),
        DataColumn(label: Text("Purchase Date")),
        DataColumn(label: Text("Supplier")),
        DataColumn(label: Text("Price")),
      ],
      rows: rows,
    );
  }
}
