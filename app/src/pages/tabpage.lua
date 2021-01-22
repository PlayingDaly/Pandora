require "pages.page"

TabPage = function(event, order, layout)

	--Set the Page Name
	layout = layout or {}
	layout.options = layout.options or {}
	if not layout.name then
		local eid = (event == 1 and "L" or "R")	
		layout.options.name = string.format("pg_%s_%s", "SystemStatus", eid)
	end

	--Set the Base Data
	local this = PageBase(event, order, layout)
	this.childpages = nil
	this.currentIndex = 1
	this.currentPage = nil

	function this:AddPageContent()

	end
	function this:AddChildPage(cp)
		if not self.childpages then self.childpages = {} end
		self.childpages[#self.childpages + 1] = cp
	end
	function this:RemoveChildPage(cp)
		if self.childpages and #self.childpages > 0 then
			local k = Utils.table.getKeyForValue(self.childpages,cp.name, "name")

			if k then
				self.childpages[k] = nil
			end
		end
	end

	--pagination
	function this:IncrementPage()
		if self.currentIndex < #self.childpages then
			self.currentIndex = self.currentIndex + 1
			self.currentPage = self.childpages[self.currentIndex]
			self.currentPage:ImmdiateUpdate(false)
		end
	end
	function this:DecrementPage()

	end

	return this
end