part of lh.core.db;

/// A Schema property of native type [T] and represented type [R] in forms
abstract class Property<T, R> implements Storable {
  final String label;
  final String _key;
  final T Function(R) convert;
  late final T _value;
  final R? defaultValue;
  final bool optional;

  Property(
    this.label, {
    this.optional = false,
    this.defaultValue,
    T Function(R)? converter,
    String? key,
  })  : convert = converter ?? ((R r) => r as T),
        _key = key ?? label.toCamelCase();

  void set(T value) => _value = value;

  T get() {
    try {
      return _value;
    } catch (e) {
      if (optional) {
        if (defaultValue != null) {
          return convert(defaultValue!);
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
    super.converter,
  });
}

abstract class FormProperty<T, R> extends Property<T, R> {
  FormProperty(
    super.label, {
    super.optional,
    super.defaultValue,
    super.key,
    super.converter,
  });

  Widget createComponent(ComponentProvider provider);
}

class TextProperty<T> extends FormProperty<T, String> {
  TextProperty(
    super.label, {
    super.optional,
    super.defaultValue,
    super.key,
    super.converter,
  });

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.textField((String text) {
      set(convert(text));
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
  }) : super(converter: (String input) {
          if (N is int) {
            return numConverter(int.parse(input) as N);
          } else {
            return numConverter(double.parse(input) as N);
          }
        });

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.numberField((String text) {
      set(convert(text));
    });
  }
}

class MultiSelectProperty<T, R> extends FormProperty<T, R> {
  MultiSelectProperty(
    super.label, {
    super.optional,
    super.defaultValue,
    super.key,
    super.converter,
  });

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.multiDropdown((R selection) {
      set(convert(selection));
    });
  }
}

class SingleSelectProperty<T, R> extends FormProperty<T, R> {
  SingleSelectProperty(
    super.label, {
    super.optional,
    super.defaultValue,
    super.key,
    super.converter,
  });

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.singleDropdown((R selection) {
      set(convert(selection));
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
          converter: (String? input) =>
              input != null ? DateTime.parse(input) : null,
        );

  @override
  Widget createComponent(ComponentProvider provider) {
    return provider.datePicker((String dtString) {
      set(convert(dtString));
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
    super.converter,
  });

  @override
  Widget createComponent(ComponentProvider provider) =>
      provider.expandableSection(properties);
}
