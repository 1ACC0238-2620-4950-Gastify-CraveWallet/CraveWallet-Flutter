#!/usr/bin/env bash
set -euo pipefail

: "${API_BASE_URL:?Set API_BASE_URL to the public HTTPS backend URL}"
if [[ "$API_BASE_URL" != https://* ]]; then
  echo 'API_BASE_URL must use HTTPS.' >&2
  exit 1
fi

flutter_sdk="$PWD/.render-flutter-sdk"
if [[ ! -x "$flutter_sdk/bin/flutter" ]]; then
  git clone --depth 1 --branch 3.50.0 https://github.com/flutter/flutter.git "$flutter_sdk"
fi
export PATH="$flutter_sdk/bin:$PATH"
export FLUTTER_SUPPRESS_ANALYTICS=true

flutter pub get --enforce-lockfile
flutter build web --release --no-pub --base-href / \
  --dart-define="API_BASE_URL=${API_BASE_URL%/}"
