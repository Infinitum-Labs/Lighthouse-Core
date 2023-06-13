library core.cli;

import '../../engines/wheelhouse_engine/core_commands/core_commands.dart';
import '../../engines/wheelhouse_engine/wh_script/wh_script.dart';
import '../../engines/wheelhouse_engine/wheelhouse_engine.dart';
import '../../utils/utils.dart';

void writeToConsole(dynamic msg) {
  print(msg);
}

/* void main(List<String> args) {
  final WizCommand wizCommand = WHParser(source: args.join(' ')).parse();
  final WizResult wizResult = WheelhouseEngine(
    commandsRegistry: WHCommandsRegistry(registry: {
      '': UserTools(),
    }),
    outputPipe: const OutputPipe(
      log: writeToConsole,
      warn: writeToConsole,
      err: writeToConsole,
    ),
  ).handleCommand(wizCommand);
} */
