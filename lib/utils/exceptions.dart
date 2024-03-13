part of core.utils;

enum LighthouseCoreComponent {
  lhcore_utils_utils,
  lhcore_utils_types,
  lhcore_db_db,
  lhcore_db_property,
}

abstract class LighthouseException extends Storable implements Exception {
  final String exceptionId = ObjectID.generateAlphaNumString(16);
  final DateTime timestamp = DateTime.now();
  final String title;
  final String desc;
  final LHDataSnapshot? dataSnapshot;

  LighthouseException({
    required this.title,
    required this.desc,
    this.dataSnapshot,
  });

  @override
  Object? toStorable() {
    return {
      'exceptionId': exceptionId,
      'timestamp': timestamp.toStorable(),
      'title': title,
      'desc': desc,
      if (dataSnapshot != null) 'savedData': dataSnapshot!.toStorable(),
    };
  }
}

abstract class LHCoreException extends LighthouseException {
  final LighthouseCoreComponent componentId;

  LHCoreException({
    required this.componentId,
    required super.title,
    required super.desc,
    super.dataSnapshot,
  });
}

class LHDataSnapshot<T> extends Storable {
  final T data;

  const LHDataSnapshot(this.data);

  @override
  Object? toStorable() {
    if (data is Storable) {
      return (data as Storable).toStorable();
    } else if (data.isNative) {
      return data;
    } else {
      return data.toString();
    }
  }
}

class InsufficientPermsException {
  final Set<Permission> missingPerms;
  const InsufficientPermsException(this.missingPerms);
}
