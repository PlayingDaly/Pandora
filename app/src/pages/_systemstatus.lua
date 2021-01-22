require "kernel.ui"
require "pages.tabpage"

System_Status_Page = function(event, order, layout)	
	
	--Set this to the base object stack
	local this = TabPage(event, order, layout)
	local bcolor
	

	function this:CreateLeftClickPage(bcolor)
		self:SetBackground(bcolor)

		--Create Data Grid
		local dg = UI.Components.Grid(self:GetDisplay(),self.startpoint.x + 2, self.startpoint.y + 2,self:GetDisplayHeight()-4,self:GetDisplayWidth()-4,true,{name = "grd_StatusPage_L_Primary",background=UI.StatusColors.Test,foreground=UI.StatusColors.Optimal})

		for i=2,10 do
			local t = UI.Components.TextBlock(self:GetDisplay(),UI.Components.Point(dg.startpoint.x,dg.startpoint.y * (i-1)),string.format("I'm a rendered Text Line %s",i), true, {name="txt_SS_"..i})
			--print(t.name, t.startpoint:Details())
			dg:AddChild(t)
		end

		self:AddChild(dg)


		--Test Shift up
		--dg:ShiftDataUp(30,4)			--Works with a bug on elements that disappear. If trying to shift in same cycle as initial render, initial render may overwrite the wipe on the screen.

	end
	function this:CreateRightClickPage(bcolor)
		self:SetBackground(bcolor)

	end


	if event == 1 then
		this:CreateLeftClickPage(UI.SysColors.Debug)
	elseif event == 2 then
		this:CreateRightClickPage(UI.SysColors.Warning)
	end
	return this
end