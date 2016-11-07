
-- parallel universe typing simulator 2016

local keys = {}
local keyMap = {}
 
local topRow = "qwertyuiop"
local secondRow = "asdfghjkl"
local thirdRow = "zxcvbnm"
 

local camera = {
	x = 0, 
	y = 0,
	vx = 0,
	vy = 0,
	acceleration = 100,
	friction = 0.1,
	scale = 0.5,
	rotation = 0
}


local tileWidth = 30 
local tileHeight = 30



local map = {}


local roomLayout = {
	{1, 1, 0, 1, 1},
	{1, 0, 0, 0, 1}, 
	{0, 0, 0, 0, 0},
	{1, 0, 0, 0, 1},
	{1, 1, 0, 1, 1}
}


local roomWidth = #roomLayout[1]
local roomHeight = #roomLayout
local roomHeightPx = tileWidth * roomWidth
local roomWidthPx = tileHeight * roomHeight

local mapWidth = 5 * roomWidth + 1
local mapHeight = 3 * roomHeight + 1

local mapWidthInPx = roomWidthPx * mapWidth
local mapHeightInPx = roomHeightPx * mapHeight

local floorCol = {
	r = 0,
	b = 26,
	g = 77
}

local wallCol = {
	r = 255,
	b = 255,
	g = 55
}

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




	for yy=1,mapHeight do
		for xx=1,mapWidth do

			local rr 
			local gg
			local bb 
			if math.fmod(yy - 1, roomHeight) == 0 or yy == mapHeight or 
			math.fmod(xx - 1, roomWidth) == 0 or xx == mapWidth then 
				rr = wallCol.r 
				gg = wallCol.g 
				bb = wallCol.b 
			else 
				rr = floorCol.r 
				gg = floorCol.g 
				bb = floorCol.b 
			end 

			map[mapWidth * yy + xx] = {
				r = rr,
				g = gg,
				b = bb,
				

				x = xx, 
				y = yy
			}
		end
	end

end


function updateGame(dt)	
	if getKeyDown("tab") then 
		newKeyboard()
	end 

	if getKeyDown("up") then 
		camera.y = camera.y - 10
	elseif getKeyDown("down") then 
		camera.y = camera.y + 10
	end 

	if getKeyDown("left") then 
		camera.x = camera.x - 10
	elseif getKeyDown("right") then 
		camera.x = camera.x + 10
	end 

	if getKeyDown("q") then camera.scale = camera.scale - dt end 
	if getKeyDown("e") then camera.scale = camera.scale + dt end 
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
	love.graphics.print(keyMap[character], keyboardTopLeft.x + (20 * x) + (5*y) + 5, keyboardTopLeft.y + (20 * y) + 5)	
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

	drawKeyboard(100, 100)

	love.graphics.origin()
	love.graphics.push()

		-- camera update
		love.graphics.scale(camera.scale)		
		--love.graphics.translate((screenWidth / 2), (screenHeight / 2))
			love.graphics.translate((-camera.x), (-camera.y))	
			--love.graphics.rotate(camera.rotation)
			--love.graphics.scale(camera.scale)	
		--love.graphics.translate((-screenWidth / 2), (-screenHeight / 2))
	

			


		for y=1,mapHeight do
			for x=1,mapWidth do 
				if x * tileWidth >= camera.x and x * tileWidth < camera.x + roomWidthPx then 
					love.graphics.setColor(map[mapWidth*y+x].r, map[mapWidth*y+x].g, map[mapWidth*y+x].b)
					love.graphics.rectangle("fill", (map[mapWidth*y+x].x-1)*tileWidth, 
													(map[mapWidth*y+x].y-1)*tileHeight, 
													tileWidth, tileHeight)

				end 
			end 
		end
	love.graphics.pop()
end


