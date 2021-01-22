require "libs.utils"
require "libs.drawing"
require "libs.colors"
require "libs.datastructs"
UI = {}

--Screen Ratio
local function sRatio(x,y)
	local this = {
		x = x,
		y = y
	}
	function this:Details()
		return string.format("%s:%s",self.x,self.y)
	end
	return this
end

--(PrimaryDisplay, X, Y, Height, Width, RenderOnCreation)
local function UIBase(pd,x,y,h,w,r)	
	local this = Drawing.Rectangle(pd,UI.Components.Point(math.floor(x),math.floor(y)),h,w,r,1,UI.SysColors.Transparent,UI.SysColors.Transparent)
	this.name = nil
	this.parent = nil
	this.children = nil
	this.availableOptions = nil

	function this:AvailableOptions()
		if not self.availableOptions then
			return "No Additional Options can be set on this component"
		else
			local opt = ""
			for k,v in pairs(self.availableOptions) do
				opt = string.format("%s\n%s", opt, v)
			end
			return opt
		end
	end

	function this:AddChild(v)
		if not self.children then self.children = {} end
		if v.type and v.type == 1 then
			self.children[#self.children + 1] = v
			v:SetParent(self)
			v:SetRenderOrder(self:GetRenderOrder() + #self.children)
		end
	end
	function this:RemoveChild(c)
		local index = Utils.table.getKeyForValue(self.children,c.name,"name")
        table.remove(self.children,index)
	end
	function this:SetParent(p)
		self.parent = p 
		
		if p then
			if p.fcolor and self.fcolor and self.fcolor:IsTransparent() then self:SetForeground(p.fcolor) end
			if p.bcolor and self.bcolor and self.bcolor:IsTransparent() then self:SetBackground(p.bcolor) end
		end
	end

	return this
end


--Border
UI.Border = function(l,t,r,b,t)
	local this = {
		left = l,
		top = t,
		right = r,
		bottom = b,
		thickness = t
	}

	return this
end
--Button(primdisplay,x,y,h,w,content,options)
UI.Button = function(pd,x,y,h,w,c,r,options)
	--local this = Drawing.Rectangle(pd,UI.Components.Point(math.floor(x),math.floor(y)),h,w,1,UI.SysColors.Transparent,UI.SysColors.Transparent)
	local this = UIBase(pd,x,y,h,w,r)
	this.name = "btn_"..Utils.general.generateUuid()
	this.parent = nil
	this.availableOptions = {"name","parent","zIndex","foreground","background","mouseenter","mouseleave","mousemove","click","leftclickPg","rtclickPg" }
	
	--Click Pages
	leftclickPg = nil
	rtclickPg = nil

	--content
	this.content = c
	this.content:SetParent(this)
	this.content:SetRenderOrder(this:GetRenderOrder() + 1)		--Force the Render Order to be 1 above the current
	--c:SetRenderOrder(this:GetRenderOrder() + 1)		--Force the Render Order to be 1 above the current
		
	--Button Setup options
	if options then
		--Data props
		if options.name then
			this.name = options.name
		end
		if options.parent then
			this:SetParent(options.parent)
		end

		--UI props	
		if options.zIndex then 
			this.dataChangedListener:SetRenderOrder(options.zIndex) 
		end

		--Colors
		if options.foreground then 
			this:SetForeground(options.foreground) 
			if this.content then this.content:SetForeground(options.foreground) end
		end
		if options.background then 
			this:SetBackground(options.background) 
			if this.content then this.content:SetBackground(options.background) end
		end

		--Register the Mouse Events
		if options.mouseenter then
			this.mouseListeners:SetMouseEnter(this, options.mouseenter)
		end
		if options.mouseleave then
			this.mouseListeners:SetMouseLeave(this, options.mouseleave)
		end
		if options.mousemove then
			error("Mouse Move Not Implemented!")
		end
		if options.click then
			this.mouseListeners:SetClick(this, options.click)
		end
		if options.leftclickPg then
			this.leftclickPg = options.leftclickPg
		end
		if options.rtclickPg then
			this.rtclickPg = options.rtclickPg
		end
	end

	return this
end
--ComboBox
UI.ComoboBox = function(pd,x,y,h,w,i,r,options)
	local this = UIBase(pd,x,y,h,w,r)
	this.name = "cmbx_"..Utils.general.generateUuid()
	this.children = {}

	return this
end
--Grid
local gridDefaults = function()
	local this = {
		columns = 1,
		rows = 1,
		textAlign = UI.TextAlign.Left,
		textWrap = UI.TextWrap.NoWrap,
		fcolor = UI.SysColors.Write,
		bcolor = UI.SysColors.Background,
		zIndex = 1,
		margin = UI.Components.Margin(0,0,0,0)
	}

	return this;
end
UI.Grid = function(pd,x,y,h,w,r,options)
	local this = UIBase(pd,x,y,h,w,r)
	this.name = "grd_"..Utils.general.generateUuid()
	--this.children = {}
	this.ui_settings = gridDefaults()
	this.availableOptions = {"name","parent","children","columns","rows","zIndex","foreground","background","mouseenter","mouseleave","mousemove","click" }
	this.currentWritePoint = UI.Components.Point(x,y)
	this.contentbuffer = ContentBuffer(UI.Components.Point(x,y),h,w)

	function this:UISettings(displayData)
		if displayData then
			print("Grid UI Settings")
			print(string.format("columns: %s\nrows: %s\nforeground: %s\nbackground: %s\nzIndex: %s",self.ui_settings.columns,self.ui_settings.rows,self.ui_settings.fcolor:Details(),self.ui_settings.bcolor:Details(), self.ui_settings.zIndex))
		else
			return self.ui_settings.columns,self.ui_settings.rows,self.ui_settings.foreground,self.ui_settings.background
		end
	end
	function this:Details(displayData, showOpts)
		local opts = nil
		if displayData then
			print("Grid Details:")
			print(string.format("Grid Data: \nn:%s\nx:%s\ny:%s\nw:%s\nh:%s\n",self.name,self.startpoint.x, self.startpoint.y, self.height, self.width))

			if showOpts then opts = self:UISettings(displayData) end
		else
			if showOpts and not opts then 
		 		return self.startpoint.x, self.startpoint.y, self.height, self.width, self:UISettings(displayData)
			else
				return self.startpoint.x, self.startpoint.y, self.height, self.width
			end
		end
	end
	function this:AddChild(v)
		if not self.children then self.children = {} end
		if v.type and v.type == 1 then
			self.children[#self.children + 1] = v
			v:SetParent(self)
			v:SetRenderOrder(self:GetRenderOrder() + #self.children)
			
			--Add to Write buffer -- Handle sizing here???
			--print(v.name, v.startpoint:Details())
			self.contentbuffer:AddContentItem(v.startpoint.y,v)
		end
	end
	function this:RemoveChild(c)
		local index = Utils.table.getKeyForValue(self.children,c.name,"name")
        --print("Child Index:",index)
		self.contentbuffer:RemoveContent(c)
		table.remove(self.children,index)
	end
	function this:CanWrite(point)
		return self.currentWritePoint:Compare(point)
	end
	function this:ShiftDataUp(moveAllAboveY, amt)

		--print(string.format("Shifting up %s spaces, starting at %s", amt, moveAllAboveY))

		--Loop through each item and shift
		for i=1,moveAllAboveY do
			local buffItem = self.contentbuffer:GetContentItem(i)
			if buffItem then
				--print(string.format("BI:%s p:%s, amt:%s, sy:%s > %s :: %s", buffItem.content.name, buffItem.point:Details(), amt, self.startpoint.y, buffItem.point.y - amt, (buffItem.point.y - amt <= self.startpoint.y)))
				if buffItem.point.y - amt <= self.startpoint.y then
					self:RemoveChild(buffItem.content)
				elseif buffItem.point.y <= moveAllAboveY then
					buffItem:ShiftDataUp(amt)
					--print(string.format("BA:%s p:%s, amt:%s, sy:%s", buffItem.content.name, buffItem.point:Details(), amt, self.startpoint.y))
				end
			end
		end
	end
	
	--Grid Setup options
	if options then
		--Data props
		if options.name then
			this.name = options.name
		end
		if options.parent then
			this:SetParent(options.parent)
		end

		--UI props
		if options.columns then 
			this.ui_settings.columns = options.columns 
		end
		if options.rows then 
			this.ui_settings.rows = options.rows 
		end		
		if options.zIndex then 
			this.ui_settings.zIndex = options.zIndex 
			this.dataChangedListener:SetRenderOrder(options.zIndex) 
		end

		--Children
		if options.children then
			if type(options.children) == "table" then
				for k,v in pairs(options.children) do
					this:AddChild(v)
				end
			else
			--TODO: Handle cases when children is set to single item
				print("Child is type: ",type(options.children))
			end
		end

		--Colors
		if options.foreground then 
			this.ui_settings.fcolor = options.foreground 
			this:SetForeground(options.foreground) 
			this:SetChildColors(this.fcolor,this.bcolor)
		end
		if options.background then 
			this.ui_settings.bcolor = options.background 
			this:SetBackground(options.background) 
			this:SetChildColors(this.fcolor,this.bcolor)
		end

		--Register the Mouse Events
		if options.mouseenter then
			this.mouseListeners:SetMouseEnter(this, options.mouseenter)
		end
		if options.mouseleave then
			this.mouseListeners:SetMouseLeave(this, options.mouseleave)
		end
		if options.mousemove then
			error("Mouse Move Not Implemented!")
		end
		if options.click then
			this.mouseListeners:SetClick(this, options.click)
		end
	end

	return this
end

--ListBox
UI.ListBox = function(pd,x,y,h,w,r,options)
	local this = UIBase(pd,x,y,h,w,r)
	this.name = "lbx_"..Utils.general.generateUuid()
	this.children = {}
	this.scroller = nil





	if options then


	end

	return this;
end
--Margin
UI.Margin = function(l,t,r,b)
	local this = {
		left = l,
		top = t,
		right = r,
		bottom = b
	}

	return this
end
--Page --Container that holds grids
UI.Page = function(pd,x,y,h,w,r,options)
	--local this = Drawing.Rectangle(pd,UI.Components.Point(math.floor(x),math.floor(y)),h,w,1)
	local this = UIBase(pd,x,y,h,w,r)
	this.name = "pg_"..Utils.general.generateUuid()
	this.children = {}

	function this:Details(displayData)
		local opts = nil
		if displayData then
			print("Page Details:")
			print(string.format("Page Data: \nn:%s\nx:%s\ny:%s\nw:%s\nh:%s\n",self.name,self.startpoint.x, self.startpoint.y, self.height, self.width))

		else
			return self.startpoint.x, self.startpoint.y, self.height, self.width
		end
	end
	function this:AvailableOptions()
		print("Page Options:")
	end

	if options then
		if options.name then this.name = options.name end
		if options.children then this.children = options.children end
		if options.parent then this:SetParent(options.parent) end
		if options.background then this:SetBackground(options.background) end
	end

	--If no children set on creation, add a child grid
	if this.children and #this.children < 1 then
		local grdName = "grd_pg_"..Utils.general.generateUuid()
		if options and options.name then grdName = string.format("grd_%s",options.name) end
		local g = UI.Components.Grid(pd,x+1,y+1,h-2,w-3,{name = grdName, background = UI.SysColors.Transparent})	-- has 1,1,1,1 margin
		
		this:AddChild(g)
	end

	return this
end
--Paginator - Will fill bottom 3 rows of parent container
UI.Pagination = function(pd,parent,x,y,options)

end
--Point
UI.Point = function(x,y)
	local this = {
		x = tonumber(x) or 0,
		y = tonumber(y) or 0
	}
	function this:Details()
		return "("..x..","..y..")"
	end
	function this:Compare(point)
		local xPass = false
		local yPass = false

		if point then			
			if point.x == self.x then 
				xPass = true 
			end
			
			--Skip searching Y if x doesn't match
			if xPass then
				if point.y == self.y then 
					yPass = true 
				end
			end

			if xPass and yPass then return true end
		end
		return false
	end


	return this;
end

--TextBlock
UI.TextBlock = function(d,p,t,r,options)
	local this = Drawing.Text(d,p,t,UI.TextAlign.Left, d.width, r, UI.SysColors.Transparent, UI.SysColors.Transparent)
	this.name = "txt_"..Utils.general.generateUuid()
	this.parent = nil

	function this:AvailableOptions()
		return { "name", "parent", "textcolor", "highlightcolor", "maxlength", "textalignment", "continuousText", "zIndex"}
	end
	function this:SetParent(p)
		self.parent = p 
		
		if p then
			if p.fcolor and self.fcolor:IsTransparent() then self:SetForeground(p.fcolor) end
			if p.bcolor and self.bcolor:IsTransparent() then self:SetBackground(p.bcolor) end
		end
	end

	if options then
		if options.name then this.name = options.name end
		if options.parent then this:SetParent(options.parent) end
		if options.textcolor then this:SetForeground(options.textcolor) end
		if options.highlightcolor then this:SetBackground(options.highlightcolor) end
		if options.maxlength then this.drawX = options.maxlength end
		if options.textalignment then this.textalign = options.textalignment end
		if options.zIndex then this:SetRenderOrder(options.zIndex) end
		if options.continuousText then this.continuousText = options.continuousText end

	end
	return this
end
UI.TextBox = function(d,p,t,r,options)

end


--UI Exposed Table
UI = {	
	SysColors = {
		Background = Colors.Clear,
		Black = Colors.Black,
		Debug = Colors.Aqua,
		Error = Colors.Red,
		Highlight = Colors.Blue,
		ToolBar = Colors.Green,
		Transparent = Colors.Transparent,
		Warning = Colors.Yellow,
		Write = Colors.White
	},
	StatusColors = {
		Optimal = Colors.Green,
		Issue = Colors.Yellow,
		Error = Colors.Red,
		Offline = Colors.Blue,
		Test = Colors.Orange
	},
	Components = {
		Border = UI.Border,
		Button = UI.Button,
		ComboBox = UI.ComboBox,
		Grid = UI.Grid,
		ListBox = UI.ListBox,
		Margin = UI.Margin,
		Page = UI.Page,
		Pagination = UI.Pagination,
		Point = UI.Point,
		TextBlock = UI.TextBlock,
		TextBox = UI.TextBox
		
	},
	ScreenRatios = {
		--ScreenDriverRatio = sRatio(11,5),
		--LargeScreenRatio = sRatio(11,3)
		SmallScreenRatio = sRatio(11,5),
		NormalScreenRatio = sRatio(11,3),
		LargeScreenRatio = sRatio(11,2),
		UltraScreenRatio = sRatio(11,1)
	},
	
	TextAlign = {
		Left = "LEFT",
		Center = "CENTER",
		Right = "RIGHT"	
	},
	TextWrap = {
		NoWrap = "NoWrap",
		Wrap ="Wrap"
	}

}