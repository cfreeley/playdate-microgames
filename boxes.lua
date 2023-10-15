import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/keyboard"

local gfx <const> = playdate.graphics
lossReason = nil

local alarmSprite = nil
local alarmOff = gfx.image.new("Images/alarmOff")
local alarmOn = gfx.image.new("Images/alarmOn")
alarmSprite = gfx.sprite.new( alarmOff )
alarmSprite:setZIndex(100)
alarmSprite:add()

function drawBackground()
    local thermo_per = 1 - math.min(timer / time_limit, 1)
    local thermo_len = (screen_h - 20) -thermo_per * (screen_h - 20)

    -- layout UX
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(buffer_x, 0, buffer_x, screen_h)
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(.5)
    gfx.fillRect(0, 0, buffer_x, screen_h)
    gfx.setDitherPattern(.9)
    gfx.fillRect(buffer_x, 0, buffer_x, screen_h)
    gfx.setDitherPattern(0)
    gfx.drawRect(buffer_x, 0, buffer_x, screen_h)

    -- thermo
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(buffer_x + 10, 10, buffer_w - 20, screen_h - 20)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(buffer_x + 10, 10, buffer_w - 20, screen_h - 20)
    gfx.fillRect(buffer_x + 10, 10 + (thermo_per * (screen_h - 20)), buffer_w - 20, thermo_len)

    for i = 1, #currentBoxes do
        drawBox(currentBoxes[i].x, currentBoxes[i].y, box_w, box_h)
    end
end

bgSprite = gfx.sprite.setBackgroundDrawingCallback(drawBackground)

-- box logic

local function drawBox(x, y, w, h)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x, y, w, h)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(x, y, w, h)
end

alarmTimer, alarmLen = 0, 20
local function buttonBox(x, y, w, h)
    ball_x, ball_y, ball_r = x + (w/2), y + (h/2), 16
    alarmSprite:setVisible(true)
    alarmSprite:moveTo(ball_x, ball_y - 20)
    
    alarmTimer += 1
    if alarmTimer == alarmLen then
        alarmSprite:setImage(alarmOn)
    elseif alarmTimer > alarmLen * 3 then
        lossReason = 'button'
        timer = time_limit
    end

    if playdate.buttonJustPressed(playdate.kButtonB) and alarmTimer >= alarmLen then
        alarmTimer = 0
        alarmSprite:setImage(alarmOff)
    end

    gfx.drawTextAligned("B", ball_x, ball_y + 12, kTextAlignment.center )
    gfx.drawCircleAtPoint(ball_x, ball_y + 20, ball_r)
end

-- box manage + layout

screen_w, screen_h = playdate.display.getWidth(), playdate.display.getHeight()
box_w, box_h = 120, 120
buffer_w, buffer_x = screen_w - (box_w * 3), box_w * 3
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

local boxIndex = 1
timer, time_limit = 0, 500
setBox(boxIndex)

function offloadBoxes()
    timer = 0
    alarmSprite:setVisible(false)
    alarmSprite:setImage(alarmOff)
    alarmTimer = -20
    bgSprite:setVisible(false)
end
offloadBoxes()

function runBoxes()
    bgSprite:setVisible(true)
    gfx.sprite.redrawBackground()
    timer += 1

    for i = 1, #currentBoxes do
        currentBoxes[i].run(currentBoxes[i].x, currentBoxes[i].y, box_w, box_h)
    end

    if (timer >= time_limit and lossReason == nil) then
        print('win!')
        setBox(boxIndex + 1)
    end

    return timer < time_limit and lossReason == nil
end