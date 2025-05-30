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
	echo ""
    else
        echo -e $red"ERROR - Something about the Authorization went wrong."$end
        echo $text
        sleep 3
        exit
    fi
}

##FPR Cross Function Automated with a csv
cross(){
    jwt=$(<fod_log.txt)
    token=${jwt:(+17):(-64)}
    echo -ne "$blue CSV File Path:$end "
    read csv
    echo -ne "$blue FOD API URL:$end "
    read api
    mapfile -t sc_id < <(awk -F',' 'NR > 1 {print $1}' $csv)
    mapfile -t app < <(awk -F',' 'NR > 1 {print $2}' $csv)
    mapfile -t app_v < <(awk -F',' 'NR > 1 {print $3}' $csv)
    echo ""
    recieve_fpr
    upload_fpr
}
recieve_fpr(){
    for i in $(seq 0 $((${#sc_id[@]} - 1))); do
        if [ -n "${sc_id[$i]}" ] && [ -n "${app[$i]}" ] && [ -n "${app_v[$i]}" ]; then
            ###FOD Instructions
            curl -X GET --header 'Accept: application/json' -H "Authorization: Bearer $token" "$api/api/v3/scans/${sc_id[$i]}/fpr" -o  ${sc_id[$i]}.fpr
            sleep 1
        else
            echo "Index $i empty"
        fi
    done
}
upload_fpr(){
    for i in $(seq 0 $((${#sc_id[@]} - 1))); do
        if [ -n "${sc_id[$i]}" ] && [ -n "${app[$i]}" ] && [ -n "${app_v[$i]}" ]; then
            ###SSC Instructions
            echo -e "$blue $i. ScanID: ${sc_id[$i]} / Application: ${app[$i]} / Application Version: ${app_v[$i]} $end"
            sleep 1
            fcli ssc appversion create "${app[$i]}":"${app_v[$i]}" --auto-required-attrs --skip-if-exists --store myVersion
            
            #Needed reference to scan id
            id="${sc_id[$i]}.fpr"
            sleep 1

            ##Upload
            fcli ssc artifact upload --appversion ::myVersion:: -f=$id
            echo ""
        else
            echo "Index $i empty"
        fi
    done
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
    #loading
    welcome
}

#Main execution
main
##############
