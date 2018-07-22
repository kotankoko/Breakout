-- Represents powerups which should spawn after certain number of hits to the block are achieved
-- they float down from block hit and player grabs them by colliding with the paddle

Powerup = Class{}

function Powerup:init()
	self.x = VIRTUAL_WIDTH / 2
	self.y = VIRTUAL_HEIGHT / 3
	self.randomPowerup = math.random(1)

	self.width = 16
	self.height = 16

	self.dy = 20
end

--Expects collision with the paddle
--if collision is detected powerup is despawned it's position reset and effect applied

function Powerup:pickup(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

-- i don't know why it won't work if i just use Powerup:reset() here
-- if i just use reset function, power up will not properly reset it's position
-- it will stay and respawn at or close to position at which it was picked up
	self.x = VIRTUAL_WIDTH / 2
	self.y = VIRTUAL_HEIGHT / 3

    powerupInPlay = false
    hitCounter = 0
    spawnBalls = 3
    tBall['ball2'] = Ball()
    tBall['ball3'] = Ball()
    return true
end

function Powerup:reset()
	self.x = VIRTUAL_WIDTH / 2
	self.y = VIRTUAL_HEIGHT / 3

    powerupInPlay = false
    hitCounter = 0
    table.remove(tBall, 2)
    table.remove(tBall, 3)
end

function Powerup:update(dt)
	self.y = self.y + self.dy * dt
end

function Powerup:render()
	if powerupInPlay == true then
		love.graphics.draw(gTextures['main'], gFrames['powerups'] [1], self.x, self.y)
	end
end