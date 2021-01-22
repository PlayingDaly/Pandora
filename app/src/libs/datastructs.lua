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

local function bufferLocation(p,len)
    local this = {
        point = p,
        maxLen = len,
        content = nil
    }

    function this:AddContent(c)
        if not self.content then self.content = {} end

        
        --Update the contents start points
        c.startpoint.x = self.point.x
        c.startpoint.y = self.point.y
        --self.content[#self.content + 1] = c
        self.content = c
    end
    function this:RemoveContent(c)
        error("FUTURE: REMOVE Content Not Implemented")
    end

    function this:ShiftDataUp(amt)
		self.point.y = self.point.y - amt
        self.content.startpoint.y = self.point.y
        self.content:SetForeground(UI.SysColors.Write)
        --self.content:NotifyChanged()
	end

    return this
end
ContentBuffer = function(p, size, lineSz)
    local this = {
        point = p,
        sz = size,
        maxLen = lineSz,
        buffer = {}
    }

    function this:AddContentItem(yIndex, c)
        --print("Add content to buffer @", yIndex, c.name)
        if c then
            local p = self.point
            p.y = yIndex
            local bi = bufferLocation(c.startpoint,self.maxLen)
            bi:AddContent(c)
            --self.buffer[yIndex] = bi
            table.insert(self.buffer,bi)
            --print("ACI:",c.name,bi.point:Details())
        end
    end
    function this:RemoveContent(c)
        --print("Remove content")
        local index = Utils.table.getKeyForValue(self.buffer,c.name,"name")
        --print("Content Index:",index)
        
        if index then
            table.remove(self.buffer,index)
            --print("Removing content/Paint over:",c.startpoint.x,c.startpoint.y,c.drawX,c.drawY)
            c:GetDisplay().gpu:fill(c.startpoint.x,c.startpoint.y,c.drawX,c.drawY," ")      --Doesn't work consistently. Change list can cause it overwrite the remove'
        end
    end
    function  this:GetContentItem(index)
	    return self.buffer[index]
    end

    return this
end