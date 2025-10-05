import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/utils/routes.dart';
import 'package:stock_register/widgets/app_logo.dart';
import 'package:stock_register/widgets/bottom_nav_items.dart';
//Providers Imports
import 'package:stock_register/providers/home_provider.dart';
import 'package:stock_register/providers/user_provider.dart';
//List Page View Imports
import 'package:stock_register/widgets/list/raw_material_list.dart';
import 'package:stock_register/widgets/list/production_list.dart';
import 'package:stock_register/widgets/list/stock_list.dart';
import 'package:stock_register/widgets/list/orders_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final userProvider = context.watch<UserProvider>();
    final companyName = userProvider.currentUser?.companyName ?? "User";

    final List<Widget> listScreens = [
      RawMaterialList(),
      ProductionList(),
      StockList(),
      OrdersList(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: const AppLogo(),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [whisteria, skyBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard, color: night, size: 28),
            tooltip: "Go to Dashboard",
            onPressed: () {
              Navigator.pushNamed(context, Routes.dashboard);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          /// 🔹 Welcome Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [night, deepBrown, whisteria],
                  stops: [0.0, 0.05, 0.9],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: black.withAlpha(80),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, $companyName 👋",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: cream,
                    ),
                  ),
                  const SizedBox(height: 6),

                  /// Subtitle
                  const Text(
                    "Here's your business overview",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: cream,
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Date (dynamic)
                  Text(
                    "📅 ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                    style: TextStyle(fontSize: 16, color: cream.withAlpha(200)),
                  ),
                ],
              ),
            ),
          ),

          /// 🔹 PageView with horizontal swipe
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                context.read<HomeProvider>().changeIndex(index);
              },
              children: listScreens,
            ),
          ),
        ],
      ),

      /// 🔹 Modern Floating Bottom Navigation
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: homeProvider.selectedIndex,
            onTap: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              homeProvider.changeIndex(index);
            },
            backgroundColor: whisteria,
            selectedItemColor: night,
            selectedIconTheme: IconThemeData(
              shadows: [
                Shadow(color: white, offset: Offset(2, 2), blurRadius: 10),
                Shadow(color: white, offset: Offset(-2, -2), blurRadius: 10),
              ],
            ),
            unselectedItemColor: deepBrown,
            elevation: 6,
            type: BottomNavigationBarType.fixed,
            items: bottomNavItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
