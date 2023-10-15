import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/keyboard"
import "boxes"

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

    bobSprite = gfx.sprite.new(bobOpenImg)
    bobSprite:moveTo(200, 120)   -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    bobSprite:add()              -- This is critical!
    bobSprite:setVisible(false)
end

initGraphics()

function offloadDialogue()
    bobSprite:setVisible(false)
end

lossConvos = {
    button = { "Oh buddy, what happened?\nYou didn't press the button in time!",
        "I'm gonna have to dock that from your pay.\nLet's try again, huh?" },
    crank = { "Oh buddy, what happened?\nYou let the song run out!",
        "Remember to turn the crank before it does.\nLet's try again, huh?" },
    sand= { "Oh buddy, what happened?\nYou let the hourglass run out!",
    "Remember to press \"DOWN\" to flip the hourglass\nbefore the sand runs out.\nLet's try again, huh?" },
    boat= { "My man, you almost killed me!\nYou've got to watch out for those icebergs.",
    "Remember to press \"LEFT\" and \"RIGHT\" to\nsteer the ship away. Let's try again, huh?" },
}

introText = {
    "Hello, your name is Joe. right?",
    "Excellent! Welcome to the Button Factory.\nWe're excited to have you join our family.",
    "Since you're not busy,\nhow about you help us with this button?",
    "It's very simple. When the light goes on,\npress \"B\". Get it? \"B\" for button!",
    "Easy as that.\nAnyway, how about you get started and I\ncome back when I find some more work for you?"
}

onboardCrankText = {
    "Hey Joe- are you busy?", "No? Wonderful!", "Can you keep an eye on this victrola?",
    "This music helps productivity but it needs to be\ncranked. If you ever hear the song start to\nrun out, just start cranking.",
    "And don't forget to keep pressing that button!"
}

onboardHourglassText = {
    "Hey Joe- are you busy?", "No? Wonderful!\nYou're on hourglass duty then.",
    "Make sure the hourglass doesn't run out of time.\nDon't ask why.\nHit the \"DOWN\" button before the sand runs\nout to flip it over.",
    "And don't forget to keep pressing that button!", "Or winding that victrola."
}

onboardBoatText = {
    "Greetings from the Carribean!\n",
    "I decided to take a well-deserved vacation.\nProblem is I need to take a nap, but someone\nneeds to steer my yacht.",
    "If you could give a hand, that'd be great.\nYou can use \"LEFT\" and \"RIGHT\" to remotely steer.\nPretty cool, right?",
    "And don't forget to keep pressing that button!", "Or winding that victrola.", "Or flipping that hourglass."
}

victoryText = {
    "Congratulations, you did it!", "You're position is no longer required and\nyour employment has been released!"
}

conversations = { introText, onboardCrankText, onboardHourglassText, onboardBoatText, victoryText }
convIndex, textIndex, animIdx, chatIdx = 1, 1, 1, 1

-- returns if still active
function runDialogue()
    bobSprite:setVisible(true)
    curConv = conversations[convIndex]

    if lossReason ~= nil then
        curConv = lossConvos[lossReason]
    end

    curTxt = curConv[textIndex] or ":)"
    gfx.drawText(curTxt:sub(0, animIdx), 16, 16)

    animIdx += 1
    if (animIdx % 4 == 0) then
        chatIdx += 1
    end

    bobSprite:setImage((chatIdx % 2 == 1 or animIdx > curTxt:len()) and bobCloseImg or bobOpenImg)

    if playdate.buttonJustReleased(playdate.kButtonA) then
        if animIdx < curTxt:len() then
            animIdx = curTxt:len()
        else
            animIdx = 0
            chatIdx = 0
            textIndex += 1
        end
    end

    if textIndex > #curConv or playdate.buttonJustPressed(playdate.kButtonB) then
        if convIndex >= #conversations and lossReason == nil then
            return true
        end

        if lossReason == nil then
            convIndex += 1
        else
            lossReason = nil
        end

        textIndex = 1
        return false
    end

    return true
end
