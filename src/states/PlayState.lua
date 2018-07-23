--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.locked = params.locked
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.lockedB = LockedBrick()
    self.ball = tBalls

    self.level = params.level

    -- init powerup and randomizer flag
    self.powerup = Powerup()
    powerupRandomized = false

    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.ball[1].dx = math.random(-200, 200)
    self.ball[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- bary paddle size by health and score
    if self.health == 3 then
        self.paddle.width = 64
        self.paddle.size = 2
    elseif self.health == 2 then
        self.paddle.width = 96
        self.paddle.size = 3
    elseif self.health == 1 then
        self.paddle.width = 128
        self.paddle.size = 4
    end
    if self.score > 5000 and self.health == 3 then
        self.paddle.width = 32
        self.paddle.size = 1
    elseif self.score > 5000 and self.health == 2 then
        self.paddle.width = 64
        self.paddle.size = 2
    elseif self.score > 5000 and self.health == 1 then
        self.paddle.width = 96
        self.paddle.size = 3
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    --update positions for every ball in table(in game)
    for k,v in pairs(self.ball) do
        self.ball[k]:update(dt)
    end

    for k,v in pairs(self.ball) do
        if self.ball[k]:collides(self.paddle)then
            -- raise ball above paddle in case it goes below it, then reverse dy
            self.ball[k].y = self.paddle.y - 8
            self.ball[k].dy = -self.ball[k].dy
            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
        if self.ball[k].x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            self.ball[k].dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball[k].x))
        
        -- else if we hit the paddle on its right side while moving right...
        elseif self.ball[k].x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
            self.ball[k].dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball[k].x))
        end

        gSounds['paddle-hit']:play()
        end
    end

    -- if powerup is in play update it and expect collision
    -- if it reaches bottom of the screen then reset it
    if powerupInPlay == true then
        self.powerup:update(dt)
        self.powerup:pickup(self.paddle)
        if self.powerup.y >= VIRTUAL_HEIGHT - self.powerup.height then
            self.powerup:reset()
        end
    end

    -- update lockedblock collision and scoring for every ball in table (in game)
    for k,v in pairs(self.ball) do
        if self.lockedB.inPlay == true and self.ball[k]:collides(self.lockedB) then
            if self.ball[k].x + 2 < self.lockedB.x and self.ball[k].dx > 0 then
                    
            -- flip x velocity and reset position outside of brick
            self.ball[k].dx = -self.ball[k].dx
            self.ball[k].x = self.lockedB.x - 8
                
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif self.ball[k].x + 6 > self.lockedB.x + self.lockedB.width and self.ball[k].dx < 0 then
                
                -- flip x velocity and reset position outside of brick
                self.ball[k].dx = -self.ball[k].dx
                self.ball[k].x = self.lockedB.x + 32
            
            -- top edge if no X collisions, always check
            elseif self.ball[k].y < self.lockedB.y then
                
                -- flip y velocity and reset position outside of brick
                self.ball[k].dy = -self.ball[k].dy
                self.ball[k].y = self.lockedB.y - 8
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of brick
                self.ball[k].dy = -self.ball[k].dy
                self.ball[k].y = self.lockedB.y + 16
            end

            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(self.ball[k].dy) < 150 then
                self.ball[k].dy = self.ball[k].dy * 1.02
            end

            if self.lockedB.inPlay == true and haveKey == true and self.ball[k]:collides(self.lockedB) then
                self.score = self.score + 9000
                self.lockedB:hit()
            end
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        -- only check collision if we're in play
        for k,v in pairs(self.ball) do
            if brick.inPlay and self.ball[k]:collides(brick) then

                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if self.ball[k].x + 2 < brick.x and self.ball[k].dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    self.ball[k].dx = -self.ball[k].dx
                    self.ball[k].x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif self.ball[k].x + 6 > brick.x + brick.width and self.ball[k].dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    self.ball[k].dx = -self.ball[k].dx
                    self.ball[k].x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif self.ball[k].y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    self.ball[k].dy = -self.ball[k].dy
                    self.ball[k].y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    self.ball[k].dy = -self.ball[k].dy
                    self.ball[k].y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(self.ball[k].dy) < 150 then
                    self.ball[k].dy = self.ball[k].dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    for k,v in pairs(self.ball) do
        if self.ball[k].y >= VIRTUAL_HEIGHT and #self.ball < 2 then
            self.health = self.health - 1
            gSounds['hurt']:play()
            table.remove(tBalls, 2)
            table.remove(tBalls, 3)
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        elseif self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        end

        if self.ball[k].y >= VIRTUAL_HEIGHT then
            table.remove(self.ball, k)
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.lockedB:render()
    self.paddle:render()
    -- self.ball[1]:render()

    for k, v in pairs(self.ball) do
        self.ball[k]:render()
    end

    -- use counter to check if we need to render powerup
    if hitCounter >= 3 then
        if powerupRandomized == false then
            self.powerup.randomPowerup = math.random(2)
            if haveKey == true and self.lockedB.inPlay == true then
                self.powerup.randomPowerup = 1
            elseif haveKey == false and self.lockedB.inPlay == false then
                self.powerup.randomPowerup = 1
            end
            powerupRandomized = true
        end
        powerupInPlay = true
        self.powerup:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.printf(hitCounter, 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    if self.lockedB.inPlay == true then
        return false
    end

    return true
end