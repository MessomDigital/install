#!/bin/sh
SEMANTIC_PROPERTIES_FILE=$(dirname $BASH_SOURCE)/alert.properties
if [ -f "$SEMANTIC_PROPERTIES_FILE" ]; then
    . $SEMANTIC_PROPERTIES_FILE
fi

SERVICE_VERSION=$( readlink $JAR_FILE)

curl --location $SLACK_INFO_PROD --header 'Content-Type: application/json' --data '{"text":":green_heart: Starting '"$SERVICE_NAME - $SERVICE_VERSION"' "}'

