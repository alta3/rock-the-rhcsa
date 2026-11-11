#!/bin/bash
# boot_target_check.sh (RHCSA practice)
# The default boot target must be multi-user.target (runlevel3.target is
# the same thing). It must be set the normal way, as systemd's default,
# not forced with a systemd.unit= kernel argument in GRUB.
# Read-only: changes nothing.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

case "$(systemctl get-default 2>/dev/null)" in
    multi-user.target|runlevel3.target) ;;
    *) fail ;;
esac

# A systemd.unit= on the default kernel's command line would override
# the default target at boot.
if command -v grubby &>/dev/null; then
    sudo grubby --info=DEFAULT 2>/dev/null | grep -q 'systemd\.unit=' && fail
fi

pass
