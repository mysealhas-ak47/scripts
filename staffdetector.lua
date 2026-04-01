local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

Notification:Notify(
    {Title = "✅Competitor Administrator Detector | 2v2版本", Description = "The detector has already been activated. OwO"},
    {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 5, Type = "default"}
)

local function playSound(id)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(id)
    sound.Parent = game:GetService("SoundService")
    sound.Volume = 0.7
    sound:Play()
    game.Debris:AddItem(sound, 6)
end

playSound(113194405128446)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local alreadyNotifiedServerSize = false
local alreadyNotifiedNewPlayer = false
local checkedPlayers = {}

local groupId = game.CreatorId
local startTime = tick()
local previousPlayerCount = #Players:GetPlayers()

local knownFriendStaff = {}

local function getRankName(player)
    local success, rankName = pcall(function()
        return player:GetRoleInGroup(groupId)
    end)
    if success and rankName and rankName ~= "" then
        return rankName:lower()
    end
    return ""
end

local function checkPlayerRank(player)
    if player == Players.LocalPlayer or checkedPlayers[player.UserId] then
        return false
    end
    
    checkedPlayers[player.UserId] = true
    
    local rank = getRankName(player)
    if rank ~= "" then
        local isSuspect = rank:find("mod") or rank:find("staff") or 
                          rank:find("contributor") or rank:find("script") or 
                          rank:find("build")
        
        if isSuspect then
            Notification:Notify(
                {Title = "⚠️ Competitor Administrator Detector", 
                 Description = "Administrator detected [" .. player.Name .. "]"},
                {OutlineColor = Color3.fromRGB(255, 0, 0), Time = 180, Type = "default"}
            )
            playSound(5855421995)
            return true
        end
    end
    return false
end

local function getFriendStaffInfo()
    local list = {}
    local seen = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        local success, pages = pcall(function()
            return Players:GetFriendsAsync(plr.UserId)
        end)
        
        if success and pages then
            while true do
                local page = pages:GetCurrentPage()
                for _, friend in ipairs(page) do
                    if checkedPlayers[friend.Id] and not seen[friend.Id] then
                        table.insert(list, string.sub(friend.Name, 1, 6) .. (#friend.Name > 6 and "..." or ""))
                        seen[friend.Id] = true
                    end
                end
                if pages.IsFinished then break end
                pages:AdvanceToNextPageAsync()
            end
        end
    end
    
    return list
end

local hasAnyStaff = false
for _, player in ipairs(Players:GetPlayers()) do
    if checkPlayerRank(player) then
        hasAnyStaff = true
    end
end

local friendStaff = getFriendStaffInfo()
if #friendStaff > 0 then
    local desc = "Detected an administrator among your friends: " .. table.concat(friendStaff, ", ")
    Notification:Notify(
        {Title = "⚠️Competitor Administrator Detector", Description = desc},
        {OutlineColor = Color3.fromRGB(255, 165, 0), Time = 180, Type = "default"}
    )
    playSound(5855421995)
end

RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    local playerList = Players:GetPlayers()
    local currentCount = #playerList

    if currentCount > 4 and not alreadyNotifiedServerSize then
        alreadyNotifiedServerSize = true
        Notification:Notify(
            {Title = "⚠️ Competitor Administrator Detector", Description = "Possible administrator detected | Server personnel exceed 4 people"},
            {OutlineColor = Color3.fromRGB(255, 0, 0), Time = 60, Type = "default"}
        )
        playSound(5855421995)
    end

    if currentTime - startTime >= 3 then
        if currentCount > previousPlayerCount and not alreadyNotifiedNewPlayer then
            alreadyNotifiedNewPlayer = true
            Notification:Notify(
                {Title = "⚠️Competitor Administrator Detector", Description = "A new user has joined"},
                {OutlineColor = Color3.fromRGB(255, 255, 0), Time = 15, Type = "default"}
            )
            playSound(5855421995)
        end
        previousPlayerCount = currentCount
    end
end)

Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    local isStaff = checkPlayerRank(player)
    
    local newFriendStaff = getFriendStaffInfo()
    local addedFriends = {}
    
    for _, name in ipairs(newFriendStaff) do
        if not table.find(knownFriendStaff, name) then
            table.insert(addedFriends, name)
            table.insert(knownFriendStaff, name)
        end
    end
    
    if #addedFriends > 0 then
        local desc = "Newly detected administrator among friends: " .. table.concat(addedFriends, ", ")
        Notification:Notify(
            {Title = "⚠️Competitor Administrator Detector", Description = desc},
            {OutlineColor = Color3.fromRGB(255, 165, 0), Time = 180, Type = "default"}
        )
        playSound(5855421995)
    end
    
    if isStaff then
        Notification:Notify(
            {Title = "⚠️Competitor Administrator Detector", Description = "A new administrator has joined the server"},
            {OutlineColor = Color3.fromRGB(255, 0, 0), Time = 180, Type = "default"}
        )
        playSound(5855421995)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    checkedPlayers[player.UserId] = nil
end)
