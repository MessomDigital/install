#!/bin/bash
SEMANTIC_PROPERTIES_FILE=$(dirname $BASH_SOURCE)/azure_applicationinsights.properties
if [ -f "$SEMANTIC_PROPERTIES_FILE" ]; then
    . $SEMANTIC_PROPERTIES_FILE
fi

$(dirname $BASH_SOURCE)/semantic_update_service.sh --group-id="$GROUP_ID" --artifact-id="$ARTIFACT_ID"
