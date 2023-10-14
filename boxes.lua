import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/keyboard"

local gfx <const> = playdate.graphics

-- box logic

function drawBox(x, y, w, h)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x, y, w, h)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(x, y, w, h)
end

function buttonBox(x, y, w, h)
    drawBox(x, y, w, h)

    ball_x, ball_y, ball_r = x + (w/2), y + (h/2), 16
    
    gfx.drawCircleAtPoint(x+(w/2), y+(h/2), 16)
end

-- box manage + layout

screen_w, screen_h = playdate.display.getWidth(), playdate.display.getHeight()
box_w, box_h = 120, 120
buffer_w = screen_w - (box_w * 3)
mid_x, mid_y = (screen_w - buffer_w) / 2, screen_h / 2
half_w, half_h = box_w / 2, box_h / 2

boxes = { buttonBox }
layouts = {
    -- initial: center
    { { x = mid_x - half_w, y = mid_y - half_h, } },
    -- 2: parallel
    { { x = 40, y = mid_y - half_h, }, { x = 200, y = mid_y - half_h, } },
    -- 3: T-shape
    { { x = 40, y = 0, }, { x = 200, y = 0, }, { x = mid_x - half_w, y = mid_y, } },
    -- 4: small grid
    { 
        { x = 40, y = 0, }, { x = 200, y = 0, },
        { x = 40, y = mid_y, }, { x = 200, y = mid_y, }
    },
    -- 5: trapezoid
    {
        { x = 0, y = 0, }, { x = box_w, y = 0, }, { x = box_w * 2, y = 0, },
        { x = 40, y = mid_y, }, { x = 200, y = mid_y, }
    },
    -- 6: full grid
    {
        { x = 0,         y = 0, },
        { x = box_w,     y = 0, },
        { x = box_w * 2, y = 0, },
        { x = 0,         y = box_h, },
        { x = box_w,     y = box_h, },
        { x = box_w * 2, y = box_h, },
    }
}

currentBoxes = {}

function setBox(bIndx)
    currentBoxes = {}
    for i = 1, #layouts[bIndx] do
        currentBoxes[i] = layouts[bIndx][i]
        currentBoxes[i].run = boxes[i] ~= nil and boxes[i] or buttonBox
    end
end

boxIndex = 1
setBox(boxIndex)
function runBoxes()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(box_w * 3, 0, box_w * 3, screen_h)
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(.5)
    gfx.fillRect(0, 0, box_w * 3, screen_h)
    gfx.setDitherPattern(.9)
    gfx.fillRect(box_w * 3, 0, box_w * 3, screen_h)
    gfx.setDitherPattern(0)
    gfx.drawRect(box_w * 3, 0, box_w * 3, screen_h)

    for i = 1, #currentBoxes do
        currentBoxes[i].run(currentBoxes[i].x, currentBoxes[i].y, box_w, box_h)
    end

    if playdate.buttonJustReleased(playdate.kButtonA) then
        boxIndex += 1
        setBox(boxIndex)
    end
    return true
end