library lhcore.engines.wh_engine.core_commands;

import 'package:lighthouse_core/auth/auth.dart';
import 'package:lighthouse_core/db/db.dart';
import 'package:lighthouse_core/engines/wheelhouse_engine/wheelhouse_engine.dart';
import 'package:lighthouse_core/main.dart';
import 'package:lighthouse_core/services/services.dart';

part './obj.dart';

class UserTools extends WHCommandHandler {
  UserTools()
      : super(handlerId: 'userHandler', endpoints: {
          'current': (WheelhouseCommand cmd, ExecutionEnvironment env) async {
            env.outputPipe.log("DataService not connected");
            return WheelhouseResult.success(wizCommand: cmd);
          },
          'login': (WheelhouseCommand cmd, ExecutionEnvironment env) async {
            final String name = cmd.namedArgs.requestFor<String>('name');
            final String pwd = cmd.namedArgs.requestFor<String>('password');
            env.outputPipe.log("Logged in as $name!");
            return WheelhouseResult.success(wizCommand: cmd);
          }
        });
}
