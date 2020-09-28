#!/bin/bash

actual_dir="$(dirname "${BASH_SOURCE}")"
source "$actual_dir/color_tools.sh"
source "$actual_dir/git_tools.sh"


function separator_section {
  echo "$(get_color 255)]-[$(get_color)"
}

function separator_subsection {
  echo "$(get_color 255))($(get_color)"
}

function open_separator_section {
  echo "$(get_color 255)[$(get_color)"
}

function close_separator_section {
  echo "$(get_color 255)]$(get_color)"
}

function git_section {
  local lang="$1"
  local status=$(git_status)

  if [[ "$status" == "" ]]; then
    echo ""
  else
    local color=$(git_color $status)
    local local_branch=$(echo $status | cut -d " " -f1)
    local remote_branch=$(echo $status | cut -d " " -f2)
    local new_files=$(echo $status | cut -d " " -f3)
    local conflicted_files=$(echo $status | cut -d " " -f4)
    local changed_files=$(echo $status | cut -d " " -f5)
    local staged_files=$(echo $status | cut -d " " -f6)
    local ahead=$(echo $status | cut -d " " -f7)
    local ahead_num=$(echo $status | cut -d " " -f8)
    local behind=$(echo $status | cut -d " " -f9)
    local behind_num=$(echo $status | cut -d " " -f10)

    local display="$(get_color $color)$local_branch"
    local subsection=""

    if [[ $conflicted_files -gt 0 ]]; then
      local color="$(git_color "conflicts")"
      subsection="$subsection$(get_color $color)${conflicted_files}!"
    fi
    if [[ $new_files -gt 0 ]]; then
      local color="$(git_color "new")"
      subsection="$subsection$(get_color $color)${new_files}+"
    fi
    if [[ $changed_files -gt 0 ]]; then
      local color="$(git_color "changed")"
      subsection="$subsection$(get_color $color)${changed_files}C"
    fi
    if [[ $staged_files -gt 0 ]]; then
      local color="$(git_color "staged")"
      subsection="$subsection$(get_color $color)${staged_files}S"
    fi
    if [[ $ahead != "" ]]; then
      local color="$(git_color "ahead")"
      subsection="$subsection$(get_color $color)${ahead_num}A"
    fi
    if [[ $behind != "" ]]; then
      local color="$(git_color "behind")"
      subsection="$subsection$(get_color $color)${behind_num}B"
    fi

    if [[ $subsection != "" ]]; then
      display="$display$(separator_subsection)$subsection"
    fi
    echo "$(separator_section)${display}$(get_color)"
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
    local lang=$(locale 2> /dev/null | egrep LANG= | sed -r s/LANG=\([a-z0-9]*\)_.*/\\1/g)

    local ps1_aux="";
    ps1_aux="$ps1_aux$(open_separator_section)"
    ps1_aux="$ps1_aux$(hour_section)"
    ps1_aux="$ps1_aux$(separator_section)"
    ps1_aux="$ps1_aux$(user_section)"
    ps1_aux="$ps1_aux$(separator_section)"
    ps1_aux="$ps1_aux$(host_section)"
    ps1_aux="$ps1_aux$(separator_section)"
    ps1_aux="$ps1_aux$(path_section)"
    ps1_aux="$ps1_aux$(git_section $lang)"
    ps1_aux="$ps1_aux$(venv_section)"
    ps1_aux="$ps1_aux$(close_separator_section)"
    ps1_aux="$ps1_aux$(get_color)\n$ "
    export PS1="$ps1_aux"
}

export PROMPT_COMMAND='update_ps1'
