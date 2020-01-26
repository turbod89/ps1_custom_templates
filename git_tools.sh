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
