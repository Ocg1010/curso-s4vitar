#!/bin/bash

function ctrl_c (){
  echo -e "[+]\n\n Saliendo...."
  tput cnorm ; exit 1
}

#Ctrl+C
trap ctrl_c INT

tput civis # Ocultar el cursos

for i in $(seq 1 254); do
  timeout 1 bash -c "ping -c 1 10.0.0.${i}" &>/dev/null && echo "[+] HOST 10.0.0.${i} ACTIVE" || echo "[+] HOST 10.0.0.${i} DESACTIVE" &
done; wait

# Recuperar el cursor
tput cnorm