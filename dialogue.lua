import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/keyboard"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics
local bobSprite = nil
local bobOpenImg, bobCloseImg


-- A function to set up our game environment.

function initGraphics()

    bobOpenImg = gfx.image.new("Images/bobHappy")
    bobCloseImg = gfx.image.new("Images/bobSmile")

    bobSprite = gfx.sprite.new( bobOpenImg )
    bobSprite:moveTo( 200, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    bobSprite:add() -- This is critical!

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

initGraphics()

introText = {
    "Hello, your name is Joe. right?",
    "Excellent! Welcome to the Button Factory.\nWe're excited to have you join our family.",
    "Since you're not busy,\nhow about you help us with this button?",
    "It's very simple. When the light goes on,\npress \"B\". Get it? \"B\" for button!",
    "Easy as that.\nAnyway, how about you get started and I\ncome back when I find some more work for you?"
}

onboardCrankText = {
    "Hey Joe- are you busy?", "No? Wonderful!", "Can you keep an eye on this victrola?", "This music helps productivity but it needs to be\ncranked. If you ever hear the song start to\nrun out, just start cranking.", "And don't forget to keep pressing that button!"
}

conversations = { introText, onboardCrankText }
convIndex, textIndex, animIdx, chatIdx = 1, 1, 1, 1

-- returns if still active
function runDialogue()
    curTxt = conversations[convIndex][textIndex]
    gfx.drawText(curTxt:sub(0, animIdx), 16, 16)

    animIdx += 1
    if (animIdx % 4 == 0) then
        chatIdx += 1
    end

    bobSprite:setImage((chatIdx % 2 == 1 or animIdx > curTxt:len()) and bobCloseImg or bobOpenImg)

    if playdate.buttonJustReleased(playdate.kButtonA) then
        animIdx = 0
        chatIdx = 0
        textIndex = textIndex + 1
    end

    if textIndex > #conversations[convIndex] then
        textIndex = 1
        convIndex = convIndex + 1
        return false
    end

    -- gfx.sprite.update()
    return true
end
