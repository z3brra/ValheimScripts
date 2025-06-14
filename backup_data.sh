#! /bin/bash

set -o allexport
source /home/valheim/scripts/config/.env
set +o allexport

source /home/valheim/scripts/discord_utils.sh

# === CONFIGURATION ===
SAVE_DIR="/home/valheim/.config/unity3d/IronGate/Valheim/worlds_local"
BACKUP_DIR="/home/valheim/backups"
LOG_FILE="/home/valheim/logs/backup_valheim.log"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="world_backup_$TIMESTAMP.tar.gz"
MAX_BACKUPS=7

WEBHOOK_ID=$VALHEIM_LOGS_WEBHOOK_ID


# === CREATION DU FICHIER LOG SI IL N EXISTE PAS ===
#if [ ! -f "$LOG_FILE" ]; then
#    touch "$LOG_FILE"
#    chown :valheim "$LOG_FILE"
#    chmod 775 "$LOG_FILE"
#fi


# === BACKUP ===
if [ -d "$SAVE_DIR" ]; then
    if [ ! -d "$BACKUP_DIR" ]; then
        embed=$(build_discord_embed \
            "$(get_emoji "error") Backup error" \
            "Backup dir not found or does not exist : **${BACKUP_DIR}**" \
            "red")
        send_discord_payload $WEBHOOK_ID "$embed"
        echo "[$(date '+%Yè%m-%d %H:%M:%S')] ERROR : Backup directory not found: $BACKUP_DIR" >> "$LOG_FILE"
        exit 1
    fi

    tar -czf "$BACKUP_DIR/$BACKUP_NAME" "$SAVE_DIR"

    embed=$(build_discord_embed \
        "$(get_emoji "success") Backup successfully" \
        "Backup name : **${BACKUP_NAME}**" \
        "green")

    send_discord_payload $WEBHOOK_ID "$embed"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup successful: $BACKUP_NAME" >> "$LOG_FILE"
else
    embed=$(build_discord_embed \
        "$(get_emoji "error") Backup error" \
        "Save directory not found or does not exist : **${SAVE_DIR}**" \
        "red")
    send_discord_payload $WEBHOOK_ID "$embed"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Save directory not found: $SAVE_DIR" >> "$LOG_FILE"
    exit 1
fi

# === ROTATION DES BACKUPS ===
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/world_backup_*.tar.gz 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    OLDEST=$(ls -1t "$BACKUP_DIR"/world_backup_*.tar.gz | tail -n +$(($MAX_BACKUPS + 1)))
    echo "$OLDEST" | while read -r file; do
        rm -f "$file"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleted old backup : $(basename "$file")" >> "$LOG_FILE"
    done
fi