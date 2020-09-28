#!/bin/bash

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

function contains() {
  # $([[ "$1" =~ (^| )"$2"($| ) ]] && echo "0") || echo "1"
  for item in $1; do
    if [[ "$item" == "$2" ]]; then
      echo "1"
      return
    fi
  done
  echo "0"
}

function git_status() {
  local git_status="$(git status --porcelain -b -u 2> /dev/null)"
  local local_branch=""
  local remote_branch=""
  local i=0
  local new_files=0
  local conflicted_files=0
  local changed_files=0
  local staged_files=0
  local ahead="  "
  local behind="  "
  while IFS= read -r line; do
    if [[ $i -eq "0" ]]; then
      local has_remote=$(echo "$line" | egrep "^## (\S+?)\.{3}(\S+?)( .+)?$")
      local has_ahead_behind=$(echo "$line" | egrep "^## (\S+?) \[(ahead [0-9]+)?(, )?(behind [0-9]+)?\]$")
      if [[ $has_remote != "" ]]; then
        local_branch=$(echo "$line" | sed -E 's/^## (\S+?)\.{3}(\S+?)( .+)?$/\1/g')
        remote_branch=$(echo "$line" | sed -E 's/^## (\S+?)\.{3}(\S+?)( .+)?$/\2/g')
      else
        local_branch=$(echo "$line" | sed -E 's/^## (\S+?)( .+)?$/\1/g')
      fi
      if [[ $has_ahead_behind != "" ]]; then
        local ahead_behind=$(echo "$line" | sed -E "s/^## (\S+?)( \[((ahead [0-9]+)?(, )?(behind [0-9]+)?\]))$/\3/g")
        ahead_behind=$(echo "$ahead_behind" | sed -E "s/(.+)(, )(.+)/\1 \3/g")
        local has_ahead=$(echo "$ahead_behind" | egrep ".*ahead [0-9]+.*") 
        local has_behind=$(echo "$ahead_behind" | egrep ".*behind [0-9]+.*")
        if [[ $has_ahead != "" ]]; then
          ahead=$(echo "$ahead_behind" | sed -E "s/.*(ahead [0-9]+).*/\1/g")
        fi
        if [[ $has_behind != "" ]]; then
          behind=$(echo "$ahead_behind" | sed -E "s/.*(behind [0-9]+).*/\1/g")
        fi
      fi
    else
      local code=$(echo "$line" | cut -c1-2)
      if [[ "$code" == "??" ]]; then
        new_files=$((new_files+1))
      elif [[ "$(contains "DD AU UD UA DU AA UU" "$code")" == 1 ]]; then
        conflicted_files=$((conflicted_files+1))
      else
        local c1=$(echo "$code" | cut -c1-1)
        local c2=$(echo "$code" | cut -c2-2)
        [[ $c1 == " " ]] || staged_files=$((staged_files+1))
        [[ $c2 == " " ]] || changed_files=$((changed_files+1))
      fi
    fi
    i=$((i+1))
  done <<< "$git_status"

  if [[ $local_branch != "" ]]; then
    echo "$local_branch $remote_branch $new_files $conflicted_files $changed_files $staged_files $ahead $behind"
  fi
}

function git_color {

  if [[ "$#" -eq 1 ]]; then
    if [[ "$1" == "conflicts" ]]; then
      echo "98" # purle
    elif [[ "$1" == "new" ]]; then
      echo "160" # red
    elif [[ "$1" == "changed" ]]; then
      echo "160" # red
    elif [[ "$1" == "staged" ]]; then
      echo "208" # orange
    elif [[ "$1" == "ok" ]]; then
      echo "82" # green
    else
      echo "82" # green
    fi
  elif [[ "$#" -ge 6 ]]; then
  # local local_branch=$(echo $status | cut -d " " -f1)
  # local remote_branch=$(echo $status | cut -d " " -f2)
  # local new_files=$(echo $status | cut -d " " -f3)
  # local conflicted_files=$(echo $status | cut -d " " -f4)
  # local changed_files=$(echo $status | cut -d " " -f5)
  # local staged_files=$(echo $status | cut -d " " -f6)
  # local ahead=$(echo $status | cut -d " " -f7)
  # local ahead_num=$(echo $status | cut -d " " -f8)
  # local behind=$(echo $status | cut -d " " -f9)
  # local behind_num=$(echo $status | cut -d " " -f10)
    local local_branch="$1"
    local remote_branch="$2"
    local new_files="$3"
    local conflicted_files="$4"
    local changed_files="$5"
    local staged_files="$6"

    if [[ $conflicted_files -gt 0 ]]; then
      echo "$(git_color "conflicts")"
    elif [[ $new_files -gt 0 ]]; then
      echo "$(git_color "new")"
    elif [[ $changed_files -gt 0 ]]; then
      echo "$(git_color "changed")"
    elif [[ $staged_files -gt 0 ]]; then
      echo "$(git_color "staged")"
    else
      echo "$(git_color "ok")"
    fi
  fi
}

#function git_color {
#  local lang="$1"
#  local git_status="$(git status 2> /dev/null)"
#  local on_branch="${git_on_branch[$lang]} ([^${IFS}]*)"
#
#  if [[ $git_status =~ $on_branch ]]; then
#        
#        local branch=${BASH_REMATCH[1]}
#        
#        if [[ $git_status =~ ${git_branch_ahead_of[$lang]} ]]; then
#            echo "11" # light orange = yellow
#        elif [[ $git_status =~ ${git_staged[$lang]} ]]; then
#            echo "160" # red
#        elif [[ $git_status =~ ${git_to_commit[$lang]} ]]; then
#            echo "208" # dark orange
#        elif [[ $git_status =~ ${git_nothing_to_commit[$lang]} ]]; then
#            echo "82" # green
#        fi
#
#    elif [[ $git_status =~ $on_commit ]]; then
#        
#        local commit=${BASH_REMATCH[1]}
#        
#        if [[ ! $git_status =~ ${git_work_clean[$lang]} ]]; then
#            echo "160"
#        elif [[ $git_status =~ "Your commit is ahead of" ]]; then
#            echo "11"
#        fi
#    else
#        echo ""
#    fi
#}

function git_branch {
  local lang="$1"
  local git_status="$(git status --porcelain -b 2> /dev/null)"
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
