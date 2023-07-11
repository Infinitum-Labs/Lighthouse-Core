library core.model.db;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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
}
