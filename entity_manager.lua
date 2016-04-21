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
                if not self.components[k] then
                    error("Attempt to create a component with a non-existant type")
                end

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
    --  not only the ones that match the sig
    function index:getEntsFromSig(signature)
        --entities maps {entity id -> {component type -> component}}
        local entities = {}

        --get table length
        local n = 0
        for _ in ipairs(signature) do n = n + 1 end

        if not self.components[signature[n]] then
            error("Signature contains a component that doesn't exist")
        end

        --prepopulate the entities table with all of the entities that have
        --the last component in the signature
        for k,v in pairs(self.components[signature[n]]) do
            entities[k] = {}
            entities[k][signature[n]] = v
            for compk,compv in pairs(self.components) do
                entities[k][compk] = compv[k]
            end
        end
        signature[n] = nil

        for sigk,sigv in ipairs(signature) do
            for entk,entv in pairs(entities) do
                --if this entity has this component, keep it in the list
                --otherwise, remove that entity
                if not self.components[sigv] then
                    error("Signature contains a component that doesn't exist")
                end

                if not self.components[sigv][entk] then
                    entities[entk] = nil
                end
            end
        end

        return entities
    end

    --for debug purposes. prints a list of all entities and their data
    function index:display()
        local inspect = require("inspect")
        for k,v in pairs(self.entityIds) do
            for kk,vv in pairs(self.components) do
                if vv[k] then
                    print("entity id:"..k.." component:"..kk)
                    print(inspect(vv[k]))
                end
            end
        end
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

    return entityManagerClass
end
