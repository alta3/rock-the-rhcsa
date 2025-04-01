if sudo lvdisplay /dev/vg-starfleet/lv-spock &> /dev/null && \
   [[ $(sudo lsblk -f /dev/vg-starfleet/lv-spock | awk 'NR==2 {print $2}') == "xfs" ]] && \
   grep -Pq "/mnt/enterprise\s+xfs\s+defaults\s+0\s+0" /etc/fstab; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
