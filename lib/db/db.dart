library lh.core.db;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_core/utils/utils.dart';

part './natives.dart';
part './storable.dart';

/// This DB class is NOT a service. It is only meant to be used by the app,
/// since it will not check for permissions before making requests.
class DB {
  static final FirebaseFirestore db = FirebaseFirestore.instance
    ..useFirestoreEmulator(
      '127.0.0.1',
      8080,
    );
  static Future<void> init(FirebaseOptions webOptions) async {
    await Firebase.initializeApp(
      options: webOptions,
    );
    await db.enablePersistence();
  }

  static T loadNative<T extends Storable>(JSON json) {
    switch (json['prefix']) {
      case 'wb':
        return Workbench.fromJson(json) as T;
      case 'go':
        return Goal.fromJson(json) as T;
      case 'pj':
        return Project.fromJson(json) as T;
      case 'ep':
        return Epic.fromJson(json) as T;
      case 'sp':
        return Sprint.fromJson(json) as T;
      case 'tk':
        return Task.fromJson(json) as T;
      case 'ev':
        return Event.fromJson(json) as T;
      default:
        throw DBException(
          title: DBException.loadNativeFailed_PrefixNotRecog,
          desc: "The prefix ${json['prefix']} was not recognised",
          dataSnapshot: LHDataSnapshot<JSON>(json),
        );
    }
  }
}

class DBException extends LHCoreException {
  DBException({
    required super.title,
    required super.desc,
    super.dataSnapshot,
  }) : super(componentId: LighthouseCoreComponent.lhcore_db_db);

  static const String loadNativeFailed_PrefixNotRecog =
      "Failed to load native object from DB json";
}
