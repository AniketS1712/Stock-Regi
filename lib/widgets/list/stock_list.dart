import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/providers/stock_provider.dart';
import 'package:stock_register/models/stock_model.dart';
import 'package:stock_register/utils/routes.dart';
import 'package:stock_register/utils/string_capitalize.dart';

class StockList extends StatefulWidget {
  const StockList({super.key});

  @override
  State<StockList> createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  final Map<String, bool> _expandedGroups = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, _) {
        final stocks = stockProvider.currentStock;

        // Group by stock name
        final grouped = <String, List<StockModel>>{};
        for (final stock in stocks) {
          grouped.putIfAbsent(stock.name, () => []).add(stock);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Stock Present",
              style: TextStyle(color: night, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [deepBrown, whisteria, whisteria, skyBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.2, 0.8, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            elevation: 3,
          ),
          body: grouped.isEmpty
              ? const Center(
                  child: Text(
                    "No stock items found.",
                    style: TextStyle(color: night, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final entry = grouped.entries.elementAt(index);
                      final groupName = entry.key;
                      final items = entry.value;

                      final totalQty = items.fold<double>(
                        0,
                        (sum, s) => sum + s.quantity,
                      );

                      final isExpanded = _expandedGroups[groupName] ?? false;

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
                            // Header
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: whisteria.withAlpha(40),
                                child: const Icon(
                                  Icons.inventory,
                                  color: night,
                                ),
                              ),
                              title: Text(
                                capitalize(groupName),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: night,
                                ),
                              ),
                              subtitle: Text(
                                "Total: $totalQty",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: IconButton(
                                icon: AnimatedRotation(
                                  duration: const Duration(milliseconds: 250),
                                  turns: isExpanded ? 0.5 : 0,
                                  child: const Icon(
                                    Icons.expand_more,
                                    color: night,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _expandedGroups[groupName] = !isExpanded;
                                  });
                                },
                              ),
                            ),

                            // Expanded details
                            if (isExpanded)
                              Container(
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: whisteria.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => Divider(
                                    color: night.withAlpha(50),
                                    thickness: 0.8,
                                    height: 12,
                                  ),
                                  itemBuilder: (context, i) {
                                    final stock = items[i];
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: night,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "${capitalize(stock.size)} • ${capitalize(stock.color)}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${stock.quantity}",
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
                          ],
                        ),
                      );
                    },
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: skyBlue,
            elevation: 6,
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.stockForm);
            },
            child: const Icon(Icons.add, color: night),
          ),
        );
      },
    );
  }
}
