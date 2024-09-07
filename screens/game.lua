local love = require "love"
local Text = require "assets/text"

function Game(save_data)
    return {
        level = 1,
        state = {
            menu = false,
            paused = false,
            running = true,
            ended = false
        },
        score = 0,
        high_score = 0,
        screen_text = {},
        game_over_showing = false,

        changeGameState = function(self, state)
            self.state.menu = state == "menu"
            self.state.paused = state == "paused"
            self.state.running = state == "running"
            self.state.ended = state == "ended"

            if self.state.ended then
                self:gameOver()
            end
        end,

        gameOver = function(self)
            self.screen_text = { Text(
                "GAME OVER",
                0,
                love.graphics.getHeight() * 0.4,
                "h1",
                true,
                true,
                love.graphics.getWidth(),
                "center"
            ) }

            self.game_over_showing = true
        end,

        draw = function(self, faded)
            local opacity = 1

            if faded then
                opacity = 0.2
            end

            for index, text in pairs(self.screen_text) do
                if self.game_over_showing then
                    self.game_over_showing = text:draw(self.screen_text, index)

                    if not self.game_over_showing then
                        self:changeGameState("menu")
                    end
                else
                    text:draw(self.screen_text, index)
                end
            end

            Text(
                "SCORE: " .. self.score,
                -80,
                10,
                "h4",
                false,
                false,
                love.graphics.getWidth(),
                "right",
                faded and opacity or 0.8
            ):draw()

            Text(
                "HIGH SCORE: " .. self.high_score,
                0,
                10,
                "h5",
                false,
                false,
                love.graphics.getWidth(),
                "center",
                faded and opacity or 0.8
            ):draw()

            if faded then
                Text(
                    "PAUSED",
                    0,
                    love.graphics.getHeight() * 0.6,
                    "h1",
                    false,
                    false,
                    love.graphics.getWidth(),
                    "center",
                    1
                ):draw()
            end
        end,

        startNewGame = function(self, tron)
            if tron.lives <= 0 then
                self:changeGameState("ended")
                return
            else
                self:changeGameState("running")
            end
        end
    }
end

return Game
