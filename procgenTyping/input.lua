
local keys = {}
keyToSwappedMap = {}
swappedToKeyMap = {}


topRow = "qwertyuiop"
secondRow = "asdfghjkl"
thirdRow = "zxcvbnm"

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