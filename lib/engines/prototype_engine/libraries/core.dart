part of core.engines.prototype_engine.libraries;

// Math, DateTime, Package & Deployment

class Package extends Component<void> {
  Package()
      : super(
          token: 'package',
          tags: [],
          parameters: {
            'name': const Parameter<String>(
              required: true,
            ),
            'visibility': const Parameter<String>(
              defaultValue: 'private',
            ),
            'deploymentScript': const Parameter<Function?>(
              defaultValue: null,
            ),
          },
        );

  @override
  void run(ExecutionEnvironment env) {}

  @override
  String toString() {
    return """package ${parameters['name']} {
  visibility: ${parameters['visibility']}
  deploymentScript: ${parameters['deploymentScript']}
}
""";
  }
}
/**
package AutoTriage {
    visibility: public,
    deployment: deploymentScript
}

import Services.DBService;
import Services.SchedulerService;

func deploymentScript() {
    SchedulerService.schedule(
        'cron expression',
        autoTriage
    );
}

func autoTriage() {
    List<Task> tasks = DBService.getAll('tasks');
    if (tasks.isNotEmpty) {
        for (Task t in tasks) {
            if (t.state is State.inbox) {

            }
        }
    }
}
*/
