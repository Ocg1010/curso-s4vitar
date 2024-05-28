#!/bin/bash

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c () {
echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
exit 1
}

function helpPanel() {
  echo -e "\n${yellowColour}[!]${endcColour} ${grayColour}Uso:${endColour}${purpleColour} $0${endColour}\n"
  echo -e "\t ${blueColour}-m)${blueColour}${grayColour} Dinero con el que se desea jugar${endColour}"
  echo -e "\t ${blueColour}-t)${endColour}${grayColour} Técnica a utilizar${endColour} ${purpleColour}(${endColour}${yellowColour}martingala${endColour}${blueColour}/${endColour}${yellowColour}inverseLabrouchere${endColour}${purpleColour})${endColour} \n"
  exit 1
}

function martingala (){
  echo -e "\n[+] Vamos a jugar con la técnica Martingala\n"
}

# Ctrl+C 
trap ctrl_c INT

while getopts "m:t:h" arg; do
  case $arg in
    m) money=$OPTARG;;
    t) technique=$OPTARG;;
    h) helpPanel;;
  esac
done

if [ "$money" ] && [ "$technique" ]; then
    if [ "$technique" == "martingala" ]; then
      martingala
    else
      echo -e "${redColour}[!]${endColour}${grayColour} La técnica introducida no existe${endColour}"
      helpPanel
    fi
else
    helpPanel
fi


