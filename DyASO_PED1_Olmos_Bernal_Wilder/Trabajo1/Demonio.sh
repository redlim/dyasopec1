#!/bin/bash
#declaración de constantes
processFile="procesos";
serviceProcessFile="procesos_servicio";
intervalProcessFile="procesos_periodicos";
devilProcessFile="procesos_demonio";
bibleFile="Biblia.txt";
apocalipisFile="Apocalipsis";
saintPeterFile="SanPedro";
files=($processFile $serviceProcessFile $intervalProcessFile $devilProcessFile $apocalipisFile $saintPeterFile);
filesProcess=($processFile $serviceProcessFile $intervalProcessFile);
hellDirectory="Infierno"
tempFile="tempFile"

processFilePIDIndex=0
serviceProcessPIDIndex=0
intervalProcessTimeIndex=0
intervalProcessPeriodIndex=1
intervalProcessPIDIndex=2

#para escribir en un fichero temporal
function writeInTempFile() {
    echo $1 >> $tempFile;
}

function moveTempFile() {
    #movemos el fichero al destino en caso de que exista.
    file=$1
    if [ -f "$tempFile" ]; then
        mv "$tempFile" "$file"
    fi
}

function writeInPeriodicProcess() {
    echo $1 >> $intervalProcessFile
}

function writeBible() {
    date=$(date +%H:%M:%S);
    echo "${date} $1" >> $bibleFile;
}


function killProcessAndChilds {
    pstree -p "$1" | grep -o '([0-9]\+)' | grep -o '[0-9]\+' | tac | xargs -I {} kill -15 {}
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
            command=$(grep -oP "'\K[^']+(?=')" <<< "$currentLine")
            #ejecuto el comando y obtener el nuevo pid
            eval $command & PID=$!;
            #escribimos en la biblia
            writeBible "El proceso $pid resucita con pid $PID"
            #apunta entrada en un fichero temporal
            writeInTempFile "$PID '$command'";
        fi
    done < $serviceProcessFile;
    
    moveTempFile $serviceProcessFile
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
        command=$(grep -oP "'\K[^']+(?=')" <<< "$currentLine")
          #si el pid se encuentra en el infierno matamos el proceso
        checkProcessInHellAndKillIt $pid $line $intervalProcessFile

        #Si el tiempo que ha pasado es menor que el tiempo que tiene que estar en ejecución:
        if [ $currentTime -le $period ]; then 
            let "currentTime++"
            writeInTempFile "$currentTime $period $pid $command";

        else 
            #si el proceso no está en ejecución:
            isProcessRunning=$(ps gl | grep -c $pid)
            if [ "$isProcessRunning" = 1 ]; then
                #ejecuto el comando y obtener el nuevo pid
                eval $command & PID=$!;
                #apunta entrada en el fichero temporal
                writeInTempFile "0 $period $PID '$command'";
                #escribimos en la biblia
                writeBible "El proceso $pid se ha reencarnado con pid $PID"
            fi
        fi
    done < $intervalProcessFile;

    #reescribimos en archivo.
    moveTempFile $intervalProcessFile
}


function checkProcessFiles() {
    checkAndUpdateProcessFile
   
    checkAndUpdateServiceProcessFile

    checkAndUpdateIntervalProcessFile
}

function killProcessFile(){
    #leemos línea a línea el fichero procesos
    while IFS= read -r line
    do
        arrIN=(${line//' '/ });
        pid=${arrIN[$processFilePIDIndex]} ;
        #Matamos todos los procesos arrancados y sus hijos
        killProcessAndChilds $pid 
        writeBible "El proceso $pid ha terminado"

    done < $processFile;
}

function killServiceFile(){
   #leemos línea a línea el fichero procesos
    while IFS= read -r line
    do
        currentLine=$line
        arrIN=(${line//' '/ });
        pid=${arrIN[$serviceProcessPIDIndex]};
        #Matamos todos los procesos arrancados y sus hijos      
        killProcessAndChilds $pid 
        writeBible "El proceso $pid ha terminado"

    done < $serviceProcessFile;
}

function killInterfalFile(){
    #leemos línea a línea el fichero procesos
    while IFS= read -r line
    do
        currentLine=$line
        arrIN=(${line//' '/ });
        pid=${arrIN[$intervalProcessPIDIndex]};
        #Matamos todos los procesos arrancados y sus hijo      
        killProcessAndChilds $pid
        writeBible "El proceso $pid ha terminado"

    done < $intervalProcessFile;
}


#Borrado de ficheros si existen
deleteAndCreateInitialFiles() {
    for file in ${files[@]}; do
        #Borramos si existe el fichero
        if [ -f "$file" ]; then
            rm "$file";
        fi
    done

    #borramos y creamos el directorio Infierno.
    if [ -d "$hellDirectory" ]; then
        rm -Rf "$hellDirectory";
    fi

    rm $apocalipisFile
}

function executeApocalipsis() {
    writeBible "--------Apocalipsis-------"
    killProcessFile
    killInterfalFile
    killServiceFile
    deleteAndCreateInitialFiles
    writeBible "Se acabó el mundo"
}

#Bucle mientras que no llegue el apocalipsis
while [ ! -f "$apocalipisFile" ]
    do
        sleep 1s;
        #finish process of files
        checkProcessFiles
    done

#ejecutar el apocalipsis cuando llegue.
if [ -f "$apocalipsisFile"]; then
    executeApocalipsis
fi
