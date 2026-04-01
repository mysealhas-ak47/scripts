local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Visual state storage (parameters only)
local visualState = {
    time = 0,
    rotationProgress = 0,
    currentRotationSpeed = 0.8,
    smoothedRotation = 5,
    -- Lines params: size, position, color
    lines = {
        top = {Size = UDim2.new(0, 3, 0, 25), Position = UDim2.new(0.5, -1.5, 0, 0), Color = Color3.new(1,1,1)},
        bottom = {Size = UDim2.new(0, 3, 0, 25), Position = UDim2.new(0.5, -1.5, 1, -25), Color = Color3.new(1,1,1)},
        left = {Size = UDim2.new(0, 25, 0, 3), Position = UDim2.new(0, 0, 0.5, -1.5), Color = Color3.new(1,1,1)},
        right = {Size = UDim2.new(0, 25, 0, 3), Position = UDim2.new(1, -25, 0.5, -1.5), Color = Color3.new(1,1,1)},
    },
    -- Text params
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

-- Helper to create line
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

-- Helper to create text with outline
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

-- Clear previous GUI if exists
local function clearGui()
    if screenGui then
        screenGui:Destroy()
        screenGui = nil
    end
end

-- Create GUI elements fresh and restore from visualState parameters
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

    -- Create text label with saved params
    textLabel = createTextLabel(screenGui, visualState.text.Text, visualState.text.Position, visualState.text.Color, visualState.text.Font, visualState.text.TextScaled)
end

-- Save current GUI parameters into visualState table
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

-- Restore visual state parameters to GUI elements
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

-- Function to get rainbow color by time
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

-- On character added, recreate GUI and restore state
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

-- Animation loop
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
