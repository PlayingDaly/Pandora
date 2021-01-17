require "sysTime"

--Timer ticks are linked to sysTime
function Timer(h,)
	local this = {
		tick = 0,	
		stopTime = 0,			--How Long in milliseconds
		isRunning = false		
	}

	function this:SetInterval(i)
		if i ~= 0 then 
			self.interval_amt = i
			self.interval = true
		end
	end
	function this:Start()
		self.isRunning = true
	end
	function this:Stop()
		self.isRunning = false
	end
	function this:Elapsed()
		return self.tick
	end
	function this:Running()
		if self.isRunning then
			self.tick = SysTime.ms

			if self.stopTime = -1 then
				return false
			elseif self.tick > self.stopTime then
				self:Stop()
				return true
			end
		else
			return false
		end
	end

	return this
end