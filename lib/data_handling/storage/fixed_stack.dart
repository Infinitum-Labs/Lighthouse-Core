part of core.data_handling.storage;

class FixedStack<E> {
  final List<E> _list = [];
  final int maxItems;

  FixedStack([this.maxItems = 5]);

  void push(E value) {
    if (length < maxItems) {
      _list.add(value);
    } else {
      removeOldest();
      _list.add(value);
    }
  }

  void addAll(List<E> elements) => _list.addAll(elements);

  void removeOldest() => _list.removeAt(0);

  E pop() => _list.removeLast();

  E get peek => _list.last;

  List<E> toList() => _list;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;
  int get length => _list.length;

  @override
  String toString() => _list.toString();
}
