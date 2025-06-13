#! bin/bash

get_discord_color() {
    case "$1" in
        green)     echo 2926237 ;;
        red)       echo 16738657 ;;
        yellow)    echo 16772721 ;;
        blue)      echo 5793266 ;;
        grey|gray) echo 12434877 ;;
        *)         echo 2306866 ;;
    esac
}

build_discord_embed() {
    local title="$1"
    local description="$2"
    local color_name="$3"

    local color
    color=$(get_discord_color "$color_name")

    local timestamp
    timestamp=$(date --iso-8601=seconds)

    cat <<EOF
{
    "embeds": [
        {
            "title": "$title",
            "description": "$description",
            "color": $color,
            "footer": {
                "text": "🕒 Sent automatically"
            },
            "timestamp": "$timestamp"
        }
    ]
}
EOF
}

send_discord_payload() {
    local webhook_url="https://discord.com/api/webhooks/${1}"
    local payload="$2"

    curl -s -H "Content-Type: application/json" -d "$payload" "$webhook_url" > /dev/null
}

get_emoji() {
    case "$1" in
        success) echo ":white_check_mark:" ;;
        error)   echo ":x:" ;;
        warning) echo ":warning:" ;;
        info)    echo ":information_source:" ;;
        restart) echo ":arrows_counterclockwise:" ;;
        check)   echo ":mag:" ;;
        clock)   echo ":clock3:" ;;
        rocket)  echo ":rocket:" ;;
        skull)   echo ":skull:" ;;
        hammer)  echo ":hammer:" ;;
        fire)    echo ":fire:" ;;
        heart)   echo ":heart:" ;;
        *)       echo "" ;;
    esac
}