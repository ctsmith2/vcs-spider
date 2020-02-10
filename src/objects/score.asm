;======================
; Score (playfield)
;======================

; Constants

SCORE_BG_COLOR      = #$00
SCORE_LABEL_COLOR   = #$0f
SCORE_LEVEL_COLOR   = #$44
SCORE_HEALTH_COLOR  = #$C8

SCORE_LABEL_SIZE    = 5
SCORE_DIGIT_SIZE    = 5
SCORE_LINE_SIZE     = 2
SCORE_LINES         = SCORE_LABEL_SIZE+1+SCORE_DIGIT_SIZE*SCORE_LINE_SIZE+3

; Initialization

ScoreInit:

    ; Health Score
    lda #$ff
    sta ScoreValue+0

    ; Game Score
    lda #0
    sta ScoreValue+1

    rts

; Frame Update

ScoreUpdate:

    ; Current Level Digits
    lda LevelCurrent
    clc
    adc #1

    jsr BinBcdConvert

    ; Only use first byte
    txa
    and #$0f
    tay
    txa
    and #$f0
    REPEAT 4
    lsr
    REPEND
    tax

    ; Adjust index positions by multiplying by 5
    txa
    sta Temp
    asl
    asl
    adc Temp
    sta ScoreDigitTens

    tya
    sta Temp
    asl
    asl
    adc Temp
    sta ScoreDigitOnes

    ; Score Digits
    lda ScoreValue+1

    jsr BinBcdConvert

    ; Only use first byte
    txa
    and #$0f
    tay
    txa
    and #$f0
    REPEAT 4
    lsr
    REPEND
    tax

    ; Adjust index positions by multiplying by 5
    txa
    sta Temp
    asl
    asl
    adc Temp
    sta ScoreDigitTens+1

    tya
    sta Temp
    asl
    asl
    adc Temp
    sta ScoreDigitOnes+1

    ; Health Bar
    lda ScoreValue+0
    beq .score_update_bar_empty

    REPEAT 4
    lsr
    REPEND
    cmp #8
    bcs .score_update_bar_top

.score_update_bar_bottom:
    tax
    lda ScoreBar,x
    ldy #$00
    jmp .score_update_bar_store

.score_update_bar_top:
    and #%00000111
    tax
    lda #$ff
    ldy ScoreBarFlip,x
    jmp .score_update_bar_store

.score_update_bar_empty:
    lda #0
    ldy #0

.score_update_bar_store:
    sta ScoreBarGfx+0
    sty ScoreBarGfx+1

.score_update_end:
    rts

; Draw loop (uses SCORE_LINES scanlines)

ScoreDraw:

    ; Load Colors
    lda #SCORE_BG_COLOR
    sta COLUBK
    lda #SCORE_LABEL_COLOR
    sta COLUPF
    sta COLUP0
    sta COLUP1

    ; Set Non-Mirror
    lda CtrlPf
    and #%11111100
    ora #%00000010
    sta CtrlPf
    sta CTRLPF

    ldx #0
.score_draw_label:

    sta WSYNC

    ; First half of image
    ;lda ScoreLabel+0,x ; 4
    ;sta PF0 ; 3
    lda ScoreLabel+1,x
    sta PF1
    lda ScoreLabel+2,x
    sta PF2

    sleep 20

    ; Second half of image
    ;lda ScoreLabel+3,x
    ;sta PF0
    lda ScoreLabel+4,x
    sta PF1
    lda ScoreLabel+5,x
    sta PF2

    txa
    clc
    adc #KERNEL_IMAGE_FULL_DATA
    tax
    cpx #KERNEL_IMAGE_FULL_DATA*SCORE_LABEL_SIZE
    bne .score_draw_label

    ; Clear labels and setup color
    lda #0
    sta PF0
    sta PF1
    sta PF2

    sta WSYNC

    lda #SCORE_LEVEL_COLOR
    sta COLUPF
    sta COLUP0
    lda #SCORE_HEALTH_COLOR
    sta COLUP1

    sta WSYNC

    ; Prepare initial line

    ; Level
    ldy ScoreDigitTens
    lda ScoreDigits,y
    and #$f0
    sta ScoreDigitGfx

    ldy ScoreDigitOnes
    lda ScoreDigits,y
    and #$0f
    ora ScoreDigitGfx
    sta ScoreDigitGfx

    ; Score
    ldy ScoreDigitTens+1
    lda ScoreDigitsFlip,y
    and #$0f
    sta ScoreDigitGfx+1

    ldy ScoreDigitOnes+1
    lda ScoreDigitsFlip,y
    and #$f0
    ora ScoreDigitGfx+1
    sta ScoreDigitGfx+1

    ldx #SCORE_DIGIT_SIZE
.score_draw_digit:

    sta WSYNC

    lda ScoreDigitGfx
    sta PF1
    lda ScoreDigitGfx+1
    sta PF2

    ; Begin preparing next line
    inc ScoreDigitOnes
    inc ScoreDigitTens
    inc ScoreDigitOnes+1
    inc ScoreDigitTens+1

    ; Level 1st Digit
    ldy ScoreDigitTens
    lda ScoreDigits,y
    and #$f0
    sta Temp

    lda ScoreBarGfx+0
    sta PF1
    lda ScoreBarGfx+1
    sta PF2

    ; Score 1st Digit
    ldy ScoreDigitTens+1
    lda ScoreDigitsFlip,y
    and #$0f
    sta Temp+1

    sta WSYNC
    lda ScoreDigitGfx
    sta PF1
    lda ScoreDigitGfx+1
    sta PF2

    ; Level 2nd Digit (and transfer)
    ldy ScoreDigitOnes
    lda ScoreDigits,y
    and #$0f
    ora Temp
    sta ScoreDigitGfx

    ; Score 2nd Digit (and transfer)
    ldy ScoreDigitOnes+1
    lda ScoreDigitsFlip,y
    and #$f0
    ora Temp+1
    sta ScoreDigitGfx+1

    lda ScoreBarGfx+0
    sta PF1
    ldy ScoreBarGfx+1
    sty PF2

    dex
    bne .score_draw_digit

    lda #0
    sta WSYNC
    sta PF1
    sta PF2

    rts

ScoreBar:
    .BYTE #%10000000
    .BYTE #%11000000
    .BYTE #%11100000
    .BYTE #%11110000
    .BYTE #%11111000
    .BYTE #%11111100
    .BYTE #%11111110
    .BYTE #%11111111

ScoreBarFlip:
    .BYTE #%00000001
    .BYTE #%00000011
    .BYTE #%00000111
    .BYTE #%00001111
    .BYTE #%00011111
    .BYTE #%00111111
    .BYTE #%01111111
    .BYTE #%01111111

    include "objects/score_digits.asm"
    include "objects/score_label.asm"
;    include "objects/score_level.asm"
;    include "objects/score_health.asm"
