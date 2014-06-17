
function get_free_memory {
  local free_memory=`free -m | awk '{if (NR==3) print $4}' | xargs -i echo 'scale=1;{}/1000' | bc`"G"
  echo $free_memory
}

function get_cpu_load() {
  local cpu_load=`uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3 }' | tr -d ","`
  echo $cpu_load
}

function get_average_cpu_temp() {
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

function battery_status() {
    #local acpi
    #acpi="$(acpi --battery 2>/dev/null)"
    local PR_BATTERY
    local BATT_STATE="$(acpi --battery 2>/dev/null)"
    local BATT_PERCENT="$(echo ${BATT_STATE[(w)4]}|sed -r 's/(^[0-9]+).*/\1/')"
    local BATT_STATUS="$(echo ${BATT_STATE[(w)3]})"
    if [[ "${BATT_STATUS}" = "Discharging," ]]; then
        if [[ -z "${BATT_PERCENT}" ]]; then
            PR_BATTERY=""
        elif [[ "${BATT_PERCENT}" -lt 15 ]]; then
            # Pokud je baterka pod 15%, zobrazim misto procent zbyvajici cas
            BATT_REMAINING="$(echo ${BATT_STATE[(w)5]})"
            PR_BATTERY="${FX[bold]}${FG[009]}${BATT_REMAINING}"
        elif [[ "${BATT_PERCENT}" -lt 60 ]]; then
            PR_BATTERY="${FG[010]}${BATT_PERCENT}%%"
        elif [[ "${BATT_PERCENT}" -lt 100 ]]; then
            PR_BATTERY="${FG[040]}${BATT_PERCENT}%%"
        else
            PR_BATTERY=""
        fi
    else
        PR_BATTERY=""
    fi
    echo $PR_BATTERY
}

# TODO tuhle fci uz ted asi nebudu potrebovat, kdyz mam v obou ZSH_THEME_GIT_PROMPT_DIRTY a ZSH_THEME_GIT_PROMPT_CLEAN neco
# nastaveno a oboji je stejne dlouhe
function is_git_dirty() {
    local flag=0 # 0 znamena true, git IS dirty!!
    # pokud je len 0 - adresart je cisty, neni dirty, nastavim flag=1, is_git_dirty fce udelala echo "$ZSH_THEME_GIT_PROMPT_CLEAN" (tahle env musi byt tedy prazdna!!!)
    # nenulova delka znamena, ze parse_git_dirty fce udelala echo "$ZSH_THEME_GIT_PROMPT_DIRTY", ktere jsem nastavil nejaky obsah, ktery se ma zobrazit
    local DIRTY_GIT_LEN=${#$(parse_git_dirty)}

    if [ $DIRTY_GIT_LEN = 0 ]; then
        # adresa je cisty, neni dirty, nastavuji jednicku do flagu, coz znamena false
        flag=1
    fi

    return $fl
}

function get_gitpromptlen() {
    # TODO 11 asi neni dobre
    local COLORCODE_LEN=11
    # TODO nevim, jaktoze je resetcolor jenom 5 dlouhy: %{$reset_color%} - co se doplni za $reset_color ? Asi to bude jenom jeden znak
    local RESETCOLOR_LEN=5
    # TODO melo by to 30, ale staci 27. nechapu, tohle je asi blbe
    local DIRTYGIT_LEN=27
    gitinfo=$(git_prompt_info)
    local gitPromptWidth=${#${(%):-$gitinfo}}
    if [ $gitPromptWidth != 0 ]; then
        (( gitPromptWidth = $gitPromptWidth - $COLORCODE_LEN - $RESETCOLOR_LEN ))
        # TODO podminka uz neni potreba, prejmenovat $DIRTYGIT_LEN a vzdy to odecitat proto oba ZSH_THEME_GIT_PROMPT_DIRTY a
        # ZSH_THEME_GIT_PROMPT_CLEAN jsou stejne dlouhe
        if is_git_dirty; then
            (( gitPromptWidth = $gitPromptWidth - $DIRTYGIT_LEN ))
        fi
    fi
    echo "$gitPromptWidth"
}

function setupMyPromptVariables {
    STIBI_THEME_CPU_LOAD=$(get_cpu_load)
    STIBI_THEME_FREE_MEMORY=$(get_free_memory)
    STIBI_THEME_CPU_TEMP=$(get_average_cpu_temp)
}

function calculateVariablesWidths {
    STIBI_THEME_PROMPT_WIDTH=${#${(%):-%n@%m:}}
    STIBI_THEME_PWD_WIDTH=${#${(%):-%~}}
    STIBI_THEME_TIMESTAMP_WIDTH=${#${(%):-%*}}
    STIBI_THEME_RSYSINFO_WIDTH=${#${(%):-  $STIBI_THEME_FREE_MEMORY  $STIBI_THEME_CPU_LOAD  $STIBI_THEME_CPU_TEMP }}
    STIBI_THEME_GIT_PROMPT_WIDTH=$(get_gitpromptlen)
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
    ((adjustedPwdWidth = $totalTerminalWidth - $STIBI_THEME_PROMPT_WIDTH - $STIBI_THEME_TIMESTAMP_WIDTH - $STIBI_THEME_RSYSINFO_WIDTH - $STIBI_THEME_GIT_PROMPT_WIDTH - 2))
    echo $adjustedPwdWidth
}

function getFillbarToAlignRightPromptSide {
    local totalTerminalWidth=$1
    local totalVisiblePromptWidth=$2
    # For debug: fillbarSymbol="─"
    local fillbarSymbol=" "
    local fillbar="\${(l.(($totalTerminalWidth - $totalVisiblePromptWidth - 2))..${fillbarSymbol}.)}"
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

    RPROMPT='$(battery_status)%{$reset_color%}'
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
