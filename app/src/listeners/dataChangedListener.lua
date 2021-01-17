
DataChangedRenderStack = function()
	local this = {
		changedItems = nil
	}
	function this:AddRenderItem(item)
		--print("Add Render Item")
		if not self.changedItems then self.changedItems = {} end
		self.changedItems[#self.changedItems+1] = item
	end
	function this:ResetChangedStack(newStack)
		self:Clear();
		self.changedItems = newStack
	end
	function this:Clear()
		self.changedItems = nil
	end
	function this:HasChanges()
		if self.changedItems and #self.changedItems > 0 then
			--print("Items: ", #self.changedItems)
			return true
		else
			return false
		end
	end
	return this;
end



DataChangeListener = function(d, ro)
	local this = {
		changeDetected = false,
		renderorder = ro or 1,				--1 to N, the higher the number, the higher the priority
		renderDisplay = d
	}

	function this:GetDisplay()
		return self.renderDisplay
	end
	function this:HasChanges()
		return self.changeDetected
	end
	function this:ResetChanged()
		self.changeDetected = false
	end
	function this:NotifyChanged()
		self.changeDetected = true
		--print("Notify CHange", self.renderDisplay)
		if self.renderDisplay then
			self.renderDisplay.changedItemStack:AddRenderItem(self)
		end
	end
	function this:SetRenderOrder(i)
		self.renderorder = i or 1
	end
	function this:GetRenderOrder()
		return self.renderorder
	end
	function this:DisplayHasMirrors()
	local hasMirrors = false
		if self.renderDisplay and self.renderDisplay.mirroredDisplay and #self.renderDisplay.mirroredDisplay > 0 then
			hasMirrors = true
		end
		return hasMirrors
	end
	function this:GetDisplayMirrors()
		--print("GDM: ",self.renderDisplay.mirroredDisplay)
		return self.renderDisplay.mirroredDisplay
	end

	return this
end