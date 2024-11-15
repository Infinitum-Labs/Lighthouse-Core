import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lighthouse_core/engines/helmscript_engine/core_commands/core_commands.dart';
import 'package:lighthouse_core/engines/helmscript_engine/helmscript_engine.dart';
import 'package:lighthouse_core/main.dart';

import './utils/utils.dart';

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
  /* late final WheelhouseService wheelhouseService = WheelhouseService(
    commandsRegistry: HSCommandsRegistry(registry: {
      'user': UserTools(),
      'dev': DevCmd(),
      'obj': ObjectTools(),
    }),
    outputPipe: OutputPipe(
      log: logFn,
      warn: logFn,
      err: logFn,
    ),
    accessKey: superAccessKey,
  ); */

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
            onSubmitted: (String value) async {
              logFn(value.trim(), true);
              try {
                /* final HelmscriptResult wheelhouseResult =
                    await wheelhouseService.executeCommandFromWHCommand(
                  HSParser().parse(
                    HSTokeniser().tokenise(
                      value.trim(),
                    ),
                  ),
                ); */
                // Doesnt work:
                // .executeCommandFromString(value.trim());

                //logFn(">  [${wheelhouseResult.code}]: ${wheelhouseResult.msg}");
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
