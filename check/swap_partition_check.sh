#!/bin/bash
# swap_partition_check.sh (RHCSA practice)
# A ~500 MB swap *partition* must be active now and listed in /etc/fstab.

pass() { echo -e "\e[32mSUCCESS!\e[0m"; exit 0; }
fail() { echo -e "\e[31mNO PASS - TRY AGAIN!\e[0m"; exit 1; }

# Swap devices listed in fstab (uncommented entries only), resolved to real paths
mapfile -t fstab_swaps < <(findmnt --fstab --evaluate -n -t swap -o SOURCE 2>/dev/null \
                            | while read -r s; do readlink -f "$s"; done)

# Active swap partitions of about 500 MB (500 MB - 5% .. 500 MiB + 5%)
while read -r name type size; do
    [[ "$type" == "partition" ]] || continue
    (( size >= 475000000 && size <= 550502400 )) || continue
    dev=$(readlink -f "$name")
    for s in "${fstab_swaps[@]}"; do
        [[ "$s" == "$dev" ]] && pass
    done
done < <(swapon --show=NAME,TYPE,SIZE --bytes --noheadings 2>/dev/null)

fail
