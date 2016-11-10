
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

local gameState = nil


local currentWord = "attack"
local currentWordIndex = 1

local currentWordTimer = nil

local player = nil 

local particleList = {} 

local gravity = 22

-- the text is optional 
-- will create normal particle otherwise 
function newParticle(_x, _y, _vx, _vy, _lifespan, text)
	return {
		x = _x, 
		y = _y, 
		vx = _vx,
		vy = _vy,
		lifespan = _lifespan,
		alpha = 255,
		e = math.random(0.8, 0.83) -- elasticity 
	}
end 

function loadGame()
	gameState = Stack:new()
	gameState:push(GAME_STATES.title)

	newKeyboard()
	currentWordTimer = Timer:new(13, TimerModes.single)
	
	initBackground()

	player = {
		x = -tileSize, 
		y = floorY - tileSize,
		width = tileSize,
		height = tileSize,
		r = math.random(22, 255),
		g = math.random(22, 255),
		b = math.random(22, 255)
	}
end

-- BASE UPDATE 
function updateGame(dt)	

	print(gameState:peek())

	if getKeyPress("escape") then 
		love.event.quit()
		if gameState:peek() == GAME_STATES.paused then 
			gameState:pop()	
		else 
			gameState:push(GAME_STATES.paused)
		end 
	end 

	if gameState:peek() == GAME_STATES.title then 
		updateTitle(dt)
	elseif gameState:peek() == GAME_STATES.walking then 
		updateWalking(dt)
	elseif gameState:peek() == GAME_STATES.battle then 
		updateBattle(dt)
	elseif gameState:peek() == GAME_STATES.paused then 
		updatePaused(dt)
	end 
end

function updateTitle(dt)
	if getKeyDown("r") then 
		gameState:push(GAME_STATES.walking)
	end 
end 

function updateWalking(dt)
	updateBackground(dt, math.floor(200 * dt))
	if player.x < tileSize * 5 then 
		--player.x = player.x + dt * 80 
		player.x = player.x + (((tileSize*5) - player.x ) * 0.07)
	end 

	-- if an enemy is 4 tiles away then switch to battle mode
	if enemyWithinRange(player.x, screenWidth * 0.6 ) then 
		gameState:push(GAME_STATES.battle)
	end
end 

local hit = false

function updateBattle(dt)
	if currentWordTimer:isComplete(dt) then 
		--love.event.quit()
	end 

	-- check if the current letter in the current word was typed 
	if letterInWordPressed(currentWord, currentWordIndex) then 
		currentWordIndex = currentWordIndex + 1 
		-- if the whole word was typed ...
		if currentWordIndex > #currentWord then 
			currentWordIndex = 1
			keys = {}
			newKeyboard()
			currentWordTimer = Timer:new(13, TimerModes.single)
		end 
	end 

	if not hit  then 
		for i=1,40 do
			table.insert(particleList, newParticle(player.x, player.y, math.random(-10, -200), math.random(-250, -550), 3))
		end

		
		hit = true 
	end 
	updateParticles(dt)
end 

function updatePaused(dt)

end 

-- BASE DRAW 
function drawGame()
	love.graphics.setColor(255,255,255)
	if gameState:peek() == GAME_STATES.title then 
		drawTitle()
	elseif gameState:peek() == GAME_STATES.walking then 
		drawWalking()
	elseif gameState:peek() == GAME_STATES.battle then 
		drawBattle()
	elseif gameState:peek() == GAME_STATES.paused then 
		drawPaused()
	end 
end

function drawTitle()
	love.graphics.print("press r to start", screenWidth/2, screenHeight/2)
end 

function drawWalking()
	drawBackground()
	drawPlayer()
end 

function drawBattle()
	drawBackground()
	drawPlayer()
	drawWord(currentWord, currentWordIndex, 50, 50)
	drawKeyboard(100, 100)
	currentWordTimer:draw(10, 10, 100, 20)
	drawParticles()
end 


function drawPaused()
	love.graphics.print("game paused", screenWidth/2, screenHeight/2)
end 


function drawPlayer()
	love.graphics.setColor(player.r, player.g, player.b)
	love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end 

-- not super sure where to stick this 
-- it draws a word based on how much of the word has been typed 
function drawWord(wordToDraw, lettersTyped, x, y)
	local counter = 1
	for c in wordToDraw:gmatch"." do
		if lettersTyped <= counter then 
			love.graphics.setColor(0, 255, 0)
		else 
			love.graphics.setColor(255, 100, 0)
		end 
		-- need to change this to sprite -> 10 becomes tileSize
		love.graphics.print(c, x + (counter * 10), y)
		counter = counter + 1
	end
end 



function love.focus(f)
	if not f then
		gameState:push(GAME_STATES.paused)
	elseif gameState:peek() == GAME_STATES.paused then 
		gameState:pop() 
	end
end

function updateParticles(dt)
	for i=#particleList,1,-1 do
		particleList[i].x = particleList[i].x + (particleList[i].vx * dt)
		
		particleList[i].vy = (particleList[i].vy + gravity) 
		particleList[i].y = particleList[i].y + (particleList[i].vy * dt)

		if particleList[i].y > floorY then 
			particleList[i].alpha = particleList[i].alpha* 0.75
			particleList[i].y = floorY
			particleList[i].vy = -particleList[i].vy * particleList[i].e
		end

		if particleList[i].alpha < 0 or particleList[i].lifespan <= 0 then 
			table.remove(particleList, i)
		else 
			particleList[i].lifespan = particleList[i].lifespan - dt
		end
	end
end

function drawParticles()
	for i=1,#particleList do
		love.graphics.setColor(255, 255, 255, particleList[i].alpha)
		love.graphics.circle("fill",particleList[i].x, particleList[i].y, 5) 
	end
end