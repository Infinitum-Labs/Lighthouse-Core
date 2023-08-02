part of core.tools;

class SchemaGen {
  static List<String> printSchemaForSpecs(List<SchemaSpec> specs) =>
      [for (SchemaSpec spec in specs) spec.createClass()];
}

class SchemaSpec {
  final Map<String, Type> props;
  final String specName;
  final String prefix;
  final bool extendsSchemaObject;

  const SchemaSpec({
    required this.specName,
    required this.prefix,
    required this.props,
    this.extendsSchemaObject = true,
  });

  String createClass() {
    final List<String> propFields = [];
    final List<String> propParams = [];
    final List<String> jsonProps = [];
    final List<String> jsonFields = [];
    for (MapEntry<String, Type> entry in props.entries) {
      propFields.add("final ${entry.value} ${entry.key};");
      propParams.add("required this.${entry.key},");
      jsonProps.add("${entry.key} = json['${entry.key}'] as ${entry.value},");
      jsonFields.add("'${entry.key}': ${entry.key},");
    }

    return """class $specName ${extendsSchemaObject ? 'extends SchemaObject' : ''} {
  
${propFields.join('\n')}

  $specName({
  ${propParams.join('\n')}
  required super.userKey,
  }) : super(prefix: '$prefix');

  $specName.fromJson(JSON json)
      : 
        ${jsonProps.join('\n')}
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      ${jsonFields.join('\n')}
    };
  }
}
      """;
  }
}
