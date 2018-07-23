-- Represents powerups which should spawn after certain number of hits to the block are achieved
-- they float down from block hit and player grabs them by colliding with the paddle

Powerup = Class{}

function Powerup:init()
	self.x = VIRTUAL_WIDTH / 2
	self.y = VIRTUAL_HEIGHT / 3
	
	self.randomPowerup = nil

	self.paddle = Paddle()
	self.ball = Ball()
	self.balls = tBalls

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
	powerupRandomized = false
	hitCounter = 0
	if self.randomPowerup == 1 then
    	tBalls[1] = Ball()
    	tBalls[2] = Ball()
    	tBalls[3] = Ball()
    	self.balls[1].skin = math.random(7)
    	self.balls[1].dx = math.random(-200, 200)
    	self.balls[1].dy = math.random(-50, -60)
    	self.balls[2].dx = math.random(-200, 200)
    	self.balls[2].dy = math.random(-50, -60)
    	self.balls[2].skin = math.random(7)
    	self.balls[3].dx = math.random(-200, 200)
    	self.balls[3].dy = math.random(-50, -60)
    	self.balls[3].skin = math.random(7)
	elseif self.randomPowerup == 2 then
		haveKey = true
	end
    return true
end

function Powerup:reset()
	self.x = VIRTUAL_WIDTH / 2
	self.y = VIRTUAL_HEIGHT / 3

    powerupInPlay = false
    hitCounter = 0
end

function Powerup:update(dt)
	if self.randomPowerup == 1 then
		self.y = self.y + self.dy * dt
	elseif self.randomPowerup == 2 then
		if self.y < self.paddle.y-8 then
		self.y = self.y + self.dy * dt
		elseif self.y > self.paddle.y then
			self.y = self.paddle.y - 8
		end
	end
end

function Powerup:render()
	if powerupInPlay == true then
		love.graphics.draw(gTextures['main'], gFrames['powerups'] [self.randomPowerup], self.x, self.y)
	end
end