#!/usr/bin/env bash
set -euo pipefail

if [ -d "flutter/.git" ]; then
  git -C flutter fetch --depth 1 origin stable
  git -C flutter checkout stable
else
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git
fi

flutter/bin/flutter config --enable-web
flutter/bin/flutter pub get
flutter/bin/flutter build web --release --no-pub --verbose
