local webhookURL = "webhookURL"
local args = { ... } 
local mode = args[1] 

local message = ":green_circle: **Hutcch.co System Status:** Online and Operational."

-- Change message based on the "mode" argument
if mode == "alert" then
    message = ":warning: **Security Alert:** Unauthorized login attempt on Hutcch.co OS!"
elseif mode == "complete" then
    message = ":checkered_flag: **Operation Complete:** A mining unit has returned to the surface."
elseif mode == "console" then
    message = ":desktop: **Command Sent By Console** Someone is inside the console"
end

local function sendToDiscord(msg)
    if not http then return false end
    local payload = textutils.serializeJSON({
        username = "Hutcch.co OS",
        content = msg,
        avatar_url = "photo url here"
    })
    local response = http.post(webhookURL, payload, {["Content-Type"] = "application/json"})
    return response ~= nil
end

print("Communicating with Hutcch.co Servers...")
if sendToDiscord(message) then
    print("Signal Sent Successfully.")
else
    print("Signal Failed.")
end
sleep(1)
