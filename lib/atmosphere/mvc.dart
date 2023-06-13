part of core.controller.atmosphere;

abstract class StatelessView extends StatelessWidget {
  const StatelessView({required Key key}) : super(key: key);
}

abstract class StatefulView extends StatefulWidget {
  const StatefulView({required Key key}) : super(key: key);
}

abstract class ViewController<T extends StatefulView> extends State<T> {}
