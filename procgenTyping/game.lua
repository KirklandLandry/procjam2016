
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

	initKeyboard()

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
		currentWordTimer:reset()
		newKeyboard()
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
			currentWordIndex = 1
		end 

		-- if the whole word was typed ...
		if currentWordIndex > #currentWord then 
			currentWordIndex = 1
			--newKeyboard()
			--currentWordTimer = Timer:new(13, TimerModes.single)
		end 
	end 

end 

function updatePaused(dt)
	if getKeyDown("q") then love.event.quit() end 
	if getKeyDown("r") then gameState:pop() end 
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
	drawText("just type attack to attack", 32, 32)
	drawText("pretty easy huh", 32, 64)
	drawText("press r to start", 32, 96)
	--drawText("0123456789", 32, 64)
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
	drawText("game paused", 32, 32)
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
		drawText(c, x + (counter * 16), y)
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

		if particleList[i].y + 16 > floorY then 
			particleList[i].alpha = particleList[i].alpha* 0.75
			particleList[i].y = floorY - 16
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
			--love.graphics.print(, 0, 2, 2)
			drawText(particleList[i].text, particleList[i].x, particleList[i].y)
		else 
			love.graphics.circle("fill",particleList[i].x, particleList[i].y, 5) 
		end 
	end
end





-- make a sprite class if I had time 
local textTileset = nil 
local textTilesetQuads = nil

function initKeyboard()
	textTileset = love.graphics.newImage("assets/sprites/16x16PixelFont.png")
	textTileset:setFilter("nearest", "nearest")

	local tilesetWidth = textTileset:getWidth()
	local tilesetHeight = textTileset:getHeight()

	textTilesetQuads = {}

	textTilesetQuads[" "] = love.graphics.newQuad(0, 32, 16, 16, tilesetWidth, tilesetHeight)

    local counter = 0
    for i=string.byte("a"),string.byte("z") do
    	textTilesetQuads[string.char(i)] = love.graphics.newQuad(counter * 16, 0, 16, 16, tilesetWidth, tilesetHeight)
    	counter = counter + 1
    end

    -- map numbers 
    for i=1,10 do
    	if i == 10 then 
    		textTilesetQuads[tostring(0)] = love.graphics.newQuad((26*16) + ((i-1)*16), 0, 16, 16, tilesetWidth, tilesetHeight)
    	else 
			textTilesetQuads[tostring(i)] = love.graphics.newQuad((26*16) + ((i-1)*16), 0, 16, 16, tilesetWidth, tilesetHeight)
    	end 
    	
    end



end 

function drawText(word, x, y)
	local counter = 0
	for c in word:gmatch"." do
		love.graphics.draw(textTileset, textTilesetQuads[c], x + (counter*16), y)
		counter = counter + 1
	end
end 





