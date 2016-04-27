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
        hasBox = false
    }

    _t[1] = {
        name = "Regular Tile",
        color = {255, 255, 255},
        hasBox = true
    }

    _t[2] = {
        name = "Death Tile",
        color = {247, 39, 39},
        hasBox = true
    }

    return _t
end
