-- key list containing if a key is pressed or not 
local keys = {}
-- map of actual key value -> randomized key value 
local keyToSwappedMap = {}
-- map of randomized key value -> actual key value 
local swappedToKeyMap = {}

-- just defining the keyboard layout 
-- obviously won't work with non qwerty and non english keyboards 
-- but I don't have anything else to test with and all I need is to get something that works for now 
local topRow = "qwertyuiop"
local secondRow = "asdfghjkl"
local thirdRow = "zxcvbnm"



-- key press callback
function love.keypressed(key)
	print(key, string.byte(key), keyToSwappedMap[key])
    keys[key] = {down = true, held = false} 
end

-- key released callback
function love.keyreleased(key)
    keys[key] = {down = false, held = false} 
end

-- just check if a key is down
function getKeyDown(key)
	if not keys[key] then 
		keys[key] = {down = false, held = false}
	elseif keys[key].down then 
		if not keys[key].held then keys[key].held = true end 
		return true
	end
	return false
end

-- checking if a key is pressed. key will be set as released once checked
function getKeyPress(key)
	if not keys[key] then 
		keys[key] = {down = false, held = false}
	elseif keys[key].down and keys[key].held == false then 
		--keys[key].down = false
		if not keys[key].held then keys[key].held = true end 
		return true
	end
	return false
end

-- checking if the swapped letter pressed corresponds to a letter in the given word at the given index 
function letterInWordPressed(wordToCheck, indexToCheck)
	return getKeyPress(swappedToKeyMap[wordToCheck:sub(indexToCheck,indexToCheck)]) 
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
	keys = {}

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


function colourSet(character)
	if getKeyDown(character) then 
		love.graphics.setColor(10, 10, 10)
	else 
		love.graphics.setColor(255, 255, 255)
	end 
end 


function drawKey(character, x, y, keyboardTopLeft)	
	love.graphics.setColor(50, 50, 50)
	love.graphics.rectangle("fill", keyboardTopLeft.x + (32 * x) + (5*y), keyboardTopLeft.y + (32 * y), 32, 32)
	love.graphics.setColor(100, 100, 100)
	love.graphics.rectangle("line", keyboardTopLeft.x + (32 * x) + (5*y), keyboardTopLeft.y + (32 * y), 32, 32)
	colourSet(character)
	drawText(keyToSwappedMap[character], keyboardTopLeft.x + (32 * x) + (5*y) + 10, keyboardTopLeft.y + (32 * y) + 7)
	resetColor()
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