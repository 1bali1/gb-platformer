INCLUDE "include/hardware.inc"
INCLUDE "src/graphics.asm"

DEF V_TITLE_START EQU 0x9000

SECTION "Header", ROM0[0x100]
    jp EntryPoint

    ds $150 - @, 0

EntryPoint:
    xor a
    ld [rNR52], a

FirstVBlank:
    ld a, [rLY]
    cp 144
    jr c, FirstVBlank

    xor a
    ld [rLCDC], a

    ; Load ascii letters to vram
    ld de, ASCII
    ld hl, V_TITLE_START
    ld bc, ASCII.End - ASCII

    call CopySpaceTo

    ; Write to screen
    ld de, T_Title
    ld b, 2
    ld c, 3

    call WriteTitleToScreen
 
    ld a, LCDC_ON | LCDC_BG_ON
    ld [rLCDC], a

    ld a, 0b11100100
    ld [rBGP], a
    ld [rOBP0], a

Main:
    halt

    jr Main

; @param de: text start
; @param b: x coord
; @param c: y coord
WriteTitleToScreen:
    ld hl, TILEMAP0

    add a, b
    ld l, a

    ld b, 0
    ld a, c

    ; 5 times
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b

    add hl, bc

.doTitleWrite
    ld a, [de]
    or a

    ret z

    inc de

    bit 7, a
    jr z, .notSpace

    xor a

.notSpace:
    sub 64

    ld [hl+], a

    jr .doTitleWrite

; @param de: source
; @param hl: dest
; @param bc: length
CopySpaceTo:
    ld a, [de]
    ld [hl+], a

    inc de
    dec bc

    ld a, b
    or c

    jr nz, CopySpaceTo

    ret

SECTION "Player data", WRAM0
score: db

SECTION "Text data", ROM0
T_Title:
    db "ABBA BABA BAB", 0