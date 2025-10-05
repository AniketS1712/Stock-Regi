import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/providers/production_provider.dart';
import 'package:stock_register/utils/string_capitalize.dart';
import 'package:stock_register/widgets/tables/dashboard_table.dart';

class ProductionTable extends StatelessWidget {
  const ProductionTable({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductionProvider>();
    final productions = provider.productions;

    final rows = productions.map((p) {
      final materials = p.materialsUsed
          .map(
            (m) =>
                "${capitalize(m.materialName)} (${capitalize(m.materialType)} - ${capitalize(m.materialColor)}) - ${m.quantityUsed} ${m.unit.name}",
          )
          .join(", ");

      return DataRow(
        cells: [
          DataCell(Text(p.batchNumber)),
          DataCell(Text(p.startDate.toLocal().toString().split(' ')[0])),
          DataCell(
            Text(
              p.endDate != null
                  ? p.endDate!.toLocal().toString().split(' ')[0]
                  : "-",
            ),
          ),
          DataCell(Text(capitalize(p.status))),
          DataCell(Text(materials)),
        ],
      );
    }).toList();

    return DashboardTable(
      columns: const [
        DataColumn(label: Text("Batch No")),
        DataColumn(label: Text("Start Date")),
        DataColumn(label: Text("End Date")),
        DataColumn(label: Text("Status")),
        DataColumn(label: Text("Materials Used")),
      ],
      rows: rows,
    );
  }
}
