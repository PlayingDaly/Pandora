require "libs.colors"
require "listeners.dataChangedListener"
require "listeners.mouseEvents"

--Screen Write handles writing ALL data to a Screen
Drawing = {}

local function drawingbase(disp,p,x,y,r,fcolor,bcolor)
	local this ={
		type = 1,													--Type of 1 lets the render engine know its a renderable Object
		fcolor = fcolor or Colors.White,
		bcolor = bcolor or Colors.Transparent,
		drawY = y or 1,
		drawX = x or 1,
		startpoint = p or UI.Components.Point(0,0),
		dataChangedListener = DataChangeListener(disp,1),
		mouseListeners = MouseEventListeners(),
		renderOnCreation = r 
	}

	function this:SetBackground(color)
		self.bcolor = color
		self:SetChildColors(nil,color)
	end
	function this:SetForeground(color)
		self.fcolor = color
		self:SetChildColors(color)
	end
	function this:SetChildColors(fcolor,bcolor)
		if self.children and #self.children then
			for k,v in ipairs(self.children) do
				--print(string.format("B: %s PC:  b:%s f:%s CC: b:%s f:%s", self.children[k].name, self.bcolor:Details(), self.fcolor:Details(), self.children[k].bcolor:Details(), self.children[k].fcolor:Details()))
				if fcolor and v.fcolor:IsTransparent() then v.fcolor = fcolor end
				if bcolor and v.bcolor:IsTransparent() then v.bcolor = bcolor end
				--print(string.format("A: %s PC:  b:%s f:%s CC: b:%s f:%s", self.children[k].name, self.bcolor:Details(), self.fcolor:Details(), self.children[k].bcolor:Details(), self.children[k].fcolor:Details()))
			end
		end
	end
	function this:HasChanges()
		return self.dataChangedListener:HasChanges()
	end
	function this:GetDisplay()
		return self.dataChangedListener:GetDisplay()
	end
	function this:SetRenderOrder(i)
		self.dataChangedListener:SetRenderOrder(i)

		--print(self.children, self.content)

		--Update all child render orders
		if self.children and #self.children > 0 then
			for k,v in ipairs(self.children) do
				v:SetRenderOrder(k+i)
			end
		end

		if self.content then
			self.content:SetRenderOrder(self:GetRenderOrder()+i)
		end
	end
	function this:GetRenderOrder()
		return self.dataChangedListener:GetRenderOrder()
	end
	function this:GetDisplayWidth()
		return self.startpoint.x + self.drawX
	end
	function this:GetDisplayHeight()
		return self.startpoint.y + self.drawY
	end
	
	function this:DrawToScreen(gpu)
		local clearOnWrite = true
		gpu = gpu or self:GetDisplay().gpu

		--print(string.format("N:%s P:%s B:%s F:%s O:%s", self.name:sub(0,15), self.startpoint:Details(), self.bcolor:Details(), self.fcolor:Details(), self:GetRenderOrder()))
		gpu:setBackground(self.bcolor.r,self.bcolor.g,self.bcolor.b,self.bcolor.a)
		gpu:setForeground(self.fcolor.r,self.fcolor.g,self.fcolor.b,self.fcolor.a)
		gpu:fill(self.startpoint.x,self.startpoint.y,self.drawX,self.drawY, " ")
		

		if self.dataChangedListener:DisplayHasMirrors() then
			for k,v in ipairs(self.dataChangedListener:GetDisplayMirrors()) do
				--if not v then print("NOT V") end
				--if not v.screendata then print("NOT V SD") end
				v.gpu:setBackground(self.bcolor.r,self.bcolor.g,self.bcolor.b,self.bcolor.a)
				v.gpu:setForeground(self.fcolor.r,self.fcolor.g,self.fcolor.b,self.fcolor.a)
				v.gpu:fill(self.startpoint.x,self.startpoint.y,self.drawX,self.drawY, " ")

				v.gpu:flush()
			end
		end


		return clearOnWrite
	end
	function this:CheckPoint(x,y, inrange)
		if not inrange then
			if	x < self.startpoint.x or x > self.startpoint.x + self.drawX or
				y < self.startpoint.y or y > self.startpoint.y + self.drawY then
				return true
			end
		else
			if	x >= self.startpoint.x and 	x <= self.startpoint.x + self.drawX and
				y >= self.startpoint.y and y <= self.startpoint.y + self.drawY	then
				return true
			end
		end
		return false
	end

	function this:NotifyChanged()
		self.dataChangedListener.changeDetected = true
		--Writing this to log creates an indefinate loop as adding to the log adds to the change list
		--Log.Debug(string.format("Change @:%s %sx%s", self.startpoint:Details(),self.drawX,self.drawY))
		--print(string.format("Change %s @:%s %sx%s %s",self.name, self.startpoint:Details(),self.drawX,self.drawY,self.renderOnCreation))
		computer.skip()
		if self.dataChangedListener:GetDisplay() then
			self.dataChangedListener:GetDisplay().changedItemStack:AddRenderItem(self)
		end
	end
	function this:ImmediateUpdate()
		error("No Implementation in base class")
	end

	return this
end

Drawing.Point = function(d,p)
	local this = drawingbase(d,p)

	--On Creation auto add to changed items stack
	this:NotifyChanged()

	return this
end
Drawing.Line = function(d,p)
	local this = drawingbase(d,p)

	--On Creation auto add to changed items stack
	this:NotifyChanged()

	return this
end
Drawing.Rectangle = function(d,p,h,w,r,zIndex,fcolor,bcolor)
	local this = drawingbase(d,p,w,h,r,fcolor,bcolor)
	this.dataChangedListener:SetRenderOrder(zIndex)
	
	function this:ImmediateUpdate(isChildUpdateCall, bcolor,fcolor)
		local currentfcolor,currentbcolor
		if bcolor and not bcolor:Compare(self.bcolor) then 
			currentbcolor = self.bcolor 
			self:SetBackground(bcolor) 
		end

		if fcolor and not fcolor:Compare(self.fcolor) then
			currentfcolor = self.fcolor
			self:SetForeground(fcolor) 
		end

		self:DrawToScreen()

		

		--Iterate children and post
		if self.children and #self.children > 0 then
			for k,v in Utils.table.spairs(self.children, function(t,a,b) return t[b].dataChangedListener.renderorder > t[a].dataChangedListener.renderorder end) do
				v:ImmediateUpdate(true, bcolor, fcolor)
			end
		end

		--Handle content property
		if self.content then
			self.content:ImmediateUpdate(true,bcolor,fcolor)
		end

		if not isChildUpdateCall or isChildUpdateCall == false then
			self:GetDisplay().gpu:flush()
		end

		--Reset to Original color
		if currentbcolor then
			self:SetBackground(currentbcolor)
		end
		if currentfcolor then
			self:SetForeground(currentfcolor)
		end
	end
	function this:MouseEnter(...)
		local x = select(1,...)
		local y = select(2,...)
		if self:CheckPoint(x,y,true)	then
			self.mouseListeners.isMouseOver = true
		end
	end
	function this:MouseLeave(...)
		local x = select(1,...)
		local y = select(2,...)
		if self:CheckPoint(x,y,false) then
			self.mouseListeners.isMouseOver = false
		end
	end
	function this:LeftClick(color)
		self:GetDisplay():SetDisplayPage(self.leftclickPg)
		self:ImmediateUpdate(false, color)
		self.mouseListeners.isRightClicked = false;
	end
	function this:RightClick(color)
		self:GetDisplay():SetDisplayPage(self.rtclickPg)
		self:ImmediateUpdate(false, color)
		self.mouseListeners.isLeftClicked = false;
	end
	function this:Click(lfunc, rfunc,...)
		local x = select(1,...)
		local y = select(2,...)
		local bitField = select(3,...)
		local isClicked = self:CheckPoint(x,y,true)

		--L/R Click same nav tab doesn't change'-----------------------HERE 

		--Check the bit field for the L or R Click
		if bitField & 1 > 0 then
			-- left mouse pressed			
			if self.mouseListeners.isLeftClicked ~= isClicked then
				self.mouseListeners.isLeftClicked = isClicked
				if lfunc then lfunc(self) end
			end

		elseif bitField & 2 > 0 then
			-- right mouse pressed
			if self.mouseListeners.isRightClicked ~= isClicked then
				self.mouseListeners.isRightClicked = isClicked
				if rfunc then rfunc(self) end
			end
		end
	end

	--On Creation auto add to changed items stack if property not Set
	if this.renderOnCreation == nil or this.renderOnCreation == true then		--False gets by this.....
		this:NotifyChanged()
	end
	computer.skip()
	
	return this
end
Drawing.Text = function(d,p,t,talign,mxlen,r, fcolor, bcolor)
	local this = drawingbase(d,p,mxlen,1,r,fcolor,bcolor,r)
	this.text = t
	this.continuousText = false

	if talign then this.textalign = talign:upper() end

	--Base Overwrite "Methods"
	--Text needs to overwrite base fn
	function this:DrawToScreen(gpu)
		local text = ""
		local writeX = self.startpoint.x
		local writeY = self.startpoint.y
		gpu = gpu or self:GetDisplay().gpu

		if type(self.text) == "function" then 
			text = self.text()
		else 
			text = self.text
		end

		--Set the Y Max if Y is greater then parent height
		if self.parent then
			if writeY > self.parent:GetDisplayHeight() then
				writeY = self.parent:GetDisplayHeight()
			end
		end

		--Handle if need to multi-line the text based on parent (wrap/no wrap) and the drawX v textlen



		--Handle Text Alignment if center or right alignment
		if self.textalign and self.drawX > text:len() then
			if self.textalign == "CENTER" then
				--print(string.format("%s + (%s - %s) = %s",writeX, math.floor(self.drawX/2), math.floor(text:len()/2),writeX + (math.floor(self.drawX/2) - math.floor(text:len()/2))))
				writeX = writeX + (math.floor(self.drawX/2) - math.floor(text:len()/2))	-- 1 + 25/2 - 13/2  = 1+12-6 = 7
			elseif self.textalign == "RIGHT" then
				writeX = writeX + (self.drawX - text:len())
			end
		end

		if not self.fcolor then self:SetForeground(UI.SysColors.Warning) end

		gpu:setBackground(self.bcolor.r,self.bcolor.g,self.bcolor.b,self.bcolor.a)
		gpu:setForeground(self.fcolor.r,self.fcolor.g,self.fcolor.b,self.fcolor.a)
		gpu:setText(writeX,writeY,text)

		if self.dataChangedListener:DisplayHasMirrors() then
			for k,v in ipairs(self.dataChangedListener:GetDisplayMirrors()) do
				v.gpu:setBackground(self.bcolor.r,self.bcolor.g,self.bcolor.b,self.bcolor.a)
				v.gpu:setForeground(self.fcolor.r,self.fcolor.g,self.fcolor.b,self.fcolor.a)
				v.gpu:setText(writeX,writeY,text)
				v.gpu:flush()
			end
		end

		--return clearOnWrite
		return not this.continuousText
	end
	function this:ImmediateUpdate(isChildUpdateCall, bcolor,fcolor)
		local currentfcolor,currentbcolor
		if bcolor and not bcolor:Compare(self.bcolor) then 
			currentbcolor = self.bcolor 
			self:SetBackground(bcolor) 
		end

		if fcolor and not fcolor:Compare(self.fcolor) then
			currentfcolor = self.fcolor
			self:SetForeground(fcolor) 
		end

		self:DrawToScreen()

		if not isChildUpdateCall or isChildUpdateCall == false then
			self:GetDisplay().gpu:flush()
		end

		--Reset to Original color
		if currentbcolor then
			self:SetBackground(currentbcolor)
		end
		if currentfcolor then
			self:SetForeground(currentfcolor)
		end
	end

	--On Creation auto add to changed items stack if property not Set
	if this.renderOnCreation == nil or this.renderOnCreation == true then
		this:NotifyChanged()
	end
	computer.skip()
	return this
end

