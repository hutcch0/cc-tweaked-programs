local w, h = term.getSize()

local function drawNeofetch()
    local logo = {
        "  _    _  ",
        " | |  | | ",
        " | |__| | ",
        " |  __  | ",
        " | |  | | ",
        " |_|  |_| "
    }
    
    term.setTextColor(colors.blue)
    for i, line in ipairs(logo) do
        term.setCursorPos(2, 2 + i)
        print(line)
    end
    
    term.setTextColor(colors.white)
    local statsX = 15
    term.setCursorPos(statsX, 3) print("OS: Hutcch.co OS v6.0")
    term.setCursorPos(statsX, 4) print("KERNEL: H-Core 4.2.0-CC")
    term.setCursorPos(statsX, 5) print("UPTIME: " .. math.floor(os.clock()) .. "s")
    term.setCursorPos(statsX, 6) print("SHELL: hutcch-sh")
    term.setCursorPos(statsX, 7) print("CPU: TurtleCore R-600")
    term.setCursorPos(statsX, 8) print("MEM: 512KB / 512KB")
end

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.green)
print("HUTCCH.CO TERMINAL INTERFACE")
term.setTextColor(colors.white)
print("Type 'exit' to return to Desktop.")
print("Type 'help' for commands.")

while true do
    term.setTextColor(colors.blue)
    write("hutcch@admin:~$ ")
    term.setTextColor(colors.white)
    
    local input = read()
    
    if input == "neofetch" then
        drawNeofetch()
        print("\n")
    elseif input == "help" then
        print("Available: neofetch, clear, discord-ping, burn, exit")
    elseif input == "clear" then
        term.clear()
        term.setCursorPos(1,1)
    elseif input == "discord-ping" then
        shell.run("discord.lua", "console")
        elseif input == "burn" then
        shell.run("burn.lua")
    elseif input == "exit" then
        return
    else
        print("Command not found: " .. input)
    end
end
