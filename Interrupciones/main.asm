// Compilar con Kickassembler - 
// BasicUpstart2: esta macro genera codigo 
// en BASIC para iniciar el programa
BasicUpstart2(main)

/*
    Interrupts - LO BASICO
    Este programa cicla los colores del borde, 60 veces 
    por segundo
*/
            * = $1000 "Main Program"
main:
	sei 				// Deshabilita interrupciones
	lda #<intcode 		// Seteo en 788/9 
	sta 788 			// el byte bajo y el alto
	lda #>intcode 		// de nuestra rutina
	sta 789
	cli                           // habilito las interrupciones
	rts                           // retorno (en este caso BASIC)

								  // nuestra super rutina	
intcode:
	inc $d020                     // cicla el color de borde
	jmp $ea31                     // salto a las rutinas del sistema