import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/keyboard"

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
convIndex = 1
textIndex = 1
-- returns if still active
function runDialogue()
    playdate.graphics.drawText(conversations[convIndex][textIndex], 16, 16)

    if playdate.buttonJustReleased(playdate.kButtonA) then
        textIndex = textIndex + 1
    end

    if textIndex > #conversations[convIndex] then
        textIndex = 1
        convIndex = convIndex + 1
        return false
    end
    return true
end
