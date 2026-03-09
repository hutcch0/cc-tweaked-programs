-- --- Configuration ---
local fuelSlot = 16
local modem = peripheral.find("modem")
if modem then rednet.open(peripheral.getName(modem)) end

-- Position Tracking
local pos = {x = 0, y = 27, z = 0, face = 0, fuel = 0, limit = 0}
local isUnloading = false

-- --- COMPASS SETUP ---
if not fs.exists("pos.txt") then
    term.clear()
    print("--- COMPASS CALIBRATION ---")
    print("Chest should be BEHIND turtle.")
    print("Turtle should face MINING AREA.")
    print("0: N | 1: E (+X) | 2: S | 3: W (-X)")
    write("Initial Facing (Type 1 for East): ")
    pos.face = tonumber(read()) or 1
    local file = fs.open("pos.txt", "w")
    file.write(textutils.serialize(pos))
    file.close()
end

-- Load Persistence
local file = fs.open("pos.txt", "r")
local data = textutils.unserialize(file.readAll())
if data then pos = data end
file.close()

local masterID = nil
if fs.exists("pair.txt") then
    local f = fs.open("pair.txt", "r")
    masterID = tonumber(f.readAll())
    f.close()
end

local function save()
    pos.fuel = turtle.getFuelLevel()
    pos.limit = turtle.getFuelLimit()
    pos.coal = turtle.getItemCount(16) 
    local f = fs.open("pos.txt", "w")
    f.write(textutils.serialize(pos))
    f.close()
    
    if masterID then 
        rednet.send(masterID, pos, "mining_status") 
    end
end

-- Navigation Functions
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

local function face(targetDir)
    while pos.face ~= targetDir do turn("right") end
end

local function smartMove(dir)
    -- 1. Check Fuel before moving
    if turtle.getFuelLevel() < 200 then
        print("Fuel low. Refueling from slot 16...")
        turtle.select(fuelSlot)
        while turtle.getFuelLevel() < 1000 and turtle.getItemCount(fuelSlot) > 0 do
            turtle.refuel(1)
        end
        turtle.select(1)
        
        -- If still critical, alert the Hub
        if turtle.getFuelLevel() < 50 then
            print("CRITICAL: NO FUEL IN SLOT 16")
            if masterID then rednet.send(masterID, "Unit #"..os.getComputerID().." STUCK: NO FUEL", "mining_status") end
        end
    end

    local success = false
    local attempts = 0
    while not success do
        if dir == "forward" then
            if turtle.detect() then turtle.dig() end
            success = turtle.forward()
            if success then
                if     pos.face == 0 then pos.z = pos.z - 1
                elseif pos.face == 1 then pos.x = pos.x + 1
                elseif pos.face == 2 then pos.z = pos.z + 1
                elseif pos.face == 3 then pos.x = pos.x - 1 end
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
        
        if not success then 
            turtle.attack()
            turtle.dig()   
            attempts = attempts + 1
            sleep(0.5) 
            if attempts > 20 then return false end 
        end
    end
    save()
    return true
end

local function goHome()
    print("Returning to 0,0,27...")
    if pos.z > 0 then face(0) while pos.z > 0 do smartMove("forward") end
    elseif pos.z < 0 then face(2) while pos.z < 0 do smartMove("forward") end end
    
    if pos.x > 0 then face(3) while pos.x > 0 do smartMove("forward") end
    elseif pos.x < 0 then face(1) while pos.x < 0 do smartMove("forward") end end
    
    while pos.y < 27 do smartMove("up") end
end

local function unloadItems()
    if isUnloading then return end
    isUnloading = true
    local oldX, oldY, oldZ = pos.x, pos.y, pos.z
    local oldFace = pos.face
    
    goHome()
    face(3) 
    print("Unloading to Chest...")
    for i = 1, 15 do 
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
    
    print("Diving back to site...")
    while pos.y > oldY do smartMove("down") end
    if oldX > 0 then face(1) while pos.x < oldX do smartMove("forward") end end
    if oldZ > 0 then face(2) while pos.z < oldZ do smartMove("forward") end end
    
    face(oldFace)
    isUnloading = false
end

local function checkInv()
    local full = true
    for i = 1, 15 do
        if turtle.getItemCount(i) == 0 then full = false break end
    end
    if full then unloadItems() end
end

local function startMining(size, startY, targetY)
    if pos.y > startY then
        print("Diving to Start Layer...")
        while pos.y > startY do smartMove("down") end
    end

    while pos.y > targetY do
        print("Mining Layer Y: " .. pos.y)
        for x = 1, size do
            for z = 1, (size - 1) do 
                smartMove("forward")
                checkInv()
                local _, m = rednet.receive("mining_command", 0)
                if m == "BTS" or m == "STOP" then return end
            end

            if x < size then
                if x % 2 == 1 then
                    turn("right") smartMove("forward") checkInv() turn("right")
                else
                    turn("left") smartMove("forward") checkInv() turn("left")
                end
            end
        end
        
        print("Layer finished. Returning to shaft...")
        if pos.z > 0 then face(0) while pos.z > 0 do smartMove("forward") end
        elseif pos.z < 0 then face(2) while pos.z < 0 do smartMove("forward") end end
        if pos.x > 0 then face(3) while pos.x > 0 do smartMove("forward") end
        elseif pos.x < 0 then face(1) while pos.x < 0 do smartMove("forward") end end
        
        smartMove("down")
        face(1) 
    end
    print("Mission Complete.")
end

-- --- MAIN LOOP ---
while true do
    save()
    if not masterID then
        local id, msg = rednet.receive("pair_request")
        masterID = id
        local f = fs.open("pair.txt", "w")
        f.write(tostring(id))
        f.close()
    else
        local id, msg = rednet.receive("mining_command")
        if id == masterID then
            if type(msg) == "table" then
                startMining(msg.size, msg.startY, msg.depth) 
                goHome()
            elseif msg == "BTS" then
                goHome()
            elseif msg == "RESET" then
                pos.x, pos.y, pos.z = 0, 27, 0
                save()
            end
        end
    end
end
