part of lh.core.db;

/// This mixin allows Views to load data from the DB before rendering.
///
/// However, more importantly, it also allows data to be passed to the ViewController
/// (State object) from its view (StatefulWidget object). This can be used for debugging
/// or when Views need to be loaded with different query data.
///
/// This mixin provides a [singleBoundBuilder] that provides abstraction over
/// a standard FutureBuilder implementation, single-query views. Examples include
/// the [LaunchStateNight] view.
///
/// For use cases that make multiple queries and store the data in different variables,
/// a [multiBoundBuilder] is provided. The data types of variables must be matching
/// in both the View and ViewController. Examples include the [SprintEndUnready] view.
mixin ViewDataBinding<T extends StatefulWidget> on State<T> {
  final List<Future<void>> _futures = [];

  void addField<F>(
    void Function(F) assign,
    F? passed,
    Future<F> Function() query,
  ) {
    if (passed == null) {
      _futures.add(() async {
        assign(await query());
      }());
    } else {
      assign(passed);
    }
  }

  Widget multiBoundBuilder({
    required Widget Function(BuildContext) builder,
  }) {
    return FutureBuilder(
      future: Future.wait(_futures),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return builder(context);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
