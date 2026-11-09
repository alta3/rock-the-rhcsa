#!/bin/bash
# create_users_check.sh (RHCSA practice)
# natasha + harry in starwars, sarah in startrek and unable to log in,
# harry UID 2000, natasha/harry password "nerdzrule".
PASS="nerdzrule"

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

# expect drives the su password prompts so the check never hangs.
# It is not installed on the lab VMs by default, so install it quietly.
if ! command -v expect &>/dev/null; then
  sudo dnf install -y -q expect &>/dev/null
  if ! command -v expect &>/dev/null; then
    echo "This check needs the 'expect' package. Install it with: sudo dnf install -y expect"
    exit 2
  fi
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
  # Feed the password so it can't hang; pass only if login is blocked.
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

for u in natasha harry sarah; do
  id "$u" &>/dev/null || fail
done

[[ " $(id -Gn natasha) " == *" starwars "* ]] || fail
[[ " $(id -Gn harry) "   == *" starwars "* ]] || fail
[[ " $(id -Gn sarah) "   == *" startrek "* ]] || fail
[[ $(id -u harry) -eq 2000 ]] || fail

case "$(getent passwd sarah | cut -d: -f7)" in
  /sbin/nologin|/usr/sbin/nologin|/bin/false|/usr/bin/false) ;;
  *) fail ;;
esac

check_password natasha || fail
check_password harry   || fail
check_sarah_blocked    || fail

pass
