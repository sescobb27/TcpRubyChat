ruby version: ruby 1.9.2p320

ruby chatserver2.rb -p [port] -ip [ip or localhost]

ruby client.rb -p [port] -ip [ip or localhost]

##[list|LIST]!-all!!-sala!
lista los usuarios conectados en esa sala, con la opcion
-all
	lista todos los usuarios en todas las salas y en que
	sala se encuentra.
-sala 
	lista todas las salas disponibles
lo que esta dentro de !! es opcional.
####==============NO COPIE LOS ([ ])==============

##[\<end\>|\<END\>] o ctrl + c
termina session en el chat. 
####=======NO OLVIDE COPIAR LOS < >, sino sera leido como un mensaje normal.=======
####==============NO COPIE LOS ([ ])==============

##[p:|P:][name]:[message]
envia un mensaje privado al usuario con el nombre indicado
en el campo name, recuerde que este debe estar en su misma
sala.
####==============NO COPIE LOS ([ ])==============
####==============PERO SI LOS (:)==============

##[help|HELP]
despliega el menu de ayuda.
####==============NO COPIE LOS ([ ])==============

##\<new room\>\<NOMBRE\>
si desea crear una sala nueva, cuando vaya a escoger
una de las salas, coloque el nombre de la nueva sala,
recuerde que debe tener un nombre unico,siendo el
nombre de 3 o mas caracteres que pueden ser (LETRA, NUMERO, _).
si ya se encuentra en una sala, puede copiar el comando anterior
para crear la sala y luego con el proximo comando se puede cambiar
a ella.
####=======NO OLVIDE COPIAR LOS < >, sino sera leido como un mensaje normal.=======

##\<change\>\<NOMBRE\>
si desea cambiar de sala, recuerde que la sala debe existir
previamente o saldra error, si la sala no existe debe
crearla primero.
####=======NO OLVIDE COPIAR LOS < >, sino sera leido como un mensaje normal.=======