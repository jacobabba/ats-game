--this creates the entity manager "class"
--the entity manager class creates entity managers, each with their own entities

do
    --index with shared functions/data
    local index = {}

    --matches component type -> component type base class
    index.componentTypes = require("components/component_types")

    --the components is an optional table which maps 
    --    {component type -> {preliminary values for that component}}
    --uid is an optional unique identifier for this entity, and can be used
    --    to reference this entity from other entities
    function index:addEntity(components, uid)
        --find first unused id
        local id = table.getn(self.entities)
        id = id + 1
        self.entities[id] = {}

        if uid then
            if self.uniqueIds[uid] then
                error("Attempt to register a unique entity id that is already in use"..
                      " for this manager")
            end
            
            self.uniqueIds[uid] = id
        end

        if components then
            for k,v in pairs(components) do
                if not self.componentTypes[k] then
                    error("Attempt to create a component with a non-existant type")
                end

                self.entities[id][k] = self.componentTypes[k]:newComponent(v)
            end
        end
    end

    function index:removeEntity(id)
        self.entities[id] = nil
        for k,v in pairs(self.uniqueIds) do
            if v == id then
                self.uniqueIds[k] = nil
            end
        end
    end

    --returns a table mapping component type -> component for that entity
    function index:getEntity(uid)
        local id = self.uniqueIds[uid]
        if id == nil then return nil end

        return self.entities[id]
    end

    --gets all entities that have all requested components
    --signature should be a table containing names of required components
    --return table has structure {entity ids -> {component name -> component}}
    --  not only the ones that match the sig
    --  each with a table containing their own components
    --TODO: cache entity lists with different signatures?
    function index:getEntsFromSig(signature)
        --entities maps {entity id -> {component type -> component}}
        local e = {}

        for entk,entv in pairs(self.entities) do
            local include = true
            for _,sigv in ipairs(signature) do
                if not entv[sigv] then include = false end
            end

            if include then e[entk] = entv end
        end

        return e
    end

    local entityManagerClass = {}
    entityManagerClass.mt = {__index = index}

    function entityManagerClass:newManager()
        local manager = {}

        --any used ids will be set to true
        --this table maps {entity id -> {component name -> component}}
        manager.entities = {}

        --maps unique ids (to be referenced by other entities) to entity ids
        manager.uniqueIds = {}

        setmetatable(manager, self.mt)

        return manager
    end

    return entityManagerClass
end
