dynamic defaultKeyTransformation(dynamic e) {
  return e;
}

String defaultValueTransformation(dynamic e) {
  return "$e";
}

extension SetMapExtension<T> on Set<T> {
  /// Returns a map with the elements of the set as keys and a string
  /// representation of the elements as values.
  Map<T, String> toDisplayMap(
      {Function(T e) keyTransformation = defaultKeyTransformation,
      Function(T e) valueTransformation = defaultValueTransformation}) {
    var map = Map<T, String>.fromIterable(this,
        key: (k) => keyTransformation(k), value: (v) => valueTransformation(v));
    return map;
  }
}
