import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  final PageController pageController = PageController(initialPage: 0);

  int get selectedIndex => _selectedIndex;

  void changeIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void onPageChanged(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void jumpToPage(int index) {
    pageController.jumpToPage(index);
    changeIndex(index);
  }

  void animateToPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    changeIndex(index);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
