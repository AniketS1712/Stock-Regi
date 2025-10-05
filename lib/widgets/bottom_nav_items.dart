import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({required this.icon, required this.label});
}

final List<BottomNavItem> bottomNavItems = [
  BottomNavItem(icon: Icons.inventory, label: 'Purchases'),
  BottomNavItem(icon: Icons.factory, label: 'Production'),
  BottomNavItem(icon: Icons.warehouse, label: 'Finished Goods'),
  BottomNavItem(icon: Icons.shopping_cart, label: 'Orders'),
];
