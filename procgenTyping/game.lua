
-- parallel universe typing simulator 2016

local keys = {}
local keyToSwappedMap = {}
local swappedToKeyMap = {}
 
local topRow = "qwertyuiop"
local secondRow = "asdfghjkl"
local thirdRow = "zxcvbnm"
 
local currentWord = "cattle"
local currentWordIndex = 1
local win = false 

-- key press callback
function love.keypressed(key)
	print(key, string.byte(key), keyToSwappedMap[key])
	if key == "escape" then
		love.event.quit() 		
	end
    keys[key] = {down = true} 
end

-- key released callback
function love.keyreleased(key)
    keys[key] = {down = false} 
end

-- just check if a key is down
function getKeyDown(key)
	if not keys[key] then 
		keys[key] = {down = false}
	elseif keys[key].down then 
		return true
	end
	return false
end

function getSwappedKeyDown(key)
	if not keys[key] then 
		keys[key] = {down = false}
	elseif keys[key].down then 
		return true
	end
	return false
end 

-- checking if a key is pressed. key will be set as released once checked
function getKeyPress(key)
	if not keys[key] then 
		keys[key] = {down = false}
	elseif keys[key].down then 
		keys[key].down = false
		return true
	end
	return false
end

function swap(array, index1, index2)
    array[index1], array[index2] = array[index2], array[index1]
end

function shuffle(array, size)
    local counter = string.byte("a")
    while counter <= string.byte("z") do
        local index = string.char(math.random(string.byte("a"), string.byte("z")))
        swap(array, index, string.char(counter))
        counter = counter + 1
    end
end

function newKeyboard()
	local current = string.byte("a")
	
	local letters = {}
	while current <= string.byte("z") do
		letters[string.char(current)] = string.char(current)--string.char(love.math.random(string.byte("a"), string.byte("z")))
		current = current + 1
	end 
	shuffle(letters)

	current = string.byte("a")
	keyToSwappedMap = {}
	while current <= string.byte("z") do
		keyToSwappedMap[string.char(current)] = letters[string.char(current)] --string.char(current)--string.char(love.math.random(string.byte("a"), string.byte("z")))
		swappedToKeyMap[letters[string.char(current)]] = string.char(current)
		current = current + 1
	end 
end 


function loadGame()
	newKeyboard()

end


function updateGame(dt)	
	if getKeyDown("tab") then 
		newKeyboard()
	end 

	if not win and getKeyDown(swappedToKeyMap[currentWord:sub(currentWordIndex,currentWordIndex)]) then 
		currentWordIndex = currentWordIndex + 1 
		if currentWordIndex > #currentWord then 
			win = true 
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




	--[[love.graphics.origin()
	love.graphics.push()
		love.graphics.scale(camera.scale)		
		love.graphics.translate((-camera.x), (-camera.y))	
	love.graphics.pop()]]
end


