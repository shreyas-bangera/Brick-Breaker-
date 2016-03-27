display.setStatusBar(display.HiddenStatusBar)

local physics = require("physics")

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local height = display.contentHeight
local width = display.contentWidth

--load audio
collect = audio.loadSound("bounce.wav")
ballSound = audio.loadSound("ball.wav")
bgSound = audio.loadSound("bg.wav")

audio.play( bgSound, {loops=-1})

bg = display.newImage("bg.jpg", centerX, centerY)
bg.height = height + 200

scoreValue = 0
life = 3

function main()
	setPhysics()
	createWall()
	createBricks()
	createBall()
	createPaddle()
	scoreCheck()
	ballVelocity()
	--startGame()
	reStart()
end

function setPhysics()
	physics.start( )
	physics.setGravity(0,0)
end

function createWall()
	--left wall
	local wall = display.newRect(0, 0, 10, height + 1200 )
	physics.addBody( wall, "static", {bounce=1, friction=0} )
	wall.isVisible = false
	--right wall
	wall = display.newRect(width, 0, 10, height + 1200 )
	physics.addBody( wall, "static", {bounce=1, friction=0} )
	wall.isVisible = false
	--top
	wall = display.newRect(0, -35, width + 400, 10 )
	physics.addBody( wall, "static", {bounce=1, friction=0} )
	wall.isVisible = false
	--bottom
	wall = display.newRect(0, centerY * 2 + 35, width + 400, 10 )
	physics.addBody( wall, "static", {bounce=1, friction=0} )
	wall.isVisible = false
	wall:setFillColor(255,255,255)

	wall.type = "bottomwall"
end

function createBricks()
	--color
	r= math.random(50,255)
	g= math.random(50,255)
	b= math.random(50,255)

	for i = 1, 5 do
		for j = 1, 4 do
			brick = display.newImage("brick.png", 0,0)
			brick.width = 50
			brick.height = 40
			brick.x = brick.x + (i * 55)
			brick.y = brick.y + (j * 50) - 30 
			physics.addBody(brick, "static", {bounce=1, friction=0})
			brick.type = "brick"
		end
	end
end

function createPaddle()
	paddle = display.newImage("paddle.png")
	paddle.x = centerX
	paddle.y = height - 50
	paddle.height = 20
	paddle.width = 80
	paddle.type = "paddle"
	physics.addBody(paddle, "static", {bounce=1, friction = 0})

	function movePaddle(event)
		paddle.x = event.x

		if(paddle.x < 0) then
			paddle.x = 0
		end

		if(paddle.x > width) then
			paddle.x = width
		end
	end
	Runtime:addEventListener("touch", movePaddle)
end

function createBall()
	ball = display.newImage("ball.png", centerX, centerY)
	ball.width = 20
	ball.height = 20
	physics.addBody( ball, "dynamic", {bounce=1, friction=0, radius=10} )


	function ball.collision(self, event)
		if(event.phase == "ended") then
			if(event.other.type == "brick") then
				event.other:removeSelf( )
				audio.play(collect)
				scoreValue = scoreValue + 10
				scoreBoard.text = ("Score : "..scoreValue)
				youWon()
			end

			if (event.other.type == "bottomwall") then
				self:removeSelf( )
				life = life - 1
				lifeText.text = "Life : "..life
				if (life <= 0) then
					ball:removeEventListener( "collision", ball )
					Runtime:removeEventListener("touch", movePaddle)
					gameOver()
				end

				function onComplete(event)
					if(life <= 0) then
						return
					else
						createBall()
						ballVelocity()
					end
				end

				timer.performWithDelay( 1500, onComplete, 1 )
			end

			if (event.other.type == "paddle") then
				audio.play(ballSound)
			end
		end
	end

	ball:addEventListener( "collision", ball, -1 )
end

function scoreCheck()
	scoreBoard = display.newText("Score : "..scoreValue, 120, 10, 210,80 ,"Akashi", 20 )
	lifeText = display.newText("Life : "..life, 120, width + 190 ,210,80 ,"Akashi", 20 )
end

function ballVelocity()
	ball:setLinearVelocity( -85, 300 )
end

function gameOver()
	gameover = display.newText("Game Over", centerX,  centerY - 400, 0, 180, "Akashi", 50)
	transition.to( gameover, {time=1000, y=centerY} )
	gameover:setFillColor( 0/255, 100/255, 0/255 )
end

function youWon(score)
	if (scoreValue == 200) then
		won = display.newText("You Won!", centerX,  centerY + 400, 0, 180, "Akashi", 50)
		transition.to( won, {time=1000, y=centerY} )
		won:setFillColor( 0/255, 100/255, 0/255 )

		ball:removeEventListener( "collision", ball )
		Runtime:removeEventListener("touch", movePaddle)
		scoreValue = scoreValue
		life = life
	end
end

function reStart()
	restart = display.newImage("restart.png", width -20, height)
	restart.height = 50
	restart.width = 50

	function reload(event)
		if (event.phase == "ended") then
			
		end
	end

	restart:addEventListener( "touch", reload )
end

function startGame()
	start = display.newText("Start", centerX,  centerY - 400, 0, 180, "Akashi", 50)
	transition.to( start, {time=2000, y=centerY} )

	function check(event)
		if(event.phase == "ended") then
			event.target:removeSelf( )
			main()
		end
	end
	start:addEventListener( "touch", check )
end 

startGame()
--main()










