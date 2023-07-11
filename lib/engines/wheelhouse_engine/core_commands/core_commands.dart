library lhcore.engines.wiz_engine.core_commands;

import '../wheelhouse_engine.dart';

part './obj.dart';

class UserTools extends WizCommandHandler {
  UserTools()
      : super(root: 'user', endpoints: {
          'current': (WizCommand cmd, ExecutionEnvironment env) {
            env.outputPipe.log("DataService not connected");
            return WizResult.success(wizCommand: cmd);
          },
          'login': (WizCommand cmd, ExecutionEnvironment env) {
            final String name = cmd.namedArgs.requestFor<String>('name');
            final String pwd = cmd.namedArgs.requestFor<String>('password');
            env.outputPipe.log("Logged in as $name!");
            return WizResult.success(wizCommand: cmd);
          }
        });
}
