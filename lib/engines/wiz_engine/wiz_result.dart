part of core.engines.wiz_engine;

class WizResult {
  final Status status;
  final String title;
  final String description;

  WizResult({
    required this.status,
    required this.title,
    this.description = '',
  });

  WizResult.success([this.description = ''])
      : status = Status.log,
        title = 'Command completed successfully!';

  WizResult.commandNotFound(String fullSignature)
      : status = Status.log,
        title = 'Command failed',
        description =
            'The command of signature "$fullSignature" does not exist';
}

enum Status {
  err,
  warn,
  log,
}
