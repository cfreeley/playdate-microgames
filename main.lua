import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "dialogue"
import "boxes"

local gfx <const> = playdate.graphics
local playerSprite = nil

-- A function to set up our game environment.

function initGraphics()
    local playerImage = gfx.image.new("Images/playerImage")
    playerSprite = gfx.sprite.new(playerImage)
    playerSprite:moveTo(0, 0)
end

initGraphics()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

BOTTOM, TOP, LEFT, RIGHT = 240, 0, 0, 400
rooms, roomIdx = { { run = runDialogue, offload = offloadDialogue }, { run = runBoxes, offload = offloadBoxes } }, 1
function playdate.update()
    -- Call the functions below in playdate.update() to draw sprites and keep
    -- timers updated. (We aren't using timers in this example, but in most
    -- average-complexity games, you will.)

    gfx.sprite.update()
    playdate.timer.updateTimers()
    curRoom = rooms[(roomIdx % 2) + 1]
    isActive = curRoom.run()
    if not isActive then
        curRoom.offload()
        roomIdx += 1
    end
end
