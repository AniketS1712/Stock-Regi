enum UnitType { kg, pcs }

extension UnitTypeExtension on UnitType {
  String get label {
    switch (this) {
      case UnitType.kg:
        return "kg";
      case UnitType.pcs:
        return "pcs";
    }
  }
}
