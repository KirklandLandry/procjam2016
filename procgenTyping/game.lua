
-- parallel universe typing simulator 2016

keys = {}

 
 local keyMap = {}
 
local topRow = "qwertyuiop"
local secondRow = "asdfghjkl"
local thirdRow = "zxcvbnm"
 
-- key press callback
function love.keypressed(key)
	print(key, string.byte(key), keyMap[key])
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


function newKeyboard()
	local current = string.byte("a")
	keyMap = {}
	while current <= string.byte("z") do
		keyMap[string.char(current)] = string.char(love.math.random(string.byte("a"), string.byte("z")))
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
end

function colourSet(character)
	if getKeyDown(character) then 
		love.graphics.setColor(255, 0, 0)
	else 
		love.graphics.setColor(255, 255, 255)
	end 
end 


local keyboardTopLeft = { x = 100, y = 100 }

function drawKey(character, x, y)	
	love.graphics.setColor(0, 0, 200)
	love.graphics.rectangle("fill", keyboardTopLeft.x + (20 * x) + (5*y), keyboardTopLeft.y + (20 * y), 20, 20)
	love.graphics.setColor(0, 0, 150)
	love.graphics.rectangle("line", keyboardTopLeft.x + (20 * x) + (5*y), keyboardTopLeft.y + (20 * y), 20, 20)
	colourSet(character)
	love.graphics.print(keyMap[character], keyboardTopLeft.x + (20 * x) + (5*y) + 5, keyboardTopLeft.y + (20 * y) + 5)	
end 

function drawGame()

	local counter = 0
	for c in topRow:gmatch"." do
		drawKey(c, counter, 0)
		counter = counter + 1
	end

	counter = 0
	for c in secondRow:gmatch"." do
		drawKey(c, counter, 1)
		counter = counter + 1
	end
	
	counter = 0
	for c in thirdRow:gmatch"." do
		drawKey(c,  counter, 2)
		counter = counter + 1
	end

end


