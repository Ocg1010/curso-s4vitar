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
tput cnorm; exit 1
}

function helpPanel() {
  echo -e "\n${yellowColour}[!]${endcColour} ${grayColour}Uso:${endColour}${purpleColour} $0${endColour}\n"
  echo -e "\t ${blueColour}-m)${blueColour}${grayColour} Dinero con el que se desea jugar${endColour}"
  echo -e "\t ${blueColour}-t)${endColour}${grayColour} Técnica a utilizar${endColour} ${purpleColour}(${endColour}${yellowColour}martingala${endColour}${blueColour}/${endColour}${yellowColour}inverseLabrouchere${endColour}${purpleColour})${endColour} \n"
  exit 1
}

function martingala (){
  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Dinero actual:${endColour}${yellowColour} ${money}€${endColour}"
  echo -ne "\n${yellowColour}[+]${endColour}${grayColour} ¿Cuánto dinero tienes pensado apostar? -> ${endColour}" && read initial_bet
  echo -ne "\n${yellowColour}[+]${endcColour}${grayColour} ¿A que deseas apostar continuamente? (par/impar) -> ${endColour}" && read par_impar

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Vamos a iniciar con una cantidad de${endColour}${yellowColour} ${initial_bet}€${endColour}${grayColour} a${endColour}${yellowColour} ${par_impar}${endColour}" 

  backup_bet=$initial_bet
  play_counter=1
  jugadas_malas=""

  tput civis  # Ocultar el cursor
  while true; do
    money=$(($money - $initial_bet))
#    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Acabas de apostar${endColour} ${yellowColour}${initial_bet}€${endColour}${grayColour} y tienes${endColour}${yellowColour} ${money}€${endColour}"
    random_number="$(($RANDOM % 37))"
#    echo -e "${yellowColour}[+]${endColour}${grayColour} Ha salido el número${endColour}${yellowColour} ${random_number}${endColour}"
    if [ ! "$money" -lt 0 ]; then
      if [ "$par_impar" == "par" ]; then
        # Toda esta definicion es para cuando apostamos por números pares
       
        if [ "$(($random_number % 2))" -eq 0 ]; then
          if [ "$random_number" -eq 0  ]; then
#            echo -e "${redColour}[+] Ha salido el 0, por lo tanto perdemos${endColour}"
            initial_bet=$(($initial_bet * 2))
            jugadas_malas+="${random_number} "
#            echo -e "${yellowColour}[+]${endColour}${grayColour}Ahora mismo te quedas en ${endColour}${yellowColour}${money}€${endColour}"

          else
#            echo -e "${yellowColour}[+]${endColour}${greenColour} El número que ha salido es par ¡ganas!${endColour}"
            reward=$(($initial_bet * 2))
#            echo -e "${yellowColour}[+]${endColour}${grayColour} Ganas un total de ${endColour}${yellowColour}${reward}€${endColour}"
            money=$(($money + $reward))
#            echo -e "${yellowColour}[+]${endColour}${grayColour} Tienes${endColour}${yellowColour} ${money}${endColour}"
            initial_bet=$backup_bet
            jugadas_malas=""
          fi
        else
#          echo -e "${yellowColour}[+]${endColour}${redColour} El número que ha salido es impar y ¡pierdes!${endColour}"
          initial_bet=$(($initial_bet * 2))
          jugadas_malas+="$random_number "
#          echo -e "${yellowColour}[+]${endColour}${grayColour}Ahora mismo te quedas en ${endColour}${yellowColour}${money}€${endColour}"
        fi
      else
      
  # Toda esta definición es para cuando apostamos por números impares
        if [ "$(($random_number % 2))" -eq 1 ]; then
#            echo -e "${yellowColour}[+]${endColour}${greenColour} El número que ha salido es impar ¡ganas!${endColour}"
            reward=$(($initial_bet * 2))
#            echo -e "${yellowColour}[+]${endColour}${grayColour} Ganas un total de ${endColour}${yellowColour}${reward}€${endColour}"
            money=$(($money + $reward))
#            echo -e "${yellowColour}[+]${endColour}${grayColour} Tienes${endColour}${yellowColour} ${money}${endColour}"
            initial_bet=$backup_bet
            jugadas_malas=""
        else
#          echo -e "${yellowColour}[+]${endColour}${redColour} El número que ha salido es par y ¡pierdes!${endColour}"
          initial_bet=$(($initial_bet * 2))
          jugadas_malas+="$random_number "
#          echo -e "${yellowColour}[+]${endColour}${grayColour}Ahora mismo te quedas en ${endColour}${yellowColour}${money}€${endColour}"
        fi
      fi   
      else
      # Nos quedamos sin dinero
      echo -e "\n${redColour}[!] Te has quedado sin dinero${endColour}\n"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Han habido un total de${endcolour}${yellowColour} $((${play_counter} -1))${endColour}${grayColour} jugadas${endcolour}\n" 
      echo -e "${yellowColour}[+]${endColour}${grayColour} A continuacion se van a representar las malas jugadas consecutivas que han salido:${endColour}\n"
      echo -e "\n${blueColour}[ ${jugadas_malas}]${endColour}"
      tput cnorm; exit 0
    fi 

    let play_counter+=1
    
  done

  tput cnorm # Recuperamos el cursor
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


