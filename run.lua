function love.run()
    local TIME_PER_UPDATE = 1.0/60
 
	if love.math then
		love.math.setRandomSeed(os.time())
	end
 
	if love.load then local world, player = love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
    local lag = 0
 
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
            lag = lag + dt
		end
 
		-- Call update and draw
        while lag >= TIME_PER_UPDATE do
            if love.update then love.update(dt, world, player) end -- will pass 0 if love.timer is disabled
            lag = lag - TIME_PER_UPDATE
        end
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw(lag/TIME_PER_UPDATE, world, player) end
			love.graphics.present()
		end
 
		if love.timer then love.timer.sleep(0.001) end
	end
 
end
