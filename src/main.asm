INCLUDE "include/hardware.inc"
INCLUDE "src/graphics.asm"

DEF BLANK_TILE EQU 0x00
DEF LEFT_BRICK EQU 0x01
DEF RIGHT_BRICK EQU 0x02

SECTION "Header", ROM0[0x100]
    jp EntryPoint

    ds $134 - @, 0

    db "PLATFORMER"

EntryPoint:
    xor a
    ld [rNR52], a

SECTION "Player data", WRAM0
score: db