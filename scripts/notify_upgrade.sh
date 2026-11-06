#!/bin/sh
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SEMANTIC_PROPERTIES_FILE="$SCRIPT_DIR/alert.properties"
if [ -f "$SEMANTIC_PROPERTIES_FILE" ]; then
    . "$SEMANTIC_PROPERTIES_FILE"
fi

SERVICE_VERSION=$( readlink $JAR_FILE)
curl --location $SLACK_INFO_PROD --header 'Content-Type: application/json' --data '{"text":":green_heart: Updated '"$SERVICE_NAME - $SERVICE_VERSION"' "}'

