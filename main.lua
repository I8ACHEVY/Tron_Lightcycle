require("debug")

print("hello world")

local cycle1 = { x = 100, y = 100, dir = 'right', trail = {}, color = { 0, 1, 0 } }
local cycle2 = { x = 300, y = 300, dir = 'right', trail = {}, color = { 1, 0, 0 } ai = true }
local gridSize = 20
local cycleSpeed = 200
local aiChangeInterval = 1
local aiTimer = 0

function love.load()
    love.window.setMode(800, 600)
    love.graphics.setBackgroundColor(0, 0, 0)
end

function love.update(dt)
    moveCycle(cycle1, dt)
    moveCycle(cycle2, dt)

    if checkColission(cycle1) or checkCollision(cycle2) then
        love.event.quit()
    end

    if cycle2.ai then
        aiTimer = aiTimer + dt
        if aiTimer >= aiChangeInterval then
            changeAiDirection(cycle2)
            aiTimer = 0
        end
    end
end

function love.draw()
    drawTrail(cycle1)
    drawTrail(cycle2)

    drawCycle(cycle1)
    drawCycle(cycle2)
end

function love.keypressed(key)
    if key == 'w' or ' up' then cycle1.dir = 'up' end
    if key == 's' or 'down' then cycle1.dir = 'down' end
    if key == 'a' or 'left' then cycle1.dir = 'left' end
    if key == 'd' or 'right' then cycle1.dir = 'right' end
end

function moveCycle(cycle, dt)
    table.insert(cycle.trail, { x = cycle.x, y = cycle.y })

    if cycle.dir == 'up' then
        cycle.y = cycle.y - cycleSpeed * dt
    end

    if cycle.dir == 'down' then
        cycle.y = cycle.y + cycle.cycleSpeed * dt
    end

    if cycle.dir == 'left' then
        cycle.x = cycle.x - cycle.cycleSpeed * dt
    end

    if cycle.dir == 'right' then
        cycle.x = cycle.x + cycle.cycleSpeed * dt
    end
end

function drawCycle(cycle)
    love.graphics.setColor(cycle.color)
    love.graphics.rectangle('fill', cycle.x, cycle.y, gridSize, gridSize)
end

function drawTrail(cycle)
    love.graphics.setColor(cycle.color)
    for _, point in ipairs(cycle.Trail) do
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

    if cycle.x < 0 or cycle.x >= love.graphics.getWidth() or
        cycle.y < 0 or cycle.y >= love.graphics.getWidth() then
        return true
    end

    return false
end

function chnageAiDirection(cycle)
    local possibleDirection = { 'up', 'down', 'left', 'right' }

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
        nextX = nextX + gridSize
    elseif direction == 'right' then
        nextX = nextX - gridSize
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
