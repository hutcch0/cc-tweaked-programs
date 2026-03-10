local w, h = term.getSize()
local mon = peripheral.wrap("left")

local function drawDesktop()
    term.setBackgroundColor(colors.gray)
    term.clear()

    -- Taskbar
    term.setCursorPos(1, h)
    term.setBackgroundColor(colors.blue)
    term.clearLine()
    term.setTextColor(colors.white)
    term.write(" [H] HUTCCH.CO   |   TIME: " .. textutils.formatTime(os.time(), true))

    -- Mining Icon
    term.setCursorPos(4, 3)
    term.setBackgroundColor(colors.black)
    term.write("  [ M ]  ")
    term.setCursorPos(4, 4)
    term.setBackgroundColor(colors.gray)
    term.write(" MINING  ")

    -- Storage Icon
    term.setCursorPos(16, 3)
    term.setBackgroundColor(colors.black)
    term.write("  [ S ]  ")
    term.setCursorPos(16, 4)
    term.setBackgroundColor(colors.gray)
    term.write(" STORAGE ")

    -- Discord Icon
    term.setCursorPos(28, 3)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.lightBlue)
    term.write("  [ D ]  ")
    term.setCursorPos(28, 4)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.write(" DISCORD ")

    -- Console Icon
    term.setCursorPos(40, 3)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.green)
    term.write("  [ C ]  ")
    term.setCursorPos(40, 4)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.write(" CONSOLE ")
    
    -- Shutdown Button
    term.setCursorPos(w - 11, h)
    term.setBackgroundColor(colors.red)
    term.write(" SHUTDOWN ")
end
local function safeRun(file)
    if fs.exists(file) then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        shell.run(file)
    else
        term.setCursorPos(1, 1)
        term.setBackgroundColor(colors.red)
        term.setTextColor(colors.white)
        term.clearLine()
        term.write(" ERROR: " .. file .. " is missing or corrupted! ")
        sleep(2)
    end
end

while true do
    drawDesktop()
    local event, button, x, y = os.pullEvent("mouse_click")
    if y == 3 or y == 4 then
        if x >= 4 and x <= 10 then
            safeRun("start.lua")
        elseif x >= 16 and x <= 22 then
            safeRun("storage.lua") -- not a thing yet coming soon
        elseif x >= 28 and x <= 34 then
            safeRun("discord.lua")
        elseif x >= 40 and x <= 46 then
            safeRun("console.lua")
        end
        
    elseif y == h and x >= w - 11 and x <= w then
        if mon then 
            mon.setBackgroundColor(colors.black) 
            mon.clear() 
        end
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        print("HUTCCH.CO: Initiating Shutdown...")
        sleep(1)
        os.shutdown()
    end
end
