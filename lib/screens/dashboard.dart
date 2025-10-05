import 'package:flutter/material.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/widgets/tables/raw_materials_table.dart';
import 'package:stock_register/widgets/tables/orders_table.dart';
import 'package:stock_register/widgets/tables/production_table.dart';
import 'package:stock_register/widgets/tables/stock_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(icon: Icon(Icons.receipt_long), text: "Purchases"),
    Tab(icon: Icon(Icons.factory), text: "Production"),
    Tab(icon: Icon(Icons.inventory), text: "Stock"),
    Tab(icon: Icon(Icons.shopping_cart), text: "Orders"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: night,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [whisteria, skyBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: white.withAlpha(65),
              borderRadius: BorderRadius.circular(64),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: cream,
              ),
              tabAlignment: TabAlignment.center,
              labelColor: night,
              unselectedLabelColor: cream,
              tabs: _tabs,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DashboardSection(child: RawMaterialTable()),
          _DashboardSection(child: ProductionTable()),
          _DashboardSection(child: StockTable()),
          _DashboardSection(child: OrdersTable()),
        ],
      ),
    );
  }
}

/// 🔹 Wraps content in a padded card-like style for consistency
class _DashboardSection extends StatelessWidget {
  final Widget child;
  const _DashboardSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
