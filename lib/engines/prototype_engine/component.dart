part of core.engines.prototype_engine;

class Parameter<T> {
  final bool required;
  final T? defaultValue;

  const Parameter({this.required = false, this.defaultValue});

  JSON toJson() {
    return {
      "type": "parameter",
      'required': required,
      'defaultValue': defaultValue,
    };
  }
}

abstract class Component<T> {
  final String token;
  final List<String> tags;
  final List<Permission> permissions;
  final Map<String, Parameter> parameters;
  final Type outputType = T;

  Component({
    required this.token,
    required this.tags,
    this.permissions = const [],
    this.parameters = const {},
  });

  T run(ExecutionEnvironment env);

  JSON toJSON() {
    return {
      'token': token,
      'tags': tags,
      'permissions': permissions,
      'parameters': parameters,
      'outputType': outputType,
    };
  }

  @override
  String toString();
}
