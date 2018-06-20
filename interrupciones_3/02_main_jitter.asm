BasicUpstart2(main)

.const RASTERUNSTABLE = $1
.const RASTERCOLOR1 = $2
.const NORMALCOLOR = 0

.const LINE = 132 	
.const LINE2 = 160

main:
{
	sei                           

	lda #$7f		
	sta $dc0d
	sta $dd0d

	lda #$35
	sta $01	

	lda $d01a		
	ora #$01
	sta $d01a

	lda $d011		
	and #$7f
	sta $d011

	lda #LINE
	sta $d012 

	lda #<intcode
	sta $fffe      
	lda #>intcode
	sta $ffff

	asl $d019	
	bit $dc0d   
	bit $dd0d	

	cli          

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
	pha
	tya	
	pha
	txa 
	pha


	lda #<intcode_stable
	sta $fffe      
	lda #>intcode_stable
	sta $ffff

	setColor(RASTERUNSTABLE)

	inc $d012 
	asl $d019					  

    tsx
    cli

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
	txs
	waitLine(8)

	noEstabilizaJitter()

	setColor(0)
	nop
	nop
	nop
	
	setColor(RASTERCOLOR1) 

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

	setColor(NORMALCOLOR)

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
    ldx #cant_loops	
    dex      		
    bne *-1  		
    bit $00  		
}


.macro estabilizaJitter() {
	lda $d012 
	cmp $d012 
	beq *+2   
}


.macro noEstabilizaJitter() {
	nop 
	nop 
	nop
	bit $00 
	nop 
}

.macro setColor(color) {
	lda #color
	sta $d020
	sta $d021
}
