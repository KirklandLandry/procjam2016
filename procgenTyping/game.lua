
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







function loadGame()
	gameState = GAME_STATES.title

	

	newKeyboard()
	currentWordTimer = Timer:new(13, TimerModes.single)
	
	initBackground()

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

