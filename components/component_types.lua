--this file returns all of the component type classes
--matches {type (string) -> sub class}

do
    local types = {}
    local componentClass = dofile("components/component_class.lua")

    --location and size data
    types.transform = componentClass:newSubClass{
        xPosition = 0,
        yPosition = 0,
        width = 1,
        height = 1
    }

    --all entities that will be drawn to the screen should have 
    --this component and the transform component
    types.drawable = componentClass:newSubClass{
        drawType = "rectangle"
    }

    --data for entities that will move should have this component
    --and the transform component
    types.motion = componentClass:newSubClass{
        xVelocity = 0,
        yVelocity = 0
    }

    --entities that will colllide with the level should have this
    --component, the transform component, and the move component
    types.rigid = componentClass:newSubClass{
        isOnGround = false,
        tilesCollidedWith = {}
    }

    --defines data specific to the player
    types.player = componentClass:newSubClass{
        MAX_HSPEED = 3,
        HACCEL = .3,
        MAX_VSPEED = 8,
        VACCEL_GRAVITY = .3,
        VACCEL_JUMP = 9
    }

    --defines data specific to lines
    --a line should also have the colorState component
    types.line = componentClass:newSubClass{
        --segments maps {id -> {x, y, width, height}}
        --x,y is the levelgrid coords of the upper left most part of this segment
        --width is the number of grid spaces the segment spans to the right
        --height is the number of grid spaces the segment spans downwards
        --only one of the previous two fields (width,height) should exist in each segment
        --behavior for negative values of width,height are undefined
        segments = nil,

        --links establishes a link between this line and lines on other levels,
        --essentially this is used to create lines that span multiple levels
        --maps {id -> {levelx, levely, uid}}
        links = {}
    }

    --defines the "color state" of an entity
    types.colorState = componentClass:newSubClass{
        state = "white"
    }

    return types
end
