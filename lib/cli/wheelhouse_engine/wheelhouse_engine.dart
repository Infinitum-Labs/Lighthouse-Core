library lhcore.engines.wiz_engine;

import '../../utils/utils.dart';

abstract class Registry<K, V> {
  final Map<K, V> registry;

  Registry({required this.registry});
}

class WHCommandsRegistry extends Registry<String, WizCommandHandler> {
  WHCommandsRegistry({required super.registry});
}

class WheelhouseEngine {
  final WHCommandsRegistry commandsRegistry;
  final OutputPipe outputPipe;

  WheelhouseEngine({
    required this.commandsRegistry,
    required this.outputPipe,
  });

  WizResult handleCommand(WizCommand command) {
    final ExecutionEnvironment environment =
        ExecutionEnvironment(outputPipe: outputPipe);

    if (commandsRegistry.registry.containsKey(command.root)) {
      final Map<String, WizResult Function(WizCommand, ExecutionEnvironment)>
          endpoints = commandsRegistry.registry[command.root]!.endpoints;
      if (endpoints.containsKey(command.endpoint)) {
        try {
          return endpoints[command.endpoint]!(command, environment);
        } on WizResult catch (e) {
          return e;
        }
      } else {
        return WizResult.failure(
          wizCommand: command,
          code: 2,
          msg: "Command endpoint '${command.root}' not found",
        );
      }
    } else {
      return WizResult.failure(
        wizCommand: command,
        code: 127,
        msg: "Command root '${command.root}' not found",
      );
    }
  }
}

class WizResult {
  final int code;
  final String msg;
  final WizCommand wizCommand;

  const WizResult({
    required this.wizCommand,
    required this.code,
    required this.msg,
  });

  WizResult.success({
    required this.wizCommand,
    String? msg,
  })  : code = 0,
        msg = msg ?? "Command #${wizCommand.id} succeeded";

  WizResult.failure({
    required this.wizCommand,
    String? msg,
    this.code = 1,
  }) : msg = msg ?? "Command #${wizCommand.id} failed";
}

class WizCommand {
  final String id;
  final String root;
  final String endpoint;
  final List<String> positionalArgsList;
  late PosArgs posArgs;
  final Map<String, dynamic> namedArgsMap;
  late NamedArgs namedArgs;
  final Map<String, dynamic> localFlags;
  final Map<String, dynamic> globalFlags;

  WizCommand({
    required this.root,
    required this.endpoint,
    this.positionalArgsList = const [],
    this.namedArgsMap = const {},
    this.localFlags = const {},
    this.globalFlags = const {},
  }) : id = ObjectID.generate('wcmd', 'userKey') {
    posArgs = PosArgs(wizCommand: this, args: positionalArgsList);
    namedArgs = NamedArgs(wizCommand: this, args: namedArgsMap);
  }
}

abstract class WizCommandHandler {
  final String root;
  final Map<String, WizResult Function(WizCommand, ExecutionEnvironment)>
      endpoints;

  WizCommandHandler({
    required this.root,
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
  final WizCommand wizCommand;

  Args({required this.wizCommand});

  WizResult argErr(RefType argReference) {
    throw WizResult.failure(
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
    } on WizResult catch (_) {
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
