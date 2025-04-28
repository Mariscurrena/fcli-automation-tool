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
            sleep 0.0075
        done
    }   
    text=" L-O-A-D-I-N-G "
    echo ""
    bar
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.0075
    done
    bar
    echo ""
    echo ""
}
scan(){
    echo -e "$blue Scanning...$end"
    /home/steve/Documents/fcli/debricked-cli/debricked scan $1 -c debricked-ssc -r $2
}
upload(){
    echo -e "$blue Uploading to SSC...$end"
}
welcome(){
    echo -e "$blue ---> Welcome to Debricked - Software Security Center Utility <---$end"
    sleep 0.5
    echo ""
    echo -e "$blue --> Please provide the following information: $end"
    echo -ne "$blue *Project Path: $end"
    read project
    echo -ne "$blue *Debricked Repository: $end"
    read repo
    # echo -ne "$blue *Debricked Token: $end"
    # read -s token
    # echo ""
    # echo -ne "$blue SSC App: $end"
    # read app
    # echo -ne "$blue SSC App version: $end"
    # read av
    # loading
    scan $project $repo
    # loading
    upload
}
main(){
    welcome
}
main