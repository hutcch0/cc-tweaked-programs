os.pullEvent = os.pullEventRaw
local screenW, screenH = term.getSize()
local myPassword = "password"

local function drawProgressBar(y, percent)
    local width = 20
    local filled = math.floor((percent / 100) * width)
    term.setCursorPos(math.floor((screenW - width) / 2), y)
    term.setTextColor(colors.white)
    write("[")
    term.setTextColor(colors.blue)
    write(string.rep("=", filled))
    term.setTextColor(colors.gray)
    write(string.rep("-", width - filled))
    term.setTextColor(colors.white)
    write("] " .. percent .. "%")
end

-- 1. BIOS BOOT SEQUENCE
term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.lightGray)
print("HUTCCH CORE ARCHITECTURE v1.0")
print("MEMORY CHECK: 512KB OK")
sleep(0.5)
print("MOUNTING HUTCCH.CO KERNEL...")
for i = 0, 100, 20 do
    drawProgressBar(5, i)
    sleep(0.1)
end

-- 2. HUTCCH.CO LOGIN SCREEN
local authenticated = false
while not authenticated do
    term.setBackgroundColor(colors.black)
    term.clear()
    
    -- Draw Login Box
    local centerX = math.floor(screenW / 2)
    term.setCursorPos(centerX - 10, 5)
    term.setTextColor(colors.blue)
    print("      HUTCCH.CO SECURITY")
    term.setCursorPos(centerX - 10, 6)
    print("----------------------------")
    
    term.setCursorPos(centerX - 8, 8)
    term.setTextColor(colors.white)
    write("PASSWORD: ")
    
    -- masks the input with asterisks
    local input = read("*")
    
    if input == myPassword then
        authenticated = true
        term.setCursorPos(centerX - 8, 10)
        term.setTextColor(colors.green)
        print("ACCESS GRANTED")
        sleep(1)
    else
        term.setCursorPos(centerX - 8, 10)
        term.setTextColor(colors.red)
        print("ACCESS DENIED")
        -- Log failed attempt to Discord
        shell.run("discord.lua", "alert")
        sleep(2)
    end
end

-- 3. LAUNCH THE DESKTOP
shell.run("desktop.lua")
