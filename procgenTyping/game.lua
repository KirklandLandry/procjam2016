
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
local win = false 

local currentWordTimer = 0

local tileSize = 32

local scrollingQueues = {
	floorTiles = nil 
}



function loadGame()
	newKeyboard()
	currentWordTimer = Timer:new(13, TimerModes.single)
	
	scrollingQueues.floorTiles = Queue:new()
end


function updateGame(dt)	
	if getKeyDown("tab") then 
		newKeyboard()
	end 

	
	if currentWordTimer:isComplete(dt) then 
		love.event.quit()
	end 
	
	if not win and getKeyDown(swappedToKeyMap[currentWord:sub(currentWordIndex,currentWordIndex)]) then 
		currentWordIndex = currentWordIndex + 1 
		if currentWordIndex > #currentWord then 
			--win = true 
			--getKeyPress(swappedToKeyMap[currentWord:sub(currentWordIndex,currentWordIndex)])
			currentWordIndex = 1
			keys = {}
			newKeyboard()
			currentWordTimer = Timer:new(13, TimerModes.single)
		end 
	end 
end

function colourSet(character)
	if getKeyDown(character) then 
		love.graphics.setColor(255, 0, 0)
	else 
		love.graphics.setColor(255, 255, 255)
	end 
end 


function drawKey(character, x, y, keyboardTopLeft)	
	love.graphics.setColor(0, 0, 200)
	love.graphics.rectangle("fill", keyboardTopLeft.x + (20 * x) + (5*y), keyboardTopLeft.y + (20 * y), 20, 20)
	love.graphics.setColor(0, 0, 150)
	love.graphics.rectangle("line", keyboardTopLeft.x + (20 * x) + (5*y), keyboardTopLeft.y + (20 * y), 20, 20)
	colourSet(character)
	love.graphics.print(keyToSwappedMap[character], keyboardTopLeft.x + (20 * x) + (5*y) + 5, keyboardTopLeft.y + (20 * y) + 5)	
end 

function drawKeyboard(_x, _y)
	local keyboardTopLeft = { x = _x, y = _y }

	local counter = 0
	for c in topRow:gmatch"." do
		drawKey(c, counter, 0, keyboardTopLeft)
		counter = counter + 1
	end

	counter = 0
	for c in secondRow:gmatch"." do
		drawKey(c, counter, 1, keyboardTopLeft)
		counter = counter + 1
	end
	
	counter = 0
	for c in thirdRow:gmatch"." do
		drawKey(c,  counter, 2, keyboardTopLeft)
		counter = counter + 1
	end
end 

function drawGame()
	--love.graphics.scale(2)

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
	
	--[[love.graphics.origin()
	love.graphics.push()
		love.graphics.scale(camera.scale)		
		love.graphics.translate((-camera.x), (-camera.y))	
	love.graphics.pop()]]
end


