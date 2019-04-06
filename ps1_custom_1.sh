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

git_on_branch["en"]="On branch"
git_on_branch["ca"]="En la branca"

git_work_clean["en"]="working directory clean"
git_work_clean["ca"]="working directory clean"

function git_color {
  local lang="$1"
  local git_status="$(git status 2> /dev/null)"
  local on_branch="${"git_on_branch_${lang}"}"
  local branch=${BASH_REMATCH[1]}

  if [[ $branch == "master" ]]; then
    echo "34"
  elif [[ ! $git_status =~ ${git_work_clean[$lang]} ]]; then
    echo "160"
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
    echo "11"
  elif [[ $git_status =~ "nothing to commit" ]]; then
    echo "82"
  else
    echo "208"
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
    # echo $(cat /proc/stat | grep -i processes)
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
    color="160" #$(git_color $lang)
    echo "$(get_color 255){$(get_color $color)$branch$(get_color 255)}$(get_color)"
  fi
}

function user_section {
  echo "$(get_color 255)($(get_color 154)\\u$(get_color)$(get_color 255))$(get_color)"
}

function path_section {
  echo "$(get_color 255)[$(get_color 250)\\w$(get_color 255)]$(get_color)"
}

function separator_section {
  echo "$(get_color 255)-$(get_color)"
}

function end_section {
  echo "$(get_color 255):$(get_color) "
}

function update_ps1 {
  ps1_aux="";
  ps1_aux="$ps1_aux$(user_section)"
  ps1_aux="$ps1_aux$(separator_section)"
  ps1_aux="$ps1_aux$(path_section)"
  ps1_aux="$ps1_aux$(separator_section)"
  ps1_aux="$ps1_aux$(git_section ca)"
  ps1_aux="$ps1_aux$(end_section)"

  export PS1="$ps1_aux"
}
export PROMPT_COMMAND='update_ps1'
