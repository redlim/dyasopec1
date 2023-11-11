#!/bin/bash
#declaración de constantes
processFile="procesos";
serviceProcessFile="procesos_servicio";
intervalProcessFile="procesos_periodicos";
devilProcessFile="procesos_demonio";
bibleFile="Biblia.txt";
apocalipisFile="Apocalipsis";
saintPeterFile="SanPedro";
files=($processFile $serviceProcessFile $intervalProcessFile $devilProcessFile $bibleFile $apocalipisFile $saintPeterFile);
filesProcess=($processFile $serviceProcessFile $intervalProcessFile);
hellDirectory="Infierno"
#Demonio Dummie, tenéis que completarlo para que haga algo

function writeBible() {
    date=$(date +%H:%M:%S);
    echo "${date} $1" >> $bibleFile;
}

finishProcess() {
    echo "finalizando procesos"
    pid="el pid a finalizar"
    writeBible "El proceso $pid ha terminado"
    writeBible "se acabó el mundo"
}

deleteFiles() {
    echo "finalizando procesos"
}

#Bucle mientras que no llegue el apocalipsis
while [ ! -f "$apocalipisFile" ]
    do
        sleep 1s;
        #finish process of files
        finishProcess
        deleteFiles
        echo "waiting...";
    done

rm $apocalipisFile

#   -Lee las listas y revive los procesos cuando sea necaario dejando entradas en la biblia
#   -Puede usar todos los ficheros temporales que quiera pero luego en el Apocalipsis hay que borrarlos
#   -Hay que usar un lock para no acceder a las listas a la vez que Fausto
#   -Ojo al cerrar los proceos, hay que terminar el arbol completo no sólo uno de ellos
#Fin bucle
#Apocalipsis: termino todos los procesos y limpio todo dejando sólo Fausto, el Demonio y la Biblia
   
