#!/bin/bash

# COLOURS
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c (){
echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
tput cnorm && exit 1
}
# Variables globales
declare -r main_url="https://htbmachines.github.io/bundle.js"


# ctrl+c
# trap es un comando que establece una trampa para señales especificas
# crtl_c nombre de la funsón o comando que se ejecutara cuando reciba la señal
# INT es una señal que estamos atrapando, señal de iterrupción (iterrupt) la cual se envía cuando el susuario preciona Ctrl+c en el terminal
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}\n"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o acttualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por un nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por la dificultad de la máquina${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por el sistema operativo${endColour}"
  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar por skill${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Obtener link de la resolución de la máquina en YouTube${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}\n"
}


function updateFiles (){
    tput civis
  if [[ ! -f bundle.js ]]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s -X GET ${main_url} > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados${endColour}\n"
    tput cnorm
  else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciones pendientes...${endColour}"
    curl -s -X GET ${main_url} > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js  | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [[ "${md5_temp_value}" == "${md5_original_value}" ]]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No se han detectado actualizaciones, lo tienes todo al día ;)${endColour}"
      rm -r bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Se han encontrado actualizaciones disponibles${endColour}"
      sleep 2
      rm -r bundle.js && mv bundle_temp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actualizados${encColour}" 
    fi
    tput cnorm
  fi
}

function searchMachine (){
  machineName="$1"
  
  machineName_checker=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -Ev "id|sku|resuelta" | tr -d "," | tr -d "\"" | sed 's/^ *//')

  if [[ ${machineName_checker} ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la máquina${endColour} ${blueColour}${machineName}${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -Ev "id|sku|resuelta" | tr -d "," | tr -d "\"" | sed 's/^ *//'
    echo -e "\n"
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi

}

function searchIP (){
  
  ipAddress="$1"
  machineName=$(cat bundle.js | grep "ip: \"${ipAddress}\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d "\"" | tr -d ",")
  if [[ ${machineName} ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La máquina correspondiente para la IP${endColour} ${blueColour}${ipAddress}${endColour} ${grayColour}es ${endColour}${purpleColour}${machineName}${endColour}\n"
    #searchMachine ${machineName}
  else
    echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}\n"
  fi
}

function getYoutubeLink (){
  machineName=${1}
  youtubeLink=$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -Ev "id|sku|resuelta" | tr -d "," | tr -d "\"" | sed 's/^ *//' | grep 'youtube' | awk 'NF {print $NF}')
  if [[ ${youtubeLink} ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial para esta máquina está en el siguiente enlace:${endColour} ${blueColour}${youtubeLink}${endColour}\n"
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi
}

function getMachineDifficulty (){
  difficulty=${1}
  results_check=$(cat bundle.js | grep "dificultad: \"${difficulty}\""  -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d "\"" | column)
  if [[ ${results_check} ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Representando las máquinas que poseen un nivel de dificultad ${endColour}${blueColour}${difficulty}${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "dificultad: \"${difficulty}\""  -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d "\"" | column
    echo -e "\n"
  else
    echo -e "\n${redColour}[!] La dificultad indicada no existe${endColour}\n"
  fi
}

function getOSMachines (){
  os=${1}
  os_results=$(cat bundle.js | grep "so: \"${os}\""  -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d "\"" | column)
  if [[ ${os_results} ]]; then
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Mostrando las máquinas cuyo sistema operativo es${endColour} ${blueColour}${os}${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "so: \"${os}\""  -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d "\"" | column
  else
    echo -e "\n${redColour}[!] El sistema operativo no existe${endColour}\n"
  fi
}

function getOsDifficultyMachines (){
  difficulty=${1}
  os=${2}
  check_results=$(cat bundle.js | grep "so: \"${os}\"" -C 4 | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column)
  if [[ ${check_results} ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando máquinas de dificultad${endColour} ${blueColour}${difficulty}${endColour} ${grayColour}que tengan sistema operativo ${endColour}${purpleColour}${os}${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "so: \"${os}\"" -C 4 | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column
    echo -e "\n"
  else
    echo -e "\n${redColour}[!] Se ha detectado una dificultad o sistema operativo incorrectos ${endColour}\n"
  fi
}

function getSkill (){
  skill=${1}
  check_skill=$(cat bundle.js | grep "skills: " -B 6 | grep -i "${skill}" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d "," | tr -d '"')
  if [[ ${check_skill} ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}A continuación se representan las máquinas donde se toca la skill${endColour} ${blueColour}${skill}${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "skills: " -B 6 | grep -i "${skill}" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d "," | tr -d '"' | column
    echo -e "\n"
  else
    echo -e "\n${redColour}[!] No se ha encontrado ninguna máquina con la skill indicada ${endColour}\n"
  fi
}

# Indicadores
declare -i parameter_counter=0
declare -i indicador_difficulty=0
declare -i indicador_os=0

# Sintaxis: getopts optstring variable
#arg: Es la opción (opstring) que se está procesando.
#OPTARG: Es el valor proporcionado a esa opción, si lo requiere.
# El case se utiliza para ejecutar diferentes bloques de código según el valor de una variable.

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; parameter_counter+=3;;
    y) machineName="$OPTARG"; parameter_counter+=4;;
    d) difficulty="$OPTARG"; indicador_difficulty=1; parameter_counter+=5;;
    o) os="$OPTARG"; indicador_os=1; parameter_counter+=6;;
    s) skill="$OPTARG"; parameter_counter+=7;;
    h) ;;
  esac
done

if [[ ${parameter_counter} -eq 1 ]]; then
  searchMachine ${machineName}
elif
  [[ ${parameter_counter} -eq 2 ]]; then
  updateFiles
elif [[ ${parameter_counter} -eq 3 ]]; then
  searchIP ${ipAddress}
elif [[ ${parameter_counter} -eq 4 ]]; then
  getYoutubeLink ${machineName}
elif [[ ${parameter_counter} -eq 5 ]]; then
  getMachineDifficulty ${difficulty}
elif [[ parameter_counter -eq 6 ]]; then
  getOSMachines ${os}
elif [[ ${indicador_difficulty} -eq 1 && ${indicador_os} -eq 1 ]]; then
  getOsDifficultyMachines ${difficulty} ${os}
elif [[ ${parameter_counter} -eq 7 ]]; then
  getSkill "${skill}"
else
  helpPanel
fi



