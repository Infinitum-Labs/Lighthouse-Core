part of lh.core.db;

/// A Schema property of native type [T] and represented type [R] in forms
abstract class Property<T, R> implements Storable {
  final String label;
  final String _key;
  final T Function(R) convertToNative;
  final R Function(T) convertToStorable;
  late T _value;
  final T? defaultValue;
  final bool optional;

  Property(
    this.label, {
    this.optional = false,
    this.defaultValue,
    T Function(R)? toNative,
    R Function(T)? toStorable,
    String? key,
  })  : convertToNative = toNative ?? ((R r) => r as T),
        convertToStorable = toStorable ?? ((T t) => t as R),
        _key = key ?? label.toCamelCase();

  void set(T value) => _value = value;

  T get() {
    try {
      return _value;
    } catch (e) {
      if (optional) {
        if (defaultValue != null) {
          return defaultValue!;
        } else {
          throw "Property [${toString()}] named [$label] is optional but does not have a default value specified";
        }
      } else {
        throw "Property [${toString()}] named [$label] has not initialised inner value";
      }
    }
  }

  MapEntry<String, Object?> toJson() => MapEntry(_key, toStorable());

  @override
  Object? toStorable() {
    if (_value is Storable) {
      return (_value as Storable).toStorable();
    } else {
      return _value;
    }
  }

  @override
  bool operator ==(Object? other) => other is Property && other._key == _key;
}

class HiddenProperty<T, R> extends Property<T, R> {
  HiddenProperty(
    super.label, {
    super.optional,
    super.defaultValue,
    super.key,
    super.toNative,
    super.toStorable,
  });
}

abstract class FormProperty<T, R> extends Property<T, R> {
  FormProperty(
    super.label, {
    super.optional,
    super.defaultValue,
    super.key,
    super.toNative,
    super.toStorable,
  });

  Widget createComponent(ComponentProvider provider);
}

class TextProperty<T> extends FormProperty<T, String> {
  TextProperty(
    super.label, {
    super.optional,
    super.defaultValue,
    super.key,
    super.toNative,
    super.toStorable,
  });

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.textField(this, (String text) {
      set(convertToNative(text));
    });
  }
}

class NumProperty<T, N extends num?> extends FormProperty<T, String> {
  NumProperty(
    super.label, {
    super.optional,
    super.defaultValue,
    super.key,
    required T Function(N) numConverter,
  }) : super(toNative: (String input) {
          if (N is int) {
            return numConverter(int.parse(input) as N);
          } else {
            return numConverter(double.parse(input) as N);
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
    super.optional,
    required this.options,
    super.defaultValue,
    super.key,
    super.toNative,
    super.toStorable,
  });

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
    super.optional,
    required this.options,
    super.defaultValue,
    super.key,
    super.toNative,
    super.toStorable,
  });

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.singleDropdown(this, (String selection) {
      set(convertToNative(selection));
    });
  }
}

class DateTimeProperty extends FormProperty<DateTime?, String?> {
  DateTimeProperty(
    super.label, {
    super.optional,
    super.defaultValue,
    super.key,
  }) : super(
          toNative: (String? input) =>
              input != null ? DateTime.parse(input) : null,
        );

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
    super.optional,
    super.defaultValue,
    super.key,
    super.toNative,
    super.toStorable,
  });

  @override
  Widget createComponent(ComponentProvider provider) =>
      provider.expandableSection(this, properties);
}
