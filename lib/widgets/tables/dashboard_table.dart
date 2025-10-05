import 'package:flutter/material.dart';
import 'package:stock_register/colors.dart';

class DashboardTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;

  const DashboardTable({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Text(
          "No Data Found",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 16,
                headingRowHeight: 48,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 60,
                headingRowColor: WidgetStateProperty.all(
                  deepBrown.withAlpha(220),
                ),
                headingTextStyle: const TextStyle(
                  color: cream,
                  fontWeight: FontWeight.bold,
                ),
                columns: columns,
                rows: List.generate(rows.length, (index) {
                  final row = rows[index];
                  final isEven = index % 2 == 0;
                  return DataRow(
                    color: WidgetStateProperty.all(
                      isEven ? Colors.grey[50] : white,
                    ),
                    cells: row.cells,
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
