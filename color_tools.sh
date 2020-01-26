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