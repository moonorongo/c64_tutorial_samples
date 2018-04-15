BasicUpstart2(main)
/*
    Interrupts - LO BASICO
    Este programa divide el borde en 2 colores
*/

	* = $1000 "Main Program"

.const COLOUR1 = 0
.const COLOUR2 = 1
.const LINE1 = 20
.const LINE2 = 150

main:

	sei                           // Todo esto es lo mismo que 
								  // en ejemplos anteriores

	lda #$7f
	sta $dc0d

	lda $d01a
	ora #$01
	sta $d01a

	lda $d011
	and #$7f
	sta $d011

	lda #LINE1
	sta $d012 

	lda #<intcode
	sta 788      
	lda #>intcode
	sta 789

	cli          
	rts          

intcode:

	lda modeflag                  // vemos si estamos en la parte
	                              // superior o inferior
	beq mode1 					  // de la pantalla
	jmp mode2

mode1:

	lda #$01                      // invertimos el modeflag
	sta modeflag				  // para que la proxima vez vaya a 
								  // la otra parte del codigo
	lda #COLOUR1                  // ponemos color 
	sta $d020

	lda #LINE1                    // seteamos nuevamente la
	sta $d012                     // linea de interrupcion

	inc $d019					  // acusamos recibo de interrupcion

	jmp $ea31                     // esta parte va a las rutinas 
								  // del kernel en ROM

mode2:
	lda #$00                      // invertimos el modeflag
	sta modeflag

	lda #COLOUR2                  // ponemos el color
	sta $d020

	lda #LINE2                    // seteamos linea de raster
	sta $d012                     


	// lda $#ff					  // interesante en este ejemplo
	// sta $d019                  // la diferencia de usar 
								  // uno u otro metodo.

	inc $d019					  // acusamos recibo


								  // PEEERO: 
	pla                           // Aqui salimos completamente
	tay                           // esta es la forma de salir de la
	pla                           // interrupción, restaurando
	tax                           // los registros.
	pla                           // lo explico con mas detalle a continuación
	rti

modeflag: .byte 0
