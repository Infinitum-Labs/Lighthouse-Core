part of core.engines.prototype_engine;

class Prototype {
  final String name;
  final String objectId;
  final List<Role> roles;
  final List<Component> actions;

  Prototype({
    required this.name,
    required this.objectId,
    required this.roles,
    this.actions = const [],
  });

  ExecutionResult run(ExecutionEnvironment env) {
    final ExecutionResult result = ExecutionResult();
    try {
      for (final Component c in actions) {
        c.run(env);
      }
    } catch (e, st) {
      result.error = e;
      result.stackTrace = st;
    }

    return result;
  }

  JSON toJSON() {
    return {
      'name': name,
      'objectId': objectId,
      'roles': roles,
      'actions': actions,
    };
  }
}

class ExecutionResult {
  dynamic error;
  StackTrace? stackTrace;
}
