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
    text=" L O A D I N G " ##Can be changed in any language or with other text
    echo ""
    echo -en "\033[37;5;69m[\033[0m "
    sleep 0.1
    bar
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep 0.1
    done
    bar
    echo -en "\033[37;5;69m ]\033[0m"
    sleep 0.1
    echo ""
    echo ""
}
oss-scan(){
    echo -ne "$blue Project Path (including project name): $end"
    read path
    echo -ne "$blue Repository Name: $end"
    read repo
    echo -e "$blue Files found with OSS Dependencies are: $end" 
    /home/steve/Documents/fcli/debricked-cli/debricked files find $path
    echo ""
    #### Without Reachability Analysis
    echo -e "$blue Scanning... $end" 
    /home/steve/Documents/fcli/debricked-cli/debricked scan $path -c oss-automation-script -r $repo
    echo -e "$green Scan Finished $end" 
    echo ""
    # #### With Reachability Analysis
    # echo -e "$blue Scanning... $end" 
    # /home/steve/Documents/fcli/debricked-cli/debricked scan $path -c oss-automation-script-CG -r $repo --callgraph
    # echo -e "$green Scan Finished $end" 
    # echo ""
}
welcome(){
    echo -e "$blue Welcome to Debricked CLI Automation Utility $end"
}
main(){
    welcome
    #loading
    oss-scan
}
main