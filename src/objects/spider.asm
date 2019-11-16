;=================
; Spider (player0)
;=================

; Constants

SPIDER_COLOR        = #$56
SPIDER_SIZE         = 16
SPIDER_SPRITE_SIZE  = 8
SPIDER_VEL_X        = 2
SPIDER_VEL_Y        = 2

; Initialization

SpiderInit:

    ; Initial Control
    lda #50
    sta SpiderPos
    sta SpiderPos+1

    ; Setup Sprite
    SET_POINTER SpiderPtr, SpiderSprite

    rts

; Frame Update

SpiderUpdate:
    jsr SpiderControl
    rts

SpiderControl:

    ; Control Position
    ldx SpiderPos
    ldy SpiderPos+1
    lda SWCHA

.spider_control_check_right:
    bmi .spider_control_check_left

    REPEAT #SPIDER_VEL_X
    inx
    REPEND

.spider_control_check_left:
    rol
    bmi .spider_control_check_down

    REPEAT #SPIDER_VEL_X
    dex
    REPEND

.spider_control_check_down:
    rol
    bmi .spider_control_check_up

    REPEAT #SPIDER_VEL_Y
    dey
    REPEND

.spider_control_check_up:
    rol
    bmi .spider_control_sprite

    REPEAT #SPIDER_VEL_Y
    iny
    REPEND

.spider_control_sprite:
    ; Control Sprite
    lda #%00000000 ; First 2 bits are left or right, second 2 bits are up or down

.spider_control_sprite_x:
    cpx SpiderPos
    bcc .spider_control_sprite_left
    beq .spider_control_sprite_y
    bcs .spider_control_sprite_right

.spider_control_sprite_left:
    ora #%10000000
    jmp .spider_control_sprite_y

.spider_control_sprite_right:
    ora #%01000000

.spider_control_sprite_y:
    cpy SpiderPos+1
    bcc .spider_control_sprite_down
    beq .spider_control_sprite_store
    bcs .spider_control_sprite_up

.spider_control_sprite_down:
    ora #%00010000
    jmp .spider_control_sprite_store

.spider_control_sprite_up:
    ora #%00100000

.spider_control_sprite_store:
    cmp #%00000000
    beq .spider_control_boundary
    sta SpiderCtrl

.spider_control_boundary:
    ; Check Playfield Boundaries

.spider_control_boundary_left:
    cpx #SPIDER_VEL_X+1
    bcs .spider_control_boundary_right
    ldx #SPIDER_VEL_X+1
    jmp .spider_control_boundary_top

.spider_control_boundary_right:
    cpx #(KERNEL_WIDTH/2)-(SPIDER_SIZE*2)-SPIDER_VEL_X
    bcc .spider_control_boundary_top
    ldx #(KERNEL_WIDTH/2)-(SPIDER_SIZE*2)-SPIDER_VEL_X

.spider_control_boundary_top:
    cpy #SPIDER_VEL_X+1
    bcs .spider_control_boundary_bottom
    ldy #SPIDER_VEL_X+1
    jmp .spider_control_store

.spider_control_boundary_bottom:
    cpy #KERNEL_SCANLINES-SCORE_LINES-SPIDER_VEL_Y
    bcc .spider_control_store
    ldy #KERNEL_SCANLINES-SCORE_LINES-SPIDER_VEL_Y

.spider_control_store:
    ; Store new position
    stx SpiderPos
    sty SpiderPos+1

.spider_control_sprite_assign:
    ; Skip if no change
    cmp #%00000000
    beq .spider_control_return

.spider_control_sprite_assign_left:
    cmp #%10000000
    bne .spider_control_sprite_assign_right
    SET_POINTER SpiderPtr, SpiderSprite+#SPIDER_SPRITE_SIZE*6
    jmp .spider_control_return

.spider_control_sprite_assign_right:
    cmp #%01000000
    bne .spider_control_sprite_assign_top
    SET_POINTER SpiderPtr, SpiderSprite+#SPIDER_SPRITE_SIZE*2
    jmp .spider_control_return

.spider_control_sprite_assign_top:
    cmp #%00100000
    bne .spider_control_sprite_assign_bottom
    SET_POINTER SpiderPtr, SpiderSprite+#SPIDER_SPRITE_SIZE*0
    jmp .spider_control_return

.spider_control_sprite_assign_bottom:
    cmp #%00010000
    bne .spider_control_sprite_assign_top_right
    SET_POINTER SpiderPtr, SpiderSprite+#SPIDER_SPRITE_SIZE*4
    jmp .spider_control_return

.spider_control_sprite_assign_top_right:
    cmp #%01100000
    bne .spider_control_sprite_assign_bottom_right
    SET_POINTER SpiderPtr, SpiderSprite+#SPIDER_SPRITE_SIZE*1
    jmp .spider_control_return

.spider_control_sprite_assign_bottom_right:
    cmp #%01010000
    bne .spider_control_sprite_assign_bottom_left
    SET_POINTER SpiderPtr, SpiderSprite+#SPIDER_SPRITE_SIZE*3
    jmp .spider_control_return

.spider_control_sprite_assign_bottom_left:
    cmp #%10010000
    bne .spider_control_sprite_assign_top_left
    SET_POINTER SpiderPtr, SpiderSprite+#SPIDER_SPRITE_SIZE*5
    jmp .spider_control_return

.spider_control_sprite_assign_top_left:
    cmp #%10100000
    bne .spider_control_return
    SET_POINTER SpiderPtr, SpiderSprite+#SPIDER_SPRITE_SIZE*7

.spider_control_return:
    rts

SpiderPosition:

    ; Set Position
    ldx #0                  ; Object (player0)
    lda SpiderPos      ; X Position
    jsr PosObject

    rts

; Scanline Draw

SpiderDrawStart:

    ; Set player 0 to be double size
    ; and missile 0 to be 4 clock size
    lda NuSiz0
    ora #%00000111
    sta NuSiz0
    sta NUSIZ0

    ; Set sprite color
    lda #SPIDER_COLOR
    sta COLUP0

    ; Determine if we need to use vertical delay (odd line)
    lda SpiderPos+1    ; Y Position
    lsr
    bcs .spider_draw_start_nodelay

    ldy #1
    jmp .spider_draw_start_set_delay

.spider_draw_start_nodelay:
    ldy #0

.spider_draw_start_set_delay:
    sty VDELP0

.spider_draw_start_pos:
    ; Calculate starting position
    clc
    adc #SPIDER_SIZE
    sta SpiderDrawPos

    ; Initialize sprite index
    lda #0
    sta SpiderIndex

    rts

SpiderDraw:

    ldy SpiderIndex
    cpy #(SPIDER_SPRITE_SIZE*2)
    beq .spider_draw_blank  ; At end of sprite
    bcs .spider_draw_return ; Completed drawing sprite
    cpy #0
    bne .spider_draw_line

    ; Divide y in half
    txa
    lsr

    sbc SpiderDrawPos
    bpl .spider_draw_return ; Not yet to draw sprite

.spider_draw_line:
    tya
    lsr
    bcs .spider_draw_skip
    tay

    lda (SpiderPtr),y
    sta GRP0

    ; Using this for now until we have another sprite
    lda #0
    sta GRP1

.spider_draw_skip:
    ldy SpiderIndex
    iny
    sty SpiderIndex
    rts                     ; Early return

.spider_draw_blank:
    lda #0
    sta GRP0

    ; Using this for now until we have another sprite
    lda #0
    sta GRP1

    ; Push index to be one above
    iny
    sty SpiderIndex

.spider_draw_return:
    rts

SpiderClean:

    ; Clear out Player0 sprite
    lda #0
    sta GRP0

    rts

    ; Spider Sprites
    include "objects/spider_sprite.asm"
