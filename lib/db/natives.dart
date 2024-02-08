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
  final tasks = MultiSelectProperty<String>('Tasks', options: []);
  final dependencyType = SingleSelectProperty<DependencyType>(
    'Dependency Type',
    key: 'dependencyType',
    options: DependencyType.values,
    toNative: DependencyType.fromString,
    toStorable: (item) => item.toStorable(),
  );

  Dependency({
    required super.userKey,
    required super.objectTitle,
  }) : super(objectPrefix: 'de') {
    properties.addAll([tasks, dependencyType]);
  }

  Dependency.fromJson(JSON json) : super.fromJson(json) {
    tasks.set(json.getList('tasks').listOf<String>((val) => val.toString()));
    dependencyType
        .set(DependencyType.fromString(json.get<String>('dependencyType')));
  }
}

class Workbench extends SchemaObject {
  final userName = TextProperty<String>('Username', key: 'userName');
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
    required super.objectTitle,
  }) : super(objectPrefix: 'wb') {
    properties.addAll(
        [userName, projects, goals, tasks, epics, sprints, events, bin]);
  }

  Workbench.fromJson(JSON json) : super.fromJson(json) {
    userName.set(json.get<String>('userName'));
    projects
        .set(json.getList('projects').listOf<String>((val) => val.toString()));
    goals.set(json.getList('goals').listOf<String>((val) => val.toString()));
    tasks.set(json.getList('tasks').listOf<String>((val) => val.toString()));
    epics.set(json.getList('epics').listOf<String>((val) => val.toString()));
    sprints
        .set(json.getList('sprints').listOf<String>((val) => val.toString()));
    events.set(json.getList('events').listOf<String>((val) => val.toString()));
    bin.set(json.getList('bin').listOf<String>((val) => val.toString()));
    properties.addAll(
        [userName, projects, goals, tasks, epics, sprints, events, bin]);
  }
}

class Goal extends SchemaObject {
  final value = NumProperty<double, double>('Value', numConverter: (n) => n);

  Goal({
    required super.userKey,
    required super.objectTitle,
  }) : super(objectPrefix: 'go') {
    properties.add(value);
  }

  Goal.fromJson(JSON json) : super.fromJson(json) {
    value.set(json.get<double>('value'));
    properties.add(value);
  }
}

class Project extends SchemaObject {
  final goals = MultiSelectProperty<String>(
    'Goals',
    options: [],
  );
  final epics = MultiSelectProperty<String>('Epics',
      optional: true, options: [], defaultValue: []);

  Project({
    required super.userKey,
    required super.objectTitle,
  }) : super(objectPrefix: 'pj') {
    properties.addAll([goals, epics]);
  }

  Project.fromJson(JSON json) : super.fromJson(json) {
    goals.set(json.getList('goals').listOf<String>((val) => val.toString()));
    epics.set(json.getList('epics').listOf<String>((val) => val.toString()));
    properties.addAll([goals, epics]);
  }
}

class Epic extends SchemaObject {
  final tasks = MultiSelectProperty<String>(
    'Tasks',
    optional: true,
    options: [],
    defaultValue: [],
  );
  final project = SingleSelectProperty<String>('Project', options: []);

  Epic({
    required super.userKey,
    required super.objectTitle,
  }) : super(objectPrefix: 'ep') {
    properties.addAll([tasks, project]);
  }

  Epic.fromJson(JSON json) : super.fromJson(json) {
    tasks.set(json.getList('tasks').listOf<String>((val) => val.toString()));
    project.set(json.get<String>('project'));
    properties.addAll([tasks, project]);
  }
}

class Sprint extends SchemaObject {
  final tasks = MultiSelectProperty<String>('Tasks',
      options: [], optional: true, defaultValue: []);
  final status = SingleSelectProperty<SprintStatus>(
    'Status',
    optional: true,
    options: SprintStatus.values,
    defaultValue: SprintStatus.inbox,
    toNative: SprintStatus.fromString,
    toStorable: (item) => item.toStorable(),
  );
  final start = DateTimeProperty('Start');
  final end = DateTimeProperty('End');

  Sprint({
    required super.userKey,
    required super.objectTitle,
  }) : super(objectPrefix: 'sp') {
    properties.addAll([tasks, start, start, end]);
  }

  Sprint.fromJson(JSON json) : super.fromJson(json) {
    tasks.set(json.getList('tasks').listOf<String>((val) => val.toString()));
    status.set(SprintStatus.fromString(json.get<String>('status')));
    start.set(DTStorable.fromStorable(json.get<int>('start')));
    end.set(DTStorable.fromStorable(json.get<int>('end')));
  }
}

class Task extends SchemaObject {
  final description = TextProperty<String?>('Description', optional: true);

  /// Possible error with this property not specifying toStorable/toNative
  final dependencies = MultiSelectProperty<String>(
    'Dependencies',
    optional: true,
    options: [],
    defaultValue: [],
  );
  final status = SingleSelectProperty<TaskStatus>(
    'Status',
    optional: true,
    options: TaskStatus.values,
    defaultValue: TaskStatus.inbox,
    toNative: TaskStatus.fromString,
    toStorable: (item) => item.toStorable(),
  );
  final due = DateTimeProperty(
    'Due Date',
    optional: true,
    key: 'due',
  );

  final assigned = DateTimeProperty(
    'Assigned Date',
    optional: true,
    key: 'assigned',
  );

  final duration = NumProperty<Duration?, int?>(
    'Duration',
    optional: true,
    numConverter: (minutes) =>
        minutes != null ? DurationStorable.fromStorable(minutes) : null,
  );

  final load = NumProperty<double?, double?>(
    'Estimated Load',
    optional: true,
    defaultValue: null,
    key: 'load',
    numConverter: (n) => n,
  );

  final contexts = MultiSelectProperty<String>(
    'Context Labels',
    optional: true,
    options: [],
    defaultValue: [],
    key: 'contexts',
  );

  final epic = TextProperty<String?>('Epic', optional: true);
  final sprint = TextProperty<String?>('Sprint', optional: true);
  final project = TextProperty<String?>('Project', optional: true);

  Task({
    required super.userKey,
    required super.objectTitle,
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
    description.set(json.getOrNull<String>('description'));
    dependencies.set(
        json.getList('dependencies').listOf<String>((val) => val.toString()));
    status.set(TaskStatus.fromString(json.get<String>('status')));
    due.set(json.containsKey('due')
        ? DTStorable.fromStorable(json.get<int>('due'))
        : null);
    assigned.set(json.containsKey('assigned')
        ? DTStorable.fromStorable(json.get<int>('assigned'))
        : null);
    duration.set(json.containsKey('duration')
        ? DurationStorable.fromStorable(json.get<int>('duration'))
        : null);
    load.set(json.containsKey('load') ? json.get<double>('load') : null);
    contexts
        .set(json.getList('contexts').listOf<String>((val) => val.toString()));
    epic.set(json.getOrNull<String>('epic'));
    sprint.set(json.get<String>('sprint'));
    project.set(json.get<String>('project'));
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
  final description = TextProperty<String?>(
    'Description',
    optional: true,
  );
  final task = TextProperty<String?>(
    'Task',
    optional: true,
  );
  final start = DateTimeProperty('Start');

  final duration = NumProperty<int?, int?>(
    'Duration',
    optional: true,
    numConverter: (n) => n,
  );

  final repeatRule = ExpandableProperty(
    'Repeat Rule',
    key: 'repeatRule',
    // converter
    properties: [],
  );

  Event({
    required super.userKey,
    required super.objectTitle,
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
        until = DTStorable.fromStorable(json['until'] as int),
        count = json['count'] as int,
        countUnit = RRCountUnit.fromString(json['countUnit'] as String),
        weekDays = (json['weekDays'] as List)
            .listOf<RRWeekDays>((val) => RRWeekDays.fromString(val));

  @override
  Object? toStorable() {
    return <String, dynamic>{
      'freq': frequency.name,
      if (until != null) 'until': until!.toStorable(),
      if (count != null) 'count': count!,
      if (countUnit != null) 'countUnit': countUnit!.name,
      'weekDays': <String>[
        if (weekDays != null)
          for (RRWeekDays weekdays in weekDays!) weekdays.name
      ],
    };
  }
}
