local config = require 'config'
local sprites = require 'sprites'

local gamestate = 'title'

local activeFrame
local currentFrame = 7

local music
local font
local level = 1
local map = {
	data = {}
}

-- init
function love.load()
	sprites.loadTiles()
	activeFrame = sprites.tiles[7]

	musicIntro = love.audio.newSource("music/intro.mod", "stream")
	musicIngame = love.audio.newSource("music/ingame.mod", "stream")
	love.audio.setVolume(0.5)

	font = love.graphics.newImageFont("images/font.png",
		" abcdefghijklmnopqrstuvwxyz" ..
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
		"123456789.,!?-+/():;%&`'*#=[]\"")
	love.graphics.setFont(font)

	love.audio.play(musicIntro)

end

-- keyboard events
function love.keypressed(key, unicode)

	-- title
	if (gamestate == 'title') then

		if (love.keyboard.isDown('escape')) then
			print("Bye!")
			love.event.push('quit')
		end

		if (love.keyboard.isDown('f1')) then
			love.audio.stop()
			love.audio.play(musicIngame)
			gamestate = 'ingame'
			map = love.filesystem.load('maps/level_1.lua')
		end

	end

	-- ingame
	if (gamestate == 'ingame') then

		if (love.keyboard.isDown('escape')) then
			love.audio.stop()
			love.audio.play(musicIntro)
			gamestate = 'title'
		end

	end

end

-- game logic
local elapsedTime = 0
function love.update(dt)
	elapsedTime = elapsedTime + dt

	-- every 1/25 sec change a frame
	if (elapsedTime > 1/25) then
		if (currentFrame < 12) then
			currentFrame = currentFrame + 1
		else
			currentFrame = 7
		end
		activeFrame = sprites.tiles[currentFrame]
		elapsedTime = 0
	end

end

-- draw frame
function love.draw()
	love.graphics.setBackgroundColor(0, 63, 93) -- blue background

	-- title
	if (gamestate == 'title') then
		love.graphics.print('Chopper Duel ver. '..config.version, 0, 0)

		love.graphics.print('F1 - NEW GAME', 250, 250)
		love.graphics.print('ESC - QUIT', 250, 270)

		sprites.drawTile(
			activeFrame,
			love.graphics.getWidth()/2 - ({activeFrame:getViewport()})[3]/2 * config.scale,
			love.graphics.getHeight()/2 - ({activeFrame:getViewport()})[4]/2 * config.scale
		)
	end

	-- ingame
	if (gamestate == 'ingame') then

		drawMap()

		love.graphics.print('Player 1 [#####] [..........]', 0, 0)
		love.graphics.print('[..........] [#####] Player 2', love.graphics.getWidth() - 260, 0)

		sprites.drawTile(
			activeFrame,
			0,
			15
		)
	end
end

-- draw map
function drawMap()
	local m = map()
	for x = 0, 20 do
		for y = 0, 12 do
			sprites.drawTile(
				sprites.tiles[m.data[(y-1) * 20 + x]],
				(16 * config.scale) * (x - 1),
				(16 * config.scale) * (y - 1) + 16
			)
		end
	end
end
