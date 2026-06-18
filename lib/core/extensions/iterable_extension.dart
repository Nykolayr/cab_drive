extension IterableExt<T> on Iterable<T> {
  Iterable<T> superJoin(T Function(int) separator) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return [];

    final _l = [iterator.current];
    while (iterator.moveNext()) {
      _l..add(separator(_l.length - 1))..add(iterator.current);
    }
    return _l;
  }
}