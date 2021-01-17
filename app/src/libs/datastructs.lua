Queue = {}

local function queue()
    local this = {
        first = 0,
        last = 0,
        sz = 0
    }
    function this:push (value)
      local last = self.last + 1
      self.last = last
      self[last] = value
      self.sz = self.sz + 1
    end
    function this:pop ()
        local first = self.first

        if not first then 
            error("Queue is empty, unable to pop")
            self.sz = 0
            return nil
        else
            local value = self[first]
            self[first] = nil
            self.first = first + 1
            self.sz = self.sz - 1
            return value
        end
    end
    function this:Size()
        return self.sz
    end

    return this
end

function Queue:Create()
    return queue()
end

AppModule = {}

local function appModule(e,r,ex,i)
    local this = {
                    enabled = e,
                    refresh_interval = r,
                    execute = ex,
                    initArgs = i
    }
    function this:Init(func,...)
        if func then
            if arg then
                func(arg)
            else
                func(self.initArgs)
            end
        elseif self.execute then
            self.execute:Init(self.initArgs)
        end
    end
    return this
end

function AppModule:Register(...)    
    local m = appModule(false,1.0)

    for k,v in pairs(...) do 
        if k == "enabled" then m.enabled = v end
        if k == "refresh_rate" then m.refresh_interval = v end
        if k == "execute" then m.execute = v end
        if k == "initArgs" then m.initArgs = v end

        m[k] = v
    end

    return m
end
function AppModule:RegisterAndInitialize(...)
    local m = appModule(false,1.0)

    for k,v in pairs(...) do 
        if k == "enabled" then m.enabled = v end
        if k == "refresh_rate" then m.refresh_interval = v end
        if k == "execute" then m.execute = v end
        if k == "initArgs" then m.initArgs = v end

        m[k] = v
    end


    if m.execute and m.enabled then
        m.execute:Initialize(m.initArgs)
    end

    return m
end