#!/bin/bash

# TODO notifikace

ONE_STEP="8000"
# TODO testovat, jestli existuje
BACKLIGHT_DEVICE="/sys/class/backlight/gmux_backlight"

currentBacklightLevel=$(cat ${BACKLIGHT_DEVICE}/brightness)
maxBacklightLevel=$(cat ${BACKLIGHT_DEVICE}/max_brightness)
minBacklightLevel="8231"

case $1 in
    up)
        ((newBacklightLevel=${currentBacklightLevel} + ${ONE_STEP}))
        if [[ ${newBacklightLevel} -gt ${maxBacklightLevel} ]]; then
            newBacklightLevel=${maxBacklightLevel}
        fi
        ;;
    down)
        ((newBacklightLevel=${currentBacklightLevel} - ${ONE_STEP}))
        if [[ ${newBacklightLevel} -lt ${minBacklightLevel} ]]; then
            newBacklightLevel=${minBacklightLevel}
        fi
        ;;
    *)
        echo "Usage: ${FUNCNAME} [ up | down | help ]"
        exit 1
        ;;
esac

echo ${newBacklightLevel} | tee ${BACKLIGHT_DEVICE}/brightness

# Zatim nepremava notify-send "brightness: ${newBacklightLevel}"
