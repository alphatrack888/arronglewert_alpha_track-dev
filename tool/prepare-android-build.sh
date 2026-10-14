#!/usr/bin/env bash
# Load build env into your *current* shell (do not execute directly):
#   source ~/.../alpha_track_app/tool/prepare-android-build.sh
#   . ~/.../alpha_track_app/tool/prepare-android-build.sh

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "This script must be sourced so JAVA_HOME stays in your terminal."
  echo ""
  echo "  source \"$(cd "$(dirname "$0")\" && pwd)/prepare-android-build.sh\""
  echo ""
  exit 0
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JDK_HOME="/usr/lib/jvm/java-21-openjdk"

if [[ ! -d "$JDK_HOME" ]]; then
  echo "JDK not found at $JDK_HOME — install java-21-openjdk-devel or edit this script."
  return 1
fi

export JAVA_HOME="$JDK_HOME"
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

if command -v flutter >/dev/null 2>&1; then
  flutter config --jdk-dir="$JAVA_HOME" >/dev/null 2>&1 || true
fi

LOCAL_PROPS="$ROOT/android/gradle-local.properties"
if [[ ! -f "$LOCAL_PROPS" ]]; then
  cp "$ROOT/android/gradle-local.properties.example" "$LOCAL_PROPS"
  echo "Created android/gradle-local.properties from example."
fi

echo "Android build environment loaded."
echo "  JAVA_HOME=$JAVA_HOME"
echo "  ANDROID_HOME=$ANDROID_HOME"
echo ""
echo "Next (close heavy apps if RAM is tight; swap was full during prior OOM):"
echo "  cd \"$ROOT/android\" && ./gradlew --stop"
echo "  cd \"$ROOT\""
echo "  flutter pub get"
echo "  flutter build apk --debug"
