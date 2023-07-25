part of lhcore.engines.wiz_engine.core_commands;

class ObjectTools extends WHCommandHandler {
  ObjectTools()
      : super(root: 'obj', endpoints: {
          'workbenches': (WheelhouseCommand cmd, ExecutionEnvironment env) {
            return WheelhouseResult.failure(
              msg: '',
              wizCommand: cmd,
            );
          },
        });
}
