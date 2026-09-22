SelectGameLevelVBlank:
    ; vblank

    ld b, 2
    ld c, 12
    ld de, T_Placeholder

    call BlinkText

    call DrawLevelIcons

    ret

; Draws all level icon
DrawLevelIcons:
    ret