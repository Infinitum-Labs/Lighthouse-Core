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

  Future<WheelhouseResult> executeCommandFromString(String command) async {
    requirePermissions(const {});
    return await executeCommandFromWHCommand(WHParser(source: command).parse());
  }

  Future<WheelhouseResult> executeCommandFromWHCommand(
      WheelhouseCommand command) async {
    try {
      requirePermissions(const {
        Permission(permId: PermissionId.wh_execute),
      });
      return await wheelhouseEngine.handleCommand(command);
    } catch (e) {
      if (e is InsufficientPermsException) {
        return WheelhouseResult.failure_insufficientPerms(
          wizCommand: command,
          permsNeeded: e.missingPerms,
        );
      } else {
        rethrow;
      }
    }
  }
}
