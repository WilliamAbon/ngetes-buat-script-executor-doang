-- UI Library Sederhana: Slider + Color Picker
-- Dipakai dengan cara:
-- local UI = LoadLibrary()
-- UI:Slider("Volume", 0, 100, function(v) print(v) end)
-- UI:ColorPicker("Warna", Color3.new(1,0,0), function(c) print(c) end)

local Library = {}
Library.Signals = {}

-- buat window
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 300)
Main.Position = UDim2.new(0, 40, 0, 40)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Parent = ScreenGui

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 6)
List.Parent = Main

-- fungsi slider
function Library:Slider(title, min, max, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 60)
    holder.BackgroundColor3 = Color3.fromRGB(40,40,40)
    holder.Parent = Main

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 0, 20)
    text.Position = UDim2.new(0, 5, 0, 5)
    text.BackgroundTransparency = 1
    text.Text = title
    text.TextColor3 = Color3.new(1,1,1)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 16
    text.Parent = holder

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -10, 0, 8)
    bar.Position = UDim2.new(0, 5, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(70,70,70)
    bar.Parent = holder

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.Parent = bar

    local dragging = false

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("RunService").Heartbeat:Connect(function()
        if dragging then
            local m = game:GetService("UserInputService").GetMouseLocation(game:GetService("UserInputService"))
            local rel = m.X - bar.AbsolutePosition.X
            local pct = math.clamp(rel / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            local value = math.floor(min + (max - min) * pct)
            callback(value)
        end
    end)
end

-- fungsi colorpicker sederhana
function Library:ColorPicker(title, defaultColor, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 200)
    holder.BackgroundColor3 = Color3.fromRGB(40,40,40)
    holder.Parent = Main

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 0, 20)
    text.Position = UDim2.new(0, 5, 0, 5)
    text.BackgroundTransparency = 1
    text.Text = title
    text.TextColor3 = Color3.new(1,1,1)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 16
    text.Parent = holder

    -- HSV storage
    local h, s, v = Color3.toHSV(defaultColor)

    -- preview box
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 40, 0, 20)
    preview.Position = UDim2.new(1, -45, 0, 5)
    preview.BackgroundColor3 = defaultColor
    preview.Parent = holder

    -- SV Square
    local SV = Instance.new("Frame")
    SV.Size = UDim2.new(0.75, -10, 1, -40)
    SV.Position = UDim2.new(0, 5, 0, 30)
    SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    SV.ClipsDescendants = true
    SV.Parent = holder

    local gradientS = Instance.new("UIGradient")
    gradientS.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(h,1,1))
    }
    gradientS.Parent = SV

    local gradientV = Instance.new("UIGradient")
    gradientV.Rotation = 90
    gradientV.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
    }
    gradientV.Parent = SV

    local SVdot = Instance.new("Frame")
    SVdot.Size = UDim2.new(0, 10, 0, 10)
    SVdot.BackgroundColor3 = Color3.new(1,1,1)
    SVdot.AnchorPoint = Vector2.new(0.5,0.5)
    SVdot.Position = UDim2.new(s,0, 1-v,0)
    SVdot.Parent = SV

    -- Hue bar
    local Hbar = Instance.new("Frame")
    Hbar.Size = UDim2.new(0.2, -10, 1, -40)
    Hbar.Position = UDim2.new(0.8, 0, 0, 30)
    Hbar.Parent = holder

    local hueGrad = Instance.new("UIGradient")
    hueGrad.Rotation = 90
    hueGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Color3.fromHSV(0,1,1)),
        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
        ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50,1,1)),
        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
        ColorSequenceKeypoint.new(1.0, Color3.fromHSV(1,1,1))
    }
    hueGrad.Parent = Hbar

    local Hdot = Instance.new("Frame")
    Hdot.Size = UDim2.new(1,0, 0, 6)
    Hdot.AnchorPoint = Vector2.new(0,0.5)
    Hdot.Position = UDim2.new(0,0, h,0)
    Hdot.BackgroundColor3 = Color3.new(1,1,1)
    Hdot.Parent = Hbar

    local UIS = game:GetService("UserInputService")
    local draggingSV = false
    local draggingH = false

    local function update()
        local col = Color3.fromHSV(h, s, v)
        preview.BackgroundColor3 = col
        SV.BackgroundColor3 = Color3.fromHSV(h,1,1)
        callback(col)
    end

    SV.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end
    end)
    Hbar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingH = true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false draggingH = false end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if draggingSV then
            local m = UIS:GetMouseLocation()
            local relX = (m.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X
            local relY = (m.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y
            s = math.clamp(relX, 0, 1)
            v = 1 - math.clamp(relY, 0, 1)
            SVdot.Position = UDim2.new(s,0, 1-v,0)
            update()
        end
        if draggingH then
            local m = UIS:GetMouseLocation()
            local relY = (m.Y - Hbar.AbsolutePosition.Y) / Hbar.AbsoluteSize.Y
            h = math.clamp(relY, 0, 1)
            Hdot.Position = UDim2.new(0,0, h,0)
            update()
        end
    end)
end

return Library
