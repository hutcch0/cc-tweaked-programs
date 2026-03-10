local w, h = term.getSize()
local mon = peripheral.wrap("left")

local function drawDesktop()
    term.setBackgroundColor(colors.black)
    term.clear()

    --Terminal Prompt
    term.setCursorPos(1, 1)
    term.setTextColor(colors.green)
    term.write("root@hutcch-os:~# ")
    term.setTextColor(colors.white)
    term.write("./start-workspace")

    term.setCursorPos(1, 3)
    term.setTextColor(colors.blue)
    term.write("=== SYSTEM MODULES ===")

    -- Mining
    term.setCursorPos(2, 5)
    term.setTextColor(colors.white)
    term.write("[ M ]  MINING CORE")

    -- Storage
    term.setCursorPos(2, 6)
    term.setTextColor(colors.white)
    term.write("[ S ]  STORAGE ARRAY")

    -- Discord
    term.setCursorPos(2, 7)
    term.setTextColor(colors.lightBlue)
    term.write("[ D ]  DISCORD UPLINK")

    -- Console
    term.setCursorPos(2, 8)
    term.setTextColor(colors.green)
    term.write("[ C ]  ROOT CONSOLE")

    -- Shutdown
    term.setCursorPos(2, 10)
    term.setTextColor(colors.red)
    term.write("[ X ]  HALT SYSTEM")

    -- Bottom Status Bar
    term.setCursorPos(1, h)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.black)
    term.clearLine()
    term.write(" SYS: ONLINE  |  MEM: 512KB  |  v6.1 pro  | " .. textutils.formatTime(os.time(), true))
    term.setBackgroundColor(colors.black)
end

-- APP VALIDATION
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
        term.write(" ERR: Module '" .. file .. "' not found. ")
        sleep(2)
    end
end

while true do
    drawDesktop()
    local event, button, x, y = os.pullEvent("mouse_click")

    if x >= 2 and x <= 25 then
        if y == 5 then
            safeRun("start.lua")
        elseif y == 6 then
            safeRun("storage.lua") -- not a thing yet
        elseif y == 7 then
            safeRun("discord.lua")
        elseif y == 8 then
            safeRun("console.lua")
        elseif y == 10 then
            if mon then
                mon.setBackgroundColor(colors.black)
                mon.clear()
            end
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1,1)
            term.setTextColor(colors.green)
            print("root@hutcch-os:~# shutdown -h now")
            sleep(1)
            os.shutdown()
        end
    end
end
