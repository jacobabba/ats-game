--this file returns all of the component type classes
--matches {type (string) -> sub class}

do
    local types = {}
    local componentClass = require("component_class")

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
        colorR = 255,
        colorG = 255,
        colorB = 255,
        drawType = "rectangle"
    }

    --data for entities that will move should have this component
    --and the transform component
    types.motion = componentClass:newSubClass{
        xVelocity = 0,
        yVelocity = 0,
        xVelocityCap = 0,
        yVelocityCap = 0,
        xAcceleration = 0,
        yAcceleration = 0
    }

    --entities that will colllide with the level should have this
    --component, the transform component, and the move component
    types.rigid = componentClass:newSubClass{

    }

    --defines actions to be done on different types of keypresses
    types.input = componentClass:newSubClass{
        up = "do_up",
        down = "do_down",
        left = "do_left",
        right = "do_right",
        jump = "do_jump"
    }

    types.player{
        state = "white"
    }

    types.line{
        state = "white"
    }

    return types
end
