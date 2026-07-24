#!/usr/bin/env bash
#
# Сборка релизов с единым номером сборки для всех платформ.
#
# Номер (CFBundleVersion / versionCode / file version) берётся из числа коммитов
# в git — монотонно растёт и одинаков на всех платформах для одного коммита.
# Флаг --build-number перекрывает `version: x.y.z+N` из pubspec.yaml сразу для
# iOS, macOS, Android и Windows. Маркетинговую версию (--build-name) не трогаем:
# она остаётся из pubspec.
#
# Использование:
#   scripts/build_release.sh                 # все цели, доступные на этой ОС
#   scripts/build_release.sh ios android     # только выбранные
#   BUILD_OFFSET=1 scripts/build_release.sh   # перезалить из того же коммита
#
# Цели: ios macos android windows linux web
# Ограничения хоста: ios/macos — только macOS; windows — только Windows;
# linux — только Linux; android/web — где угодно.

set -euo pipefail

cd "$(dirname "$0")/.."

# --- flutter на PATH, иначе известный путь SDK на этой машине ---------------
if ! command -v flutter >/dev/null 2>&1; then
  MAC_SDK="/Users/danila/KVLK_Studio/Studio/Projects/flutter/bin"
  if [ -x "$MAC_SDK/flutter" ]; then
    export PATH="$MAC_SDK:$PATH"
  else
    echo "error: flutter не найден в PATH" >&2
    exit 1
  fi
fi

# --- единый номер сборки ----------------------------------------------------
OFFSET="${BUILD_OFFSET:-0}"
BUILD=$(( $(git rev-list --count HEAD) + OFFSET ))
echo "==> build number: $BUILD (offset $OFFSET)"

# --- какие цели собирать ----------------------------------------------------
if [ "$#" -gt 0 ]; then
  TARGETS=("$@")
else
  case "$(uname -s)" in
    Darwin)  TARGETS=(ios macos android web) ;;
    Linux)   TARGETS=(android linux web) ;;
    MINGW*|MSYS*|CYGWIN*) TARGETS=(windows) ;;
    *)       TARGETS=(android web) ;;
  esac
fi

HOST="$(uname -s)"

# Артефакт по платформе. android → appbundle (то, что принимает Play Store);
# нужен apk — добавь 'apk' как отдельную цель.
build_one() {
  case "$1" in
    ios)     [ "$HOST" = Darwin ] || { echo "skip ios: нужен macOS"; return; }
             flutter build ipa       --build-number="$BUILD" ;;
    macos)   [ "$HOST" = Darwin ] || { echo "skip macos: нужен macOS"; return; }
             flutter build macos     --build-number="$BUILD" ;;
    windows) case "$HOST" in MINGW*|MSYS*|CYGWIN*) ;; *) echo "skip windows: нужен Windows"; return ;; esac
             flutter build windows   --build-number="$BUILD" ;;
    linux)   [ "$HOST" = Linux ]  || { echo "skip linux: нужен Linux"; return; }
             flutter build linux     --build-number="$BUILD" ;;
    android) flutter build appbundle --build-number="$BUILD" ;;
    apk)     flutter build apk       --build-number="$BUILD" ;;
    web)     flutter build web       --build-number="$BUILD" ;;
    *)       echo "error: неизвестная цель '$1'" >&2; exit 1 ;;
  esac
}

for t in "${TARGETS[@]}"; do
  echo "==> flutter build $t"
  build_one "$t"
done

echo "==> готово. build number = $BUILD"
