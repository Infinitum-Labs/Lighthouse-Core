library core.utils;

import 'dart:convert';
import 'dart:math';

import 'package:lighthouse_core/auth/auth.dart';
import 'package:lighthouse_core/db/db.dart';

part './types.dart';
part './exceptions.dart';

void emptyCallback() {}

class ObjectID {
  static const String _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
  static final Random _rnd = Random();

  static String generateAlphaNumString([int length = 8]) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

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

extension PropertyListUtils<T, R> on List<Property<T, R>> {
  List<T> getValues() => [for (final prop in this) prop.get()];
}

extension JSONUtils on JSON {
  T get<T>(String key) => this[key] as T;

  T? getOrNull<T>(String key, [T Function()? orElse]) => containsKey(key)
      ? get<T>(key)
      : orElse == null
          ? null
          : orElse();

  List<Object?> getList(String key) => get<List<Object?>>(key);
}

extension DateUtils on DateTime {
  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).round();
  int get minutesSinceEpoch => (millisecondsSinceEpoch / dtConvConst).round();
}

extension StringUtils on String {
  String toCamelCase() {
    final List<String> chunks = split(' ');
    final List<String> result = [];
    result.add(chunks[0].toLowerCase());
    for (int i = 1; i < chunks.length; i++) {
      result.add(
        "${chunks[i][0].toUpperCase()}${chunks[i].substring(1).toLowerCase()}",
      );
    }
    return result.join('');
  }
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
    final result = enumValues.where((T value) => value.name == label);
    if (result.isEmpty) {
      throw "EnumFromString failed for value '$label'";
    } else {
      return result.first;
    }
  }
}

bool equalsType<A, B>() => A == B;

extension TypeUtils on Object? {
  bool get isNative => this is num || this is String || this is bool;

  /// If
  dynamic isStorable([bool shouldReturnVal = false]) {
    if (this == null) {
      return shouldReturnVal ? null : true;
    } else if (isNative) {
      return shouldReturnVal ? this : true;
    } else if (this is DateTime) {
      return shouldReturnVal ? (this as DateTime).minutesSinceEpoch : true;
    } else if (this is Duration) {
      return shouldReturnVal ? (this as Duration).inMinutes : true;
    } else if (this is Storable) {
      return shouldReturnVal ? (this as Storable).toStorable() : true;
    } else if (this is Iterable) {
      if (this is Iterable<Storable>) {
        return shouldReturnVal
            ? [for (final st in this as Iterable<Storable>) st.toStorable()]
            : true;
      } else {
        bool isOnlyPrimitive = true;
        for (final x in (this as Iterable<Object?>)) {
          if (!x.isNative) {
            isOnlyPrimitive = false;
            if (!x.isStorable()) {
              return shouldReturnVal
                  ? throw "shouldReturnVal for isStorable, but iterable has non-storables"
                  : false;
            }
          }
        }
        if (isOnlyPrimitive) {
          return shouldReturnVal ? this : true;
        } else {
          return shouldReturnVal
              ? [
                  for (final n in (this as Iterable<Object?>))
                    n.isStorable(true)
                ]
              : true;
        }
      }
    } else if (this is Map) {
      if ((this as Map).keys.isStorable() &&
          (this as Map).values.isStorable()) {
        return shouldReturnVal ? this : true;
      } else {
        return shouldReturnVal
            ? throw "shouldReturnVal for isStorable, but map has non-storables"
            : false;
      }
    } else {
      return false;
    }
  }
}
