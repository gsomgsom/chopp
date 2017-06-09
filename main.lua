local config = require 'config'
local sprites = require 'sprites'

local platform = {}

local player1 = {}
local player2 = {}

local gameState = 'title'

local activeFrame1
local activeFrame2
local currentFrame1 = 2
local currentFrame2 = 7

local music
local font
local level = 1
local map = {
	data = {}
}

-- return char as utf8 string
local function CodeToUTF8 (Unicode)
  if (Unicode == nil) then 
    return ""
  end

  if (Unicode < 0x20) then return ' '; end;

    if (Unicode <= 0x7F) then return string.char(Unicode); end;

    if (Unicode <= 0x7FF) then
      local Byte0 = 0xC0 + math.floor(Unicode / 0x40);
      local Byte1 = 0x80 + (Unicode % 0x40);
      return string.char(Byte0, Byte1);
    end;

    if (Unicode <= 0xFFFF) then
      local Byte0 = 0xE0 +  math.floor(Unicode / 0x1000);
      local Byte1 = 0x80 + (math.floor(Unicode / 0x40) % 0x40);
      local Byte2 = 0x80 + (Unicode % 0x40);
      return string.char(Byte0, Byte1, Byte2);
    end;

    return "";    -- ignore UTF-32 for the moment
end;


-- convert ascii string to utf8 string
function AsciiToUTF8(str)
  result = ""
  for i = 1, #str do
    result = result .. CodeToUTF8(string.byte(str, i, i+1))
  end
  return result
end

-- init
function love.load()
	sprites.loadTiles()
	activeFrame1 = sprites.tiles[1]
	activeFrame2 = sprites.tiles[7]

	platform.width = love.graphics.getWidth()
	platform.height = love.graphics.getHeight() - (8 * config.scale) -- 8px ftom top to status bar
	platform.x = 0
	platform.y = config.scale * 8 -- 8px ftom top to status bar

	initPlayers()

	-- music
	musicIntro = love.audio.newSource("music/intro.mod", "stream")
	musicIngame = love.audio.newSource("music/ingame.mod", "stream")
	love.audio.setVolume(0.5) -- @todo settings
	love.audio.play(musicIntro)

	-- font
	local charset = ''
	for x = 0, 255 do
		charset = charset..string.char(x);
	end
	font = love.graphics.newImageFont("images/font.png", AsciiToUTF8(charset))
	love.graphics.setFont(font)

end

-- keyboard events
function love.keypressed(key, unicode)

	-- title
	if (gameState == 'title') then

		if (love.keyboard.isDown('escape')) then
			print("Bye!")
			love.event.push('quit')
		end

		if (love.keyboard.isDown('f1')) then
			love.audio.stop()
			love.audio.play(musicIngame)
			gameState = 'ingame'
			map = love.filesystem.load('maps/level_1.lua')
			initPlayers()
		end

	end

	-- ingame
	if (gameState == 'ingame') then

		if (love.keyboard.isDown('escape')) then
			love.audio.stop()
			love.audio.play(musicIntro)
			gameState = 'title'
		end

	end

end

-- game logic
local elapsedTime = 0
function love.update(dt)
	elapsedTime = elapsedTime + dt

	-- every 1/25 sec change a frame
	if (elapsedTime > 1/25) then
		-- player 1 (geen)
		if (player1.direction == 'right') then
			if (currentFrame1 < 19) then
				currentFrame1 = currentFrame1 + 1
			else
				currentFrame1 = 14
			end
		else
			if (currentFrame1 < 6) then
				currentFrame1 = currentFrame1 + 1
			else
				currentFrame1 = 1
			end
		end
		activeFrame1 = sprites.tiles[currentFrame1]

		-- player 2 (red)
		if (player2.direction == 'right') then
			if (currentFrame2 < 25) then
				currentFrame2 = currentFrame2 + 1
			else
				currentFrame2 = 20
			end
		else
			if (currentFrame2 < 12) then
				currentFrame2 = currentFrame2 + 1
			else
				currentFrame2 = 7
			end
		end
		activeFrame2 = sprites.tiles[currentFrame2]

		elapsedTime = 0
	end

	-- ingame
	if (gameState == 'ingame') then

		-- @todo refactor, make class

		-- player 1 (green)
		if love.keyboard.isDown('right') then
			if (player1.direction == 'left') then
				currentFrame1 = 14
			end
			player1.direction = 'right'
			if player1.x < (love.graphics.getWidth() - 16 * config.scale) then
				player1.x = player1.x + (player1.speed * dt)
			end
		elseif love.keyboard.isDown('left') then
			if (player1.direction == 'right') then
				currentFrame1 = 1
			end
			player1.direction = 'left'
			if player1.x > 0 then 
				player1.x = player1.x - (player1.speed * dt)
			end
		end

		if love.keyboard.isDown('up') then
			if player1.y > 0 then
				player1.y_velocity = player1.y_velocity - 1
			end
		end

		if player1.y_velocity ~= 0 then
			player1.y = player1.y + player1.y_velocity * dt
			player1.y_velocity = player1.y_velocity - player1.gravity * dt
		end

		if player1.y > player1.ground then
			player1.y_velocity = 0
   		 	player1.y = player1.ground
		end

		if player1.y < 0 then
   		 	player1.y = 0
			player1.y_velocity = 1
		end

		if love.keyboard.isDown('space') then
			-- fire @todo
		end

		-- player 2 (red)
		if love.keyboard.isDown('d') then
			if (player2.direction == 'left') then
				currentFrame2 = 20
			end
			player2.direction = 'right'
			if player2.x < (love.graphics.getWidth() - 16 * config.scale) then
				player2.x = player2.x + (player2.speed * dt)
			end
		elseif love.keyboard.isDown('a') then
			if (player2.direction == 'right') then
				currentFrame2 = 7
			end
			player2.direction = 'left'
			if player2.x > 0 then 
				player2.x = player2.x - (player2.speed * dt)
			end
		end

		if love.keyboard.isDown('w') then
			if player2.y > 0 then
				player2.y_velocity = player2.y_velocity - 1
			end
		end

		if player2.y_velocity ~= 0 then
			player2.y = player2.y + player2.y_velocity * dt
			player2.y_velocity = player2.y_velocity - player2.gravity * dt
		end

		if player2.y > player2.ground then
			player2.y_velocity = 0
   		 	player2.y = player2.ground
		end

		if player2.y < 0 then
   		 	player2.y = 0
			player2.y_velocity = 1
		end

		if love.keyboard.isDown('lshift') then
			-- fire @todo
		end

	end

end

-- draw frame
function love.draw()
	love.graphics.setBackgroundColor(0, 63, 93) -- blue background

	-- title
	if (gameState == 'title') then
		love.graphics.print('Chopper Duel ver. '..config.version, 0, 0)

		love.graphics.print('F1 - NEW GAME', 250, 250)
		love.graphics.print('ESC - QUIT', 250, 270)

		-- player 2 (red)
		sprites.drawTile(
			activeFrame2,
			love.graphics.getWidth()/2 - ({activeFrame2:getViewport()})[3]/2 * config.scale,
			love.graphics.getHeight()/2 - ({activeFrame2:getViewport()})[4]/2 * config.scale
		)
	end

	-- ingame
	if (gameState == 'ingame') then

		-- map tiles
		drawMap()

		-- status bar @todo
		love.graphics.print('Player 1 [#####] [..........]', 0, 0)
		love.graphics.print('[..........] [#####] Player 2', love.graphics.getWidth() - 260, 0)

		-- player 1 (green)
		sprites.drawTile(
			activeFrame1,
			player1.x,
			player1.y
		)

		-- player 2 (red)
		sprites.drawTile(
			activeFrame2,
			player2.x,
			player2.y
		)
	end
end

-- draw map
function drawMap()
	-- 20 x 12 map with tiles 16 x 16px
	-- top 8px is reserved to status bar
	local m = map()
	for x = 0, 20 do
		for y = 0, 12 do
			sprites.drawTile(
				sprites.tiles[m.data[(y - 1) * 20 + x]],
				(16 * config.scale) * (x - 1),
				(16 * config.scale) * (y - 1) + (8 * config.scale)
			)
		end
	end
end

function initPlayers()
	-- player 1 (green)
	player1.x = 0
	player1.y = 16 * config.scale
	player1.speed = 200
	player1.img = sprites.tiles[2]
	player1.ground = love.graphics.getHeight() - 16 * config.scale
	player1.y_velocity = -1
	player1.gravity = -200
	player1.direction = 'right'
	player1.fuel = 255
	player1.score = 0

	-- player 2 (red)
	player2.x = love.graphics.getWidth() - 16 * config.scale
	player2.y = 16 * config.scale
	player2.speed = 200
	player2.img = sprites.tiles[7]
	player2.ground = love.graphics.getHeight() - 16 * config.scale
	player2.jump_height = -300
	player2.y_velocity = -1
	player2.gravity = -200
	player2.direction = 'left'
	player2.fuel = 255
	player2.score = 0
end
