part of lh.core.db;

mixin DataBinding {
  Widget dataBoundBuilder<T>({
    required Future<QuerySnapshot<T>> future,
    required Widget Function(BuildContext, List<T>) builder,
  }) {
    return FutureBuilder<QuerySnapshot<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return builder(
            context,
            [for (final d in snapshot.data!.docs) d.data()],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
