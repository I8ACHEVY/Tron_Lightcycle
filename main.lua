require 'debug'
local Game = require 'screens/game'
local Menu = require 'screens/menu'

Highscore = {}
Tron = {}
Abraxas = {}

local aiChangeInterval = 1
local aiTimer = 0
local fixedLineWidth = 5

local wallImage = nil
local wallWidth = 10
local wallHeight = 10

local tronSurvivalTime = 0
local tronLives = 3
local lifeImage = nil

local resetComplete = false
local clickedMouse = false

local function reset()
    --     tron = tron(3, sfx)
    game = Game()
    menu = Menu()

    collision = false
end

local directionAngles = {
    up = -math.pi / 2,  -- 90 degrees counterclockwise
    down = math.pi / 2, -- 90 degrees clockwise
    left = math.pi,     -- 180 degrees
    right = 0           -- 0 degrees
}

function love.load()
    require "tron"
    require "abraxas"
    love.mouse.setVisible(false)
    love.window.setMode(1300, 1000)
    mouse_x, mouse_y = 0, 0
    reset()
    game = Game()
    menu = Menu(game, Tron)

    love.graphics.setBackgroundColor(0, 0, 0)

    Tron.image = love.graphics.newImage('assets/images/Tron_50.png')
    abraxas.image = love.graphics.newImage('assets/images/Tron2_50.png')

    wallImage = love.graphics.newImage('assets/images/wall.png')
    wallWidth = wallImage:getWidth()
    wallHeight = wallImage:getHeight()

    lifeImage = love.graphics.newImage('assets/images/Tron_33.png')
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if game.state.running then
            clickedMouse = false
        else
            clickedMouse = true
        end
    end
end

function love.update(dt)
    mouse_x, mouse_y = love.mouse.getPosition()
    if game.state.running then
        moveCycle(Tron, dt)
        moveCycle(abraxas, dt)
        if checkCollision(Tron) or checkCollision(abraxas) then
            if Tron.lives - 1 <= 0 then
                game:changeGameState("ended")
            end
        end
        if checkCollision(Tron) then
            tronLives = tronLives - 1
            if tronLives > 0 then
                Tron.x = 100
                Tron.y = 100
                Tron.dir = 'right'
                Tron.trail = {}
            else
                love.event.quit()
            end
        end
    end
    if not (checkCollision(Tron) or checkCollision(abraxas)) then
        tronSurvivalTime = tronSurvivalTime + dt * 2
        game.score = math.floor(tronSurvivalTime)
    end
    -- AI logic
    if abraxas.ai then
        aiTimer = aiTimer + dt
        if aiTimer >= aiChangeInterval then
            changeAIDirection(abraxas)
            aiTimer = 0
        end
    elseif game.state.menu then
        menu:run(clickedMouse)
        clickedMouse = false
        if not resetComplete then
            reset()
            resetComplete = true
        end
    elseif game.state.ended then
        resetComplete = false
    end
end

function love.draw()
    if game.state.running or game.state.paused then
        drawWalls()

        drawTrail(Tron)
        drawTrail(abraxas)

        love.graphics.setColor(1, 1, 1)
        drawCycle(Tron)
        drawCycle(abraxas)

        local lifeImageWidth = lifeImage:getWidth()
        local lifeImageHeight = lifeImage:getHeight()
        local livesStartX = 300
        local livesStartY = 6
        local spacing = lifeImageWidth + 10 -- Space between life images

        for i = 1, tronLives do
            love.graphics.draw(lifeImage, livesStartX + (i - 1) * spacing, livesStartY)
        end

        if tronLives <= 0 then
            love.graphics.setFont(love.graphics.newFont(48))
            love.graphics.setColor(1, 0, 0)
            love.graphics.printf("Game Over", 0, love.graphics.getHeight(
            ) / 2 - 50, love.graphics.getWidth(), "center")
        end

        game:draw(game.state.paused)
    elseif game.state.menu then
        menu:draw()
    end

    love.graphics.setColor(1, 1, 1, 1)

    if not game.state.running then
        love.graphics.circle('fill', mouse_x, mouse_y, 10)
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
    local collisionDistance = fixedLineWidth

    for i = 1, #cycle.trail - 10 do -- adjust trail starting point
        local p1 = cycle.trail[i]
        local p2 = cycle.trail[i + 1]
        local distance = pointToSegmentDistance(cycle.x,
            cycle.y, p1.x, p1.y, p2.x, p2.y)

        if distance < collisionDistance then
            return true
        end
    end

    local otherCycle = (cycle == Tron) and abraxas or Tron
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

function WriteScore()
    local tmp = {}
    tmp[1] = Tron.score
    for a = 1, #HighScore do
        table.insert(tmp, HighScore[a])
    end
    local reset = ''
    for a = 1, #tmp do
        reset = reset .. tmp[a] .. '\n'
    end
    local f = io.open('highscore.score', 'w+')
    if f ~= nil then
        f:write(reset)
        f:close()
    end
end

function FileExists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function LinesFrom(file)
    if not FileExists(file) then return { 0 } end
    Lines = {}
    for line in io.lines(file) do
        Lines[#Lines + 1] = tonumber(line)
    end
    return Lines
end

function GetHighScore()
    if FileExists('highscore.score') then
        HighScore = LinesFrom('highscore.score')
    else
        local f = io.open('highscore.score', 'w')
        if f ~= nil then
            f:write('0')
            f:close()
            HighScore = { 0 }
        end
    end
end
