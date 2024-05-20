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
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por la dificultad de una máquina${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por el sistema operativo${endColour}"
  echo -e "\t${purpleColour}s)${endColour}${grayColour} Buscar por skill${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link de la resolución de la máquina en YouTube${endColour}"
  
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Motrar este panel de ayuda${endColour}\n"

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

  machineName_checker="$(cat bundle.js  | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d ',' | tr -d '"' | sed 's/^ *//')"

  if [ "${machineName_checker}" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la maquina ${endColour}${blueColour}${machineName}${endColour}${grayColour}:${endColour}\n"
    cat bundle.js  | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d ',' | tr -d '"' | sed 's/^ *//' 
    echo ''
  else
    echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
  fi
}

function searchIP (){
  ipAddress="$1"

  machineName="$(cat bundle.js | grep "ip: \"${ipAddress}\"" -B 3 | grep "name:" | awk 'NF {print $NF}' | tr -d '"' | tr -d ",")"

  if [ "${machineName}" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la ip${endColour} ${blueColour}${ipAddress}${endColour} ${grayColour}es ${endColour}${purpleColour}${machineName}${endcolour}\n"
  else
    echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}\n"
  fi
}

function getYoutubeLink () {
  machineName="$1"
  youtubeLink="$(cat bundle.js  | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d ',' | tr -d '"' | sed 's/^ *//' | grep 'youtube' | awk 'NF {print $NF}')"
  if [ "${machineName}" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} El tutorial para esta máquina esta en el siguiente enlace: ${endColour}${blueColour}${youtubeLink}${endColour}\n"
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe ${endColour}\n"
  fi
}

function getMachinesDifficulty (){
  difficulty="$1"

  results_check="$(cat bundle.js | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name:" | awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "${results_check}" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${greyColour}Representando las maquinas que poseen un nivel de dificultad ${endColour}${blueColour}${difficulty}${endcolour}${grayColour}:${endColour}\n"
      echo -e "${results_check}"
  else
      echo -e "\n${redColour}[!] La dificultad indicada no existe ${endColour}\n"
  fi
}

function getOSMachines () {
  os="$1"
  
  os_results="$(cat bundle.js | grep "so: \"${os}\"" -B 5 | grep 'name:' | awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "${os_results}" ]; then
      echo -e "${yellowColour}[+]${endColour}${grayColour} Mostrando las máquinas cuyo sistema operativo es${endColour} ${blueColour}${os}${endColour}${grayColour}:${endColour} \n"
      cat bundle.js | grep "so: \"${os}\"" -B 5 | grep 'name:' | awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column
  else
      echo -e "\n${redColour}[!] El sistema operativo indicado no existe ${endColour}\n"
  fi
}

function getOSDifficultyMacbines () {
  difficulty=$1
  os=$2
  
  check_results="$(cat bundle.js | grep "so: \"${os}\"" -C 4 | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name:" | awk 'NF {print $NF}' | tr -d '"' | tr -d "," | column)"

  if [ "${check_results}" ]; then
      echo -e "${yellowColour}[+]${endColour}${grayColour} Listando máquinas de dificultad${endColour} ${blueColor}${difficulty}${endColour}${grayColour} que tengan sistema operativo${endColour}${purpleColour} ${os}${endColour}${graycolour}:${endColour}"
      cat bundle.js | grep "so: \"${os}\"" -C 4 | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name:" | awk 'NF {print $NF}' | tr -d '"' | tr -d "," | column
  else
      echo -e "\n${redColour}[!] Se ha indicado una dificultad o sistema operativo incorrectos ${endColour}\n"
  fi
}

function getSkill (){
  skill="$1"

  check_skill="$(cat bundle.js  | grep 'skills:' -C 6 | grep -i "Snmp enumeration" -B 7 | grep 'name: ' | awk 'NF {print $NF}' | tr -d '"' | tr -d "," | column)"

  if [ "${check_skill}" ]; then
      echo -e "${yellowColour}[+]${endColour}${grayColour} A continuación se representan las maquinas donde se ve toca la skill ${endColour}${blueColour}${skill}${endColour}${grayColour}:${endColour}\n"
      cat bundle.js  | grep 'skills:' -C 6 | grep -i "${skill}" -B 7 | grep 'name: ' | awk 'NF {print $NF}' | tr -d '"' | tr -d "," | column
  else
      echo -e "\n${redColour}[!] No se ha encontrado ninguna máquina con la skill indicada ${endColour}\n"
  fi
}

# CRTL+C
trap ctrl_c INT



# INDICADORES
declare -i parameter_counter=0

# CHIVATOS
declare -i chivato_difficulty=0
declare -i chivato_os=0


# MENU
while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    h) ;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; parameter_counter+=6;;
    s) skill="$OPTARG"; parameter_counter+=7;;
  esac
done

if [ ${parameter_counter} -eq 1 ]; then
    searchMachine ${machineName}
elif [ ${parameter_counter} -eq 2 ]; then
    updateFiles
elif [ ${parameter_counter} -eq 3 ]; then
    searchIP ${ipAddress}
elif [ ${parameter_counter} -eq 4 ]; then
    getYoutubeLink ${machineName}
elif [ ${parameter_counter} -eq 5 ]; then
    getMachinesDifficulty ${difficulty}
elif [ ${parameter_counter} -eq 6 ]; then
    getOSMachines $os
elif [ ${parameter_counter} -eq 7 ]; then
    getSkill "$skill"
elif [ ${chivato_difficulty} -eq 1 ] && [ ${chivato_os} -eq 1 ]; then
    getOSDifficultyMacbines $difficulty $os 
else   
    helpPanel
fi