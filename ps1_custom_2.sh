#!/bin/bash

function get_color {
  if [[ "$#" == "0" ]]; then
    echo -e "\[\033[0m\]"
  elif [[ "$#" == "1" ]]; then
    local color="$1"
    echo -e "\[\033[0m\033[38;5;${color}m\]"
  elif [[ "$#" == "2" ]]; then
    local fg="$1"
    local bg="$2"
    echo -e "\[\033[38;5;${fg}m\]\[\033[48;5;${bg}m\]"
  fi
}

function separator_section {
  echo "$(get_color 255)]-[$(get_color)"
}

function open_separator_section {
  echo "$(get_color 255)[$(get_color)"
}

function close_separator_section {
  echo "$(get_color 255)]$(get_color)"
}

function open_tag {
    local b="\ue0b2"
    if [[ "$#" == "2" ]]; then
        echo -e "$(get_color $2)$b$(get_color $1 $2)"
    elif [[ "$#" == "3" ]]; then
        echo -e "$(get_color $2 $3)$b$(get_color $1 $2)"
    fi
}


function close_tag {
    local b="\ue0b0"
    if [[ "$#" == "2" ]]; then
        echo -e "$(get_color $2)${b}$(get_color $1)"
    elif [[ "$#" == "3" ]]; then
        echo -e "$(get_color $2 $3)${b}$(get_color $1 $3)"
    fi
}

declare -A git_on_branch=(
  ["en"]="On branch"
  ["ca"]="En la branca"
)

declare -A git_work_clean=(
  ["en"]="working directory clean"
  ["ca"]="La vostra branca està al dia"
)

declare -A git_branch_ahead_of=(
  ["en"]="Your branch is ahead of"
  ["ca"]="La vostra branca està davant de"
)

declare -A  git_staged=(
  ["en"]="Changes not staged for commit"
  ["ca"]="Canvis no «staged» per a cometre"
)

declare -A git_to_commit=(
  ["en"]="Changes to be committed"
  ["ca"]="Canvis a cometre"
)

declare -A git_nothing_to_commit=(
  ["en"]="nothing to commit"
  ["ca"]="no hi ha res a cometre"
)

function git_color {
  local lang="$1"
  local git_status="$(git status 2> /dev/null)"
  local on_branch="${git_on_branch[$lang]} ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
        
        local branch=${BASH_REMATCH[1]}
        
        if [[ $git_status =~ ${git_branch_ahead_of[$lang]} ]]; then
            echo "11" # light orange = yellow
        elif [[ $git_status =~ ${git_staged[$lang]} ]]; then
            echo "160" # red
        elif [[ $git_status =~ ${git_to_commit[$lang]} ]]; then
            echo "208" # dark orange
        elif [[ $git_status =~ ${git_nothing_to_commit[$lang]} ]]; then
            echo "82" # green
        fi

    elif [[ $git_status =~ $on_commit ]]; then
        
        local commit=${BASH_REMATCH[1]}
        
        if [[ ! $git_status =~ ${git_work_clean[$lang]} ]]; then
            echo "160"
        elif [[ $git_status =~ "Your commit is ahead of" ]]; then
            echo "11"
        fi
    else
        echo ""
    fi
}

function git_branch {
  local lang="$1"
  local git_status="$(git status 2> /dev/null)"
  local on_branch="${git_on_branch[$lang]} ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo "$branch"
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo "$commit"
  else
	  echo ""
  fi
}

function parse_git_branch {
  a=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')
	echo "$a"
}

function git_section {
  local lang="$1"
  branch="$(git_branch $lang)"

  if [[ "$branch" == "" ]]; then
    echo ""
  else
    color=$(git_color $lang)
    echo "$(separator_section)$(get_color $color)$branch$(get_color)"
  fi
}


function venv_section {
  if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo ""
    return
  else
    local name=`basename "$VIRTUAL_ENV"`
    echo "$(separator_section)$(get_color 208)$name$(get_color)"
  fi
}

function user_section {
  echo "$(get_color 83)\\u$(get_color)"
}

function host_section {
  echo "$(get_color 214)\\h$(get_color)"
}

function path_section {
  echo "$(get_color 69)\\w$(get_color)"
}

function hour_section {
    local d=$(date +"%T")
    echo "$(get_color 220)$d$(get_color)"
}

function update_ps1 {
    lang=$(locale 2> /dev/null | egrep LANG= | sed -r s/LANG=\([a-z0-9]*\)_.*/\\1/g)

    ps1_aux="";
    ps1_aux="$ps1_aux$(open_separator_section)"
    ps1_aux="$ps1_aux$(hour_section)"
    ps1_aux="$ps1_aux$(separator_section)"
    ps1_aux="$ps1_aux$(user_section)"
    ps1_aux="$ps1_aux$(separator_section)"
    ps1_aux="$ps1_aux$(host_section)"
    ps1_aux="$ps1_aux$(separator_section)"
    ps1_aux="$ps1_aux$(path_section)"
    ps1_aux="$ps1_aux$(venv_section)"
    ps1_aux="$ps1_aux$(git_section $lang)"
    ps1_aux="$ps1_aux$(close_separator_section)"
    ps1_aux="$ps1_aux$(get_color)\n$ "
    export PS1="$ps1_aux"
}

export PROMPT_COMMAND='update_ps1'
