#!/bin/sh
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SEMANTIC_PROPERTIES_FILE="$SCRIPT_DIR/alert.properties"
if [ -f "$SEMANTIC_PROPERTIES_FILE" ]; then
    . "$SEMANTIC_PROPERTIES_FILE"
  else
    echo Finner ikke alert.properties filen i $SCRIPT_DIR, kan ikke sende varsling til Slack
    exit
fi

SERVICE_VERSION=$(readlink "$JAR_FILE" 2>/dev/null || echo "$JAR_FILE")
RESPONSE="${1:-}"
MESSAGE=":broken_heart: ${SERVICE_NAME} - ${SERVICE_VERSION} is DOWN."
SLACK_ALERT_PROD=$(printf '%s' "${SLACK_ALERT_PROD:-}" | tr -d '\r')

if [ -z "$SLACK_ALERT_PROD" ]; then
  echo "FEIL: SLACK_ALERT_PROD er ikke satt."
  exit 1
fi

if [ -n "${1:-}" ] && [ -n "$(printf '%s' "${1:-}" | tr -d '[:space:]')" ]; then
  RESPONSE="${1}"
  PAYLOAD=$(jq -nc \
    --arg text "$MESSAGE" \
    --arg response "$RESPONSE" \
    '{text: $text, attachments: [{color: "#d00000", text: ("```json\n" + $response + "\n```"), mrkdwn_in: ["text"]}]}')
else
  PAYLOAD=$(jq -nc \
    --arg text "$MESSAGE" \
    '{text: $text}')
fi
echo "Sending Slack alert to $SLACK_ALERT_PROD with payload:"
echo "$PAYLOAD"

CURL_RESPONSE=$(curl --silent --show-error \
  --request POST "$SLACK_ALERT_PROD" \
  --header 'Content-Type: application/json' \
  --data "$PAYLOAD" \
  --write-out '\n%{http_code}')

HTTP_CODE=$(printf '%s' "$CURL_RESPONSE" | tail -n 1)
BODY=$(printf '%s' "$CURL_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" != "200" ]; then
  echo "FEIL: Slack webhook svarte med HTTP $HTTP_CODE"
  [ -n "$BODY" ] && echo "$BODY"
  exit 1
fi

if [ "$BODY" != "ok" ]; then
  echo "FEIL: Uventet respons fra Slack webhook: $BODY"
  exit 1
fi

echo "Slack-varsel sendt."
