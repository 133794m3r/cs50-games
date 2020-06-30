Paddle = Class{}

function Paddle:init(x,y,width,height,color)
	self.x=x
	self.y=y
	self.width=width
	self.height=height
	local default={1,1,1}
	color = color == nil and default or color
	self.color=color
	self.dy=0
end

function Paddle:update(dt)

	if self.dy < 0 then
		self.y = math.max(0,self.y+self.dy*dt)
	else
		self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y+self.dy*dt)
	end
end

function Paddle:draw()
	love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
	love.graphics.setColor(1,1,1)
end

Ai = Class{}


function Ai:init(level, move_speed)
	self.level = level
	self.move_speed = move_speed
	self.cur_bonus = 0
	self.mid = 10
end


function Ai:update(dt)
	local acceleration=1.0
	local dif = player2.x - ball.x
	if dif < 200 then
		MODIFIED_TICK_DELAY=0.90
	elseif dif < 100 then
		MODIFIED_TICK_DELAY=0.8
	elseif dif < 50 then
		MODIFIED_TICK_DELAY=0.7
	elseif dif < 25 then
		MODIFIED_TICK_DELAY=0.25
	else
		MODIFIED_TICK_DELAY=1
	end
	
	if ball.y < player2.y then
		difference=(player2.y - ball.y) / VIRTUAL_HEIGHT
		if difference <= 9 then
			acceleration=1.125
		elseif difference > 10 then
			acceleration = 1.25
		elseif difference > 20 then
			acceleration = 1.65
		elseif difference > 40 then
			acceleration=1.85
		elseif difference > 60 then
			acceleration=3.9
		elseif difference > 75 then
			acceleration=7
		elseif difference > 85 then
			acceleration=12
		end
		player2.y = math.max(0,player2.y+(-self.move_speed*(dt*acceleration)))
	elseif ball.y > (player2.y+player2.height) then
		difference=(ball.y - player2.y) / VIRTUAL_HEIGHT
		if difference <= 9 then
			acceleration=1.125
		elseif difference > 10 then
			acceleration = 1.24
		elseif difference > 20 then
			acceleration = 1.65
		elseif difference > 40 then
			acceleration=1.85
		elseif difference > 60 then
			acceleration=3.9
		elseif difference > 75 then
			acceleration=7
		elseif difference > 85 then
			acceleration=12
		end
		player2.y = math.min(VIRTUAL_HEIGHT - player2.height, player2.y+(self.move_speed*(dt*acceleration)))
	end

	if player2.y < 0 then
		player2.y = 0
	--else
		--player2.y = math.min(VIRTUAL_HEIGHT - player2.height,player2.y)
	end

end
