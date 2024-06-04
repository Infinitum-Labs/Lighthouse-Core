part of lh.core.db;

/// The number of milliseconds in a minute
const int dtConvConst = 60000;

enum SprintStatus implements Storable {
  inbox;

  static SprintStatus fromString(String label) =>
      EnumUtils.enumFromString(values, label);

  @override
  String toStorable() => name;
}

enum DependencyType implements Storable {
  isBlocked,
  isBlocking;

  static DependencyType fromString(String label) =>
      EnumUtils.enumFromString(values, label);
  @override
  String toStorable() => name;
}

enum TaskStatus implements Storable {
  inbox;

  static TaskStatus fromString(String label) =>
      EnumUtils.enumFromString(values, label);
  @override
  String toStorable() => name;
}

class Context {
  final String location;
  final double energy;
  final Duration duration;
  final List<String> resources;

  Context({
    required this.location,
    required this.energy,
    required this.duration,
    required this.resources,
  });
}

class ContextLabel extends SingleElement<String> {
  final String contextLabel;

  const ContextLabel(this.contextLabel);

  @override
  String convert() => contextLabel;
}

class Dependency extends SchemaObject {
  final task =
      SingleSelectProperty<String>('Tasks', options: [], defaultValue: null);
  final dependencyType = SingleSelectProperty<DependencyType>(
    'Dependency Type',
    key: 'dependencyType',
    defaultValue: DependencyType.isBlocked,
    options: DependencyType.values,
    native: DependencyType.fromString,
  );

  Dependency({
    required super.userKey,
  }) : super(objectPrefix: 'de') {
    properties.addAll([task, dependencyType]);
  }

  Dependency.fromJson(JSON json) : super.fromJson(json) {
    task.setFromJson(json);
    dependencyType.setFromJson(json);
  }
}

class Workbench extends SchemaObject {
  final userName =
      TextProperty<String>('Username', key: 'userName', defaultValue: null);
  final projects =
      MultiSelectProperty<String>('Projects', options: [], defaultValue: []);
  final goals =
      MultiSelectProperty<String>('Goals', options: [], defaultValue: []);
  final tasks =
      MultiSelectProperty<String>('Tasks', options: [], defaultValue: []);
  final epics =
      MultiSelectProperty<String>('Epics', options: [], defaultValue: []);
  final sprints =
      MultiSelectProperty<String>('Sprints', options: [], defaultValue: []);
  final events =
      MultiSelectProperty<String>('Events', options: [], defaultValue: []);
  final bin =
      HiddenProperty<List<String>, List<String>>('Bin', defaultValue: []);

  Workbench({
    required super.userKey,
  }) : super(objectPrefix: 'wb') {
    properties.addAll(
        [userName, projects, goals, tasks, epics, sprints, events, bin]);
  }

  Workbench.fromJson(JSON json) : super.fromJson(json) {
    userName.setFromJson(json);
    projects.setFromJson(json);
    goals.setFromJson(json);
    tasks.setFromJson(json);
    epics.setFromJson(json);
    sprints.setFromJson(json);
    events.setFromJson(json);
    bin.setFromJson(json);
    properties.addAll(
        [userName, projects, goals, tasks, epics, sprints, events, bin]);
  }
}

class Goal extends SchemaObject {
  final value = NumProperty<double, double>('Value',
      numConverter: (n) => n, defaultValue: 0.6);

  Goal({
    required super.userKey,
  }) : super(objectPrefix: 'go') {
    properties.add(value);
  }

  Goal.fromJson(JSON json) : super.fromJson(json) {
    value.setFromJson(json);
    properties.add(value);
  }
}

class Project extends SchemaObject {
  final goals =
      MultiSelectProperty<String>('Goals', options: [], defaultValue: []);
  final epics =
      MultiSelectProperty<String>('Epics', options: [], defaultValue: []);

  Project({
    required super.userKey,
  }) : super(objectPrefix: 'pj') {
    properties.addAll([goals, epics]);
  }

  Project.fromJson(JSON json) : super.fromJson(json) {
    goals.setFromJson(json);
    epics.setFromJson(json);
    properties.addAll([goals, epics]);
  }
}

class Epic extends SchemaObject {
  final tasks = MultiSelectProperty<String>(
    'Tasks',
    options: [],
    defaultValue: [],
  );
  final project =
      SingleSelectProperty<String?>('Project', options: [], defaultValue: null);

  Epic({
    required super.userKey,
  }) : super(objectPrefix: 'ep') {
    properties.addAll([tasks, project]);
  }

  Epic.fromJson(JSON json) : super.fromJson(json) {
    tasks.setFromJson(json);
    project.setFromJson(json);
    properties.addAll([tasks, project]);
  }
}

class Sprint extends SchemaObject {
  final tasks =
      MultiSelectProperty<String>('Tasks', options: [], defaultValue: []);
  final status = SingleSelectProperty<SprintStatus>(
    'Status',
    options: SprintStatus.values,
    defaultValue: SprintStatus.inbox,
    native: SprintStatus.fromString,
  );
  final start = DateTimeProperty('Start');
  final end = DateTimeProperty('End');

  Sprint({
    required super.userKey,
  }) : super(objectPrefix: 'sp') {
    properties.addAll([tasks, start, start, end]);
  }

  Sprint.fromJson(JSON json) : super.fromJson(json) {
    tasks.setFromJson(json);
    status.setFromJson(json);
    start.setFromJson(json);
    end.setFromJson(json);
  }
}

class Task extends SchemaObject {
  final description = TextProperty<String?>(
    'Description',
    defaultValue: null,
  );

  /// Possible error with this property not specifying toStorable/toNative
  final dependencies = MultiSelectProperty<String>(
    'Dependencies',
    options: [],
    defaultValue: [],
  );
  final status = SingleSelectProperty<TaskStatus>(
    'Status',
    options: TaskStatus.values,
    defaultValue: TaskStatus.inbox,
    native: TaskStatus.fromString,
  );
  final due = DateTimeProperty(
    'Due Date',
    key: 'due',
  );

  final assigned = DateTimeProperty(
    'Assigned Date',
    key: 'assigned',
  );

  final duration = NumProperty<Duration?, int?>(
    'Duration',
    defaultValue: null,
    numConverter: (minutes) =>
        minutes != null ? Duration(minutes: minutes) : null,
  );

  final load = NumProperty<double?, double?>(
    'Estimated Load',
    defaultValue: null,
    key: 'load',
    numConverter: (n) => n,
  );

  final contexts = MultiSelectProperty<String>(
    'Context Labels',
    options: [],
    defaultValue: [],
    key: 'contexts',
  );

  final epic = TextProperty<String?>('Epic', defaultValue: null);
  final sprint = TextProperty<String?>('Sprint', defaultValue: null);
  final project = TextProperty<String?>('Project', defaultValue: null);

  Task({
    required super.userKey,
  }) : super(objectPrefix: 'tk') {
    properties.addAll([
      description,
      dependencies,
      status,
      due,
      assigned,
      duration,
      load,
      contexts,
      epic,
      sprint,
      project,
    ]);
  }

  Task.fromJson(JSON json) : super.fromJson(json) {
    description.setFromJson(json);
    dependencies.setFromJson(json);
    status.setFromJson(json);
    due.setFromJson(json);

    assigned.setFromJson(json);

    duration.setFromJson(json);

    load.setFromJson(json);
    contexts.setFromJson(json);
    epic.setFromJson(json);
    sprint.setFromJson(json);
    project.setFromJson(json);
    properties.addAll([
      description,
      dependencies,
      status,
      due,
      assigned,
      duration,
      load,
      contexts,
      epic,
      sprint,
      project
    ]);
  }
}

class Event extends SchemaObject {
  final description = TextProperty<String?>('Description', defaultValue: null);
  final task = TextProperty<String?>('Task', defaultValue: null);
  final start = DateTimeProperty('Start');

  final duration = NumProperty<int?, int?>(
    'Duration',
    defaultValue: null,
    numConverter: (n) => n,
  );

  final repeatRule = ExpandableProperty(
    'Repeat Rule',
    key: 'repeatRule',
    defaultValue: null,
    // converter
    properties: [],
  );

  Event({
    required super.userKey,
  }) : super(objectPrefix: 'ev');

  Event.fromJson(JSON json) : super.fromJson(json);

  /* 
      : description = json['description'] as String,
        task = json['task'] as String,
        start = DTStorable.fromStorable(json['start'] as int),
        duration = DurationStorable.fromStorable(json['duration'] as int),
        repeatRule = RepeatRule.fromJson(json['repeatRule'] as JSON),
        super.fromJson(json); */
}

enum RRFrequency implements Storable {
  secondly,
  minutely,
  hourly,
  daily,
  weekly,
  monthly,
  yearly;

  static RRFrequency fromString(String label) =>
      EnumUtils.enumFromString(values, label);
  @override
  String toStorable() => name;
}

enum RRCountUnit implements Storable {
  day,
  week,
  month,
  year;

  static RRCountUnit fromString(String label) =>
      EnumUtils.enumFromString(values, label);
  @override
  String toStorable() => name;
}

enum RRWeekDays implements Storable {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static RRWeekDays fromString(String label) =>
      EnumUtils.enumFromString(values, label);
  @override
  String toStorable() => name;
}

/// Based on https://icalendar.org/iCalendar-RFC-5545/3-3-10-recurrence-rule.html
class RepeatRule extends Storable {
  final RRFrequency frequency;

  /// Specify either [until] or [count] only
  final DateTime? until;
  final int? count;

  /// If [countUnit] is [RRCountUnit.week], then [weekDays] must be specified
  final RRCountUnit? countUnit;
  final List<RRWeekDays>? weekDays;

  const RepeatRule({
    required this.frequency,
    this.until,
    this.count,
    this.countUnit,
    this.weekDays,
  });

  RepeatRule.fromJson(JSON json)
      : frequency = RRFrequency.fromString(json['freq'] as String),
        until = DateTime.fromMillisecondsSinceEpoch(
            (json['until'] as int) * dtConvConst),
        count = json['count'] as int,
        countUnit = RRCountUnit.fromString(json['countUnit'] as String),
        weekDays = (json['weekDays'] as List)
            .listOf<RRWeekDays>((val) => RRWeekDays.fromString(val));

  @override
  Object? toStorable() {
    return <String, dynamic>{
      'freq': frequency.name,
      if (until != null) 'until': until!.isStorable(true),
      if (count != null) 'count': count!,
      if (countUnit != null) 'countUnit': countUnit!.name,
      'weekDays': <String>[
        if (weekDays != null)
          for (RRWeekDays weekdays in weekDays!) weekdays.name
      ],
    };
  }
}
