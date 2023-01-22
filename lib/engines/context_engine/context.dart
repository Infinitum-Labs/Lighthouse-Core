part of core.engines.context_engine;

class Context {
  final String location;
  final double energy;
  final Duration duration;
  final List<String> resources;

  Context({
    required this.location,
    required this.energy,
    required this.duration,
    required this.resources,
  });
}
