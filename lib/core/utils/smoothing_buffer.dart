class SmoothingBuffer<T extends num> {
  final int size;
  final List<T> _values;

  SmoothingBuffer(this.size) : _values = [];

  void add(T value) {
    _values.add(value);
    if (_values.length > size) {
      _values.removeAt(0);
    }
  }

  double get average {
    if (_values.isEmpty) return 0.0;
    final sum = _values.fold<double>(0.0, (prev, v) => prev + v.toDouble());
    return sum / _values.length;
  }

  bool get isFull => _values.length >= size;

  void clear() => _values.clear();

  int get count => _values.length;
}
