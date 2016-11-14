
-- keyboard warrior

-- maybe have it with variation for battle mode

-- for block have a single letter appear -> 1 second to block each letter attack

local GAME_STATES = {battle = "battle", walking = "walking", paused = "paused", title = "title", gameOver = "gameOver"}
local BATTLE_STATES = {attacking = "attacking", blocking = "blocking"}

local gameState = nil
local battleState = nil

local currentWord = "attack"
local currentWordIndex = 1
local currentWordTime = 6
local currentWordTimer = nil

local audiopath = "assets/audio/"
local sounds ={
	enemyHit = audiopath.."hitEnemy.wav",
	block = {
		audiopath.."block1.wav",
		audiopath.."block2.wav",
		audiopath.."block3.wav",
		audiopath.."block4.wav",
		audiopath.."block5.wav"
	}
}

-- keep track of enemies defeated and show it on game over screen 
local enemiesDefeated = 0 

-- for screenshake when you get hit 
local screenShakeTimer = nil 
local screenShake = false
local screenshakeBounds = {
	min = {
		x = -5,
		y = -5
	},
	max = {
		x = 5,
		y = 5
	}	
}

local player = nil 

local particleList = {} 

local gravity = 22

function setCurrentWord(newWord)
	currentWord = newWord 
	currentWordIndex = 1
end 

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
	currentWordTimer = Timer:new(currentWordTime, TimerModes.single)
	setCurrentWord("attack")
	battleState = BATTLE_STATES.attacking

	enemiesDefeated = 0 

	initBackground()

	initText()

	player = {
		x = -tileSize, 
		y = floorY - tileSize,
		width = tileSize,
		height = tileSize,
		baseAttack = 1,
		health = 25,
		maxHealth = 25,
		tileset = love.graphics.newImage("assets/sprites/32x32spaceshipTileset.png"),
		tilesetQuads = {},
		animationTimer = Timer:new(0.3,TimerModes.repeating),
		animationIndex = 1
	}


	player.tileset = love.graphics.newImage("assets/sprites/32x32spaceshipTileset.png")
	player.tileset:setFilter("nearest", "nearest")

	local playerTilesetWidth = player.tileset:getWidth()
	local playerTilesetHeight = player.tileset:getHeight()

	player.tilesetQuads = {}
	for i=1,4 do
		player.tilesetQuads[i] = love.graphics.newQuad((i-1)*32, 0, 32, 32, playerTilesetWidth, playerTilesetHeight)	
	end
	
	screenShake = false 
	screenShakeTimer = nil
end

function restartGame()
	loadGame()
end 

-- BASE UPDATE 
function updateGame(dt)	

	local frameScroll = 0

	if getKeyPress("escape") then 
		if gameState:peek() == GAME_STATES.paused then 
			gameState:pop()	
		else 
			if gameState:peek() ~= GAME_STATES.title and gameState:peek() ~= GAME_STATES.gameOver then 
				gameState:push(GAME_STATES.paused)
			end 
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
	elseif gameState:peek() == GAME_STATES.gameOver then 
		frameScroll = math.floor(200 * dt)
		updateWalking(dt, frameScroll)
		updateParticles(dt, frameScroll)
		updateGameOver(dt)
	end 
end

function updateTitle(dt)
	if getKeyDown("r") then 
		gameState:push(GAME_STATES.walking)
	end 
	--[[if getKeyDown("q") then 
		love.events.quit()
	end ]]
end 

function updateWalking(dt, frameScroll)
	updateBackground(dt, frameScroll)
	if player.x < tileSize * 5 then 
		--player.x = player.x + dt * 80 
		player.x = player.x + (((tileSize*5) - player.x ) * 0.07)
	end 

	-- if an enemy is 4 tiles away then switch to battle mode
	if enemyWithinRange(player.x, screenWidth * 0.6 ) and gameState:peek() ~= GAME_STATES.gameOver then 
		battleState = BATTLE_STATES.attacking
		currentWordTimer:reset()
		newKeyboard()
		gameState:push(GAME_STATES.battle)
	end

	updatePlayer(dt)
end 


-- clean this up, it's messy
function updateBattle(dt)

	updatePlayer(dt)

	if currentWordTimer:isComplete(dt) then 
		--love.event.quit()
		if battleState == BATTLE_STATES.attacking then 
			if currentWordIndex == 1 then 
				table.insert(particleList, newParticle(currentEnemyPosition().x, currentEnemyPosition().y, math.random(100, 200), math.random(-250, -550), 3, tostring(0)))
			end 
			battleState = BATTLE_STATES.blocking
			setCurrentWord("block")
		elseif battleState == BATTLE_STATES.blocking then 
			-- if it got here then the player didn't fully type out block
			screenShakeTimer = Timer:new(0.3, TimerModes.single)
			screenShake = true 
			local hitDamage = currentEnemyGetAttackDamage() + (currentEnemyGetAttackDamage() * 0.5 * (#currentWord - (currentWordIndex-1)))
			print(tostring(hitDamage))
			table.insert(particleList, newParticle(player.x, player.y, math.random(-100, -200), math.random(-250, -550), 3, tostring(hitDamage)))
			player.health = player.health - hitDamage
			if player.health <= 0 then 
				for i=1,40 do
					table.insert(particleList, newParticle(player.x, player.y, math.random(-250, 250), math.random(-250, -550), 3, "dead"))
				end
				gameState:push(GAME_STATES.gameOver)
				return
			end 
			battleState = BATTLE_STATES.attacking
			setCurrentWord("attack")
		end 
		newKeyboard()
		currentWordTimer = Timer:new(currentWordTime, TimerModes.single)
	end 

	-- check if the current letter in the current word was typed 
	if letterInWordPressed(currentWord, currentWordIndex) then 
		currentWordIndex = currentWordIndex + 1 

		if battleState == BATTLE_STATES.attacking then 
			love.audio.play(sounds.enemyHit)
			local hitDamage = math.random(player.baseAttack, player.baseAttack + 3)
			table.insert(particleList, newParticle(currentEnemyPosition().x, currentEnemyPosition().y, math.random(100, 200), math.random(-250, -550), 3, tostring(hitDamage)))
			decreaseCurrentEnemyHealth(hitDamage)
			-- enemy defeated, battle over 
			if currentEnemyHealth() <= 0 then 
				gameState:pop()
				removeEnemy()
				setCurrentWord("attack")
				--player.health = player.maxHealth
			end 
		elseif battleState == BATTLE_STATES.blocking then 
			love.audio.play(sounds.block[currentWordIndex-1])
		end 

		-- if the whole word was typed ...
		if currentWordIndex > #currentWord then 
			if battleState == BATTLE_STATES.attacking then 
				currentWordTimer:reset()
				battleState = BATTLE_STATES.blocking
				setCurrentWord("block")
			-- if the whole word was typed, player takes no damage
			elseif battleState == BATTLE_STATES.blocking then 
				table.insert(particleList, newParticle(player.x, player.y, math.random(-100, -200), math.random(-250, -550), 3, tostring(0)))
				currentWordTimer:reset()
				battleState = BATTLE_STATES.attacking
				setCurrentWord("attack")
			end 
			newKeyboard()
		end 
	end 

	if screenShake and screenShakeTimer:isComplete(dt) then 
		print("screenshake done")
		screenShake = false
	end 

end 

function updatePaused(dt)
	if getKeyDown("q") then love.event.quit() end 
	if getKeyDown("r") then gameState:pop() end 
end 

function updateGameOver(dt)
	if getKeyDown("q") then love.event.quit() end 
	if getKeyDown("r") then 
		restartGame()
	end 
end 

function updatePlayer(dt)
	if player.animationTimer:isComplete(dt) then 
		player.animationIndex = player.animationIndex + 1 
		if player.animationIndex > 4 then 
			player.animationIndex = 1 
		end 
	end 
end 

-- BASE DRAW 
function drawGame()
	resetColor()
	if gameState:peek() == GAME_STATES.title then 
		drawTitle()
	elseif gameState:peek() == GAME_STATES.walking then 
		drawWalking()
		drawParticles()
	elseif gameState:peek() == GAME_STATES.battle then 
		if screenShake then 
			love.graphics.origin()
			love.graphics.translate(math.random(screenshakeBounds.min.x, screenshakeBounds.max.x), math.random(screenshakeBounds.min.y, screenshakeBounds.max.y))
		end 
		drawBattle()
		drawParticles()
	elseif gameState:peek() == GAME_STATES.paused then 
		drawPaused()
	elseif gameState:peek() == GAME_STATES.gameOver then 
		drawWalking()
		drawParticles()
		drawGameOver()
	end 
end

function drawTitle()
	drawText("just type attack to attack", 32, 32)
	drawText("and block to block", 32, 64)
	drawText("pretty easy huh?", 32, 96)
	drawText("press esc in game to pause", 32, 128)
	drawText("press r to start", 32, 160)
end 

function drawWalking()
	drawBackground()
	if gameState:peek() ~= GAME_STATES.gameOver then 
		drawPlayer()
	end 
end 

function drawBattle()
	drawBackground()
	drawPlayer()
	
	-- draw the current word with a black box behind it
	local top = 64 
	local left = 192
	love.graphics.setColor(200, 200, 200)
	love.graphics.rectangle("line", left-8, top-8, #currentWord * 16 +16, 16 +16)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", left-8, top-8, #currentWord * 16 +16, 16 +16)
	resetColor()
	drawWord(currentWord, currentWordIndex, left, top)
	

	drawKeyboard(96, 96)
	currentWordTimer:draw(32, 16, screenWidth - 64, 32)
	
	drawHealthBar(8, 96, 32, 96, player.health, player.maxHealth)
	drawHealthBar(screenWidth - 8 - 32, 96, 32, 96, currentEnemyHealth(), currentEnemyMaxHealth())
end 

function drawPaused()
	drawText("game paused", 32, 32)
	drawText("press esc to resume", 32, 64)
	drawText("press q to quit", 32, 96)
end 

function drawGameOver()
	drawText("game over", 32, 32)
	drawText("press r to restart", 32, 64)
	drawText("press q to quit", 32, 96)
end 

function drawPlayer()
	love.graphics.draw(player.tileset, player.tilesetQuads[player.animationIndex], player.x, player.y)
end 

-- vertical bar
function drawHealthBar(x, y, width, height, value, maxValue)
	local timerPercentComplete = value / maxValue
	love.graphics.rectangle("line", x, y, width, height)
	love.graphics.rectangle("fill", x, y + height, width, y - height - (height * timerPercentComplete))
end 

-- not super sure where to stick this 
-- it draws a word based on how much of the word has been typed 
function drawWord(wordToDraw, lettersTyped, x, y)
	local counter = 1
	for c in wordToDraw:gmatch"." do
		if lettersTyped <= counter then 
			love.graphics.setColor(255, 255, 255)
		else 
			love.graphics.setColor(120, 120, 120)
		end 
		-- need to change this to sprite -> 10 becomes tileSize
		drawText(c, x + ((counter-1) * 16), y)
		counter = counter + 1
	end
	resetColor()
end 



function love.focus(f)
	if not f then
		if gameState:peek() ~= GAME_STATES.title or gameState:peek() ~= GAME_STATES.gameOver then 
			gameState:push(GAME_STATES.paused)
		end 
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
			drawText(particleList[i].text, particleList[i].x, particleList[i].y)
		else 
			love.graphics.circle("fill",particleList[i].x, particleList[i].y, 5) 
		end 
	end
	resetColor()
end





-- make a sprite class if I had time 
local textTileset = nil 
local textTilesetQuads = nil

function initText()
	textTileset = love.graphics.newImage("assets/sprites/16x16PixelFont.png")
	textTileset:setFilter("nearest", "nearest")

	local tilesetWidth = textTileset:getWidth()
	local tilesetHeight = textTileset:getHeight()

	textTilesetQuads = {}

	textTilesetQuads[" "] = love.graphics.newQuad(0, 32, 16, 16, tilesetWidth, tilesetHeight)

	textTilesetQuads["."] = love.graphics.newQuad((26*16) + ((1)*16), 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["?"] = love.graphics.newQuad((26*16) + ((2)*16), 16, 16, 16, tilesetWidth, tilesetHeight)


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





