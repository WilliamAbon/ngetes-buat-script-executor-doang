-- SimpleExecutorUILibrary.lua
-- Single-file UI lib for executors. Lightweight and practical.
-- Usage: local Library = loadstring(readfile("SimpleExecutorUILibrary.lua"))() OR paste direct into executor.

local Library = {}
Library.__index = Library

-- ---------- Helpers: environment detection ----------
local function safeGet(func)
    local ok, res = pcall(func)
    if ok then return res end
    return nil
end

local function GetGUIParent()
    -- Prefer gethui/get_hidden_gui for executor-safe parenting, fallback to CoreGui
    if safeGet(function() return gethui end) then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    if safeGet(function() return get_hidden_gui end) then
        local ok, h = pcall(get_hidden_gui)
        if ok and h then return h end
    end
    local CoreGui = game:GetService("CoreGui")
    return CoreGui
end

local function GetCustomAsset(path)
    -- tries common executor functions, fallback empty string
    if type(getcustomasset) == "function" then
        local ok, r = pcall(getcustomasset, path)
        if ok and r then return r end
    end
    if type(getsynasset) == "function" then
        local ok, r = pcall(getsynasset, path)
        if ok and r then return r end
    end
    if type(waxgetcustomasset) == "function" then
        local ok, r = pcall(waxgetcustomasset, path)
        if ok and r then return r end
    end
    return ""
end

local UIParent = GetGUIParent()

-- ---------- Utility functions ----------
local function Make(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            inst[k] = v
        end
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function Draggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local uis = game:GetService("UserInputService")
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            -- needed to receive delta
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

-- ---------- Create Window ----------
function Library:CreateWindow(title)
    local selfwin = {}
    selfwin.tabs = {}
    selfwin.instance = Make("ScreenGui", {Name = title .. "_UI"}, UIParent)
    -- protect gui with syn if available
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, selfwin.instance)
    end

    local main = Make("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Color3.fromRGB(25,25,25),
        BorderSizePixel = 0
    }, selfwin.instance)

    Make("UICorner", {CornerRadius = UDim.new(0,8)}, main)
    local titleBar = Make("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1,0,0,36),
        BackgroundTransparency = 1,
        Parent = main
    })
    local titleLabel = Make("TextLabel", {
        Text = title or "UI",
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(235,235,235),
        Font = Enum.Font.SourceSansSemibold,
        TextSize = 18,
        Parent = titleBar
    })

    local closeBtn = Make("TextButton", {
        Text = "X",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0, 4),
        BackgroundColor3 = Color3.fromRGB(180,60,60),
        BorderSizePixel = 0,
        Parent = titleBar
    })
    Make("UICorner", {CornerRadius = UDim.new(0,6)}, closeBtn)

    closeBtn.MouseButton1Click:Connect(function()
        pcall(function() selfwin.instance:Destroy() end)
    end)

    Draggable(main, titleBar)

    -- Tab bar
    local tabBar = Make("Frame", {
        Name = "TabBar",
        Size = UDim2.new(0, 140, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(35,35,35),
        Parent = main
    })
    Make("UICorner", {CornerRadius = UDim.new(0,6)}, tabBar)

    local contentHolder = Make("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -140, 1, -36),
        Position = UDim2.new(0, 140, 0, 36),
        BackgroundColor3 = Color3.fromRGB(20,20,20),
        Parent = main
    })
    Make("UICorner", {CornerRadius = UDim.new(0,6)}, contentHolder)

    -- scrollbar container inside content
    local uiListLayout = Make("UIListLayout", {Padding = UDim.new(0,8)}, contentHolder)
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0,8)

    function selfwin:Tab(name)
        -- create tab button
        local btn = Make("TextButton", {
            Text = name,
            Size = UDim2.new(1, -12, 0, 36),
            Position = UDim2.new(0, 6, 0, 6 + ( #selfwin.tabs * 44 )),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(220,220,220),
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            Parent = tabBar
        })
        local tabContent = Make("Frame", {
            Name = name .. "_Content",
            Size = UDim2.new(1, -24, 1, -24),
            Position = UDim2.new(0, 12, 0, 12),
            BackgroundTransparency = 1,
            Parent = contentHolder,
            Visible = (#selfwin.tabs == 0) -- first tab visible
        })

        -- layout inside tab
        local list = Make("UIListLayout", {Padding = UDim.new(0,8)}, tabContent)
        list.SortOrder = Enum.SortOrder.LayoutOrder

        local function setVisibleOnly()
            for _, t in pairs(selfwin.tabs) do
                if t.content then t.content.Visible = false end
            end
            tabContent.Visible = true
        end

        btn.MouseButton1Click:Connect(function()
            setVisibleOnly()
        end)

        local tabObj = {
            name = name,
            button = btn,
            content = tabContent
        }

        -- component builders
        function tabObj:Button(text, callback)
            local f = Make("Frame", {Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1, Parent = tabContent})
            local b = Make("TextButton", {
                Text = text,
                Size = UDim2.new(1,0,1,0),
                BackgroundColor3 = Color3.fromRGB(60,60,60),
                TextColor3 = Color3.fromRGB(240,240,240),
                BorderSizePixel = 0,
                Parent = f
            })
            Make("UICorner", {CornerRadius = UDim.new(0,6)}, b)
            b.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            return b
        end

        function tabObj:Toggle(text, default, callback)
            local f = Make("Frame", {Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1, Parent = tabContent})
            local label = Make("TextLabel", {Text = text, Size = UDim2.new(0.7,0,1,0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(235,235,235), Parent = f})
            local btn = Make("TextButton", {Text = "", Size = UDim2.new(0, 36, 0, 24), Position = UDim2.new(1, -44, 0.5, -12), BackgroundColor3 = Color3.fromRGB(70,70,70), BorderSizePixel = 0, Parent = f})
            Make("UICorner", {CornerRadius = UDim.new(0,6)}, btn)
            local state = default and true or false
            local function update()
                if state then
                    btn.Text = "ON"
                    btn.BackgroundColor3 = Color3.fromRGB(80,150,80)
                else
                    btn.Text = "OFF"
                    btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
                end
            end
            update()
            btn.MouseButton1Click:Connect(function()
                state = not state
                update()
                pcall(callback, state)
            end)
            return {get = function() return state end, set = function(v) state = v; update() end}
        end

        function tabObj:Slider(text, min, max, default, callback)
            local f = Make("Frame", {Size = UDim2.new(1, -20, 0, 48), BackgroundTransparency = 1, Parent = tabContent})
            local label = Make("TextLabel", {Text = text .. " (" .. tostring(default) .. ")", Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(235,235,235), Parent = f})
            local barBg = Make("Frame", {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,0,24), BackgroundColor3 = Color3.fromRGB(60,60,60), Parent = f})
            Make("UICorner", {CornerRadius = UDim.new(0,6)}, barBg)
            local fill = Make("Frame", {Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = Color3.fromRGB(120,120,220), Parent = barBg})
            Make("UICorner", {CornerRadius = UDim.new(0,6)}, fill)

            local dragging = false
            local uis = game:GetService("UserInputService")
            barBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            uis.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            uis.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((inp.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(rel,0,1,0)
                    local val = math.floor(min + rel * (max-min))
                    label.Text = text .. " (" .. tostring(val) .. ")"
                    pcall(callback, val)
                end
            end)
            return {
                get = function()
                    local rel = fill.Size.X.Scale
                    return math.floor(min + rel * (max-min))
                end,
                set = function(v)
                    local rel = (v - min) / (max-min)
                    fill.Size = UDim2.new(math.clamp(rel,0,1),0,1,0)
                end
            }
        end

        function tabObj:Textbox(placeholder, callback)
            local f = Make("Frame", {Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1, Parent = tabContent})
            local box = Make("TextBox", {
                Text = "",
                PlaceholderText = placeholder or "",
                Size = UDim2.new(1,0,1,0),
                BackgroundColor3 = Color3.fromRGB(55,55,55),
                TextColor3 = Color3.fromRGB(235,235,235),
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                Parent = f
            })
            Make("UICorner", {CornerRadius = UDim.new(0,6)}, box)
            box.FocusLost:Connect(function(enter)
                pcall(callback, box.Text)
            end)
            return box
        end

        function tabObj:Dropdown(text, options, defaultIndex, callback)
            local f = Make("Frame", {Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1, Parent = tabContent})
            local label = Make("TextLabel", {Text = text, Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(235,235,235), Parent = f})
            local btn = Make("TextButton", {Text = tostring(options[defaultIndex] or options[1]), Size = UDim2.new(0.4, -6, 1, 0), Position = UDim2.new(0.6, 6, 0, 0), BackgroundColor3 = Color3.fromRGB(70,70,70), BorderSizePixel = 0, Parent = f})
            Make("UICorner", {CornerRadius = UDim.new(0,6)}, btn)
            local dropdownFrame = Make("Frame", {Size = UDim2.new(0,200,0,#options*28), Position = UDim2.new(0,0,1,6), BackgroundColor3 = Color3.fromRGB(50,50,50), Visible = false, Parent = f})
            Make("UICorner", {CornerRadius = UDim.new(0,6)}, dropdownFrame)
            for i,opt in ipairs(options) do
                local optBtn = Make("TextButton", {Text = tostring(opt), Size = UDim2.new(1,0,0,28), Position = UDim2.new(0,0,0,(i-1)*28), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(230,230,230), Parent = dropdownFrame})
                optBtn.MouseButton1Click:Connect(function()
                    btn.Text = tostring(opt)
                    dropdownFrame.Visible = false
                    pcall(callback, opt, i)
                end)
            end
            btn.MouseButton1Click:Connect(function()
                dropdownFrame.Visible = not dropdownFrame.Visible
            end)
            return {
                get = function() return btn.Text end,
                set = function(val) btn.Text = tostring(val) end
            }
        end

        function tabObj:Bind(text, defaultKey, callback)
            local f = Make("Frame", {Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1, Parent = tabContent})
            local label = Make("TextLabel", {Text = text, Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(235,235,235), Parent = f})
            local btn = Make("TextButton", {Text = defaultKey or "None", Size = UDim2.new(0.4, -6, 1, 0), Position = UDim2.new(0.6, 6, 0, 0), BackgroundColor3 = Color3.fromRGB(70,70,70), BorderSizePixel = 0, Parent = f})
            Make("UICorner", {CornerRadius = UDim.new(0,6)}, btn)
            local binding = defaultKey
            local uis = game:GetService("UserInputService")
            btn.MouseButton1Click:Connect(function()
                btn.Text = "Press key..."
                local conn
                conn = uis.InputBegan:Connect(function(inp, gpe)
                    if not gpe and inp.KeyCode then
                        binding = inp.KeyCode.Name
                        btn.Text = binding
                        pcall(callback, binding)
                        conn:Disconnect()
                    end
                end)
            end)
            return {
                get = function() return binding end,
                set = function(k) binding = k; btn.Text = k end
            }
        end

        table.insert(selfwin.tabs, tabObj)
        return tabObj
    end

    return selfwin
end

return setmetatable(Library, Library)
