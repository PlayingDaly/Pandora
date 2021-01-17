require "kernel.ui"
require "pages.tabpage"

Network_Page = function(event, order, layout)	
	
	--Set this to the base object stack
	local this = TabPage(event, order, layout)
	local bcolor
	if event == 1 then
		bcolor = UI.SysColors.ToolBar
	elseif event == 2 then
		bcolor = UI.SysColors.Error
	end





	
	this:SetBackground(bcolor)



	return this
end