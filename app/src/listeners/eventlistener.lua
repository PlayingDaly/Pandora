ListenerTypes = {
	NetworkMessage = "NetworkMessage",
	OnMouseDown = "OnMouseDown",
	OnMouseUp = "OnMouseUp",
	OnMouseMove = "OnMouseMove"
}


--SourceClassObj, ListenerType, Fn Called on event exec,
--Event class - basics for all event items
function EventListener(s,h,t)
	local this = {
		handler = h,
		listenertype = t,
		source = s
		
	}
	function this:Details()
		return string.format("%s %s %s", self.handler, self.source.name, self.listenertype)
	end
	function this:Execute(...)
		--print("Ex: ", self.source.name, select(1,...), select(2,...), select(3,...), select(4,...))
		if self.handler then
			if self.handler(self.source,...) then
				--self.handler:NotifyChanged()
			end
		end
	end

	return this
end