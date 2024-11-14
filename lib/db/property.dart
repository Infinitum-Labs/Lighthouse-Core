part of lh.core.db;

/// A Schema property of native type [T] and represented type [R] in forms
abstract class Property<T, R> implements Storable {
  DocumentReference? docRef;

  /// The label shown above the form field
  final String label;

  /// The corresponding key in the JSON representation
  final String key;
  final T Function(R) convertToNative;

  /// The underlying native value being stored
  T? _value;

  /// Don't provide a [defaultValue] if:
  /// - the property is optional AND nullable, or,
  /// - the property is required
  /// Do provide a [defaultValue] if:
  /// - the property is optional and it is sensible to assign a default value, or,
  /// - the property is optional but not nullable
  final T? defaultValue;

  Property(
    this.label, {
    required this.defaultValue,
    T Function(R)? native,
    String? key,
  })  : convertToNative = native ?? ((R r) => r as T),
        key = key ?? label.toCamelCase();

  void set(T value) => _value = value;

  Future<void> setAndUpdate(T value) async {
    set(value);
    if (docRef != null) {
      await docRef!.update({key: toStorable()});
    }
  }

  void linkTo(DocumentReference dr) {
    docRef = dr;
  }

  void unlink() => docRef = null;

  /// This method must be overridden by properties that wrap
  /// over [List]s. Usually, `list.cast<T>()` will suffice as a concrete
  /// implementation, since those properties will have access to the item type, T,
  /// of the list [R].
  R convertListToR(List<dynamic> list) => list as R;

  void setFromJson(JSON json) {
    if (json.containsKey(key)) {
      final Object? val = json[key];
      if (val == null) {
        // Slightly different from the way [get] is implemented, we don't play around
        // and check for default values and whatnot. If it's not nullable, it should not
        // be null.
        if ((null is! T)) {
          final exc = PropertyException(
            title: PropertyException.nonNullablePropertyGivenNullValue,
            desc:
                "Property [${toString()}] ([$key]) parsed a value of [null] from JSON, when it is not an optional property. Try giving a default value.",
            dataSnapshot: LHDataSnapshot<JSON>(json),
          );
          print(exc.toStorable());
          throw exc;
        }
        _value = null;
      } else {
        if (val is R) {
          set(convertToNative(val as R));
        } else if (val is List) {
          set(convertToNative(convertListToR(val)));
        } else {
          final exc = PropertyException(
            title: PropertyException.propertyGivenNonCompatibleStorableType,
            desc:
                "Property [${toString()}] ([$key]) parsed a value of type [${val.runtimeType}] from JSON, when [$R] was expected.",
            dataSnapshot: LHDataSnapshot<JSON>(json),
          );
          print(exc.toStorable());
          throw exc;
        }
      }
    } else {
      final exc = PropertyException(
        title: PropertyException.propertyKeyNotIncludedInJson,
        desc:
            "Property [${toString()}] could not find key [$key] when parsing JSON. This is considered an error condition. Instead, include the key and set it to null or a default value.",
        dataSnapshot: LHDataSnapshot<JSON>(json),
      );
      print(exc.toStorable());
      throw exc;
    }
  }

  /// If [T] is nullable, return the inner value immediately (case 1).
  /// If [T] is assigned a non-null value, also return that.
  /// Otherwise, the property must be optional, so we look for the [defaultValue] (cases 3 and 4).
  /// Since the only remaining case (case 2) states that "the property is required", we
  /// throw an exception when this case is reached. The form provider must ensure
  /// that the user provides an input to this property, but if [get] is called before
  /// that, this exception will be thrown.
  T get({bool asCheck = false}) {
    if (null is T) return _value as T;
    if (_value != null) {
      return _value!;
    } else {
      if (defaultValue != null) {
        return defaultValue!;
      } else {
        if (asCheck) {
          throw PropertyException(title: '', desc: '');
        } else {
          final exc = PropertyException(
            title: PropertyException
                .strictylRequiredProperty_accessedBeforeAssigned,
            desc:
                "Property [${toString()}] named [$label] is strictly required, but get() was called before a value was provided.",
            dataSnapshot: LHDataSnapshot<Property<T, R>>(this),
          );
          print(exc.toStorable());
          throw exc;
        }
      }
    }
  }

  bool get strictlyRequired {
    try {
      get();
      return true;
    } on PropertyException catch (_) {
      return false;
    }
  }

  /* if (optional) {
        // if T is nullable, return the default value, which can also be null
        if (null is T) {
          return null as T;
        } else {
          // if T is not nullable, but the default value is null (none provided)
          if (defaultValue == null) {
            throw "Property [${toString()}] named [$label] is optional but does not have a default value specified";
          } else {
            // if T is not nullable and the default value is not null, then great!
            return defaultValue!;
          }
        }
      } else {
        throw "Property [${toString()}] named [$label] has not initialised inner value";
      } */

  MapEntry<String, Object?> toJson() => MapEntry(key, toStorable());

  @override
  Object? toStorable() {
    if (_value == null && defaultValue == null) {}
    final v = _value ?? defaultValue;
    return v.isStorable(true);
  }

  @override
  bool operator ==(Object? other) => other is Property && other.key == key;
}

class HiddenProperty<T, R> extends Property<T, R> {
  HiddenProperty(
    super.label, {
    required super.defaultValue,
    super.key,
    super.native,
  });
}

abstract class FormProperty<T, R> extends Property<T, R> {
  FormProperty(
    super.label, {
    required super.defaultValue,
    super.key,
    super.native,
  });

  Widget createComponent(ComponentProvider provider);
}

class TextProperty<T> extends FormProperty<T, String> {
  TextProperty(
    super.label, {
    required super.defaultValue,
    super.key,
    super.native,
  });

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.textField(this, (String text) {
      set(convertToNative(text));
    });
  }
}

class NumProperty<T, N extends num?> extends FormProperty<T, Object> {
  NumProperty(
    super.label, {
    required super.defaultValue,
    super.key,
    required T Function(N) numConverter,
  }) : super(native: (Object input) {
          if (input is String) {
            if (equalsType<N, int?>()) {
              return numConverter(int.parse(input) as N);
            } else if (equalsType<N, double?>()) {
              return numConverter(double.parse(input) as N);
            } else {
              throw "NumProperty ($label) toNative exception (${input.runtimeType}) >> (${N.toString()})";
            }
          } else if (input is int || input is double) {
            return numConverter(input as N);
          } else {
            throw "NumProperty ($label) toNative exception (${input.runtimeType}) >> (${N.toString()})";
          }
        });

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.numberField(this, (String text) {
      set(convertToNative(text));
    });
  }
}

class MultiSelectProperty<T> extends FormProperty<List<T>, List<String>> {
  final List<T> options;
  MultiSelectProperty(
    super.label, {
    required this.options,
    required super.defaultValue,
    super.key,
    super.native,
  });

  @override
  List<String> convertListToR(List list) => list.cast<String>();

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.multiDropdown<T>(this, (List<String> selections) {
      set(convertToNative(selections));
    });
  }
}

class SingleSelectProperty<T> extends FormProperty<T, String> {
  final List<T> options;

  SingleSelectProperty(
    super.label, {
    required this.options,
    required super.defaultValue,
    super.key,
    super.native,
  });

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.singleDropdown(this, (String selection) {
      set(convertToNative(selection));
    });
  }
}

class DateTimeProperty extends FormProperty<DateTime?, Object?> {
  DateTimeProperty(
    super.label, {
    super.key,
  }) : super(
            defaultValue: null,
            native: (Object? input) {
              if (input == null) return null;
              if (input is String) {
                return DateTime.parse(input);
              } else if (input is int) {
                return DateTime.fromMillisecondsSinceEpoch(input * 60000);
              }
            });

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.datePicker(this, (String dtString) {
      set(convertToNative(dtString));
    });
  }
}

class ExpandableProperty<T> extends FormProperty<T, dynamic> {
  final List<FormProperty> properties;

  ExpandableProperty(
    super.label, {
    required this.properties,
    required super.defaultValue,
    super.key,
    super.native,
  });

  @override
  Widget createComponent(ComponentProvider provider) =>
      provider.expandableSection(this, properties);
}

class PropertyException extends LHCoreException {
  PropertyException({
    required super.title,
    required super.desc,
    super.dataSnapshot,
  }) : super(componentId: LighthouseCoreComponent.lhcore_db_property);

  static String strictylRequiredProperty_accessedBeforeAssigned =
      "Failed to access data of a required field because a value was not assigned to it yet";
  static String propertyKeyNotIncludedInJson =
      "Failed to extract property values from JSON because the key was not found";
  static String nonNullablePropertyGivenNullValue =
      "Failed to extract property values from JSON because a null value was provided to a non-nullable property";
  static String propertyGivenNonCompatibleStorableType =
      "Failed to extract property values from JSON because the wrong Storable type was provided by the JSON field";
}
