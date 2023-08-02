library core.utils;

import 'dart:convert';
import 'dart:math';

import 'package:lighthouse_core/db/db.dart';

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

abstract class JSONObject {
  Map toJson();
}

class HttpUtils {
  static final Codec<String, String> _codec = utf8.fuse(base64Url);

  static String encodeToBase64Url(String src) => _codec.encode(src);
  static String decodeFromBase64Url(String src) => _codec.decode(src);
}

extension ListUtils<O> on List<O> {
  List<N> listOf<N>(N Function(O) converter) => map(converter).toList();
}

extension StorableListUtils on List<Storable> {
  List<Object?> toStorableList() => map((e) => e.toStorable()).toList();
}

extension DateUtils on DateTime {
  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).round();
}

const List<String> alphabets = [
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
];

class EnumUtils {
  static T enumFromString<T extends Enum>(
    Iterable<T> enumValues,
    String label,
  ) {
    return enumValues.firstWhere(
      (T value) => value.name == label,
      orElse: () => enumValues.first,
    );
  }
}
