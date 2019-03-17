--[[
	Cookie Clicker
	
	Author: Victoria Tassie
	Source: https://www.twitch.tv/videos/387596393?filter=all&sort=time
]]

-- setting height and width constants for window
local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720

-- function to scale images
function getImageScaleForNewDimensions( image, newWidth, newHeight )
    local currentWidth, currentHeight = image:getDimensions()
    return ( newWidth / currentWidth ), ( newHeight / currentHeight )
end

-- set size for cookie
local COOKIE_DIAMETER = 250
local COOKIE_RADIUS = COOKIE_DIAMETER / 2

function importImage(path, height, width)
local texture = love.graphics.newImage(path)
local scaleX, scaleY = getImageScaleForNewDimensions(texture, width, height)
return texture, scaleX, scaleY
end

-- import the cookie image
local cookieTexture, scaleX, scaleY = importImage('graphics/cookie.png',COOKIE_DIAMETER, COOKIE_DIAMETER)
local cookieLeft = WINDOW_WIDTH / 2 - COOKIE_RADIUS
local cookieTop = WINDOW_HEIGHT / 2 - COOKIE_RADIUS

-- import cursor image
local cursorTexture, scaleSpriteX, scaleSpriteY = importImage('graphics/Cursor1.png', 30, 20)
local cursorLeft = WINDOW_WIDTH - cursorTexture:getWidth() - 300
local cursorTop = cursorTexture:getHeight() + 60

-- import the chef image
local chefTexture = love.graphics.newImage('graphics/chef.png')
local chefLeft = WINDOW_WIDTH - chefTexture:getWidth() - 300
local chefTop = chefTexture:getHeight() + 120 + cursorTexture:getHeight()

-- initialise the number of cookies and cps
local cookies = 0
local cps = 0
local makeCookieBigger = false
local cookiesLastSecond = 0
local cookiesThisSecond= 0
local secondTimer = 0

-- set font sizes
local smallFont = love.graphics.newFont(14)
local largeFont = love.graphics.newFont(32)

-- initialising sprite variables
local cursors = 1
local cursorCost = 10
local chefs = 0
local chefCost = 100

function love.load()

	-- sets the title of the window running
	love.window.setTitle('Cookie Clicker')

	-- set size of window
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

	-- set default font size
	love.graphics.setFont(largeFont)
end

function love.keypressed(key)

	-- quit the program if escape key is pressed
	if key == 'escape' then
		love.event.quit()
	end
end

function love.mousepressed(x, y, button)
	
	-- by default 1 is left click
	if button == 1 and makeCookieBigger then
		cookies = cookies + cursors
		cookiesThisSecond = cookiesThisSecond + cursors
	end

	-- if cursor sprite is clicked
	if button == 1 and cursorTextAppear then
		if cookies >= cursorCost then
			cookies = cookies - cursorCost
			cursors = cursors + 1
			cursorCost = cursorCost + (2 * cursors)
		end
	end

	-- if chef sprite is clicked
	if button == 1 and chefTextAppear then
		if cookies >= chefCost then
			cookies = cookies - chefCost
			chefs = chefs + 1
			chefCost = chefCost + (2 * chefs)
		end
	end
end

-- love update runs 60 times every second
function love.update(dt)
	local x, y =  love.mouse.getPosition()

	makeCookieBigger =  (x - cookieLeft - COOKIE_RADIUS)^2 + (y - cookieTop - COOKIE_RADIUS)^2 <= (COOKIE_RADIUS)^2

	cursorTextAppear = x >= cursorLeft and x < cursorLeft + cursorTexture:getWidth()*scaleSpriteX and y >= cursorTop and y < cursorTop + cursorTexture:getHeight()*scaleSpriteY

	chefTextAppear = x >= chefLeft and x < chefLeft + cursorTexture:getWidth()*scaleSpriteX and y >= chefTop and y < chefTop + cursorTexture:getHeight()*scaleSpriteY

	updateChefs(dt)

	secondTimer = secondTimer + dt

	--if a second has elapsed
	if secondTimer >=1 then
		secondTimer = secondTimer - 1
		-- calculate cps
		cps = (cookiesLastSecond + cookiesThisSecond) / 2
		-- reset the cookies each second
		cookiesLastSecond = cookiesThisSecond
		cookiesThisSecond = 0
	end	

end

function love.draw()

	-- display number of cookies clicked and the number of cookies per second
	-- note: .. is string concatenation
	love.graphics.printf('Cookies: ' .. tostring(math.floor(cookies)), 0, 24, 
	WINDOW_WIDTH, 'center')

	love.graphics.printf('Cookies per second: ' .. tostring(round(cps, 1)), 0, 65, 
	WINDOW_WIDTH*2, 'center', 0, 0.5, 0.5)

	-- draw cookie to the window
	love.graphics.draw(cookieTexture, 
	makeCookieBigger and WINDOW_WIDTH / 2 - COOKIE_RADIUS*1.2 or cookieLeft,
	makeCookieBigger and  WINDOW_HEIGHT / 2 - COOKIE_RADIUS*1.2 or cookieTop, 
	0, 
	makeCookieBigger and scaleX*1.2 or scaleX,
	makeCookieBigger and scaleY*1.2 or scaleY)

	-- draw cursor to the window
	love.graphics.draw(cursorTexture,
	cursorLeft,
	cursorTop, 
	0,
	scaleSpriteX,
	scaleSpriteY)

	love.graphics.setFont(smallFont)
	love.graphics.print('Cost: ' .. tostring(cursorCost), cursorLeft - 10, cursorTop + 40)
	love.graphics.setFont(largeFont)

	-- if hovering over cursor then display text
	if cursorTextAppear then
		love.graphics.printf('+1 cookie per click \nCurently own: ' .. tostring(cursors),
		cursorLeft + cursorTexture:getWidth()+20,
		cursorTop, 
		WINDOW_WIDTH,
		'left',
		0,
		0.4,
		0.4)
	end


	-- draw cursor to the window
	love.graphics.draw(chefTexture,
	chefLeft,
	chefTop, 
	0,
	scaleSpriteX,
	scaleSpriteY)

	love.graphics.setFont(smallFont)
	love.graphics.print('Cost: ' .. tostring(chefCost), chefLeft - 10, chefTop + 40)
	love.graphics.setFont(largeFont)

	-- if hovering over cursor then display text
	if chefTextAppear then
		love.graphics.printf('Adds 1 CPS \nCurrently own: ' .. tostring(chefs),
		chefLeft + chefTexture:getWidth()+20,
		chefTop, 
		WINDOW_WIDTH,
		'left',
		0,
		0.4,
		0.4)
	end
	
end

-- function to give automatic cookies
function updateChefs(dt)

	for i = 1, chefs do
		cookies = cookies + dt 
		cookiesThisSecond = cookiesThisSecond + dt 
	end

end


-- simple rounding function
function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end