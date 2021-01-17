require "libs.utils"
require "libs.datastructs"
require "listeners.eventlistener"

--Event manager framework.  Listens for event presses and executes them
EventManager = {
	Listeners = {}
}

--Source is expected to be of type drawing
function EventManager:RegisterListener(source, handler, type)	
	local elist = EventListener(source, handler,type)
	self.Listeners[#self.Listeners + 1] = elist

	return elist
end

function EventManager:Initialize()
	print("Initialize Event Listener")

	--Register the desktop Listener
	event.listen(SysConfig.Display_Manager.execute.Desktop.gpu)
end


EventManager.Listen = function()

	--e,s, p1,p2,p3,p4,p5,p6,p7,p8,p9 = event.pull(0.1)
	e = table.pack(event.pull(0.1))

	if e then 
		if e[1] and e[1] ~= "FileSystemUpdate" then
			--Pass the Event to the correct registered listener
			if EventManager.Listeners then
				local listeners = Utils.table.getAllKeysForValue(EventManager.Listeners, e[1], "listenertype")

				--for k,v in pairs(listeners) do print(k, v, #EventManager.Listeners, EventManager.Listeners[v]) end
				--computer.stop()

				--Removes e and 
				if #e > 1 then
					table.remove(e,1)		--Remove the Message name
				end

				--If listener found then process the event
				if listeners then
					for k,v in ipairs(listeners) do
						--print("Listener: ",k,v,EventManager.Listeners[v]:Details())
						EventManager.Listeners[v]:Execute(e)
					end
				end
			end
		end
	end
end