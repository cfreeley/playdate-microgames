import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/keyboard"

local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry
local snd <const> = playdate.sound
lossReason = nil

local alarmSprite = nil
local alarmOff = gfx.image.new("Images/alarmOff")
local alarmOn = gfx.image.new("Images/alarmOn")
alarmSprite = gfx.sprite.new(alarmOff)
alarmSprite:add()

local victSprite = nil
local victOn = gfx.image.new("Images/victrolaLoud")
local victOff = gfx.image.new("Images/victrolaQuiet")
victSprite = gfx.sprite.new(victrolaLoud)
victSprite:add()
local popSong = snd.sampleplayer.new("Audio/pop")

local function drawBox(x, y, w, h)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x, y, w, h)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(x, y, w, h)
end

function drawBackground()
    local thermo_per = 1 - math.min(timer / time_limit, 1)
    local thermo_len = (screen_h - 20) - thermo_per * (screen_h - 20)

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

function gameOver(reason)
    lossReason = reason
end

alarmTimer, alarmLen = 0, 30
local function buttonBox(x, y, w, h)
    ball_x, ball_y, ball_r = x + (w / 2), y + (h / 2), 16
    alarmSprite:setVisible(true)
    alarmSprite:moveTo(ball_x, ball_y - 20)

    alarmTimer += 1
    if alarmTimer == alarmLen then
        alarmSprite:setImage(alarmOn)
    elseif alarmTimer > alarmLen * 3 then
        gameOver("button")
    end

    if playdate.buttonJustPressed(playdate.kButtonB) and alarmTimer >= alarmLen then
        alarmTimer = 0
        alarmSprite:setImage(alarmOff)
    end

    gfx.drawTextAligned("B", ball_x, ball_y + 12, kTextAlignment.center)
    gfx.drawCircleAtPoint(ball_x, ball_y + 20, ball_r)
end

crankIdx = 0
local function crankBox(x, y, w, h)
    if not popSong:isPlaying() then
        popSong:setFinishCallback(function() gameOver("crank") end)
        popSong:play()
    end

    if (timer % 4 == 0) then
        crankIdx += 1
    end

    cTicks = playdate.getCrankTicks(12)
    if math.abs(cTicks) > 0 then
        popSong:setOffset(math.max(popSong:getOffset() - math.abs(cTicks / 3), 0))
    end

    victSprite:setVisible(true)
    victSprite:setImage((crankIdx % 2 == 1) and victOn or victOff)
    victSprite:moveTo(x + (w / 2), y + (h / 2))
end

hour_idx, hour_len = 0, 200
flip_idx = 0
local function hourglassBox(x, y, w, h)
    gfx.setScreenClipRect(x, y, w, h)
    hour_idx += 1
    padding, max_pad = 30, w / 2
    hour_per = (hour_idx / hour_len)
    sand_pad = (max_pad - padding) * hour_per ^ 1.8

    if flip_idx == 1 then
        y -= 10
        flip_idx += 1
    elseif flip_idx == 2 then
        y += 10
        flip_idx = 0
    end

    if playdate.buttonJustPressed(playdate.kButtonDown) then
        flip_idx = 1
        hour_idx = hour_len - hour_idx
    end

    if hour_per > 1 then
        gameOver("sand")
    end

    -- top sand
    gfx.setDitherPattern(.5)
    gfx.fillTriangle(x + padding + sand_pad, y + padding + sand_pad, x + w - padding - sand_pad, y + padding + sand_pad,
        x + (w / 2), y + (h / 2))

    -- bottom sand
    gfx.fillTriangle(x + padding, y + h - padding, x + w - padding, y + h - padding, x + (w / 2), y + (h / 2))
    gfx.setColor(gfx.kColorWhite) -- erase small triangle off full triangle to make sand pool
    gfx.setDitherPattern(0)
    gfx.fillTriangle(x + padding + sand_pad, y + h - padding - sand_pad, x + w - padding - sand_pad, y + h - padding -
        sand_pad, x + (w / 2), y + (h / 2))

    -- sand line
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(1 - (math.random() / 2))
    gfx.drawLine(x + (w / 2), y + (h / 2), x + (w / 2), y + h - padding)

    -- hourglass
    gfx.setDitherPattern(0)
    gfx.drawTriangle(x + padding, y + padding, x + w - padding, y + padding, x + (w / 2), y + (h / 2))
    gfx.drawTriangle(x + padding, y + h - padding, x + w - padding, y + h - padding, x + (w / 2), y + (h / 2))
    gfx.fillRect(x + padding - 1, y + padding - 2, w - (padding * 2) + 2, 2)
    gfx.fillRect(x + padding - 1, y + h - padding, w - (padding * 2) + 2, 3)
end

function makeGlacier(x, y, r, v)
    sqrtHalf = (1 / 2) ^ (1 / 2)
    points = { { x = x,       y = y - r }, { x = x + (r * sqrtHalf), y = y - (r * sqrtHalf) },
        { x = x + (r * sqrtHalf), y = y + (r * sqrtHalf) },
        { x = x - (r * sqrtHalf), y = y + (r * sqrtHalf) }, { x = x - (r * sqrtHalf), y = y - (r * sqrtHalf) } }

    for i = 1, #points do
        points[i].x += math.random(-v, v)
        points[i].y += math.random(-v, v)
        points[i] = geo.point.new(points[i].x, points[i].y)
    end
    points[6] = points[1]
    return geo.polygon.new(table.unpack(points))
end

glaciers, boat_x, flip_wave = {}, 0, 0
local function boatBox(x, y, w, h)
    gfx.setScreenClipRect(x, y, w, h)
    -- if timer % 30 == 0 then
    --     flip_wave += 1
    -- end
    -- gfx.setDitherPattern(flip_wave % 2 == 0 and .9 or .8)
    -- gfx.fillRect(x, y, w, h)
    -- gfx.setDitherPattern(1)

    -- spawn glaciers
    if #glaciers == 0 or (math.random(75) == 1 and glaciers[#glaciers]:getBoundsRect().y > h / 3) then
        local newGlac = makeGlacier(math.random(w), -10, 14, 4)
        glaciers[#glaciers + 1] = newGlac
    end

    -- boat

    boat_w, boat_h, boat_x_glob = 15, 25, boat_x + x
    boat = geo.polygon.new(
        boat_x_glob - (boat_w / 2), y + h - 1,
        boat_x_glob - (boat_w / 2) + 2, y + h - (boat_h * .6),
        boat_x_glob, y + h - boat_h,
        boat_x_glob + (boat_w / 2) - 2, y + h - (boat_h * .6),
        boat_x_glob + (boat_w / 2), y + h - 1
    )
    gfx.drawPolygon(boat)
    gfx.fillCircleAtPoint(boat_x_glob, y + h - 4, 2)
    gfx.fillCircleAtPoint(boat_x_glob, y + h - 9, 2)

    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        boat_x -= 2
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then
        boat_x += 2
    end

    -- update + draw glaciers
    updatedGlaciers = {}
    for i = 1, #glaciers do
        glaciers[i]:translate(0, 1)
        local locGlacier = glaciers[i]:copy()
        locGlacier:translate(x, y)
        gfx.drawPolygon(locGlacier)
        if locGlacier:intersects(boat) then
            gameOver("boat")
        elseif locGlacier:getBoundsRect():intersects(geo.rect.new(x, y, w, h)) then
            updatedGlaciers[#updatedGlaciers + 1] = glaciers[i]
        end
    end
    glaciers = updatedGlaciers
end

balloon_y, balloon_r, min_r, is_pressing_up = 0, 30, 20, false
function balloonBox(x, y, w, h)
    max_balloon_y = h - (18 + min_r)
    if balloon_y < max_balloon_y then
        balloon_y += .5
    else
        gameOver("balloon")
    end

    if playdate.buttonJustPressed(playdate.kButtonUp) then
        is_pressing_up = true
    elseif balloon_y <= -(balloon_r / 2) or playdate.buttonJustReleased(playdate.kButtonUp) then
        is_pressing_up = false
    end

    if is_pressing_up then
        balloon_y -= 1.5
    end

    cur_r = math.floor((balloon_r - min_r) * (1 - (balloon_y / max_balloon_y)) + min_r)
    print(cur_r)

    gfx.setScreenClipRect(x, y, w, h)
    gfx.drawCircleAtPoint(x + (w / 2), y + balloon_y, cur_r)
    gfx.setDitherPattern(.5)
    gfx.fillRect(x + (w / 2) - 4, y + balloon_y + cur_r + 2, 8, 6)
    gfx.setDitherPattern(0)
    gfx.drawRect(x + (w / 2) - 4, y + balloon_y + cur_r + 2, 8, 6)
    gfx.drawLine(x + (w / 2) - 2, y + balloon_y + cur_r, x + (w / 2) - 2, y + balloon_y + cur_r + 2)
    gfx.drawLine(x + (w / 2) + 1, y + balloon_y + cur_r, x + (w / 2) + 1, y + balloon_y + cur_r + 2)

    gfx.setDitherPattern(.5)
    gfx.drawLine(x, y + h - 12, x + w, y + h - 12)
    gfx.setDitherPattern(0)
end

local function drawSaucer(x, y, s)
    gfx.drawCircleAtPoint(x, y, s)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillEllipseInRect(x - (s * 1.5), y, s * 3, s)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawEllipseInRect(x - (s * 1.5), y, s * 3, s)
    gfx.setDitherPattern(.25)
    gfx.fillEllipseInRect(x - (s * 1.5), y, s * 3, s)
    gfx.setDitherPattern(0)
end

saucers, bullets, turret_ang, ang_spd = {}, {}, 90, 1
function shooterBox(x, y, w, h)
    if math.random(100) == 1 and (#saucers == 0 or saucers[#saucers].y > y + (h / 4)) then
        local newSauc = {
            x = math.random(w - 24) + 12 + x,
            y = y,
            s = 8,
            spd = .5 * (math.random() > .5 and -1 or 1),
            bounds = function(slf) return geo.rect.new(slf.x - (slf.s * 1.5), slf.y, slf.s * 3, slf.s) end
        }
        saucers[#saucers + 1] = newSauc
    end


    gfx.setScreenClipRect(x, y, w, h)
    updSaucers = {}
    for i = 1, #saucers do
        local curS = saucers[i]
        drawSaucer(curS.x, curS.y, curS.s)
        curS.x += curS.spd
        curS.y += math.abs(curS.spd / 5)
        if curS.x < x then
            curS.spd = math.abs(curS.spd)
        elseif curS.x > x + w then
            curS.spd = -math.abs(curS.spd)
        end
        if curS.y > y + h - 24 then
            gameOver("shooter")
        elseif curS:bounds():intersects(geo.rect.new(x, y, w, h)) then
            updSaucers[#updSaucers + 1] = curS
        end
    end
    saucers = updSaucers

    -- turret
    turret_ang += ang_spd
    if turret_ang >= 180 then
        ang_spd = -math.abs(ang_spd)
    elseif turret_ang <= 0 then
        ang_spd = math.abs(ang_spd)
    end
    gfx.drawCircleAtPoint(x + (w / 2), y + h, 12)
    gfx.drawLine(x + (w / 2), y + h - 12, x + (w / 2), y + h - 24)
end

-- box manage + layout

screen_w, screen_h = playdate.display.getWidth(), playdate.display.getHeight()
box_w, box_h = 120, 120
buffer_w, buffer_x = screen_w - (box_w * 3), box_w * 3
mid_x, mid_y = (screen_w - buffer_w) / 2, screen_h / 2
half_w, half_h = box_w / 2, box_h / 2

boxes = {
    buttonBox,
    crankBox,
    hourglassBox,
    boatBox,
    balloonBox,
    shooterBox,
}
max_rooms = #boxes

layouts = {
    -- initial: center
    { { x = mid_x - half_w, y = mid_y - half_h, } },
    -- 2: parallel
    {
        { x = 40,  y = mid_y - half_h, }, -- L
        { x = 200, y = mid_y - half_h, }  -- R
    },
    -- 3: T-shape
    {
        { x = 40,             y = 0, },    -- L
        { x = 200,            y = 0, },    -- R
        { x = mid_x - half_w, y = mid_y, } -- D
    },
    -- 4: small grid
    {
        { x = 0,   y = 0, },     -- 1
        { x = 160, y = 0, },     -- 2
        { x = 240, y = mid_y, }, -- 4
        { x = 80,  y = mid_y, }, -- 3
    },
    -- 5: trapezoid
    {
        { x = box_w,     y = 0, }, -- 2
        { x = box_w * 2, y = 0, }, -- 3
        { x = 200,       y = mid_y, }, -- 5
        { x = 40,        y = mid_y, }, -- 4
        { x = 0,         y = 0, }, -- 1
    },
    -- 6: full grid
    {
        { x = box_w,     y = 0, },     -- 2
        { x = box_w * 2, y = 0, },     -- 3
        { x = box_w,     y = box_h, }, -- 5
        { x = 0,         y = box_h, }, -- 4
        { x = 0,         y = 0, },     -- 1
        { x = box_w * 2, y = box_h, }, -- 6
    }
}

currentBoxes = {}

function setBox(bIndx)
    boxIndex = bIndx
    if data ~= nil then
        data.roomId = boxIndex
    end
    time_limit = 250 + (bIndx * 50)
    currentBoxes = {}
    for i = 1, #layouts[bIndx] do
        currentBoxes[i] = layouts[bIndx][i]
        currentBoxes[i].run = boxes[i] ~= nil and boxes[i] or buttonBox
    end
end

boxIndex = 1
timer, time_limit = 0, 300
setBox(boxIndex)

function offloadBoxes()
    timer = 0
    bgSprite:setVisible(false)

    alarmSprite:setVisible(false)
    alarmSprite:setImage(alarmOff)
    alarmTimer = -20

    victSprite:setVisible(false)

    hour_idx = 0

    glaciers = {}
    boat_x = box_w / 2

    balloon_y = 0
    is_pressing_up = false

    saucers = {}
    bullets = {}
    turret_ang = 0

    popSong:setFinishCallback(function() end)
    popSong:setOffset(0)
    popSong:stop()
end

offloadBoxes()

function runBoxes()
    bgSprite:setVisible(true)
    gfx.sprite.redrawBackground()
    if not is_endless then
        timer += 1
    end
    time_out = timer < time_limit

    for i = 1, #currentBoxes do
        currentBoxes[i].run(currentBoxes[i].x, currentBoxes[i].y, box_w, box_h)
    end

    if (timer >= time_limit and lossReason == nil) then
        setBox(boxIndex + 1)
    end

    return time_out and lossReason == nil
end
