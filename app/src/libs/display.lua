require "kernel.ui"
require "libs.utils"
require "listeners.dataChangedListener"
require "pages.pagemgr"

DisplayTypes = {
	
	Large_Screen,
	Panel_Screen,
	Screen_Driver
}
NavigationBarLocation = {
	Bottom = 0,
	Top = 1
}


function Display(n,s,dt,x,r,options)
	local this = {
		name = n,
		gpu = nil,
		screendata = s,
		--comid = s.id,
		type = dt or DisplayTypes.Screen_Driver,
		ratio = r,
		height = (x/r.x)*r.y,
		width = x,
		color = UI.SysColors.Background,
		displayPage = nil,
		pages = {},
		navbar = {},
		focusedComponent = nil,
		changedItemStack = DataChangedRenderStack(),
		mirroredDisplay = nil,
		ismirrorDisplay = false,
		navbarlocation = NavigationBarLocation.Top						--Top is 0, Bottom is 1
	}
	function this:Details()
		return string.format("Name: %s\tSize: %s,%s\tRatio: %s:%s", self.name, self.width, self.height, self.ratio.x, self.ratio.y)
	end
	function this:ResetDisplay()
		self.gpu:setBackground(self.color.r,self.color.g,self.color.b,self.color.a)
		self.gpu:fill(0,0,self.width,self.height," ")
		self.gpu:flush()
	end
	function this:GetGridByName(name)
		if not self.displayPage then 
			--error("Display Page isn't Set")
			return nil
		elseif not self.displayPage.children then 
			--error(string.format("Current Page(%s) doesn't have any children set", self.displayPage.name))
			return nil
		else		
			local key =  Utils.table.getKeyForValue( self.displayPage.children, name, "name" )
			return self.displayPage.children[key]
		end
	end
	function this:SetGPU(v)
		self.gpu = v
		self.gpu:bindScreen(self.screendata)
		self.gpu:setSize(self.width, self.height)
		self:ResetDisplay()
		Log.Debug(self.name.." screen bound")
	end
	function this:ReleaseGPU()
		if self.gpu then
			print("Release GPU")
			self.gpu:bindScreen(nil)
		end
	end
	function this:Initialize()
		--Get all the computer GPUs
		local gpus = computer.getGPUs()

		--Iterate through the gpu's to find one that isn't bound
		for k,v in pairs(gpus) do
			if not v:getScreen() or v:getScreen() == self.screendata then
				self:SetGPU(v)
				break
			else
				print("Existing Screen: ", v:getScreen())
			end
		end

		if not self.gpu then
			print("Not Enough Gpu's to support the provided screens. Please add additional GPUs or remove screens")
		end
    end
	
	function this:Render()
		if self.changedItemStack:HasChanges() then
			local continuousMonitorlist = {}
			Log.Debug(string.format("Change List has %s item(s)", #self.changedItemStack.changedItems))
			--print(string.format("Change List has %s item(s)", #self.changedItemStack.changedItems))
			for k,v in Utils.table.spairs(self.changedItemStack.changedItems, function(t,a,b) return t[b].dataChangedListener.renderorder > t[a].dataChangedListener.renderorder end) do
				if v.type and v.type == 1 then
					if not v:DrawToScreen() then
						continuousMonitorlist[#continuousMonitorlist + 1] = v
					end
				else
					Log.Debug(function(k,v) str = string.format("Unable to Render index %s of type %s\n", k, type(v)) for kk,vv in pairs(v) do str = str..string.format("%s %s\n",kk,vv) end   end, {k=k,v=v})
				end
			end

			--Load the changed stack with the new continuous list.
			if continuousMonitorlist and #continuousMonitorlist > 0 then
				self.changedItemStack:ResetChangedStack(continuousMonitorlist)
			else
				self.changedItemStack:Clear()
			end

			self.gpu:flush()
		--else
		--	Log.Debug(string.format("No Changes Detected on %s", self.screendata))
		end
	end
	function this:AddNavbarItem()
		self.navbar[#self.navbar + 1] = g
	end
	function this:RemoveNavbarItem(gname)
		local index = Utils.table.getKeyForValue(self.navbar, gname, "name")

		if index and index > 0 then
			self.navbar[index] = nil
		end
	end
	function this:AddPage(g)
		self.pages[#self.pages + 1] = g
	end
	function this:RemovePage(gname)
		local index = Utils.table.getKeyForValue(self.pages, gname, "name")

		if index and index > 0 then
			self.pages[index] = nil
		end
	end
	function this:SetDisplayPage(p)
		p:ImmediateUpdate()

		--print(p.name, " set as display page. B:", p.bcolor:Details())
		self.displayPage = p
	end
	function this:AddMirror(screen)
		if not self.mirroredDisplay then self.mirroredDisplay = {} end
		self.mirroredDisplay[#self.mirroredDisplay + 1] = screen
	end
	function this:RemoveMirror(screen)
		local index = Utils.table.getKeyForValue(self.mirroredDisplay, screen.name, "name")
		if index and index > 0 then
			self.mirroredDisplay[index] = nil
		end
	end


	if options then
		if options.navbarlocation then 
			this.navbarlocation = options.navbarlocation 
		end
		if options.ismirror then
			this.ismirrorDisplay = options.ismirror
		end
	end


	return this
end