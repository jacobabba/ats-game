-----------------------------------------------------------------
-- editor/tile_types.lua
-- Contains the tile structure with all of the possible tiles
-- Author: Jacob Abba
-----------------------------------------------------------------

do
    local _t = {}

    --isTile specifies whether the whole tile is filled
    --isLIne specifies whether there's a line through that tile

    _t[0] = {
        name = "Blank",
        tileColorR = 0,
        tileColorG = 0,
        tileColorB = 0,
        isLine = false,
        isTile = true
    }

    _t[1] = {
        name = "Regular Tile",
        tileColorR = 255,
        tileColorG = 255,
        tileColorB = 255,
        isLine = false,
        isTile = true
    }

    return _t
end
