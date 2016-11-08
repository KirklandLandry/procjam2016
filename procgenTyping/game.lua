
-- parallel universe typing simulator 2016
-- or "keyboard warrior"

-- TODO 
-- make it so that you only use half of the keyboard 
-- disable keys that aren't being used 
-- make it so that in each string you only hit a key once 
-- key lights up once it's been hit 
-- add a bar that fills up as you complete the word 

-- the game will be like a 2D shootout type of thing 
-- all particle effects will be gravity applied 
-- when you get hit the damage number flies off you like a particle

-- maybe have a set of letters 
-- try to type as many as you can in the given time 
-- more letters typed means a stronger attack 

local GAME_STATES = {battle = "battle", walking = "walking", paused = "paused", title = "title"}
local BATTLE_STATES = {attacking = "attacking", blocking = "blocking"}

local gameState = GAME_STATES.title


local currentWord = "attack"
local currentWordIndex = 1

local currentWordTimer = 0

local floorY = 0

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


function loadGame()
	gameState = GAME_STATES.title

	floorY = screenHeight - tileSize 

	newKeyboard()
	currentWordTimer = Timer:new(13, TimerModes.single)
	
	scrollingQueues.floorTiles = Queue:new()

	for i=1,(screenWidth/tileSize) + 1 do
		scrollingQueues.floorTiles:enqueue(newScrollingElement((i-1)*tileSize, floorY))
	end

end


function updateGame(dt)	
	if getKeyDown("tab") then 
		newKeyboard()
	end 
	
	if currentWordTimer:isComplete(dt) then 
		--love.event.quit()
	end 

	updateBackground(dt)

	
	if getKeyDown(swappedToKeyMap[currentWord:sub(currentWordIndex,currentWordIndex)]) then 
		currentWordIndex = currentWordIndex + 1 
		if currentWordIndex > #currentWord then 
			currentWordIndex = 1
			keys = {}
			newKeyboard()
			currentWordTimer = Timer:new(13, TimerModes.single)
		end 
	end 
end



function drawGame()
	--love.graphics.scale(2)

	drawBackground()


	local counter = 1
	for c in currentWord:gmatch"." do
		if currentWordIndex <= counter then 
			love.graphics.setColor(0, 255, 0)
		else 
			love.graphics.setColor(255, 100, 0)
		end 
		love.graphics.print(c, 50 + (counter * 10), 50)
		counter = counter + 1
	end


	drawKeyboard(100, 100)


	local timerPercentComplete = currentWordTimer.timerValue / currentWordTimer.timerMax
	
	love.graphics.rectangle("line", 10, 10, 100, 20)
	love.graphics.rectangle("fill", 10, 10, 100 - (100 * timerPercentComplete), 20)
	
end


function updateBackground(dt)
	local frameScrollAmount = 90 * dt


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