--this creates the component "base class"
--the base class creates sub classes, which in turn create component objects

do
    local compBaseClass = {}

    --creates a new component sub class, with a table that has default values
    --must contain default values for all possible fields, even if they are set to 0
    function compBaseClass:newSubClass(d)
        local compSubClass = {}
        local default = d
        
        --creates a new component object of the sub class, with the default parameters
        --vals is an optional table to initialize parameters
        function compSubClass:newComponent(vals)
            local component = {}

            --recursive function used in case of nested tables
            local function copyDefaults(source, destination)
                for k,v in pairs(source) do
                    if type(v) ~= "table" then
                        destination[k] = v
                    else
                        destination[k] = {}
                        copyDefaults(v, destination[k])
                    end
                end
            end
            
            copyDefaults(default, component)

            if vals then
                for k,v in pairs(vals) do
                    component[k] = v
                end
            end

            return component
        end

        return compSubClass
    end

    return compBaseClass
end
