MACRO TILEMAP_ROW
    DEF count = _NARG

    REPT count
        db (((V_TITLE_START + (ASCII.End - ASCII)) + (\1 - Tiles)) - V_TITLE_START) / 16
        
        SHIFT
    ENDR

    REPT 32 - count
        db 0
    ENDR
ENDM