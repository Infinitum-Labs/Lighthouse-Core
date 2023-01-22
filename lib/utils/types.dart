part of core.utils;

typedef JSON = Map<String, Object?>;
typedef ObjectId = String;

class ExecutionEnvironment {
  final String processId = 'someProcId';
  final Map<String, Object?> inputRegistry;
  final OutputPipe outputPipe;
  // final ToastController? toastController;

  // final List<Permission> executionPermissions;

  ExecutionEnvironment({
    this.inputRegistry = const {},
    this.outputPipe = const OutputPipe(log: print, warn: print, err: print),
    // this.toastController,
  });
}

typedef LogFunction = void Function(dynamic);

class OutputPipe {
  final LogFunction log;
  final LogFunction warn;
  final LogFunction err;

  const OutputPipe({
    required this.log,
    required this.warn,
    required this.err,
  });
}

class Queue<E> {
  final List<E> _list = [];

  void enqueue(E element) => _list.add(element);
  E dequeue() => _list.removeAt(0);
  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;
}
