
local scrollingQueues = {
	floorTiles = nil,
	pillars = nil,
	pillarsParallax = nil
}

local enemyList = nil

local enemySpawnTimer = nil 

local pillarSpawnChance = 87
local parralaxPillarSpawnChance = 85

local backgroundTileset = nil 
local backgroundTilesetQuads = nil


function newScrollingElement(_x, _y, _tileIndex)
	return {
		x = _x, 
		y = _y,
		tileIndex = _tileIndex,
		r = 255,
		g = 255,
		b = 255,
		scrollmodifier = 1 -- for different scroll speeds. 
	}
end

function addPillar(scrollMod)
	local val = math.random(15, 130)
	for i=1,8 do 
		local temp = newScrollingElement(screenWidth, (i-1)*32, 1)
		temp.scrollmodifier = scrollMod or 1
		if scrollMod then 
			temp.r = val
			temp.g = val
			temp.b = val
			scrollingQueues.pillarsParallax:enqueue(temp)
		else 
			scrollingQueues.pillars:enqueue(temp)
		end 
	end 
end

function newEnemy()
	return {
		x = screenWidth,
		y = floorY - tileSize,
		width = tileSize,
		height = tileSize,
		health = 25,
		maxHealth = 25,
		baseAttack = 1,
		attackRange = 2
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
	scrollingQueues.pillarsParallax = Queue:new()

	scrollingQueues.floorTiles = Queue:new()
	enemyList = Queue:new()

	enemySpawnTimer = Timer:new(math.random(1,3), TimerModes.single)

	for i=1,(screenWidth/tileSize) + 2 do
		scrollingQueues.floorTiles:enqueue(newScrollingElement((i-1)*tileSize, floorY, math.random(1,3)))
	end
end 

function updateBackground(dt, scrollSpeed)
	local frameScrollAmount = math.floor(scrollSpeed)

	if enemySpawnTimer:isComplete(dt) then 
		enemyList:enqueue(newEnemy())
		enemySpawnTimer.timerMax = math.random(2, 7)
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
			if math.random(0,100) > pillarSpawnChance then 
				addPillar()
			end 
			if math.random(0,100) > parralaxPillarSpawnChance then 
				addPillar(math.random(40,70)/100)
			end 
		end 
	end

	-- update enemy positions 
	for i=enemyList:getLast(),enemyList:getFirst(),-1 do
		enemyList:elementAt(i).x = enemyList:elementAt(i).x - frameScrollAmount
	end

	-- update background pillars
	-- currently not being removed if it goes off screen (bad!)
	-- low priority for now, fix later
	for i=scrollingQueues.pillars:getLast(),scrollingQueues.pillars:getFirst(),-1 do
		scrollingQueues.pillars:elementAt(i).x = scrollingQueues.pillars:elementAt(i).x - (frameScrollAmount * scrollingQueues.pillars:elementAt(i).scrollmodifier)
	end

	for i=scrollingQueues.pillarsParallax:getLast(),scrollingQueues.pillarsParallax:getFirst(),-1 do
		scrollingQueues.pillarsParallax:elementAt(i).x = scrollingQueues.pillarsParallax:elementAt(i).x - (frameScrollAmount * scrollingQueues.pillarsParallax:elementAt(i).scrollmodifier)
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

	for i=scrollingQueues.pillarsParallax:getLast(),scrollingQueues.pillarsParallax:getFirst(),-1 do
		local temp = scrollingQueues.pillarsParallax:elementAt(i)
		love.graphics.setColor(temp.r, temp.g, temp.b)
		love.graphics.draw(backgroundTileset, backgroundTilesetQuads.pillar, temp.x, temp.y)
	end

	for i=scrollingQueues.pillars:getLast(),scrollingQueues.pillars:getFirst(),-1 do
		resetColor()	
		love.graphics.draw(backgroundTileset, backgroundTilesetQuads.pillar, scrollingQueues.pillars:elementAt(i).x, scrollingQueues.pillars:elementAt(i).y)
	end

	resetColor()	

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

function currentEnemyMaxHealth()
	return enemyList:peek().maxHealth
end 

function currentEnemyGetAttackDamage()
	return math.random(enemyList:peek().baseAttack, enemyList:peek().baseAttack + enemyList:peek().attackRange)
end 

function decreaseCurrentEnemyHealth(amount)
	assert(type(amount) == "number", "decreaseCurrentEnemyHealth expects a number")
	enemyList:peek().health = enemyList:peek().health - amount
end 

function removeEnemy()
	enemyList:dequeue()
end 