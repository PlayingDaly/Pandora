require "kernel.ui"
require "kernel.desktop"
require "libs.display"

local function ScreenDriverDisplay(n,w)
	local coms = computer.getScreens()

	if not coms and coms[1] then
		Log.Error("No screen drivers found. Please add a screen driver before trying to add")
		return nil
	elseif #coms > 1 then
		Log.Warning("Only One screen driver supported in "..SysConfig.AppName.." v. "..SysConfig.Version)
		return nil
	else
		local this = Display(n,coms[1],DisplayTypes.Screen_Driver,w,UI.ScreenRatios.NormalScreenRatio)
		return this
	end
end
local function LargeScreenDisplay(n,w, ismirror)
	local com = component.proxy(component.findComponent(n))
	
	if not com and com[1] then
		Log.Error("Unable to find a screen with the name "..n)
		return nil
	else
		w = (ismirror and DisplayManager.Desktop.width or w)
		local this = Display(n,com[1],DisplayTypes.Large_Screen,w,UI.ScreenRatios.NormalScreenRatio,{ismirror = ismirror})
		
		--If mirror is set then add to desktop as mirror
		if ismirror and isMirror ~= false then
			DisplayManager.Desktop:AddMirror(this)
		end

		return this
	end
end


--As of 06.01.21 Max number of gpu's in a computer is 3
DisplayManager = {
	Desktop = ScreenDriverDisplay("Desktop",220),			--220 for small ui
	Screen1 = nil,
	Screen2 = nil
}
function DisplayManager:Initialize(args)
	print("Starting Display Manager.....")

	--Set the Desktop Visuals
	self.Desktop:Initialize()
	--PANDORA_Desktop:InitializeDesktop(self.Desktop)

	if args then
		if Utils.table.setContains(args,"screen1") then
			local s = args["screen1"]
			self.Screen1 = LargeScreenDisplay(s.name, s.width, s.isMirror)
		end

		if Utils.table.setContains(args,"screen2") then
			local s = args["screen1"]
			self.Screen2 = LargeScreenDisplay(s.name, s.width, s.isMirror)
		end
	end

	if self.Screen1 then
		self.Screen1:Initialize()
	end

	if self.Screen2 then
		self.Screen2:Initialize()
	end

	PANDORA_Desktop:InitializeDesktop(self.Desktop)
end
function DisplayManager:AddScreen(display)
	if not self.Screen1 then self.Screen1 = display
	elseif not self.Screen2 then self.Screen2 = display
	else print("This computer doesn't support any additional screens. Please remove one before trying to add this screen.")
	end
end
function DisplayManager:RemoveScreen(name)
	if self.Screen1.name == name then 
		self.Screen1.ReleaseGPU()
		self.Screen1 = nil 
	end
end
function DisplayManager:GetAllScreenDetails()
	
	if self.Desktop then
		Log.Information(string.format("Desktop: %s",self.Desktop:Details()))
	end
	if self.Screen1 then
		Log.Information(string.format("Screen1: %s",self.Screen1:Details()))
	end
	if self.Screen2 then
		Log.Information(string.format("Screen2: %s",self.Screen2:Details()))
	end
end
function DisplayManager:ValidateDisplay(display)
	local isValid = false
	local com = component.proxy(component.findComponent(display.name))
	--[[
		Verifies the component has been registered before
		if not registers the display as long as the display was defined in the 
		initialization of the display manager.
	  ]]
	if not display.screendata and com[1] then
		if com then
			display.screendata = com[1]
			display:ReleaseGPU()
			display:SetGPU(display.gpu)
		end
	elseif not com[1] then
		display.screendata = nil
	else
		if com and com[1] and display and display.screendata then
			--Check if screen has changed
			if display.screendata.id ~= com[1].id then
				display.screendata = com[1]
				display:ReleaseGPU()
				display:SetGPU(com[1])

			end
		end
	end

	--Check if the screen component exists
	if display.screendata then
		isValid = true
	end
	
	--TODO: When screen is connected to a running app the refresh doesn't happen immediately. How to make this happen?

	return isValid
end


DisplayManager.Render = function()
	--Function Runs on a timed interval of the Set refresh rate.
	if DisplayManager.Desktop then DisplayManager.Desktop:Render() end
	if DisplayManager.Screen1 and DisplayManager:ValidateDisplay(DisplayManager.Screen1) then  DisplayManager.Screen1:Render() end
	if DisplayManager.Screen2 then DisplayManager.Screen2:Render() end

end