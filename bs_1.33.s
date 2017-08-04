.feature labels_without_colons, pc_assignment
; ****************************
	flag =$0298
	ff =255
	seri2 =$029b
	seri1 =$029c
	sero2 =$029e
	sero1 =$029d
	serst =$0297
	map  =$0299
	blnkt =$0313
	blnk1 =$02be
	blnk2 =$02bf
	acia =$d600
	mike  =1
.if mike

	*=$ecd9
bc	.byt 11,0

	*=$e535
	.byt 15
	tpi =$d500
rtsb =4
.else
	tpi =$df00
	bc =$ecd9
.endif

;
;********************************
;--------------------------------
;aenderungen am rom
;--------------------------------
;farbe fuer clr/home hintergrund
	*=$e4da
	lda $0286

	*=$eb1c
	ldy #3; cursor speed

	*=$ff7d
	jmp nreset; clkhi bei cont und rs232 init

;********************************
;--------------------------------
;        rs 232 per acia
;--------------------------------
; belegt     $f014-$f0ac
;            $f409-$f49d
;--------------------------------
.if mike
	serts =tpi+2
.endif
;-------open
	*=$f409
rsopen	ldy #0
	sty serst
rs0	cpy $b7
	beq rs1
	lda ($bb),y
	sta $0293,y
	iny
	cpy #$04
	bne rs0
rs1	lda $0293
	ora #16
	sei
	sta acia+1
	sta acia+3
	lda $0294
	and #$f0
	ora #$07
	sta acia+2
	lda acia+1
	lda #0
	sta $02a1
	cli
	jsr $fe27
	lda $f8
	bne rs2
	dey
	sty $f8
	stx $f7
rs2	lda $fa
	bne rs3
	dey
	sty $fa
	stx $f9
rs3	sec
	lda #$f0
	jmp $fe2d

;-------- reset
nreset	jsr freset
rsreset	sta acia+1
	rts

;-------- basin
rsbasin	lda serst
	ldy seri1
	cpy seri2
	beq rsbie
	and #$f7
	sta serst
	lda ($f7),y
	inc seri1
	pha
	lda $0294
	and #1
	beq rsbi1
	lda seri1
	sec
	sbc seri2
	cmp #$c0
	bcc rsbi1
.if !mike
	lda acia+2
	and #$f3
	ora #$04
	sta acia+2
.else
	lda serts
	and #ff-rtsb
	sta serts
.endif
rsbi1	pla
	clc
	rts
rsbie	ora #$08
	sta serst
	lda #0
	rts

;f49e
;-------- close
	*=$f2af
	jsr rsreset

	*=$f2c5
	jmp rs3

;-------- chkin
	*=$f227
	jmp rschkin

;-------- chkout
	*=$f26c
	jmp rsckout

;-------- bsout
	*=$f014
	nop
	nop
	nop
rsbsout	ldy sero2
	iny
	cpy sero1
	beq rsbsout
	sty sero2
	dey
	lda $9e
	sta ($f9),y
crts	clc
	rts

;-------- irq
rsir1	tax
	lda serst
	and #$0c
	sta serst
	txa
	and #$63
	ora serst
	sta serst
;----
	txa
	and #%00001000
	beq si3
	lda acia
	ldy seri2
	sta ($f7),y
	iny
	lda serst
	cpy seri1
	bne si2
	ora #4
	sta serst
si2	sty seri2
;----
	lda $0294
	and #1
	beq si3
	lda seri1
	sec
	sbc seri2;=frei
	cmp #$40
	bcs si3; mehr als 1/4
.if !mike
	lda acia+2
	and #$f3
	sta acia+2
.else
	lda serts
	ora #rtsb
	sta serts
.endif
;----
si3	txa
	and #%00010000
	beq si6
	ldy sero1
	cpy sero2
	beq si6
	lda ($f9),y
	jmp sii
;----
	jmp rsbasin ;(	*=f086)
sii	sta acia
	iny
	sty sero1
;----
si6	lda acia+1
	rts
;----
rsirq	lda acia+1
	bpl rsir2
	jsr rsir1
	jmp $ea81
rsir2	jmp rsir3
	nop
	nop
	rts; f0a4
rsir3	jsr $ffea
	jmp blirq

;$ea34
;-------- chkin/ckout
rschkin	sta $99
	clc
	rts
rsckout	sta $9a
	clc
	rts

;f0bd
;--------------------------------
;-------- nmiout adrs
	*=$ed0e
	nop
	nop
	nop

	*=$f88a
	nop
	nop
	nop
;-------- nmi-einsprung loeschen
	*=$fe54
	nop
	nop

	*=$fe72
	jmp $feb6

;-------- irq setzen
	*=$ea31
	jmp rsirq

;********************************
;-------------------------------
	*=$e1e6
	jsr lsp; load/save im dir

	*=$e1d9
	ldx #8
	ldy #1
	jsr lsd

	*=$e5e7
	jsr key; f-tasten

	*=$ece7 ; shift run/stop
	.byt 'L','O'+$80,34,'*'

	*=$e44b
	.word neubef ;basic-

	*=$e451
	.word getaus ;vektoren

	*=$ec78
	.byt $84 ;ctrl inst

	*=$ecab
	.byt $82 ;ctrl home

	*=$ec7a
	.byt $81 ;ctrl crsr right

;--------------------------------
	*=$eebb
lsd	jsr $ffba
tstba	lda flag
	bpl lsp1
	and #15
	sta $ba
	rts
lsp	jsr $0079
	cmp #','
	beq lsp1
	pla
	pla
	jmp $a8f8
lsp1	rts
key	jsr $e5b4
	bit $9d
	bpl lsp1
	bit flag
	bpl lsp1
	cmp #3
	bne key2
clr	ldx #0
	stx $c7
	stx $d4
	stx $d8
	beq lsp1
key2	cmp #$81
	bcc lsp1
	bne key3
	ldy $d5
	iny
kl1	dey
	bmi kl2
	lda ($d1),y
	cmp #' '
	beq kl1
kl2	sty $d3
	cpy $d5
	beq k3c
	inc $d3
	bne k3c
key3	cmp #$82
	bne key4
	ldx #24
	ldy #0
	clc
	jsr $fff0
k3c	jsr clr
	jmp k3
key4	cmp #$84
	bne key5
	lda #' '
	ldy $d3
k4	cpy $d5
	beq k5
	bcs k3c
k5	sta ($d1),y
	iny
	bne k4
key5	cmp #140
	beq k8
	bcs lsp1
	cmp #137
	beq lsp1
	cmp #133
	bcc lsp1
	sbc #133
	tay
	ldx key1,y
	ldy #1
k1	lda kt,x
	beq k2
ktx	sta $0276,y
	iny
	inx
	bne k1
k8	lda #'@'
	sta $0277
	lda flag
	and #15
	eor #1
	ora #'0'
	sta $0278
	lda #13
	sta $0279
	ldy #3
k2	sty $c6
k3	pla
	pla
	jmp $e5cd

key1	.byt 0, kt3-kt, kt5-kt, kt7-kt
	.byt <-1, kt4-kt, kt6-kt
kt	.byt "list"
	.byt 13,0
kt3	.byt "run:"
	.byt 13,0
kt5	.byt "load"
	.byt 13,0
kt7	.byt ">$0"
	.byt 13,0
kt4	.byt "_"
	.byt 13,0
kt6	.byt "save"
	.byt 0

getaus	bit flag
	bmi getok
	jmp $ae86
getok	lda #0
	sta $0d
	jsr $0073
	cmp #'$'
	beq gta1
	cmp #'%'
	beq gta2
	jsr $0079
	jmp $ae8d
gta2	lda #0
	sta $63
	sta $62
gta2a	jsr $0073
	bcs gtae
	cmp #'2'
	bcs gtaerr
	lsr
	rol $63
	rol $62
	bcc gta2a
gtaerr	jmp $b248 ; ill. quantity
gta1	lda #0
	sta $62
gta1a	sta $63
	jsr $0073
	sec
	sbc #'0'
	bcc gtae
	cmp #10
	bcc gta1o
	sbc #'A'-'9'-1
	cmp #10
	bcc gtae
	cmp #16
	bcs gtaerr
gta1o	pha
	ldy #4
gta3	asl $63
	rol $62
	bcs gtaerr
	dey
	bne gta3
	pla
	ora $63
	jmp gta1a
gtae	ldx #$90
	sec
	jsr $bc49
	jmp $0079
;f014
;--------------------------------
;--------------------------------
	*=$fe75
nb1f	lda #0
	sta $90
	lda $ba
	jsr $ffb1
	lda $0201
	cmp #'$'
	bne nb1c
	lda #$f0
	.byt $2c
nb1c	lda #$ff
	jsr $ff93
	lda $90
	bmi nba1e
	ldy #0
nba1a	lda $0201,y
	beq nb1e
	jsr $ffa8
	iny
	bne nba1a
nb1e	jsr $ffae
	lda $90
	bne nba1e
	lda $ba
	jsr $ffb4
	lda $0201
	cmp #'$'
	jmp nb1g
;ffb6
;--------------------------------
	*=$fec2
nb1g	beq nb1d
	lda #$ff
	jsr $ff96
nb1b	jsr $ffa5
	jsr $e716
	lda $90
	beq nb1b
nbde	jsr $ffab
nba1e	pla
	pla
	jmp $e386
nb1d	lda #$f0
	jsr $ff96
	jsr $ffa5
	jsr $ffa5
nbdl	jsr $ffa5
	jsr $ffa5
	ldx $90
	bne edl3
	jsr $ffa5
	tax
	jsr $ffa5
	jsr $bdcd
edl1	jsr $ffa5
	ldx $90
	bne edl2
	jsr $e716
	cmp #0
	bne edl1
edl2	lda #13
	jsr $e716
	jsr $ffe4
	bne edl3
	lda $90
	beq nbdl
edl3	jsr $ffab
	lda $ba
	jsr $ffb1
	lda #$e0
	jsr $ff93
	jsr $ffae
	jmp nba1e
	sta acia+1
	jmp $ff6e
;ff48
;******** kassette loeschen *****
	*=$f5f8
	bcc $f5f1 ; save

	*=$f4b6
	bcc $f4af ; load

	*=$f38b
	jmp $f713 ; open

	*=$f2c8
	jmp $f713 ; close

	*=$f26f
	jmp $f713 ; ckout

	*=$f225
	bne $f26f ; chkin

	*=$f1e5
	sec
	bcs $f1fd ; bsout

	*=$f179
	sec
	rts   ; basin

;******* paralleler iec-bus *****
z1 =$94
z2 =$95
z4 =$a3
z3 =$0285
b1 =$fe1c
b2 =$dc07
b3 =$dc0d
b4 =$dc0f
b5 =tpi
b6 =tpi+1
b7 =tpi+3
b8 =tpi+4
c1 =b5
c2 =tpi+2
c3 =tpi+3
c4 =b8
c5 =tpi+5
	*=$fdab
	jsr nini

	*=$fd50
	jmp nmini

	*=$ed0e
	jmp ntalk; und listen

	*=$edbb
	jmp nsecl

	*=$edc9
	jmp nsect

	*=$eddd
	jmp nout
	nop

	*=$edf0
	jmp nut

	*=$ee00
	jmp nul

	*=$ee13
	jmp nin

	*=$f281
	jsr natnhi

	*=$f72c
nini	sta $dc00
iecini
.if mike
	lda #%00011100
	sta c5
	lda #0
	sta c2
.endif
	lda c2
	and #239
	sta c2
	ldy #0
	sty c4
	lda #58
	sta c1
	lda #63
	sta c3
	lda c2
	and #254
	sta c2
	ldy #255
l0	dey
	nop
	bne l0
	lda c2
	ora #1
	sta c2
	lda #57
	sta c1
	jmp $fdae
	;rts
;*****
iectalk	ora #64
	.byt $2c
ieclisten
	ora #32
iectl
l1	pha
	lda #59
	sta b7
	lda #255
	sta b6
	sta b8
	lda #250
	sta b5
	lda z1
	bpl l2
	lda b5
	and #223
	sta b5
	lda z2
	jsr l7
	lda z1
	and #127
	sta z1
	lda b5
	ora #32
	sta b5
l2	lda b5
	and #247
	sta b5
	pla
	jmp l7
seclisten
	jsr l7
l3	lda b5
	ora #8
	sta b5
	rts
sectalk	jsr l7
l4	lda #61
	and b5
	sta b5
	lda #195
	sta b7
	lda #0
	sta b8
	beq l3
iecout	pha
	lda z1
	bpl l5
	lda z2
	jsr l7
	lda z1
l5	ora #128
	sta z1
	pla
	sta z2
	clc
	rts
untalk	lda #95
	bne l6
unlisten
	lda #63
l6	jsr l1
	jsr l4
	lda #253
	ora b5
	sta b5
	cli
	rts
l7	eor #255
	sta b6
	lda b5
	ora #18
	sta b5
	bit b5
	bvc l8
	bpl l8
	lda #128
	jsr b1
	bne l12
l8	lda b5
	bpl l8
	and #239
	sta b5
l9	jsr l18
l10	bit b5
	bvs l11
	lda b3
	and #2
	beq l10
	lda z3
	bmi l9
	lda #1
	jsr b1
l11	lda b5
	ora #16
	sta b5
l12	lda #255
	sta b6
	rts
iecin	lda b5
	and #189
	ora #129
	sta b5
l13	jsr l18
l14	lda b5
	and #16
	beq l15
	lda b3
	and #2
	beq l14
	lda z3
	bmi l13
	lda #2
	jsr b1
	lda b5
	and #61
	sta b5
	lda #13
	clc
	rts
l15	lda b5
	and #127
	sta b5
	and #32
	bne l16
	lda #64
	jsr b1
l16	lda b6
	eor #255
	pha
	lda b5
	ora #64
	sta b5
l17	lda b5
	and #16
	beq l17
	lda b5
	and #191
	sta b5
	pla
	clc
	rts
l18	lda #255
	sta b2
	lda #17
	sta b4
	lda b3
	rts
;**** einbindung
ntalk	jsr setdev
	bit map
	bpl otl
	jmp iectl
otl	jsr $f0a4
	jmp $ed11
nsecl	bit map
	bpl osl
	jmp seclisten
osl	jsr $ed36
	jmp $edbe
nsect	bit map
	bpl ost
	jmp sectalk
ost	jsr $ed36
	jmp $edcc
nout	bit map
	bpl oout
	jmp iecout
oout	bit $94
	bmi oout1
	jmp $ede1
oout1	jmp $ede6
nut	bit map
	bpl out
	jmp untalk
out	jsr $ee8e
	jmp $edf3
nul	bit map
	bpl oul
	jmp unlisten
oul	jsr $ed11
	jmp $ee03
nin	bit map
	bpl oin
	jmp iecin
oin	sei
	lda #0
	jmp $ee16
setdev	pha
	sty z4
	and #15
	sec
	sbc #4
	bcc piec
	cmp #7
	bcs siec1;piec
	tay
	lda pot2,y
	ldy z4
	lsr z4
	and map
	beq piec
siec1	lda map
	and #127
siec	sta map
	pla
	rts
piec	lda map
	ora #128
	bne siec

pot2	.byt 1,2,4,8,$10,$20,$40

nmini	lda #0
	tay
	jsr $fd53
.if mike
	lda #%10000001
.else
	lda #%10000000
.endif
	sta map
	lda #128
	sta 650
freset	lda #8+128
	sta flag
	lda #180
	sta blnk2
	sta blnkt
.if mike
	lda #50
.else
	lda #0
.endif
	sta blnk1
	rts

natnhi	bit map
	bpl oah
	jmp l3
oah	jmp $edbe
;***** was nicht mit kassete geht
neubef	bit flag
	bpl neuend
	jsr tstba
	lda $0200
	cmp #'@'
	beq nba1
	cmp #'>'
	beq nba1
	cmp #'!'
	beq nba2
	cmp #'_'
	beq sysoff
neuend	jmp $a57c
nba2	lda #1
	tay
	sta ($2b),y
	jsr $a533
	lda $22
	clc
	adc #2
	sta $2d
	lda $23
	adc #0
	sta $2e
	jsr $a663
	jmp $e386
nba1	jsr $0073
	bcc nbz1
	jmp nb1f
nbz1	jsr $b79e
	txa
	and #15
	ora #128
	.byt $2c
sysoff	lda #0
nba1ex	sta flag
	jmp nba1e

;*******************************
;***** scroll-halt
	pcx1=*
	*=$e940
	eor #%00100100
	and #%00100100
	beq $e956
	jmp pcx1
	nop
	nop

	*=pcx1
	cmp #%00000100
	beq s1;ctrl langsam
	cmp #%00100000
	bne s2;ctrl/cbm stop
	;jsr testhcopy;nur cbm
s0	jmp $e938
s1	jmp $e94b
s2	lda $dc01
	cmp #$ff
	bne s2
s3	lda $dc01
	and #$20
	bne s3
	beq s0

;********************************
.if 0
	testhcopy lda #$7f
	sta $dc00
	hc1 lda $dc01
	cmp $dc01
	bne hc1
	and #%00100010
	beq hcopy
	clc
	rts
.endif
;********************************

	lb0 =$b0
	lb1 =lb0+1
	l028e =$028e
	hcdev =4
	hcsec =7
hcopy	;inc 53280
	lda #$20
	bit $d011; test hires
	bne lc1aa
	lda l028e
	bmi lc1aa
	lda #$80
	sta l028e
	lda $dd00; adresse berechnen
	lsr
	lda $d018
	and #$70
	ror
	tax
	lda $dd00
	lsr
	lsr
	txa
	ror
	eor #$c0
	sta lb1; hibyte
	lda #$00
	sta lb0
	lda #hcdev
	jsr $ed0c; listen
	lda #$60+hcsec; seclisten
	jsr $edb9
	lda #13
	jsr $eddd
	ldx #25
lc1e0	ldy #$00
lc1e2	lda (lb0),y
	and #$7f
	cmp #$40
	bcc lc1f2
	cmp #$60
	bcc lc1f0
	eor #$40
lc1f0	eor #$80
lc1f2	cmp #$20
	bcs lc1f8
	eor #$40
lc1f8	jsr $eddd
	iny
	cpy #$28
	bcc lc1e2
	lda #$0d
	jsr $eddd
	tya
	clc
	adc lb0
	sta lb0
	bcc lc22a
	inc lb1
lc22a	dex
	bne lc1e0
	jsr $edfe; unlisten
	jsr $edfe
	lda #$00
	sta l028e
lc1aa	sec
	rts

;*******************************
	pcx2=*
	*=$eb76
	jmp hc2

	*=pcx2
hc2	cpx #4
	bne hce
	lda $cb
	cmp #$39
	bne hce
	bit $c6
	bpl hc
hce	jmp $eae0
hc	lda #<-1
	sta $c6
	jsr hcopy
	lda #0
	sta $c6
	jmp $eb42
;*******************************

blirq	ldx blnk1
	beq blxx
	ldx $d011
	txa
	and #%11101111
	ldy blnk2
	cpy #255
	beq blank
	txa
	and #%00010000
	bne blxx
	txa
	ldx bc
	ora #%00010000
	.byt $2c
blank	ldx #0
	sta $d011
	stx 53280
blxx	jmp $ea34

;*******************************
	pcx3=*
	*=$ea98
	jmp blnk

	*=pcx3
blnk	beq notpr
	tay
	lda blnkt
	sta blnk2
	jmp $ea9b
notpr	lda blnk1
	beq ble
	dec blnk1
	bne ble
	lda #50
	sta blnk1
	lda blnk2
	cmp #255
	beq ble
	dec blnk2
ble	jmp $eb26

	pcx4=*
	*=$e716
	jmp bls

	*=pcx4
bls	pha
	sta $d7
	lda blnkt
	sta blnk2
	jmp $e719
;******** leere bereiche loeschen
;fcd1
;*******************************
