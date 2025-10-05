import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/providers/order_provider.dart';
import 'package:stock_register/providers/production_provider.dart';
import 'package:stock_register/providers/raw_material_provider.dart';
import 'package:stock_register/providers/stock_provider.dart';
import 'package:stock_register/providers/user_provider.dart';
import 'package:stock_register/screens/dashboard.dart';
import 'package:stock_register/screens/forms/order_form.dart';
import 'package:stock_register/screens/forms/production_form.dart';
import 'package:stock_register/screens/forms/raw_material_form.dart';
import 'package:stock_register/screens/forms/stock_form.dart';
import 'package:stock_register/screens/forms/user_signup_form.dart';
import 'package:stock_register/screens/home_screen.dart';
import 'package:stock_register/service/stock_service.dart';
import 'package:stock_register/utils/routes.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userProvider.currentUser == null) {
          return const UserSignupForm();
        }

        // User is logged in → initialize providers
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  RawMaterialProvider(userId: userProvider.currentUser!.id),
            ),
            ChangeNotifierProvider(
              create: (_) =>
                  ProductionProvider(userId: userProvider.currentUser!.id),
            ),
            ChangeNotifierProvider(
              create: (_) =>
                  StockProvider(userId: userProvider.currentUser!.id),
            ),
            ChangeNotifierProvider(
              create: (_) => OrdersProvider(
                userId: userProvider.currentUser!.id,
                stockService: StockService(
                  userId: userProvider.currentUser!.id,
                ),
              ),
            ),
          ],
          child: const _AppNavigator(),
        );
      },
    );
  }
}

class _AppNavigator extends StatelessWidget {
  const _AppNavigator();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: Routes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case Routes.rawMaterialForm:
            return MaterialPageRoute(builder: (_) => const RawMaterialForm());
          case Routes.productionForm:
            return MaterialPageRoute(builder: (_) => const ProductionForm());
          case Routes.stockForm:
            return MaterialPageRoute(builder: (_) => const StockForm());
          case Routes.orderForm:
            return MaterialPageRoute(builder: (_) => const OrdersForm());
          case Routes.dashboard:
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
