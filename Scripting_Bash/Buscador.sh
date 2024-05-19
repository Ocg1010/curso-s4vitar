#!/bin/bash
# htbmachines.sh

# COLOURS
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# VARIABLES GLOBALES
mainUrl="https://htbmachines.github.io/bundle.js"


# FUNCIONES
function ctrl_c () {
  echo -e "$\n\n${redColour}[+]Saliendo...\n${endColour}"
  tput cnorm && exit 1
}
function helpPanel () {
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de maquina${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Motrar este panel de ayuda${endColour}\n"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP${endColour}\n"
}

function updateFiles (){
  if [ ! -f bundle.js ]; then
      tput civis
      echo -e "${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}\n"
      curl -s ${mainUrl} > bundle.js
      # js-beautify bundle.js | sponge bundle.js
      echo -e "${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados${endColour}\n"
      tput cnorm
  else
      tput civis
      echo -e "${yellowColour}[+]${endColour}${grayColour}Comprobando si hay actualizaciones pendientes${endColour}\n"
      curl -s ${mainUrl} > bundle_temp.js
      # js-beautify bundle_temp.js | sponge bundle_temp.js
      md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
      md5_original_value=$(md5sum bundle.js | awk '{print $1}')
      if [ "$md5_temp_value" == "$md5_original_value" ]; then
          echo -e "${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones, lo tienes todo al día ;)${endColour}\n"
          rm -r bundle_temp.js
      else
          echo -e "${yellowColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones disponibles${endColour}\n"
          sleep 1
          rm -rf bundle.js && mv bundle_temp.js bundle.js
          echo -e "${yellowColour}[+]${endColour}${grayColour}Los archivos han sido actualizados${endColour}\n"
      fi
      tput cnorm
  fi
}

function searchMachine (){
  machineName="$1"
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la maquina ${endColour}${blueColour}${machineName}${endColour}${grayColour}:${endColour}\n"
  cat bundle.js  | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d ',' | tr -d '"' | sed 's/^ *//'
  
  
}

function searchIP (){
  ipAddress="$1"
  machineName="$(cat bundle.js | grep "ip: \"${ipAddress}\"" -B 3 | grep "name:" | awk 'NF {print $NF}' | tr -d '"' | tr -d ",")"
  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la ip${endColour} ${blueColour}${ipAddress}${endColour} ${grayColour}es ${endColour}${purpleColour}${machineName}${endcolour}\n"
}

# CRTL+C
trap ctrl_c INT



# INDICADORES
declare -i parameter_counter=0


# MENU
while getopts "m:ui:h" arg; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    h) ;;
    i) ipAddress=$OPTARG; let parameter_counter+=3;;
  esac
done

if [ ${parameter_counter} -eq 1 ]; then
    searchMachine ${machineName}
elif [ ${parameter_counter} -eq 2 ]; then
    updateFiles
elif [ ${parameter_counter} -eq 3 ]; then
    searchIP ${ipAddress}
else
    helpPanel
fi