pixelmap = {}

local pixmap_mt = {
	__index = pixelmap
}

function pixelmap.open(fname)
	local func,err = love.filesystem.load(fname)
	if not func then return nil,err end
	return pixelmap.new(func())
end

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

function pixelmap:getFrame()
	return self._frame
end

function pixelmap:changeFrame(id)
	self._frame = id
	self:updateData()
end

function pixelmap:updateData()
	for frame=1,#self._data do
		local v = self._data[frame]
		for y=1,#v do
			local w = v[y]
			for x=1,#w do
				if not self._oldData or w[x] ~= self._oldData[frame][y][x] then
					local c = self._palette[w[x]]
					self._imageData:setPixel(x, y, c[1], c[2], c[3], c[4])
				end
			end
		end
	end
	self._oldData = self._data
	self._image = love.graphics.newImage(self._imageData)
end

function pixelmap:draw(...)
	return love.graphics.draw(self._image, ...)
end