-- --- Configuration ---
local mainPC_ID = 2
local modem = peripheral.find("modem")
if modem then rednet.open(peripheral.getName(modem)) end

local function drawUI(status)
    term.clear()
    term.setCursorPos(1,1)
    
    -- Header
    term.setBackgroundColor(colors.blue)
    term.clearLine()
    print("  POCKET COMMAND v4.5  ")
    term.setBackgroundColor(colors.black)
    
    print("\n Linked to: Base #" .. mainPC_ID)
    print(" -----------------------")
    
    if status then
        term.setTextColor(colors.yellow)
        print("\n  " .. status)
        term.setTextColor(colors.white)
    end

    term.setCursorPos(1, 10)
    term.setBackgroundColor(colors.red)
    term.clearLine()
    print(" [ 1 ] REQUEST BTS (HOME) ")
    
    term.setCursorPos(1, 13)
    term.setBackgroundColor(colors.orange)
    term.clearLine()
    print(" [ 2 ] EMERGENCY STOP     ")
    
    term.setCursorPos(1, 16)
    term.setBackgroundColor(colors.gray)
    term.clearLine()
    print(" [ 3 ] RESET Y TO 27      ")
    
    term.setBackgroundColor(colors.black)
end

local function sendCmd(msg, label)
    drawUI("SENDING: " .. label)
    rednet.send(mainPC_ID, msg, "pocket_relay")
    sleep(0.8)
end

-- Main Loop
while true do
    drawUI()
    
    local event, side, x, y = os.pullEvent()
    
    if event == "mouse_click" then
        if y == 10 then
            sendCmd("BTS_REQUEST", "BTS")
        elseif y == 13 then
            sendCmd("STOP_REQUEST", "STOP")
        elseif y == 16 then
            sendCmd("RESET_REQUEST", "RESET")
        end
    
    elseif event == "char" then
        if side == "1" then
            sendCmd("BTS_REQUEST", "BTS")
        elseif side == "2" then
            sendCmd("STOP_REQUEST", "STOP")
        elseif side == "3" then
            sendCmd("RESET_REQUEST", "RESET")
        end
    end
end
