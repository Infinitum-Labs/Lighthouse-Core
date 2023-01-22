library core.services;

import '../engines/engines.dart';

part 'auth_service.dart';
part 'beaconsearch_service.dart';
part 'context_service.dart';
part 'keybine_service.dart';
part 'prototype_service.dart';
part 'wiz_service.dart';

/* abstract class Service {
  final List<int> policies;

  Service({required this.policies});
} */
class Key {
  late int value = hashCode;
}

abstract class Service {
  final Key key;
  final String? opt;

  Service(this.key, {this.opt}) {
    if (authenticate() == false) {
      throw "Unauthenticated";
    }
  }

  bool authenticate() => key.value.isEven;
}

class Core {
  void write(String s) => print(s);
}

class CoreService extends Service with Core {
  CoreService(super.key, String opt) : super(opt: opt);
}

void main() {
  final CoreService cs = CoreService(Key(), "null");
  cs.write("Hello!");
}
