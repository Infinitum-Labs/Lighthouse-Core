part of lh.core.db;

abstract class Storable {
  const Storable();

  Object? toStorable();
}

abstract class SingleElement<T> extends Storable {
  const SingleElement();

  @override
  Object? toStorable() => convert();

  T convert();
}

abstract class SchemaObject extends Storable {
  final String title;
  final String prefix;
  final String objectId;

  SchemaObject({
    required this.title,
    required String userKey,
    required this.prefix,
  }) : objectId = ObjectID.generate(prefix, userKey);

  SchemaObject.fromJson(JSON json)
      : title = json['title'] as String,
        prefix = json['prefix'] as String,
        objectId = json['objectId'] as String;

  @override
  Object? toStorable() => toJson();

  @mustCallSuper
  Map<String, dynamic> toJson() {
    return {
      'prefix': prefix,
      'objectId': objectId,
      'title': title,
    };
  }
}
