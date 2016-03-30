--this file returns all of the component type classes
--matches {type (string) -> sub class}

do
    local types = {}
    local componentClass = dofile("component_class")

    types.transform = componentClass:newSubClass{
        x = 0
        y = 0
        w = 1
        h = 1
    }

    types.drawable = componentClass:newSubClass{
        colorR = 255
        colorG = 255
        colorB = 255
        drawType = "rectangle"
    }

    types.motion = componentClass:newSubClass{
        xVelocity = 0
        yVelocity = 0
        xVelocityCap = 0
        yVelocityCap = 0
        xAcceleration = 0
        yAcceleration = 0
    }

    return types
end
