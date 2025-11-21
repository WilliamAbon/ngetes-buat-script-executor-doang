local Library = {}

Library.Screen = Instance.new("ScreenGui")
Library.Screen.Name = "KONTOL SCREEN"
Library.Screen.Parent = game.CoreGui

Library.Container = Instance.new("Frame")
Library.Container.Size = UDim2.new(0, 200, 0, 300)
Library.Container.Parent = Library.Screen

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 5)
list.Parent = Library.Container

function Library:CreateButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = name
    btn.Parent = self.Container
    return btn
end

return Library
