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
local cycleSpeed = 200


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
    local nextX, nextY = cycle.x, cycle.y

    if direction == 'up' then
        nextY = nextY - cycleSpeed
    elseif direction == 'down' then
        nextY = nextY + cycleSpeed
    elseif direction == 'left' then
        nextX = nextX - cycleSpeed
    elseif direction == 'right' then
        nextX = nextX + cycleSpeed
    end

    if nextX < 0 or nextX >= love.graphics.getWidth() or
        nextY < 0 or nextY >= love.graphics.getHeight() then
        return true
    end

    return calculateTrailCollision(nextX, nextY)
end

function calculateTrailCollision(x, y)
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

function getBestDirection(cycle)
    local bestDirection
    local maxDistance = math.huge

    local possibleDirections = { 'up', 'down', 'left', 'right' }
    local oppositeDir = getOppositeDirection(cycle.dir)

    for i = #possibleDirections, 1, -1 do
        if possibleDirections[i] == oppositeDir then
            table.remove(possibleDirections, i)
        end
    end

    for _, direction in ipairs(possibleDirections) do
        if not isDirectionBlocked(cycle, direction) then
            local nextX, nextY = cycle.x, cycle.y

            if direction == 'up' then
                nextY = nextY - cycleSpeed
            elseif direction == 'down' then
                nextY = nextY + cycleSpeed
            elseif direction == 'left' then
                nextX = nextX - cycleSpeed
            elseif direction == 'right' then
                nextX = nextX + cycleSpeed
            end

            local distance = getDistanceToNearestObstacle(nextX, nextY)

            if distance < maxDistance then
                maxDistance = distance
                bestDirection = direction
            end
        end
    end

    return bestDirection
end

function getDistanceToNearestObstacle(x, y)
    local minDistance = math.huge
    for _, point in ipairs(tron.trail) do
        local d = math.sqrt((x - point.x) ^ 2 + (y - point.y) ^ 2)
        if d < minDistance then
            minDistance = d
        end
    end

    for _, point in ipairs(abraxas.trail) do
        local d = math.sqrt((x - point.x) ^ 2 + (y - point.y) ^ 2)
        if d < minDistance then
            minDistance = d
        end
    end

    return minDistance
end

function changeAIDirection(cycle)
    --     local possibleDirections = { 'up', 'down', 'left', 'right' }
    --     local oppositeDir = getOppositeDirection(cycle.dir)

    --     for i = #possibleDirections, 1, -1 do
    --         if possibleDirections[i] == oppositeDir then
    --             table.remove(possibleDirections, i)
    --         end
    --     end
    --     repeat
    --         newDir = possibleDirections[math.random(#possibleDirections)]
    --     until not isDirectionBlocked(cycle, newDir)

    --     print("AI changeing direction to: " .. newDir)

    --     cycle.dir = newDir
    -- end

    local newDir = getBestDirection(cycle)
    if newDir then
        print("AI changing direction to: " .. newDir)
        cycle.dir = newDir
    end
end

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
