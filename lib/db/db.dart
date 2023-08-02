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
      default:
        throw "";
    }
  }

  static JSON loadJsonFrom<T extends SchemaObject>(T obj) => obj.toJson();
}
