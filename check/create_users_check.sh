#!/bin/bash

# Check users and their conditions
if id natasha &>/dev/null && id harry &>/dev/null && id sarah &>/dev/null &&
   [[ $(id -Gn natasha) == *"starwars"* ]] &&
   [[ $(id -Gn harry) == *"starwars"* ]] &&
   [[ $(id -Gn sarah) == *"startrek"* ]] &&
   [[ $(id -u harry) -eq 2000 ]] &&
   ([[ $(getent passwd sarah | cut -d: -f7) == "/sbin/nologin" ]] || [[ $(getent passwd sarah | cut -d: -f7) == "/usr/sbin/nologin" ]]); then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"
fi
