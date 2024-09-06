abraxas =
{
    x = 1200,
    y = 900,
    dir = 'left',
    trail = {},
    image = nil,
    ai = true,
    color = { 255, 50, 0 },
    scale = 1,
}

require 'tron'
local gridSize = 400
local cycleSpeed = 200

function moveCycle(cycle, dt)
    local prevX, prevY = cycle.x, cycle.y
    table.insert(cycle.trail, { x = prevX, y = prevY })

    if cycle.dir == 'up' then cycle.y = cycle.y - cycleSpeed * dt end
    if cycle.dir == 'down' then cycle.y = cycle.y + cycleSpeed * dt end
    if cycle.dir == 'left' then cycle.x = cycle.x - cycleSpeed * dt end
    if cycle.dir == 'right' then cycle.x = cycle.x + cycleSpeed * dt end
    if checkCollision(cycle) then
        cycle.x, cycle.y = prevX, prevY
    end
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

    for _, point in ipairs(tron.trail) do
        if nextX == point.x and nextY == point.y then
            return true
        end
    end

    for _, point in ipairs(abraxas.trail) do
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

    for _, point in ipairs(tron.trail) do
        if x == point.x and y == point.y then
            return true
        end
    end

    for _, point in ipairs(abraxas.trail) do
        if x == point.x and y == point.y then
            return true
        end
    end

    return false
end
