
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
            batteryStatus="${FX[bold]}${FG[009]}${remainingBatteryTime}"
        elif [[ "${remainingBatteryPercent}" -lt 60 ]]; then
            batteryStatus="${FG[010]}${remainingBatteryPercent}%%"
        elif [[ "${remainingBatteryPercent}" -lt 100 ]]; then
            batteryStatus="${FG[040]}${remainingBatteryPercent}%%"
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
    STIBI_THEME_PROMPT_WIDTH=$(calculateUserVisibleStringLength "%n@%m:")
    STIBI_THEME_PWD_WIDTH=$(calculateUserVisibleStringLength "%~")
    STIBI_THEME_TIMESTAMP_WIDTH=$(calculateUserVisibleStringLength "%*")
    # "X" na zacatku a nakonci je kvuli mezere pred a za, funkce ty mezery asi
    # nepocita jako viditelne znaky (TODO) takze mi to nesedlo a musel jsem
    # jinde jeste navic odecitat dvojku (viz git history)
    # Nejsem si uplne jisty, jestli nekecam, ale myslim, ze ne.
    # TODO vyhodit mezery z PROMPT a ty Xka tady a uvidim
    STIBI_THEME_RSYSINFO_WIDTH=$(calculateUserVisibleStringLength "X  $STIBI_THEME_FREE_MEMORY  $STIBI_THEME_CPU_LOAD  $STIBI_THEME_CPU_TEMP X")
    STIBI_THEME_GIT_PROMPT_WIDTH=$(calculateGitPromptWidth)
}

function calculatePromptWidth {
    local promptWidth;
    (( promptWidth = $STIBI_THEME_PROMPT_WIDTH + $STIBI_THEME_TIMESTAMP_WIDTH \
        + $STIBI_THEME_PWD_WIDTH + $STIBI_THEME_RSYSINFO_WIDTH \
        + $STIBI_THEME_GIT_PROMPT_WIDTH ))
    echo $promptWidth
}

function calculateAdjustedPwdWidth {
    local totalTerminalWidth=$1
    local adjustedPwdWidth
    # bez te dvojky na konci se to chovalo blbe, pri uzkem terminalu, spatne se zarovnala prava strana
        # -1 je urcite za mezeru mezi fillbarem a [sysinfo], ale proc to chce -2 si nejsem jisty
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
        pwdColor="${FG[123]}"
    else
        pwdColor="${FG[192]}"
    fi
    echo $pwdColor
}

function executeMyPreCmd() {
    local termwidth
    (( termwidth = ${COLUMNS} - 1 ))

    # TODO jine pojmenovani maybe? Proc ten PR_ prefix?

    STIBI_THEME_FILLBAR=""
    ADJUST_PWD_TO_WIDTH=""

    local visiblePromptWidth=$(calculatePromptWidth)

    if isPromptLongerThanTerminalWidth $termwidth $visiblePromptWidth; then
        ADJUST_PWD_TO_WIDTH=$(calculateAdjustedPwdWidth $termwidth)
    else
        # TODO nekde mi tam litaji dve mezery, proto ty dve -2
        # TODO fix it
        STIBI_THEME_FILLBAR=$(getFillbarToAlignRightPromptSide $termwidth $visiblePromptWidth)
    fi

    # now let's change the color of the path if it's not writable
    STIBI_THEME_PWD_COLOR=$(getColorForPwd)
}

setprompt() {
    # TODO tohle dela co?
    #setopt prompt_subst

    ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[208]%} [git:"
    ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[001]%} %{$reset_color%}%{$FG[208]%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[076]%} %{$reset_color%}%{$FG[208]%}"

    ret_status="%(?,%{$FG[070]%}$,%{$FG[009]%}$)"

    PROMPT='
%{$FX[bold]%}%{$FG[208]%}%n%{$FG[250]%}@%{$FG[208]%}%m%{$FX[reset]%}\
%{$FG[250]%}:%{$STIBI_THEME_PWD_COLOR%}\
%$ADJUST_PWD_TO_WIDTH<...<%~%<<$(git_prompt_info)${(e)STIBI_THEME_FILLBAR} \
%{$FG[208]%}  %{$FG[250]%}$STIBI_THEME_FREE_MEMORY \
%{$FG[208]%}  %{$FG[250]%}$STIBI_THEME_CPU_LOAD \
%{$FG[208]%} %{$FG[250]%}$STIBI_THEME_CPU_TEMP \
%{$FG[123]%}%*%{$reset_color%}
$ret_status%{$reset_color%} '

    RPROMPT='$STIBI_THEME_BATTERY_STATUS%{$reset_color%}'
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
