
local scrollingQueues = {
	floorTiles = nil,
	pillars = nil
}

local enemyList = nil

local enemySpawnTimer = nil 


local backgroundTileset = nil 
local backgroundTilesetQuads = nil


function newScrollingElement(_x, _y, _tileIndex)
	return {
		x = _x, 
		y = _y,
		tileIndex = _tileIndex
	}
end

function addPillar()
	for i=1,8 do 
		scrollingQueues.pillars:enqueue(newScrollingElement(screenWidth, (i-1)*32, 1))
	end 
end

function newEnemy()
	return {
		x = screenWidth,
		y = floorY - tileSize,
		width = tileSize,
		height = tileSize,
		health = 25
	}
end 

function initBackground()

	-- http://opengameart.org/content/32x32-black-and-white-platformer-tiles
	backgroundTileset = love.graphics.newImage("assets/sprites/32x32backgroundTiles.png")
	backgroundTileset:setFilter("nearest", "nearest")

	local backgroundTilesetWidth = backgroundTileset:getWidth()
	local backgroundTilesetHeight = backgroundTileset:getHeight()

	print(backgroundTilesetWidth, backgroundTilesetHeight)

	backgroundTilesetQuads = {}
	backgroundTilesetQuads.floor = {}
	
	backgroundTilesetQuads.pillar = love.graphics.newQuad(32, 64, 32, 32, backgroundTilesetWidth, backgroundTilesetHeight)	

	for i=1,3 do
		backgroundTilesetQuads.floor[i] = love.graphics.newQuad((i-1)*32, 96, 32, 32, backgroundTilesetWidth, backgroundTilesetHeight)	
	end
	
	scrollingQueues.pillars = Queue:new()


	scrollingQueues.floorTiles = Queue:new()
	enemyList = Queue:new()

	enemySpawnTimer = Timer:new(1, TimerModes.single)

	for i=1,(screenWidth/tileSize) + 2 do
		scrollingQueues.floorTiles:enqueue(newScrollingElement((i-1)*tileSize, floorY, math.random(1,3)))
	end
end 

function updateBackground(dt, scrollSpeed)
	local frameScrollAmount = math.floor(scrollSpeed)


	if enemySpawnTimer:isComplete(dt) then 
		enemyList:enqueue(newEnemy())
		enemySpawnTimer.timerMax = math.random(2, 4)
		enemySpawnTimer:reset()
	end 

	-- scroll the floor tiles. always ensure the legnth stays the same 
	local length = scrollingQueues.floorTiles:length()
	for i=1,length do
		local temp = scrollingQueues.floorTiles:dequeue()
		temp.x = temp.x - frameScrollAmount 
		if temp.x > -tileSize then 
			-- keep drawing the element by re-enqueueing it
			scrollingQueues.floorTiles:enqueue(temp)
		else 
			-- don't re-enqueue the old tile, add a new one 
			scrollingQueues.floorTiles:enqueue(newScrollingElement((length*tileSize) + temp.x, floorY, math.random(1,3)))
			-- maybe add a pillar?
			if math.random(0,100) > 87 then 
				addPillar()
			end 
		end 
	end

	-- update enemy positions 
	for i=enemyList:getLast(),enemyList:getFirst(),-1 do
		enemyList:elementAt(i).x = enemyList:elementAt(i).x - frameScrollAmount
	end

	-- update background pillars

	for i=scrollingQueues.pillars:getLast(),scrollingQueues.pillars:getFirst(),-1 do
		scrollingQueues.pillars:elementAt(i).x = scrollingQueues.pillars:elementAt(i).x - frameScrollAmount
	end

end 

function drawBackground()
	-- draw the floor tiles 
	local length = scrollingQueues.floorTiles:length()
	for i=1,length do
		local temp = scrollingQueues.floorTiles:dequeue()
		love.graphics.draw(backgroundTileset, backgroundTilesetQuads.floor[temp.tileIndex], temp.x, temp.y)
		scrollingQueues.floorTiles:enqueue(temp)
	end

	for i=scrollingQueues.pillars:getLast(),scrollingQueues.pillars:getFirst(),-1 do
		--scrollingQueues.pillars:elementAt(i).x = scrollingQueues.pillars:elementAt(i).x - frameScrollAmount
		love.graphics.draw(backgroundTileset, backgroundTilesetQuads.pillar, scrollingQueues.pillars:elementAt(i).x, scrollingQueues.pillars:elementAt(i).y)
	end

	drawEnemies()
end 

function drawEnemies()
	for i=enemyList:getLast(),enemyList:getFirst(),-1 do
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

function removeEnemy()
	enemyList:dequeue()
end 