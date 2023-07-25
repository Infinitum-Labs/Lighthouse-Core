import 'package:flutter/material.dart';
import 'package:lighthouse_core/db/db.dart';
import 'package:lighthouse_core/db/firebase_configs.dart';
import './engines/wheelhouse_engine/wheelhouse_engine.dart';
import './engines/wheelhouse_engine/wh_script/wh_script.dart';
import './engines/wheelhouse_engine/core_commands/core_commands.dart';
import './utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.init(webOptions);
  runApp(const App());
}

class App extends StatefulWidget {
  static final List<LogEntry> logs = [];
  const App({super.key});

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 100,
              right: 100,
              top: 50,
              bottom: 50,
            ),
            child: SelectableRegion(
              focusNode: FocusNode(),
              selectionControls: emptyTextSelectionControls,
              child: Container(
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: App.logs,
                      ),
                    ),
                    CommandEntryWidget(refreshFn: setState, key: widget.key),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogEntry extends StatelessWidget {
  final String content;
  final bool isCommand;

  LogEntry({
    required this.content,
    this.isCommand = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: TextStyle(
        color: isCommand ? Colors.white : Colors.grey.shade700,
        fontSize: 20,
        fontFamily: 'Courier_Prime',
      ),
    );
  }
}

class CommandEntryWidget extends StatefulWidget {
  final Function(void Function()) refreshFn;

  CommandEntryWidget({
    required this.refreshFn,
    required super.key,
  });
  @override
  State<CommandEntryWidget> createState() => CommandEntryWidgetVC();
}

class CommandEntryWidgetVC extends State<CommandEntryWidget> {
  final TextEditingController editingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  late WheelhouseEngine wheelhouseEngine = WheelhouseEngine(
    commandsRegistry: WHCommandsRegistry(registry: {
      'user': UserTools(),
    }),
    outputPipe: OutputPipe(
      log: logFn,
      warn: logFn,
      err: logFn,
    ),
  );

  logFn(dynamic logData, [bool isCommand = false]) {
    App.logs.add(LogEntry(
      content: logData.toString(),
      isCommand: isCommand,
    ));
    widget.refreshFn(() {});
  }

  CommandEntryWidgetVC();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey[800],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: TextField(
            focusNode: focusNode,
            controller: editingController,
            autofocus: true,
            cursorWidth: 10,
            cursorRadius: const Radius.circular(1),
            cursorColor: Colors.grey[300],
            decoration: const InputDecoration(
              focusedBorder: InputBorder.none,
            ),
            onSubmitted: (String value) {
              logFn(value, true);
              try {
                final WheelhouseCommand wheelhouseCommand =
                    WHParser(source: value.trim()).parse();
                final WheelhouseResult wheelhouseResult =
                    wheelhouseEngine.handleCommand(wheelhouseCommand);
                logFn(">  [${wheelhouseResult.code}]: ${wheelhouseResult.msg}");
              } catch (e, st) {
                logFn(e);
                print(e);
                print(st);
              } finally {
                editingController.clear();
                focusNode.requestFocus();
                widget.refreshFn(() {});
              }
            },
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 20,
              fontFamily: 'Courier_Prime',
            ),
          ),
        ),
      ),
    );
  }
}
