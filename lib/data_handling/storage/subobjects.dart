part of core.data_handling.storage;

abstract class SubObject {
  static const String object_revision = 'object_revision';
  static const String meta_tag = 'meta_tag';
  static const String revision_tracker = 'revision_tracker';

  factory SubObject.fromJSON(JSON json) {
    switch (json['type']) {
      case object_revision:
        return ObjectRevision.fromJSON(json);
      case meta_tag:
        return MetaTag.fromJSON(json);
      case revision_tracker:
        return RevisionTracker.fromJSON(json);
      default:
        throw "FormatError: SubObject factory >> JSON does not specify a valid SubObject";
    }
  }

  JSON toJson();
}

class ObjectRevision implements SubObject {
  final JSON
      json; // Does not refer to its own JSON data, but that of the object it is tracking
  final DateTime creationDate;

  ObjectRevision.fromJSON(JSON objJSON)
      : json = objJSON,
        creationDate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(objJSON['creationDate'].toString()));

  @override
  JSON toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class RTUpdate {
  final ObjectId objectId;
  final JSON data;
  final int timestamp = DateTime.now().millisecondsSinceEpoch;
  final String collection;

  RTUpdate({required this.collection, required this.data})
      : objectId = data['objectId'] as ObjectId;
}

class RTCreation {
  final String collection;
  final JSON data;
  final ObjectId objectId;

  RTCreation({required this.collection, required this.data})
      : objectId = data['objectId'] as ObjectId;
}

class RTDeletion {
  final String collection;
  final ObjectId objectId;

  const RTDeletion({required this.collection, required this.objectId});
}

class RevisionTracker implements SubObject {
  final Map<String, Map<String, List<JSON>>>
      updates; // { id: { data: JSON, timestamp: DateTime } }
  final Map<String, List<ObjectId>> deletions;
  final Map<String, List<JSON>> creations; // { collection: Data[] }
  final List<ObjectId> creationsList = [];

  RevisionTracker.fromJSON(JSON objJson)
      : updates = objJson['updates'] as Map<String, Map<String, List<JSON>>>,
        deletions = objJson['deletions'] as Map<String, List<ObjectId>>,
        creations = objJson['creations'] as Map<String, List<JSON>>;

  Future<void> markAsCreation(RTCreation rtCreation) async {
    creations[rtCreation.collection]!.add(rtCreation.data);
    creationsList.add(rtCreation.objectId);
  }

  Future<void> markAsUpdate(RTUpdate rtUpdate) async {
    updates[rtUpdate.collection]![rtUpdate.objectId]!.add({
      'data': rtUpdate.data,
      'timestamp': rtUpdate.timestamp,
    });
  }

  Future<void> markAsDeletion(RTDeletion rtDeletion) async {
    if (!creationsList.contains(rtDeletion.objectId)) {
      creationsList.remove(rtDeletion.objectId);
      creations[rtDeletion.collection]!.removeWhere(
        (JSON json) => json.values.first == rtDeletion.objectId,
      );
    } else {
      deletions[rtDeletion.collection]!.add(rtDeletion.objectId);
    }
  }

  @override
  JSON toJson() {
    return {
      'type': SubObject.revision_tracker,
      'updates': updates,
      /**
       * {
       *    collectionName: {
       *            objectId: [
       *                    {
       *                    data: JSON,
       *                    timestamp: int
       *                  }
       *                ]
       *        }
       * }
       */
      'deletions': deletions,
      /**
       * {
       *    collectionName: [
       *          objectId
       *      ]
       * }
       */
      'creations': creations,
      /**
       * {
       *    collectionName: [
       *          objectId
       *      ]
       * }
       */
    };
  }
}

class Permission implements SubObject {
  @override
  JSON toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class MetaTag implements SubObject {
  final JSON json;
  final String? area;
  final String value;

  MetaTag.fromJSON(JSON objJSON)
      : json = objJSON,
        area = objJSON['area'] as String?,
        value = objJSON['value'] as String;
  @override
  JSON toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
