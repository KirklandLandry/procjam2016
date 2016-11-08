Queue = {}
function Queue:new ()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.first = 0
	o.last = -1
	return o
end
-- enqueue / pushright
function Queue:enqueue (value)
	local last = self.last + 1
	self.last = last
	self[last] = value
end

--dequeue / popleft
function Queue:dequeue ()
	local first = self.first
	if first > self.last then error("list is empty") end
	local value = self[first]
	self[first] = nil        -- to allow garbage collection
	self.first = first + 1
	return value
end

function Queue:isEmpty()
	if self.first > self.last then 
		return true
	end
	return false
end

function Queue:length()
	return self.last - self.first + 1
end 