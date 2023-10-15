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

is_intro, is_endless, data = true, false, nil
select_idx, blink_timer, is_blinked = 1, 0, false
function introRoom()
    options = { "NEW" }
    data = playdate.datastore.read()
    if data ~= nil and data.roomId ~= nil and data.roomId > 1 then
        options[2] = "CONTINUE"
        if data.roomId > max_rooms then
            options[3] = "ENDLESS"
        end
    end
    
    cursor_height = BOTTOM / 2 + (select_idx - 1) * 30 + 10
    gfx.fillTriangle(70, cursor_height, 65, cursor_height - 5, 65, cursor_height + 5)
    for i=1, #options do
        gfx.drawText(options[i], 80, BOTTOM / 2 + (i-1) * 30)
    end

    if playdate.buttonJustPressed(playdate.kButtonDown) and select_idx < #options then
        select_idx += 1
    elseif playdate.buttonJustPressed(playdate.kButtonUp) and select_idx > 1 then
        select_idx -= 1
    end

    blink_timer += 1
    if blink_timer % 24 == 0 then
        is_blinked = not is_blinked
    end

    gfx.drawRect(RIGHT / 4, BOTTOM / 4 - 16, RIGHT / 2, 50)
    if is_blinked then
        gfx.fillRect(RIGHT / 4, BOTTOM / 4 - 16, RIGHT / 2, 50)
        gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
    end
    gfx.drawTextAligned("BUTTON FACTORY", RIGHT / 2, BOTTOM / 4, kTextAlignment.center)
    gfx.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)

    if playdate.buttonJustPressed(playdate.kButtonA) then
        is_intro = false
        if options[select_idx] == "CONTINUE" then
            setBox(data.roomId)
        elseif options[select_idx] == "ENDLESS" then
            is_endless = true
            setBox(max_rooms)
        end
    end
end

function playdate.gameWillTerminate()
    playdate.datastore.write({ roomId= boxIndex})
    printTable(playdate.datastore.read())
end

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

BOTTOM, TOP, LEFT, RIGHT = 240, 0, 0, 400
rooms, roomIdx, max_rooms = { { run = runDialogue, offload = offloadDialogue }, { run = runBoxes, offload = offloadBoxes } }, 0, 4
function playdate.update()
    -- Call the functions below in playdate.update() to draw sprites and keep
    -- timers updated. (We aren't using timers in this example, but in most
    -- average-complexity games, you will.)

    gfx.sprite.update()
    playdate.timer.updateTimers()

    if is_intro then
        introRoom()
        return
    end

    curRoom = rooms[(roomIdx % 2) + 1]
    isActive = curRoom.run()
    if not isActive then
        curRoom.offload()
        roomIdx += 1
    end
end
