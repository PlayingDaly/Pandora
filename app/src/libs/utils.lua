--Utility Functions

Utils = {
    debug = {
            printFunctionArgs = function(...)
	                                local t = Utils.varArgsToTable(...)[1] or nil
                                    if t then
	                                    print("------------------------------------------")
	                                    for k,v in pairs(t) do
		                                    print(string.format("arg: %s\tval: %s", k,v))
	                                    end
	                                    print("------------------------------------------")
                                    end
                                end,
            printTable = function(t)
                            if type(t) == "table" then
                                for k,v in pairs(t) do 
                                    print(k,v) 
                                end
                            end
                        end
    },
    general = {
    --Provided by jrus @ https://gist.github.com/jrus/3197011#file-lua-uuid-lua-L2
            generateUuid = function()
                                local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
                                return string.gsub(template, '[xy]', function (c)
                                    local v = (c == 'x') and SysConfig.NumGenerator(0, 0xf) or SysConfig.NumGenerator(8, 0xb)
                                    return string.format('%x', v)
                                end)
                            end
    },
    --String Related found @ http://lua-users.org/wiki/StringRecipes
    strings = {
            starts_with = function(str, start)
                            return str:sub(1, #start) == start
                          end,
            ends_with = function(str, ending)
                            return ending == "" or str:sub(-#ending) == ending
                        end,
            lastIndexOfChar =   function(str,char)
                                    index = string.find(str, char.."[^"..char.."]*$")
                                    return index
                                end,
            wrap = function(str, limit, indent, indent1)
                        indent = indent or ""
                        indent1 = indent1 or indent
                        limit = limit or 72
                        local here = 1-#indent1
                    
                        local function check(sp, st, word, fi)
                            if fi - here > limit then
                                here = st - #indent
                                return "\n"..indent..word
                            end
                        end
                        return indent1..str:gsub("(%s+)()(%S+)()", check)
                    end,
            stringToParagraph = function(str, limit, indent, indent1)
                                    return (str:gsub("%s*\n%s+", "\n")
                                        :gsub("%s%s+", " ")
                                        :gsub("[^\n]+", function(line)
                                                            return wrap(line, limit, indent, indent1)
                                                        end))
                                end,
            replace = function(str, strToFind, strToReplace)
                            strToReplace = strToReplace or " "
                            return string.gsub(str,strToFind,strToReplace)
                          end
    },
    table = {
            varArgsToTable =    function(...)
                                    return {...}
                                end,
            setContains =   function(T, key)
                                return T[key] ~= nil
                            end,
            has_value = function (tab, val)
                            for index, value in pairs(tab) do
                                if value == val then
                                    return true
                                else
                                    return false
                                end
                            end
                        end,
            spairs = function(t, order)
                        -- collect the keys
                        local keys = {}
                        for k in pairs(t) do 
                            keys[#keys+1] = k 
                        end
                        -- if order function given, sort by it by passing the table and keys a, b,
                        -- otherwise just sort the keys 
                        if order then
                            table.sort(keys, function(a,b) return order(t, a, b) end)
                        else
                            table.sort(keys)
                        end
                        
                        -- return the iterator function
                        local i = 0
                        return function()
                            i = i + 1
                            if keys[i] then
                                computer.skip()
                                return keys[i], t[keys[i]]
                            end
                        end
                    end,
            getTableLength = function(T)
                                local count = 0
                                if T then
                                    for _ in pairs(T) do 
                                        count = count + 1 
                                    end
                                end
                                return count
                            end,
            getKeyForValue = function( t, value, childKey )
                                --print("Searching for ", value, " with childKey: ", childKey)
                                for k,v in pairs(t) do
                                --Catch rare case of improper use of function call. If doing simple key lookup setContains is a better choice
                                    if childKey and k == childKey then
                                        return k
                                    else
                                        if type(v) == "table" then
                                            if Utils.table.setContains(v,value) then
                                                return k
                                           elseif childKey then
                                           --elseif childKey and Utils.table.setContains(v,childKey) and v[childKey] == value then
                                                if Utils.table.setContains(v,childKey) and v[childKey] == value then
                                                    return k
                                                end
                                            else
                                                local res = Utils.table.getKeyForValue(v,value,childKey)
                                                if res then 
                                                    return k 
                                                end
                                            end
                                        elseif v == value then
                                            return k
                                        end
                                    end
                                end
                                return nil
                            end,
            getAllKeysForValue = function(t, value, childKey)
                                    --print("Searching for ", value, " with childKey: ", childKey)
                                    local result = {}
                                    for k,v in pairs(t) do

                                    --Catch rare case of improper use of function call. If doing simple key lookup setContains is a better choice
                                        if childKey and k == childKey then
                                            result[#result + 1] =  k
                                        else
                                            if type(v) == "table" then
                                                
                                                --for kk,vv in pairs(v) do print(kk,vv) end
                                                
                                                --print(Utils.table.setContains(v,"listenertype"))    --This returns false???? WHY????????
                                                --computer.stop()

                                                if Utils.table.setContains(v,value) then
                                                    --print("Table contains value")
                                                    result[#result + 1] =  k
                                                --elseif childKey and Utils.table.setContains(v,childKey) and v[childKey] == value then
                                                elseif childKey then
                                                    --for kk,vv in pairs(v) do print(kk,vv) end
                                                    --print("Item Child key: ", v[childkey])
                                                    if Utils.table.setContains(v,childKey) and v[childKey] == value then
                                                        result[#result + 1] =  k
                                                    end
                                                else
                                                    --print("Search deeper")
                                                    local res = Utils.table.getAllKeysForValue(v,value,childKey)
                                                    if res then 
                                                        for k,v in ipairs(res) do
                                                            result[#result + 1] =  v
                                                        end
                                                    end
                                                end
                                            elseif v == value then
                                                result[#result + 1] =  k
                                            end
                                        end

                                        --computer.stop()
                                    end

                                    if result and #result > 0 then
                                        return result
                                    else
                                        return nil
                                    end
                                 end,
            --shallowCopy and deepCopy Provided by MihailJP @ https://gist.github.com/MihailJP/3931841
            shallowCopy  = function(t)
                                if type(t) ~= "table" then 
                                    return t 
                                end
                                local meta = getmetatable(t)
                                local target = {}
                                for k, v in pairs(t) do 
                                    target[k] = v 
                                end
                                setmetatable(target, meta)
                                return target
                            end,
            deepCopy  = function(t)
                            if type(t) ~= "table" then 
                                return t 
                            end
                            local meta = getmetatable(t)
                            local target = {}
                            for k, v in pairs(t) do
                                if type(v) == "table" then
                                    target[k] = Utils.tableShallowCopy(v)
                                else
                                    target[k] = v
                                end
                            end
                            setmetatable(target, meta)
                            return target
                        end,
            bindFunction = function(t, k)
                                return function(...) 
                                            return t[k](t, ...) 
                                        end
                            end
    }
}