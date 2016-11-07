Timer = {timerValue = 0, timerMax = 0, mode = nil}
TimerModes = {repeating = "repeating", single = "single"}

function Timer:new(timerMax, mode)	
	assert((mode == TimerModes.repeating or mode == TimerModes.single) and timerMax >= 0, 
	"incorrect timer initialization (check that you sent a valid TimerMode and timerMax is > 0)")
	
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.timerValue = 0
	o.timerMax = timerMax
	o.mode = mode or TimerModes.single
	return o
end
 
function Timer:isComplete(dt)
	self.timerValue = self.timerValue + dt 
	if self.timerValue >= self.timerMax then 
		if self.mode == TimerModes.single then 
			self.timerValue = self.timerMax
		elseif self.mode == TimerModes.repeating then 
			self.timerValue = 0 
		end
		return true
	end
	return false
end

function Timer:reset()
	self.timerValue = 0
end