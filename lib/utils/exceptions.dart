class InvalidQuantityException implements Exception {
  final String message;
  InvalidQuantityException(this.message);
  @override
  String toString() => 'InvalidQuantityException: $message';
}

class InvalidPriceException implements Exception {
  final String message;
  InvalidPriceException(this.message);
  @override
  String toString() => 'InvalidPriceException: $message';
}

class UnitMismatchException implements Exception {
  final String message;
  UnitMismatchException(this.message);
  @override
  String toString() => 'UnitMismatchException: $message';
}

class StockNotFoundException implements Exception {
  final String message;
  StockNotFoundException(this.message);
  @override
  String toString() => 'StockNotFoundException: $message';
}