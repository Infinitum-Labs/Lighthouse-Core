import 'package:flutter/material.dart';
import 'package:lighthouse_core/data_handling/data_handling.dart';
import 'package:lighthouse_core/utils/utils.dart';

void main() async {
  runApp(
    App(
      child: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.lightBlue,
          child: const Text("Hello"),
        ),
      ),
    ),
  );
}

class App extends StatefulWidget {
  final Widget child;

  const App({
    required this.child,
  });

  @override
  _AppState createState() => _AppState();

  static void initClient() async {
    HTTP.init();
    await HTTP.getJwtToken('john.bappleseed@gmail.com', 'john69');
    final List<JSON> payload = (await HTTP.getAllObjects()).jsonPayload;
    Synchroniser.init();
    Storage.init(HTTP.jwtToken!.sub, payload);
  }

  static void deinitClient() async {
    HTTP.deinit();
    Synchroniser.deinit();
    Storage.deinit();
  }
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: widget.child,
    );
  }
}
