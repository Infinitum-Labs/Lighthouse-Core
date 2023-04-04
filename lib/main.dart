import 'package:flutter/material.dart';
import 'package:lighthouse_core/db/firebase_configs.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: webOptions,
  );
}
