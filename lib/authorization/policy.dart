part of core.authorization;

class Policy {
  final Role role;
  final List<String> members;

  Policy({
    required this.role,
    required this.members,
  });
}
