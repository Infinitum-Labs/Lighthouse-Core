part of core.authorization;

class Permission {
  final List<Scope> scopes;

  Permission({required this.scopes});

  JSON toJson() {
    return {
      'scopes': scopes,
    };
  }
}
