-----------------------------------------------------------------
-- editor/tile_types.lua
-- Contains the tile structure with all of the possible tiles
-- Author: Jacob Abba
-----------------------------------------------------------------

do
    local _t = {}

    --hasBox specifies whether the whole tile is filled
    --isLIne specifies whether there's a line through that tile

    _t[0] = {
        name = "Blank",
        hasLine = false,
        hasBox = false
    }

    _t[1] = {
        name = "Regular Tile",
        boxColorR = 255,
        boxColorG = 255,
        boxColorB = 255,
        hasLine = false,
        hasBox = true
    }

    _t[12] = {
        name = "Regular Line",
        lineColorR = 255,
        lineColorG = 255,
        lineColorB = 255,
        hasLine = true,
        hasBox = false
    }

    _t[13] = {
        name = "Double Jump Line",
        lineColorR = 128,
        lineColorG = 168,
        lineColorB = 124,
        hasLine = true,
        hasBox = false
    }

    return _t
end
