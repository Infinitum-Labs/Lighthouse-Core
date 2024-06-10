library lh.core.engines.helmscript;

import 'package:lighthouse_core/utils/utils.dart';
export './helmscript_language_bundle/helmscript_lb.dart';

part './commands_registry.dart';
part './hs_result.dart';
part './hs_command.dart';

abstract class Registry<K, V> {
  final Map<K, V> registry;

  const Registry({required this.registry});
}

class HelmscriptEngine {
  final HSCommandsRegistry commandsRegistry;
  final OutputPipe outputPipe;

  const HelmscriptEngine({
    required this.commandsRegistry,
    required this.outputPipe,
  });

  Future<HelmscriptResult> handleCommand(HelmscriptCommand command) async {
    final ExecutionEnvironment environment =
        ExecutionEnvironment(outputPipe: outputPipe);

    if (commandsRegistry.registry.containsKey(command.root)) {
      final Map<
              String,
              Future<HelmscriptResult> Function(
                  HelmscriptCommand, ExecutionEnvironment)> endpoints =
          commandsRegistry.registry[command.root]!.endpoints;
      if (endpoints.containsKey(command.endpoint)) {
        try {
          return await endpoints[command.endpoint]!(command, environment);
        } on HelmscriptResult catch (e) {
          return e;
        }
      } else {
        return HelmscriptResult.failure(
          wizCommand: command,
          code: 2,
          msg: "Command endpoint '${command.endpoint}' not found",
        );
      }
    } else {
      return HelmscriptResult.failure(
        wizCommand: command,
        code: 127,
        msg: "Command root '${command.root}' not found",
      );
    }
  }
}
