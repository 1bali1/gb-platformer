INCLUDE "include/hardware.inc"
INCLUDE "src/graphics.asm"

DEF V_TITLE_START EQU 0x9000
DEF STATE_TITLE EQU 0x00
DEF STATE_SELECT_LEVEL EQU 0x01

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

    ; Load bg tilemap
    ld de, MainTitle
    ld hl, TILEMAP0
    ld bc, MainTitle.End - MainTitle

    call CopySpaceTo

    ; Write to screen
    ld de, T_Title
    ld b, 4
    ld c, 3

    call WriteTitleToScreen

    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_ON | LCDC_BG_MAP
    ld [rLCDC], a

    ld a, 0b11100100
    ld [rBGP], a
    ld [rOBP0], a

    ld a, IF_JOYPAD | IF_VBLANK
    ld [rIE], a

    ei

Main:
    ; main

    ld hl, wVBlankFlag
    xor a


.VBlank:
    halt

    nop

    cp a, [hl]
    jr z, .VBlank
    ld [hl], a

    ld a, [wGameState]

    cp a, STATE_TITLE
    jr z, .gameTitleScene

    cp a, STATE_SELECT_LEVEL
    jr z, .selectGameLevel

    jr Main

.gameTitleScene:
    ; vlbank
    ld b, 2
    ld c, 12
    ld de, T_PressAnyButton

    call BlinkText

    jr Main

.selectGameLevel:
    ld b, 2
    ld c, 12
    ld de, T_PressAnyButton

    call ClearTilemapArea

    jr Main

InitalizeGame:
    ld a, 1
    ld [wGameState], a

    ret

; @param b: x coord
; @param c: y coord
; @param de: text start
BlinkText:
    ld a, [wTextBlinkTimer]
    inc a
    ld [wTextBlinkTimer], a

    cp a, 1
    call z, ClearTilemapArea

    cp a, 30
    call z, WriteTitleToScreen

    cp a, 60
    ret c

    xor a
    ld [wTextBlinkTimer], a

    ret

; @param b: x coord
; @param c: y coord
; @param de: text start
WriteTitleToScreen:
    call CalculateTilemapCoords

.doTitleWrite:
    ld a, [de]
    or a

    ret z

    inc de

    sub 64
    bit 7, a

    jr z, .notSpace

    xor a

.notSpace:
    ld [hl+], a

    jr .doTitleWrite

; @param b: x coord
; @param c: y coord
; @param de: text start
ClearTilemapArea:
    push de

    call CalculateTilemapCoords

.clear:
    ld a, [de]
    or a

    jr z, .done

    inc de

    xor a

    ld [hl+], a

    jr .clear

.done:
    pop de

    ret

; @param b: x coord
; @param c: y coord
; @return hl: tilemap address
CalculateTilemapCoords:
    ld hl, TILEMAP1

    ld l, b

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

    ret

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

SECTION "VBlank interrupt service", ROM0[0x040]
    push af
    
    ld a, 1
    ld [wVBlankFlag], a
    
    pop af

    reti

SECTION "Joypad interrupt service", ROM0[0x060]
    push af
    push hl

    ld a, [wGameState]
    cp a, STATE_TITLE

    call z, InitalizeGame

    pop af
    pop hl

    reti


SECTION "Player data", WRAM0
score: db


SECTION "Variables", WRAM0
wVBlankFlag:
    db
    
wTextBlinkTimer:
    db

wGameState:
    db

SECTION "Text data", ROM0
T_Title:
    db "ABCDEFGHMSBML JK", 0

T_PressAnyButton:
    db "BAD CED BBCACB", 0