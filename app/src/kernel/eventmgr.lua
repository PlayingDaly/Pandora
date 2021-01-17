require "libs.utils"
require "libs.datastructs"
require "libs.eventlistener"

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

		e,s, p1,p2,p3,p4,p5,p6,p7,p8,p9 = event.pull(0.1)

		if e and e ~= "FileSystemUpdate" then
			--print(e,p1,p2)
			--Log.Information(string.format("%s %s %s",e,p1,p2))
			--print(#EventManager.Listeners)
			--computer.stop()
			--Pass the Event to the correct registered listener
			--computer.stop()
			if EventManager.Listeners then
				--for k,v in ipairs(EventManager.Listeners) do print(k,v.source.name, v.listenertype) end
				--computer.stop()
				local listeners = Utils.table.getAllKeysForValue(EventManager.Listeners, e, "listenertype")
				--print("Found Listeners: ", #listeners)
				--If listener found then process the event
				if listeners then
				--for kk,vv in pairs(EventManager.Listeners) do print(kk,vv.source.name) end
				--computer.stop()
					for k in ipairs(listeners) do
						--print("Listener: ",k,EventManager.Listeners[k]:Details())
						EventManager.Listeners[k]:Execute(p1,p2,p3,p4,p5,p6,p7,p8,p9)
					end
				end
			end

			--if e == "OnMouseMove" then computer.stop() end
		end
	
end