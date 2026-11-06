#!/bin/bash
# Definerer variabler
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
echo "Script dir is $SCRIPT_DIR"
SEMANTIC_PROPERTIES_FILE="$SCRIPT_DIR/alert.properties"
LOCAL_OVERRIDE_FILE="$HOME/local_override.properties"
KILL_SCRIPT="$SCRIPT_DIR/kill-service.sh"
START_SCRIPT="$SCRIPT_DIR/start-service.sh"
NOTIFY_STOPPED_SCRIPT="$SCRIPT_DIR/notify_service_stopped.sh"
NOTIFY_DOWN_SCRIPT="$SCRIPT_DIR/notify_service_down.sh"
NOTIFY_STARTED_SCRIPT="$SCRIPT_DIR/notify_startup.sh"
WAIT_TIME=0.1  # 100ms
if [ -f "$SEMANTIC_PROPERTIES_FILE" ]; then
    . "$SEMANTIC_PROPERTIES_FILE"
  else
    echo Finner ikke alert.properties filen i $SCRIPT_DIR, kan ikke sende varsling til Slack
    exit
fi

if [ -f "$LOCAL_OVERRIDE_FILE" ]; then
    . "$LOCAL_OVERRIDE_FILE"
fi

KILL_ON_DOWN="${KILL_ON_DOWN:-true}"  # default hvis ikke satt i alert.properties

should_kill_service() {
  case "$(printf '%s' "$KILL_ON_DOWN" | tr '[:upper:]' '[:lower:]')" in
    1|true|yes|on) return 0 ;;
    0|false|no|off) return 1 ;;
    *) echo "Ugyldig KILL_ON_DOWN='$KILL_ON_DOWN', bruker default=true"; return 0 ;;
  esac
}




# Sjekker om kill_service.sh og start_service.sh eksisterer og er kjørbare
if [ ! -x "$KILL_SCRIPT" ]; then
    echo "FEIL: $KILL_SCRIPT finnes ikke eller er ikke kjørbar"
    exit 1
fi

if [ ! -x "$START_SCRIPT" ]; then
    echo "FEIL: $START_SCRIPT finnes ikke eller er ikke kjørbar"
    exit 1
fi

echo "Sjekker status på tjenesten..."

# Prøver å hente status og lagrer responsen
#RESPONSE=$(curl -s "$HEALTH_CHECK_URL" 2>/dev/null)
echo "Health check URL: $HEALTH_CHECK_URL"
RESPONSE=$(curl -s "$HEALTH_CHECK_URL" )
CURL_STATUS=$?
echo Response: $RESPONSE
echo Curl_status: $CURL_STATUS
# Sjekker først om curl kommandoen var vellykket
if [ $CURL_STATUS -ne 0 ]; then
    echo "Tjenesten svarer ikke. Starter tjenesten på nytt..."
    if should_kill_service; then
      echo "Killer tjenesten..."
      #FIXME $KILL_SCRIPT
    fi
    $NOTIFY_STOPPED_SCRIPT
    sleep $WAIT_TIME
    $START_SCRIPT > /dev/null
    $NOTIFY_STARTED_SCRIPT
    exit 0
fi

# Sjekker om responsen inneholder "UP" status
if echo "$RESPONSE" | grep -q '"Status":"UP"'; then
    echo "Tjenesten kjører normalt (Status: UP)"
    exit 0
else
    echo "Tjenesten rapporterer ikke 'UP' status. Starter tjenesten på nytt..."
    if should_kill_service; then
      echo "Killer tjenesten..."
      #FIXME $KILL_SCRIPT
    fi
    "$NOTIFY_DOWN_SCRIPT" "$RESPONSE"
    sleep $WAIT_TIME
    $NOTIFY_STARTED_SCRIPT
    $START_SCRIPT > /dev/null
    exit 0
fi
