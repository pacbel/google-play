class CryptoResult {
  final String value;

  const CryptoResult(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoResult &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CryptoResult(value: $value)';
}
