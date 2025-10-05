import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stock_register/models/production_model.dart';
import 'package:stock_register/service/production_service.dart';

class ProductionProvider extends ChangeNotifier {
  final ProductionService _service = ProductionService();
  final String userId;

  List<ProductionModel> productions = [];
  bool isLoading = false;
  String? errorMessage;

  StreamSubscription<List<ProductionModel>>? _prodSub;

  ProductionProvider({required this.userId}) {
    _subscribeStream();
  }

  // 🔹 PRIVATE HELPERS
  void _setLoading(bool value) {
    if (isLoading != value) {
      isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String? msg) {
    if (errorMessage != msg) {
      errorMessage = msg;
      notifyListeners();
    }
  }

  void _subscribeStream() {
    _prodSub?.cancel();
    _prodSub = _service.getProductions(userId).listen((list) {
      productions = list;
      _setError(null);
    }, onError: (e) => _setError(e.toString()));
  }

  // 🔹 CRUD OPERATIONS
  Future<void> addProduction(ProductionModel production) =>
      _performServiceAction(() => _service.addProduction(userId, production));

  Future<void> updateProduction(ProductionModel production) =>
      _performServiceAction(
        () => _service.updateProduction(userId, production),
      );

  Future<void> deleteProduction(String id) =>
      _performServiceAction(() => _service.deleteProduction(userId, id));

  /// ✅ Mark production as completed
  Future<void> markAsCompleted(String batchNumber) async {
    try {
      final prod = productions.firstWhere((p) => p.batchNumber == batchNumber);

      final updatedProd = prod.copyWith(
        status: "completed",
        endDate: DateTime.now(),
      );

      await updateProduction(updatedProd);
    } catch (e) {
      _setError("Production with batch $batchNumber not found");
    }
  }

  // 🔹 General helper for CRUD calls (loading & error handling)
  Future<void> _performServiceAction(Future<void> Function() action) async {
    _setLoading(true);
    try {
      await action();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 🔹 REFRESH STREAM
  void refresh() => _subscribeStream();

  // 🔹 CLEAR PROVIDER STATE
  void clear() {
    productions.clear();
    _setError(null);
    notifyListeners();
  }

  @override
  void dispose() {
    _prodSub?.cancel();
    super.dispose();
  }
}
