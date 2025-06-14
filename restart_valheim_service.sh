#!/bin/bash

set -o allexport
source /home/valheim/scripts/config/.env
set +o allexport

source /home/valheim/scripts/discord_utils.sh

SERVICE_NAME=valheim-server
LOG_FILE="/home/valheim/logs/restart_valheim.log"
NOW=$(date "+%Y-%m-%d %H:%M:%S")
MAX_WAIT=180  # Maximum 3 minutes d'attente
WAIT_INTERVAL=5
ELAPSED=0

WEBHOOK_ID=$VALHEIM_LOGS_WEBHOOK_ID

embed=$(build_discord_embed \
    "$(get_emoji "warning") Restarting valheim  server..." \
    "Service is now restarting : **${SERVICE_NAME}**" \
    "yellow")
send_discord_payload $WEBHOOK_ID "$embed"

echo "[$NOW] Restarting $SERVICE_NAME..." >> "$LOG_FILE"


# systemd gère le redémarrage
sudo systemctl restart "$SERVICE_NAME"

# Attends que le port 2456 soit ouvert (serveur en ligne)
while ! ss -uln | grep -q ":2456"; do
    sleep $WAIT_INTERVAL
    ELAPSED=$((ELAPSED + WAIT_INTERVAL))

    if [ $ELAPSED -ge $MAX_WAIT ]; then
        embed=$(build_discord_embed \
            "$(get_moji "error") Timeout error" \
            "Port 2456 is still closed after **${MAX_WAIT}** seconds." \
            "red")
        send_discord_payload $WEBHOOK_ID "$embed"

        echo "[$(date "+%Y-%m-%d %H:%M:%S")] ERROR: Timeout — port 2456 is still closed after $MAX_WAIT seconds." >> "$LOG_FILE"
        exit 1
    fi
done

echo "[$(date "+%Y-%m-%d %H:%M:%S")] Port 2456 is open — server likely up." >> "$LOG_FILE"

# Vérif du processus valheim
if pgrep -f valheim_server.x86_64 > /dev/null; then
    embed=$(build_discord_embed \
        "$(get_emoji "success") Restart success" \
        "Valheim server is now running - Restarted in : **${ELAPSED}** sec" \
        "green")
    send_discord_payload $WEBHOOK_ID "$embed"

    echo "[$(date "+%Y-%m-%d %H:%M:%S")] valheim_server process is running." >> "$LOG_FILE"
else
    embed=$( \
        "$(get_emoji "check") Server not found" \
        "Valheim server process is not found !" \
        "yellow")
    send_discord_payload $WEBHOOK_ID "$embed"

    echo "[$(date "+%Y-%m-%d %H:%M:%S")] WARNING: valheim_server process not found!" >> "$LOG_FILE"
fi