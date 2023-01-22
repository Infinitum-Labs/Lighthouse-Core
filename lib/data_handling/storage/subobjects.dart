part of core.data_handling.storage;

class SubObject {
  factory SubObject.fromJSON(JSON json) {
    switch (json['type']) {
      case 'object_revision':
        return ObjectRevision.fromJSON(json);
      case 'meta_tag':
        return MetaTag.fromJSON(json);
      default:
        throw "FormatError: JSON does not specify a valid SubObject";
    }
  }
}

class ObjectRevision implements SubObject {
  final JSON
      json; // Does not refer to its own JSON data, but that of the object it is tracking
  final DateTime creationDate;

  ObjectRevision.fromJSON(JSON objJSON)
      : json = objJSON,
        creationDate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(objJSON['creationDate'].toString()));
}

class Permission implements SubObject {}

class MetaTag implements SubObject {
  final JSON json;
  final String? area;
  final String value;

  MetaTag.fromJSON(JSON objJSON)
      : json = objJSON,
        area = objJSON['area'] as String?,
        value = objJSON['value'] as String;
}
