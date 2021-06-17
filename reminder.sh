SOUND="/home/fgiorget/Music/5glasses.ogg"
SLEEP=${1:-10}
NOTIFICATION_MESSAGE="${2:-Notification message is empty}"

nohup sleep ${SLEEP} > /dev/null 2>&1 && (play ${SOUND} & notify-send "${NOTIFICATION_MESSAGE}") > /dev/null 2>&1 &
