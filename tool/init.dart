// Renames the template: app name, Dart package and bundle/application ID.
// Usage: tool/init --name "My App" --package my_app --bundle-id com.acme.my_app
//        [--repo owner/repo] [--skip-repo-setup] [--dry-run]
import 'dart:io';

const _oldPackage = 'flutter_bloc_template';
const _oldBundle = 'dev.invoketech.flutter_bloc_template';
const _oldBundleCamel = 'dev.invoketech.flutterBlocTemplate';
const _oldTitle = 'Flutter BLoC Template';
const _oldName = 'Template';

const _usage = '''
Usage: tool/init --name <App Name> --package <dart_package> --bundle-id <com.acme.app>
                 [--repo owner/repo] [--skip-repo-setup] [--dry-run]''';

Future<void> main(List<String> args) async {
  final opts = <String, String>{};
  final flags = <String>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--dry-run' || a == '--skip-repo-setup') {
      flags.add(a);
    } else if (const {
          '--name',
          '--package',
          '--bundle-id',
          '--repo',
        }.contains(a) &&
        i + 1 < args.length) {
      opts[a] = args[++i];
    } else {
      _die('Unknown or incomplete argument: $a');
    }
  }
  final name = opts['--name'];
  final package = opts['--package'];
  final bundle = opts['--bundle-id'];
  if (name == null ||
      name.trim().isEmpty ||
      package == null ||
      bundle == null) {
    _die('--name, --package and --bundle-id are required.');
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(package)) {
    _die('Invalid --package "$package": use lowercase letters, digits, _.');
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$').hasMatch(bundle)) {
    _die(
      'Invalid --bundle-id "$bundle": use dotted lowercase segments, '
      'e.g. com.acme.app.',
    );
  }
  if (name.contains(RegExp(r'["\\$&]'))) {
    _die('--name must not contain quotes, backslashes, \$ or &.');
  }

  final dryRun = flags.contains('--dry-run');
  final root = Directory.fromUri(
    Platform.script.resolve('..'),
  ).resolveSymbolicLinksSync();
  final changed = rewriteFiles(
    root: root,
    name: name.trim(),
    package: package,
    bundle: bundle,
    dryRun: dryRun,
  );
  final verb = dryRun ? 'Would update' : 'Updated';
  for (final c in changed) {
    stdout.writeln('$verb $c');
  }

  final moved = moveKotlinPackage(root, bundle, dryRun: dryRun);
  if (moved != null)
    stdout.writeln('${dryRun ? 'Would move' : 'Moved'} $moved');

  if (dryRun || flags.contains('--skip-repo-setup')) {
    stdout.writeln(
      dryRun
          ? 'Dry run: nothing written, tool/setup_repo.sh not run.'
          : 'Skipped tool/setup_repo.sh.',
    );
    return;
  }
  final repo = opts['--repo'];
  final result = await Process.run('$root/tool/setup_repo.sh', [
    if (repo != null) repo,
  ]);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    _die(
      'tool/setup_repo.sh failed (exit ${result.exitCode}). Files were '
      'renamed; re-run it manually or use --skip-repo-setup.',
    );
  }
}

Never _die(String msg) {
  stderr.writeln('error: $msg\n$_usage');
  exit(64);
}

bool _isText(String path) {
  const binary = {'.png', '.jar', '.ico', '.jpg', '.jpeg', '.keystore'};
  return !binary.any(path.toLowerCase().endsWith);
}

String _transform(
  String path,
  String content,
  String name,
  String package,
  String bundle,
) {
  var out = content
      .replaceAll(_oldBundle, bundle)
      .replaceAll(_oldBundleCamel, bundle)
      .replaceAll('package:$_oldPackage/', 'package:$package/')
      .replaceAll('${_oldPackage}_workspace', '${package}_workspace')
      .replaceAll(_oldTitle, name);
  if (path.endsWith('/pubspec.yaml') || path == 'pubspec.yaml') {
    out = out.replaceFirst(
      RegExp('^name: $_oldPackage\$', multiLine: true),
      'name: $package',
    );
  }
  // Flavor display names: "Template", "Template Dev", "Template Staging".
  out = out.replaceAllMapped(
    RegExp('(["=])$_oldName( Dev| Staging)?(?=["\\r\\n]|\$)', multiLine: true),
    (m) => '${m[1]}$name${m[2] ?? ''}',
  );
  return out;
}

/// Rewrites tracked-looking project files; returns changed relative paths.
List<String> rewriteFiles({
  required String root,
  required String name,
  required String package,
  required String bundle,
  required bool dryRun,
}) {
  final changed = <String>[];
  const skipDirs = {'.git', '.dart_tool', 'build', 'Pods', '.gradle', '.idea'};
  for (final e in Directory(
    root,
  ).listSync(recursive: true, followLinks: false)) {
    if (e is! File) continue;
    final rel = e.path.substring(root.length + 1);
    if (rel.split('/').any(skipDirs.contains)) continue;
    if (rel.startsWith('tool/init') || rel.startsWith('tool/test/init'))
      continue;
    if (rel == 'pubspec.lock' || !_isText(rel)) continue;
    final String original;
    try {
      original = e.readAsStringSync();
    } on FileSystemException {
      continue;
    }
    var updated = _transform(rel, original, name, package, bundle);
    if (rel.endsWith('.dart')) updated = _sortPackageImports(updated);
    if (rel == 'README.md') {
      updated = updated.replaceFirst(
        RegExp(r'^# .*$', multiLine: true),
        '# $name',
      );
    }
    if (updated == original) continue;
    changed.add(rel);
    if (!dryRun) e.writeAsStringSync(updated);
  }
  changed.sort();
  return changed;
}

/// Moves MainActivity's kotlin package directory; returns a description or null.
String? moveKotlinPackage(String root, String bundle, {required bool dryRun}) {
  final kotlin = Directory('$root/apps/app/android/app/src/main/kotlin');
  final from = Directory('${kotlin.path}/${_oldBundle.replaceAll('.', '/')}');
  final to = Directory('${kotlin.path}/${bundle.replaceAll('.', '/')}');
  if (!from.existsSync() || from.path == to.path) return null;
  final desc =
      '${from.path.substring(root.length + 1)} -> '
      '${to.path.substring(root.length + 1)}';
  if (dryRun) return desc;
  to.parent.createSync(recursive: true);
  from.renameSync(to.path);
  // Prune now-empty ancestors of the old package (dev/invoketech/...).
  var dir = from.parent;
  while (dir.path != kotlin.path &&
      dir.existsSync() &&
      dir.listSync().isEmpty) {
    dir.deleteSync();
    dir = dir.parent;
  }
  return desc;
}

/// Keeps each contiguous block of `package:` imports alphabetical, as the
/// directives_ordering lint requires after a package rename.
String _sortPackageImports(String source) {
  final lines = source.split('\n');
  final out = <String>[];
  var i = 0;
  bool isImport(String l) => l.startsWith("import 'package:");
  while (i < lines.length) {
    if (!isImport(lines[i])) {
      out.add(lines[i++]);
      continue;
    }
    final block = <String>[];
    while (i < lines.length && isImport(lines[i])) {
      block.add(lines[i++]);
    }
    block.sort();
    out.addAll(block);
  }
  return out.join('\n');
}
