part of lh.core.db;

const int dtConvConst = 60000;

enum SprintStatus implements Storable {
  inbox;

  static SprintStatus fromString(String label) =>
      EnumUtils.enumFromString(values, label);

  @override
  String toStorable() => name;
}

enum Dependency implements Storable {
  isBlocked,
  isBlocking;

  static Dependency fromString(String label) =>
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

class ContextLabel extends SingleElement<String> {
  final String contextLabel;

  const ContextLabel(this.contextLabel);

  @override
  String convert() => contextLabel;
}

class DateTimeRep extends SingleElement<int> {
  final DateTime dateTime;
  const DateTimeRep(this.dateTime);

  static DateTimeRep fromStorable(int storable) =>
      DateTimeRep(DateTime.fromMillisecondsSinceEpoch(storable * dtConvConst));

  @override
  int convert() => (dateTime.millisecondsSinceEpoch / dtConvConst).round();
}

class DurationRep extends SingleElement<int> {
  final Duration duration;
  const DurationRep(this.duration);

  static DurationRep fromStorable(int storable) =>
      DurationRep(Duration(minutes: storable * dtConvConst));

  @override
  int convert() => duration.inMinutes;
}

class Workbench extends SchemaObject {
  final String userName;
  final List<String> projects;
  final List<String> goals;
  final List<String> tasks;
  final List<String> epics;
  final List<String> sprints;
  final List<String> events;
  final List<String> bin;

  Workbench({
    required this.userName,
    required this.projects,
    required this.goals,
    required this.tasks,
    required this.epics,
    required this.sprints,
    required this.events,
    required this.bin,
    required super.userKey,
    required super.title,
  }) : super(prefix: 'wb');

  Workbench.fromJson(JSON json)
      : userName = json['userName'] as String,
        projects =
            (json['projects'] as List).listOf<String>((val) => val.toString()),
        goals = (json['goals'] as List).listOf<String>((val) => val.toString()),
        tasks = (json['tasks'] as List).listOf<String>((val) => val.toString()),
        epics = (json['epics'] as List).listOf<String>((val) => val.toString()),
        sprints =
            (json['sprints'] as List).listOf<String>((val) => val.toString()),
        events =
            (json['events'] as List).listOf<String>((val) => val.toString()),
        bin = (json['bin'] as List).listOf<String>((val) => val.toString()),
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'userName': userName,
      'projects': projects,
      'goals': goals,
      'tasks': tasks,
      'epics': epics,
      'sprints': sprints,
      'events': events,
      'bin': bin,
    };
  }
}

class Goal extends SchemaObject {
  final double value;

  Goal({
    required this.value,
    required super.userKey,
    required super.title,
  }) : super(prefix: 'go');

  Goal.fromJson(JSON json)
      : value = json['value'] as double,
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'value': value,
    };
  }
}

class Project extends SchemaObject {
  final List<String> goals;
  final List<String> epics;

  Project({
    required this.goals,
    required this.epics,
    required super.userKey,
    required super.title,
  }) : super(prefix: 'pj');

  Project.fromJson(JSON json)
      : goals = (json['goals'] as List).listOf<String>((val) => val.toString()),
        epics = (json['epics'] as List).listOf<String>((val) => val.toString()),
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'goals': goals,
      'epics': epics,
    };
  }
}

class Epic extends SchemaObject {
  final List<String> tasks;
  final String project;

  Epic({
    required this.tasks,
    required this.project,
    required super.userKey,
    required super.title,
  }) : super(prefix: 'ep');

  Epic.fromJson(JSON json)
      : tasks = (json['tasks'] as List).listOf<String>((val) => val.toString()),
        project = json['project'] as String,
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'tasks': tasks,
      'project': project,
    };
  }
}

class Sprint extends SchemaObject {
  final List<String> tasks;
  final SprintStatus status;
  final DateTimeRep start;
  final DateTimeRep end;

  Sprint({
    required this.tasks,
    required this.status,
    required this.start,
    required this.end,
    required super.userKey,
    required super.title,
  }) : super(prefix: 'sp');

  Sprint.fromJson(JSON json)
      : tasks = (json['tasks'] as List).listOf<String>((val) => val.toString()),
        status = SprintStatus.fromString(json['status'] as String),
        start = DateTimeRep.fromStorable(json['start'] as int),
        end = DateTimeRep.fromStorable(json['end'] as int),
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'tasks': tasks,
      'status': status.toStorable(),
      'start': start.toStorable(),
      'end': end.toStorable(),
    };
  }
}

class Task extends SchemaObject {
  final String description;
  final List<Dependency> dependencies;
  final TaskStatus status;
  final DateTimeRep due;
  final DateTimeRep assigned;
  final DurationRep duration;
  final double load;
  final List<ContextLabel> contexts;
  final String epic;
  final String sprint;
  final String project;

  Task({
    required this.description,
    required this.dependencies,
    required this.status,
    required this.due,
    required this.assigned,
    required this.duration,
    required this.load,
    required this.contexts,
    required this.epic,
    required this.sprint,
    required this.project,
    required super.userKey,
    required super.title,
  }) : super(prefix: 'tk');

  Task.fromJson(JSON json)
      : description = json['description'] as String,
        dependencies = (json['description'] as List)
            .listOf<Dependency>((val) => Dependency.fromString(val)),
        status = TaskStatus.fromString(json['status'] as String),
        due = DateTimeRep.fromStorable(json['due'] as int),
        assigned = DateTimeRep.fromStorable(json['assigned'] as int),
        duration = DurationRep.fromStorable(json['duration'] as int),
        load = json['load'] as double,
        contexts = (json['contexts'] as List)
            .listOf<ContextLabel>((val) => ContextLabel(val)),
        epic = json['epic'] as String,
        sprint = json['sprint'] as String,
        project = json['project'] as String,
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'description': description,
      'dependencies': dependencies.toStorableList(),
      'status': status.toStorable(),
      'due': due.toStorable(),
      'assigned': assigned.toStorable(),
      'duration': duration.toStorable(),
      'load': load,
      'contexts': contexts.toStorableList(),
      'epic': epic,
      'sprint': sprint,
      'project': project,
    };
  }
}

class Event extends SchemaObject {
  final String description;
  final String task;
  final DateTimeRep start;
  final DateTimeRep duration;
  final RepeatRule? repeatRule;

  Event({
    required this.description,
    required this.task,
    required this.start,
    required this.duration,
    this.repeatRule,
    required super.userKey,
    required super.title,
  }) : super(prefix: 'ev');

  Event.fromJson(JSON json)
      : description = json['description'] as String,
        task = json['task'] as String,
        start = DateTimeRep.fromStorable(json['start'] as int),
        duration = DateTimeRep.fromStorable(json['duration'] as int),
        repeatRule = RepeatRule.fromJson(json['repeatRule'] as JSON),
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'description': description,
      'task': task,
      'start': start.toStorable(),
      'duration': duration.toStorable(),
    };
  }
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
  final DateTimeRep? until;
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
        until = DateTimeRep.fromStorable(json['until'] as int),
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
      if (weekDays != null)
        'weekDays': <String>[
          for (RRWeekDays weekdays in weekDays!) weekdays.name
        ],
    };
  }
}
