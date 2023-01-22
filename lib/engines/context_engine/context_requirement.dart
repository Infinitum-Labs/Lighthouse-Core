part of core.engines.context_engine;

class ContextRequirement {
  final List<String> location;
  final double minEnergy;
  final double maxEnergy;
  final Duration duration;
  final List<String> resources;
  final Weightage weightage;

  ContextRequirement({
    required this.location,
    required this.minEnergy,
    required this.maxEnergy,
    required this.duration,
    required this.resources,
    this.weightage = const Weightage(),
  });
}

class Weightage {
  final double location;
  final double energy;
  final double duration;
  final double resources;

  const Weightage({
    this.location = 1.0,
    this.energy = 0.4,
    this.duration = 0.8,
    this.resources = 1.0,
  });
}
