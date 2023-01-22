import 'wiz_engine.dart';
import 'wiz_script/wiz_script.dart';
import 'package:lighthouse_core/utils/utils.dart';

class Project extends Root {
  Project()
      : super(
          root: 'proj',
          description: "Work with Project objects",
          commands: {
            'create': Proj_Create(),
          },
        );
}

class Proj_Create extends CommandHandler {
  Proj_Create()
      : super(
          description: "Create a Project",
          positionalParams: [
            Param(
              name: 'title',
              description: "The title of the Project to be created",
              required: true,
              type: 'String',
              example: '"My Amazing Project"',
            ),
          ],
          namedParams: [
            Param(
              name: 'members',
              description: "Members to be added to this Project",
              type: 'List<String>',
              example: "John Bappleseed, Bohnbap, Appleseed",
            ),
            Param(
              name: '-O',
              description:
                  "Open the Project Editor popup to continue editing this project",
              type: 'void',
              example: "-O",
            ),
          ],
        );

  @override
  WizResult handle(WizCommand cmd, ExecutionEnvironment env) {
    print("Hello! Check these out");
    print(cmd.namedArgs['title']);
    print(cmd.json);
    return WizResult.success();
  }
}

class ToastRoot extends Root {
  ToastRoot()
      : super(
          root: 'toast',
          description: "Work with Project objects",
          commands: {
            'show': Toast_Create(),
          },
        );
}

class Toast_Create extends CommandHandler {
  Toast_Create()
      : super(
          description: "Create a Project",
          positionalParams: [],
          namedParams: [
            Param(
              name: 'members',
              description: "Members to be added to this Project",
              type: 'List<String>',
              example: "John Bappleseed, Bohnbap, Appleseed",
            ),
            Param(
              name: '-O',
              description:
                  "Open the Project Editor popup to continue editing this project",
              type: 'void',
              example: "-O",
            ),
          ],
        );

  @override
  WizResult handle(WizCommand cmd, ExecutionEnvironment env) {
    /* env.toastController!.enqueue(
      () => Toast(
        message: cmd.namedArgs['title']!,
        toastController: env.toastController!,
      ),
    ); */
    env.outputPipe.log(cmd.json);
    return WizResult.success();
  }
}

/*
class Mouth extends Root {
  Mouth()
      : super(
          root: 'mouth',
          description: '',
          commands: {
            'scream': Mouth_Scream(),
          },
        );
}

class Mouth_Scream extends CommandHandler {
  Mouth_Scream()
      : super(
          description: '',
          positionalParams: [
            Param(
              name: 'message',
              description: '',
              required: true,
              type: '',
              example: '',
            ),
          ],
          namedParams: [
            Param(
              name: 'exclaim',
              description: '',
              type: '',
              example: '',
            ),
            Param(
              name: '-r',
              description: '',
              type: '',
              example: '',
            ),
          ],
        );

  @override
  WizResult handle(WizCommand cmd, ExecutionEnvironment env) {
    final String message;
    if (cmd.namedArgs.containsKey('exclaim') &&
        cmd.namedArgs['exclaim'] == 'true') {
      message = cmd.posArgs.first.toUpperCase() + '!';
    } else {
      message = cmd.posArgs.first.toUpperCase();
    }
    print(message);
    if (cmd.localFlags.containsKey('r')) {
      for (int i = 0; i < int.parse(cmd.localFlags['r']!); i++) {
        print(message);
      }
    }
    return WizResult.success();
  }
}
*/
