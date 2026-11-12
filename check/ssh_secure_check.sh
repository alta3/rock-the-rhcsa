#!/bin/bash
# ssh_secure_check.sh (RHCSA practice) - run on rhel-2 as student
#
# Task 1: bart (rhel-2) can "ssh skinner@rhel-1" with his own default key, no
#         passphrase, no password, no -i.
# Task 2: the practice server sshd-exam on rhel-1 (port 2022) refuses root logins and
#         password logins, in its saved config AND in the running server; its config
#         is valid; it is running and enabled at boot; skinner can still log in with
#         bart's key.
#
# Lockout-safe: it never makes a failing login against the real sshd (port 22). The
# real bart -> skinner login is only tried once skinner's files show that it will
# work. Failed logins on port 2022 never block anyone (PerSourcePenalties no).
# Read-only.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

# As root, "ssh rhel-1" would be a failed login (root has no key there).
[[ $EUID -ne 0 ]] || fail

R1=$(getent ahostsv4 rhel-1 | awk 'NR==1{print $1}')
[[ -n "$R1" ]] || fail
r1() { timeout 30 ssh -o BatchMode=yes -o ConnectTimeout=10 -o LogLevel=ERROR "$R1" "$@" </dev/null; }
SSHOPTS=(-o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no
         -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o GSSAPIAuthentication=no)
as_bart() { sudo -u bart -H timeout 30 ssh "${SSHOPTS[@]}" "$@" </dev/null; }

# ---------------- Task 1 ----------------
id bart &>/dev/null || fail
BH=$(getent passwd bart | cut -d: -f6)

# bart's default-name keys that exist as a pair and have no passphrase.
blobs=()
for t in ed25519 ecdsa rsa; do
    k="$BH/.ssh/id_$t"
    sudo test -f "$k" -a -f "$k.pub" || continue
    sudo ssh-keygen -y -P '' -f "$k" &>/dev/null || continue
    blobs+=("$(sudo awk '{print $2}' "$k.pub")")
done
(( ${#blobs[@]} )) || fail

# skinner's side, read through student's own (working) login.
info=$(r1 'sudo stat -c "%a %U %n" /home/skinner /home/skinner/.ssh /home/skinner/.ssh/authorized_keys 2>/dev/null; echo ---; sudo cat /home/skinner/.ssh/authorized_keys 2>/dev/null') || fail
modes=$(sed '/^---$/,$d' <<<"$info")
keys=$(sed '1,/^---$/d' <<<"$info")
(( $(wc -l <<<"$modes") == 3 )) || fail
while read -r mode owner path; do
    [[ "$owner" == skinner ]] || fail
    (( (8#$mode & 8#022) == 0 )) || fail        # not writable by group/others
done <<<"$modes"
found=0
for b in "${blobs[@]}"; do grep -qF -- "$b" <<<"$keys" && found=1; done
(( found )) || fail

# Now the real login (port 22): default keys only, no password.
as_bart -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no skinner@rhel-1 true || fail

# ---------------- Task 2 ----------------
cfg=$(r1 'systemctl is-active sshd-exam; systemctl is-enabled sshd-exam
          sudo sshd -t -f /etc/ssh/sshd_exam_config &>/dev/null && echo SYNTAX_OK
          sudo sshd -T -f /etc/ssh/sshd_exam_config -C user=root,host=rhel-2,addr=192.0.2.1 2>/dev/null |
              grep -E "^(port|permitrootlogin|passwordauthentication|pubkeyauthentication) " | sed "s/^/root /"
          sudo sshd -T -f /etc/ssh/sshd_exam_config -C user=skinner,host=rhel-2,addr=192.0.2.1 2>/dev/null |
              grep -E "^(passwordauthentication|pubkeyauthentication) " | sed "s/^/skinner /"') || fail
for want in "active" "enabled" "SYNTAX_OK" "root port 2022" "root permitrootlogin no" \
            "root passwordauthentication no" "skinner passwordauthentication no" \
            "skinner pubkeyauthentication yes"; do
    grep -qxF -- "$want" <<<"$cfg" || fail
done

# The RUNNING server: the key still works on 2022 ...
as_bart -p 2022 -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no skinner@rhel-1 true || fail
# ... and it no longer offers passwords at all.
msg=$(sudo -u bart -H timeout 30 ssh "${SSHOPTS[@]}" -p 2022 -o PubkeyAuthentication=no skinner@rhel-1 true 2>&1 </dev/null)
grep -q 'Permission denied (' <<<"$msg" || fail
grep -qE 'password|keyboard-interactive' <<<"$msg" && fail

pass
