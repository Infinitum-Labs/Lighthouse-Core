part of lh.core.engines.helmscript.core_commands;

class ObjectTools extends HSCommandHandler {
  ObjectTools()
      : super(handlerId: 'objHandler', endpoints: {
          'workbenches':
              (HelmscriptCommand cmd, ExecutionEnvironment env) async {
            return HelmscriptResult.failure(
              msg: '',
              wizCommand: cmd,
            );
          },
          'workbenches.create':
              (HelmscriptCommand cmd, ExecutionEnvironment env) async {
            final Workbench wb = (await DB.workbenchesColl
                    .where('userName', isEqualTo: 'john')
                    .get())
                .docs
                .first
                .data();
            return HelmscriptResult.success(
                wizCommand: cmd, msg: "ObId: ${wb.objectId}");
          },
        });
}

/// Only for dev purposes
class DevCmd extends HSCommandHandler {
  DevCmd()
      : super(handlerId: 'devHandler', endpoints: {
          'show.this': (cmd, env) async {
            return HelmscriptResult.success(
              wizCommand: cmd,
              msg: 'Root: ${cmd.root}\nEndpoint: ${cmd.endpoint}',
            );
          }
        });
}
