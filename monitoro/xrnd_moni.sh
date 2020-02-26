# bash script telegram bot 1,2,3 = status - if null start- then sync status msg  
while [ "true" ]
    do
        token=""
        chat_id=""
        tg_api="https://api.telegram.org/bot${token}/sendMessage?chat_id=${chat_id}"



        catching_up="true|false"
        status=`curl localhost:26657/status | grep -E ${catching_up}`
        peers=`curl localhost:26657/net_info | grep -E n_peers`
        if ! pgrep -x "xrnd" > /dev/null
        then
            crash_msg="☢️No response‼️ from the node☢️, let's restart this boy. . . 🚀 "
            echo $crash_msg
            curl -s "${tg_api}" --data-urlencode "text=${crash_msg}"
            echo -e screen -S regen && xrnd start &
            sleep 1800
        else
            status_msg="Regen V: 💻 ⛏${peers} ⚛️  ${status} ⚙️"
            echo "${status_msg}"
            # Telegram notification
            # If no need to notificate just comment line bellow
            curl -s "${tg_api}" --data-urlencode "text=${status_msg}"
        fi
        sleep 900

done