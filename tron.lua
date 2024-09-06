tron =
{
    x = 100,
    y = 100,
    dir = 'right',
    trail = {},
    image = nil,
    color = { 0, 50, 255 },
    scale = 1,
    lastScore = 0,
    score = 0,
    cycleSpeed = 200,
}

function tron:update(dt)
    if self.lastScore < self.nextEarnLife * 1000 and self.score >= self.nextEarnLife * 1000 then
        self.life = self.life + 1
        self.nextEarnLife = self.nextEarnLife + 1
        -- SoundExtra:play()
    end

    self.lastScore = self.score
end

function love.keypressed(key)
    if key == 'w' or key == 'up' then tron.dir = 'up' end
    if key == 's' or key == 'down' then tron.dir = 'down' end
    if key == 'a' or key == 'left' then tron.dir = 'left' end
    if key == 'd' or key == 'right' then tron.dir = 'right' end
end
