part of lhcore.engines.wiz_engine.core_commands;

class ObjectTools extends WizCommandHandler {
  ObjectTools()
      : super(root: 'obj', endpoints: {
          'workbenches': (WizCommand cmd, ExecutionEnvironment env) {

            return WizResult.failure(
              msg: '',
              wizCommand: cmd,
            );
          },
        });
}
