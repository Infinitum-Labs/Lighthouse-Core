library core.engines.keybine_engine;

import 'package:flutter/services.dart';
import 'dart:async';

export 'package:flutter/services.dart';
export 'dart:async';

part 'keybine_event_handler.dart';
part 'invocation_context.dart';

typedef KeySequence = List<LogicalKeyboardKey>;

class KeybineEngine {
  static final Map<KeySequence, KeybineEventHandler> hooks = {};
  static KeySequence? activeKeySequence;
  static StreamController<KeyEvent>? streamController;
  static KeybineEventHandler? activeHandler;

  static void registerHook(
    KeySequence keySequence,
    KeybineEventHandler eventHandler,
  ) {
    if (hooks.containsKey(keySequence)) throw "Hook for sequence exists";
    hooks[keySequence] = eventHandler;
  }

  static void handleKeyEvent(KeyEvent keyEvent) {
    if (streamController != null) {
      streamController!.add(keyEvent);
    } else if (activeKeySequence != null) {
      activeKeySequence!.add(keyEvent.logicalKey);
    } else if (keyEvent is KeyUpEvent) {
      checkActiveSequence();
      activeKeySequence = null;
    } else if (keyEvent is KeyDownEvent) {
      activeKeySequence = [keyEvent.logicalKey];
    }
  }

  static void checkActiveSequence() {
    if (hooks.containsKey(activeKeySequence)) {
      streamController = StreamController();
      final InvocationContext invocationContext = InvocationContext(
        eventsStream: streamController!.stream,
      );
      hooks[activeKeySequence]!.trigger(invocationContext);
    }
  }

  static void deactivateEventHandler(KeybineEventHandler eventHandler) {
    streamController!.close();
    streamController = null;
  }
}
