import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/providers/stock_provider.dart';
import 'package:stock_register/utils/string_capitalize.dart';
import 'package:stock_register/widgets/tables/dashboard_table.dart';

class StockTable extends StatelessWidget {
  const StockTable({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();
    final stocks = provider.stockHistory;

    final rows = stocks.map((s) {
      return DataRow(
        cells: [
          DataCell(Text(capitalize(s.name))),
          DataCell(Text(capitalize(s.color))),
          DataCell(Text(s.size)),
          DataCell(Text(s.quantity.toString())),
        ],
      );
    }).toList();

    return DashboardTable(
      columns: const [
        DataColumn(label: Text("Name")),
        DataColumn(label: Text("Color")),
        DataColumn(label: Text("Size")),
        DataColumn(label: Text("Quantity")),
      ],
      rows: rows,
    );
  }
}