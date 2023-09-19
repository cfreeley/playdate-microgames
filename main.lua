-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics
local playerSprite = nil

-- A function to set up our game environment.

function myGameSetUp()

    local playerImage = gfx.image.new("Images/playerImage")
    assert( playerImage ) -- make sure the image was where we thought

    playerSprite = gfx.sprite.new( playerImage )
    playerSprite:moveTo( 200, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    playerSprite:add() -- This is critical!

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

vspeed, hspeed, gravity, friction = 0, 0, 1, .9
BOTTOM, TOP, LEFT, RIGHT = 240,0,0,400
function playdate.update()

    if playerSprite.y >= BOTTOM or playerSprite.y <= TOP then
        vspeed = vspeed * -1
    else
        vspeed = math.min(20, gravity + vspeed)
    end   
    
    rot = playdate.getCrankTicks(360)
    if playerSprite.x >= RIGHT or playerSprite.x <= LEFT then
        hspeed = hspeed * -1
    elseif rot ~= nil and rot ~= 0 then
        hspeed = hspeed + (rot / 20)
    elseif hspeed ~= 0 then
        hspeed = hspeed * friction
    end   
    
    ypos = playerSprite.y + vspeed
    playerSprite:moveBy( hspeed, vspeed )

    playerSprite:setRotation(playerSprite:getRotation() + rot)

    -- Call the functions below in playdate.update() to draw sprites and keep
    -- timers updated. (We aren't using timers in this example, but in most
    -- average-complexity games, you will.)

    gfx.sprite.update()
    playdate.timer.updateTimers()

end