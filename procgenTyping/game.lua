
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
local battleState = nil

local currentWord = "attack"
local currentWordIndex = 1

local currentWordTimer = nil

local player = nil 

local particleList = {} 

local gravity = 22

-- the text is optional 
-- will create normal particle otherwise 
function newParticle(_x, _y, _vx, _vy, _lifespan, _text)
	return {
		x = _x, 
		y = _y, 
		vx = _vx,
		vy = _vy,
		lifespan = _lifespan,
		alpha = 255,
		e = math.random(0.8, 0.83), -- elasticity 
		text = _text or nil
	}
end 

function loadGame()
	gameState = Stack:new()
	gameState:push(GAME_STATES.title)

	newKeyboard()
	currentWordTimer = Timer:new(7, TimerModes.single)
	
	initBackground()

	player = {
		x = -tileSize, 
		y = floorY - tileSize,
		width = tileSize,
		height = tileSize,
		r = math.random(22, 255),
		g = math.random(22, 255),
		b = math.random(22, 255),
		baseAttack = 3
	}
end

-- BASE UPDATE 
function updateGame(dt)	

	--print(gameState:peek())
	local frameScroll = 0

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
		frameScroll = math.floor(200 * dt)
		updateWalking(dt, frameScroll)
		updateParticles(dt, frameScroll)
	elseif gameState:peek() == GAME_STATES.battle then 
		updateBattle(dt)
		updateParticles(dt, frameScroll)
	elseif gameState:peek() == GAME_STATES.paused then 
		updatePaused(dt)
	end 
end

function updateTitle(dt)
	if getKeyDown("r") then 
		gameState:push(GAME_STATES.walking)
	end 
end 

function updateWalking(dt, frameScroll)
	updateBackground(dt, frameScroll)
	if player.x < tileSize * 5 then 
		--player.x = player.x + dt * 80 
		player.x = player.x + (((tileSize*5) - player.x ) * 0.07)
	end 

	-- if an enemy is 4 tiles away then switch to battle mode
	if enemyWithinRange(player.x, screenWidth * 0.6 ) then 
		battleState = BATTLE_STATES.attacking
		gameState:push(GAME_STATES.battle)
	end
end 

local hit = false

function updateBattle(dt)
	if currentWordTimer:isComplete(dt) then 
		--love.event.quit()
		if battleState == BATTLE_STATES.attacking then 
			battleState = BATTLE_STATES.blocking
		elseif battleState == BATTLE_STATES.blocking then 
			battleState = BATTLE_STATES.attacking
		end 
		newKeyboard()
		currentWordTimer = Timer:new(7, TimerModes.single)
	end 

	-- check if the current letter in the current word was typed 
	if letterInWordPressed(currentWord, currentWordIndex) then 
		currentWordIndex = currentWordIndex + 1 

		local hitDamage = math.random(player.baseAttack, player.baseAttack + 4)
		table.insert(particleList, newParticle(currentEnemyPosition().x, currentEnemyPosition().y, math.random(100, 200), math.random(-250, -550), 3, tostring(hitDamage)))
		decreaseCurrentEnemyHealth(hitDamage)
		if currentEnemyHealth() <= 0 then 
			gameState:pop()
			removeEnemy()
		end 

		-- if the whole word was typed ...
		if currentWordIndex > #currentWord then 
			currentWordIndex = 1
			--newKeyboard()
			--currentWordTimer = Timer:new(13, TimerModes.single)
		end 
	end 

	-- a particle test 
	--[[if not hit  then 
		for i=1,40 do
			table.insert(particleList, newParticle(player.x, player.y, math.random(-10, -200), math.random(-250, -550), 3))
		end
		hit = true 
	end ]]
	
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
		drawParticles()
	elseif gameState:peek() == GAME_STATES.battle then 
		drawBattle()
		drawParticles()
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

function updateParticles(dt, frameScroll)
	for i=#particleList,1,-1 do
		particleList[i].x = particleList[i].x + (particleList[i].vx * dt) - frameScroll
		
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
		if particleList[i].text then 
			love.graphics.print(particleList[i].text, particleList[i].x, particleList[i].y, 0, 2, 2)
		else 
			love.graphics.circle("fill",particleList[i].x, particleList[i].y, 5) 
		end 
	end
end
