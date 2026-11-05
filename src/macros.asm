MACRO ASCII_M
    db (\1 - ASCII) / 16
ENDM

MACRO GAME
    db ((ASCII_End - ASCII) / 16) + ((\1 - Tiles) / 16)
ENDM

MACRO TILEMAP_ROW
    DEF count = _NARG

    REPT count
        \1
        SHIFT
    ENDR

    REPT 32 - count
        db 0
    ENDR
ENDM