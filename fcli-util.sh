#!/usr/bin/env bash
clear

GREEN="\033[30;42m"; GREENF="\033[0m"
RED="\033[31;40m"; REDF="\033[0m"
echo -e "${GREEN}Bienvenido a la funcionalidad de FCLI. \n Por favor, sigue las instrucciones.${GREENF}"

login(){
    echo -n "Ingresa la URL de SSC: "
    read ssc 
    echo -n "Ingresa tu username: "
    read usrname 
    echo -n "Ingresa tu contraseña: "
    read -s passwrd
    fcli ssc session login --url $ssc -u $usrname -p $passwrd -c M1crofocus.
    echo ""
}
app(){
    echo -e "${GREEN}Las aplicaciones en Software Security Center son: ${GREENF}"
    fcli ssc app list -o json
    echo ""
}
appversion(){
    echo -e "${GREEN}Las versiones de las aplicaciones en Software Security Center son: ${GREENF}"
    fcli ssc appversion list -o json
    echo ""
}
sast(){
    echo "SAST Scan Option Soon..."
    echo -n "Ingresa la ruta de tu proyecto (.zip): " #/home/mobaxterm/MyDocuments/Cybersecurity-Optima/Products/Fortify/Fortify-Extra/IWA/package.zip
    read project
    echo -n "Ingresa el nombre de la aplicación (SSC): "
    read app
    echo -n "Ingresa la versión de ${app} (SSC): "
    read version
    ###fcli
    #fcli ssc appversion create $app:$version --skip-if-exists --auto-required-attrs
    fcli sc-sast scan start -v 23.2 -f $project --publish-to $app:$version --store x
    fcli sc-sast scan wait-for ::x::jobToken
    echo ""
    # echo "fcli ssc appversion create ${app}:${version} --auto-required-attrs --skip-if-exists"
    # echo $project
}

login
select option in "app" "appversion" "SAST-Scan" "quit"
do
        case $option in
            app) app;;
            appversion) appversion;;
            SAST-Scan) sast;;
            quit) clear && break;;
            *) echo -e "${RED}That is not a valid option.${REDF}";;
        esac
done