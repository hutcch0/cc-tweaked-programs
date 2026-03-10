local hubID = 2
local modem = peripheral.find("modem")
if modem then rednet.open(peripheral.getName(modem)) end

local w, h = term.getSize()

local function drawAppMenu()
    term.setBackgroundColor(colors.gray)
    term.clear()

    -- Mobile Taskbar
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.blue)
    term.clearLine()
    term.setTextColor(colors.white)
    local title = " HUTCCH MOBILE v1.2 "
    term.setCursorPos(math.floor((w - #title)/2) + 1, 1)
    term.write(title)

    term.setBackgroundColor(colors.black)
    
    term.setCursorPos(3, 4)
    term.setTextColor(colors.yellow)
    print(" [ 1 ] FLEET STATUS ")

    term.setCursorPos(3, 7)
    term.setTextColor(colors.red)
    print(" [ 2 ] RECALL (BTS) ")

    term.setCursorPos(3, 10)
    term.setTextColor(colors.orange)
    print(" [ 3 ] EMERGENCY STOP")

    term.setCursorPos(3, 13)
    term.setTextColor(colors.lightBlue)
    print(" [ 4 ] DISCORD PING ")
    
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(1, h)
    term.write(" Connected to Hub #" .. hubID)
end

local function sendCommand(cmd, alertText)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 4)
    term.setTextColor(colors.cyan)
    print(" TRANSMITTING...")
    print(" " .. alertText)
    
    rednet.send(hubID, cmd, "mobile_command")
    sleep(1.5)
end

while true do
    drawAppMenu()
    local event, p1, p2, p3 = os.pullEvent()
    local selection = nil
    if event == "char" then
        selection = p1
    elseif event == "mouse_click" then
        if p3 >= 4 and p3 <= 5 then selection = "1"
        elseif p3 >= 7 and p3 <= 8 then selection = "2"
        elseif p3 >= 10 and p3 <= 11 then selection = "3"
        elseif p3 >= 13 and p3 <= 14 then selection = "4"
        end
    end
    if selection == "1" then
        sendCommand("STATUS", "Requesting Telemetry")
    elseif selection == "2" then
        sendCommand("BTS", "Recalling Fleet to Surface")
    elseif selection == "3" then
        sendCommand("STOP", "HALTING ALL MINING UNITS")
    elseif selection == "4" then
        if fs.exists("discord.lua") then
            shell.run("discord.lua", "custom", ":iphone: **Mobile Alert:** Commander is exploring the caves.")
        else
            sendCommand("DISCORD", "Pinging from Hub...")
        end
    end
end
