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

# texto de ayuda
helpText="NAME | NOMBRE\n
    fausto.sh \n
    \t EN: Process handler created to obtain the max punctuation \n
    \t ES: Manejador de procesos creado para obtener la máxima calificación \n \n
    \t SYNOPSIS | DESCRIPCIÓN \n
    \t \t     fausto.hs [ OPTION ] [ INTERVAL ]* [ PID ]* [ COMMAND ]*\n
    \t \t     *optional | opcional \n \n
    \t OPTION | OPCIONES \n
    \t \t     run [COMMAND]: to run once a simple command | para lanzar un comando una sola vez\n
    \t \t     run-service [COMMAND]:to run a service | para lanzar un servicio \n
    \t \t     run-periodic [INTERVAL] [COMMAND]: to run a command just for a interval time | para lanzar un comando durante un intervalo de tiempo \n
    \t \t     help: visualize the options | visualiza las opciones \n
    \t \t     stop: [PID] to stop a process | para parar un proceso \n
    \t \t     end: to stop all process | para parar todos los procesos \n \n

    \t EXAMPLES | EJEMPLOS \n
    \t \t     $ ./Fausto.sh run 'sleep 10; echo hola' \n

    \t \t     $ ./Fausto.sh run-service 'yes > /dev/null'\n
       
    \t \t     $ ./Fausto.sh run-periodic 10 'echo hola'\n
    

    \n\nAUTHOR | AUTOR \t
        Written by Wilder Olmos Bernal
"

#Borrado de ficheros si existen
deleteAndCreateInitialFiles() {
    for file in ${files[@]}; do
        #Borramos si existe el fichero
        if [ -f "$file" ]; then
            rm "$file";
        fi
        #creamos todo de nuevo menos Apocalipsis
        if [ $file != $apocalipisFile ]; then
            touch $file;
        fi
    done

    #borramos y creamos el directorio Infierno.
    if [ -d "$hellDirectory" ]; then
        rm -Rf "$hellDirectory";
    fi
    mkdir $hellDirectory;
}


function writeBible() {
    date=$(date +%H:%M:%S);
    echo "${date} $1" >> $bibleFile;
}

function initBible(){
    writeBible "---------------Génesis---------------"
}


function writeInProcess() {
    echo $1 >> $processFile;
}

function writeInServiceProcess() {
    echo $1 >> $serviceProcessFile;
}

function writeInPeriodicProcess() {
    echo $1 >> $intervalProcessFile
}

#Si el Demonio no está vivo lo crea
isDaemonRunning=$(ps gl | grep -c 'Demonio.sh')
if [ $isDaemonRunning -lt 2 ]
then
    deleteAndCreateInitialFiles
    echo "arrancando demonio";
    $(nohup ./Demonio.sh >> /dev/null  &) 
    initBible;
    echo $isDaemonRunning
fi

#ejecuta el comando run
function executeRun() {
    command=$@;
    #ejecuta el comando y obtener el pid
    eval $@ & PID=$!;
    #apunta entrada en la lista de procesos
    writeInProcess "$PID '$command'";
    #apunta entrada en la Biblia.
    writeBible "El proceso $PID '$command' ha nacido.";
}

#ejecuta el comando run-service
function executeRunService() {
    command=$@;
    #ejecuta el comando y obtener el pid
    eval $@ & PID=$!;
    #apunta entrada en la lista de procesos_servicio
    writeInServiceProcess "$PID '$command'";
    #apunta entrada en la Biblia.
    writeBible "El proceso $PID '$command' ha nacido.";
}

#ejecuta el comando run-periodic
function executeRunPeriodic() {
    interval=$1;
    shift 1;
    command=$@;
    #ejecuta el comando y obtener el pid
    eval $command & PID=$!;
    #apunta entrada en la lista de procesos periódicos
    writeInPeriodicProcess "0 $interval $PID '$command'";
    #apunta entrada en la Biblia.
    writeBible "El proceso $PID '$command' ha nacido.";
}

#ejecuta el comando list
function executeList() {
    echo "Procesos:";
    $(cat $processFile);
    echo "Procesos servicio:";
    $(cat $serviceProcessFile);
    echo "Procesos periódicos:";
    $(cat $intervalProcessFile);
}


#ejecuta el comando help
function executeHelp() {
    echo -e $helpText;
}

#busca un pid en todos los ficheros
#devuelve true si lo encuentra y false en otro caso.

function findProccessInFile(){
len=${#filesProcess[@]};
start=0;
result="";
while  [ $start -lt $len ] && [ "$result" = "" ]
    do
        processFile=${filesProcess[$start]};
        while IFS= read -r line
        do
            #arrIN=(${line//' '/ });
            #echo ${arrIN[0]} ;
            case $line in (*"$1"*)
                result=$1;
            ;;esac
        #return;
        done < $processFile;
    let start=$start+1;
    done;
}

#ejecuta el comando stop
function executeStop() {
 findProccessInFile $1
 echo "$result el resultado";
    if [ "$result" != "" ]; then
        $(touch "$hellDirectory/$1");
    fi
}

function executeEnd() {
    touch $apocalipisFile
}

case $1 in
  "run")
    executeRun $2;
  ;;
  "run-service")
    executeRunService $2;
  ;;
  "run-periodic")
    executeRunPeriodic $2 $3;
  ;;
    "list")
    executeList;
  ;;
    "help")
    executeHelp;
  ;;  
  "stop")
    executeStop $2;
  ;;
    "end")
    executeEnd;
  ;;
# error
  *)
    echo -e 'There is and error | tienes un error /n You can use ./Fausto.sh help | puedes usar /.Fausto.sh help';
  ;;
esac


#Al leer/escribir en las listas hay que usar bloqueo para no coincidir con el Demonio
