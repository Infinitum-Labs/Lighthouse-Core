part of core.data_handling.storage;

enum TriageState {
  inbox,
  triaged,
  scheduled,
  underway,
  archived,
}

enum ProjectType {
  shortTerm,
  longTerm,
}

enum IssueSeverity {
  minimal,
  minor,
  significant,
  critical,
}

abstract class StandardTable extends Table {
  final TableField<FixedStack<ObjectRevision>> revisions =
      TableField('revisions');

  StandardTable(super.name) {
    fields.addAll({'revisions': revisions});
  }
}

class UsersTable extends StandardTable {
  final TableField<String> userName = TableField('userName');
  final TableField<String> emailAddress = TableField('emailAddress');
  final TableField<String> password = TableField('password');
  final TableField<String> workbenchId = TableField('workbenchId');
  final TableField<List<Role>> roles = TableField('roles');
  final TableField<String> userKey = TableField('userKey');

  UsersTable() : super('users') {
    fields.addAll({
      'userName': userName,
      'emailAddress': emailAddress,
      'password': password,
      'workbenchId': workbenchId,
      'roles': roles,
      'userKey': userKey,
    });
  }
}

class WorkbenchesTable extends StandardTable {
  final TableField<JSON> revisionTracker = TableField('revisionTracker');
  final TableField<List<ObjectId>> projects = TableField('projects');
  final TableField<List<ContextRequirement>> contextRequirements =
      TableField('contextRequirements');
  final TableField<List<MetaTag>> metaTags = TableField('metaTags');

  WorkbenchesTable() : super('workbench') {
    fields.addAll({
      'projects': projects,
      'revisionTracker': revisionTracker,
      'contextRequirements': contextRequirements,
      'metaTags': metaTags,
    });
  }

  Future<void> markAsCreation(JSON json) async {
    getIndexesWhere(TableQuery(Storage.workbench)
      ..addFilter<ObjectId>(
          'objectId', (ObjectId obId) => obId == Storage.workbenchId));
  }

  Future<void> markAsUpdate(JSON json) async {}

  Future<void> markAsDeletion(JSON json) async {}
}

class GoalsTable extends StandardTable {
  final TableField<String> title = TableField('title');
  final TableField<double> value = TableField('value');
  final TableField<String> description = TableField('description');
  final TableField<List<ObjectId>> projects = TableField('projects');

  GoalsTable() : super('goals') {
    fields.addAll({
      'title': title,
      'value': value,
      'description': description,
      'projects': projects,
    });
  }
}

class ProjectsTable extends StandardTable {
  final TableField<String> title = TableField('title');
  final TableField<String> description = TableField('description');
  final TableField<List<String>> epics = TableField('epics');
  final TableField<ProjectType> type = TableField('type');

  ProjectsTable() : super('projects') {
    fields.addAll({
      'title': title,
      'description': description,
      'epics': epics,
      'type': type,
    });
  }
}

class EpicsTable extends StandardTable {
  final TableField<String> title = TableField('title');
  final TableField<String> objective = TableField('objective');
  final TableField<List<ObjectId>> tasks = TableField('tasks');
  final TableField<TriageState> triageState = TableField('triageState');

  EpicsTable() : super('epics') {
    fields.addAll({
      'title': title,
      'objective': objective,
      'tasks': tasks,
      'triageState': triageState,
    });
  }
}

class SprintsTable extends StandardTable {
  final TableField<String> title = TableField('title');
  final TableField<DateTime> startDate = TableField('startDate');
  final TableField<DateTime> endDate = TableField('endDate');
  final TableField<List<ObjectId>> epics = TableField('epics');
  final TableField<TriageState> triageState = TableField('triageState');

  SprintsTable() : super('sprints') {
    fields.addAll({
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'epics': epics,
      'triageState': triageState,
    });
  }
}

class TasksTable extends StandardTable {
  final TableField<String> title = TableField('title');
  final TableField<String> description = TableField('description');
  final TableField<TriageState> triageState = TableField('triageState');
  final TableField<DateTime> dueDate = TableField('dueDate');
  final TableField<Duration> duration = TableField('duration');
  final TableField<ObjectId> event = TableField('event');
  final TableField<List<ObjectId>> issues = TableField('issues');
  final TableField<List<MetaTag>> metaTags = TableField('metaTags');
  final TableField<List<ObjectId>> dependencies = TableField('dependencies');

  TasksTable() : super('tasks') {
    fields.addAll({
      'title': title,
      'description': description,
      'triageState': triageState,
      'dueDate': dueDate,
      'event': event,
      'issues': issues,
      'metaTags': metaTags,
      'dependencies': dependencies,
    });
  }
}

class EventsTable extends StandardTable {
  final TableField<String> title = TableField('title');
  final TableField<String> description = TableField('description');
  final TableField<String> calendar = TableField('calendar');
  final TableField<DateTime> startDate = TableField('startDate');
  final TableField<DateTime> endDate = TableField('endDate');
  final TableField<List<DateTime>> followUps = TableField('followUps');
  final TableField<List<DateTime>> reminders = TableField('reminders');
  final TableField<Duration> travelTime = TableField('travelTime');
  final TableField<Duration> trackedTime = TableField('trackedTime');
  final TableField<String> conditionReference =
      TableField('conditionReference');

  EventsTable() : super('events') {
    fields.addAll({
      'title': title,
      'description': description,
      'calendar': calendar,
      'startDate': startDate,
      'endDate': endDate,
      'followUps': followUps,
      'reminders': reminders,
      'travelTime': travelTime,
      'trackedTime': trackedTime,
      'conditionReference': conditionReference,
    });
  }
}

class IssuesTable extends StandardTable {
  final TableField<String> title = TableField('title');
  final TableField<String> description = TableField('description');
  final TableField<IssueSeverity> issueSeverity = TableField('issueSeverity');
  final TableField<List<ObjectId>> thread = TableField('thread');

  IssuesTable() : super('issues') {
    fields.addAll({
      'title': title,
      'description': description,
      'issueSeverity': issueSeverity,
      'thread': thread,
    });
  }
}

class PrototypesTable extends StandardTable {
  final TableField<String> title = TableField('title');
  final TableField<List<Role>> roles = TableField('roles');
  final TableField<List<Component>> actions = TableField('actions');

  PrototypesTable() : super('prototypes') {
    fields.addAll({
      'title': title,
      'roles': roles,
      'actions': actions,
    });
  }
}

extension ListUtils<T extends Enum> on List<T> {
  List<String> stringify() => map((T value) => value.name).toList();
  T asEnum(String value) => firstWhere((T element) => element.name == value);
}
