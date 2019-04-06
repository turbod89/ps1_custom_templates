#!/bin/bash

C_FG_S1=94
C_FG_S2=214
C_FG_S3=0

C_BG_S1=214
C_BG_S2=33
C_BG_S3=95


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

function git_section {
    local git_status="$(git status 2> /dev/null)"
    local on_branch="On branch ([^${IFS}]*)"
    local on_commit="HEAD detached at ([^${IFS}]*)"

    if [[ $git_status =~ $on_branch ]]; then
        
        local branch=${BASH_REMATCH[1]}
        
        if [[ $branch == "master" && ! $git_status =~ "working directory clean" ]]; then
            echo " $(open_tag 250 124)${branch}$(close_tag 255 124)"
        elif [[ ! $git_status =~ "working directory clean" ]]; then
            echo " $(open_tag 0 160)${branch}$(close_tag 255 160)"
        elif [[ $git_status =~ "Your branch is ahead of" ]]; then
            echo " $(open_tag 0 11)${branch}$(close_tag 255 11)"
        elif [[ $git_status =~ "nothing to commit" ]]; then
            echo " $(open_tag 0 82)${branch}$(close_tag 255 82)"
        fi

    elif [[ $git_status =~ $on_commit ]]; then
        
        local commit=${BASH_REMATCH[1]}
        
        if [[ ! $git_status =~ "working directory clean" ]]; then
            echo " $(open_tag 0 160)$commit$(close_tag 255 160)"
        elif [[ $git_status =~ "Your commit is ahead of" ]]; then
            echo " $(open_tag 0 11)$commit$(close_tag 255 11)"
        fi
    else
        echo ""
    fi
}


function user_section {
  echo "$(get_color ${C_FG_S1} ${C_BG_S1}) \\u $(close_tag ${C_FG_S1} ${C_BG_S1} ${C_BG_S2})"
}

function path_section {
  echo "$(get_color ${C_FG_S2} ${C_BG_S2}) \\w $(close_tag ${C_FG_S2} ${C_BG_S2})"
}

function separator_section {
  echo "$(get_color 255)-$(get_color)"
}

function hour_section {
    local d=$(date +"%T")
    echo "$(get_color ${C_FG_S3} ${C_BG_S3}) $d $(close_tag ${C_FG_S3} ${C_BG_S3} ${C_BG_S1})"
}

function update_ps1 {
    export PS1="";
    export PS1="$PS1\$(hour_section)"
    export PS1="$PS1$(user_section)"
    #export PS1="$PS1$(separator_section)"
    export PS1="$PS1$(path_section)"
    #export PS1="$PS1$(separator_section)"
    export PS1="$PS1$(git_section)"

    export PS1="$PS1$(get_color)\n$ "
}

export PROMPT_COMMAND='update_ps1'
