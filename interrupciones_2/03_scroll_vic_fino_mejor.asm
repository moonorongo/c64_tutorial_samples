BasicUpstart2(main)

.const scrollLine = $0400+17*40
.const COLOUR1 = 0
.const COLOUR2 = 6
.const LINE1 = 200
.const LINE2 = 170

    * = $1000 "Main Program"

main:
    sei                           // deshabilito interrupciones

    lda #$7f                      // apago las interrupciones
    sta $dc0d                     // de la CIA

    lda $d01a                     // activo la irq
    ora #$01                      // por raster
    sta $d01a

    lda $d011                     // borro el MSB de raster
    and #$7f                      
    sta $d011

    lda #0                        // especifico una linea de raster
    sta $d012                     // LSB (puede ser cualquiera aca)

    lda #<intcode                 // Seteo en 788/9 
    sta 788                       // el byte bajo y el alto
    lda #>intcode                 // de nuestra rutina
    sta 789
    cli                           // habilito las interrupciones
    rts                           // retorno (en este caso BASIC)

intcode:
    lda modeflag
    beq lineaScroll
    jmp restauroPantalla

lineaScroll:                      // viene si modeflag es 0
{

    lda #$01                      // invertimos el modeflag
    sta modeflag                  // para que la proxima vez vaya a 
                                  // la otra parte del codigo
    lda #COLOUR1                  // ponemos color 
    sta $d020
    sta $d021

    jsr scrollPixel               // voy a mi rutina de scroll

    lda #LINE1                    // seteamos nuevamente la
    sta $d012                     // linea de interrupcion
    inc $d019                     // acusamos recibo de interrupcion

    jmp $ea31                     // salto a las rutinas del sistema
}

restauroPantalla:
{
    lda #$00                      // invertimos el modeflag
    sta modeflag

    lda #COLOUR2                  // ponemos el color
    sta $d020
    sta $d021

    ldx #0                        // dejamos el scroll fijo
    stx $d016   

    lda #LINE2                    // seteamos linea de raster
    sta $d012                     

    inc $d019                     // acusamos recibo
                 
                                  // PEEERO: 
    pla                           // Aqui salimos completamente
    tay                           // esta es la forma de salir de la
    pla                           // interrupción, restaurando
    tax                           // los registros.
    pla                           // lo explico con mas detalle a continuación
    rti
}




scrollPixel:
{
    ldx #7                    // 38 columnas, scroll h, index scroll fino
    cpx #255
    beq resetScrollFino
   
    stx $d016                 
    dec scrollPixel + 1
    rts

resetScrollFino:
    ldx #7
    stx scrollPixel + 1
    stx $d016
    jsr scrollChar
    rts
}



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

modeflag: .byte 0