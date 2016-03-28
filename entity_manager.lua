--this creates the entity manager "class"
--the entity manager class creates entity managers, each with their own entities

do
    --meta table with the sared data
    local mt = {}
    compBaseClass = dofile("component_type")

    mt.__index = {
        
    }

    mt.__index.componentTypes = {}

    local em = {}
    em.mt = mt

    function em:new()
        local manager = {}
        manager.entityIds = {}

        --components matches component type -> a table of components of that type
        --each component table matches entity id -> component
        manager.components = {}
        setmetatable(manager, self.mt)

        return manager
    end

    return em
end
