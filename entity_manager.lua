--this creates the entity manager "class"
--the entity manager class creates entity managers, each with their own entities

do
    --index with shared functions/data
    local index = {}

    --matches component type -> component type base class
    index.componentTypes = dofile("component_types")

    --the components is an optional table which maps 
    --    {component type -> {preliminary values for that component}}
    --uid is an optional unique identifier for this entity, and can be used
    --    to reference this entity from other entities
    function index:addEntity(components, uid)
        --find first unused id
        local id = 0
        for k,v in ipairs(self.entityIds) do id = k end
        id = id + 1
        self.entityIds[id] = true

        if uid then
            if self.uniqueIds[uid] then
                error("Attempt to register a unique entity id that is already in use"..
                      " for this manager")
            end
            
            self.uniqueIds[uid] = id
        end

        if components then
            for k,v in pairs(components) do
                self.components[k][id] = self.componentTypes[k]:newComponent(v)
            end
        end
    end

    function index:removeEntity(id)
        self.entityIds[id] = nil
        for k,v in pairs(self.uniqueIds) do
            if v == id then
                self.uniqueIds[k] = nil
            end
        end

        for k,v in pairs(self.components) do
            v[id] = nil
        end
    end

    --returns a table mapping component type -> component for that entity
    function index:getEntity(uid)
        local id = self.uniqueIds[uid]
        if id == nil then return nil end

        local entity = {}

        for k,v in pairs(self.components) do
            entity[k] = v[id]
        end

        return entity
    end

    --gets all entities that have all requested components
    --signature should be a table containing names of required components
    --return table has structure {entity ids -> {component name -> component}}
    function index:getEntFromSig(signature)
        --entities maps {entity id -> {component type -> component}}
        local entities = {}
        local n = table.getn(signature)
        for k,v in pairs(self.components[signature[n]]) do
            entities[k] = {}
            entities[k][signature[n]] = v
        end
        signature[n] = nil

        for sigk,sigv in ipairs(signature) do
            for entk,entv in pairs(entities) do
                --if this entity has this component, add that component to the entity list
                --otherwise, remove that entity from our list
                if self.components[sigv][entk] then
                    entv[sigv] = self.components[sigv][entk]
                else
                    entv = nil
                end
            end
        end

        return entities
    end
    
    local entityManagerClass = {}
    entityManagerClass.mt = {__index = index}

    function entityManagerClass:newManager()
        local manager = {}

        --any used ids will be set to true
        manager.entityIds = {}

        --maps unique ids (to be referenced by other entities) to entity ids
        manager.uniqueIds = {}

        setmetatable(manager, self.mt)

        --the components table maps {component type -> {entity id -> component}}
        manager.components = {}
        for k,v in pairs(manager.componentTypes) do
            manager.components[k] = {}
        end

        return manager
    end

    return em
end
