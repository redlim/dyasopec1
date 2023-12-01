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

processFilePIDIndex=0
serviceProcessPIDIndex=0
intervalProcessTimeIndex=0
intervalProcessPeriodIndex=1
intervalProcessPIDIndex=2

function writeInServiceProcess() {
    echo $1 >> $serviceProcessFile;
}

function writeInPeriodicProcess() {
    echo $1 >> $intervalProcessFile
}

function writeBible() {
    date=$(date +%H:%M:%S);
    echo "${date} $1" >> $bibleFile;
}


function deleteFiles() {
    echo "finalizando procesos"
}

function killProcessAndChilds {
    echo $1 
    pstree -p |  grep $1 | grep -Eo '[0-9]{1,4}'
}

function checkProcessInHellAndKillIt(){
    pid=$1;
    line=$2
    file=$3
   if [ -f "$hellDirectiory/$pid" ]; then
        killProcessAndChilds $pid
        #borramos directorio del infierno
        rm "$hellDirectiory/$pid";
        #escribimos en la biblia
        writeBible "El proceso $pid ha terminado"
        #borramos la línea del fichero
        $(sed -i "/$line/d" "$file")

    fi
}

function checkAndUpdateProcessFile(){
    #leemos línea a línea el fichero procesos
    while IFS= read -r line
    do
        arrIN=(${line//' '/ });
        pid=${arrIN[$processFilePIDIndex]} ;
        
        #si el pid se encuentra en el infierno matamos el proceso
        checkProcessInHellAndKillIt $pid $line $processFile

        #si el processo ya no está en ejecución
        isProcessRunning=$(ps gl | grep -c $pid)
        if [ "$isProcessRunning" = 1 ]; then
            #escribimos en la biblia
            writeBible "El proceso $pid ha terminado"
            #borramos la línea del fichero
            $(sed -i "/$line/d" "$processFile")

        fi
    done < $processFile;
}

function checkAndUpdateServiceProcessFile(){
   #leemos línea a línea el fichero procesos
    while IFS= read -r line
    do
        currentLine=$line
        arrIN=(${line//' '/ });
        pid=${arrIN[$serviceProcessPIDIndex]};
        #si el pid se encuentra en el infierno matamos el proceso
        checkProcessInHellAndKillIt $pid $currentLine $serviceProcessFile

        #si el processo ya no está en ejecución
        isProcessRunning=$(ps gl | grep -c $pid)
        if [ "$isProcessRunning" = 1 ]; then
            #obtenemos el comando basandonos en una expresión regular que nos lo de
            command=$(grep -oP '^[0-9]+\s*\K.*' <<< "$currentLine")
            #ejecuto el comando y obtener el nuevo pid
            bash -c "'$command'" & PID=$!;
            #apunta entrada en la lista de procesos_servicio
            writeInServiceProcess "$PID $command";
            #escribimos en la biblia
            writeBible "El proceso $pid resucita con pid $PID"
            #borramos la línea del fichero
            $(sed -i "/$currentLine/d" "$serviceProcessFile")
        fi
    done < $serviceProcessFile;
}

function checkAndUpdateIntervalProcessFile(){
    #leemos línea a línea el fichero procesos
    while IFS= read -r line
    do
        currentLine=$line
        arrIN=(${line//' '/ });
        currentTime=${arrIN[$intervalProcessTimeIndex]};
        period=${arrIN[$intervalProcessPeriodIndex]};
        pid=${arrIN[$intervalProcessPIDIndex]};
        command=$(grep -oE "'([^']+)'" <<< "$currentLine")
          #si el pid se encuentra en el infierno matamos el proceso
        checkProcessInHellAndKillIt $pid $line $intervalProcessFile
        echo " bo que pasa $currentTime $period $pid $command"

        #Si el tiempo que ha pasado es menor que el tiempo que tiene que estar en ejecución:
        if [ $currentTime -le $period ]; then 
            let "currentTime++"

            $(sed -i "/$currentLine/d" "$intervalProcessFile")
            writeInPeriodicProcess "$currentTime $period $pid $command";
        else 
            #si el proceso no está en ejecución:
            isProcessRunning=$(ps gl | grep -c $pid)
            if [ "$isProcessRunning" = 1 ]; then
                #ejecuto el comando y obtener el nuevo pid
                echo $command
                bash -c "'$command'" & PID=$!;
                #apunta entrada en la lista de procesos_servicio
                writeInPeriodicProcess "0 $period $PID '$command'";
                #escribimos en la biblia
                writeBible "El proceso $pid resucita con pid $PID"
                #borramos la línea del fichero
                $(sed -i "/$currentLine/d" "$intervalProcessFile")
            fi
        fi
    done < $intervalProcessFile;

}


function checkProcessFiles() {
    checkAndUpdateProcessFile
   
    checkAndUpdateServiceProcessFile

    checkAndUpdateIntervalProcessFile
}

#Bucle mientras que no llegue el apocalipsis
while [ ! -f "$apocalipisFile" ]
    do
        sleep 1s;
        #finish process of files
        checkProcessFiles
        echo "waiting...";
    done

rm $apocalipisFile

#   -Lee las listas y revive los procesos cuando sea necaario dejando entradas en la biblia
#   -Puede usar todos los ficheros temporales que quiera pero luego en el Apocalipsis hay que borrarlos
#   -Hay que usar un lock para no acceder a las listas a la vez que Fausto
#   -Ojo al cerrar los proceos, hay que terminar el arbol completo no sólo uno de ellos
#Fin bucle
#Apocalipsis: termino todos los procesos y limpio todo dejando sólo Fausto, el Demonio y la Biblia
   
