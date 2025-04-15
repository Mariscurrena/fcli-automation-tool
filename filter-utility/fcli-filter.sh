#!/usr/bin/env bash
clear
## Stylish
blue="\033[38;5;69m"
green="\033[30;42m"
red="\033[5;31;40m"
end="\033[0m"
loading(){
    bar(){
        blue="\033[38;5;69m"
        end="\033[0m"
        for (( i=1; i<=20; i++ )); do
            echo -en "$blue=$end"
            sleep 0.1
        done
    }   
    text=" L-O-A-D-I-N-G " ##Can be changed in any language or with other text
    echo ""
    bar
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.1
    done
    bar
    echo ""
}
login(){
    echo -n "SSC URL: "
    read ssc 
    echo -n "Username: "
    read usrname 
    echo -n "Password: "
    read -s passwrd
    fcli ssc session login --url $ssc -u $usrname -p $passwrd
    echo ""
}
filter(){
    ## List application versions
    echo -e "$blue--------------------Listing application versions--------------------$end"
    echo ""
    fcli ssc appversion ls -o csv > appversion.csv
    loading
    echo ""
    echo -e "$green--------------------Application Version successfully listed--------------------$end"
    sleep 1
    echo ""

    ## List columns
    echo -e "$blue--------------------Enumerating Exploitable vulnerabilities--------------------$end"
    mapfile -t apps < <(awk -F',' '{print $3}' appversion.csv)
    mapfile -t versions < <(awk -F',' '{print $8}' appversion.csv)
    echo -e "$red------------------------------ Tag: EXPLOITABLE ------------------------------$end"
    for i in $(seq 1 $((${#apps[@]} - 1))); do
        if [ -n "${apps[$i]}" ] && [ -n "${versions[$i]}" ]; then
            echo -e "Application: ${apps[$i]} / Version: ${versions[$i]}" >> report.yaml
            echo -e "$blue--------------------Application: ${apps[$i]} / Version: ${versions[$i]}--------------------$end"
            fcli ssc issue count --av "${apps[$i]}":"${versions[$i]}" -o yaml --filter="Analysis:Exploitable" | tee -a report.yaml
        else
            echo "Index $i empty"
        fi
    done
    sleep 1
    echo -e "$green Exploitable Vulnerabilities Successfully Listed $end"
}
login
filter