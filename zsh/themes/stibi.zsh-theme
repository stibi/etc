
function get_free_memory {
  MY_FREE_RAM=`free -m | awk '{if (NR==3) print $4}' | xargs -i echo 'scale=1;{}/1000' | bc`"G"
}

function get_cpu_load() {
  #uptime | awk '{print $11}' | tr ',' ' '
  #MY_CPU_LOAD=`uptime | awk '{print $10}' | tr -d ','`
  MY_CPU_LOAD=`uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3 }' | tr -d ","`
}

function get_average_cpu_temp() {
    local count=0
    local sum=0
    for i in $(sensors | sed -n -r "s/^(Core).*: *\+([0-9]*)\..°.*/\2/p"); do
        ((sum=$sum+$i))
        ((count=$count+1))
    done
    ((AVERAGE_CPU_TEMP=$sum/$count))
    MY_AVERAGE_CPU_TEMP=$AVERAGE_CPU_TEMP"°C"
}

function get_pwd() {
    # TODO vysvetlit, proc nepouzivam %~
    # je to kvuli odsazeni prave casti a z %~ nezjistim, jak je ten string dlouhy
    echo "${PWD/$HOME/~}"
}

function battery_status() {
    #local acpi
    #acpi="$(acpi --battery 2>/dev/null)"
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
    DIRTY_GIT_LEN=${#$(parse_git_dirty)}

    if [ $DIRTY_GIT_LEN = 0 ]; then
        # adresa je cisty, neni dirty, nastavuji jednicku do flagu, coz znamena false
        flag=1
    fi

    return $flag
}


function get_gitpromptlen() {
    # TODO 11 asi neni dobre
    COLORCODE_LEN=11
    # TODO nevim, jaktoze je resetcolor jenom 5 dlouhy: %{$reset_color%} - co se doplni za $reset_color ? Asi to bude jenom jeden znak
    RESETCOLOR_LEN=5
    # TODO melo by to 30, ale staci 27. nechapu, tohle je asi blbe
    DIRTYGIT_LEN=27
    gitinfo=$(git_prompt_info)
    GITPROMPTSIZE=${#${(%):-$gitinfo}}
    if [ $GITPROMPTSIZE != 0 ]; then
        (( GITPROMPTSIZE = $GITPROMPTSIZE - $COLORCODE_LEN - $RESETCOLOR_LEN ))
        # TODO podminka uz neni potreba, prejmenovat $DIRTYGIT_LEN a vzdy to odecitat proto oba ZSH_THEME_GIT_PROMPT_DIRTY a
        # ZSH_THEME_GIT_PROMPT_CLEAN jsou stejne dlouhe
        if is_git_dirty; then
            (( GITPROMPTSIZE = $GITPROMPTSIZE - $DIRTYGIT_LEN ))
        fi
    fi
}

function myprecmd() {
    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))

    # TODO jine pojmenovani maybe? Proc ten PR_ prefix?

    PR_FILLBAR=""
    PR_PWDLEN=""

    #local promptsize=${#${(%):%n@%m}}
    # TODO kua jak tohle presne funguje, hlavne to :-
    local promptsize=${#${(%):-%n@%m:}}
    local pwdsize=${#${(%):-%~}}
    local timestampsize=${#${(%):-%*}}

    # asi zatim netreba: local zero='%([BSUbfksu]|([FB]|){*})'
    get_free_memory
    get_cpu_load
    get_average_cpu_temp
    #freeram=$(get_free_RAM)
    #currentload=$(get_load)
    # asi zatim netreba: freeramsize=${#${(S%%)freeram//$~zero/}}
    # Mezera pred budikem oddeluje sysinfo PWD
    sysinfosize=${#${(%):-  $MY_FREE_RAM  $MY_CPU_LOAD  $MY_AVERAGE_CPU_TEMP }}


    get_gitpromptlen
    #gitinfo=$(git_prompt_info)
    #gitinfosize=${#${(%):-$gitinfo}}
    #COLORCODE_LEN=12
    #gitinfo=$(git_prompt_info)
    #local gitpromptlen=$(get_gitpromptlen)
    #finalgitinfosize

    #cpu_load_len=${#${(%):-$MY_CPU_LOAD}}
    # TODO pripocist do sysinfosize
    #cpu_temp_len=${#${(%):-$AVERAGE_CPU_TEMP}}
    #(( sysinfosize = $sysinfosize + $get_average_cpu_temp ))

    local total_visible_prompt_len
    # ten +1 na konci je kvuli mezere na prave strane, mezi fillbarem a [sysinfo], spust si debug fill a uvidis to
    (( total_visible_prompt_len = $promptsize + $timestampsize + $pwdsize + $sysinfosize + $GITPROMPTSIZE ))

    if [[ $total_visible_prompt_len -gt $TERMWIDTH ]]; then
        # bez te dvojky na konci se to chovalo blbe, pri uzkem terminalu, spatne se zarovnala prava strana
        # -1 je urcite za mezeru mezi fillbarem a [sysinfo], ale proc to chce -2 si nejsem jisty
        ((PR_PWDLEN = $TERMWIDTH - $promptsize - $timestampsize - $sysinfosize - $GITPROMPTSIZE - 2))
    else
        # TODO nekde mi tam litaji dve mezery, proto ty dve -2
        # TODO fix it
        PR_FILLBAR="\${(l.(($TERMWIDTH - $total_visible_prompt_len - 2))..${PR_HBAR}.)}"
    fi

    # now let's change the color of the path if it's not writable
    if [[ -w $PWD ]]; then
        PR_PWDCOLOR="${FG[123]}"
    else
        PR_PWDCOLOR="${FG[192]}"
    fi
}

#local smiley="%(?,%{$fg[green]%}☺ %{$reset_color%},%{$fg[red]%}☹ %{$reset_color%})"

#PROMPT='$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'
#PROMPT='%{$fg_bold[green]%}%n@%m% %  %{$reset_color%}'

setprompt() {
    # TODO tohle dela co?
    #setopt prompt_subst

    ###
    # Modify Git prompt
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[208]%} [git:"
    ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[001]%} %{$reset_color%}%{$FG[208]%}"
    #ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[red]%}!%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[076]%} %{$reset_color%}%{$FG[208]%}"

    #ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
    #ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹"
    #ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
    #ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
    #ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═"
    #ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭

    # TODO prejmenovat promenou na neco hezciho
    # For debug: PR_HBAR="─"
    PR_HBAR=" "

    ret_status="%(?,%{$FG[070]%}$,%{$FG[009]%}$)"
    #ret_status="%{$FG[070]%}$"

    PROMPT='
%{$FX[bold]%}%{$FG[208]%}%n%{$FG[250]%}@%{$FG[208]%}%m%{$FX[reset]%}\
%{$FG[250]%}:%{$PR_PWDCOLOR%}\
%$PR_PWDLEN<...<%~%<<$(git_prompt_info)${(e)PR_FILLBAR} \
%{$FG[208]%}  %{$FG[250]%}$MY_FREE_RAM \
%{$FG[208]%}  %{$FG[250]%}$MY_CPU_LOAD \
%{$FG[208]%} %{$FG[250]%}$MY_AVERAGE_CPU_TEMP \
%{$FG[123]%}%*%{$reset_color%}
$ret_status%{$reset_color%} '

    RPROMPT='$(battery_status)%{$reset_color%}'
}

setprompt

#TMOUT=1
#TRAPALRM() {
#    zle reset-prompt
#}

TRAPWINCH() {
    # TODO Hmm tak tady uz se zacinam ztracet :)
    zle || return 0
    myprecmd
    #setprompt
    zle reset-prompt
}

autoload -U add-zsh-hook
add-zsh-hook precmd myprecmd
