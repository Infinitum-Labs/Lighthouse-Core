import 'package:flutter/material.dart';
import 'package:lighthouse_core/db/db.dart';
import 'package:lighthouse_core/db/firebase_configs.dart';

import './dev_temp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.init(webOptions);

  await Future.delayed(
    const Duration(seconds: 10),
    () async => Workbench(
      userName: 'johnbap',
      projects: [],
      sprints: [],
      tasks: [],
      epics: [],
      events: [],
      goals: [],
      bin: [],
      userKey: 'jb',
    ),
  );
  // runApp(const App());
}
