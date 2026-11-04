// Merges every package's coverage/lcov.info and fails below the threshold.
import 'dart:io';

const threshold = 90.0;

// Files excluded from coverage: generated code and composition/entrypoints.
final excluded = <RegExp>[
  RegExp(r'\.g\.dart$'),
  RegExp(r'[/\\]l10n[/\\]generated[/\\]'),
  RegExp(r'app_localizations(_\w+)?\.dart$'),
  RegExp(r'[/\\]main_\w+\.dart$'),
  RegExp(r'[/\\]injection\.dart$'),
];

void main() {
  final reports = <File>[
    for (final entity in Directory('.').listSync(recursive: true))
      if (entity is File &&
          entity.path.endsWith('coverage${Platform.pathSeparator}lcov.info') &&
          !entity.path.contains('.dart_tool'))
        entity,
  ];
  if (reports.isEmpty) {
    stderr.writeln('No lcov.info found. Run `melos run test` first.');
    exit(1);
  }

  // Key by "<package dir>/<source file>" so reports merge without collisions.
  final hits = <String, Map<int, int>>{};
  for (final report in reports) {
    final packageDir = report.parent.parent.path;
    String? current;
    for (final line in report.readAsLinesSync()) {
      if (line.startsWith('SF:')) {
        final path = '$packageDir/${line.substring(3)}';
        current = excluded.any((r) => r.hasMatch(path)) ? null : path;
        if (current != null) hits.putIfAbsent(current, () => {});
      } else if (line.startsWith('DA:') && current != null) {
        final parts = line.substring(3).split(',');
        final n = int.parse(parts[0]);
        final count = int.parse(parts[1]);
        hits[current]![n] = (hits[current]![n] ?? 0) + count;
      }
    }
  }

  var found = 0;
  var covered = 0;
  for (final lines in hits.values) {
    found += lines.length;
    covered += lines.values.where((c) => c > 0).length;
  }
  final pct = found == 0 ? 100.0 : covered * 100 / found;
  stdout.writeln(
    'Coverage: ${pct.toStringAsFixed(2)}% ($covered/$found lines), '
    'threshold $threshold%',
  );
  if (pct < threshold) {
    stderr.writeln('Coverage below threshold.');
    exit(1);
  }
}
