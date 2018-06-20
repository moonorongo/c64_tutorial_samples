BasicUpstart2(main)

.const RASTERUNSTABLE = $1
.const RASTERCOLOR1 = $2
.const NORMALCOLOR = 0

.const LINE = 134 	
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
	txa	
	pha
	tya 
	pha

	setColor(RASTERUNSTABLE)
	
	lda #<intcode_restore
	sta $fffe      
	lda #>intcode_restore
	sta $ffff

	ldx #LINE2
	stx $d012 

	asl $d019					  

	pla
	tay
	pla
	tax
	pla

	rti
}

intcode_restore: 
{
	pha
	txa	
	pha
	tya 
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
	tay
	pla
	tax
	pla

	rti
}


.macro setColor(color) {
	lda #color
	sta $d020
	sta $d021
}
