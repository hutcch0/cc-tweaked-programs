-- --- HUTCCH.CO v6.1
local modemSide = "right"
rednet.open(modemSide)
local mon = peripheral.wrap("left")
local myID = os.getComputerID()

-- --- LOAD CONFIG
local config = {}
if fs.exists("hutcch.cfg") then
    local f = fs.open("hutcch.cfg", "r")
    config = textutils.unserialize(f.readAll()) or {}
    f.close()
end

local bots = {}
local logs = {}
local currentlyMining = false

local function addLog(msg)
    local timestamp = textutils.formatTime(os.time(), true)
    table.insert(logs, 1, "[" .. timestamp .. "] " .. msg)
    if #logs > 12 then table.remove(logs) end
end

-- --- 1. THE MONITOR  ---
local function updateMonitor()
    if not mon then return end
    local w, h = mon.getSize()
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.setTextColor(colors.green)
    mon.write("root@hutcch-os:~# ./telemetry-daemon")

    mon.setCursorPos(1, 3)
    mon.setTextColor(colors.gray)
    mon.write(string.rep("-", w))
    mon.setCursorPos(2, 4)
    mon.setTextColor(colors.lightBlue)
    mon.write("UNIT   X      Y      Z      COAL      STATUS")

    local line = 6
    local currentTime = os.clock()
    for id, data in pairs(bots) do
        local isOnline = (currentTime - (data.lastPing or 0)) < 15
        mon.setCursorPos(2, line)
        mon.setTextColor(isOnline and colors.green or colors.gray)
        mon.write(string.format("#%-4s", id))

        mon.setTextColor(isOnline and colors.white or colors.gray)
        mon.setCursorPos(9, line)  mon.write(string.format("%-6s", data.x or 0))
        mon.setCursorPos(16, line) mon.write(string.format("%-6s", data.y or 27))
        mon.setCursorPos(23, line) mon.write(string.format("%-6s", data.z or 0))

        mon.setCursorPos(30, line)
        if not isOnline then
            mon.setTextColor(colors.red)
            mon.write("N/A       [ SIGNAL LOST ]")
        else
            mon.write(string.format("%-9s", (data.coal or 0) .. " pcs"))
            mon.setTextColor(colors.green)
            mon.write("[ ONLINE ]")
        end
        line = line + 1
    end
end

-- --- THE TERMINAL ---
local function updateTerminal()
    local w, h = term.getSize()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.green)
    term.write("root@hutcch-os:~/mining# tail -f fleet.log")

    for i, log in ipairs(logs) do
        term.setCursorPos(2, 3 + i)
        term.setTextColor(colors.lightGray)
        term.write(log)
    end

    term.setCursorPos(1, h - 1)
    term.setTextColor(colors.gray)
    term.write(string.rep("-", w))
    term.setCursorPos(1, h)
    term.setTextColor(colors.green)
    term.write(" [D]eploy  [S]urface  [R]eset  [P]air  [Q]uit")
end

-- --- DEPLOYMENT  ---
local function getSpecs()
    term.clear()
    term.setCursorPos(1,1)
    print("--- GLOBAL DEPLOYMENT ---")
    write("Hole Size: ")
    local s = tonumber(read()) or 3
    write("Start Y:   ")
    local sy = tonumber(read()) or 27
    write("Target Y:  ")
    local ty = tonumber(read()) or -60

    currentlyMining = true
    rednet.broadcast({size = s, startY = sy, depth = ty}, "mining_command")
    addLog("GLOBAL: Sent " .. s .. "x" .. s .. " to all units.")
end

-- --- MAIN LOOP ---
addLog("Daemon initialized.")
while true do
    updateMonitor()
    updateTerminal()

    local timer = os.startTimer(1)
    local event, p1, p2, p3 = os.pullEvent()

    if event == "rednet_message" then
        if p3 == "mining_status" then
            p2.lastPing = os.clock()
            bots[p1] = p2

            if currentlyMining and p2.y >= (p2.startY or 27) then
                currentlyMining = false
                addLog("UNIT #"..p1..": Job complete.")
                if config.webhook and config.webhook ~= "" then
                    shell.run("discord.lua", "custom", ":pick: **MINING COMPLETE**\nUnit #"..p1.." is back at Y:"..p2.y)
                end
            end

        elseif p3 == "mining_confirm" then
            addLog("UNIT #"..p1..": Handshake confirmed.")
            bots[p1] = {x=0, y=27, z=0, lastPing=os.clock()}

        elseif p3 == "mining_debug" then
            addLog("DEBUG #"..p1..": "..tostring(p2))
            if string.find(tostring(p2), "STUCK") and config.webhook and config.webhook ~= "" then
                shell.run("discord.lua", "custom", ":warning: **EMERGENCY**\nUnit #"..p1.." is STUCK!")
            end
        end

    elseif event == "key" then
        if p1 == keys.p then
            rednet.broadcast(myID, "pair_request")
            addLog("Pairing signal sent...")
        elseif p1 == keys.d then
            getSpecs()
        elseif p1 == keys.q then
            return
        end
    end
end
