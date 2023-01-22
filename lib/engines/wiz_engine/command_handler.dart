part of core.engines.wiz_engine;

abstract class Node {
  final String description;

  Node({required this.description});
}

abstract class Root extends Node {
  final String root;
  final Map<String, CommandHandler> commands;

  Root(
      {required this.root, required super.description, required this.commands});

  WizResult handle(WizCommand wizCommand, ExecutionEnvironment env) {
    final String fullSignature = wizCommand.cmdRoot.join('');
    final String trimmedSignature = wizCommand.cmdRoot.sublist(1).join('');
    if (commands.containsKey(trimmedSignature)) {
      return commands[trimmedSignature]!.handle(wizCommand, env);
    } else {
      return WizResult.commandNotFound(fullSignature);
    }
  }
}

abstract class CommandHandler extends Node {
  final List<Param> positionalParams;
  final List<Param> namedParams;

  CommandHandler({
    required super.description,
    required this.positionalParams,
    required this.namedParams,
  });

  WizResult handle(
    WizCommand cmd,
    ExecutionEnvironment env,
  );
}

class Param extends Node {
  final String name;
  final String type;
  final String example;
  final bool required;

  Param({
    required this.name,
    required super.description,
    required this.type,
    this.required = false,
    required this.example,
  });
}
