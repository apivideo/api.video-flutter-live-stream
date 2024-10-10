class Range<T extends num> {
  final T min;
  final T max;

  const Range({required this.min, required this.max});

  @override
  String toString() => 'Range<${T.runtimeType}>(min:$min, max:$max)';

  @override
  bool operator ==(Object other) =>
      other is Range<T> && min == other.min && max == other.max;

  @override
  int get hashCode => min.hashCode & max.hashCode;
}
