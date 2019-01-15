#!/bin/bash

COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[0;33m"
COLOR_GREEN="\033[0;32m"
COLOR_OCHRE="\033[38;5;95m"
COLOR_BLUE="\033[0;34m"
COLOR_WHITE="\033[0;37m"
COLOR_RESET="\033[0m"

COLOR_RED_BLINK="\033[5;31m"
COLOR_RED_INVERTED="\033[7;31m"

function getColor {
  if [[ "$#" == "0" ]]; then
    echo -e "\033[0m"
  else
    local color="$1"
    echo -e "\033[38;5;${color}m"
  fi
}

function git_color {
  local git_status="$(git status 2> /dev/null)"
  local on_branch="On branch ([^${IFS}]*)"
  local branch=${BASH_REMATCH[1]}

  if [[ $branch == "master" ]]; then
    echo -e "\033[5;31m"
  elif [[ ! $git_status =~ "working directory clean" ]]; then
    echo -e $(getColor 160)
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
    echo -e $(getColor 11)
  elif [[ $git_status =~ "nothing to commit" ]]; then
    echo -e $(getColor 82)
  else
    echo -e $(getColor 208)
  fi
}

function git_branch {
  local git_status="$(git status 2> /dev/null)"
  local on_branch="On branch ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo "$branch"
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo "$commit"
  else
	  echo ""
    # echo $(cat /proc/stat | grep -i processes)
  fi
}


function parse_git_branch {
     a=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')
	echo "$a"
}

function git_section {
  branch="$(git_branch)"

  if [[ "$branch" == "" ]]; then
    echo ""
  else
    echo "$(getColor 255)-{$(git_color)$branch$(getColor 255)}"
  fi
}

function user_section {
  echo "$(getColor 255)($(getColor 154)\\u$(getColor)$(getColor 255))$(getColor)"
}

function path_section {
  echo "$(getColor 255)[$(getColor 250)\\w$(getColor 255)]$(getColor)"
}

function separator_section {
  echo "$(getColor 255)-$(getColor)"
}

export PS1="";
export PS1="$PS1$(user_section)"
export PS1="$PS1$(separator_section)"
export PS1="$PS1$(path_section)"
#export PS1="$PS1$(separator_section)"
export PS1="$PS1\$(git_section)"

export PS1="$PS1\[\$(getColor 255)\]:\[\$(getColor)\] "


#export PS1="\[\$(getColor 255)\]{\[\$(git_color)\]\$(git_branch)\[\$(getColor 255)\]}-(\[\$(getColor 154)\]\u\[\$(getColor)\]\[\$(getColor 255)\])-[\[\$(getColor 250)\]\w\[\$(getColor)\]\[\$(getColor 255)\]]:\[\$(getColor)\] "

