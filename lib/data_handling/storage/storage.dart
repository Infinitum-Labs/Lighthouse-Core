library core.data_handling.storage;

import 'package:lighthouse_core/data_handling/data_handling.dart';

import '../../authorization/authorization.dart';
import '../../engines/context_engine/context_engine.dart';
import '../../engines/prototype_engine/prototype_engine.dart';
import '../transfer/transfer.dart';
import 'package:lighthouse_core/utils/utils.dart';

part './fixed_stack.dart';
part './table.dart';
part './standard_table.dart';
part './subobjects.dart';

class Storage {
  static final BinTable bin = BinTable();
  static final UsersTable users = UsersTable();
  static final WorkbenchesTable workbench = WorkbenchesTable();
  static final GoalsTable goals = GoalsTable();
  static final ProjectsTable projects = ProjectsTable();
  static final EpicsTable epics = EpicsTable();
  static final SprintsTable sprints = SprintsTable();
  static final TasksTable tasks = TasksTable();
  static final EventsTable events = EventsTable();
  static final IssuesTable issues = IssuesTable();
  static final PrototypesTable prototypes = PrototypesTable();
  static late ObjectId userId;
  static late ObjectId workbenchId;

  static void init(ObjectId usrId) {
    userId = usrId;
    Synchroniser.init();
  }

  static void deinit() {
    Synchroniser.deinit();
  }

  static final Map<String, Table> tables = {
    'bin': bin,
    'users': users,
    'workbench': workbench,
    'goals': goals,
    'projects': projects,
    'epics': epics,
    'sprints': sprints,
    'tasks': tasks,
    'events': events,
    'issues': issues,
    'prototypes': prototypes,
  };

  static Future<void> cascadeData(Map<String, List<JSON>> data) async {}
}
