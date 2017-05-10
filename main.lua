local config = require 'config'
local sprites = require 'sprites'

local activeFrame
local currentFrame = 7

local music

-- init
function love.load()
	sprites.loadTiles()
	activeFrame = sprites.tiles[7]

	musicIntro = love.audio.newSource("music/intro.mod", "stream")
	musicIngame = love.audio.newSource("music/ingame.mod", "stream")

	love.audio.play(musicIntro)

end

-- keyboard events
function love.keypressed(key, unicode)
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
	love.graphics.setBackgroundColor(0,63,93) -- blue background

	sprites.drawTile(
		activeFrame,
		love.graphics.getWidth()/2 - ({activeFrame:getViewport()})[3]/2 * config.scale,
        love.graphics.getHeight()/2 - ({activeFrame:getViewport()})[4]/2 * config.scale
	)
end
