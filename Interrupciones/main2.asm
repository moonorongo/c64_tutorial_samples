BasicUpstart2(main)
/*
    Interrupts - LO BASICO
    Este programa cicla los colores del borde, 60 veces 
    por segundo. En este ejemplo la fuente de interrupción
    es el VIC2
*/

	* = $1000 "Main Program"

main:
	sei                           // deshabilito interrupciones

	lda #$7f                      // apago las interrupciones
	sta $dc0d					  // de la CIA

	lda $d01a                     // activo la irq
	ora #$01					  // por raster
	sta $d01a

	lda $d011                     // borro el MSB de raster
	and #$7f					  
	sta $d011

	lda #100                      // especifico una linea de raster
	sta $d012                     // LSB (puede ser cualquiera aca)

	lda #<intcode                 // Seteo en 788/9 
	sta 788                       // el byte bajo y el alto
	lda #>intcode                 // de nuestra rutina
	sta 789
	cli                           // habilito las interrupciones
	rts                           // retorno (en este caso BASIC)


intcode:
	inc $d020                     // ciclo el color del borde
	
	lda #$ff                      // *1 ver explicación a continuación
	sta $d019					  
	//inc $d019					  // *2 forma optimizada

	lda #100                      // Restauro el punto de interrupción
	sta $d012					  // para el proximo refresco 

	jmp $ea31                     // salto a las rutinas del sistema
