-- StyledExecutorUI.lua
-- Versi styled GUI library — tema modern flat, sidebar tab, smooth rounding.

local Library = {}
Library.__index = Library

-- Helpers
local function safeGet(f) local ok,res = pcall(f) if ok then return res end return nil end

local function GetGUIParent()
    if safeGet(function() return gethui end) then
        local ok,h = pcall(gethui) if ok and h then return h end
    end
    if safeGet(function() return get_hidden_gui end) then
        local ok,h = pcall(get_hidden_gui) if ok and h then return h end
    end
    return game:GetService("CoreGui")
end

local function GetCustomAsset(path)
    if type(getcustomasset) == "function" then
        local ok,r = pcall(getcustomasset, path) if ok and r then return r end
    end
    if type(getsynasset) == "function" then
        local ok,r = pcall(getsynasset, path) if ok and r then return r end
    end
    return ""
end

local UIParent = GetGUIParent()

local function Make(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k,v in pairs(props) do inst[k] = v end
    end
    if parent then inst.Parent = parent end
    return inst
end

local function Draggable(frame, handle)
    handle = handle or frame
    local uis = game:GetService("UserInputService")
    local dragging = false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    uis.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Theme variables (ubah sesuai keinginan)
local Colors = {
    Background = Color3.fromRGB(30,30,30),
    Sidebar = Color3.fromRGB(40,40,40),
    TabButton = Color3.fromRGB(55,55,55),
    TabButtonHover = Color3.fromRGB(70,70,70),
    Primary = Color3.fromRGB(85,170,255),
    Text = Color3.fromRGB(235,235,235),
    Accent = Color3.fromRGB(100,200,255)
}

-- Create Window
function Library:CreateWindow(title)
    local selfwin = {}
    selfwin.tabs = {}
    selfwin.instance = Make("ScreenGui", {Name = title .. "_UI"}, UIParent)
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, selfwin.instance)
    end

    local main = Make("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    }, selfwin.instance)
    Make("UICorner", {CornerRadius = UDim.new(0,12)}, main)

    local titleBar = Make("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1,0,0,36),
        BackgroundTransparency = 1,
        Parent = main
    })
    local titleLabel = Make("TextLabel", {
        Text = title or "UI Window",
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Parent = titleBar
    })

    local closeBtn = Make("TextButton", {
        Text = "✕",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0, 4),
        BackgroundColor3 = Colors.TabButton,
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        BorderSizePixel = 0,
        Parent = titleBar
    })
    Make("UICorner", {CornerRadius = UDim.new(0,6)}, closeBtn)
    closeBtn.MouseButton1Click:Connect(function()
        pcall(function() selfwin.instance:Destroy() end)
    end)

    Draggable(main, titleBar)

    -- Sidebar for tabs
    local sidebar = Make("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 140, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Colors.Sidebar,
        Parent = main
    })
    Make("UICorner", {CornerRadius = UDim.new(0,12)}, sidebar)

    local contentHolder = Make("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -140, 1, -36),
        Position = UDim2.new(0, 140, 0, 36),
        BackgroundColor3 = Colors.Background,
        Parent = main
    })
    Make("UICorner", {CornerRadius = UDim.new(0,12)}, contentHolder)

    function selfwin:Tab(name)
        -- tab button in sidebar
        local idx = #selfwin.tabs + 1
        local btn = Make("TextButton", {
            Text = name,
            Size = UDim2.new(1, -12, 0, 40),
            Position = UDim2.new(0, 6, 0, 6 + (idx-1)*46),
            BackgroundColor3 = Colors.TabButton,
            TextColor3 = Colors.Text,
            Font = Enum.Font.Gotham,
            TextSize = 16,
            BorderSizePixel = 0,
            Parent = sidebar
        })
        Make("UICorner", {CornerRadius = UDim.new(0,8)}, btn)

        local content = Make("Frame", {
            Name = name .. "_Content",
            Size = UDim2.new(1, -24, 1, -24),
            Position = UDim2.new(0, 12, 0, 12),
            BackgroundTransparency = 1,
            Visible = (idx == 1),
            Parent = contentHolder
        })
        local layout = Make("UIListLayout", {Padding = UDim.new(0,12)}, content)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local function deactivateAll()
            for _, t in ipairs(selfwin.tabs) do
                t.btn.BackgroundColor3 = Colors.TabButton
                t.content.Visible = false
            end
        end

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Colors.TabButtonHover
        end)
        btn.MouseLeave:Connect(function()
            if btn.BackgroundColor3 ~= Colors.Primary then
                btn.BackgroundColor3 = Colors.TabButton
            end
        end)

        btn.MouseButton1Click:Connect(function()
            deactivateAll()
            btn.BackgroundColor3 = Colors.Primary
            content.Visible = true
        end)

        local tabObj = {
            name = name,
            btn = btn,
            content = content
        }

        -- component builders
        function tabObj:Button(text, callback)
            local f = Make("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Parent = content})
            local b = Make("TextButton", {
                Text = text,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Colors.TabButton,
                TextColor3 = Colors.Text,
                Font = Enum.Font.Gotham,
                TextSize = 16,
                BorderSizePixel = 0,
                Parent = f
            })
            Make("UICorner", {CornerRadius = UDim.new(0,6)}, b)
            b.MouseEnter:Connect(function() b.BackgroundColor3 = Colors.TabButtonHover end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = Colors.TabButton end)
            b.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            return b
        end

        function tabObj:Toggle(text, default, callback)
            local f = Make("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Parent = content})
            local label = Make("TextLabel", {
                Text = text,
                Size = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Colors.Text,
                Font = Enum.Font.Gotham,
                TextSize = 16,
                Parent = f
            })
            local btn = Make("TextButton", {
                Text = default and "ON" or "OFF",
                Size = UDim2.new(0, 50, 0, 24),
                Position = UDim2.new(1, -60, 0.5, -12),
                BackgroundColor3 = default and Colors.Primary or Colors.TabButton,
                TextColor3 = Colors.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                BorderSizePixel = 0,
                Parent = f
            })
            Make("UICorner", {CornerRadius = UDim.new(0,6)}, btn)
            local state = default and true or false
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = state and "ON" or "OFF"
                btn.BackgroundColor3 = state and Colors.Primary or Colors.TabButton
                pcall(callback, state)
            end)
            return {get = function() return state end, set = function(v) state = v; btn.Text = v and "ON" or "OFF"; btn.BackgroundColor3 = v and Colors.Primary or Colors.TabButton end}
        end

        -- Other components: Slider, Textbox, Dropdown, Bind — bisa ditambahkan seperti library awal
        -- Untuk singkat, kita hanya implement Button dan Toggle di versi ini. Kamu bisa minta tambahan nanti.

        table.insert(selfwin.tabs, tabObj)
        return tabObj
    end

    return selfwin
end

return setmetatable(Library, Library)
