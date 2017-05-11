local config = require 'config'

local sprites = {}

sprites.tilesImage = ''
sprites.maxTile = 0
sprites.tiles = {}
sprites.scale = 2

-- draw a tile n at position x, y (absolute)
function sprites.drawTile(n, x, y)
	if (n ~= nil) then
		love.graphics.draw(sprites.tilesImage, n, x, y, 0, config.scale, config.scale, 0, 0)
	end
end

-- load tile images
function sprites.loadTiles()
	sprites.tilesImage = love.graphics.newImage("images/tiles.png")
	sprites.maxTile = sprites.tilesImage:getHeight() / 16 - 1

	-- load tiles
	for i = 1, sprites.maxTile do
		sprites.tiles[i] = love.graphics.newQuad(0,16*i,16,16,sprites.tilesImage:getDimensions())
	end
end

return sprites
