INCLUDE "include/hardware.inc"
INCLUDE "src/graphics/ascii.asm"
INCLUDE "src/graphics/other.asm"
INCLUDE "src/graphics/tilemaps.asm"
INCLUDE "src/game/select.asm"

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

    ld de, Tiles
    ld hl, V_TITLE_START + (ASCII.End - ASCII)
    ld bc, TilesEnd - Tiles

    call CopySpaceTo

    ; Load bg tilemap
    ld de, MainTitle
    ld hl, TILEMAP0
    ld bc, MainTitle.End - MainTitle

    call CopySpaceTo

    ; Write to screen
    ld de, T_Title
    ld b, 5
    ld c, 3

    call WriteTitleToScreen
    
    call InitalizeLcdc

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
    jr z, .gameTitleSceneVBlank

    cp a, STATE_SELECT_LEVEL
    call z, SelectGameLevelVBlank

    jr Main

.gameTitleSceneVBlank:
    ; vlbank

    ld b, 2
    ld c, 12
    ld de, T_PressAnyButton

    call BlinkText

    jr Main

InitalizeSelectLevel:
    ld a, STATE_SELECT_LEVEL
    ld [wGameState], a

    ld a, LCDC_OFF
    ld [rLCDC], a

    ld de, SelectLevel
    ld hl, TILEMAP0
    ld bc, SelectLevel.End - SelectLevel

    call CopySpaceTo

    call InitalizeLcdc

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

    cp a, 0x0a
    jr z, .writeNewLine

    sub 64
    bit 7, a

    jr z, .notSpace

    xor a

.notSpace:
    ld [hl+], a

    jr .doTitleWrite

; @do hl: tilemap address
.writeNewLine:
    ld a, 1
    add c
    ld c, a

    call CalculateTilemapCoords

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
    push bc

    ld hl, TILEMAP0

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

    pop bc

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

; Turns on LCDC with the flags: LCDC_ON | LCDC_BG_ON | LCDC_WIN_ON
InitalizeLcdc:
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_ON
    ld [rLCDC], a
    
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

    call z, InitalizeSelectLevel

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

wSelectedGameMode:
    db

SECTION "Text data", ROM0
T_Title:
    db "THE\nPLATFORMER", 0

T_PressAnyButton:
    db "PRESS ANY BUTTON", 0

T_Placeholder:
    db "PLACEHOLDER", 0