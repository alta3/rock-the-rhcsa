#!/bin/bash
# flatpak_cmus_setup.sh (RHCSA practice)
# Start the task without the cmus flatpak installed. If the system-wide
# flathub remote exists but nothing system-wide was installed from it,
# remove it too, so adding the remote is part of the task.
# Runtimes are kept on purpose (a retry would re-download about 260 MB),
# so after a first attempt the remote stays, because the runtime still
# comes from it. Does not remove the flatpak package itself.

APP=io.github.cmus.cmus

if command -v flatpak &>/dev/null; then
    sudo flatpak uninstall --system -y --noninteractive "$APP" &>/dev/null
    flatpak uninstall --user -y --noninteractive "$APP" &>/dev/null

    if flatpak remotes --system --columns=name 2>/dev/null | grep -qx flathub; then
        if ! flatpak list --system --columns=origin 2>/dev/null | grep -qx flathub; then
            sudo flatpak remote-delete --system flathub &>/dev/null
        fi
    fi
fi

echo "Setup is complete. Begin your task!"
