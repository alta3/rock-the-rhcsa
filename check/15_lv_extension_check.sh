if sudo lvdisplay /dev/vg-starfleet/lv-spock | grep -q "LV Size\s*5.00 GiB"; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
