BasicUpstart2(main)
.const scrollLine = $0400+22*40

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
	jsr scrollChar                // voy a mi rutina de scroll
	inc $d019					  // notifico interrupcion

	lda #100                      // Restauro el punto de interrupción
	sta $d012					  // para el proximo refresco 

	jmp $ea31                     // salto a las rutinas del sistema

scrollChar: 
{
    // rutina que scrollea un caracter a la izquierda
    ldx #0
loopScroll:    
    lda scrollLine+1, x
    sta scrollLine, x
    inx
    cpx #39
    bne loopScroll


    // obtengo un nuevo caracter 
textIndex:          // index de la cadena en text:
    ldx #0          // #0 se va a ir modificando
    lda $0400 , x
    sta scrollLine + 39

    inx
    cpx #39         // si llego al ultimo caracter
    beq resetIndex  // de la primera linea, reseteo el index
    stx textIndex + 1 // si no incremento
    rts 

resetIndex:
    ldx #0
    stx textIndex + 1    
    rts
} // end scroll

