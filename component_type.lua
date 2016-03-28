--this creates the component "base class"
--the base class creates sub classes, which in turn create component objects

do
    local compBaseClass = {}

    compBaseClass.mt = {
        __newindex = function ()
            error("Attempt to modify a non-existant component value")
        end
    }

    --creates a new component sub class, with a table that has default values
    --must contain default values for all possible fields
    function compBaseClass:newCompSubClass(d)
        local compSubClass = {default = d}
        local cc = self
        
        --creates a new component object of the sub class, with the default parameters
        function compSubClass:newComponent()
            local component = {}
            for k,v in pairs(cc.default) do
                component[k] = v
            end

            setmetatable(newComponent, cc.mt)

            return component
        end

        return compSubClass
    end

    return compBaseClass
end
