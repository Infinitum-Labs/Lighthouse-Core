library lhcore.engines.wiz_engine;

import '../../utils/utils.dart';

abstract class Registry<K, V> {
  final Map<K, V> registry;

  Registry({required this.registry});
}

class WHCommandsRegistry extends Registry<String, WHCommandHandler> {
  WHCommandsRegistry({required super.registry});
}

class WheelhouseEngine {
  final WHCommandsRegistry commandsRegistry;
  final OutputPipe outputPipe;

  WheelhouseEngine({
    required this.commandsRegistry,
    required this.outputPipe,
  });

  WheelhouseResult handleCommand(WheelhouseCommand command) {
    final ExecutionEnvironment environment =
        ExecutionEnvironment(outputPipe: outputPipe);

    if (commandsRegistry.registry.containsKey(command.root)) {
      final Map<
              String,
              WheelhouseResult Function(
                  WheelhouseCommand, ExecutionEnvironment)> endpoints =
          commandsRegistry.registry[command.root]!.endpoints;
      if (endpoints.containsKey(command.endpoint)) {
        try {
          return endpoints[command.endpoint]!(command, environment);
        } on WheelhouseResult catch (e) {
          return e;
        }
      } else {
        return WheelhouseResult.failure(
          wizCommand: command,
          code: 2,
          msg: "Command endpoint '${command.root}' not found",
        );
      }
    } else {
      return WheelhouseResult.failure(
        wizCommand: command,
        code: 127,
        msg: "Command root '${command.root}' not found",
      );
    }
  }
}

class WheelhouseResult {
  final int code;
  final String msg;
  final WheelhouseCommand wizCommand;

  const WheelhouseResult({
    required this.wizCommand,
    required this.code,
    required this.msg,
  });

  WheelhouseResult.success({
    required this.wizCommand,
    String? msg,
  })  : code = 0,
        msg = msg ?? "Command #${wizCommand.id} succeeded";

  WheelhouseResult.failure({
    required this.wizCommand,
    String? msg,
    this.code = 1,
  }) : msg = msg ?? "Command #${wizCommand.id} failed";
}

class WheelhouseCommand {
  final String id;
  final String root;
  final String endpoint;
  final List<String> positionalArgsList;
  late PosArgs posArgs;
  final Map<String, dynamic> namedArgsMap;
  late NamedArgs namedArgs;
  final Map<String, dynamic> localFlags;
  final Map<String, dynamic> globalFlags;

  WheelhouseCommand({
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

abstract class WHCommandHandler {
  final String root;
  final Map<String,
          WheelhouseResult Function(WheelhouseCommand, ExecutionEnvironment)>
      endpoints;

  WHCommandHandler({
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
  final WheelhouseCommand wizCommand;

  Args({required this.wizCommand});

  WheelhouseResult argErr(RefType argReference) {
    throw WheelhouseResult.failure(
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
    } on WheelhouseResult catch (_) {
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
