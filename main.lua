require 'debug'
epsilon = 1.1920928955078125e-07

local cycle1 = { x = 100, y = 100, dir = 'right', trail = {}, image = nil, color = { 0, 50, 255 }, scale = 1 }
local cycle2 = { x = 1000, y = 800, dir = 'left', trail = {}, image = nil, ai = true, color = { 255, 50, 0 }, scale = 1 }
local gridSize = 100
local cycleSpeed = 200
local aiChangeInterval = 1
local aiTimer = 0
local fixedLineWidth = 5

local wallImage = nil
local wallWidth = 10
local wallHeight = 10

--local gameState = require "screens/menu"

-- local Game = require "screens/game"

-- Rotation angles for directions (in radians)
local directionAngles = {
    up = -math.pi / 2,  -- 90 degrees counterclockwise
    down = math.pi / 2, -- 90 degrees clockwise
    left = math.pi,     -- 180 degrees
    right = 0           -- 0 degrees
}

function love.load()
    love.window.setMode(1300, 1000)

    love.graphics.setBackgroundColor(0, 0, 0)

    cycle1.image = love.graphics.newImage('assets/images/Tron_50.png')
    cycle2.image = love.graphics.newImage('assets/images/Tron2_50.png')

    wallImage = love.graphics.newImage('assets/images/wall.png')
    wallWidth = wallImage:getWidth()
    wallHeight = wallImage:getHeight()
end

function love.update(dt)
    --if gameState == 'game' then
    moveCycle(cycle1, dt)
    moveCycle(cycle2, dt)
    if checkCollision(cycle1) or checkCollision(cycle2) then
        --gameState = 'menu'
        love.event.quit()
        --end
    end

    -- AI logic
    if cycle2.ai then
        aiTimer = aiTimer + dt
        if aiTimer >= aiChangeInterval then
            changeAIDirection(cycle2)
            aiTimer = 0
        end
    end
end

function love.draw()
    --if gameState == 'menu' then
    --    drawMenu()
    --elseif gameState == 'game' then

    drawWalls()

    drawTrail(cycle1)
    drawTrail(cycle2)

    love.graphics.setColor(1, 1, 1)
    drawCycle(cycle1)
    drawCycle(cycle2)
    --end
end

function love.keypressed(key)
    -- if gameState == 'menu' then
    --     if key == 'return' then
    --         gameState = 'playing'
    --     elseif key == 'i' then
    --         gameState = 'instructions'
    --     elseif key == 'q' then
    --         love.event.quit()
    --     end
    -- elseif gameState == 'instructions' then
    --     if key == 'return' then
    --         gameState = 'menu'
    --     end
    --elseif gameState == 'playing' then
    if key == 'w' or key == 'up' then cycle1.dir = 'up' end
    if key == 's' or key == 'down' then cycle1.dir = 'down' end
    if key == 'a' or key == 'left' then cycle1.dir = 'left' end
    if key == 'd' or key == 'right' then cycle1.dir = 'right' end
    --end
end

function moveCycle(cycle, dt)
    local prevX, prevY = cycle.x, cycle.y
    table.insert(cycle.trail, { x = prevX, y = prevY }) -- Edit Trail location, orig = { x = cycle.x, y = cycle.y })

    if cycle.dir == 'up' then cycle.y = cycle.y - cycleSpeed * dt end
    if cycle.dir == 'down' then cycle.y = cycle.y + cycleSpeed * dt end
    if cycle.dir == 'left' then cycle.x = cycle.x - cycleSpeed * dt end
    if cycle.dir == 'right' then cycle.x = cycle.x + cycleSpeed * dt end

    if checkCollision(cycle) then
        cycle.x, cycle.y = prevX, prevY
    end
end

function drawCycle(cycle)
    local scaleX = cycle.scale
    local scaleY = cycle.scale
    local angle = directionAngles[cycle.dir]

    local imageWidth = cycle.image:getWidth() * scaleX
    local imageHeight = cycle.image:getHeight() * scaleY

    local drawX = cycle.x + imageWidth / 240
    local drawY = cycle.y + imageHeight / 60

    love.graphics.draw(cycle.image, drawX, drawY, angle, scaleX, scaleY,
        imageWidth / 2, imageHeight / 2)
end

function drawTrail(cycle)
    love.graphics.setLineWidth(fixedLineWidth)
    love.graphics.setColor(cycle.color)

    for i = 1, #cycle.trail - 1 do
        local p1 = cycle.trail[i]
        local p2 = cycle.trail[i + 1]
        love.graphics.line(p1.x, p1.y, p2.x, p2.y)
    end
end

function drawWalls()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    love.graphics.draw(wallImage, 0, 0, 0, screenWidth / wallWidth, wallHeight / wallHeight)

    love.graphics.draw(wallImage, 0, screenHeight - wallHeight, 0, screenWidth / wallWidth, wallHeight / wallHeight)

    love.graphics.draw(wallImage, 0, 0, 0, wallWidth / wallWidth, screenHeight / wallHeight)

    love.graphics.draw(wallImage, screenWidth - wallWidth, 0, 0, wallWidth / wallWidth, screenHeight / wallHeight)
end

function debugCycleTrail(cycle)
    print("Trail length: ", #cycle.trail)
    for i, point in ipairs(cycle.trail) do
        print("Point ", i, ": ", point.x, point.y)
    end
end

function pointToSegmentDistance(px, py, x1, y1, x2, y2)
    local lineLengthSquared = (x2 - x1) ^ 2 + (y2 - y1) ^ 2
    if lineLengthSquared == 0 then
        return math.sqrt((px - x1) ^ 2 + (py - y1) ^ 2)
    end
    local t = ((px - x1) * (x2 - x1) + (py - y1) * (y2 - y1)) / lineLengthSquared
    t = math.max(0, math.min(1, t))
    local projectionX = x1 + t * (x2 - x1)
    local projectionY = y1 + t * (y2 - y1)
    return math.sqrt((px - projectionX) ^ 2 + (py - projectionY) ^ 2)
end

function checkCollision(cycle)
    local imageWidth = cycle.image:getWidth() * cycle.scale
    local imageHeight = cycle.image:getHeight() * cycle.scale
    local collisionDistance = fixedLineWidth + imageWidth -- Adjust this to match the trail's visual width

    -- Check collision with the trail
    for i = 1, #cycle.trail - 1 do
        local p1 = cycle.trail[i]
        local p2 = cycle.trail[i + 1]
        local distance = pointToSegmentDistance(cycle.x,
            cycle.y, p1.x, p1.y, p2.x, p2.y)

        print(string.format("Checking collision: Distance to segment (%d, %d) - (%d, %d) is %f", p1.x, p1.y, p2.x, p2.y,
            distance)) -- debug info
        if distance < collisionDistance then
            return true
        end
    end

    local otherCycle = (cycle == cycle1) and cycle2 or cycle1
    for i = 1, #otherCycle.trail - 1 do
        local p1 = otherCycle.trail[i]
        local p2 = otherCycle.trail[i + 1]
        local distance = pointToSegmentDistance(cycle.x, cycle.y, p1.x, p1.y, p2.x, p2.y)
        if distance < collisionDistance then
            return true
        end
    end

    if cycle.x < 0 or cycle.x + imageWidth > love.graphics.getWidth() or
        cycle.y < 0 or cycle.y + imageHeight > love.graphics.getHeight() then
        return true
    end

    return false
end

function changeAIDirection(cycle)
    local possibleDirections = { 'up', 'down', 'left', 'right' }

    local oppositeDir = getOppositeDirection(cycle.dir)
    for i = #possibleDirections, 1, -1 do
        if possibleDirections[i] == oppositeDir then
            table.remove(possibleDirections, i)
        end
    end
    repeat
        newDir = possibleDirections[math.random(#possibleDirections)]
    until not isDirectionBlocked(cycle, newDir)

    cycle.dir = newDir
end

function getOppositeDirection(direction)
    if direction == 'up' then
        return 'down'
    elseif direction == 'down' then
        return 'up'
    elseif direction == 'left' then
        return 'right'
    elseif direction == 'right' then
        return 'left'
    end
end

function isDirectionBlocked(cycle, direction)
    local nextX = cycle.x
    local nextY = cycle.y
    if direction == 'up' then
        nextY = nextY - gridSize
    elseif direction == 'down' then
        nextY = nextY + gridSize
    elseif direction == 'left' then
        nextX = nextX - gridSize
    elseif direction == 'right' then
        nextX = nextX + gridSize
    end

    if nextX < 0 or nextX >= love.graphics.getWidth() or
        nextY < 0 or nextY >= love.graphics.getHeight() then
        return true
    end

    for _, point in ipairs(cycle1.trail) do
        if nextX == point.x and nextY == point.y then
            return true
        end
    end

    for _, point in ipairs(cycle2.trail) do
        if nextX == point.x and nextY == point.y then
            return true
        end
    end

    return false
end

function calculateFreeSpace(x, y)
    local space = 0
    local directions = { 'up', 'down', 'left', 'right' }

    if x < 0 or x >= love.graphics.getWidth() or
        y < 0 or y >= love.graphics.getHeight() then
        return true
    end

    for _, point in ipairs(cycle1.trail) do
        if x == point.x and y == point.y then
            return true
        end
    end

    for _, point in ipairs(cycle2.trail) do
        if x == point.x and y == point.y then
            return true
        end
    end

    return false
end
