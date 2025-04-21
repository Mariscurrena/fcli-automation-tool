#!/usr/bin/env bash
clear
## Stylish
blue="\033[38;5;69m"
green="\033[30;42m"
red="\033[5;31;40m"
end="\033[0m"

##Loading Bar

login(){
    echo -n "FOD Username: "
    read fod_usr
    echo -n "FOD Password: "
    read -s fod_pwd
    echo ""
    echo -n "FOD Tenant: "
    read fod_ten
    echo -n "FOD API URL: "
    read fod_api
    #Scope: manage-apps
    bearer= curl --request POST $fod_api --form 'scope="api-tenant"' --form 'grant_type="password"' --form "username=$fod_ten\\$fod_usr" --form "password=$fod_pwd" -o bearer.txt
}
login