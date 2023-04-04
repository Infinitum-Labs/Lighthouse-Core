library core.engines.wiz_engine;

import 'wiz_script/wiz_script.dart';
import 'commands_client.dart' as commands;
import '../context_engine/context_engine.dart';
import 'package:lighthouse_core/model/storage/storage.dart';
import 'package:lighthouse_core/utils/utils.dart';

part 'wizardry.dart';
part 'commands.dart';
part 'command_handler.dart';
part 'wiz_result.dart';

class WizEngine {
  final Map<String, Root> commandsRegistry = {
    'proj': commands.Project(),
    'toast': commands.ToastRoot(),
  };

  WizResult handleCommand(String command, ExecutionEnvironment env) {
    final WizScriptTokeniser tokeniser = WizScriptTokeniser(command);
    final WizScriptParser parser =
        WizScriptParser((tokeniser..tokenise()).tokens);
    final WizCommand wizCommand = parser.parse();
    if (commandsRegistry.containsKey(wizCommand.cmdRoot.first)) {
      return commandsRegistry[wizCommand.cmdRoot.first]!
          .handle(wizCommand, env);
    } else {
      return WizResult.commandNotFound(wizCommand.cmdRoot.join(''));
    }
  }
}
