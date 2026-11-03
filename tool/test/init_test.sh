#!/usr/bin/env bash
# Behavior tests for tool/init, run against a throwaway copy of the repo.
# setup_repo.sh in the copy is replaced by a stub; the real one is never run.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/init-test.XXXXXX")"
trap 'rm -rf "$work"' EXIT

fail() { echo "FAIL $1"; exit 1; }
ok() { echo "ok $1"; }

fresh_copy() { # dir
  mkdir -p "$1"
  (cd "$repo" && git ls-files -co --exclude-standard -z | rsync -a --from0 --files-from=- ./ "$1/")
  printf '#!/usr/bin/env bash\necho "$@" >> "$(dirname "$0")/setup_called"\n' >"$1/tool/setup_repo.sh"
  chmod +x "$1/tool/setup_repo.sh"
}
leftovers() { # dir
  grep -rIl --exclude-dir=.git --exclude-dir=.dart_tool --exclude='init*' --exclude=pubspec.lock \
    -e flutter_bloc_template -e flutterBlocTemplate -e invoketech \
    -e 'Flutter BLoC Template' -e 'Template' "$1" || true
}
ARGS=(--name "Acme Shop" --package acme_shop --bundle-id com.acme.shop)

# dry run changes nothing
d="$work/dry"; fresh_copy "$d"
(cd "$d" && git init -q && git add -A >/dev/null 2>&1 && git -c user.name=t -c user.email=t@t commit -qm x)
(cd "$d" && tool/init "${ARGS[@]}" --skip-repo-setup --dry-run >out.txt)
[ -z "$(cd "$d" && git status --porcelain | grep -v out.txt)" ] || fail "dry-run modified files"
grep -q 'apps/app/pubspec.yaml' "$d/out.txt" || fail "dry-run should list files"
ok "dry-run changes nothing"

# full run
d="$work/full"; fresh_copy "$d"
(cd "$d" && tool/init "${ARGS[@]}" --skip-repo-setup >/dev/null)
[ -z "$(leftovers "$d")" ] || fail "leftovers: $(leftovers "$d")"
ok "no leftover template names"
grep -q '^name: acme_shop$' "$d/apps/app/pubspec.yaml" || fail "pubspec name"
grep -q '^name: acme_shop_workspace$' "$d/pubspec.yaml" || fail "workspace name"
grep -rq 'package:acme_shop/' "$d/apps/app/lib" || fail "imports"
grep -q '"appTitle": "Acme Shop"' "$d/packages/l10n/lib/src/l10n/app_hr.arb" || fail "Croatian app title"
grep -q "String get appTitle => 'Acme Shop';" "$d/packages/l10n/lib/src/generated/app_localizations_hr.dart" || fail "generated Croatian app title"
ok "package rename"
# directives_ordering lint: package imports must stay alphabetical
while IFS= read -r f; do
  { grep "^import 'package:" "$f" || true; } | LC_ALL=C sort -c 2>/dev/null || fail "import order in $f"
done < <(find "$d/apps" "$d/packages" -name '*.dart' -not -path '*/.dart_tool/*')
ok "package imports sorted"
f="$d/apps/app/android/app/build.gradle.kts"
grep -q 'namespace = "com.acme.shop"' "$f" || fail "namespace"
grep -q 'applicationId = "com.acme.shop"' "$f" || fail "applicationId"
[ -f "$d/apps/app/android/app/src/main/kotlin/com/acme/shop/MainActivity.kt" ] || fail "kotlin dir"
[ ! -d "$d/apps/app/android/app/src/main/kotlin/dev" ] || fail "old kotlin dir remains"
grep -q '^package com.acme.shop$' "$d/apps/app/android/app/src/main/kotlin/com/acme/shop/MainActivity.kt" || fail "kotlin package"
grep -q 'applicationId = "com.acme.shop.dev"' "$d/apps/app/android/app/flavorizr.gradle.kts" || fail "flavor id"
grep -q 'value = "Acme Shop Staging"' "$d/apps/app/android/app/flavorizr.gradle.kts" || fail "flavor name"
ok "android"
grep -q 'PRODUCT_BUNDLE_IDENTIFIER = com.acme.shop.RunnerTests;' "$d/apps/app/ios/Runner.xcodeproj/project.pbxproj" || fail "RunnerTests id"
grep -q '^BUNDLE_DISPLAY_NAME=Acme Shop Dev$' "$d/apps/app/ios/Flutter/devDebug.xcconfig" || fail "xcconfig"
grep -q '^BUNDLE_NAME=Acme Shop$' "$d/apps/app/ios/Flutter/prodRelease.xcconfig" || fail "xcconfig prod"
ok "ios"
grep -q 'bundleId: "com.acme.shop.staging"' "$d/apps/app/pubspec.yaml" || fail "flavorizr bundleId"
grep -q 'name: "Acme Shop Dev"' "$d/apps/app/pubspec.yaml" || fail "flavorizr name"
grep -q 'bundle_identifier: com.acme.shop.staging' "$d/codemagic.yaml" || fail "codemagic bundle"
grep -q 'PACKAGE_NAME: "com.acme.shop"' "$d/codemagic.yaml" || fail "codemagic package"
head -1 "$d/README.md" | grep -qx '# Acme Shop' || fail "README title"
ok "flavorizr, codemagic, README"
[ ! -e "$d/tool/setup_called" ] || fail "setup_repo ran despite --skip-repo-setup"
ok "skip-repo-setup"

# repo setup is called by default, forwarding --repo
d="$work/setup"; fresh_copy "$d"
(cd "$d" && tool/init "${ARGS[@]}" --repo acme/shop >/dev/null)
grep -qx 'acme/shop' "$d/tool/setup_called" || fail "setup_repo not called with repo"
ok "calls setup_repo.sh"

# validation
d="$work/bad"; fresh_copy "$d"
(cd "$d" && git init -q && git add -A >/dev/null 2>&1 && git -c user.name=t -c user.email=t@t commit -qm x)
if (cd "$d" && tool/init --name X --package Bad-Name --bundle-id com.acme.shop --skip-repo-setup >/dev/null 2>&1); then
  fail "invalid package accepted"
fi
if (cd "$d" && tool/init --name X --package ok_name --bundle-id nodots --skip-repo-setup >/dev/null 2>&1); then
  fail "invalid bundle id accepted"
fi
if (cd "$d" && tool/init --name "Shop: Mobile" --package ok_name --bundle-id com.acme.shop --skip-repo-setup >/dev/null 2>&1); then
  fail "YAML-unsafe display name accepted"
fi
if (cd "$d" && tool/init --name "Bob's Shop" --package ok_name --bundle-id com.acme.shop --skip-repo-setup >/dev/null 2>&1); then
  fail "Dart-unsafe apostrophe accepted"
fi
[ -z "$(cd "$d" && git status --porcelain)" ] || fail "invalid input modified files"
ok "validation"
echo "all init tests passed"
