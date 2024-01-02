library lh.core.db;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_core/db/firebase_configs.dart';
import 'package:lighthouse_core/utils/utils.dart';

part './natives.dart';
part './storable.dart';
part './property.dart';
part './view_data_binders/data_binding.dart';
part './view_data_binders/component_provider.dart';

/// This DB class is NOT a service. It is only meant to be used by the app,
/// since it will not check for permissions before making requests.
class DB {
  static final FirebaseFirestore db = FirebaseFirestore.instance
    ..useFirestoreEmulator(
      '127.0.0.1',
      8080,
    );
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: webOptions,
    );
    await db.enablePersistence();
  }

  static final CollectionReference<Workbench> workbenchesColl = db
      .collection('workbenches')
      .withConverter(
          fromFirestore: (snapshot, _) =>
              loadNative<Workbench>(snapshot.data()!),
          toFirestore: (workbench, _) => workbench.toJson());

  static final CollectionReference<Goal> goalsColl = db
      .collection('goals')
      .withConverter(
          fromFirestore: (snapshot, _) => loadNative<Goal>(snapshot.data()!),
          toFirestore: (goal, _) => goal.toJson());

  static final CollectionReference<Project> projectsColl = db
      .collection('projects')
      .withConverter(
          fromFirestore: (snapshot, _) => loadNative<Project>(snapshot.data()!),
          toFirestore: (project, _) => project.toJson());

  static final CollectionReference<Epic> epicsColl = db
      .collection('epics')
      .withConverter(
          fromFirestore: (snapshot, _) => loadNative<Epic>(snapshot.data()!),
          toFirestore: (epic, _) => epic.toJson());

  static final CollectionReference<Sprint> sprintsColl = db
      .collection('sprints')
      .withConverter(
          fromFirestore: (snapshot, _) => loadNative<Sprint>(snapshot.data()!),
          toFirestore: (sprint, _) => sprint.toJson());

  static final CollectionReference<Task> tasksColl = db
      .collection('tasks')
      .withConverter(
          fromFirestore: (snapshot, _) => loadNative<Task>(snapshot.data()!),
          toFirestore: (task, _) => task.toJson());

  static final CollectionReference<Event> eventsColl = db
      .collection('events')
      .withConverter(
          fromFirestore: (snapshot, _) => loadNative<Event>(snapshot.data()!),
          toFirestore: (event, _) => event.toJson());

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
