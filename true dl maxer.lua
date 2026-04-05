getgenv().autoload

local REPLACEMENTS = {
    ["16537449730"] = "rbxassetid://4764109000",
    ["16537337310"] = "rbxassetid://4764109000",

    ["16530229616"] = "rbxassetid://135097031120155",
    ["16530229541"] = "rbxassetid://135097031120155",
    ["16530229695"] = "rbxassetid://135097031120155",
}


local REMOVE_IDS = {
    ["12307734932"]=true,["12307583853"]=true,
    ["18226913133"]=true,["24108148"]=true,["1053546634"]=true,
    ["1858069131"]=true,["2045471763"]=true,["4634384903"]=true,
    ["6372755229"]=true,["7261161576"]=true,["9920484153"]=true,
    ["7658055825"]=true,["10055526642"]=true,["10237720195"]=true,
    ["10312359831"]=true,["10372251207"]=true,["11454212345"]=true,
    ["11191634674"]=true,["11454576739"]=true,["11477602857"]=true,
    ["11481072646"]=true,["12257815938"]=true,["12993641937"]=true,
    ["12994255512"]=true,["12994305541"]=true,["12995298072"]=true,
    ["13926595956"]=true,["13970862959"]=true,["14003050924"]=true,
    ["14220695494"]=true,["14580701813"]=true,["14632162943"]=true,
    ["14632191598"]=true,["15394335373"]=true,["15439244719"]=true,
    ["16833617681"]=true,["16885732418"]=true,["17098901439"]=true,
    ["17098901515"]=true,["17549641791"]=true,["17848929675"]=true,
    ["17878306151"]=true,["18341247839"]=true,["18341252690"]=true,
    ["18954440250"]=true,

  
    
    ["99205746879920517696"]=true
}

local function extractId(str)
    if not str then return nil end
    return string.match(str, "%d+")
end

local function handle(value)
    if not value then return value end

    local id = extractId(value)
    if not id then return value end

  
    if REMOVE_IDS[id] then
        return ""
    end


    if REPLACEMENTS[id] then
        return REPLACEMENTS[id]
    end

    return value
end

local function process(obj)
    if obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Texture = handle(obj.Texture)

    elseif obj:IsA("MeshPart") then
        obj.TextureID = handle(obj.TextureID)
    end
end

for _, obj in ipairs(game:GetDescendants()) do
    process(obj)
end

game.DescendantAdded:Connect(function(obj)
    task.wait()


local plrs = game:GetService("Players")
local rf = game:GetService("ReplicatedFirst")
local lp = plrs.LocalPlayer

print("bypass started")

local fake = Instance.new("RemoteEvent")
fake.Name = "ClientAlert"
fake.Parent = lp


local pmt = getrawmetatable(lp)
local oldnc = pmt.__namecall
setreadonly(pmt, false)
pmt.__namecall = newcclosure(function(self, ...)
if getnamecallmethod() == "WaitForChild" and select(1, ...) == "ClientAlert" then
return fake
end
return oldnc(self, ...)
end)
setreadonly(pmt, true)


local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
local m = getnamecallmethod()

if self == lp and (m == "Kick" or m == "kick") then return end
if m:lower():find("kick") or m == "Shutdown" then return end
if m == "FireServer" and self == fake then
return
end
return old(self, ...)
end)
setreadonly(mt, true)


local ls3 = rf:WaitForChild("LocalScript3", 10)
local c = 0
for _, f in getgc(false) do
if typeof(f) == "function" then
local ok, e = pcall(getfenv, f)
if ok and e then
local scr = rawget(e, "script")
if scr and (scr == ls3 or tostring(scr):find("LoadingScreen")) then
local ok2, cs = pcall(debug.getconstants, f)
if ok2 then
for _, k in cs do
if typeof(k) == "string" and (k:find("TakeTheL") or k:find("ban") or k:find("kick")) then -- TakeTheL is found in the decompiled LocalScript3 result
hookfunction(f, function() end)
c = c + 1
break
end
end
end
end
end
end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerScripts = player.PlayerScripts
local controllers = playerScripts.Controllers
local EnumLibrary = require(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 10))
if EnumLibrary then EnumLibrary:WaitForEnumBuilder() end
local CosmeticLibrary = require(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 10))
local ItemLibrary = require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 10))
local DataController = require(controllers:WaitForChild("PlayerDataController", 10))
local equipped, favorites = {}, {}
local constructingWeapon, viewingProfile = nil, nil
local lastUsedWeapon = nil
local function cloneCosmetic(name, cosmeticType, options)
    local base = CosmeticLibrary.Cosmetics[name]
    if not base then return nil end
    local data = {}
    for key, value in pairs(base) do data[key] = value end
    data.Name = name
    data.Type = data.Type or cosmeticType
    data.Seed = data.Seed or math.random(1, 1000000)
    if EnumLibrary then
        local success, enumId = pcall(EnumLibrary.ToEnum, EnumLibrary, name)
        if success and enumId then data.Enum, data.ObjectID = enumId, data.ObjectID or enumId end
    end
    if options then
        if options.inverted ~= nil then data.Inverted = options.inverted end
        if options.favoritesOnly ~= nil then data.OnlyUseFavorites = options.favoritesOnly end
    end
    return data
end
local saveFile = "unlockall/config.json"
local function saveConfig()
    if not writefile then return end
    pcall(function()
        local config = {equipped = {}, favorites = favorites}
        for weapon, cosmetics in pairs(equipped) do
            config.equipped[weapon] = {}
            for cosmeticType, cosmeticData in pairs(cosmetics) do
                if cosmeticData and cosmeticData.Name then
                    config.equipped[weapon][cosmeticType] = {
                        name = cosmeticData.Name, seed = cosmeticData.Seed, inverted = cosmeticData.Inverted
                    }
                end
            end
        end
        makefolder("unlockall")
        writefile(saveFile, HttpService:JSONEncode(config))
    end)
end
local function loadConfig()
    if not readfile or not isfile or not isfile(saveFile) then return end
    pcall(function()
        local config = HttpService:JSONDecode(readfile(saveFile))
        if config.equipped then
            for weapon, cosmetics in pairs(config.equipped) do
                equipped[weapon] = {}
                for cosmeticType, cosmeticData in pairs(cosmetics) do
                    local cloned = cloneCosmetic(cosmeticData.name, cosmeticType, {inverted = cosmeticData.inverted})
                    if cloned then cloned.Seed = cosmeticData.seed equipped[weapon][cosmeticType] = cloned end
                end
            end
        end
        favorites = config.favorites or {}
    end)
end
CosmeticLibrary.OwnsCosmeticNormally = function() return true end
CosmeticLibrary.OwnsCosmeticUniversally = function() return true end
CosmeticLibrary.OwnsCosmeticForWeapon = function() return true end
local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
    if name:find("MISSING_") then return originalOwnsCosmetic(self, inventory, name, weapon) end
    return true
end
local originalGet = DataController.Get
DataController.Get = function(self, key)
    local data = originalGet(self, key)
    if key == "CosmeticInventory" then
        local proxy = {}
        if data then for k, v in pairs(data) do proxy[k] = v end end
        return setmetatable(proxy, {__index = function() return true end})
    end
    if key == "FavoritedCosmetics" then
        local result = data and table.clone(data) or {}
        for weapon, favs in pairs(favorites) do
            result[weapon] = result[weapon] or {}
            for name, isFav in pairs(favs) do result[weapon][name] = isFav end
        end
        return result
    end
    return data
end
local originalGetWeaponData = DataController.GetWeaponData
DataController.GetWeaponData = function(self, weaponName)
    local data = originalGetWeaponData(self, weaponName)
    if not data then return nil end
    
    local merged = {}
    for key, value in pairs(data) do merged[key] = value end
    merged.Name = weaponName
    if equipped[weaponName] then
        for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do merged[cosmeticType] = cosmeticData end
    end
    return merged
end
local FighterController
pcall(function() FighterController = require(controllers:WaitForChild("FighterController", 10)) end)
if hookmetamethod then
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local dataRemotes = remotes and remotes:FindFirstChild("Data")
    local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
    local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
    local replicationRemotes = remotes and remotes:FindFirstChild("Replication")
    local fighterRemotes = replicationRemotes and replicationRemotes:FindFirstChild("Fighter")
    local useItemRemote = fighterRemotes and fighterRemotes:FindFirstChild("UseItem")
    if equipRemote then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
            local args = {...}
            if useItemRemote and self == useItemRemote then
                local objectID = args[1]
                if FighterController then
                    pcall(function()
                        local fighter = FighterController:GetFighter(player)
                        if fighter and fighter.Items then
                            for _, item in pairs(fighter.Items) do
                                if item:Get("ObjectID") == objectID then
                                    lastUsedWeapon = item.Name
                                    break
                                end
                            end
                        end
                    end)
                end
            end            
            if self == equipRemote then
                local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}                
                if cosmeticName and cosmeticName ~= "None" and cosmeticName ~= "" then
                    local inventory = DataController:Get("CosmeticInventory")
                    if inventory and rawget(inventory, cosmeticName) then return oldNamecall(self, ...) end
                end                
                equipped[weaponName] = equipped[weaponName] or {}                
                if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                    equipped[weaponName][cosmeticType] = nil
                    if not next(equipped[weaponName]) then equipped[weaponName] = nil end
                else
                    local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                    if cloned then equipped[weaponName][cosmeticType] = cloned end
                end                
                task.defer(function()
                    pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
                    task.wait(0.2)
                    saveConfig()
                end)
                return
            end            
            if self == favoriteRemote then
                favorites[args[1]] = favorites[args[1]] or {}
                favorites[args[1]][args[2]] = args[3] or nil
                saveConfig()
                task.spawn(function() pcall(function() DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
                return
            end            
            return oldNamecall(self, ...)
        end)
    end
end
local ClientItem
pcall(function() ClientItem = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) end)
if ClientItem and ClientItem._CreateViewModel then
    local originalCreateViewModel = ClientItem._CreateViewModel
    ClientItem._CreateViewModel = function(self, viewmodelRef)
        local weaponName = self.Name
        local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
        constructingWeapon = (weaponPlayer == player) and weaponName or nil    
        if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Skin and viewmodelRef then
            local dataKey, skinKey, nameKey = self:ToEnum("Data"), self:ToEnum("Skin"), self:ToEnum("Name")
            if viewmodelRef[dataKey] then
                viewmodelRef[dataKey][skinKey] = equipped[weaponName].Skin
                viewmodelRef[dataKey][nameKey] = equipped[weaponName].Skin.Name
            elseif viewmodelRef.Data then
                viewmodelRef.Data.Skin = equipped[weaponName].Skin
                viewmodelRef.Data.Name = equipped[weaponName].Skin.Name
            end
        end
        local result = originalCreateViewModel(self, viewmodelRef)
        constructingWeapon = nil
        return result
    end
end
local viewModelModule = player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
if viewModelModule then
    local ClientViewModel = require(viewModelModule)
    if ClientViewModel.GetWrap then
        local originalGetWrap = ClientViewModel.GetWrap
        ClientViewModel.GetWrap = function(self)
            local weaponName = self.ClientItem and self.ClientItem.Name
            local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
            if weaponName and weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap then
                return equipped[weaponName].Wrap
            end
            return originalGetWrap(self)
        end
    end
    local originalNew = ClientViewModel.new
    ClientViewModel.new = function(replicatedData, clientItem)
        local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
        local weaponName = constructingWeapon or clientItem.Name
        if weaponPlayer == player and equipped[weaponName] then
            local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
            local dataKey = ReplicatedClass:ToEnum("Data")
            replicatedData[dataKey] = replicatedData[dataKey] or {}
            local cosmetics = equipped[weaponName]
            if cosmetics.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = cosmetics.Skin end
            if cosmetics.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
            if cosmetics.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = cosmetics.Charm end
        end
        local result = originalNew(replicatedData, clientItem)
        if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap and result._UpdateWrap then
            result:_UpdateWrap()
            task.delay(0.1, function() if not result._destroyed then result:_UpdateWrap() end end)
        end
        return result
    end
end
local originalGetViewModelImage = ItemLibrary.GetViewModelImageFromWeaponData
ItemLibrary.GetViewModelImageFromWeaponData = function(self, weaponData, highRes)
    if not weaponData then return originalGetViewModelImage(self, weaponData, highRes) end
    local weaponName = weaponData.Name
    local shouldShowSkin = (weaponData.Skin and equipped[weaponName] and weaponData.Skin == equipped[weaponName].Skin) or (viewingProfile == player and equipped[weaponName] and equipped[weaponName].Skin)
    if shouldShowSkin and equipped[weaponName] and equipped[weaponName].Skin then
        local skinInfo = self.ViewModels[equipped[weaponName].Skin.Name]
        if skinInfo then return skinInfo[highRes and "ImageHighResolution" or "Image"] or skinInfo.Image end
    end
    return originalGetViewModelImage(self, weaponData, highRes)
end
pcall(function()
    local ViewProfile = require(player.PlayerScripts.Modules.Pages.ViewProfile)
    if ViewProfile and ViewProfile.Fetch then
        local originalFetch = ViewProfile.Fetch
        ViewProfile.Fetch = function(self, targetPlayer)
            viewingProfile = targetPlayer
            return originalFetch(self, targetPlayer)
        end
    end
end)
local ClientEntity
pcall(function() ClientEntity = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity) end)
if ClientEntity and ClientEntity.ReplicateFromServer then
    local originalReplicateFromServer = ClientEntity.ReplicateFromServer
    ClientEntity.ReplicateFromServer = function(self, action, ...)
        if action == "FinisherEffect" then
            local args = {...}
            local killerName = args[3]            
            local decodedKiller = killerName
            if type(killerName) == "userdata" and EnumLibrary and EnumLibrary.FromEnum then
                local ok, decoded = pcall(EnumLibrary.FromEnum, EnumLibrary, killerName)
                if ok and decoded then decodedKiller = decoded end
            end            
            local isOurKill = tostring(decodedKiller) == player.Name or tostring(decodedKiller):lower() == player.Name:lower()            
            if isOurKill and lastUsedWeapon and equipped[lastUsedWeapon] and equipped[lastUsedWeapon].Finisher then
                local finisherData = equipped[lastUsedWeapon].Finisher
                local finisherEnum = finisherData.Enum                
                if not finisherEnum and EnumLibrary then
                    local ok, result = pcall(EnumLibrary.ToEnum, EnumLibrary, finisherData.Name)
                    if ok and result then finisherEnum = result end
                end                
                if finisherEnum then
                    args[1] = finisherEnum
                    return originalReplicateFromServer(self, action, unpack(args))
                end
            end
        end        
        return originalReplicateFromServer(self, action, ...)
    end
end
loadConfig()
  
    local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()


local visualState = {
    time = 0,
    rotationProgress = 0,
    currentRotationSpeed = 0.8,
    smoothedRotation = 5,

    lines = {
        top = {Size = UDim2.new(0, 3, 0, 25), Position = UDim2.new(0.5, -1.5, 0, 0), Color = Color3.new(1,1,1)},
        bottom = {Size = UDim2.new(0, 3, 0, 25), Position = UDim2.new(0.5, -1.5, 1, -25), Color = Color3.new(1,1,1)},
        left = {Size = UDim2.new(0, 25, 0, 3), Position = UDim2.new(0, 0, 0.5, -1.5), Color = Color3.new(1,1,1)},
        right = {Size = UDim2.new(0, 25, 0, 3), Position = UDim2.new(1, -25, 0.5, -1.5), Color = Color3.new(1,1,1)},
    },

    text = {
        Text = " ", --custom text
        Position = UDim2.new(0, 0, 0, 0),
        Color = Color3.new(1,1,1),
        Font = Enum.Font.Arcade,
        TextScaled = true,
    }
}

local screenGui
local aimContainer
local topLine, bottomLine, leftLine, rightLine
local textLabel

local lineLength = 25
local lineThickness = 3
local baseRotationSpeed = 0.8
local pulseSpeed = 2.5
local minLength = -10
local maxLength = -30

local time = 0
local rotationProgress = 0
local currentRotationSpeed = baseRotationSpeed
local smoothedRotation = 5

local function createLine(parent, size, position, color)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.ZIndex = 5
    frame.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(0,0,0)
    stroke.Thickness = 1
    stroke.Parent = frame

    return frame
end


local function createTextLabel(parent, text, position, color, font, scaled)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Position = position
    label.TextColor3 = color
    label.Font = font
    label.TextScaled = scaled
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 150, 0, 23)
    label.ZIndex = 10
    label.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    stroke.Color = Color3.new(0,0,0)
    stroke.Thickness = 1
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = label

    return label
end

local function clearGui()
    if screenGui then
        screenGui:Destroy()
        screenGui = nil
    end
end


local function createGui()
    clearGui()

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimSightGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    aimContainer = Instance.new("Frame")
    aimContainer.BackgroundTransparency = 1
    aimContainer.Size = UDim2.new(0, 25, 0, 25)
    aimContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    aimContainer.Parent = screenGui

    -- Create lines with saved params
    topLine = createLine(aimContainer, visualState.lines.top.Size, visualState.lines.top.Position, visualState.lines.top.Color)
    bottomLine = createLine(aimContainer, visualState.lines.bottom.Size, visualState.lines.bottom.Position, visualState.lines.bottom.Color)
    leftLine = createLine(aimContainer, visualState.lines.left.Size, visualState.lines.left.Position, visualState.lines.left.Color)
    rightLine = createLine(aimContainer, visualState.lines.right.Size, visualState.lines.right.Position, visualState.lines.right.Color)


    textLabel = createTextLabel(screenGui, visualState.text.Text, visualState.text.Position, visualState.text.Color, visualState.text.Font, visualState.text.TextScaled)
end


local function saveVisualState()
    visualState.time = time
    visualState.rotationProgress = rotationProgress
    visualState.currentRotationSpeed = currentRotationSpeed
    visualState.smoothedRotation = smoothedRotation

    visualState.lines.top.Size = topLine.Size
    visualState.lines.top.Position = topLine.Position
    visualState.lines.top.Color = topLine.BackgroundColor3

    visualState.lines.bottom.Size = bottomLine.Size
    visualState.lines.bottom.Position = bottomLine.Position
    visualState.lines.bottom.Color = bottomLine.BackgroundColor3

    visualState.lines.left.Size = leftLine.Size
    visualState.lines.left.Position = leftLine.Position
    visualState.lines.left.Color = leftLine.BackgroundColor3

    visualState.lines.right.Size = rightLine.Size
    visualState.lines.right.Position = rightLine.Position
    visualState.lines.right.Color = rightLine.BackgroundColor3

    visualState.text.Text = textLabel.Text
    visualState.text.Position = textLabel.Position
    visualState.text.Color = textLabel.TextColor3
    visualState.text.Font = textLabel.Font
    visualState.text.TextScaled = textLabel.TextScaled
end

local function restoreVisualState()
    if not (topLine and bottomLine and leftLine and rightLine and textLabel) then
        return
    end

    time = visualState.time or 0
    rotationProgress = visualState.rotationProgress or 0
    currentRotationSpeed = visualState.currentRotationSpeed or baseRotationSpeed
    smoothedRotation = visualState.smoothedRotation or 5

    topLine.Size = visualState.lines.top.Size or topLine.Size
    topLine.Position = visualState.lines.top.Position or topLine.Position
    topLine.BackgroundColor3 = visualState.lines.top.Color or topLine.BackgroundColor3

    bottomLine.Size = visualState.lines.bottom.Size or bottomLine.Size
    bottomLine.Position = visualState.lines.bottom.Position or bottomLine.Position
    bottomLine.BackgroundColor3 = visualState.lines.bottom.Color or bottomLine.BackgroundColor3

    leftLine.Size = visualState.lines.left.Size or leftLine.Size
    leftLine.Position = visualState.lines.left.Position or leftLine.Position
    leftLine.BackgroundColor3 = visualState.lines.left.Color or leftLine.BackgroundColor3

    rightLine.Size = visualState.lines.right.Size or rightLine.Size
    rightLine.Position = visualState.lines.right.Position or rightLine.Position
    rightLine.BackgroundColor3 = visualState.lines.right.Color or rightLine.BackgroundColor3

    textLabel.Text = visualState.text.Text or textLabel.Text
    textLabel.Position = visualState.text.Position or textLabel.Position
    textLabel.TextColor3 = visualState.text.Color or textLabel.TextColor3
    textLabel.Font = visualState.text.Font or textLabel.Font
    textLabel.TextScaled = visualState.text.TextScaled or textLabel.TextScaled
end


local function getRainbowColor(t)
    local r = math.sin(t * 0.6) * 0.5 + 0.5
    local g = math.sin(t * 0.6 + 2) * 0.5 + 0.5
    local b = math.sin(t * 0.6 + 4) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

local function calculateRotationSpeed(progress)
    local slowdownStart = 0.6
    local slowdownDuration = 0.35
    local minSlowdownSpeed = 0.3
    local baseRotationSpeedLocal = baseRotationSpeed

    if progress >= slowdownStart then
        local slowdownProgress = (progress - slowdownStart) / slowdownDuration
        local easedProgress = slowdownProgress * slowdownProgress
        local slowdownFactor = 1 - (easedProgress * (1 - minSlowdownSpeed))
        return baseRotationSpeedLocal * math.max(slowdownFactor, minSlowdownSpeed)
    else
        return baseRotationSpeedLocal
    end
end

local function smoothRotation(currentRot, targetRot, smoothing)
    return currentRot + (targetRot - currentRot) * smoothing
end

local function smoothPulse(t, speed)
    local rawPulse = math.sin(t * speed) * 0.5 + 0.5
    return rawPulse * rawPulse
end


local function onCharacterAdded(character)
    createGui()
    restoreVisualState()

    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        saveVisualState()
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
    onCharacterAdded(player.Character)
end

RunService.RenderStepped:Connect(function(deltaTime)
    if not (aimContainer and topLine and bottomLine and leftLine and rightLine and textLabel) then
        return
    end

    time = time + deltaTime

    aimContainer.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
    textLabel.Position = UDim2.new(0, mouse.X - 70, 0, mouse.Y + 50)

    rotationProgress = (rotationProgress + currentRotationSpeed * deltaTime) % 1
    currentRotationSpeed = calculateRotationSpeed(rotationProgress)

    local targetRotation = rotationProgress * 360
    smoothedRotation = smoothRotation(smoothedRotation, targetRotation, 1)
    aimContainer.Rotation = smoothedRotation

    local pulse = smoothPulse(time, pulseSpeed)
    local currentLength = minLength + (maxLength - minLength) * pulse

    topLine.Size = UDim2.new(0, lineThickness, 0, currentLength)
    bottomLine.Size = UDim2.new(0, lineThickness, 0, currentLength)
    leftLine.Size = UDim2.new(0, currentLength, 0, lineThickness)
    rightLine.Size = UDim2.new(0, currentLength, 0, lineThickness)

    topLine.Position = UDim2.new(0.5, -lineThickness / 2, 0, 0)
    bottomLine.Position = UDim2.new(0.5, -lineThickness / 2, 1, -currentLength)
    leftLine.Position = UDim2.new(0, 0, 0.5, -lineThickness / 2)
    rightLine.Position = UDim2.new(1, -currentLength, 0.5, -lineThickness / 2)

    local rainbowColor = getRainbowColor(time)

    topLine.BackgroundColor3 = rainbowColor
    bottomLine.BackgroundColor3 = rainbowColor
    leftLine.BackgroundColor3 = rainbowColor
    rightLine.BackgroundColor3 = rainbowColor

    textLabel.TextColor3 = rainbowColor
end)
