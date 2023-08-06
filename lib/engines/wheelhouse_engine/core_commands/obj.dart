part of lhcore.engines.wh_engine.core_commands;

class ObjectTools extends WHCommandHandler {
  ObjectTools()
      : super(handlerId: 'objHandler', endpoints: {
          'workbenches':
              (WheelhouseCommand cmd, ExecutionEnvironment env) async {
            return WheelhouseResult.failure(
              msg: '',
              wizCommand: cmd,
            );
          },
          'workbenches.create':
              (WheelhouseCommand cmd, ExecutionEnvironment env) async {
            final DBService dbService = DBService(accessKey: superAccessKey);
            final Workbench wb =
                await dbService.getWorkbench(userName: 'johnbap123');
            return WheelhouseResult.success(
                wizCommand: cmd, msg: "ObId: ${wb.objectId}");
          },
        });
}

/// Only for dev purposes
class DevCmd extends WHCommandHandler {
  DevCmd()
      : super(handlerId: 'devHandler', endpoints: {
          'show.this': (cmd, env) async {
            return WheelhouseResult.success(
              wizCommand: cmd,
              msg: 'Root: ${cmd.root}\nEndpoint: ${cmd.endpoint}',
            );
          }
        });
}
