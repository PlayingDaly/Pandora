require "libs.eventlistener"

function MouseEventListeners() 
	local this = {
		mouseEnter = nil,
		mouseLeave = nil,
		mousemove = nil,
		click = nil,
		isMouseOver = false,
		isLeftClick = false,
		isRightClick = false
	}
	function this:SetMouseEnter(component, func)
		self.mouseEnter = EventManager:RegisterListener(component, func, ListenerTypes.OnMouseMove)
	end
	function this:SetMouseLeave(component, func)
		self.mouseLeave = EventManager:RegisterListener(component, func, ListenerTypes.OnMouseMove)
	end
	function this:SetClick(component, func)
		self.leftclick = EventManager:RegisterListener(component, func, ListenerTypes.OnMouseDown)
	end
	function this:SetMouseMove()
		print("NOT IMPLEMNTED! FUTURE")
	end

	function this:ResetTrackers()
		self.isMouseOver = false
		self.isLeftClick = false
		self.isRightClick = false
	end
	return this
end