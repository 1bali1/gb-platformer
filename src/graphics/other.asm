SECTION "GameTiles", ROM0
Tiles:
NoneTile:
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000

FullTile:
    ; full
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111
    dw `11111111

BorderTopTile:
    ; top
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `33333333

BorderBottomTile:
    ; bottom
    dw `33333333
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000
    dw `00000000

BorderLeftTile:
    ; left
    dw `00000003
    dw `00000003
    dw `00000003
    dw `00000003
    dw `00000003
    dw `00000003
    dw `00000003
    dw `00000003

BorderRightTile:
    ; right
    dw `30000000
    dw `30000000
    dw `30000000
    dw `30000000
    dw `30000000
    dw `30000000
    dw `30000000
    dw `30000000

TilesEnd: