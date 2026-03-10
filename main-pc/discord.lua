-- Load config
local config = {}
if fs.exists("hutcch.cfg") then
    local f = fs.open("hutcch.cfg", "r")
    config = textutils.unserialize(f.readAll()) or {}
    f.close()
end

local webhookURL = config.webhook
if not webhookURL or webhookURL == "" then
    print("Discord integration disabled.")
    print("Edit hutcch.cfg to add a Webhook URL.")
    sleep(1.5)
    return
end

local args = { ... } 
local mode = args[1] 

local message = ":green_circle: **Hutcch.co System Status:** Online and Operational."
if mode == "alert" then message = ":warning: **Security Alert:** Unauthorized login attempt!"
elseif mode == "complete" then message = ":checkered_flag: **Operation Complete:** A mining unit has returned."
elseif mode == "console" then message = ":desktop: **Command Sent By Console**" 
elseif mode == "custom" and args[2] then message = args[2] end

local function sendToDiscord(msg)
    if not http then return false end
    local payload = textutils.serializeJSON({username = "Hutcch.co OS", content = msg})
    local response = http.post(webhookURL, payload, {["Content-Type"] = "application/json"})
    return response ~= nil
end

print("Communicating with Discord...")
if sendToDiscord(message) then print("Signal Sent Successfully.")
else print("Signal Failed. Check URL and HTTP settings.") end
sleep(1)
