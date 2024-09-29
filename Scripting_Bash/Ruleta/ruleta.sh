#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

#Ctrl+C
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso${endColour} ${purpleColour}$0${endColour} \n"
  echo -e "\t${blueColour}-m)${endColour} ${grayColour}Dinero con el que se desea jugar${endColour}"
  echo -e "\t${blueColour}-t)${endColour} ${grayColour}Técnica a utilizar${endColour} ${purpleColour}(${endColour}${yellowColour}martingala${endColour}${blueColour}/${endColour}${yellowColour}inverseLabrouchere${endColour}${purpleColour})${endColour}\n"
  exit 1
}
function martingala (){
  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Dinero actual: ${endColour}${yellowColour}${money}€${endColour}"
  echo -ne "${yellowColour}[+]${endColour} ${grayColour}¿Cuánto dinero tienes pensado apostar? -> ${endColour}" && read initial_bet
  echo -ne "${yellowColour}[+]${endColour} ${grayColour}¿A qué desea apostar continuamente (par/impar)? -> ${endColour}" && read par_impar

  echo -ne "\n${yellowColour}[+]${endColour} ${grayColour}Vamos a jugar con una cantidad inicial de${endColour}${yellowColour} ${initial_bet}€${endColour}${grayColour} a${endColour}${yellowColour} ${par_impar}${endColour}\n"
  tput civis
  while true; do
    random_number=$((RANDOM % 37))
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Ha salido el número${endColour}${blueColour} ${random_number}${endColour}"
    if [[ "$((random_number % 2))" -eq 0 ]]; then
      if [[ ${random_number} -eq 0 ]]; then
        echo -e "[+] Ha salido el 0, por lo tanto perdemos"
      else
      echo -e "[+] El número que ha salido es par"
      fi
    else
      echo -e "[+] El número que ha salido es impar"
    fi
    sleep 2
  done


  tput cnorm
}
while getopts "m:t:h" arg; do
  case $arg in 
    m) money=$OPTARG;;
    t) technique=$OPTARG;;
    h) helpPanel;;
  esac
done

if [[ ${money}  ]] && [[ ${technique} ]]; then
  if [[ "${technique}" == "martingala" ]]; then
    martingala
  else
    echo -e "\n${redColour}[!] La técnica introducida no existe${endColour}"
    helpPanel
  fi
else
  helpPanel
fi