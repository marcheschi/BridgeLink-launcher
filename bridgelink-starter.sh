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

# Run from the project root so the launcher's relative "jre/bin/java" lookup
# resolves deterministically, and make sure a JavaFX-capable JRE is present.
cd "$SCRIPT_DIR"
if [[ ! -x jre/bin/java ]]; then
    ./setup-jre.sh
fi

# Mirth must run on the bundled JavaFX JRE (its openjfx.jar has no natives);
# JAVA_HOME is the launcher's fallback when no bundled path matches.
export JAVA_HOME="$SCRIPT_DIR/jre"

exec java ${JAVA_OPTS:-} -jar "$JAR" "$@"
