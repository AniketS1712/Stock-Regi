import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/enum/unit_type.dart';
import 'package:stock_register/providers/order_provider.dart';
import 'package:stock_register/utils/routes.dart';
import 'package:stock_register/models/orders_model.dart';
import 'package:stock_register/utils/string_capitalize.dart';

class OrdersList extends StatefulWidget {
  const OrdersList({super.key});

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  final Map<String, bool> _expandedGroups = {};
  final dateFormatter = DateFormat.yMMMd();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Orders List",
          style: TextStyle(color: night, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [skyBlue, whisteria, whisteria, deepBrown],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        elevation: 3,
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: skyBlue),
            );
          }

          if (provider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.shopping_cart_outlined, size: 48, color: night),
                  SizedBox(height: 12),
                  Text(
                    "No orders found.",
                    style: TextStyle(color: night, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final orders = provider.orders;

          // 🔹 Group by Buyer Name
          final grouped = <String, List<OrdersModel>>{};
          for (final order in orders) {
            grouped.putIfAbsent(order.buyerName, () => []).add(order);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final entry = grouped.entries.elementAt(index);
                final buyerName = entry.key;
                final buyerOrders = entry.value;

                final totalQty = buyerOrders.fold<double>(
                  0,
                  (sum, o) => sum + o.quantity,
                );

                final isExpanded = _expandedGroups[buyerName] ?? false;

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
                      // 🔹 Group Header
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: whisteria.withAlpha(40),
                          child: const Icon(Icons.person, color: night),
                        ),
                        title: Text(
                          capitalize(buyerName),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: night,
                          ),
                        ),
                        subtitle: Text(
                          "Total Orders: $totalQty",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        trailing: IconButton(
                          icon: AnimatedRotation(
                            duration: const Duration(milliseconds: 250),
                            turns: isExpanded ? 0.5 : 0,
                            child: const Icon(Icons.expand_more, color: night),
                          ),
                          onPressed: () {
                            setState(() {
                              _expandedGroups[buyerName] = !isExpanded;
                            });
                          },
                        ),
                      ),

                      // 🔹 Expanded Orders
                      if (isExpanded)
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: whisteria.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: buyerOrders.length,
                            separatorBuilder: (_, __) => Divider(
                              color: night.withAlpha(50),
                              thickness: 0.8,
                              height: 12,
                            ),
                            itemBuilder: (context, i) {
                              final order = buyerOrders[i];
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
                                      "${order.quantity} ${order.unit.label} of ${capitalize(order.stockName)} "
                                      "(${capitalize(order.stockColor)}, ${capitalize(order.stockSize)}) "
                                      "• ${dateFormatter.format(order.orderDate)}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: deepBrown,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Delete Order"),
                                          content: Text(
                                            "Delete order of ${order.stockName} from '$buyerName'?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: deepBrown,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await provider.deleteOrder(order);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Order deleted for '$buyerName'",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: skyBlue,
        onPressed: () {
          Navigator.pushNamed(context, Routes.orderForm);
        },
        child: const Icon(Icons.add, color: night),
      ),
    );
  }
}
