part of core.authorization;

class Role {
  final String title;
  final List<Permission> permissions;

  Role({
    required this.title,
    required this.permissions,
  });
}
