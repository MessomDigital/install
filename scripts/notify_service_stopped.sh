#!/bin/sh
SEMANTIC_PROPERTIES_FILE=$(dirname $BASH_SOURCE)/alerts.properties
if [ -f "$SEMANTIC_PROPERTIES_FILE" ]; then
    . $SEMANTIC_PROPERTIES_FILE
fi

SERVICE_VERSION=$( readlink $JAR_FILE)
curl --location $SLACK_ALERT_PROD --header 'Content-Type: application/json' --data '{"text":":broken_heart: '"$SERVICE_NAME - $SERVICE_VERSION"' is not running "}'

