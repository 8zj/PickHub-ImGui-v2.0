--[[
    PickHub ImGui Template
    A comprehensive template demonstrating all ImGui features
    
    Features:
    - Window creation with customizable options
    - Tabs and sections for organization
    - UI Elements: Buttons, Toggles, Sliders, Dropdowns, Textboxes, Keybinds, Color Pickers
    - Watermark, Logger, Notifications
    - Config Save/Load system
    - Accent color customization
    
    Usage:
    1. Load the ImGui library (from GitHub or local file)
    2. Create a window with your desired settings
    3. Add tabs to organize your UI
    4. Add sections within tabs
    5. Add UI elements to sections
    6. Use flags to reference elements for config saving
    
    Press RightShift to toggle the window visibility
]]

-- ============================================================================
-- LIBRARY LOADING
-- ============================================================================
-- Option 1: Load from GitHub (recommended for Roblox)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/8zj/PickHub-ImGui-v2.0/refs/heads/main/ImGui.lua?cb=" .. tostring(tick())))()

-- Option 2: Load from local file (for testing/studio)
-- local Library = loadstring(readfile("ImGui.lua"))()

-- Option 3: Load from ReplicatedStorage (for studio)
-- local Library = require(game.ReplicatedStorage.ImGui)

if not Library or not Library.CreateWindow then
    error("[PickHub] Library failed to load - check your loading method")
end

-- ============================================================================
-- WINDOW CREATION
-- ============================================================================
local Window = Library:CreateWindow({
    Title = "PickHub | Template",
    Size = UDim2.new(0, 550, 0, 420),
    Position = UDim2.new(0.5, -275, 0.5, -210),
    ToggleKey = Enum.KeyCode.RightShift, -- Key to toggle UI visibility
})

-- ============================================================================
-- OPTIONAL COMPONENTS
-- ============================================================================

-- Watermark (top of screen, shows FPS/time/ping)
Window:CreateWatermark()

-- Logger (bottom-right console for debug messages)
local Logger = Window:CreateLogger({ Title = "Console" })

-- ============================================================================
-- LIVE CHAT (Bottom Left)
-- ============================================================================

local Chat = Window:CreateChat({
    Title = "Live Chat",
    Size = UDim2.new(0, 320, 0, 240),
    Position = UDim2.new(0, 14, 1, -254), -- Bottom left position
    
    -- Live Chat Configuration (Optional)
    -- To enable live chat, set up a server with these endpoints:
    -- POST /send - receives {username, message, userId, timestamp, apiKey}
    -- GET /fetch?apiKey=xxx - returns {messages: [{username, message, userId, timestamp}]}
    -- ServerUrl = "https://your-server.com/api/chat",
    -- ApiKey = "your-api-key",
    -- LiveChat = true, -- Set to true to enable live chat polling
    
    OnMessageSent = function(username, message, userId)
        Logger:Log("Chat: " .. username .. " sent '" .. message .. "'", "Info")
        
        -- Echo back the message with a different color (for demo purposes)
        task.wait(0.5)
        Chat.AddMessage("Bot", "You said: " .. message, Color3.fromRGB(100, 200, 100))
    end
})

-- ============================================================================
-- TABS
-- ============================================================================

local MainTab = Window:AddTab("Main")
local SettingsTab = Window:AddTab("Settings")
local ConfigTab = Window:AddTab("Config")

-- ============================================================================
-- MAIN TAB - SECTIONS & ELEMENTS
-- ============================================================================

-- === Section 1: Basic Controls ===
local BasicSection = MainTab:AddSection("Basic Controls")

-- Label - Display text
BasicSection:AddLabel("Welcome to PickHub ImGui!")

-- Separator - Visual divider
BasicSection:AddSeparator()

-- Button - Clickable button with callback
BasicSection:AddButton({
    Text = "Click Me",
    Callback = function()
        Logger:Log("Button clicked!", "Success")
        Window:Notify({ Title = "Button", Text = "You clicked the button!", Duration = 2 })
    end
})

-- Toggle - On/off switch with state tracking
BasicSection:AddToggle({
    Text = "Enable Feature",
    Default = false,
    Flag = "EnableFeature", -- Used for config saving
    Callback = function(state)
        Logger:Log("Feature: " .. tostring(state), state and "Success" or "Info")
    end
})

-- Slider - Numeric value selection
BasicSection:AddSlider({
    Text = "Value",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Flag = "ValueSlider",
    Callback = function(val)
        Logger:Log("Value: " .. val, "Debug")
    end
})

-- Dropdown - Select from options
BasicSection:AddDropdown({
    Text = "Select Option",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Flag = "OptionDropdown",
    Callback = function(opt)
        Logger:Log("Selected: " .. opt, "Info")
    end
})

-- === Section 2: Chat Controls ===
local ChatSection = MainTab:AddSection("Chat Controls")

ChatSection:AddLabel("Chat is located at bottom-left")

ChatSection:AddButton({
    Text = "Send Test Message",
    Callback = function()
        Chat.AddMessage("System", "This is a test message!", Color3.fromRGB(255, 200, 50))
        Logger:Log("Test message sent to chat", "Success")
    end
})

ChatSection:AddButton({
    Text = "Clear Chat",
    Callback = function()
        Chat.Clear()
        Logger:Log("Chat cleared", "Info")
    end
})

ChatSection:AddButton({
    Text = "Toggle Chat Visibility",
    Callback = function()
        local isVisible = Chat.IsVisible()
        Chat.SetVisible(not isVisible)
        Logger:Log("Chat visibility: " .. tostring(not isVisible), "Info")
    end
})

-- === Section 3: Advanced Controls ===
local AdvancedSection = MainTab:AddSection("Advanced Controls")

-- Textbox - Text input
AdvancedSection:AddTextbox({
    Text = "Input Text",
    Placeholder = "Type here...",
    Default = "",
    Flag = "InputText",
    Callback = function(text, enter)
        if enter then
            Logger:Log("Text: " .. text, "Success")
        end
    end
})

-- Keybind - Key binding
AdvancedSection:AddKeybind({
    Text = "Toggle Key",
    Default = Enum.KeyCode.F,
    Flag = "ToggleKeybind",
    Callback = function(key)
        Logger:Log("Key: " .. key.Name, "Info")
    end
})

-- Color Picker - Color selection
AdvancedSection:AddColorPicker({
    Text = "Accent Color",
    Default = Library.Theme.Accent,
    Flag = "AccentColor",
    Callback = function(color)
        Library:SetAccent(color)
        Logger:Log("Color changed!", "Success")
    end
})

-- ============================================================================
-- SETTINGS TAB - THEME & UI OPTIONS
-- ============================================================================

local ThemeSection = SettingsTab:AddSection("Theme")

ThemeSection:AddColorPicker({
    Text = "UI Accent Color",
    Default = Library.Theme.Accent,
    Flag = "UIAccent",
    Callback = function(color)
        Library:SetAccent(color)
    end
})

ThemeSection:AddSlider({
    Text = "UI Opacity",
    Min = 50,
    Max = 100,
    Default = 100,
    Suffix = "%",
    Flag = "UIOpacity",
    Callback = function(val)
        if Window.Frame then
            Window.Frame.BackgroundTransparency = 1 - (val / 100)
        end
    end
})

ThemeSection:AddKeybind({
    Text = "Toggle UI Key",
    Default = Enum.KeyCode.RightShift,
    Flag = "UIToggleKey",
    Callback = function(key)
        Window._ToggleKey = key
    end
})

-- ============================================================================
-- CONFIG TAB - SAVE/LOAD SYSTEM
-- ============================================================================

local ConfigSection = ConfigTab:AddSection("Configuration")

-- Get existing configs
local savedConfigs = Window:ListConfigs()
if #savedConfigs == 0 then savedConfigs = {"default"} end

-- Config name input
local configNameBox = ConfigSection:AddTextbox({
    Text = "Config Name",
    Placeholder = "my_config",
    Default = "",
})

-- Config dropdown
local configDropdown = ConfigSection:AddDropdown({
    Text = "Select Config",
    Options = savedConfigs,
    Default = savedConfigs[1],
})

-- Refresh dropdown function
local function refreshConfigList()
    local list = Window:ListConfigs()
    if #list == 0 then list = {"default"} end
    configDropdown:SetOptions(list)
end

-- Save Config button
ConfigSection:AddButton({
    Text = "Save Config",
    Callback = function()
        local name = configNameBox:Get()
        if name == "" then name = configDropdown:Get() end
        if name == "" then name = "default" end
        
        local ok, err = Window:SaveConfig(name)
        if ok then
            Logger:Log("Config saved: " .. name, "Success")
            Window:Notify({ Title = "Config", Text = "Saved '" .. name .. "'", Duration = 2 })
            refreshConfigList()
            configDropdown:Set(name)
            configNameBox:Set("")
        else
            Logger:Log("Save failed: " .. tostring(err), "Error")
        end
    end
})

-- Load Config button
ConfigSection:AddButton({
    Text = "Load Config",
    Callback = function()
        local name = configDropdown:Get()
        if not name or name == "" then name = "default" end
        
        local ok, err = Window:LoadConfig(name)
        if ok then
            Logger:Log("Config loaded: " .. name, "Success")
            Window:Notify({ Title = "Config", Text = "Loaded '" .. name .. "'", Duration = 2 })
        else
            Logger:Log("Load failed: " .. tostring(err), "Error")
        end
    end
})

-- Delete Config button
ConfigSection:AddButton({
    Text = "Delete Config",
    Callback = function()
        local name = configDropdown:Get()
        if not name or name == "" then return end
        
        -- Note: You'll need to implement delete functionality
        Logger:Log("Delete not implemented yet", "Warn")
    end
})

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Log startup message
Logger:Log("PickHub ImGui Template loaded!", "Success")
Logger:Log("Press RightShift to toggle UI", "Info")

-- Show welcome notification
task.delay(1, function()
    Window:Notify({
        Title = "Welcome",
        Text = "Template loaded successfully!",
        Duration = 3,
    })
end)

print("[PickHub] ImGui Template loaded! Press RightShift to toggle UI.")
