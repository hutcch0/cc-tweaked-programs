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

while true do
    drawDesktop()
    local event, button, x, y = os.pullEvent("mouse_click")

    if x >= 4 and x <= 10 and y == 3 then
        shell.run("start.lua")
    elseif x >= 16 and x <= 22 and y == 3 then
        shell.run("storage.lua") -- not a thing yet coming soon
    elseif x >= 28 and x <= 34 and y == 3 then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        shell.run("discord.lua")
    elseif x >= w-11 and x <= w and y == h then
        if mon then mon.setBackgroundColor(colors.black) mon.clear() end
        os.shutdown()
	elseif x >= 40 and x <= 46 and y == 3 then
   		term.setBackgroundColor(colors.black)
    	term.clear()
    	term.setCursorPos(1,1)
    	shell.run("console.lua")
    end
end
