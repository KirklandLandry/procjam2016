Queue = {}
function Queue:new ()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.first = 1
	o.last = 0
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

function Queue:elementAt(index)
	return self[index]
end

function Queue:peek()
	return self[self.first]
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