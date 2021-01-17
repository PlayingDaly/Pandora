require "kernel.ui"

PageBase = function(event, order, layout)
	local this = UI.Components.Page(layout.pd,layout.x,layout.y,layout.h,layout.w,layout.options,false)
	this.event = event				--1 is Left Click page, 2 is Right Click page
	this.order = order				--Order of pages when pagination is enabled

	
	--pagination
	function this:IncrementPage()

	end
	function this:DecrementPage()

	end

	return this;
end