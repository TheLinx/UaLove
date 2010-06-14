game,hook = {state="",hooks={},debug=false,quit=false},{}

function hook.add(event, func, id, state, debugonly)
	assert(type(event) == "string", "bad argument #1 to hook.add (string expected, got "..type(event)..")")
	assert(type(func) == "function", "bad argument #2 to hook.add (function expected, got "..type(func)..")")
	assert(type(id) == "string", "bad argument #3 to hook.add (string expected, got "..type(func)..")")
	if state ~= nil then
		assert(type(state) == "string", "bad argument #4 to hook.add (string expected, got "..type(func)..")")
		local oldfunc = func
		function func(...)
			if game.state == state then
				return oldfunc(...)
			end
			return true
		end
	end
	if debugonly ~= nil then
		assert(type(debugonly) == "boolean", "bad argument #5 to hook.add (boolean expected, got "..type(func)..")")
		local oldfunc = func
		function func(...)
			if game.debug == debugonly then
				return oldfunc(...)
			end
			return true
		end
	end
	game.hooks[id] = {event, func}
end

function hook.call(event, ...)
	out = {}
	for k,v in pairs(game.hooks) do
		if v[1] == event then
			success,ret = v[2](...)
			if not success then
				error("Hook "..k.." failed! Error: "..ret)
			else
				if ret then
					table.insert(out, ret)
				end
			end
		end
	end
	return out
end

function love.run()
	hook.call("load")

	local dt = 0

	while true do
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
		hook.call("update", dt)
		if love.graphics then
			love.graphics.clear()
			hook.call("draw")
		end

		if game.quit == true then
			hook.call("quit")
			return
		end

		if love.graphics then
			love.graphics.present()
		end
		if love.timer then
			love.timer.sleep(1)
		end
	end
end

for _,n in pairs{"joystickpressed", "joystickreleased", "keypressed",
 "keyreleased", "mousepressed", "mousereleased"} do
	love[n] = function(...)
		return hook.call(n, ...)
	end
end
