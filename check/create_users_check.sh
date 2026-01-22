#!/bin/bash
# create_users_check.sh (RHCSA practice - concise)
PASS="nerdzrule"

# Require expect so we never hang on su prompts
if ! command -v expect &>/dev/null; then
  echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"
  exit 1
fi

check_password() {
  local user="$1"
  expect <<EOF &>/dev/null
set timeout 6
spawn su - $user -c true
expect {
  -nocase -re {password:} { send "$PASS\r"; exp_continue }
  -re {Authentication failure} { exit 1 }
  -re {incorrect password}     { exit 1 }
  timeout { exit 1 }
  eof {
    catch wait result
    exit [lindex \$result 3]
  }
}
EOF
}

check_sarah_blocked() {
  # Feed the password so it can't hang; pass only if login is blocked (nologin message or nonzero exit).
  expect <<EOF &>/dev/null
set timeout 6
spawn su - sarah -c true
expect {
  -nocase -re {password:} { send "$PASS\r"; exp_continue }
  -re {Authentication failure} { exit 1 }
  -re {incorrect password}     { exit 1 }
  -nocase -re {(not available|nologin)} { exit 0 }
  timeout { exit 1 }
  eof {
    catch wait result
    set code [lindex \$result 3]
    if {\$code == 0} { exit 1 } else { exit 0 }
  }
}
EOF
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
   check_sarah_blocked; then
  echo -e "\e[32mSUCCESS!\e[0m"
else
  echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"
fi
