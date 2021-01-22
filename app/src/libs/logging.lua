require "libs.utils"
require "libs.sysTime"
require "kernel.ui"

local messagetypes = {
	Debug = "DBG",
	Information = "INFO",
	Warning = "WARN",
	Error = "ERR"
}

local function message(msg, mtype)
	local this = {
		timestamp = SysTime:GetTick(),
		message = msg,
		messageType = mtype or messagetypes.Information,
		messageColor = UI.SysColors.Write
	}

	function this:WriteMessage(arg)
		local msg = self.message

		if type(self.message) == "function" then
			msg = self.message(arg)
		end
		--print("Msg:",string.format("%s\t%s\t%s",SysConfig.Time:DisplayTime(false),self.messageType,msg))
		return string.format("%s\t%s\t%s",SysConfig.Time:DisplayTime(false),self.messageType,msg)
	end
	function this:MessageColor()
		if self.messageType == messagetypes.Debug then self.messageColor = UI.SysColors.Debug
		elseif self.messageType == messagetypes.Warning then self.messageColor = UI.SysColors.Warning
		elseif self.messageType == messagetypes.Error then self.messageColor = UI.SysColors.Error 
		end
	end

	--Update the message color after the type has been set
	this:MessageColor()

	return this
end


Log = {
	messages = {},
	errors = {},
	message_grid = nil
}


--HACK FOR THE MOMENT
line = 1;
function Log.WriteOutput(msg, arg)
	--print("Msg: ", msg.messageType, msg.message)
	
	
	--Write the log
	if SysConfig.Display_Manager then
		if SysConfig.Display_Manager.enabled and SysConfig.Display_Manager.execute then
			
			if not Log.message_grid then
				--Log.message_grid = SysConfig.Display_Manager.execute.Desktop:GetGridByName("grd_runningLog")
			end
			if Log.message_grid then
				Log.message_grid:AddChild(UI.Components.TextBlock(	Log.message_grid:GetDisplay(),
																	UI.Components.Point(Log.message_grid.startpoint.x, Log.message_grid.startpoint.y + line),
																	msg:WriteMessage(arg),
																	{	
																		textcolor = msg.messageColor,
																		continuousText = false
																	}
																))
				line = line + 1
			end
		end
	else
		print(string.format("%s: %s", msg.messageType, msg.message))
	end

end

function Log.Debug(msg,arg)
	if SysConfig.Debug then
		local m = message(msg,messagetypes.Debug)
		table.insert(Log.messages,m)
		Log.WriteOutput(m,arg)
	end
end
function Log.Information(msg)
	local m = message(msg,messagetypes.Information)
	table.insert(Log.messages,m)
	Log.WriteOutput(m)
end
function Log.Warning(msg)
	local m = message(msg,messagetypes.Warning)
	table.insert(Log.messages,m)
	Log.WriteOutput(m)
end
function Log.Error(msg)
	local m = message(msg,messagetypes.Error)
	table.insert(Log.messages,m)
	Log.WriteOutput(m)
end