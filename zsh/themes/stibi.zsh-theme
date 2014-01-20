function get_RAM {
  free -m | awk '{if (NR==3) print $4}' | xargs -i echo 'scale=1;{}/1000' | bc
}
 
function get_nr_jobs() {
  jobs | wc -l
}
 
function get_nr_CPUs() {
  grep -c "^processor" /proc/cpuinfo
}
 
function get_load() {
  uptime | awk '{print $11}' | tr ',' ' '
}


local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ %s)"
PROMPT='${ret_status}%{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'

RPROMPT='%{$fg_bold[red]%}[$(get_nr_jobs), $(get_RAM)G, $(get_load)($(get_nr_CPUs))] %{$fg_bold[green]%}%*%{$reset_color%}'

TMOUT=1

TRAPALRM() {
    zle reset-prompt
}

ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
