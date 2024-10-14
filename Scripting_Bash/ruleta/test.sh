#!/bin/bash

declare -a myArray=(1 2 3 4)

#declare -i posicion=0

#for element in ${myArray[@]}; do
#  echo -e "[+] Elemento en la posicion [${posicion}]: ${element}"
#  let posicion+=1
#done
myArray+=(5)
echo ${myArray[@]}
