local screenW, screenH = term.getSize()
os.pullEvent = os.pullEventRaw

-- --- LOAD CONFIG OR RUN SETUP ---
local config = {}
if not fs.exists("hutcch.cfg") then
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.blue)
    print("========================================")
    print("    HUTCCH.CO OS v6.0 - SYS SETUP       ")
    print("========================================")
    term.setTextColor(colors.white)

    if pocket then
        print("Mobile Device Configuration:\n")
        write("Enter your Main Command Hub ID: ")
        config.hubID = tonumber(read())
    else
        print("Command Hub Configuration:\n")
        write("Set Master Password (or leave blank): ")
        config.password = read()
        write("Enter Discord Webhook (or leave blank): ")
        config.webhook = read()
    end

    local f = fs.open("hutcch.cfg", "w")
    f.write(textutils.serialize(config))
    f.close()

    term.setTextColor(colors.green)
    print("\nSetup Complete! Rebooting...")
    sleep(1)
else
    local f = fs.open("hutcch.cfg", "r")
    config = textutils.unserialize(f.readAll()) or {}
    f.close()
end

-- --- KERNEL BOOT ---
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

if not pocket then
    term.setTextColor(colors.lightGray)
    local bootLogs = {
        "Loading kernel hutcch-core-6.0.0-cc...",
        "Probing hardware... [OK]",
        "Mounting /dev/sda1 on /root... [OK]",
        "Starting networking service... [OK]",
        "Initializing Hutcch Display Manager...",
        "Boot sequence complete."
    }
    for _, log in ipairs(bootLogs) do
        print(log)
        sleep(0.3)
    end
    sleep(0.5)
end

-- BOOT ROUTER
if pocket then
    shell.run("pocket.lua")
else
    -- --- LOGIN SCREEN ---
    if config.password and config.password ~= "" then
        local auth = false
        while not auth do
            term.setBackgroundColor(colors.black)
            term.clear()

            local logo = {
                "  _    _  ",
                " | |  | | ",
                " | |__| | ",
                " |  __  | ",
                " | |  | | ",
                " |_|  |_| "
            }

            term.setTextColor(colors.blue)
            local startY = math.floor((screenH - #logo) / 2) - 1
            for i, line in ipairs(logo) do
                term.setCursorPos(math.floor((screenW - 10) / 2), startY + i)
                print(line)
            end

            term.setTextColor(colors.lightGray)
            local sub = "HUTCCH.CO OS v6.0"
            term.setCursorPos(math.floor((screenW - #sub) / 2), startY + #logo + 2)
            print(sub)

            term.setCursorPos(2, screenH - 1)
            term.setTextColor(colors.white)
            write("hutcch login: ")

            local input = read("*")
            if input == config.password then
                auth = true
                term.setCursorPos(2, screenH)
                term.setTextColor(colors.green)
                print("Authentication successful.")
                sleep(0.5)
            else
                term.setCursorPos(2, screenH)
                term.setTextColor(colors.red)
                print("Login incorrect")
                shell.run("discord.lua", "alert")
                sleep(2)
            end
        end
    end
    shell.run("desktop.lua")
end
