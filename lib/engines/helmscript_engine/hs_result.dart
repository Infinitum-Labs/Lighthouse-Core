part of lh.core.engines.helmscript;

class HelmscriptResult {
  final int code;
  final String msg;
  final HelmscriptCommand wizCommand;

  const HelmscriptResult({
    required this.wizCommand,
    required this.code,
    required this.msg,
  });

  HelmscriptResult.success({
    required this.wizCommand,
    String? msg,
  })  : code = 0,
        msg = msg ?? "Command #${wizCommand.id} succeeded";

  HelmscriptResult.failure({
    required this.wizCommand,
    String? msg,
    this.code = 1,
  }) : msg = msg ?? "Command #${wizCommand.id} failed";
/* 
  HelmscriptResult.failure_insufficientPerms({
    required this.wizCommand,
    String? msg,
    this.code = 2,
    required Set<Permission> permsNeeded,
  }) : msg = msg ??
            "Command #${wizCommand.id} failed because the following permissions are needed:\n${permsNeeded.join('\n')}"; */
}
