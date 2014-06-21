# stibi oh-my-zsh theme
# http://about.stibi.name
# martin.stiborsky@gmail.com
# http://www.twitter.com/stibi
#

BATTERY_CHARGING_SYMBOL="⚡"
GIT_DIRTY_SYMBOL=""
GIT_CLEAN_SYMBOL=""
FREE_RAM_SYMBOL=""
CPU_LOAD_SYMBOL=""
CPU_TEMPERATURE_SYMBOL=""

BOLD="%{$FX[bold]%}"
RED="%{$FG[009]%}"
ORANGE="%{$FG[208]%}"
GREEN="%{$FG[076]%}"
CYAN="%{$FG[123]%}"
GRAY="%{$FG[250]%}"
RWPWD="%{$FG[123]%}"
ROPWD="%{$FG[192]%}"

RESETCOL="%{$reset_color%}"
RESETFX="%{$FX[reset]%}"
USER="${ORANGE}%n"
MACHINE="${ORANGE}%m"
MYPWD="%~"
TIMESTAMP="%*"

RPROMPT_SYSINFO="${ORANGE}$FREE_RAM_SYMBOL ${GRAY}$STIBI_THEME_FREE_MEMORY \
${ORANGE}$CPU_LOAD_SYMBOL ${GRAY}$STIBI_THEME_CPU_LOAD \
${ORANGE}$CPU_TEMPERATURE_SYMBOL ${GRAY}$STIBI_THEME_CPU_TEMP"

function getFreeMemory {
  local free_memory=`free -m | awk '{if (NR==3) print $4}' | xargs -i echo 'scale=1;{}/1000' | bc`"G"
  echo $free_memory
}

function getCpuLoad() {
  local cpu_load=`uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3 }' | tr -d ","`
  echo $cpu_load
}

function getAverageCpuTemp() {
    local count=0
    local sum=0
    for i in $(sensors | sed -n -r "s/^(Core).*: *\+([0-9]*)\..°.*/\2/p"); do
        ((sum=$sum+$i))
        ((count=$count+1))
    done
    local average_cpu_temp
    ((average_cpu_temp=$sum/$count))
    average_cpu_temp=$average_cpu_temp"°C"
    echo $average_cpu_temp
}

function get_pwd() {
    # TODO vysvetlit, proc nepouzivam %~
    # je to kvuli odsazeni prave casti a z %~ nezjistim, jak je ten string dlouhy
    echo "${PWD/$HOME/~}"
}

# Magic here !!!
# http://stackoverflow.com/questions/10564314/count-length-of-user-visible-string-for-zsh-prompt
function calculateUserVisibleStringLength {
    local myString=$1
    local zero='%([BSUbfksu]|([FB]|){*})'
    local myStringWidth=${#${(S%%)myString//$~zero/}}
    echo $myStringWidth
}

# No need to calculate lenght of this one, because it's placed in $RPROMPT
# and aligned by ZSH automatically
function getBatteryStatus() {
    local batteryStatus
    local batteryStateFromACPI="$(acpi --battery 2>/dev/null)"
    local remainingBatteryPercent="$(echo ${batteryStateFromACPI[(w)4]} | sed -r 's/(^[0-9]+).*/\1/')"
    local batteryChargingStatus="$(echo ${batteryStateFromACPI[(w)3]})"
    if [[ "${batteryChargingStatus}" = "Discharging," ]]; then
        if [[ -z "${remainingBatteryPercent}" ]]; then
            batteryStatus=""
        elif [[ "${remainingBatteryPercent}" -lt 15 ]]; then
            # Pokud je baterka pod 15%, zobrazim misto procent zbyvajici cas
            local remainingBatteryTime="$(echo ${batteryStateFromACPI[(w)5]})"
            batteryStatus="${BOLD}${RED}$BATTERY_CHARGING_SYMBOL${remainingBatteryTime}"
        elif [[ "${remainingBatteryPercent}" -lt 60 ]]; then
            batteryStatus="${ORANGE}$BATTERY_CHARGING_SYMBOL${remainingBatteryPercent}%%"
        elif [[ "${remainingBatteryPercent}" -lt 100 ]]; then
            batteryStatus="${GREEN}$BATTERY_CHARGING_SYMBOL${remainingBatteryPercent}%%"
        else
            batteryStatus=""
        fi
    else
        batteryStatus=""
    fi
    echo $batteryStatus
}

function calculateGitPromptWidth() {
    # Magic here !!!
    # http://stackoverflow.com/questions/10564314/count-length-of-user-visible-string-for-zsh-prompt
    gitinfo=$(git_prompt_info)
    local zero='%([BSUbfksu]|([FB]|){*})'
    local gitPromptWidth=${#${(S%%)gitinfo//$~zero/}}
    echo $gitPromptWidth
}

function setupMyPromptVariables {
    STIBI_THEME_CPU_LOAD=$(getCpuLoad)
    STIBI_THEME_FREE_MEMORY=$(getFreeMemory)
    STIBI_THEME_CPU_TEMP=$(getAverageCpuTemp)
    STIBI_THEME_BATTERY_STATUS=$(getBatteryStatus)
}

function calculateVariablesWidths {
    STIBI_THEME_PROMPT_WIDTH=$(calculateUserVisibleStringLength "${USER}@${MACHINE}:")
    STIBI_THEME_PWD_WIDTH=$(calculateUserVisibleStringLength "${MYPWD}")
    STIBI_THEME_TIMESTAMP_WIDTH=$(calculateUserVisibleStringLength "${TIMESTAMP}")
    STIBI_THEME_RSYSINFO_WIDTH=$(calculateUserVisibleStringLength "${RPROMPT_SYSINFO}")
    STIBI_THEME_GIT_PROMPT_WIDTH=$(calculateGitPromptWidth)
}

function calculatePromptWidth {
    # FIXME: nekde mi tam porad litaji dva znaky, nevim kde :(
    local promptWidth;
    (( promptWidth = $STIBI_THEME_PROMPT_WIDTH + $STIBI_THEME_TIMESTAMP_WIDTH \
        + $STIBI_THEME_PWD_WIDTH + $STIBI_THEME_RSYSINFO_WIDTH \
        + $STIBI_THEME_GIT_PROMPT_WIDTH + 2))
    echo $promptWidth
}

function calculateAdjustedPwdWidth {
    local totalTerminalWidth=$1
    local adjustedPwdWidth
    # Odecitam vsechno krom pwd, abych zjistil, kolik mi tam na pwd zbyde mista
    # TODO lepe zdokumentovat
    ((adjustedPwdWidth = $totalTerminalWidth - $STIBI_THEME_PROMPT_WIDTH - $STIBI_THEME_TIMESTAMP_WIDTH - $STIBI_THEME_RSYSINFO_WIDTH - $STIBI_THEME_GIT_PROMPT_WIDTH))
    echo $adjustedPwdWidth
}

function getFillbarToAlignRightPromptSide {
    local totalTerminalWidth=$1
    local totalVisiblePromptWidth=$2
    # For debug: fillbarSymbol="─"
    local fillbarSymbol=" "
    local fillbar="\${(l.(($totalTerminalWidth - $totalVisiblePromptWidth))..${fillbarSymbol}.)}"
    echo $fillbar
}

function isPromptLongerThanTerminalWidth {
    local totalTerminalWidth=$1
    local totalVisiblePromptWidth=$2
    if [[ $totalVisiblePromptWidth -gt $totalTerminalWidth ]]; then
        return 0
    else
        return 1
    fi
}

function getColorForPwd {
    local pwdColor
    if [[ -w $PWD ]]; then
        pwdColor=${RWPWD}
    else
        pwdColor=${ROPWD}
    fi
    echo $pwdColor
}

function executeMyPreCmd() {
    local termwidth
    # -1 je okraj na prave strane
    (( termwidth = ${COLUMNS} - 1 ))

    STIBI_THEME_FILLBAR=""
    ADJUST_PWD_TO_WIDTH=""

    local visiblePromptWidth=$(calculatePromptWidth)

    if isPromptLongerThanTerminalWidth $termwidth $visiblePromptWidth; then
        ADJUST_PWD_TO_WIDTH=$(calculateAdjustedPwdWidth $termwidth)
    else
        STIBI_THEME_FILLBAR=$(getFillbarToAlignRightPromptSide $termwidth $visiblePromptWidth)
    fi

    # now let's change the color of the path if it's not writable
    STIBI_THEME_PWD_COLOR=$(getColorForPwd)
}

setprompt() {
    # TODO tohle dela co?
    #setopt prompt_subst

    ZSH_THEME_GIT_PROMPT_PREFIX="${ORANGE} [git:"
    ZSH_THEME_GIT_PROMPT_SUFFIX="${ORANGE}]%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_DIRTY="${RED} $GIT_DIRTY_SYMBOL ${RESETCOL}"
    ZSH_THEME_GIT_PROMPT_CLEAN="${GREEN} $GIT_CLEAN_SYMBOL ${RESETCOL}"

    ret_status="%(?,${GREEN}$,${RED}$)"

    PROMPT='
${BOLD}${USER}@${MACHINE}${RESETFX}${GRAY}:$STIBI_THEME_PWD_COLOR\
%$ADJUST_PWD_TO_WIDTH<...<${MYPWD}%<<$(git_prompt_info)\
${(e)STIBI_THEME_FILLBAR} ${RPROMPT_SYSINFO} \
${CYAN}${TIMESTAMP}${RESETCOL}
${ret_status}${RESETCOL} '
    # na konci je mezera, aby se kurzor odsadil od "$" z ret_status
    # ret_status musi byt na novem radku, abych mel dvouradkovy prompt

    RPROMPT='${STIBI_THEME_BATTERY_STATUS}${RESETCOL}'
}

setprompt

TRAPWINCH() {
    # TODO Hmm tak tady uz se zacinam ztracet :)
    zle || return 0
    setupMyPromptVariables
    calculateVariablesWidths
    executeMyPreCmd
    zle reset-prompt
}

autoload -U add-zsh-hook
add-zsh-hook precmd setupMyPromptVariables
add-zsh-hook precmd calculateVariablesWidths
add-zsh-hook precmd executeMyPreCmd
