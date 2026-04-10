--[[
    PickHub ImGui - Custom ImGui-Style UI Library for Roblox
    Styled after Dear ImGui with dark theme, accent colors, and clean layout.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.__index = Library
Library._AccentObjects = {}
Library._Flags = {}

local Theme = {
    WindowBg        = Color3.fromRGB(15, 15, 15),
    TitleBg         = Color3.fromRGB(10, 10, 10),
    TitleBgActive   = Color3.fromRGB(20, 20, 20),
    ChildBg         = Color3.fromRGB(22, 22, 22),
    Border          = Color3.fromRGB(45, 45, 45),
    FrameBg         = Color3.fromRGB(30, 30, 30),
    FrameBgHover    = Color3.fromRGB(40, 40, 40),
    FrameBgActive   = Color3.fromRGB(50, 50, 50),
    CheckMark       = Color3.fromRGB(255, 50, 50),
    SliderGrab      = Color3.fromRGB(255, 50, 50),
    SliderGrabActive= Color3.fromRGB(255, 80, 80),
    Button          = Color3.fromRGB(35, 35, 35),
    ButtonHover     = Color3.fromRGB(45, 45, 45),
    ButtonActive    = Color3.fromRGB(55, 55, 55),
    Tab             = Color3.fromRGB(25, 25, 25),
    TabActive       = Color3.fromRGB(35, 35, 35),
    TabHover        = Color3.fromRGB(45, 45, 45),
    Accent          = Color3.fromRGB(255, 50, 50),
    Text            = Color3.fromRGB(220, 220, 220),
    TextDark        = Color3.fromRGB(128, 128, 128),
    Separator       = Color3.fromRGB(40, 40, 40),
    ScrollBar       = Color3.fromRGB(50, 50, 50),
    ScrollBarGrab   = Color3.fromRGB(80, 80, 80),
    Font            = Enum.Font.Code,
    TextSize        = 13,
    Padding         = 8,
    ItemSpacing     = 4,
    CornerRadius    = 3,
}

Library.Theme = Theme

function Library:_TrackAccent(obj, prop)
    table.insert(Library._AccentObjects, {Object = obj, Property = prop})
end

function Library:SetAccent(color)
    Theme.Accent = color
    Theme.CheckMark = color
    Theme.SliderGrab = color
    for _, item in ipairs(Library._AccentObjects) do
        pcall(function()
            if type(item.Property) == "function" then
                item.Property(color)
            elseif item.Object and item.Object.Parent then
                item.Object[item.Property] = color
            end
        end)
    end
end

local function tween(obj, props, duration)
    local ti = TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, ti, props):Play()
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or Theme.CornerRadius)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function padding(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

local function listLayout(parent, pad, dir)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, pad or Theme.ItemSpacing)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Parent = parent
    return l
end

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "ImGui Window"
    local size = config.Size or UDim2.new(0, 550, 0, 400)
    local pos = config.Position or UDim2.new(0.5, -275, 0.5, -200)

    local parentGui = config.Parent
    if not parentGui then
        local player = Players.LocalPlayer
        parentGui = (typeof(gethui) == "function" and gethui()) or CoreGui or (player and player:WaitForChild("PlayerGui"))
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PickImGui"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = parentGui

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if isMobile then
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local scaleRatio = math.clamp(viewportSize.X / 600, 0.55, 1)
        local uiScale = Instance.new("UIScale")
        uiScale.Scale = scaleRatio
        uiScale.Parent = ScreenGui
        size = UDim2.new(0, math.min(size.X.Offset, viewportSize.X / scaleRatio - 20), 0, math.min(size.Y.Offset, viewportSize.Y / scaleRatio - 60))
        pos = UDim2.new(0.5, -size.X.Offset / 2, 0, 30)
    end

    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Size = size
    Window.Position = pos
    Window.BackgroundColor3 = Theme.WindowBg
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent = ScreenGui
    corner(Window, 4)
    stroke(Window, Theme.Border, 1)

    local AccentLine = Instance.new("Frame")
    AccentLine.Name = "Accent"
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Window
    Library:_TrackAccent(AccentLine, "BackgroundColor3")

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 28)
    TitleBar.Position = UDim2.new(0, 0, 0, 2)
    TitleBar.BackgroundColor3 = Theme.TitleBg
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Window

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = title
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Theme.Font
    TitleLabel.TextSize = Theme.TextSize
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = "-"
    MinBtn.Size = UDim2.new(0, 22, 0, 22)
    MinBtn.Position = UDim2.new(1, -52, 0, 3)
    MinBtn.BackgroundColor3 = Theme.Button
    MinBtn.TextColor3 = Theme.Text
    MinBtn.Font = Theme.Font
    MinBtn.TextSize = 16
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TitleBar
    corner(MinBtn, 3)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "x"
    CloseBtn.Size = UDim2.new(0, 22, 0, 22)
    CloseBtn.Position = UDim2.new(1, -27, 0, 3)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.Font = Theme.Font
    CloseBtn.TextSize = 14
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TitleBar
    corner(CloseBtn, 3)

    makeDraggable(Window, TitleBar)

    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0, 120, 1, -30)
    TabBar.Position = UDim2.new(0, 0, 0, 30)
    TabBar.BackgroundColor3 = Theme.TitleBg
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Window

    local TabBarPad = padding(TabBar, 6, 6, 6, 6)
    local TabBarLayout = listLayout(TabBar, 2)

    local TabSep = Instance.new("Frame")
    TabSep.Size = UDim2.new(0, 1, 1, -30)
    TabSep.Position = UDim2.new(0, 120, 0, 30)
    TabSep.BackgroundColor3 = Theme.Border
    TabSep.BorderSizePixel = 0
    TabSep.Parent = Window

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "Content"
    ContentArea.Size = UDim2.new(1, -121, 1, -30)
    ContentArea.Position = UDim2.new(0, 121, 0, 30)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = Window

    local windowObj = {
        Gui = ScreenGui,
        Frame = Window,
        TabBar = TabBar,
        ContentArea = ContentArea,
        Tabs = {},
        ActiveTab = nil,
        Visible = true,
        Minimized = false,
        OriginalSize = size,
    }

    windowObj._ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == windowObj._ToggleKey then
            windowObj.Visible = not windowObj.Visible
            ScreenGui.Enabled = windowObj.Visible
        end
    end)

    MinBtn.MouseButton1Click:Connect(function()
        windowObj.Minimized = not windowObj.Minimized
        if windowObj.Minimized then
            tween(Window, {Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 30)}, 0.2)
            MinBtn.Text = "+"
        else
            tween(Window, {Size = windowObj.OriginalSize}, 0.2)
            MinBtn.Text = "-"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    for _, btn in ipairs({MinBtn, CloseBtn}) do
        local origColor = btn.BackgroundColor3
        btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Theme.ButtonHover}, 0.1) end)
        btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = origColor}, 0.1) end)
    end

    setmetatable(windowObj, {__index = Library})
    return windowObj
end

function Library:AddTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name
    tabBtn.Text = name
    tabBtn.Size = UDim2.new(1, 0, 0, 26)
    tabBtn.BackgroundColor3 = Theme.Tab
    tabBtn.TextColor3 = Theme.TextDark
    tabBtn.Font = Theme.Font
    tabBtn.TextSize = Theme.TextSize
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = self.TabBar
    corner(tabBtn, 3)
    padding(tabBtn, 0, 0, 8, 0)

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 3
    tabContent.ScrollBarImageColor3 = Theme.ScrollBarGrab
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.BorderSizePixel = 0
    tabContent.Visible = false
    tabContent.Parent = self.ContentArea

    padding(tabContent, 8, 8, 8, 8)
    listLayout(tabContent, 6)

    local tabObj = {
        Button = tabBtn,
        Content = tabContent,
        Name = name,
        Window = self,
    }

    table.insert(self.Tabs, tabObj)

    local function selectTab()
        for _, t in ipairs(self.Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = Theme.Tab
            t.Button.TextColor3 = Theme.TextDark
        end
        tabContent.Visible = true
        tabBtn.BackgroundColor3 = Theme.TabActive
        tabBtn.TextColor3 = Theme.Text
        self.ActiveTab = tabObj
    end

    tabBtn.MouseButton1Click:Connect(selectTab)
    tabBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tabObj then
            tween(tabBtn, {BackgroundColor3 = Theme.TabHover}, 0.1)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tabObj then
            tween(tabBtn, {BackgroundColor3 = Theme.Tab}, 0.1)
        end
    end)

    if #self.Tabs == 1 then selectTab() end

    setmetatable(tabObj, {__index = Library})
    tabObj._Container = tabContent
    return tabObj
end

function Library:AddSection(name)
    local container = self._Container

    local section = Instance.new("Frame")
    section.Name = name or "Section"
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Theme.ChildBg
    section.BorderSizePixel = 0
    section.Parent = container
    corner(section, 4)
    stroke(section, Theme.Border, 1)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = name or ""
    titleLabel.Size = UDim2.new(1, 0, 0, 22)
    titleLabel.BackgroundColor3 = Theme.TitleBg
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Theme.Font
    titleLabel.TextSize = Theme.TextSize
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BorderSizePixel = 0
    titleLabel.Parent = section
    padding(titleLabel, 0, 0, 8, 0)

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 4)
    titleCorner.Parent = titleLabel

    local inner = Instance.new("Frame")
    inner.Name = "Inner"
    inner.Size = UDim2.new(1, 0, 0, 0)
    inner.Position = UDim2.new(0, 0, 0, 24)
    inner.AutomaticSize = Enum.AutomaticSize.Y
    inner.BackgroundTransparency = 1
    inner.Parent = section

    padding(inner, 4, 6, 8, 8)
    listLayout(inner, 5)

    local sectionObj = setmetatable({_Container = inner, Window = self.Window or self}, {__index = Library})
    return sectionObj
end

function Library:AddLabel(text)
    local label = Instance.new("TextLabel")
    label.Text = text or ""
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.TextDark
    label.Font = Theme.Font
    label.TextSize = Theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = self._Container

    return {Instance = label, Set = function(_, newText) label.Text = newText end}
end

function Library:AddSeparator()
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3 = Theme.Separator
    sep.BorderSizePixel = 0
    sep.Parent = self._Container
end

function Library:AddButton(config)
    config = config or {}
    local btn = Instance.new("TextButton")
    btn.Text = config.Text or "Button"
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = Theme.Button
    btn.TextColor3 = Theme.Text
    btn.Font = Theme.Font
    btn.TextSize = Theme.TextSize
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = self._Container
    corner(btn, 3)
    stroke(btn, Theme.Border, 1)

    btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Theme.ButtonHover}, 0.1) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Theme.Button}, 0.1) end)
    btn.MouseButton1Down:Connect(function() btn.BackgroundColor3 = Theme.ButtonActive end)
    btn.MouseButton1Up:Connect(function() btn.BackgroundColor3 = Theme.ButtonHover end)

    if config.Callback then
        btn.MouseButton1Click:Connect(config.Callback)
    end

    return {Instance = btn}
end

function Library:AddToggle(config)
    config = config or {}
    local state = config.Default or false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.Parent = self._Container

    local label = Instance.new("TextLabel")
    label.Text = config.Text or "Toggle"
    label.Size = UDim2.new(1, -40, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = Theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(1, -20, 0.5, -8)
    box.BackgroundColor3 = state and Theme.Accent or Theme.FrameBg
    box.BorderSizePixel = 0
    box.Parent = frame
    corner(box, 3)
    stroke(box, Theme.Border, 1)

    local checkmark = Instance.new("TextLabel")
    checkmark.Text = "âœ“"
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.TextColor3 = Color3.new(1, 1, 1)
    checkmark.Font = Enum.Font.GothamBold
    checkmark.TextSize = 11
    checkmark.Visible = state
    checkmark.Parent = box

    local clickBtn = Instance.new("TextButton")
    clickBtn.Text = ""
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Parent = frame

    local function updateVisual()
        tween(box, {BackgroundColor3 = state and Theme.Accent or Theme.FrameBg}, 0.15)
        checkmark.Visible = state
    end

    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if config.Callback then config.Callback(state) end
    end)

    Library:_TrackAccent(nil, function(color)
        if state then box.BackgroundColor3 = color end
    end)

    local toggleObj = {
        Instance = frame,
        Set = function(_, val)
            state = val
            updateVisual()
            if config.Callback then config.Callback(state) end
        end,
        Get = function() return state end,
    }
    if config.Flag then Library._Flags[config.Flag] = toggleObj end
    return toggleObj
end

function Library:AddSlider(config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local value = default
    local suffix = config.Suffix or ""
    local decimals = config.Decimals
    local precise = decimals ~= nil or config.Precise or false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundTransparency = 1
    frame.Parent = self._Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = Theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(1, 0, 0, 16)
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = Theme.TextDark
    valLabel.Font = Theme.Font
    valLabel.TextSize = Theme.TextSize
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 24)
    track.BackgroundColor3 = Theme.FrameBg
    track.BorderSizePixel = 0
    track.Parent = frame
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 3)
    Library:_TrackAccent(fill, "BackgroundColor3")

    local function updateDisplay()
        local display
        if decimals then
            local places = math.max(0, math.ceil(-math.log10(decimals)))
            display = string.format("%%.%df", places):format(value)
        elseif precise then
            display = string.format("%.1f", value)
        else
            display = tostring(math.floor(value))
        end
        label.Text = (config.Text or "Slider")
        valLabel.Text = display .. suffix
        local pct = math.clamp((value - min) / (max - min), 0, 1)
        tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
    end
    updateDisplay()

    local sliding = false
    local clickBtn = Instance.new("TextButton")
    clickBtn.Text = ""
    clickBtn.Size = UDim2.new(1, 0, 0, 14)
    clickBtn.Position = UDim2.new(0, 0, 0, 20)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Parent = frame

    clickBtn.MouseButton1Down:Connect(function() sliding = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)

    RunService.RenderStepped:Connect(function()
        if sliding then
            local mouse = UserInputService:GetMouseLocation()
            local absPos = track.AbsolutePosition
            local absSize = track.AbsoluteSize
            local pct = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
            value = min + (max - min) * pct
            if decimals then
                value = math.floor(value / decimals + 0.5) * decimals
            elseif not precise then
                value = math.floor(value)
            end
            updateDisplay()
            if config.Callback then config.Callback(value) end
        end
    end)

    local sliderObj = {
        Instance = frame,
        Set = function(_, val)
            value = math.clamp(val, min, max)
            updateDisplay()
            if config.Callback then config.Callback(value) end
        end,
        Get = function() return value end,
    }
    if config.Flag then Library._Flags[config.Flag] = sliderObj end
    return sliderObj
end

function Library:AddDropdown(config)
    config = config or {}
    local options = config.Options or {}
    local selected = config.Default or (options[1] or "")
    local opened = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = true
    frame.Parent = self._Container

    local innerLayout = listLayout(frame, 2)

    local label = Instance.new("TextLabel")
    label.Text = config.Text or "Dropdown"
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = Theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local header = Instance.new("TextButton")
    header.Text = "  " .. selected .. "  â–¼"
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundColor3 = Theme.FrameBg
    header.TextColor3 = Theme.Text
    header.Font = Theme.Font
    header.TextSize = Theme.TextSize
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.BorderSizePixel = 0
    header.AutoButtonColor = false
    header.Parent = frame
    corner(header, 3)
    stroke(header, Theme.Border, 1)

    local optionContainer = Instance.new("Frame")
    optionContainer.Size = UDim2.new(1, 0, 0, 0)
    optionContainer.AutomaticSize = Enum.AutomaticSize.Y
    optionContainer.BackgroundColor3 = Theme.FrameBg
    optionContainer.BorderSizePixel = 0
    optionContainer.Visible = false
    optionContainer.Parent = frame
    corner(optionContainer, 3)
    stroke(optionContainer, Theme.Border, 1)
    local optLayout = listLayout(optionContainer, 0)

    local function buildOptions()
        for _, c in ipairs(optionContainer:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Text = "  " .. opt
            optBtn.Size = UDim2.new(1, 0, 0, 22)
            optBtn.BackgroundColor3 = opt == selected and Theme.TabActive or Theme.FrameBg
            optBtn.TextColor3 = opt == selected and Theme.Accent or Theme.Text
            optBtn.Font = Theme.Font
            optBtn.TextSize = Theme.TextSize
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.BorderSizePixel = 0
            optBtn.AutoButtonColor = false
            optBtn.Parent = optionContainer

            optBtn.MouseEnter:Connect(function() tween(optBtn, {BackgroundColor3 = Theme.FrameBgHover}, 0.1) end)
            optBtn.MouseLeave:Connect(function()
                tween(optBtn, {BackgroundColor3 = opt == selected and Theme.TabActive or Theme.FrameBg}, 0.1)
            end)

            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                header.Text = "  " .. selected .. "  â–¼"
                opened = false
                optionContainer.Visible = false
                buildOptions()
                if config.Callback then config.Callback(selected) end
            end)
        end
    end
    buildOptions()

    header.MouseButton1Click:Connect(function()
        opened = not opened
        optionContainer.Visible = opened
    end)

    local dropdownObj = {
        Instance = frame,
        Set = function(_, val)
            selected = val
            header.Text = "  " .. selected .. "  â–¼"
            buildOptions()
            if config.Callback then config.Callback(selected) end
        end,
        Get = function() return selected end,
        SetOptions = function(_, newOpts)
            options = newOpts
            buildOptions()
        end,
    }
    if config.Flag then Library._Flags[config.Flag] = dropdownObj end
    return dropdownObj
end

function Library:AddTextbox(config)
    config = config or {}

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = self._Container

    local label = Instance.new("TextLabel")
    label.Text = config.Text or "Input"
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = Theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Text = config.Default or ""
    box.PlaceholderText = config.Placeholder or "Type here..."
    box.Size = UDim2.new(1, 0, 0, 22)
    box.Position = UDim2.new(0, 0, 0, 18)
    box.BackgroundColor3 = Theme.FrameBg
    box.TextColor3 = Theme.Text
    box.PlaceholderColor3 = Theme.TextDark
    box.Font = Theme.Font
    box.TextSize = Theme.TextSize
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Parent = frame
    corner(box, 3)
    stroke(box, Theme.Border, 1)
    padding(box, 0, 0, 6, 6)

    box.Focused:Connect(function() tween(box, {BackgroundColor3 = Theme.FrameBgActive}, 0.1) end)
    box.FocusLost:Connect(function(enter)
        tween(box, {BackgroundColor3 = Theme.FrameBg}, 0.1)
        if config.Callback then config.Callback(box.Text, enter) end
    end)

    local textboxObj = {
        Instance = frame,
        Set = function(_, val) box.Text = val end,
        Get = function() return box.Text end,
    }
    if config.Flag then Library._Flags[config.Flag] = textboxObj end
    return textboxObj
end

function Library:AddKeybind(config)
    config = config or {}
    local currentKey = config.Default or Enum.KeyCode.Unknown
    local listening = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.Parent = self._Container

    local label = Instance.new("TextLabel")
    label.Text = config.Text or "Keybind"
    label.Size = UDim2.new(1, -70, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = Theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name
    btn.Size = UDim2.new(0, 60, 0, 20)
    btn.Position = UDim2.new(1, -62, 0.5, -10)
    btn.BackgroundColor3 = Theme.FrameBg
    btn.TextColor3 = Theme.TextDark
    btn.Font = Theme.Font
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = frame
    corner(btn, 3)
    stroke(btn, Theme.Border, 1)

    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not listening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            btn.Text = currentKey.Name
            listening = false
            if config.Callback then config.Callback(currentKey) end
        end
    end)

    local keybindObj = {
        Instance = frame,
        Get = function() return currentKey end,
        Set = function(_, key)
            currentKey = key
            btn.Text = (currentKey == Enum.KeyCode.Unknown) and "None" or currentKey.Name
        end,
    }
    if config.Flag then Library._Flags[config.Flag] = keybindObj end
    return keybindObj
end

function Library:AddColorPicker(config)
    config = config or {}
    local currentColor = config.Default or Theme.Accent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.Parent = self._Container

    local label = Instance.new("TextLabel")
    label.Text = config.Text or "Color"
    label.Size = UDim2.new(1, -30, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.Font = Theme.Font
    label.TextSize = Theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 18, 0, 18)
    preview.Position = UDim2.new(1, -20, 0.5, -9)
    preview.BackgroundColor3 = currentColor
    preview.BorderSizePixel = 0
    preview.Parent = frame
    corner(preview, 3)
    stroke(preview, Theme.Border, 1)

    local paletteOpen = false
    local palette = Instance.new("Frame")
    palette.Size = UDim2.new(1, 0, 0, 60)
    palette.BackgroundColor3 = Theme.FrameBg
    palette.BorderSizePixel = 0
    palette.Visible = false
    palette.Parent = self._Container
    corner(palette, 3)
    stroke(palette, Theme.Border, 1)
    padding(palette, 4, 4, 4, 4)

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 20, 0, 20)
    grid.CellPadding = UDim2.new(0, 3, 0, 3)
    grid.Parent = palette

    local presetColors = {
        Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 120, 50), Color3.fromRGB(255, 200, 50),
        Color3.fromRGB(50, 255, 50), Color3.fromRGB(50, 200, 255), Color3.fromRGB(100, 100, 255),
        Color3.fromRGB(200, 50, 255), Color3.fromRGB(255, 50, 200), Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(180, 180, 180), Color3.fromRGB(100, 100, 100), Color3.fromRGB(40, 40, 40),
    }

    for _, c in ipairs(presetColors) do
        local swatch = Instance.new("TextButton")
        swatch.Text = ""
        swatch.BackgroundColor3 = c
        swatch.BorderSizePixel = 0
        swatch.Parent = palette
        corner(swatch, 3)

        swatch.MouseButton1Click:Connect(function()
            currentColor = c
            preview.BackgroundColor3 = c
            if config.Callback then config.Callback(c) end
        end)
    end

    local clickBtn = Instance.new("TextButton")
    clickBtn.Text = ""
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Parent = frame

    clickBtn.MouseButton1Click:Connect(function()
        paletteOpen = not paletteOpen
        palette.Visible = paletteOpen
    end)

    local pickerObj = {
        Instance = frame,
        Get = function() return currentColor end,
        Set = function(_, c)
            currentColor = c
            preview.BackgroundColor3 = c
        end,
    }
    if config.Flag then Library._Flags[config.Flag] = pickerObj end
    return pickerObj
end

function Library:CreateWatermark(config)
    config = config or {}
    local mainGui = self.Gui
    if not mainGui then return end

    local wmGui = Instance.new("ScreenGui")
    wmGui.Name = "PickImGui_Watermark"
    wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    wmGui.ResetOnSpawn = false
    wmGui.IgnoreGuiInset = true
    wmGui.Parent = mainGui.Parent
    self._WatermarkGui = wmGui

    local wmFrame = Instance.new("Frame")
    wmFrame.Name = "Watermark"
    wmFrame.Size = UDim2.new(0, 260, 0, 24)
    wmFrame.AnchorPoint = Vector2.new(0.5, 0)
    wmFrame.Position = UDim2.new(0.5, 0, 0, 8)
    wmFrame.BackgroundColor3 = Theme.WindowBg
    wmFrame.BorderSizePixel = 0
    wmFrame.Parent = wmGui
    corner(wmFrame, 4)
    stroke(wmFrame, Theme.Border, 1)

    local wmAccent = Instance.new("Frame")
    wmAccent.Size = UDim2.new(1, 0, 0, 2)
    wmAccent.BackgroundColor3 = Theme.Accent
    wmAccent.BorderSizePixel = 0
    wmAccent.Parent = wmFrame
    Library:_TrackAccent(wmAccent, "BackgroundColor3")

    local wmLabel = Instance.new("TextLabel")
    wmLabel.Name = "WMText"
    wmLabel.Size = UDim2.new(1, 0, 1, -2)
    wmLabel.Position = UDim2.new(0, 0, 0, 2)
    wmLabel.BackgroundTransparency = 1
    wmLabel.TextColor3 = Theme.Text
    wmLabel.Font = Theme.Font
    wmLabel.TextSize = 12
    wmLabel.RichText = true
    wmLabel.Parent = wmFrame

    makeDraggable(wmFrame)

    local lastUpdate = 0
    RunService.RenderStepped:Connect(function(dt)
        local t = tick()
        if t - lastUpdate > 0.5 then
            lastUpdate = t
            local fps = math.floor(1 / dt)
            local timeStr = os.date("%I:%M:%S %p")
            local ping = 0
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local accentHex = string.format("#%02X%02X%02X",
                math.floor(Theme.Accent.R * 255),
                math.floor(Theme.Accent.G * 255),
                math.floor(Theme.Accent.B * 255))
            wmLabel.Text = string.format(
                "<font color='%s'>Pick</font>Hub <font color='#555'>|</font> %s <font color='#555'>|</font> %dfps <font color='#555'>|</font> %dms",
                accentHex, timeStr, fps, ping
            )
        end
    end)

    self._Watermark = wmFrame
    return wmFrame
end

function Library:CreateLogger(config)
    config = config or {}
    local gui = self.Gui
    if not gui then return end

    local logFrame = Instance.new("Frame")
    logFrame.Name = "Logger"
    logFrame.Size = config.Size or UDim2.new(0, 380, 0, 220)
    logFrame.Position = config.Position or UDim2.new(1, -394, 1, -234)
    logFrame.BackgroundColor3 = Theme.WindowBg
    logFrame.BorderSizePixel = 0
    logFrame.ClipsDescendants = true
    logFrame.Parent = gui
    corner(logFrame, 4)
    stroke(logFrame, Theme.Border, 1)

    local logAccent = Instance.new("Frame")
    logAccent.Size = UDim2.new(1, 0, 0, 2)
    logAccent.BackgroundColor3 = Theme.Accent
    logAccent.BorderSizePixel = 0
    logAccent.Parent = logFrame
    Library:_TrackAccent(logAccent, "BackgroundColor3")

    local logTitleBar = Instance.new("Frame")
    logTitleBar.Size = UDim2.new(1, 0, 0, 24)
    logTitleBar.Position = UDim2.new(0, 0, 0, 2)
    logTitleBar.BackgroundColor3 = Theme.TitleBg
    logTitleBar.BorderSizePixel = 0
    logTitleBar.Parent = logFrame

    local titleText = Instance.new("TextLabel")
    titleText.Text = config.Title or "Console"
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 8, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Theme.Text
    titleText.Font = Theme.Font
    titleText.TextSize = 12
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = logTitleBar

    local clearBtn = Instance.new("TextButton")
    clearBtn.Text = "CLR"
    clearBtn.Size = UDim2.new(0, 28, 0, 16)
    clearBtn.Position = UDim2.new(1, -34, 0, 4)
    clearBtn.BackgroundColor3 = Theme.Button
    clearBtn.TextColor3 = Theme.TextDark
    clearBtn.Font = Theme.Font
    clearBtn.TextSize = 10
    clearBtn.BorderSizePixel = 0
    clearBtn.AutoButtonColor = false
    clearBtn.Parent = logTitleBar
    corner(clearBtn, 3)

    makeDraggable(logFrame, logTitleBar)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -26)
    scroll.Position = UDim2.new(0, 0, 0, 26)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.ScrollBarGrab
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.BorderSizePixel = 0
    scroll.Parent = logFrame
    padding(scroll, 4, 4, 6, 6)
    listLayout(scroll, 1)

    clearBtn.MouseButton1Click:Connect(function()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
    end)

    local logColors = {
        Info    = Color3.fromRGB(100, 200, 255),
        Success = Color3.fromRGB(80, 255, 120),
        Warn    = Color3.fromRGB(255, 200, 60),
        Error   = Color3.fromRGB(255, 80, 80),
        Debug   = Color3.fromRGB(180, 180, 180),
    }

    local logPrefixes = {
        Info = "[*]", Success = "[+]", Warn = "[!]", Error = "[x]", Debug = "[~]",
    }

    local loggerObj = {}

    function loggerObj:Log(msg, logType)
        logType = logType or "Info"
        local color = logColors[logType] or Theme.Text
        local prefix = logPrefixes[logType] or "[>]"
        local timestamp = os.date("%H:%M:%S")

        local hexColor = string.format("#%02X%02X%02X",
            math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))

        local entry = Instance.new("TextLabel")
        entry.Size = UDim2.new(1, 0, 0, 0)
        entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.BackgroundTransparency = 1
        entry.Font = Theme.Font
        entry.TextSize = 12
        entry.TextColor3 = color
        entry.TextXAlignment = Enum.TextXAlignment.Left
        entry.TextWrapped = true
        entry.RichText = true
        entry.Text = string.format(
            '<font color="#555">[%s]</font> <font color="%s"><b>%s</b></font> %s',
            timestamp, hexColor, prefix, msg
        )
        entry.Parent = scroll

        local labels = {}
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextLabel") then table.insert(labels, c) end
        end
        if #labels > 150 then labels[1]:Destroy() end

        task.defer(function()
            scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
        end)
    end

    function loggerObj:Clear()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
    end

    loggerObj.Frame = logFrame
    self._Logger = loggerObj
    return loggerObj
end

function Library:Notify(config)
    config = config or {}
    local gui = self.Gui
    if not gui then return end

    if not self._NotifContainer then
        local container = Instance.new("Frame")
        container.Name = "NotifContainer"
        container.AnchorPoint = Vector2.new(1, 1)
        container.Position = UDim2.new(1, -14, 1, -14)
        container.Size = UDim2.new(0, 260, 0, 0)
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.BackgroundTransparency = 1
        container.Parent = gui
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Padding = UDim.new(0, 6)
        layout.Parent = container
        self._NotifContainer = container
        self._NotifCount = 0
    end

    self._NotifCount = self._NotifCount + 1
    local title = config.Title or "Notification"
    local text = config.Text or ""
    local duration = config.Duration or 3

    local notif = Instance.new("Frame")
    notif.Name = "Notif_" .. self._NotifCount
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.AutomaticSize = Enum.AutomaticSize.Y
    notif.BackgroundColor3 = Theme.WindowBg
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.LayoutOrder = self._NotifCount
    notif.Parent = self._NotifContainer
    corner(notif, 4)
    stroke(notif, Theme.Border, 1)

    local nAccent = Instance.new("Frame")
    nAccent.Size = UDim2.new(1, 0, 0, 2)
    nAccent.BackgroundColor3 = Theme.Accent
    nAccent.BorderSizePixel = 0
    nAccent.Parent = notif

    local nInner = Instance.new("Frame")
    nInner.Size = UDim2.new(1, 0, 0, 0)
    nInner.AutomaticSize = Enum.AutomaticSize.Y
    nInner.Position = UDim2.new(0, 0, 0, 2)
    nInner.BackgroundTransparency = 1
    nInner.Parent = notif
    padding(nInner, 6, 8, 10, 10)
    listLayout(nInner, 2)

    local nTitle = Instance.new("TextLabel")
    nTitle.Text = title
    nTitle.Size = UDim2.new(1, 0, 0, 16)
    nTitle.BackgroundTransparency = 1
    nTitle.TextColor3 = Theme.Text
    nTitle.Font = Theme.Font
    nTitle.TextSize = 13
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.LayoutOrder = 1
    nTitle.Parent = nInner

    local nText = Instance.new("TextLabel")
    nText.Text = text
    nText.Size = UDim2.new(1, 0, 0, 0)
    nText.AutomaticSize = Enum.AutomaticSize.Y
    nText.BackgroundTransparency = 1
    nText.TextColor3 = Theme.TextDark
    nText.Font = Theme.Font
    nText.TextSize = 12
    nText.TextXAlignment = Enum.TextXAlignment.Left
    nText.TextWrapped = true
    nText.LayoutOrder = 2
    nText.Parent = nInner

    task.delay(duration, function()
        if notif.Parent then notif:Destroy() end
    end)
end

function Library:SaveConfig(name)
    name = name or "default"
    local data = {}
    for flag, element in pairs(Library._Flags) do
        if flag ~= "ConfigName" then
            local ok, val = pcall(function() return element:Get() end)
            if ok then
                if typeof(val) == "EnumItem" then
                    data[flag] = {Type = "Enum", Value = tostring(val)}
                elseif typeof(val) == "Color3" then
                    data[flag] = {Type = "Color3", R = math.floor(val.R*255), G = math.floor(val.G*255), B = math.floor(val.B*255)}
                else
                    data[flag] = {Type = "Value", Value = val}
                end
            end
        end
    end
    local success, err = pcall(function()
        if not writefile then
            error("File system not available")
        end
        writefile("PickHub_" .. name .. ".json", HttpService:JSONEncode(data))
    end)
    return success, err
end

function Library:LoadConfig(name)
    name = name or "default"
    local fileName = "PickHub_" .. name .. ".json"
    local success, err = pcall(function()
        if not isfile then
            error("File system not available")
        end
        if not isfile(fileName) then
            error("Config '" .. name .. "' not found. Save one first!")
        end
        local raw = readfile(fileName)
        local data = HttpService:JSONDecode(raw)
        local loaded = 0
        for flag, info in pairs(data) do
            if Library._Flags[flag] then
                if info.Type == "Color3" then
                    Library._Flags[flag]:Set(Color3.fromRGB(info.R, info.G, info.B))
                elseif info.Type == "Enum" then
                    local keyName = tostring(info.Value):match("Enum%.KeyCode%.(.+)")
                    if keyName and Enum.KeyCode[keyName] then
                        Library._Flags[flag]:Set(Enum.KeyCode[keyName])
                    end
                else
                    Library._Flags[flag]:Set(info.Value)
                end
                loaded = loaded + 1
            end
        end
        if loaded == 0 then
            error("Config was empty or had no matching flags")
        end
    end)
    return success, err
end

function Library:ListConfigs()
    local configs = {}
    if listfiles then
        for _, file in ipairs(listfiles("")) do
            local name = file:match("PickHub_(.+)%.json$")
            if name then table.insert(configs, name) end
        end
    end
    return configs
end

return Library
