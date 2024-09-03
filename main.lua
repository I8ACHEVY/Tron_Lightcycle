require 'debug'

local cycle1 = { x = 100, y = 100, dir = 'right', trail = {}, image = nil, color = { 0, 0, 1 }, scale = 0.3 }
local cycle2 = { x = 1000, y = 800, dir = 'left', trail = {}, image = nil, color = { 1, 0, 0 }, ai = true, scale = 0.3 }
local gridSize = 40
local cycleSpeed = 200
local aiChangeInterval = 1
local aiTimer = 0
local fixedLineWidth = 5

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

    cycle1.image = love.graphics.newImage('assets/images/Tron1.png')
    cycle2.image = love.graphics.newImage('assets/images/Tron2.png')
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
    drawTrail(cycle1)
    drawTrail(cycle2)

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
    table.insert(cycle.trail, { x = cycle.x, y = cycle.y })

    if cycle.dir == 'up' then cycle.y = cycle.y - cycleSpeed * dt end
    if cycle.dir == 'down' then cycle.y = cycle.y + cycleSpeed * dt end
    if cycle.dir == 'left' then cycle.x = cycle.x - cycleSpeed * dt end
    if cycle.dir == 'right' then cycle.x = cycle.x + cycleSpeed * dt end
end

-- draw a cycle with rotation
function drawCycle(cycle)
    local scaleX = cycle.scale
    local scaleY = cycle.scale
    local angle = directionAngles[cycle.dir]
    local imageWidth = cycle.image:getWidth() * scaleX
    local imageHeight = cycle.image:getHeight() * scaleY
    local drawX = cycle.x + imageWidth / 2
    local drawY = cycle.y + imageHeight / 2
    love.graphics.draw(cycle.image, drawX, drawY, angle, scaleX, scaleY, imageWidth / 2, imageHeight / 2)
end

function drawTrail(cycle)
    --     local scaleX = cycle.scale
    --     local scaleY = cycle.scale
    --     for _, point in ipairs(cycle.trail) do
    --         local angle = directionAngles[cycle.dir]
    --         local imageWidth = cycle.image:getWidth() * scaleX
    --         local imageHeight = cycle.image:getHeight() * scaleY
    --         local drawX = point.x + imageWidth / 2
    --         local drawY = point.y + imageHeight / 2
    --         love.graphics.draw(cycle.image, drawX, drawY, angle, scaleX, scaleY, imageWidth / 2, imageHeight / 2)
    --     end
    -- end

    love.graphics.setLineWidth('2')
    love.graphics.setColor(cycle.color)

    for i = 1, #cycle.trail - 1 do
        local p1 = cycle.trail[i]
        local p2 = cycle.trail[i + 1]
        love.graphics.line(p1.x, p1.y, p2.x, p2.y)
    end

    local latest = cycle.trail[#cycle.trail]
    love.graphics.circle('fill', latest.x, latest.y, fixedLineWidth / 2)
end

function checkCollision(cycle)
    local imageWidth = cycle.image:getWidth() * cycle.scale
    local imageHeight = cycle.image:getHeight() * cycle.scale

    for _, point in ipairs(cycle.trail) do
        if cycle.x == point.x and cycle.y == point.y then
            return true
        end
    end

    local otherCycle = (cycle == cycle1) and cycle2 or cycle1
    for _, point in ipairs(otherCycle.trail) do
        if cycle.x == point.x and cycle.y == point.y then
            return true
        end
    end


    if cycle.x < 0 or cycle.x + imageWidth > love.graphics.getWidth() or cycle.y < 0 or cycle.y + imageHeight > love.graphics.getHeight() then
        return true
    end

    return false
end

-- change the AI's direction
function changeAIDirection(cycle)
    local possibleDirections = { 'up', 'down', 'left', 'right' }
    local bestDirection = nil
    local maxFreeSpace = -1

    local oppositeDir = getOppositeDirection(cycle.dir)
    for i = #possibleDirections, 1, -1 do
        if possibleDirections[i] == oppositeDir then
            table.remove(possibleDirections, i)
        end
    end

    local newDir = possibleDirections[math.random(#possibleDirections)]


    while isDirectionBlocked(cycle, newDir) do
        newDir = possibleDirections[math.random(#possibleDirections)]
    end

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

    if nextX < 0 or nextX >= love.graphics.getWidth() or nextY < 0 or nextY >= love.graphics.getHeight() then
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

-- function calculateFreeSpace(x, y)
--     local space = 0
--     local directions = { 'up', 'down', 'left', 'right' }
--
--     for _, direction in ipairs(directions) do
--         local nextX, nextY = x, y
--         if direction == 'up' then
--             nextY = nextY - gridSize
--         elseif direction == 'down' then
--             nextY = nextY + gridSize
--         elseif direction == 'left' then
--             nextX = nextX - gridSize
--         elseif direction == 'right' then
--             nextX = nextX + gridSize
--         end

--         if not isCollision(nextX, nextY) then
--             space = space + 1
--         end
--     end
--     return space
-- end

-- function getOppositeDirection(direction)
--     if direction == 'up' then
--         return 'down'
--     elseif direction == 'down' then
--         return 'up'
--     elseif direction == 'left' then
--         return 'right'
--     elseif direction == 'right' then
--         return 'left'
--     end
-- end
