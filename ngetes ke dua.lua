-- UI Library Sederhana: Slider + Color Picker
-- Dipakai dengan cara:
-- local UI = LoadLibrary()
-- UI:Slider("Volume", 0, 100, function(v) print(v) end)
-- UI:ColorPicker("Warna", Color3.new(1,0,0), function(c) print(c) end)

local Library = {}
Library.Signals = {}

-- buat window
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ewek2_Kontol"
ScreenGui.Parent = game.CoreGui

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
function Library:ColorPicker(title, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 45)
    holder.BackgroundColor3 = Color3.fromRGB(40,40,40)
    holder.Parent = Main

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.6, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = title
    text.TextColor3 = Color3.new(1,1,1)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 16
    text.Parent = holder

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0.3, 0, 0.7, 0)
    box.Position = UDim2.new(0.65, 0, 0.15, 0)
    box.BackgroundColor3 = default
    box.Text = ""
    box.Parent = holder

    box.MouseButton1Click:Connect(function()
        local color = Color3.fromHSV(math.random(), 1, 1)
        box.BackgroundColor3 = color
        callback(color)
    end)
end

return Library
