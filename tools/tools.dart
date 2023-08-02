library core.tools;

import 'package:lighthouse_core/db/db.dart';

part './schema_gen.dart';

void main(List<String> args) {
  const List<SchemaSpec> specs = [
    SchemaSpec(
      specName: 'Workbench',
      prefix: 'wb',
      props: {
        'userName': String,
        'projects': List<String>,
        'goals': List<String>,
        'tasks': List<String>,
        'epics': List<String>,
        'sprints': List<String>,
        'events': List<String>,
        'bin': List<String>,
      },
    ),
    SchemaSpec(
      specName: 'Goal',
      prefix: 'go',
      props: {
        'value': double,
      },
    ),
    SchemaSpec(
      specName: 'Project',
      prefix: 'pj',
      props: {
        'goals': List<String>,
        'epics': List<String>,
      },
    ),
    SchemaSpec(
      specName: 'Epic',
      prefix: 'ep',
      props: {
        'tasks': List<String>,
        'project': String,
      },
    ),
    SchemaSpec(
      specName: 'Sprint',
      prefix: 'sp',
      props: {
        'tasks': List<String>,
        'status': SprintStatus,
        'start': DateTime,
        'end': DateTime,
      },
    ),
    SchemaSpec(
      specName: 'Task',
      prefix: 'tk',
      props: {
        'description': String,
        'dependencies': List<Dependency>,
        'status': TaskStatus,
        'due': DateTime,
        'assigned': DateTime,
        'duration': Duration,
        'load': double,
        'contexts': List<ContextLabel>,
        'epic': String,
        'sprint': String,
        'project': String,
      },
    ),
    SchemaSpec(
      specName: 'Event',
      prefix: 'ev',
      props: {
        'description': String,
        'task': String,
        'start': DateTime,
        'duration': DateTime,
      },
    ),
  ];

  print(SchemaGen.printSchemaForSpecs(specs).join('\n\n'));
}
