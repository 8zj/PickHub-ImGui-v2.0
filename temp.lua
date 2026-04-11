--[[
    PickHub ImGui v2 - Full Demo
    Features: Watermark, Live Logs, Accent Color, Config Save/Load, Notifications
    Press RightShift to toggle the window.
]]


-- Cache-bust: tick() forces Roblox to fetch fresh copy every time
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/8zj/PickHub-ImGui-v2.0/refs/heads/main/ImGui.lua?cb=" .. tostring(tick())))()
-- Studio: local Library = require(game.ReplicatedStorage.ImGui)

if not Library or not Library.CreateWindow then
    error("[PickHub] Library failed to load - check your paste URL")
end
if not Library.CreateWatermark then
    warn("[PickHub] CreateWatermark missing - paste may be outdated or cached")
end

-- ==========================================================================
-- ============================================================================
-- WINDOW
-- ============================================================================
local Window = Library:CreateWindow({
    Title = "PickHub | v2.0",
    Size = UDim2.new(0, 560, 0, 420),
    Position = UDim2.new(0.5, -280, 0.5, -210),
    ToggleKey = Enum.KeyCode.RightShift,
})

-- ============================================================================
-- WATERMARK (top-left, shows FPS / time / ping, accent-colored)
-- ============================================================================
Window:CreateWatermark()

-- ============================================================================
-- LOGGER (bottom-right floating console)
-- ============================================================================
local Logger = Window:CreateLogger({ Title = "PickHub Console" })

-- ============================================================================
-- TAB 1: Main
-- ============================================================================
local MainTab = Window:AddTab("Main")

local GeneralSection = MainTab:AddSection("General")
GeneralSection:AddLabel("Welcome to PickHub ImGui v2!")
GeneralSection:AddSeparator()

GeneralSection:AddButton({
    Text = "Send Test Notification",
    Callback = function()
        Window:Notify({ Title = "PickHub", Text = "This is a toast notification!", Duration = 3 })
        Logger:Log("Notification sent", "Success")
    end
})

GeneralSection:AddToggle({
    Text = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(state)
        Logger:Log("Auto Farm: " .. tostring(state), state and "Success" or "Info")
    end
})

GeneralSection:AddToggle({
    Text = "Anti AFK",
    Default = true,
    Flag = "AntiAFK",
    Callback = function(state)
        Logger:Log("Anti AFK: " .. tostring(state), state and "Success" or "Warn")
    end
})

GeneralSection:AddSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Suffix = " studs",
    Flag = "WalkSpeed",
    Callback = function(val)
        Logger:Log("Walk Speed set to " .. val, "Debug")
    end
})

GeneralSection:AddDropdown({
    Text = "Farm Mode",
    Options = {"Normal", "Aggressive", "Passive", "AFK"},
    Default = "Normal",
    Flag = "FarmMode",
    Callback = function(opt)
        Logger:Log("Farm mode: " .. opt, "Info")
    end
})

-- ============================================================================
-- TAB 2: Combat
-- ============================================================================
local CombatTab = Window:AddTab("Combat")

local AimbotSection = CombatTab:AddSection("Aimbot")

AimbotSection:AddToggle({
    Text = "Enable Aimbot",
    Default = false,
    Flag = "Aimbot",
    Callback = function(state)
        Logger:Log("Aimbot: " .. tostring(state), state and "Success" or "Info")
    end
})

AimbotSection:AddSlider({
    Text = "FOV",
    Min = 50,
    Max = 800,
    Default = 200,
    Suffix = "px",
    Flag = "AimbotFOV",
    Callback = function(val)
        Logger:Log("FOV: " .. val .. "px", "Debug")
    end
})

AimbotSection:AddSlider({
    Text = "Smoothness",
    Min = 1,
    Max = 20,
    Default = 5,
    Precise = true,
    Flag = "AimbotSmooth",
    Callback = function(val)
        Logger:Log("Smoothness: " .. string.format("%.1f", val), "Debug")
    end
})

AimbotSection:AddDropdown({
    Text = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Torso", "Random"},
    Default = "Head",
    Flag = "TargetPart",
    Callback = function(opt)
        Logger:Log("Target: " .. opt, "Info")
    end
})

AimbotSection:AddKeybind({
    Text = "Aimbot Key",
    Default = Enum.KeyCode.E,
    Flag = "AimbotKey",
    Callback = function(key)
        Logger:Log("Aimbot key: " .. key.Name, "Info")
    end
})

local ESPSection = CombatTab:AddSection("Visuals")

ESPSection:AddToggle({
    Text = "Player ESP",
    Default = false,
    Flag = "ESP",
    Callback = function(state)
        Logger:Log("ESP: " .. tostring(state), state and "Success" or "Info")
    end
})

ESPSection:AddToggle({
    Text = "Chams",
    Default = false,
    Flag = "Chams",
    Callback = function(state)
        Logger:Log("Chams: " .. tostring(state), state and "Success" or "Info")
    end
})

ESPSection:AddColorPicker({
    Text = "ESP Color",
    Default = Color3.fromRGB(255, 50, 50),
    Flag = "ESPColor",
    Callback = function(color)
        Logger:Log("ESP color changed", "Debug")
    end
})

-- ============================================================================
-- TAB 3: Misc
-- ============================================================================
local MiscTab = Window:AddTab("Misc")

local TeleportSection = MiscTab:AddSection("Teleport")

TeleportSection:AddDropdown({
    Text = "Location",
    Options = {"Spawn", "Shop", "Boss Room", "Secret Area"},
    Default = "Spawn",
    Flag = "TeleportLocation",
    Callback = function(opt)
        Logger:Log("Selected: " .. opt, "Info")
    end
})

TeleportSection:AddButton({
    Text = "Teleport",
    Callback = function()
        local loc = Library._Flags["TeleportLocation"] and Library._Flags["TeleportLocation"]:Get() or "Spawn"
        Logger:Log("Teleporting to " .. loc .. "...", "Success")
        Window:Notify({ Title = "Teleport", Text = "Teleporting to " .. loc, Duration = 2 })
    end
})

local UtilSection = MiscTab:AddSection("Utilities")

UtilSection:AddTextbox({
    Text = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    Flag = "WebhookURL",
    Callback = function(text, enter)
        if enter then
            Logger:Log("Webhook saved", "Success")
        end
    end
})

UtilSection:AddButton({
    Text = "Rejoin Server",
    Callback = function()
        Logger:Log("Rejoining server...", "Warn")
        Window:Notify({ Title = "Rejoin", Text = "Reconnecting...", Duration = 2 })
    end
})

UtilSection:AddButton({
    Text = "Copy Server Link",
    Callback = function()
        Logger:Log("Server link copied to clipboard", "Success")
    end
})

-- ============================================================================
-- TAB 4: Settings (Accent Color, Toggle Key, Config, Info)
-- ============================================================================
local SettingsTab = Window:AddTab("Settings")

local ThemeSection = SettingsTab:AddSection("Theme")

ThemeSection:AddColorPicker({
    Text = "Accent Color",
    Default = Library.Theme.Accent,
    Flag = "AccentColor",
    Callback = function(color)
        Library:SetAccent(color)
        Logger:Log("Accent color updated!", "Success")
    end
})

ThemeSection:AddSlider({
    Text = "UI Opacity",
    Min = 30,
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
    Flag = "ToggleKey",
    Callback = function(key)
        Window._ToggleKey = key
        Logger:Log("Toggle key set to: " .. key.Name, "Info")
    end
})

local ConfigSection = SettingsTab:AddSection("Config")

-- Gather existing configs for dropdown
local savedConfigs = Window:ListConfigs()
if #savedConfigs == 0 then savedConfigs = {"default"} end

local configDropdown = ConfigSection:AddDropdown({
    Text = "Select Config",
    Options = savedConfigs,
    Default = savedConfigs[1],
})

local configNameBox = ConfigSection:AddTextbox({
    Text = "New Config Name",
    Placeholder = "my_config",
    Default = "",
})

local function refreshConfigList()
    local list = Window:ListConfigs()
    if #list == 0 then list = {"default"} end
    configDropdown:SetOptions(list)
end

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
        else
            Logger:Log("Save failed: " .. tostring(err), "Error")
        end
    end
})

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

local InfoSection = SettingsTab:AddSection("Info")
InfoSection:AddLabel("PickHub ImGui v2.0")
InfoSection:AddLabel("Press RightShift to toggle UI")
InfoSection:AddSeparator()
InfoSection:AddButton({
    Text = "Destroy UI",
    Callback = function()
        Window.Gui:Destroy()
    end
})

-- ============================================================================
-- FAKE LIVE LOG DATA (Demo purposes - simulates real activity)
-- ============================================================================
local fakeMessages = {
    {msg = "Connected to server", type = "Success"},
    {msg = "Player 'xShadow' joined the game", type = "Info"},
    {msg = "Auto Farm started on Wave 12", type = "Success"},
    {msg = "Collected 3 coins (+150g)", type = "Debug"},
    {msg = "Enemy spawned: Fallen King", type = "Warn"},
    {msg = "Aimbot locked onto target: HumanoidRootPart", type = "Info"},
    {msg = "Wave 12 completed in 45.2s", type = "Success"},
    {msg = "Anti-AFK ping sent", type = "Debug"},
    {msg = "Disconnection attempt blocked", type = "Warn"},
    {msg = "Player 'NoobMaster69' left the game", type = "Info"},
    {msg = "Webhook sent successfully (200 OK)", type = "Success"},
    {msg = "ESP refreshed: 8 players visible", type = "Debug"},
    {msg = "Tower placed: Accelerator Lv5", type = "Info"},
    {msg = "Low FPS detected (24fps), reducing particles", type = "Warn"},
    {msg = "Config auto-saved", type = "Debug"},
    {msg = "Boss HP: 12,450 / 50,000", type = "Info"},
    {msg = "Critical hit! 2,340 damage", type = "Success"},
    {msg = "Network timeout, retrying...", type = "Error"},
    {msg = "Reconnected successfully", type = "Success"},
    {msg = "Collected reward: Epic Crate x1", type = "Success"},
}

-- Initial welcome logs
Logger:Log("PickHub v2.0 loaded successfully", "Success")
Logger:Log("Press RightShift to toggle UI", "Info")
Logger:Log("Use Settings tab to change accent color", "Info")

-- Spawn fake logs every few seconds for demo
task.spawn(function()
    task.wait(2)
    while Window.Gui and Window.Gui.Parent do
        local entry = fakeMessages[math.random(1, #fakeMessages)]
        Logger:Log(entry.msg, entry.type)
        task.wait(math.random(20, 50) / 10)
    end
end)

-- Welcome notification
task.delay(1, function()
    Window:Notify({
        Title = "PickHub Loaded",
        Text = "Welcome! All systems operational.",
        Duration = 4,
    })
end)

print("[PickHub] ImGui v2 Demo loaded! Press RightShift to toggle.")
