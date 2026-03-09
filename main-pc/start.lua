-- --- Configuration ---
local modemSide = "right" 
rednet.open(modemSide)
local mon = peripheral.wrap("left") 
local myID = os.getComputerID()
local bots = {}
local logs = {} 
local currentlyMining = false

-- Theme Colors
local bg = colors.black
local accent = colors.blue
local text = colors.white
local highlight = colors.cyan
local info = colors.lightGray

local function addLog(msg)
    table.insert(logs, 1, "> " .. msg)
    if #logs > 4 then table.remove(logs) end 
end

-- UI
local function drawUI()
    if not mon then return end
    local w, h = mon.getSize()
    mon.setBackgroundColor(bg)
    mon.clear()

    -- HEADER ---
    mon.setBackgroundColor(accent)
    mon.setTextColor(text)
    mon.setCursorPos(1, 1)
    mon.clearLine()
    local title = "MINING SYS OS v5.9 - CONTROL HUB" 
    mon.setCursorPos(math.floor((w - #title) / 2), 1)
    mon.write(title)

    -- SYSTEM STATUS ---
    mon.setBackgroundColor(bg)
    mon.setTextColor(highlight)
    mon.setCursorPos(2, 2)
    mon.write("NETWORK: ONLINE")
    mon.setTextColor(info)
    mon.setCursorPos(w - 15, 2)
    mon.write("HUB ID: " .. myID)

    -- --- TELEMETRY ---
    mon.setCursorPos(2, 4)
    mon.setTextColor(accent)
    mon.write("UNIT ID")
    mon.setCursorPos(12, 4) mon.write("COORD-X")
    mon.setCursorPos(24, 4) mon.write("COORD-Y")
    mon.setCursorPos(36, 4) mon.write("COORD-Z")
    mon.setCursorPos(48, 4) mon.write("FUEL RESERVES")
    
    mon.setCursorPos(2, 5)
    mon.setTextColor(colors.gray)
    mon.write(string.rep("-", w - 2))
    
    local line = 6
    for id, data in pairs(bots) do
        mon.setCursorPos(2, line)
        mon.setTextColor(colors.yellow)
        mon.write("#" .. id)
        
        mon.setTextColor(text)
        mon.setCursorPos(12, line) mon.write(data.x or 0)
        mon.setCursorPos(24, line) mon.write(data.y or 27)
        mon.setCursorPos(36, line) mon.write(data.z or 0)
        
        local coalCount = data.coal or 0
        local fuelPct = math.floor((coalCount / 64) * 100)
        if fuelPct > 100 then fuelPct = 100 end
        
        mon.setCursorPos(48, line)
        if fuelPct < 20 then mon.setTextColor(colors.red) 
        elseif fuelPct < 50 then mon.setTextColor(colors.yellow)
        else mon.setTextColor(colors.green) end
        
        local bar = string.rep("|", math.floor(fuelPct/10))
        mon.write(fuelPct .. "% (" .. coalCount .. "pcs)")
        
        line = line + 1
        if line > h - 6 then break end 
    end

    -- LIVE FEED ---
    mon.setCursorPos(2, h - 5)
    mon.setTextColor(highlight)
    mon.write("LIVE OPERATIONS FEED")
    mon.setTextColor(colors.gray)
    for i, log in ipairs(logs) do
        mon.setCursorPos(2, (h - 5) + i)
        mon.write(log)
    end

    -- COMMAND BAR ---
    mon.setBackgroundColor(colors.gray)
    mon.setTextColor(colors.white)
    mon.setCursorPos(1, h)
    mon.clearLine()
    local controls = "[P] PAIR [D] DIG [S] BTS [R] RESET [Q] EXIT"
    mon.setCursorPos(math.floor((w - #controls) / 2), h)
    mon.write(controls)
    mon.setBackgroundColor(bg)
end

-- Deployment
local function getSpecs()
    term.clear()
    term.setTextColor(colors.cyan)
    print("--- DEPLOYMENT CONFIGURATION ---")
    term.setTextColor(colors.white)
    
    write("Hole Size (1-15): ")
    local s = tonumber(read()) or 3
    
    write("Start at Y Level (Surface is 27): ")
    local startY = tonumber(read()) or 27
    
    write("End at Y Level (Target): ")
    local endY = tonumber(read()) or -59
    
    currentlyMining = true
    rednet.broadcast({size = s, startY = startY, depth = endY}, "mining_command")
    addLog("Deployed " .. s .. "x" .. s .. " | " .. startY .. " to " .. endY)
end

-- --- MAIN LOOP ---
while true do
    drawUI()
    local event, p1, p2, p3 = os.pullEvent()

    if event == "rednet_message" then
        if p3 == "mining_status" then
            bots[p1] = p2
            if p2.y == 27 and currentlyMining then
                currentlyMining = false
                addLog("Unit #"..p1.." job complete!")
            end
        elseif p3 == "mining_confirm" then
            addLog("Unit #"..p1.." confirmed.")
        end

    elseif event == "key" then
        if p1 == keys.p then
            rednet.broadcast(myID, "pair_request")
            addLog("Pairing signal sent...")
        elseif p1 == keys.d then
            getSpecs()
        elseif p1 == keys.r then
            rednet.broadcast("RESET", "mining_command")
            addLog("System Reset sent.")
        elseif p1 == keys.s then
            rednet.broadcast("BTS", "mining_command")
            addLog("BTS command sent.")
        elseif p1 == keys.q then
            if mon then
                mon.setBackgroundColor(colors.black)
                mon.clear()
            end
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1,1)
            print("Returning to Hutcch.co Desktop...")
            sleep(0.5)
            return
        end
    end
end
