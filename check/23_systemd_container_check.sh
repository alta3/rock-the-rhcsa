if systemctl is-enabled container-toystory.service &> /dev/null && systemctl is-active container-toystory.service &> /dev/null; then
    echo -e "\e[32mSUCCESS!\e[0m"
else
    echo -e "\e[31mNO PASS- TRY AGAIN!\e[0m"
fi
