import 'dart:convert';
import 'dart:io';

void main() async {
  final p = await Process.start(
    'firebase',
    ["emulators:start", "--import=./data", "--export-on-exit"],
    mode: ProcessStartMode.detachedWithStdio,
  )
    ..stderr.transform(utf8.decoder).listen((event) {
      print(event);
    })
    ..stdout.transform(utf8.decoder).listen((event) {
      print(event);
    });
  print(p.pid);
  await Future.delayed(const Duration(seconds: 20), () {
    print('killing');
    print(p.kill(ProcessSignal.sigterm));
    /* Future.delayed(const Duration(seconds: 2), () {
      print(p.kill(ProcessSignal.sigint));
    }); */
  });
  final String pidToKill =
      (((await Process.run('lsof', ['-i', ':8080'])).stdout as String)
          .split('\n')
          .firstWhere((ln) => ln.startsWith('java'))
          .replaceAll('java', '')
          .trim()
          .split(' ')[0]);
  await Process.run('kill', [pidToKill]);
  exit(0);
  /* WidgetsFlutterBinding.ensureInitialized();
  await DB.init();
  runApp(const App()); */
}
