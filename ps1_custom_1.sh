#!/bin/bash

actual_dir="$(dirname "${BASH_SOURCE}")"
source "$actual_dir/color_tools.sh"
source "$actual_dir/git_tools.sh"

function git_section {
  local lang="$1"
  branch="$(git_branch $lang)"

  if [[ "$branch" == "" ]]; then
    echo ""
  else
    color=$(git_color $lang)
    echo "$(get_color 255)-{$(get_color $color)$branch$(get_color 255)}$(get_color)"
  fi
}

function venv_section {
  if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo ""
    return
  else
    local name=`basename "$VIRTUAL_ENV"`
    echo "$(get_color 255)($(get_color 208)$name$(get_color 255))$(get_color) "
  fi
}

function user_section {
	echo "$(get_color 255)($(get_color 154)\\u$(get_color 9)@$(get_color 154)\\h$(get_color 255))$(get_color)"
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
  local lang=$(locale 2> /dev/null | egrep LANG= | sed -r s/LANG=\([a-z0-9]*\)_.*/\\1/g)
  local ps1_aux="";
  ps1_aux="$ps1_aux$(venv_section)"
  ps1_aux="$ps1_aux$(user_section)"
  ps1_aux="$ps1_aux$(separator_section)"
  ps1_aux="$ps1_aux$(path_section)"
  #ps1_aux="$ps1_aux$(separator_section)"
  ps1_aux="$ps1_aux$(git_section $lang)"
  ps1_aux="$ps1_aux$(end_section)"

  export PS1="$ps1_aux"
}
export PROMPT_COMMAND='update_ps1'
