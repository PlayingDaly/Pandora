require "kernel.ui"
require "pages.pagemgr"
--Desktop.lua is builds the layout on the screen of the PANDORA Desktop


PANDORA_Desktop = {
	navbar = {},
	workarea = {}
}


local navbarHeight = 3
local navbarTabSize = 25
local sysclockGridOffset = 25 --13
local tabs = {"System_Status", "Production", "Transport","Storage","Power","Network"}		--Can add a 6th tab
local tabRightSpace = 3

local function BuildNavigationBar(display)
	local startY = 0
	local startPgY = 0

	--Determine X based on navbar location
	if display.navbarlocation == NavigationBarLocation.Bottom then
		startY = display.height-navbarHeight
	elseif display.navbarlocation == NavigationBarLocation.Top then
		startPgY = navbarHeight
	end
	local pglayout = {
					pd = display,
					x = 0,
					y = startPgY + (1 * tonumber(display.navbarlocation)),
					h = display.height - navbarHeight - 1,
					w = display.width,
					{
						zIndex = 2
					}
	}

	--Navbar base
	PANDORA_Desktop.navbar.navbarbase = UI.Components.Grid(	display,										--Display Ref
															0,												--X
															startY,											--Y
															navbarHeight,									--Height
															display.width,									--Width
															{												--Options
																name = "navbarbase",
																background = UI.SysColors.Clear
															}
														)

	--for i=1,#tabs do
	local i = 1
	for k in pairs(PageManager) do
		PANDORA_Desktop.navbar.navbarbase:AddChild(
			UI.Components.Button(display,
								(PANDORA_Desktop.navbar.navbarbase.startpoint.x + math.floor((i-1) * navbarTabSize) + i),
								PANDORA_Desktop.navbar.navbarbase.startpoint.y,
								navbarHeight,
								navbarTabSize,
								UI.Components.TextBlock(display,
														UI.Components.Point(PANDORA_Desktop.navbar.navbarbase.startpoint.x + (i-1) * navbarTabSize + i,
																			PANDORA_Desktop.navbar.navbarbase.startpoint.y + math.floor(navbarHeight/2)
																			),
														Utils.strings.replace(k,"_"),
														false,
														{
															continuousText = false,
															textalignment = UI.TextAlign.Center,
															maxlength = navbarTabSize
														}
														),
								false,
								{
									name= "btn_tab_"..k,
									background = UI.SysColors.Write,
									foreground = UI.SysColors.Highlight,
									click = function(src,...) 
												src:Click(	function(src) 							--Left Click function
																	local c = (src.mouseListeners.isLeftClick and Colors.Yellow or nil)
																	src:LeftClick(c) 
																end,
															function(src)							--Right Click function
																	local c = (src.mouseListeners.isLeftClick and Colors.Aqua or nil)
																	src:RightClick(c)
																end,
															...)									--Pass through args
												end,
									leftclickPg = PageManager[k](1,1,pglayout),
									rtclickPg = PageManager[k](2,1,pglayout),
									--[[
										--EXAMPLE OF MOUSE ENTER/ LEAVE EVENTS. NOT RECOMMENDED AS ImmediateUpdate can cause Screen flickering
																			
									mouseenter = function(src,...) 
													src:MouseEnter(...) 
													if src.mouseListeners.isMouseOver then
														--src:SetBackground(Colors.Yellow)
														src:ImmediateUpdate(Colors.Yellow)
													end
												end,
									mouseleave = function(src,...) 
													src:MouseLeave(...) 
													if not src.mouseListeners.isMouseOver then
														--src:SetBackground(Colors.Yellow)
														src:ImmediateUpdate(Colors.Write)
													end
												end,
									]]
								}
							)
		)
		i = i + 1
	end
	
	--Sys Clock
	PANDORA_Desktop.navbar.navbarclock = UI.Components.Grid(display,										--Display Ref
															display.width-sysclockGridOffset,				--X
															startY+1,										--Y
															math.floor(navbarHeight/2),						--Height
															sysclockGridOffset - 2,							--Width
															true,											--Render On Creation
															{												--Options
																name = "navbarSysClock",
																background = UI.SysColors.Clear,
																foreground = UI.SysColors.Write,
																zIndex = 2,
																children =	{ 
																			UI.Components.TextBlock(display,
																									UI.Components.Point(display.width-sysclockGridOffset,startY+1),
																									SysTime.Display,
																									true,
																									{
																										continuousText = true,
																										textalignment = UI.TextAlign.Center,
																										maxlength = sysclockGridOffset - 2
																									}
																								 )
																			}
															}
														)
end

function PANDORA_Desktop:InitializeDesktop(display)
	BuildNavigationBar(display)

	for k,v in pairs(self.navbar.navbarbase.children) do
		display:AddNavbarItem(v)

		--If the Sys Status entry found force the left click action	
		if string.match(tostring(v.name), "System_Status") then
			v.mouseListeners.isLeftClick = true
			v:LeftClick(UI.SysColors.Warning)
			
			--Re-add the item to the change stack......HACK approach
			--v:NotifyChanged()
			--v.leftclickPg:NotifyChanged()
		end
	end
end