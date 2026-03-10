local files = {
    "install.lua", "startup.lua", "desktop.lua", "start.lua", 
    "discord.lua", "console.lua"
}

term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.blue)
print("--- HUTCCH.CO OS DISK BURNER ---")
term.setTextColor(colors.white)

if not fs.exists("disk") then
    term.setTextColor(colors.red)
    print("ERROR: No floppy disk detected.")
    print("Please insert a blank disk into the drive.")
    return
end

print("Formatting and Burning OS to Floppy...\n")

for _, file in ipairs(files) do
    if fs.exists("disk/" .. file) then fs.delete("disk/" .. file) end
    
    if fs.exists(file) then
        fs.copy(file, "disk/" .. file)
        term.setTextColor(colors.gray)
        write("Burning ")
        term.setTextColor(colors.white)
        write(file .. " ... ")
        term.setTextColor(colors.green)
        print("[OK]")
    else
        term.setTextColor(colors.red)
        print("MISSING MASTER FILE: " .. file)
    end
    sleep(0.1)
end
term.setTextColor(colors.blue)
print("\n--------------------------------")
term.setTextColor(colors.yellow)
print(" BURN COMPLETE. DISK READY FOR SALE.")
