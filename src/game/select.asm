; TODO: Refactor BlinkSelectedLevel func, create an internal clock timer
InitalizeSelectLevel:
    xor a
    ld [wSelectedLevel], a

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

SelectGameLevelVBlank:
    ; vblank

    call BlinkSelectedLevel

    ret

BlinkSelectedLevel:
    ld a, [wSelectedLevelTimer]
    inc a
    ld [wSelectedLevelTimer], a

    cp a, 1
    jr z, .blink

    cp a, 30
    jr z, .blink

    cp a, 60
    ret c

    xor a

    ld [wSelectedLevelTimer], a

    ret

.blink:
    ld b, 3
    ld c, 1
    call CalculateTilemapCoords

    ld a, [wSelectedLevelTimer]
    cp a, 30
    jr z, .showElement

    xor a
    jr .load

.showElement:
    ld a, [wSelectedLevel]
    inc a

.load:
    ld [hl], a

    ret

SECTION "SelectMenuVariables", WRAM0
wSelectedLevel: db
wSelectedLevelTimer: db