enum CompatibilitySeverity { info, warning, critical }

class CompatibilityIssue {
  final String code;
  final String title;
  final String message;
  final CompatibilitySeverity severity;

  const CompatibilityIssue({
    required this.code,
    required this.title,
    required this.message,
    required this.severity,
  });

  bool get isCritical => severity == CompatibilitySeverity.critical;

  bool get isWarning => severity == CompatibilitySeverity.warning;

  bool get isInfo => severity == CompatibilitySeverity.info;

  Map<String, Object> toMap() {
    return {
      'code': code,
      'title': title,
      'message': message,
      'severity': severity.name,
    };
  }

  factory CompatibilityIssue.fromMap(Map<String, Object?> map) {
    final severityName =
        (map['severity'] as String?) ?? CompatibilitySeverity.info.name;

    final severity = CompatibilitySeverity.values.firstWhere(
      (value) => value.name == severityName,
      orElse: () => CompatibilitySeverity.info,
    );

    return CompatibilityIssue(
      code: map['code']! as String,
      title: map['title']! as String,
      message: map['message']! as String,
      severity: severity,
    );
  }
}

class ComponentCompatibilityResult {
  final bool isCompatible;
  final int score;
  final List<CompatibilityIssue> issues;

  ComponentCompatibilityResult({
    required this.isCompatible,
    required this.score,
    required List<CompatibilityIssue> issues,
  }) : issues = List<CompatibilityIssue>.unmodifiable(issues) {
    if (score < 0 || score > 100) {
      throw ArgumentError.value(
        score,
        'score',
        'Uyumluluk puanı 0 ile 100 arasında olmalıdır.',
      );
    }
  }

  bool get hasCriticalIssues => issues.any((issue) => issue.isCritical);

  bool get hasWarnings => issues.any((issue) => issue.isWarning);

  int get criticalIssueCount =>
      issues.where((issue) => issue.isCritical).length;

  int get warningIssueCount => issues.where((issue) => issue.isWarning).length;

  int get infoIssueCount => issues.where((issue) => issue.isInfo).length;

  String get statusLabel {
    if (!isCompatible || hasCriticalIssues) {
      return 'Uyumsuz';
    }

    if (hasWarnings) {
      return 'Koşullu Uyumlu';
    }

    return 'Uyumlu';
  }

  Map<String, Object> toMap() {
    return {
      'isCompatible': isCompatible,
      'score': score,
      'issues': issues.map((issue) => issue.toMap()).toList(),
    };
  }

  factory ComponentCompatibilityResult.fromMap(Map<String, Object?> map) {
    final rawIssues = map['issues']! as List<Object?>;

    return ComponentCompatibilityResult(
      isCompatible: map['isCompatible']! as bool,
      score: map['score']! as int,
      issues: rawIssues
          .map(
            (issue) => CompatibilityIssue.fromMap(
              Map<String, Object?>.from(issue! as Map),
            ),
          )
          .toList(),
    );
  }
}
