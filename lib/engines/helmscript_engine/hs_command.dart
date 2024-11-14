part of lh.core.engines.helmscript;

class HelmscriptCommand {
  final String id;
  final String root;
  final String endpoint;
  final List<String> positionalArgsList;
  late PosArgs posArgs;
  final Map<String, dynamic> namedArgsMap;
  late NamedArgs namedArgs;
  final Map<String, dynamic> localFlags;
  final Map<String, dynamic> globalFlags;

  HelmscriptCommand({
    required this.root,
    required this.endpoint,
    this.positionalArgsList = const [],
    this.namedArgsMap = const {},
    this.localFlags = const {},
    this.globalFlags = const {},
  }) : id = ObjectID.generate('hscmd', 'userKey') {
    posArgs = PosArgs(wizCommand: this, args: positionalArgsList);
    namedArgs = NamedArgs(wizCommand: this, args: namedArgsMap);
  }

  Map<String, dynamic> toJSON() {
    return {
      'root': root,
      'endpoint': endpoint,
      'posArgs': positionalArgsList,
      'namedArgs': namedArgsMap,
      'localFlags': localFlags,
      'globalFlags': globalFlags,
    };
  }
}

abstract class HSCommandHandler {
  /// Shown during logs to identify source
  final String handlerId;
  final Map<
      String,
      Future<HelmscriptResult> Function(
          HelmscriptCommand cmd, ExecutionEnvironment env)> endpoints;

  HSCommandHandler({
    required this.handlerId,
    required this.endpoints,
  });
}

class ExecutionEnvironment {
  final OutputPipe outputPipe;

  ExecutionEnvironment({
    required this.outputPipe,
  });
}

abstract class Args<RefType> {
  final HelmscriptCommand wizCommand;

  Args({required this.wizCommand});

  HelmscriptResult argErr(RefType argReference) {
    throw HelmscriptResult.failure(
      wizCommand: wizCommand,
      code: 2,
      msg: "Argument expected for reference '$argReference'",
    );
  }

  T accessArg<T>(RefType argReference);

  T requestFor<T>(RefType argReference) {
    final T result;
    try {
      result = accessArg<T>(argReference);
      return result;
    } on HelmscriptResult catch (_) {
      rethrow;
    }
  }
}

class PosArgs extends Args<int> {
  final List<dynamic> args;
  PosArgs({
    this.args = const [],
    required super.wizCommand,
  });

  @override
  T accessArg<T>(int argReference) {
    if (args.length > argReference + 1) {
      return args[argReference];
    } else {
      throw argErr(argReference);
    }
  }
}

class NamedArgs extends Args<String> {
  final Map<String, dynamic> args;
  NamedArgs({
    this.args = const {},
    required super.wizCommand,
  });

  @override
  T accessArg<T>(String argReference) {
    if (args.containsKey(argReference)) {
      return args[argReference];
    } else {
      throw argErr(argReference);
    }
  }
}
