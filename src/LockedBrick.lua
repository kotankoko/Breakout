LockedBrick = Class{}

function LockedBrick:init()

	hitCounter = 0

	self.x = VIRTUAL_WIDTH / 11
	self.y = VIRTUAL_HEIGHT / 2

	self.width = 32
    self.height = 16

    if LB == true then
        self.inPlay = true
    end
end

function LockedBrick:hit()
    -- sound on hit
    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()

    -- play a second layer sound if the brick is destroyed
    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end

    self.inPlay = false
    haveKey = false

    if powerupInPlay == false then
    hitCounter = hitCounter + 1
    end
end

function LockedBrick:render()
    if self.inPlay == true and LB == true then
            love.graphics.draw(gTextures['main'],gFrames['lockedbrick'][1],
            self.x, self.y)
    end
end