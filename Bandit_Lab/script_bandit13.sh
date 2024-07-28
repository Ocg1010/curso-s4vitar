#!bin/bash
# DESCOMPRESSOR

function ctrl_c (){
  echo -e "[+] Saliendo...\n"
 # En cuanto a los códigos de retorno, en Linux, un código de retorno de 0 generalmente indica éxito, mientras que cualquier otro valor indica algún tipo de error. 
#rc = return_code 
#0: Éxito.
#1: Error genérico.
#2: Error de sintaxis.
#126: Permiso denegado.
#127: Comando no encontrado.
#128: Error de salida del script (normalmente se suma el número de la señal).
#130: El comando fue interrumpido por una señal (por ejemplo, Ctrl+C).
#255: Error de salida desconocido.
  exit 1
}

# Ctrl+C
trap ctrl_c INT

first_file_name="data.gz"
# LO ENCIERRO EN DOBLE COMILLA PORQUE ESTO LO QUIERO GUARDAR COMO UN STRING
decompressed_file_name="$(7z l data.gz | tail -n 3 | head -n 1 | awk 'NF{print $NF}')"

# EXTRAEMOS EL CONTENIDO DEL PRIMER COMPRIMIDO, Y OCULTAMOS TANTO EL STDERR COMO EL STDOUT 
7z x ${first_file_name} &> /dev/null

# ESTE while LO QUE HACE ES QUE SI EL ARCHIVO decompressed_file_name TIENE ALGO PUES QUIERO QUE HAGAS LA ACCION A INDICAR, SIEMPRE Y CUANDO LA CONDICION SE CUMPLA (QUE EL ARCHIVO TENGA ALGO)
while [ ${decompressed_file_name} ]; do
  echo -e "\n[+] Nuevo archivo descomprimido: ${decompressed_file_name}"
  # DESCOMPRIMIMOS EL ARCHIVO QUE TENIA EN UN INICIO DENTRO data.gz 
  7z x ${decompressed_file_name} &> /dev/null
  # SI TODO SALIO BIEN PODREMOS LISTAR SI HAY OTRO COMPRIMIDO Y VOLVER A INICIAR EL BUCLE, SI NO FINALIZARIA PORQUE YA NO HAY UN ARCHIVO COMPRIMIDO
  decompressed_file_name="$(7z l ${decompressed_file_name} 2> /dev/null | tail -n 3 | head -n 1 | awk 'NF{print $NF}')"
  
done
