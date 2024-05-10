#!bin/bash

funcion (){

  echo -e "[+]\n\n Saliendo...."
  tput cnorm ;exit 1
}

#Ctrl+C
trap ctrl_c INT


tput civis # Ocultar el cursos

for port in $(seq 1 65535); do
  echo "" > /dev/tcp/127.0.0.1/22 2>/dev/null && echo "[+] ${port} - OPEN" & # Con hilo
done; wait

# Recuperamos el cursos
tput cnorm