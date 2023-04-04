library core.model.db;

import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance
  ..useFirestoreEmulator(
    '127.0.0.1',
    8080,
  );
