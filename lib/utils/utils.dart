library core.utils;

import 'dart:math';

part './types.dart';

void emptyCallback() {}

class ObjectID {
  static const String _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
  static final Random _rnd = Random();

  static String generateAlphaNumString() =>
      String.fromCharCodes(Iterable.generate(
          8, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static String generate(String objectPrefix, String userKey) =>
      '$objectPrefix-' +
      ObjectID.generateAlphaNumString() +
      '-$userKey'; // wb-nr8ybar4-voefiyg7
}

class LoopUtils {
  static void iterateOver<T>(Iterable<T> items, void Function(T) action) {
    final int iterationLimit = items.length;
    for (int i = 0; i < iterationLimit; i++) {
      action(items.elementAt(i));
    }
  }

  static Future<void> iterateOverAsync<T>(
      Iterable<T> items, Future<void> Function(T) action) async {
    final int iterationLimit = items.length;
    for (int i = 0; i < iterationLimit; i++) {
      await action(items.elementAt(i));
    }
  }
}

extension ListUtils<O> on List<O> {
  List<N> listOf<N>(N Function(O) converter) => map(converter).toList();
}
