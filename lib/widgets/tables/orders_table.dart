import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/enum/unit_type.dart';
import 'package:stock_register/providers/order_provider.dart';
import 'package:stock_register/utils/string_capitalize.dart';
import 'package:stock_register/widgets/tables/dashboard_table.dart';

class OrdersTable extends StatelessWidget {
  const OrdersTable({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final orders = provider.orders;

    final rows = orders.map((o) {
      return DataRow(
        cells: [
          DataCell(Text(capitalize(o.buyerName))),
          DataCell(Text(o.orderDate.toLocal().toString().split(' ')[0])),
          DataCell(Text(o.quantity.toString())),
          DataCell(Text(o.unit.label)),
          DataCell(Text(o.stockName)),
          DataCell(Text(o.stockColor)),
          DataCell(Text(o.stockSize)),
        ],
      );
    }).toList();

    return DashboardTable(
      columns: const [
        DataColumn(label: Text("Buyer")),
        DataColumn(label: Text("Order Date")),
        DataColumn(label: Text("Quantity")),
        DataColumn(label: Text("Unit")),
        DataColumn(label: Text("Stock Name")),
        DataColumn(label: Text("Color")),
        DataColumn(label: Text("Size")),
      ],
      rows: rows,
    );
  }
}
