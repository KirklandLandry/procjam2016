
local scrollingQueues = {
	floorTiles = nil 
}

local enemyList = nil

local enemySpawnTimer = nil 

function newScrollingElement(_x, _y)
	return {
		x = _x, 
		y = _y,
		r = math.random(10, 255),
		g = math.random(10, 255),
		b = math.random(10, 255)
	}
end

function newEnemy()
	return {
		x = screenWidth,
		y = floorY - tileSize,
		width = tileSize,
		height = tileSize,
		r = math.random(10, 255),
		g = math.random(10, 255),
		b = math.random(10, 255),
		health = 25
	}
end 

function initBackground()
	scrollingQueues.floorTiles = Queue:new()
	enemyList = Queue:new()

	enemySpawnTimer = Timer:new(1, TimerModes.repeating)

	for i=1,(screenWidth/tileSize) + 2 do
		scrollingQueues.floorTiles:enqueue(newScrollingElement((i-1)*tileSize, floorY))
	end
end 

function updateBackground(dt, scrollSpeed)
	local frameScrollAmount = math.floor(scrollSpeed)


	if enemySpawnTimer:isComplete(dt) then 
		enemyList:enqueue(newEnemy())
	end 

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

	for i=1,enemyList:length() do
		enemyList:elementAt(i).x = enemyList:elementAt(i).x - frameScrollAmount
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
	drawEnemies()
end 

function drawEnemies()
	for i=1,enemyList:length() do
		love.graphics.setColor(enemyList:elementAt(i).r, enemyList:elementAt(i).g, enemyList:elementAt(i).b)
		love.graphics.rectangle("fill", enemyList:elementAt(i).x, enemyList:elementAt(i).y, enemyList:elementAt(i).width, enemyList:elementAt(i).height)
	end
end 

function enemyWithinRange(playerX, maxDistance)
	if enemyList:length() > 0 and math.sqrt(math.pow(enemyList:peek().x, 2) - math.pow(playerX,2)) < maxDistance then
		return true 
	else 
		return false 
	end
end

function currentEnemyPosition()
	return {x = enemyList:peek().x, y = enemyList:peek().y}
end 

function currentEnemyHealth()
	return enemyList:peek().health
end 

function decreaseCurrentEnemyHealth(amount)
	assert(type(amount) == "number", "decreaseCurrentEnemyHealth expects a number")
	enemyList:peek().health = enemyList:peek().health - amount
end 