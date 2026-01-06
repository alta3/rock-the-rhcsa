#!/bin/bash

check_password() {
  local user="$1"
  echo "nerdzrule" | su - "$user" -c true &>/dev/null
}

if id natasha &>/dev/null &&
   id harry &>/dev/null &&
   id sarah &>/dev/null &&
   [[ $(id -Gn natasha) == *"starwars"* ]] &&
   [[ $(id -Gn harry) == *"starwars"* ]] &&
   [[ $(id -Gn sarah) == *"startrek"* ]] &&
   [[ $(id -u harry) -eq 2000 ]] &&
   ([[ $(getent passwd sarah | cut -d: -f7) == "/sbin/nologin" ]] || [[ $(getent passwd sarah | cut -d: -f7) == "/usr/sbin/nologin" ]]) &&
   check_password natasha &&
   check_password harry &&
   check_password sarah; then

  echo -e "\e[32mSUCCESS!\e[0m"
else
  echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"
fi
