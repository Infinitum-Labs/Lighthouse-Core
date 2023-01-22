import './wiz_engine.dart';
import 'package:lighthouse_core/utils/utils.dart';
import 'dart:io';

void main() {
  final File f = File('./sample.txt');
  /* final List<String> lines = f.readAsStringSync().split('=');
  for (String line in lines) {
    final Tokeniser tokeniser = Tokeniser(line);
    final Parser parser = Parser((tokeniser..tokenise()).tokens);
    print(parser.parse().json);
  } */
  // final String input = f.readAsStringSync();
  final String input = stdin.readLineSync()!;
  final WizEngine wizEngine = WizEngine();
  final WizResult result =
      wizEngine.handleCommand(input, ExecutionEnvironment());
  print("${result.status.name}: ${result.title}");
}
