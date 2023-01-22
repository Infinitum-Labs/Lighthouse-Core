part of core.engines.keybine_engine;

abstract class KeybineEventHandler {
  final KeySequence hook;
  final List<KeyEvent> history = [];

  KeybineEventHandler(this.hook);

  void trigger(InvocationContext context) {
    context.eventsStream.listen(
      (KeyEvent e) {
        history.add(e);
        handle(e);
      },
      onDone: () {
        history.clear();
      },
    );
  }

  void handle(KeyEvent keyEvent);
}
