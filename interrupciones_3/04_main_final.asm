BasicUpstart2(main)

.const RASTERUNSTABLE = $1
.const RASTERCOLOR1 = $2
.const NORMALCOLOR = 0

// no podemos poner LINE = 131, 139, 147, 155... porque son badlines y rompen
// hay que recalcular waitLine() para las bad lines
.const LINE =  132 	
.const LINE2 = 160

main:
{
	sei                           
					
	// disable CIA
	lda #$7f		
	sta $dc0d
	sta $dd0d

	// Bank out kernal and basic
	// ponemos disponibles 
	// $A000-$BFFF (BASIC) 
	// y $E000-$FFFF (KERNAL)
	lda #$35
	sta $01	
/*
	Basicamente: apagamos las roms del basic y el kernel 
	(realmente, nos interesa apagar el kernel porque 
		necesitamos escribir un valor alli en $fffe y $ffff 
		y el sistema pueda leer lo que escribimos) 
	mas info leer: https://dustlayer.com/c64-architecture/2013/4/13/ram-under-rom
*/
	// aca: todo lo de antes... 
	lda $d01a		// enable VIC IRQ
	ora #$01
	sta $d01a

	lda $d011		// clear MSB raster
	and #$7f
	sta $d011

	lda #LINE
	sta $d012 

	lda #<intcode
	sta $fffe      
	lda #>intcode
	sta $ffff

	// esto lo hacemos para que no haga 
	// cosas raras cuando arranca... 
	asl $d019	// Ack any previous raster interrupt
	bit $dc0d   // reading the interrupt control registers 
	bit $dd0d	// clears them

	cli          


// este dummy loop es para que la interrupcion ocurra 
// en cualquier instruccion, asi tenemos un caso lo mas 
// real posible... en los ejemplos que encontre 
// normalmente hacian un jmp *, lo cual no era real, ya que 
// la interrupcion ocurria en una instruccion que conocemos (JMP)
dummy_loop:	
	ldx #$00
	nop
	inx
	nop
	ldx $d020
	cpx #33
	nop
	ldy #$00
	iny
	bit $00
	nop 
	ldx $d020
	nop
	ldx #$00
	nop
	inx
	ldx $d020
	nop
	cpx #33
	nop
	ldy #$00
	iny
	ldx $d020
	bit $00
	nop 
	ldx $d020
	nop
	ldx #$00
	nop
	ldx $d020
	inx
	nop
	cpx #33
	nop
	ldy #$00
	ldx $d020
	iny
	bit $00
	nop 
	ldx $d020
	nop
	ldx #$00
	nop
	inx
	ldx $d020
	nop
	cpx #33
	nop
	ldy #$00
	iny
	ldx $d020
	bit $00
	nop 
	ldx $d020
	nop
	jmp dummy_loop
}

intcode:
{
	// GUARDAMOS REGISTROS *1
	/* 
	   En los ejemplos que vi lo hace mejor
	   escribiendo codigo automodificable
	   el cual ocupa menos clocks del procesador
	   pero a fines didacticos esto es mas claro
	*/
	pha
	tya	
	pha
	txa 
	pha


	lda #<intcode_stable
	sta $fffe      
	lda #>intcode_stable
	sta $ffff

	// pongo la interrupcion en la proxima linea
	inc $d012 
	asl $d019					  

    // Almacena el actual puntero del stack 
    // porque no queremos volver aca cuando se produzca el RTI
    // sino que queremos que vaya al dummy_loop 
    // (o la parte de nuestro codigo)
    tsx
    cli

    // en algun punto en los siguientes nop's 
    // se ejecutara la siguiente interrupcion
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
}


intcode_stable:
{
// en este punto, se ejecuto la interrupcion en un comando NOP,
// por lo tanto, ya tenemos 1 o 2 clocks corridos a lo sumo
// (dependiendo si estaba ejecutando la instruccion cuando llamó 
//  la interrupcion o si la había finalizado)

	// nop 1 o 2 clocks
	// salto interrupcion 7 clocks
	// 8 o 9 clocks
	
	// Restaura el puntero del stack al punto de retorno 
	// donde se llamo por primera vez (y que guardamos en X)
	// nos interesa que esté en el punto donde guardamos (*1)
	// si no el RTI va a volver acá, y no es la idea
	txs
	// 10 u 11 clocks

	// espero que pase CASI toda la linea
	// el calculo: 
	// 	2 + (7 * (2 + 3)) + 2  + 3 = 42
	waitLine(8) // (43 + (10 u 11)) = 52/53)

	// corrige el jitter de 1 clock del nop
	// para q esto funcione tenemos q estar casi al final
	// de la linea: cargamos en A el valor de $d012
	// luego lo comparamos
	// si es igual hay un ciclo de menos, entonces salta (3 clocks)
	// si es distinto pasa, hay un ciclo de mas, no salta (2 clocks)
	// y con eso se estabiliza 

	estabilizaJitter()

	setColor(RASTERCOLOR1) 

	// restauro interrupcion a 2da linea
	lda #<intcode_restore
	sta $fffe      
	lda #>intcode_restore
	sta $ffff

	ldx #LINE2
	stx $d012 

	asl $d019					  

	pla                           
	tax                           
	pla                           
	tay                           
	pla                           

	rti
}

intcode_restore: 
{
	pha
	tya	
	pha
	txa 
	pha
	// en este punto esta sin estabilizar
	// necesitamos hacer nuevamente todo lo que hicimos
	// anteriormente... 
	setColor(NORMALCOLOR)

	// restauro interrupcion
	lda #<intcode
	sta $fffe      
	lda #>intcode
	sta $ffff

	ldx #LINE
	stx $d012 

	asl $d019					  

	pla                           
	tax                           
	pla                           
	tay                           
	pla                           

	rti
}


.macro waitLine(cant_loops) {
    ldx #cant_loops	//	2  
    dex      		//  2
    bne *-1  		//	3
    bit $00  		//  3
}


.macro estabilizaJitter() {
	lda $d012 // 4 		(56/57)
	cmp $d012 // 5 		(62/63)
	beq *+2   // 2 distinto o 3 igual
}


.macro noEstabilizaJitter() {
	nop 
	nop 
	nop
	bit $00 
	nop 
	// 11 clocks
}

.macro setColor(color) {
	lda #color	//	2
	sta $d020	//	4
	sta $d021   //	4
}
