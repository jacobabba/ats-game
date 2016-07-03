-----------------------------------------------------------------
-- editor/tile_types.lua
-- Contains the tile structure with all of the possible tiles
-- Author: Jacob Abba
-----------------------------------------------------------------

do
    local _t = {}

    _t[0] = {
        name = "Blank",
        hasBox = false
    }

    _t[1] = {
        name = "White Tile",
        color = {255, 255, 255},
        hasBox = true
    }

    _t[2] = {
        name = "Red Tile",
        color = {247, 39, 39},
        hasBox = true
    }

    return _t
end
