PipePair = Class {}



function PipePair:init(y)
    -- flag to hold whether this pair has been scored (jumped through)
    self.scored = false

    -- initialize pipes past the end of the screen
    self.x = VIRTUAL_WIDTH + 32

    -- y value is for the topmost pipe; gap is a vertical shift of the second lower pipe
    self.y = y
    --[[
     Difficulty modifies how big the gaps are. The easier difficulty.
     If the person is playing on a harder difficulty the max gap height is 190, but if they are playing on easier difficulty the max is 220.
     ]]
    local gap_height_modifier = (gCurrentDifficulty) and 90 or 120
    -- instantiate two pipes that belong to this pair
    self.pipes = {
        ['top'] = Pipe('top', self.y),
        ['bottom'] = Pipe('bottom', self.y + PIPE_HEIGHT + (math.random(100)) + gap_height_modifier)
    }

    -- whether this pipe pair is ready to be removed from the scene
    self.remove = false
end

function PipePair:update(dt)
    -- remove the pipe from the scene if it's beyond the left edge of the screen,
    -- else move it from right to left
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['bottom'].x = self.x
        self.pipes['top'].x = self.x
    else
        self.remove = true
    end
end

function PipePair:render()
    for l, pipe in pairs(self.pipes) do
        pipe:render()
    end
end