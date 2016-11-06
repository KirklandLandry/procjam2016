local min_dt = 0	
local next_time = 0

function loadFramerateLock(fps)
	-- for locking the framerate
	-- min_dt will be the maximum framerate value. 60fps by default
	min_dt = fps or 1/60	
	next_time = love.timer.getTime()
end

function updateFramerateLock()
	-- for locking the framerate. must be the first thing in udpate.
	next_time = next_time + min_dt
end

function drawFramerateLock(doPrint)
	-- print fps
	if doPrint then love.graphics.print(tostring(love.timer.getFPS()), 0, 0) end 
	
	
	-- for locking the framerate. must be the last thing in draw.
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then -- met or passed dt
		next_time = cur_time 
		return
	end 
	love.timer.sleep(next_time - cur_time) -- sleep until the next frame
end