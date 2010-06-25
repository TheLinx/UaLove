pixelmap = {}

local pixmap_mt = {
	__index = pixelmap
}

function pixelmap.new(width, height, colours, data)
	local self = setmetatable({}, pixmap_mt)
	self._width,self._height = width,height
	self._imageData = love.image.newImageData(width, height)
	self._image = love.graphics.newImage(self._imageData)
	self._palette = colours
	self._palette[0] = {0,0,0,0}
	self._data = data
	self._frame = 1
	self:updateData()
	return self
end

function pixelmap:changeColour(id, r, g, b, a)
	self._palette[id] = {r, g, b, a}
	self:updateData()
end

function pixelmap:changeData(newData)
	for frame,v in pairs(newData) do
		for y,w in pairs(v) do
			for x,id in pairs(w) do
				self._data[frame][y][x] = id
			end
		end
	end
	self:updateData()
end

function pixelmap:changeFrame(id)
	self._frame = id
	self:updateData()
end

function pixelmap:updateData()
	self._imageData:mapPixel(function(x,y)
		return unpack(self._palette[self._data[self._frame][y+1][x+1]])
	end)
	self._image = love.graphics.newImage(self._imageData)
end

function pixelmap:draw(...)
	return love.graphics.draw(self._image, ...)
end