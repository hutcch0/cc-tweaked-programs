-- --- HUTCCH.CO v6.1 ---
local fuelSlot = 16
local modem = peripheral.find("modem")
if modem then rednet.open(peripheral.getName(modem), "mining_status") end

local pos = {x = 0, y = 27, z = 0, face = 0, coal = 0, startY = 27, fuel = 0, limit = 0}
local masterID = nil

-- --- ATOMIC SAVE ---
local function save()
    pos.fuel = tonumber(turtle.getFuelLevel()) or 0
    pos.limit = tonumber(turtle.getFuelLimit()) or 0
    pos.coal = tonumber(turtle.getItemCount(fuelSlot)) or 0

    local f = fs.open("pos_temp.txt", "w")
    f.write(textutils.serialize(pos))
    f.close()

    if fs.exists("pos.txt") then fs.delete("pos.txt") end
    fs.move("pos_temp.txt", "pos.txt")

    if masterID then
        rednet.send(masterID, pos, "mining_status")
    end
end

-- --- CALIBRATION ---
local function calibrate()
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.blue)
    print("=== HUTCCH.CO v6.1 CALIBRATION ===")
    term.setTextColor(colors.white)

    write("Current Y-Level: ")
    local inputY = tonumber(read()) or 27
    pos.y = inputY
    pos.startY = inputY

    print("\nFacing: 0:N | 1:E | 2:S | 3:W")
    write("Select Facing (0-3): ")
    pos.face = tonumber(read()) or 0

    pos.x = 0
    pos.z = 0
    save()
    print("\nREADY.")
    sleep(1)
end

if not fs.exists("pos.txt") then calibrate() end

if fs.exists("pos.txt") then
    local f = fs.open("pos.txt", "r")
    local data = textutils.unserialize(f.readAll())
    if data then pos = data end
    f.close()
end
if fs.exists("pair.txt") then
    local f = fs.open("pair.txt", "r")
    masterID = tonumber(f.readAll())
    f.close()
end

-- --- MOVEMENT ---
local function smartMove(dir)
    local currentFuel = tonumber(turtle.getFuelLevel()) or 0
    if currentFuel < 300 then
        turtle.select(fuelSlot)
        turtle.refuel(1)
        turtle.select(1)
    end

    local success = false
    if dir == "forward" then
        if turtle.detect() then turtle.dig() end
        success = turtle.forward()
        if success then
            if     pos.face == 0 then pos.z = pos.z - 1
            elseif pos.face == 1 then pos.x = pos.x + 1
            elseif pos.face == 2 then pos.z = pos.z + 1
            elseif pos.face == 3 then pos.x = pos.x - 1
            end
        end
    elseif dir == "down" then
        if turtle.detectDown() then turtle.digDown() end
        success = turtle.down()
        if success then pos.y = pos.y - 1 end
    elseif dir == "up" then
        if turtle.detectUp() then turtle.digUp() end
        success = turtle.up()
        if success then pos.y = pos.y + 1 end
    end

    if success then save() end
    return success
end

local function turn(dir)
    if dir == "right" then
        turtle.turnRight()
        pos.face = (pos.face + 1) % 4
    elseif dir == "left" then
        turtle.turnLeft()
        pos.face = (pos.face - 1) % 4
    end
    save()
end

local function face(target)
    while pos.face ~= target do turn("right") end
end

local function goHome()
    if pos.z > 0 then face(0) while pos.z > 0 do smartMove("forward") end
    elseif pos.z < 0 then face(2) while pos.z < 0 do smartMove("forward") end end
    if pos.x > 0 then face(3) while pos.x > 0 do smartMove("forward") end
    elseif pos.x < 0 then face(1) while pos.x < 0 do smartMove("forward") end end
    while pos.y < pos.startY do smartMove("up") end
    face(3) 
end

local function unload()
    local oldX, oldY, oldZ, oldF = pos.x, pos.y, pos.z, pos.face
    goHome()
    for i = 1, 15 do turtle.select(i) turtle.drop() end
    turtle.select(1)
    while pos.y > oldY do smartMove("down") end
    if oldX > 0 then face(1) while pos.x < oldX do smartMove("forward") end
    elseif oldX < 0 then face(3) while pos.x > oldX do smartMove("forward") end end
    if oldZ > 0 then face(2) while pos.z < oldZ do smartMove("forward") end
    elseif oldZ < 0 then face(0) while pos.z > oldZ do smartMove("forward") end end
    face(oldF)
end

-- --- MINING LOGIC ---
local function startMining(size, startY, targetY)
    pos.startY = startY
    local startFace = pos.face

    while pos.y > startY do smartMove("down") end

    while pos.y > targetY do
        for x = 1, size do
            for z = 1, size - 1 do
                smartMove("forward")
                if turtle.getItemCount(15) > 0 then unload() end
            end

            if x < size then
                if x % 2 == 1 then
                    turn("right")
                    smartMove("forward")
                    turn("right")
                else
                    turn("left")
                    smartMove("forward")
                    turn("left")
                end
            end
        end

        if pos.z ~= 0 or pos.x ~= 0 then
            if pos.z > 0 then face(0) while pos.z > 0 do smartMove("forward") end
            elseif pos.z < 0 then face(2) while pos.z < 0 do smartMove("forward") end end
            if pos.x > 0 then face(3) while pos.x > 0 do smartMove("forward") end
            elseif pos.x < 0 then face(1) while pos.x < 0 do smartMove("forward") end end
        end

        if pos.y > targetY then
            smartMove("down")
            face(startFace)
        end
    end
    goHome()
end

-- --- MAIN LOOP ---
while true do
    save()
    local id, msg, protocol = rednet.receive()
    if protocol == "pair_request" then
        masterID = id
        local f = fs.open("pair.txt", "w") f.write(tostring(id)) f.close()
        rednet.send(id, "CONNECTED", "mining_confirm")
    elseif id == masterID and protocol == "mining_command" then
        if type(msg) == "table" then
            startMining(msg.size, msg.startY, msg.depth)
        elseif msg == "RESET" then
            calibrate()
        end
    end
end
