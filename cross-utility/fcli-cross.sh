#!/usr/bin/env bash
clear
## Stylish
blue="\033[38;5;69m"
green="\033[30;42m"
red="\033[5;31;40m"
end="\033[0m"

##Loading Bar
loading(){
    bar(){
        blue="\033[38;5;69m"
        end="\033[0m"
        for (( i=1; i<=20; i++ )); do
            echo -en "$blue=$end"
            sleep 0.01
        done
    }   
    text=" L-O-A-D-I-N-G "
    echo ""
    bar
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.01
    done
    bar
    echo ""
    echo ""
}

##FOD Login Function
fod_login(){
    echo -ne "$blue -FOD Username:$end "
    read fod_usr
    echo -ne "$blue -FOD Password:$end "
    read -s fod_pwd
    echo ""
    echo -ne "$blue -FOD Tenant:$end "
    read fod_ten
    echo -ne "$blue -FOD API URL:$end "
    read fod_api
    #Scope: manage-apps
    curl --request POST $fod_api --form 'scope="api-tenant"' --form 'grant_type="password"' --form "username=$fod_ten\\$fod_usr" --form "password=$fod_pwd" -o fod_log.txt
    text=$(<fod_log.txt) 
    if echo "$text" | grep -q "error"; then
        echo -e $red"ERROR 401-Something about the Authorization went wrong."$end
        echo $text
        sleep 3
        exit
    else
        echo -e $green"Fortify On Demand Login Successful!"$end
        echo ""
    fi
}

##SSC Login Function
ssc_login(){
    echo -ne "$blue -SSC URL:$end "
    read ssc 
    echo -ne "$blue -Username:$end "
    read usrname 
    echo -ne "$blue -Password:$end "
    read -s passwrd
    echo ""
    fcli ssc session login --url $ssc -u $usrname -p $passwrd > ssc_log.txt
    echo ""
    if echo $(<ssc_log.txt) | grep -q "CREATED"; then
        echo -e $green"Software Security Center Login Successful!"$end
    else
        echo -e $red"ERROR - Something about the Authorization went wrong."$end
        echo $text
        sleep 3
        exit
    fi
}

##FPR Cross Function
cross(){
    echo ""
    jwt=$(<fod_log.txt)
    token=${jwt:(+17):(-64)}
    echo -ne "$blue FOD Scan ID:$end "
    read scan_id
    echo -ne "$blue FOD API URL:$end "
    read api
    echo -ne "$blue SSC APP NAME:$end "
    read app
    echo -ne "$blue SSC APP Version NAME:$end "
    read av
    curl -X GET --header 'Accept: application/json' -H "Authorization: Bearer $token" "$api/api/v3/scans/$scan_id/fpr" -o $scan_id.fpr
    sleep 3
    loading
    id="${scan_id}.fpr"
    echo $id
    fcli ssc artifact upload --av="$app":"$av" -f=$id
    echo ""
}

##Authentication Function
auth(){
    fod_login
    ssc_login
    cross
}

##Welcome Function
welcome(){
    echo -e "$blue Do you need to login or you are using a current session (fcli session and jwt)?$end "
    select opt in "Login" "Current" "quit"
    do
            case $opt in
                Login) auth;;
                Current) cross;;
                quit) clear && break;;
                *) echo -e "${RED}Opcion invalida.${REDF}";;
            esac
    done
}

#Main Function
main(){
    echo -e "$green Welcome to the cross utility$end"
    echo "This tool was developed to allow customers who need to synchronize FPR files across different environments (FOD <---> Fortify On Prem)"
    echo ""
    loading
    welcome
}

#Main execution
main
##############