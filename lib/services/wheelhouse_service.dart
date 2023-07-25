part of core.services;

class WheelhouseService extends LHService {
  final WheelhouseEngine wheelhouseEngine;

  WheelhouseService({
    required WHCommandsRegistry commandsRegistry,
    required OutputPipe outputPipe,
    required super.accessKey,
  }) : wheelhouseEngine = WheelhouseEngine(
          commandsRegistry: commandsRegistry,
          outputPipe: outputPipe,
        );

  WheelhouseResult executeCommandFromString(String command) {
    requirePermissions(const []);
    return executeCommandFromWHCommand(WHParser(source: command).parse());
  }

  WheelhouseResult executeCommandFromWHCommand(WheelhouseCommand command) {
    requirePermissions(const [
      Permission(permId: PermissionId.wh_execute),
    ]);
    return wheelhouseEngine.handleCommand(command);
  }
}
