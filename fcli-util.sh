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
    echo -e "${GREEN}Static Application Security Testing${GREENF}"
    echo -n "Ingresa la ruta de tu proyecto (.zip): "
    read project
    echo -n "Ingresa el nombre de la aplicación (SSC): "
    read app
    echo -n "Ingresa la versión de ${app} (SSC): "
    read version
    ###fcli
    fcli sc-sast scan start -v 23.2 -f $project --publish-to $app:$version --store x
    fcli sc-sast scan wait-for ::x::jobToken
    echo ""
}
packing(){
    echo -e "${GREEN}Herramienta para empaquetar proyectos${GREENF}"
    echo -n "Ingresa la ruta completa de la carpeta del proyecto: "
    read path_project
    cd "$path_project" #C:/Users/Angel Mariscurrena/Documents/Cybersecurity-Optima/Products/Fortify/Fortify-Extra/IWA/fortify-IWA-Java-main
    echo -n "Ingresa el nombre que tendrá el binario(.zip): "
    read binary
    echo -n "Selecciona la build tool (mvn,gradle,msbuild,none): "
    select option in "maven" "gradle" "msbuild" "ninguno" "quit"
    do
            case $option in
                maven) scancentral package -bt mvn -bf pom.xml -o $binary ;;
                gradle) scancentral package -bt gradle -bf build.gradle -o $binary ;;
                msbuild) scancentral package -bt msbuild -bf my.sln -o $binary ;;
                ninguno) scancentral package -bt none -o $binary ;;
                quit) clear && break;;
                *) echo -e "${RED}That is not a valid option.${REDF}";;
            esac
    done
}
OSS(){
    echo -e "${GREEN}Herramienta para empaquetar proyectos para analsis de composición de software${GREENF}"
    echo -n "Ingresa la ruta completa de la carpeta del proyecto: "
    read path_project
    cd "$path_project"
    echo -n "Ingresa el nombre que tendrá el binario(.zip): "
    read binary
    scancentral package -bt none -oss -o $binary
}

login
select option in "app" "appversion" "SAST-Scan" "Packaging-Project" "Packaging-OSS" "quit"
do
        case $option in
            app) app;;
            appversion) appversion;;
            SAST-Scan) sast;;
            Packing-Project) packing;;
            Packing-OSS) OSS;;
            quit) clear && break;;
            *) echo -e "${RED}That is not a valid option.${REDF}";;
        esac
done