#!/usr/bin/env bash
# v0.64.0 CodexAI. Reproducible native-template test APK; credentials never enter the repository.
set -euo pipefail
cd "$(dirname "$0")/../.."
godot_bin="${GODOT_BIN:-godot}"
sdk_path="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
java_path="${JAVA_HOME:-}"
if [ -z "$sdk_path" ] || [ -z "$java_path" ]; then
  echo 'Set ANDROID_HOME and JAVA_HOME; install build-tools 36.0.0 and Godot 4.7.2 android_debug.apk template.' >&2
  exit 1
fi
# Optional persistent test identity, supplied by CI secrets or a file outside the repository.
# Godot consumes these environment overrides without writing export_credentials.cfg.
if [ -n "${GODOT_ANDROID_KEYSTORE_DEBUG_PATH:-}" ] && [ ! -f "$GODOT_ANDROID_KEYSTORE_DEBUG_PATH" ]; then
  echo 'Configured Android keystore is missing; refusing to silently replace the signing identity.' >&2
  exit 1
fi
if [ -n "${GODOT_ANDROID_KEYSTORE_DEBUG_PATH:-}" ] && { [ -z "${GODOT_ANDROID_KEYSTORE_DEBUG_USER:-}" ] || [ -z "${GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD:-}" ]; }; then
  echo 'External Android keystore requires its alias and password environment variables.' >&2
  exit 1
fi
task_config="$(mktemp -d /tmp/shadepi-android-config.XXXXXX)"
trap 'rm -rf "$task_config"' EXIT
export XDG_CONFIG_HOME="$task_config"
mkdir -p "$task_config/godot" build/android
python3 - "$task_config/godot/editor_settings-4.7.tres" "$sdk_path" "$java_path" <<'PY'
import json,sys
from pathlib import Path
out=Path(sys.argv[1])
lines=['[gd_resource type="EditorSettings" format=3]','','[resource]']
for name,value in [('export/android/android_sdk_path',sys.argv[2]),('export/android/java_sdk_path',sys.argv[3])]:
    lines.append(name+' = '+json.dumps(value))
out.write_text('\n'.join(lines)+'\n')
PY
"$godot_bin" --headless --editor --import --quit 2>&1 | tee "$task_config/import.log"
if grep -Eq 'SCRIPT ERROR|^ERROR:|Parse Error' "$task_config/import.log"; then exit 1; fi
"$godot_bin" --headless --export-debug Android build/android/Shadepi-Echos-in-Neon.apk 2>&1 | tee "$task_config/export.log"
if grep -Eq 'SCRIPT ERROR|^ERROR:|Parse Error' "$task_config/export.log"; then exit 1; fi
"$sdk_path/build-tools/36.0.0/apksigner" verify --print-certs build/android/Shadepi-Echos-in-Neon.apk > build/android/signature.txt
cat build/android/signature.txt
