#!/bin/sh
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SEMANTIC_PROPERTIES_FILE="$SCRIPT_DIR/alert.properties"
if [ -f "$SEMANTIC_PROPERTIES_FILE" ]; then
    . "$SEMANTIC_PROPERTIES_FILE"
fi

SERVICE_VERSION=$(readlink "$JAR_FILE" 2>/dev/null || echo "$JAR_FILE")
curl --location "$SLACK_ALERT_PROD" --header 'Content-Type: application/json' --data '{"text":":broken_heart: '"$SERVICE_NAME - $SERVICE_VERSION"' is not running "}'
