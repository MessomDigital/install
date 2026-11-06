#!/bin/sh
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SEMANTIC_PROPERTIES_FILE="$SCRIPT_DIR/semantic_update_service.properties"
if [ -f "$SEMANTIC_PROPERTIES_FILE" ]; then
    . "$SEMANTIC_PROPERTIES_FILE"
fi
START_PROPERTIES_FILE="$SCRIPT_DIR/start-service.properties"
if [ -f "$START_PROPERTIES_FILE" ]; then
    . "$START_PROPERTIES_FILE"
fi
jar=$ARTIFACT_ID
jvmargs=$JVM_ARGS
nohup java $jvmargs -jar "$jar.jar" &
