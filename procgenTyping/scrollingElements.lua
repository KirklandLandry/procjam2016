local scrollingQueues = {
	floorTiles = nil 
}


function newScrollingElement(_x, _y)
	return {
		x = _x, 
		y = _y,
		r = math.random(10, 255),
		g = math.random(10, 255),
		b = math.random(10, 255)
	}
end


function initBackground()
	scrollingQueues.floorTiles = Queue:new()

	for i=1,(screenWidth/tileSize) + 1 do
		scrollingQueues.floorTiles:enqueue(newScrollingElement((i-1)*tileSize, floorY))
	end
end 

function updateBackground(dt)
	local frameScrollAmount = math.floor(90 * dt)


	-- scroll the floor tiles. always ensure the legnth stays the same 
	local length = scrollingQueues.floorTiles:length()
	for i=1,length do
		local temp = scrollingQueues.floorTiles:dequeue()
		temp.x = temp.x - frameScrollAmount 
		if temp.x > -tileSize then 
			scrollingQueues.floorTiles:enqueue(temp)
		else 
			scrollingQueues.floorTiles:enqueue(newScrollingElement((length*tileSize) + temp.x,floorY))
		end 
	end

end 

function drawBackground()
	-- draw the floor tiles 
	local length = scrollingQueues.floorTiles:length()
	for i=1,length do
		local temp = scrollingQueues.floorTiles:dequeue()
		love.graphics.setColor(temp.r, temp.g, temp.b)
		love.graphics.rectangle("fill", temp.x, temp.y, tileSize, tileSize)
		scrollingQueues.floorTiles:enqueue(temp)
	end

end 