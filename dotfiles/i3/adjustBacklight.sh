#!/bin/bash

DISPLAY_ADJUSTMENT="8000"
# TODO testovat, jestli existuje
DISPLAY_BACKLIGHT_DEVICE="/sys/class/backlight/gmux_backlight"
MAX_DISPLAY_BACKLIGHT=$(cat ${DISPLAY_BACKLIGHT_DEVICE}/max_brightness)
MIN_DISPLAY_BACKLIGHT="8231"

KEYBOARD_ADJUSTMENT="30"
# TODO testovat, jestli existuje
KEYBOARD_BACKLIGHT_DEVICE="/sys/class/leds/smc::kbd_backlight"
MAX_KEYBOARD_BACKLIGHT=$(cat ${KEYBOARD_BACKLIGHT_DEVICE}/max_brightness)
MIN_KEYBOARD_BACKLIGHT="0"

function adjustDisplay() {
    local currentBacklightLevel=$(cat ${DISPLAY_BACKLIGHT_DEVICE}/brightness)
    case $1 in
        up)
            setDisplayBrightness $((currentBacklightLevel + DISPLAY_ADJUSTMENT))
        ;;
        down)
            setDisplayBrightness $((currentBacklightLevel - DISPLAY_ADJUSTMENT))
        ;;
    esac
}

function setDisplayBrightness() {
    local backlightLevel=$1
    if [ $backlightLevel -lt $MIN_DISPLAY_BACKLIGHT ]; then
        backlightLevel=$MIN_DISPLAY_BACKLIGHT
    elif [ $backlightLevel -gt $MAX_DISPLAY_BACKLIGHT ]; then
        backlightLevel=$MAX_DISPLAY_BACKLIGHT
    fi
    echo ${backlightLevel} > ${DISPLAY_BACKLIGHT_DEVICE}/brightness
    local backlightLevelPercentage=$[((${backlightLevel} * 100) / ${MAX_DISPLAY_BACKLIGHT})]
    notify-send -h int:value:${backlightLevelPercentage} "Display backlight %p"
}

function adjustKeyboard() {
    local currentBacklightLevel=$(cat ${KEYBOARD_BACKLIGHT_DEVICE}/brightness)
    case $1 in
        up)
            setKeyboardBrightness $((currentBacklightLevel + KEYBOARD_ADJUSTMENT))
        ;;
        down)
            setKeyboardBrightness $((currentBacklightLevel - KEYBOARD_ADJUSTMENT))
        ;;
    esac
}

function setKeyboardBrightness() {
    local backlightLevel=$1
    if [ $backlightLevel -lt $MIN_KEYBOARD_BACKLIGHT ]; then
        backlightLevel=$MIN_KEYBOARD_BACKLIGHT
    elif [ $backlightLevel -gt $MAX_KEYBOARD_BACKLIGHT ]; then
        backlightLevel=$MAX_KEYBOARD_BACKLIGHT
    fi
    echo ${backlightLevel} > ${KEYBOARD_BACKLIGHT_DEVICE}/brightness
    local backlightLevelPercentage=$[((${backlightLevel} * 100) / ${MAX_KEYBOARD_BACKLIGHT})]
    notify-send -h int:value:${backlightLevelPercentage} "Keyboard backlight %p"
}

case $1 in
    display)
        adjustDisplay $2
    ;;
    keyboard)
        adjustKeyboard $2
    ;;
    *)
        echo "Usage: ${FUNCNAME} [display|keyboard] [up|down]"
        exit 1
    ;;
esac
