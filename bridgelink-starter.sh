#!/usr/bin/env bash
# BridgeLink Launcher starter — runs the packaged executable jar.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR="$SCRIPT_DIR/target/bridge-link-launcher-1.3.0.jar"

if [[ ! -f "$JAR" ]]; then
    echo "Error: $JAR not found." >&2
    echo "Build it first with: mvn package (in $SCRIPT_DIR)" >&2
    exit 1
fi

exec java ${JAVA_OPTS:-} -jar "$JAR" "$@"
