import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_register/models/raw_material_model.dart';
import 'package:stock_register/models/current_raw_material_model.dart';
import 'package:stock_register/service/raw_material_service.dart';

class RawMaterialProvider extends ChangeNotifier {
  final RawMaterialService _service = RawMaterialService();
  final String userId;

  RawMaterialProvider({required this.userId}) {
    _subscribeStreams();
  }

  List<RawMaterialModel> purchases = [];
  List<CurrentRawMaterialModel> currentStock = [];

  bool isLoading = false;
  String? errorMessage;

  StreamSubscription<List<RawMaterialModel>>? _pSub;
  StreamSubscription<List<CurrentRawMaterialModel>>? _currentSub;

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

  void _subscribeStreams() {
    _pSub?.cancel();
    _currentSub?.cancel();

    _pSub = _service.getRawMaterials(userId).listen((list) {
      purchases = list;
      notifyListeners();
    }, onError: (e) => _setError(e.toString()));

    _currentSub = _service.getCurrentRawMaterialStream(userId).listen((list) {
      currentStock = list;
      notifyListeners();
    }, onError: (e) => _setError(e.toString()));
  }

  CollectionReference<Map<String, dynamic>> get currentCollection =>
      _service.currentCollection(userId);

  // 🔹 CRUD OPERATIONS
  Future<bool> addPurchase(RawMaterialModel material) async =>
      _performServiceAction(() => _service.addRawMaterial(userId, material));

  Future<bool> updatePurchase(RawMaterialModel material) async =>
      _performServiceAction(() => _service.updateRawMaterial(userId, material));

  Future<bool> deletePurchase(String id) async =>
      _performServiceAction(() => _service.deleteRawMaterial(userId, id));

  Future<bool> _performServiceAction(Future<void> Function() action) async {
    _setLoading(true);
    _setError(null);
    try {
      await action();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🔹 DERIVED PROPERTIES
  List<String> get availableMaterials => purchases
      .map((m) => m.materialName)
      .where((n) => n.isNotEmpty)
      .toSet()
      .toList();

  List<String> getTypesFor(String materialName) {
    if (materialName.isEmpty) return [];
    return purchases
        .where((m) => m.materialName == materialName)
        .map((m) => m.materialType)
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> getColorsFor(String materialName, String type) {
    if (materialName.isEmpty) return [];
    return purchases
        .where(
          (m) =>
              m.materialName == materialName &&
              (type.isEmpty || m.materialType == type),
        )
        .map((m) => m.materialColor)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }

  List<CurrentRawMaterialModel> stockFor(String materialName, {String? unit}) {
    return currentStock.where((c) {
      final unitMatch = unit == null || c.materialUnit.name == unit;
      return c.materialName == materialName && unitMatch;
    }).toList();
  }

  // 🔹 REFRESH STREAMS
  void refresh() => _subscribeStreams();

  // 🔹 CLEAR PROVIDER STATE
  void clear() {
    purchases.clear();
    currentStock.clear();
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pSub?.cancel();
    _currentSub?.cancel();
    super.dispose();
  }
}
