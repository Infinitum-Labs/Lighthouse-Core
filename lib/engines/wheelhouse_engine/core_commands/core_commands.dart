library lhcore.engines.wiz_engine.core_commands;

import 'package:lighthouse_core/engines/wheelhouse_engine/wheelhouse_engine.dart';

part './obj.dart';

class UserTools extends WHCommandHandler {
  UserTools()
      : super(root: 'user', endpoints: {
          'current': (WheelhouseCommand cmd, ExecutionEnvironment env) {
            env.outputPipe.log("DataService not connected");
            return WheelhouseResult.success(wizCommand: cmd);
          },
          'login': (WheelhouseCommand cmd, ExecutionEnvironment env) {
            final String name = cmd.namedArgs.requestFor<String>('name');
            final String pwd = cmd.namedArgs.requestFor<String>('password');
            env.outputPipe.log("Logged in as $name!");
            return WheelhouseResult.success(wizCommand: cmd);
          }
        });
}
