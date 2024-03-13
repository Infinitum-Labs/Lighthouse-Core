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
  final List<Property> properties = [];
  final title = TextProperty<String>('Title', key: 'title', defaultValue: null);
  final prefix = HiddenProperty<String, String>('prefix', defaultValue: null);
  final objectId = HiddenProperty<String, String>('objectId',
      key: 'objectId', defaultValue: null);

  SchemaObject({
    required String userKey,
    required String objectPrefix,
  }) {
    prefix.set(objectPrefix);
    objectId.set(ObjectID.generate(prefix.get(), userKey));
    properties.addAll([title, prefix, objectId]);
  }

  SchemaObject.fromJson(JSON json) {
    title.set(json.get<String>('title'));
    prefix.set(json.get<String>('prefix'));
    objectId.set(json.get<String>('objectId'));
    properties.addAll([title, prefix, objectId]);
  }

  @override
  Object? toStorable() => toJson();

  @mustCallSuper
  Map<String, dynamic> toJson() =>
      Map.fromEntries([for (Property p in properties) p.toJson()]);
}

extension DTStorable on DateTime {
  static DateTime fromStorable(int minutes) =>
      DateTime.fromMillisecondsSinceEpoch(minutes * dtConvConst);
  Object? toStorable() => minutesSinceEpoch;
}

extension DurationStorable on Duration {
  static Duration fromStorable(int minutes) => Duration(minutes: minutes);
  Object? toStorable() => inMinutes;
}

extension StorableListUtils on List<Storable> {
  List<Object?> toStorableList() => map((e) => e.toStorable()).toList();
}
