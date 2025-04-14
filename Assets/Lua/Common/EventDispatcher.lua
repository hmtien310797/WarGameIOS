module("EventDispatcher", package.seeall)

local modules = {}
local events = {}

local delayedEvents = {}
local numDelayedEvents = 0

HANDLER_TYPE = { INSTANT = 0,           -- Handler functions will be called instantly
                 DELAYED = 1,           -- Handler functions will be called in the next late update
                 STATIC_INSTANT = 2,    -- Handler functions will be called instantly and will not be removed by unbinding
                 STATIC_DELAYED = 3, }  -- Handler functions will be called in late update and will not be removed by UnbindAll()

local function AddDelayedEvent(id, ...)
    if not delayedEvents[id] then
        delayedEvents[id] = {}
        numDelayedEvents = numDelayedEvents + 1
    end

    table.insert(delayedEvents[id], { ... })
end

local function ResetDelayedEvents()
    delayedEvents = {}
    numDelayedEvents = 0
end

local function BindHandlerToEvent(event, module, handlerType, handler)
    if not event[handlerType] then
        error(string.format("[ERROR][EventDispatcher.BindHandlerToEvent] Invalid handlerType (%d).", handlerType))
    end

    event[handlerType][module] = handler
end

local function UnbindHandlersFromEvent(event, module)
    for handlerType, handlers in pairs(event) do
        if bit.band(handlerType, 2) == 0 then
            handlers[module] = nil
        end
    end
end

local function BroadcastEvent(event, handlerType, ...)
    if event[handlerType] then
        for _, handler in pairs(event[handlerType]) do
            handler(...)
        end
    end
end

function CreateEvent(enabledHandlerTypes)
    local event = {}
    for _, handlerType in pairs(enabledHandlerTypes or HANDLER_TYPE) do
        event[handlerType] = {}
    end
    
    table.insert(events, event)

    return #events
end

function Bind(id, module, handlerType, handler)
    if not id then
        error("[ERROR][EventDispatcher.Bind] Invalid #1 argument (nil).")
    end

    if not events[id] then
        error("[ERROR][EventDispatcher.Bind] Event does not exist.")
    end

    BindHandlerToEvent(events[id], module, handlerType, handler)

    if not modules[module] then
        modules[module] = {}
    end

    modules[module][id] = handler
end

function Unbind(id, module)
    UnbindHandlersFromEvent(events[id], module)

    if modules[module] then
        modules[module][id] = nil
    end
end

function UnbindAll(module)
    for id, _ in pairs(modules[module] or {}) do
        UnbindHandlersFromEvent(events[id], module)
    end

    modules[module] = {}
end

function Broadcast(id, ...)
    local event = events[id]
    if event then
        AddDelayedEvent(id, ...)

        BroadcastEvent(event, 2, ...)
        BroadcastEvent(event, 0, ...)
    end
end

local lastUpdateTime
function LateUpdate(now)
    if now ~= lastUpdateTime then
        lastUpdateTime = now
        
        BroadcastEvent(events[1], 2, now)
        BroadcastEvent(events[1], 0, now)
    end
    
    if numDelayedEvents > 0 then
        local eventsToBroadcast = delayedEvents

        ResetDelayedEvents()

        for id, params in pairs(eventsToBroadcast) do
            BroadcastEvent(events[id], 3, params)
            BroadcastEvent(events[id], 1, params)
        end
    end
end

function Test() -- EventDispatcher.Test()
    local event1 = CreateEvent()
    local event2 = CreateEvent()
    local event3 = CreateEvent()
    local event4 = CreateEvent()
    local event5 = CreateEvent()
    local event6 = CreateEvent()

    Bind(event1, _M, HANDLER_TYPE.DELAYED, function(s)
        print(2, "event1")
    end)

    Bind(event2, _M, HANDLER_TYPE.INSTANT, function(s)
        print(1, "event2")
    end)

    Bind(event3, _M, HANDLER_TYPE.DELAYED, function(s)
        print(3, "event3")

        print("Broadcasted event4")
        Broadcast(event4)
        
        print("Broadcasted event5")
        Broadcast(event5)
    end)

    Bind(event4, _M, HANDLER_TYPE.DELAYED, function(s)
        print(6, "event4")
    end)

    Bind(event5, _M, HANDLER_TYPE.INSTANT, function(s)
        print(4, "event5")

        print("Broadcasted event6")
        Broadcast(event6)

    end)

    Bind(event6, _M, HANDLER_TYPE.INSTANT, function(s)
        print(5, "event6")
    end)
    
    print("Broadcasted event1")
    Broadcast(event1)

    print("Broadcasted event2")
    Broadcast(event2)

    print("Broadcasted event3")
    Broadcast(event3)
end

