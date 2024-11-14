part of lh.core.engines.helmscript.core_commands;

class UserTools extends HSCommandHandler {
  UserTools()
      : super(handlerId: 'userHandler', endpoints: {
          'current': (HelmscriptCommand cmd, ExecutionEnvironment env) async {
            env.outputPipe.log("DataService not connected");
            return HelmscriptResult.success(wizCommand: cmd);
          },
          'login': (HelmscriptCommand cmd, ExecutionEnvironment env) async {
            final String name = cmd.namedArgs.requestFor<String>('name');
            final String pwd = cmd.namedArgs.requestFor<String>('password');
            env.outputPipe.log("Logged in as $name!");
            return HelmscriptResult.success(wizCommand: cmd);
          }
        });
}
