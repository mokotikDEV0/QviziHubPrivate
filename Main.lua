local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if _G.QVIZI_LOADED then
	pcall(function()
		if _G.QVIZI_CLEANUP then _G.QVIZI_CLEANUP() end
	end)
	for _, g in ipairs(LP.PlayerGui:GetChildren()) do
		if g.Name == "QVIZIHUB" or g.Name == "QVIZI_FOV" or g.Name == "QVIZIIntro" then
			g:Destroy()
		end
	end
end
_G.QVIZI_LOADED = true

local VERSION = "V1.0"

local THEME = {
	BG = Color3.fromRGB(10, 5, 16),
	PANEL = Color3.fromRGB(20, 10, 30),
	ROW = Color3.fromRGB(28, 14, 40),
	ACCENT = Color3.fromRGB(190, 60, 255),
	ACCENT2 = Color3.fromRGB(255, 90, 200),
	TEXT = Color3.fromRGB(240, 225, 250),
	TEXT_DIM = Color3.fromRGB(160, 130, 185),
	OFF = Color3.fromRGB(45, 28, 60),
	GREEN = Color3.fromRGB(0, 220, 100),
	RED = Color3.fromRGB(255, 60, 80),
}

local CLICK_SOUND = "rbxassetid://139719503904449"
local INTRO_SOUND = "rbxassetid://6350854289"

local Config = {
	ESP = false,
	ESPColor = Color3.fromRGB(190, 60, 255),
	ESPMaxDist = 5000,
	ESPName = true,
	ESPDistance = true,
	ESPHealth = true,
	ESPHighlight = true,
	ESPChams = false,
	ESPRainbow = false,
	Aimbot = false,
	AimSmooth = 15,
	AimFOV = 150,
	AimPart = "Head",
	AimDrawFOV = true,
	AimVisibleCheck = true,
	AimTeamCheck = false,
	TimeMode = "Day",
	SpeedEnabled = false,
	SpeedValue = 50,
	InfJump = false,
	IntroEnabled = true,
	BodyBagESP = false,
	BodyBagOwner = true,
	BodyBagDistance = true,
	BodyBagMaxDist = 5000,
}

local DEFAULT_SPEED = 16
local CFG_FILE = "qvizi_cfg.json"

local originalLighting = nil

local function saveLighting()
	originalLighting = {
		ClockTime = Lighting.ClockTime,
		Brightness = Lighting.Brightness,
		FogEnd = Lighting.FogEnd,
		FogStart = Lighting.FogStart,
		FogColor = Lighting.FogColor,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
	}
end

local function restoreLighting()
	if not originalLighting then return end
	pcall(function()
		Lighting.ClockTime = originalLighting.ClockTime
		Lighting.Brightness = originalLighting.Brightness
		Lighting.FogEnd = originalLighting.FogEnd
		Lighting.FogStart = originalLighting.FogStart
		Lighting.FogColor = originalLighting.FogColor
		Lighting.Ambient = originalLighting.Ambient
		Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
	end)
end

local function hasFs()
	return type(writefile) == "function" and type(isfile) == "function" and type(readfile) == "function"
end

local function loadCfg()
	if not hasFs() then return end
	pcall(function()
		if isfile(CFG_FILE) then
			local data = HttpService:JSONDecode(readfile(CFG_FILE))
			if type(data) == "table" then
				for k, v in pairs(data) do
					if Config[k] ~= nil then
						if k == "ESPColor" and type(v) == "table" then
							Config.ESPColor = Color3.new(v[1], v[2], v[3])
						else
							Config[k] = v
						end
					end
				end
			end
		end
	end)
end

local function saveCfg()
	if not hasFs() then return end
	pcall(function()
		local c = {}
		for k, v in pairs(Config) do
			if typeof(v) == "Color3" then
				c[k] = {v.R, v.G, v.B}
			else
				c[k] = v
			end
		end
		writefile(CFG_FILE, HttpService:JSONEncode(c))
	end)
end

loadCfg()

local saveDebounce = false
local function saveCfgDelayed()
	if saveDebounce then return end
	saveDebounce = true
	task.delay(0.4, function()
		saveDebounce = false
		saveCfg()
	end)
end

local function playClick()
	local s = Instance.new("Sound")
	s.SoundId = CLICK_SOUND
	s.Volume = 0.5
	s.PlaybackSpeed = 1
	s.Parent = SoundService
	s:Play()
	task.delay(2, function()
		pcall(function() s:Destroy() end)
	end)
end

local cleanupFns = {}
_G.QVIZI_CLEANUP = function()
	for _, fn in ipairs(cleanupFns) do
		pcall(fn)
	end
	restoreLighting()
end

local function registerCleanup(fn)
	table.insert(cleanupFns, fn)
end

local introGui = LP.PlayerGui:FindFirstChild("QVIZIIntro")
if introGui then introGui:Destroy() end

local introPlayed = false
local function playIntro()
	if introPlayed then return end
	introPlayed = true

	local introSound = Instance.new("Sound")
	introSound.SoundId = INTRO_SOUND
	introSound.Volume = 0.35
	introSound.Parent = SoundService
	introSound:Play()
	registerCleanup(function()
		pcall(function() introSound:Destroy() end)
	end)

	local gui = Instance.new("ScreenGui")
	gui.Name = "QVIZIIntro"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 999
	gui.Parent = LP:WaitForChild("PlayerGui")

	local bg = Instance.new("Frame", gui)
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.new(0, 0, 0)
	bg.BorderSizePixel = 0

	local glow = Instance.new("Frame", bg)
	glow.Size = UDim2.new(1, 0, 1, 0)
	glow.BackgroundColor3 = THEME.ACCENT
	glow.BackgroundTransparency = 0.9
	glow.BorderSizePixel = 0

	local glitchContainer = Instance.new("Frame", bg)
	glitchContainer.Size = UDim2.new(1, 0, 0, 200)
	glitchContainer.Position = UDim2.new(0, 0, 0.5, -100)
	glitchContainer.BackgroundTransparency = 1

	local mainTitle = Instance.new("TextLabel", glitchContainer)
	mainTitle.Size = UDim2.new(1, 0, 0, 130)
	mainTitle.BackgroundTransparency = 1
	mainTitle.Text = "QVIZI HUB"
	mainTitle.TextColor3 = THEME.ACCENT
	mainTitle.Font = Enum.Font.GothamBlack
	mainTitle.TextScaled = true
	mainTitle.TextTransparency = 1
	mainTitle.TextStrokeTransparency = 1
	mainTitle.TextStrokeColor3 = THEME.ACCENT2

	local ghostR = mainTitle:Clone()
	ghostR.TextColor3 = Color3.fromRGB(255, 40, 100)
	ghostR.Position = UDim2.new(0, 8, 0, 0)
	ghostR.Parent = glitchContainer
	ghostR.ZIndex = mainTitle.ZIndex - 1

	local ghostB = mainTitle:Clone()
	ghostB.TextColor3 = Color3.fromRGB(40, 220, 255)
	ghostB.Position = UDim2.new(0, -8, 0, 0)
	ghostB.Parent = glitchContainer
	ghostB.ZIndex = mainTitle.ZIndex - 2

	local subTitle = Instance.new("TextLabel", bg)
	subTitle.Size = UDim2.new(1, 0, 0, 36)
	subTitle.Position = UDim2.new(0, 0, 0.5, 50)
	subTitle.BackgroundTransparency = 1
	subTitle.Text = "P R I V A T E   + + +   " .. VERSION
	subTitle.TextColor3 = THEME.ACCENT2
	subTitle.Font = Enum.Font.GothamBold
	subTitle.TextSize = 22
	subTitle.TextTransparency = 1

	local credit = Instance.new("TextLabel", bg)
	credit.Size = UDim2.new(1, 0, 0, 30)
	credit.Position = UDim2.new(0, 0, 0.5, 100)
	credit.BackgroundTransparency = 1
	credit.Text = "By: Arbuz0"
	credit.TextColor3 = THEME.TEXT
	credit.Font = Enum.Font.GothamBold
	credit.TextSize = 20
	credit.TextTransparency = 1

	local loadingBar = Instance.new("Frame", bg)
	loadingBar.Size = UDim2.new(0, 400, 0, 4)
	loadingBar.Position = UDim2.new(0.5, -200, 0.5, 150)
	loadingBar.BackgroundColor3 = THEME.ROW
	loadingBar.BorderSizePixel = 0
	Instance.new("UICorner", loadingBar).CornerRadius = UDim.new(1, 0)

	local loadingFill = Instance.new("Frame", loadingBar)
	loadingFill.Size = UDim2.new(0, 0, 1, 0)
	loadingFill.BackgroundColor3 = THEME.ACCENT
	loadingFill.BorderSizePixel = 0
	Instance.new("UICorner", loadingFill).CornerRadius = UDim.new(1, 0)
	local lfg = Instance.new("UIGradient", loadingFill)
	lfg.Color = ColorSequence.new(THEME.ACCENT, THEME.ACCENT2)

	local loadingLbl = Instance.new("TextLabel", bg)
	loadingLbl.Size = UDim2.new(0, 400, 0, 20)
	loadingLbl.Position = UDim2.new(0.5, -200, 0.5, 158)
	loadingLbl.BackgroundTransparency = 1
	loadingLbl.Text = "initializing..."
	loadingLbl.TextColor3 = THEME.TEXT_DIM
	loadingLbl.Font = Enum.Font.Code
	loadingLbl.TextSize = 12
	loadingLbl.TextTransparency = 1

	TweenService:Create(mainTitle, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
	TweenService:Create(ghostR, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
	TweenService:Create(ghostB, TweenInfo.new(0.4), {TextTransparency = 0}):Play()

	task.wait(0.9)
	TweenService:Create(subTitle, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
	TweenService:Create(credit, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
	TweenService:Create(loadingLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

	local stages = {
		"loading modules...",
		"hooking render...",
		"initializing ESP...",
		"loading config...",
		"connecting...",
		"ready."
	}
	for i, stageText in ipairs(stages) do
		loadingLbl.Text = stageText
		TweenService:Create(loadingFill, TweenInfo.new(0.25), {Size = UDim2.new(i / #stages, 0, 1, 0)}):Play()
		task.wait(0.25)
	end

	task.wait(0.4)
	for _, obj in pairs({mainTitle, ghostR, ghostB, subTitle, credit, loadingLbl}) do
		TweenService:Create(obj, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
	end
	TweenService:Create(loadingBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	TweenService:Create(loadingFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	TweenService:Create(bg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	TweenService:Create(glow, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	task.wait(0.45)
	gui:Destroy()
end

local fovGui, fovCircle, fovStroke

local function createFovCircle()
	local existing = LP.PlayerGui:FindFirstChild("QVIZI_FOV")
	if existing then existing:Destroy() end

	fovGui = Instance.new("ScreenGui")
	fovGui.Name = "QVIZI_FOV"
	fovGui.IgnoreGuiInset = true
	fovGui.ResetOnSpawn = false
	fovGui.DisplayOrder = 5
	fovGui.Parent = LP:WaitForChild("PlayerGui")

	fovCircle = Instance.new("Frame", fovGui)
	fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
	fovCircle.Size = UDim2.new(0, 300, 0, 300)
	fovCircle.BackgroundTransparency = 1
	fovCircle.BorderSizePixel = 0
	fovCircle.Visible = false
	Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
	fovStroke = Instance.new("UIStroke", fovCircle)
	fovStroke.Thickness = 1.5
	fovStroke.Color = THEME.ACCENT
	fovStroke.Transparency = 0.2
end

createFovCircle()
registerCleanup(function()
	if fovGui then fovGui:Destroy() end
end)

local rainbowConn = nil
local rainbowHue = 0

local function startRainbow()
	if rainbowConn then return end
	rainbowConn = RunService.RenderStepped:Connect(function(dt)
		if not Config.ESPRainbow then return end
		rainbowHue = (rainbowHue + dt * 0.5) % 1
		Config.ESPColor = Color3.fromHSV(rainbowHue, 1, 1)
	end)
	registerCleanup(function()
		if rainbowConn then rainbowConn:Disconnect() end
	end)
end

startRainbow()

local pinkSkyActive = false
local pinkSkyObjects = {}
local savedAtmosphere = nil

local function applyPinkSky()
	if pinkSkyActive then return end
	pinkSkyActive = true

	saveLighting()

	local existingAtm = Lighting:FindFirstChildOfClass("Atmosphere")
	if existingAtm and existingAtm.Name ~= "QVIZI_PinkAtm" then
		savedAtmosphere = existingAtm
		existingAtm.Parent = nil
	end

	local sky = Instance.new("Sky")
	sky.Name = "QVIZI_PinkSky"
	sky.SkyboxBk = "rbxassetid://159454299"
	sky.SkyboxDn = "rbxassetid://159454296"
	sky.SkyboxFt = "rbxassetid://159454293"
	sky.SkyboxLf = "rbxassetid://159454286"
	sky.SkyboxRt = "rbxassetid://159454300"
	sky.SkyboxUp = "rbxassetid://159454288"
	sky.SunAngularSize = 0
	sky.MoonAngularSize = 0
	sky.StarCount = 3000
	sky.Parent = Lighting
	table.insert(pinkSkyObjects, sky)

	local atm = Instance.new("Atmosphere")
	atm.Name = "QVIZI_PinkAtm"
	atm.Density = 0.32
	atm.Offset = 0
	atm.Color = Color3.fromRGB(255, 200, 225)
	atm.Decay = Color3.fromRGB(160, 110, 160)
	atm.Glare = 0.35
	atm.Haze = 1.8
	atm.Parent = Lighting
	table.insert(pinkSkyObjects, atm)

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "QVIZI_PinkCC"
	cc.Brightness = -0.02
	cc.Contrast = 0.08
	cc.Saturation = 0.1
	cc.TintColor = Color3.fromRGB(255, 220, 240)
	cc.Parent = Lighting
	table.insert(pinkSkyObjects, cc)

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "QVIZI_PinkBloom"
	bloom.Intensity = 0.35
	bloom.Size = 18
	bloom.Threshold = 1.1
	bloom.Parent = Lighting
	table.insert(pinkSkyObjects, bloom)

	Lighting.ClockTime = 18.2
	Lighting.Brightness = 1.4
	Lighting.Ambient = Color3.fromRGB(105, 85, 105)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 115, 145)
	Lighting.FogColor = Color3.fromRGB(220, 175, 200)
	Lighting.FogEnd = 8000
	Lighting.FogStart = 0
end

local function removePinkSky()
	pinkSkyActive = false
	for _, obj in ipairs(pinkSkyObjects) do
		pcall(function() obj:Destroy() end)
	end
	pinkSkyObjects = {}
	if savedAtmosphere then
		pcall(function()
			savedAtmosphere.Parent = Lighting
		end)
		savedAtmosphere = nil
	end
	restoreLighting()
end

registerCleanup(removePinkSky)

local function createMenu()
	local existing = LP.PlayerGui:FindFirstChild("QVIZIHUB")
	if existing then existing:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "QVIZIHUB"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Parent = LP:WaitForChild("PlayerGui")

	local openBtn = Instance.new("TextButton", gui)
	openBtn.Size = UDim2.new(0, 60, 0, 60)
	openBtn.Position = UDim2.new(0, 20, 0.5, -30)
	openBtn.BackgroundColor3 = THEME.PANEL
	openBtn.Text = "Q"
	openBtn.TextColor3 = THEME.ACCENT
	openBtn.Font = Enum.Font.GothamBlack
	openBtn.TextSize = 30
	openBtn.AutoButtonColor = false
	openBtn.BorderSizePixel = 0
	openBtn.Active = true
	Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
	local obs = Instance.new("UIStroke", openBtn)
	obs.Thickness = 2
	local obg = Instance.new("UIGradient", obs)
	obg.Color = ColorSequence.new(THEME.ACCENT, THEME.ACCENT2)

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 640, 0, 440)
	main.Position = UDim2.new(0.5, -320, 0.5, -220)
	main.BackgroundColor3 = THEME.BG
	main.BorderSizePixel = 0
	main.Visible = false
	main.ClipsDescendants = true
	main.Active = true
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
	local ms = Instance.new("UIStroke", main)
	ms.Thickness = 1.5
	local msg = Instance.new("UIGradient", ms)
	msg.Color = ColorSequence.new(THEME.ACCENT, THEME.ACCENT2)

	local top = Instance.new("Frame", main)
	top.Size = UDim2.new(1, 0, 0, 44)
	top.BackgroundColor3 = THEME.PANEL
	top.BorderSizePixel = 0
	Instance.new("UICorner", top).CornerRadius = UDim.new(0, 16)
	local topCover = Instance.new("Frame", top)
	topCover.Size = UDim2.new(1, 0, 0, 16)
	topCover.Position = UDim2.new(0, 0, 1, -16)
	topCover.BackgroundColor3 = THEME.PANEL
	topCover.BorderSizePixel = 0

	local topTitle = Instance.new("TextLabel", top)
	topTitle.BackgroundTransparency = 1
	topTitle.Size = UDim2.new(1, -220, 1, 0)
	topTitle.Position = UDim2.new(0, 18, 0, 0)
	topTitle.Text = "QVIZI HUB  PRIVATE +++  " .. VERSION
	topTitle.TextColor3 = THEME.ACCENT
	topTitle.Font = Enum.Font.GothamBlack
	topTitle.TextSize = 15
	topTitle.TextXAlignment = Enum.TextXAlignment.Left

	local statHolder = Instance.new("Frame", top)
	statHolder.Size = UDim2.new(0, 150, 1, 0)
	statHolder.Position = UDim2.new(1, -190, 0, 0)
	statHolder.BackgroundTransparency = 1

	local pingLbl = Instance.new("TextLabel", statHolder)
	pingLbl.Size = UDim2.new(1, 0, 0, 20)
	pingLbl.Position = UDim2.new(0, 0, 0, 4)
	pingLbl.BackgroundTransparency = 1
	pingLbl.Text = "PING: 0ms"
	pingLbl.TextColor3 = THEME.GREEN
	pingLbl.Font = Enum.Font.Code
	pingLbl.TextSize = 12
	pingLbl.TextXAlignment = Enum.TextXAlignment.Right

	local fpsLbl = Instance.new("TextLabel", statHolder)
	fpsLbl.Size = UDim2.new(1, 0, 0, 20)
	fpsLbl.Position = UDim2.new(0, 0, 0, 22)
	fpsLbl.BackgroundTransparency = 1
	fpsLbl.Text = "FPS: 0"
	fpsLbl.TextColor3 = THEME.GREEN
	fpsLbl.Font = Enum.Font.Code
	fpsLbl.TextSize = 12
	fpsLbl.TextXAlignment = Enum.TextXAlignment.Right

	local closeBtn = Instance.new("TextButton", top)
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -38, 0, 8)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 19, 82)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 18
	closeBtn.BorderSizePixel = 0
	closeBtn.AutoButtonColor = false
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

	local tabBar = Instance.new("Frame", main)
	tabBar.Size = UDim2.new(1, -30, 0, 32)
	tabBar.Position = UDim2.new(0, 15, 0, 54)
	tabBar.BackgroundTransparency = 1

	local tabHolder = Instance.new("Frame", main)
	tabHolder.Size = UDim2.new(1, -30, 1, -104)
	tabHolder.Position = UDim2.new(0, 15, 0, 94)
	tabHolder.BackgroundTransparency = 1

	local tabs = {}
	local pages = {}

	local function makeTab(name, order, w)
		local b = Instance.new("TextButton", tabBar)
		b.Size = UDim2.new(0, w or 116, 1, 0)
		b.Position = UDim2.new(0, (order - 1) * ((w or 116) + 6), 0, 0)
		b.BackgroundColor3 = THEME.ROW
		b.Text = name
		b.TextColor3 = THEME.TEXT_DIM
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

		local p = Instance.new("ScrollingFrame", tabHolder)
		p.Size = UDim2.new(1, 0, 1, 0)
		p.BackgroundTransparency = 1
		p.BorderSizePixel = 0
		p.ScrollBarThickness = 4
		p.ScrollBarImageColor3 = THEME.ACCENT
		p.Visible = false
		p.CanvasSize = UDim2.new(0, 0, 0, 900)

		tabs[name] = b
		pages[name] = p
		return p
	end

	makeTab("ESP", 1, 92)
	makeTab("Players", 2, 92)
	makeTab("Movement", 3, 92)
	makeTab("Farm", 4, 92)
	makeTab("Settings", 5, 92)
	makeTab("Aimbot", 6, 92)

	pages["ESP"].Visible = true
	tabs["ESP"].BackgroundColor3 = THEME.ACCENT
	tabs["ESP"].TextColor3 = Color3.new(1, 1, 1)

	local function switchTab(name)
		for n2, b2 in pairs(tabs) do
			b2.BackgroundColor3 = THEME.ROW
			b2.TextColor3 = THEME.TEXT_DIM
			pages[n2].Visible = false
		end
		pages[name].Visible = true
		tabs[name].BackgroundColor3 = THEME.ACCENT
		tabs[name].TextColor3 = Color3.new(1, 1, 1)
		pages[name].Position = UDim2.new(0, 20, 0, 0)
		TweenService:Create(pages[name], TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
	end

	for name, btn in pairs(tabs) do
		btn.MouseButton1Click:Connect(function()
			playClick()
			switchTab(name)
		end)
	end

	local function makeToggle(parent, text, y, key)
		local row = Instance.new("Frame", parent)
		row.Size = UDim2.new(1, -10, 0, 36)
		row.Position = UDim2.new(0, 0, 0, y)
		row.BackgroundColor3 = THEME.ROW
		row.BorderSizePixel = 0
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

		local lbl = Instance.new("TextLabel", row)
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -80, 1, 0)
		lbl.Position = UDim2.new(0, 14, 0, 0)
		lbl.Text = text
		lbl.TextColor3 = THEME.TEXT
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		lbl.TextXAlignment = Enum.TextXAlignment.Left

		local btn = Instance.new("TextButton", row)
		btn.Size = UDim2.new(0, 46, 0, 22)
		btn.Position = UDim2.new(1, -60, 0.5, -11)
		btn.BackgroundColor3 = Config[key] and THEME.ACCENT or THEME.OFF
		btn.Text = ""
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

		local dot = Instance.new("Frame", btn)
		dot.Size = UDim2.new(0, 16, 0, 16)
		dot.Position = Config[key] and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
		dot.BackgroundColor3 = Color3.new(1, 1, 1)
		dot.BorderSizePixel = 0
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

		btn.MouseButton1Click:Connect(function()
			playClick()
			Config[key] = not Config[key]
			local target = Config[key] and THEME.ACCENT or THEME.OFF
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = target}):Play()
			TweenService:Create(dot, TweenInfo.new(0.2), {Position = Config[key] and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)}):Play()
			saveCfgDelayed()
		end)
		return row
	end

	local function makeSlider(parent, text, y, minV, maxV, key, suffix)
		local row = Instance.new("Frame", parent)
		row.Size = UDim2.new(1, -10, 0, 54)
		row.Position = UDim2.new(0, 0, 0, y)
		row.BackgroundColor3 = THEME.ROW
		row.BorderSizePixel = 0
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

		local lbl = Instance.new("TextLabel", row)
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(0.6, 0, 0, 22)
		lbl.Position = UDim2.new(0, 14, 0, 6)
		lbl.Text = text
		lbl.TextColor3 = THEME.TEXT
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left

		local valLbl = Instance.new("TextLabel", row)
		valLbl.BackgroundTransparency = 1
		valLbl.Size = UDim2.new(0.4, -14, 0, 22)
		valLbl.Position = UDim2.new(0.6, 0, 0, 6)
		valLbl.Text = tostring(Config[key]) .. (suffix or "")
		valLbl.TextColor3 = THEME.ACCENT2
		valLbl.Font = Enum.Font.GothamBold
		valLbl.TextSize = 13
		valLbl.TextXAlignment = Enum.TextXAlignment.Right

		local bar = Instance.new("Frame", row)
		bar.Size = UDim2.new(1, -28, 0, 8)
		bar.Position = UDim2.new(0, 14, 0, 36)
		bar.BackgroundColor3 = THEME.OFF
		bar.BorderSizePixel = 0
		Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

		local fill = Instance.new("Frame", bar)
		fill.Size = UDim2.new((Config[key] - minV) / (maxV - minV), 0, 1, 0)
		fill.BackgroundColor3 = THEME.ACCENT
		fill.BorderSizePixel = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

		local dragging = false
		local started = false
		local function setFromX(x)
			local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			local v = math.floor(minV + (maxV - minV) * rel)
			Config[key] = v
			fill.Size = UDim2.new(rel, 0, 1, 0)
			valLbl.Text = tostring(v) .. (suffix or "")
			saveCfgDelayed()
		end

		bar.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				started = false
			end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
				if not started then
					started = true
					playClick()
				end
				setFromX(inp.Position.X)
			end
		end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		return row
	end

	local espPage = pages["ESP"]
	makeToggle(espPage, "Enable ESP", 0, "ESP")
	makeToggle(espPage, "Show Name", 44, "ESPName")
	makeToggle(espPage, "Show Distance", 88, "ESPDistance")
	makeToggle(espPage, "Show Health", 132, "ESPHealth")
	makeToggle(espPage, "Highlight", 176, "ESPHighlight")
	makeToggle(espPage, "Chams (Fill Body)", 220, "ESPChams")
	makeToggle(espPage, "Rainbow Mode", 264, "ESPRainbow")
	makeSlider(espPage, "Max Distance", 314, 1, 10000, "ESPMaxDist", "m")

	local colorRow = Instance.new("Frame", espPage)
	colorRow.Size = UDim2.new(1, -10, 0, 42)
	colorRow.Position = UDim2.new(0, 0, 0, 378)
	colorRow.BackgroundColor3 = THEME.ROW
	colorRow.BorderSizePixel = 0
	Instance.new("UICorner", colorRow).CornerRadius = UDim.new(0, 10)

	local cLbl = Instance.new("TextLabel", colorRow)
	cLbl.BackgroundTransparency = 1
	cLbl.Size = UDim2.new(0.5, 0, 1, 0)
	cLbl.Position = UDim2.new(0, 14, 0, 0)
	cLbl.Text = "ESP Color"
	cLbl.TextColor3 = THEME.TEXT
	cLbl.Font = Enum.Font.Gotham
	cLbl.TextSize = 14
	cLbl.TextXAlignment = Enum.TextXAlignment.Left

	local colorBox = Instance.new("TextButton", colorRow)
	colorBox.Size = UDim2.new(0, 70, 0, 26)
	colorBox.Position = UDim2.new(1, -84, 0.5, -13)
	colorBox.BackgroundColor3 = Config.ESPColor
	colorBox.Text = ""
	colorBox.BorderSizePixel = 0
	colorBox.AutoButtonColor = false
	Instance.new("UICorner", colorBox).CornerRadius = UDim.new(0, 8)

	local picker = Instance.new("Frame", espPage)
	picker.Size = UDim2.new(1, -10, 0, 84)
	picker.Position = UDim2.new(0, 0, 0, 424)
	picker.BackgroundColor3 = THEME.ROW
	picker.BorderSizePixel = 0
	picker.Visible = false
	Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 10)

	local hueBar = Instance.new("Frame", picker)
	hueBar.Size = UDim2.new(1, -20, 0, 14)
	hueBar.Position = UDim2.new(0, 10, 0, 12)
	hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
	hueBar.BorderSizePixel = 0
	Instance.new("UICorner", hueBar).CornerRadius = UDim.new(1, 0)
	local hueGrad = Instance.new("UIGradient", hueBar)
	hueGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	})

	local satBar = Instance.new("Frame", picker)
	satBar.Size = UDim2.new(1, -20, 0, 14)
	satBar.Position = UDim2.new(0, 10, 0, 34)
	satBar.BackgroundColor3 = Color3.new(1, 1, 1)
	satBar.BorderSizePixel = 0
	Instance.new("UICorner", satBar).CornerRadius = UDim.new(1, 0)
	local satGrad = Instance.new("UIGradient", satBar)

	local valBar = Instance.new("Frame", picker)
	valBar.Size = UDim2.new(1, -20, 0, 14)
	valBar.Position = UDim2.new(0, 10, 0, 56)
	valBar.BackgroundColor3 = Color3.new(1, 1, 1)
	valBar.BorderSizePixel = 0
	Instance.new("UICorner", valBar).CornerRadius = UDim.new(1, 0)
	local valGrad = Instance.new("UIGradient", valBar)

	local h, s, v = Config.ESPColor:ToHSV()

	local function updateColor()
		if Config.ESPRainbow then return end
		Config.ESPColor = Color3.fromHSV(h, s, v)
		colorBox.BackgroundColor3 = Config.ESPColor
		satGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
		valGrad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(h, s, 1))
		saveCfgDelayed()
	end
	updateColor()

	local function makeBarDrag(bar, cb)
		local drag = false
		local started = false
		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				drag = true
				started = false
			end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				if not started then
					started = true
					playClick()
				end
				cb(i.Position.X)
			end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				drag = false
			end
		end)
	end

	makeBarDrag(hueBar, function(x)
		if Config.ESPRainbow then return end
		h = math.clamp((x - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
		updateColor()
	end)
	makeBarDrag(satBar, function(x)
		if Config.ESPRainbow then return end
		s = math.clamp((x - satBar.AbsolutePosition.X) / satBar.AbsoluteSize.X, 0, 1)
		updateColor()
	end)
	makeBarDrag(valBar, function(x)
		if Config.ESPRainbow then return end
		v = math.clamp((x - valBar.AbsolutePosition.X) / valBar.AbsoluteSize.X, 0, 1)
		updateColor()
	end)

	colorBox.MouseButton1Click:Connect(function()
		playClick()
		if Config.ESPRainbow then return end
		picker.Visible = not picker.Visible
		espPage.CanvasSize = UDim2.new(0, 0, 0, picker.Visible and 520 or 430)
	end)

	task.spawn(function()
		while gui.Parent do
			if Config.ESPRainbow then
				colorBox.BackgroundColor3 = Config.ESPColor
			end
			task.wait(0.05)
		end
	end)

	local movePage = pages["Movement"]
	makeToggle(movePage, "Enable Speed", 0, "SpeedEnabled")
	makeSlider(movePage, "Walk Speed", 44, 16, 256, "SpeedValue", "")

	local infJumpRow = Instance.new("Frame", movePage)
	infJumpRow.Size = UDim2.new(1, -10, 0, 36)
	infJumpRow.Position = UDim2.new(0, 0, 0, 104)
	infJumpRow.BackgroundColor3 = THEME.ROW
	infJumpRow.BorderSizePixel = 0
	Instance.new("UICorner", infJumpRow).CornerRadius = UDim.new(0, 10)

	local infJumpLbl = Instance.new("TextLabel", infJumpRow)
	infJumpLbl.BackgroundTransparency = 1
	infJumpLbl.Size = UDim2.new(1, -80, 1, 0)
	infJumpLbl.Position = UDim2.new(0, 14, 0, 0)
	infJumpLbl.Text = "Infinite Jump"
	infJumpLbl.TextColor3 = THEME.TEXT
	infJumpLbl.Font = Enum.Font.Gotham
	infJumpLbl.TextSize = 14
	infJumpLbl.TextXAlignment = Enum.TextXAlignment.Left

	local infJumpBtn = Instance.new("TextButton", infJumpRow)
	infJumpBtn.Size = UDim2.new(0, 46, 0, 22)
	infJumpBtn.Position = UDim2.new(1, -60, 0.5, -11)
	infJumpBtn.BackgroundColor3 = Config.InfJump and THEME.ACCENT or THEME.OFF
	infJumpBtn.Text = ""
	infJumpBtn.BorderSizePixel = 0
	infJumpBtn.AutoButtonColor = false
	Instance.new("UICorner", infJumpBtn).CornerRadius = UDim.new(1, 0)

	local infJumpDot = Instance.new("Frame", infJumpBtn)
	infJumpDot.Size = UDim2.new(0, 16, 0, 16)
	infJumpDot.Position = Config.InfJump and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
	infJumpDot.BackgroundColor3 = Color3.new(1, 1, 1)
	infJumpDot.BorderSizePixel = 0
	Instance.new("UICorner", infJumpDot).CornerRadius = UDim.new(1, 0)

	infJumpBtn.MouseButton1Click:Connect(function()
		playClick()
		Config.InfJump = not Config.InfJump
		local target = Config.InfJump and THEME.ACCENT or THEME.OFF
		TweenService:Create(infJumpBtn, TweenInfo.new(0.2), {BackgroundColor3 = target}):Play()
		TweenService:Create(infJumpDot, TweenInfo.new(0.2), {Position = Config.InfJump and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)}):Play()
		saveCfgDelayed()
	end)

	local farmPage = pages["Farm"]
	makeToggle(farmPage, "Enable BodyBag ESP", 0, "BodyBagESP")
	makeToggle(farmPage, "Show Owner", 44, "BodyBagOwner")
	makeToggle(farmPage, "Show Distance", 88, "BodyBagDistance")
	makeSlider(farmPage, "Max Distance", 138, 1, 10000, "BodyBagMaxDist", "m")

	local setPage = pages["Settings"]
	makeToggle(setPage, "Enable Intro", 0, "IntroEnabled")

	local timeLbl = Instance.new("TextLabel", setPage)
	timeLbl.Size = UDim2.new(1, -10, 0, 30)
	timeLbl.BackgroundTransparency = 1
	timeLbl.Text = "World Time"
	timeLbl.TextColor3 = THEME.TEXT
	timeLbl.Font = Enum.Font.GothamBold
	timeLbl.TextSize = 14
	timeLbl.TextXAlignment = Enum.TextXAlignment.Left
	timeLbl.Position = UDim2.new(0, 0, 0, 46)

	local timeBtns = {}

	local function applyTime(mode)
		if mode == "Pink" then
			applyPinkSky()
			return
		end
		removePinkSky()
		if mode == "Day" then
			Lighting.ClockTime = 14
			Lighting.Brightness = 2
			Lighting.FogEnd = 100000
			Lighting.FogStart = 0
			Lighting.Ambient = Color3.fromRGB(70, 70, 70)
			Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		elseif mode == "Night" then
			Lighting.ClockTime = 0
			Lighting.Brightness = 1.5
			Lighting.Ambient = Color3.fromRGB(90, 90, 100)
			Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 120)
			Lighting.FogEnd = 100000
		elseif mode == "Fog" then
			Lighting.ClockTime = 6
			Lighting.Brightness = 1
			Lighting.FogEnd = 60
			Lighting.FogStart = 0
			Lighting.FogColor = Color3.fromRGB(180, 180, 190)
		end
	end

	local function makeTimeBtn(text, x, y, mode)
		local b = Instance.new("TextButton", setPage)
		b.Size = UDim2.new(0, 130, 0, 38)
		b.Position = UDim2.new(0, x, 0, y)
		b.BackgroundColor3 = Config.TimeMode == mode and THEME.ACCENT or THEME.ROW
		b.Text = text
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
		table.insert(timeBtns, {btn = b, mode = mode})

		b.MouseButton1Click:Connect(function()
			playClick()
			Config.TimeMode = mode
			for _, t in pairs(timeBtns) do
				t.btn.BackgroundColor3 = t.mode == mode and THEME.ACCENT or THEME.ROW
			end
			applyTime(mode)
			saveCfgDelayed()
		end)
		return b
	end

	makeTimeBtn("Day", 0, 82, "Day")
	makeTimeBtn("Night", 138, 82, "Night")
	makeTimeBtn("Fog", 276, 82, "Fog")
	makeTimeBtn("Pink Sky", 414, 82, "Pink")

	applyTime(Config.TimeMode)

	local resetBtn = Instance.new("TextButton", setPage)
	resetBtn.Size = UDim2.new(1, -10, 0, 38)
	resetBtn.Position = UDim2.new(0, 0, 0, 130)
	resetBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 110)
	resetBtn.Text = "Reset Config"
	resetBtn.TextColor3 = Color3.new(1, 1, 1)
	resetBtn.Font = Enum.Font.GothamBold
	resetBtn.TextSize = 14
	resetBtn.BorderSizePixel = 0
	resetBtn.AutoButtonColor = false
	Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 10)
	resetBtn.MouseButton1Click:Connect(function()
		playClick()
		Config.ESP = false
		Config.ESPColor = Color3.fromRGB(190, 60, 255)
		Config.ESPRainbow = false
		Config.ESPMaxDist = 5000
		Config.ESPName = true
		Config.ESPDistance = true
		Config.ESPHealth = true
		Config.ESPHighlight = true
		Config.ESPChams = false
		Config.Aimbot = false
		Config.AimSmooth = 15
		Config.AimFOV = 150
		Config.AimPart = "Head"
		Config.AimDrawFOV = true
		Config.AimVisibleCheck = true
		Config.AimTeamCheck = false
		Config.SpeedEnabled = false
		Config.SpeedValue = 50
		Config.InfJump = false
		Config.IntroEnabled = true
		Config.BodyBagESP = false
		Config.BodyBagOwner = true
		Config.BodyBagDistance = true
		Config.BodyBagMaxDist = 5000
		saveCfg()
	end)

	local aimPage = pages["Aimbot"]
	makeToggle(aimPage, "Enable Aimbot", 0, "Aimbot")
	makeToggle(aimPage, "Draw FOV Circle", 44, "AimDrawFOV")
	makeToggle(aimPage, "Visible Check", 88, "AimVisibleCheck")
	makeToggle(aimPage, "Team Check", 132, "AimTeamCheck")
	makeSlider(aimPage, "Aim Smooth", 186, 1, 100, "AimSmooth", "%")
	makeSlider(aimPage, "Aim FOV", 246, 20, 800, "AimFOV", "px")

	local aimPartLbl = Instance.new("TextLabel", aimPage)
	aimPartLbl.Size = UDim2.new(1, -10, 0, 26)
	aimPartLbl.Position = UDim2.new(0, 0, 0, 306)
	aimPartLbl.BackgroundTransparency = 1
	aimPartLbl.Text = "Aim Zone (target part)"
	aimPartLbl.TextColor3 = THEME.TEXT
	aimPartLbl.Font = Enum.Font.GothamBold
	aimPartLbl.TextSize = 13
	aimPartLbl.TextXAlignment = Enum.TextXAlignment.Left

	local aimParts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
	local aimPartBtns = {}

	local function refreshAimPartBtns()
		for _, t in pairs(aimPartBtns) do
			t.btn.BackgroundColor3 = Config.AimPart == t.name and THEME.ACCENT or THEME.ROW
		end
	end

	for i, partName in ipairs(aimParts) do
		local b = Instance.new("TextButton", aimPage)
		b.Size = UDim2.new(0, 140, 0, 34)
		b.Position = UDim2.new(0, ((i - 1) % 4) * 146, 0, 336)
		b.BackgroundColor3 = Config.AimPart == partName and THEME.ACCENT or THEME.ROW
		b.Text = partName
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 12
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
		table.insert(aimPartBtns, {btn = b, name = partName})
		b.MouseButton1Click:Connect(function()
			playClick()
			Config.AimPart = partName
			refreshAimPartBtns()
			saveCfgDelayed()
		end)
	end
	refreshAimPartBtns()

	local playersPage = pages["Players"]

	local searchBox = Instance.new("TextBox", playersPage)
	searchBox.Size = UDim2.new(1, -10, 0, 38)
	searchBox.Position = UDim2.new(0, 0, 0, 0)
	searchBox.BackgroundColor3 = THEME.ROW
	searchBox.BorderSizePixel = 0
	searchBox.PlaceholderText = "Search player..."
	searchBox.PlaceholderColor3 = THEME.TEXT_DIM
	searchBox.Text = ""
	searchBox.TextColor3 = THEME.TEXT
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 14
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus = false
	Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 10)
	local sp = Instance.new("UIPadding", searchBox)
	sp.PaddingLeft = UDim.new(0, 12)

	local playerList = Instance.new("Frame", playersPage)
	playerList.Size = UDim2.new(1, -10, 0, 780)
	playerList.Position = UDim2.new(0, 0, 0, 48)
	playerList.BackgroundTransparency = 1

	local listLayout = Instance.new("UIListLayout", playerList)
	listLayout.Padding = UDim.new(0, 6)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local playerRows = {}

	local function fetchAvatar(userId)
		local ok, img = pcall(function()
			return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok then return img end
		return "rbxassetid://0"
	end

	local function buildRow(plr)
		if playerRows[plr] then return end
		local row = Instance.new("Frame", playerList)
		row.Size = UDim2.new(1, 0, 0, 60)
		row.BackgroundColor3 = THEME.ROW
		row.BorderSizePixel = 0
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
		local rs = Instance.new("UIStroke", row)
		rs.Color = THEME.ACCENT
		rs.Thickness = 1
		rs.Transparency = 1

		local avatar = Instance.new("ImageLabel", row)
		avatar.Size = UDim2.new(0, 44, 0, 44)
		avatar.Position = UDim2.new(0, 8, 0.5, -22)
		avatar.BackgroundColor3 = THEME.PANEL
		avatar.BorderSizePixel = 0
		avatar.Image = "rbxassetid://0"
		Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
		task.spawn(function()
			avatar.Image = fetchAvatar(plr.UserId)
		end)

		local nameLbl = Instance.new("TextLabel", row)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Size = UDim2.new(0.5, 0, 0, 18)
		nameLbl.Position = UDim2.new(0, 60, 0, 8)
		nameLbl.Text = plr.Name
		nameLbl.TextColor3 = THEME.TEXT
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextSize = 14
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left

		local dispLbl = Instance.new("TextLabel", row)
		dispLbl.BackgroundTransparency = 1
		dispLbl.Size = UDim2.new(0.5, 0, 0, 16)
		dispLbl.Position = UDim2.new(0, 60, 0, 26)
		dispLbl.Text = "@" .. plr.DisplayName
		dispLbl.TextColor3 = THEME.TEXT_DIM
		dispLbl.Font = Enum.Font.Gotham
		dispLbl.TextSize = 12
		dispLbl.TextXAlignment = Enum.TextXAlignment.Left

		local hpBarBg = Instance.new("Frame", row)
		hpBarBg.Size = UDim2.new(0, 160, 0, 6)
		hpBarBg.Position = UDim2.new(0, 60, 0, 46)
		hpBarBg.BackgroundColor3 = THEME.OFF
		hpBarBg.BorderSizePixel = 0
		Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(1, 0)

		local hpBar = Instance.new("Frame", hpBarBg)
		hpBar.Size = UDim2.new(1, 0, 1, 0)
		hpBar.BackgroundColor3 = THEME.GREEN
		hpBar.BorderSizePixel = 0
		Instance.new("UICorner", hpBar).CornerRadius = UDim.new(1, 0)

		local hpLbl = Instance.new("TextLabel", row)
		hpLbl.BackgroundTransparency = 1
		hpLbl.Size = UDim2.new(0, 90, 0, 16)
		hpLbl.Position = UDim2.new(0, 226, 0, 40)
		hpLbl.Text = "100 HP"
		hpLbl.TextColor3 = THEME.GREEN
		hpLbl.Font = Enum.Font.GothamBold
		hpLbl.TextSize = 12
		hpLbl.TextXAlignment = Enum.TextXAlignment.Left

		local distLbl = Instance.new("TextLabel", row)
		distLbl.BackgroundTransparency = 1
		distLbl.Size = UDim2.new(0, 70, 0, 16)
		distLbl.Position = UDim2.new(0, 310, 0, 40)
		distLbl.Text = "0 m"
		distLbl.TextColor3 = THEME.ACCENT2
		distLbl.Font = Enum.Font.GothamBold
		distLbl.TextSize = 12
		distLbl.TextXAlignment = Enum.TextXAlignment.Left

		local tpBtn = Instance.new("TextButton", row)
		tpBtn.Size = UDim2.new(0, 90, 0, 30)
		tpBtn.Position = UDim2.new(1, -100, 0.5, -15)
		tpBtn.BackgroundColor3 = THEME.ACCENT
		tpBtn.Text = "Teleport"
		tpBtn.TextColor3 = Color3.new(1, 1, 1)
		tpBtn.Font = Enum.Font.GothamBold
		tpBtn.TextSize = 12
		tpBtn.BorderSizePixel = 0
		tpBtn.AutoButtonColor = false
		Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 8)

		tpBtn.MouseButton1Click:Connect(function()
			playClick()
			local myChar = LP.Character
			if not myChar then return end
			local myHrp = myChar:FindFirstChild("HumanoidRootPart")
			if not myHrp then return end
			local targetChar = plr.Character
			if not targetChar then return end
			local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
			if not targetHrp then return end
			myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
			myHrp.AssemblyLinearVelocity = Vector3.zero
			myHrp.AssemblyAngularVelocity = Vector3.zero
		end)

		row.MouseEnter:Connect(function()
			TweenService:Create(rs, TweenInfo.new(0.15), {Transparency = 0.4}):Play()
		end)
		row.MouseLeave:Connect(function()
			TweenService:Create(rs, TweenInfo.new(0.15), {Transparency = 1}):Play()
		end)

		playerRows[plr] = {
			row = row,
			name = plr.Name,
			display = plr.DisplayName,
			hpBar = hpBar,
			hpLbl = hpLbl,
			distLbl = distLbl,
		}
	end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP then buildRow(plr) end
	end

	Players.PlayerAdded:Connect(function(plr)
		if plr ~= LP then
			task.wait(0.5)
			buildRow(plr)
		end
	end)

	Players.PlayerRemoving:Connect(function(plr)
		if playerRows[plr] then
			playerRows[plr].row:Destroy()
			playerRows[plr] = nil
		end
	end)

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = string.lower(searchBox.Text)
		for _, data in pairs(playerRows) do
			local match = q == "" or string.find(string.lower(data.name), q, 1, true) or string.find(string.lower(data.display), q, 1, true)
			data.row.Visible = match
		end
	end)

	task.spawn(function()
		while gui.Parent do
			for plr, data in pairs(playerRows) do
				if plr.Parent and plr.Character then
					local hum = plr.Character:FindFirstChildOfClass("Humanoid")
					local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
					if hum and hrp and hum.Health > 0 then
						local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
						data.hpBar.Size = UDim2.new(ratio, 0, 1, 0)
						local col = ratio > 0.5 and THEME.GREEN or (ratio > 0.25 and Color3.fromRGB(255, 200, 60) or THEME.RED)
						data.hpBar.BackgroundColor3 = col
						data.hpLbl.Text = math.floor(hum.Health) .. " HP"
						data.hpLbl.TextColor3 = col
						local d = (Camera.CFrame.Position - hrp.Position).Magnitude
						data.distLbl.Text = math.floor(d) .. " m"
					else
						data.hpBar.Size = UDim2.new(1, 0, 1, 0)
						data.hpBar.BackgroundColor3 = THEME.OFF
						data.hpLbl.Text = "dead"
						data.hpLbl.TextColor3 = THEME.TEXT_DIM
						data.distLbl.Text = "-"
					end
				else
					data.hpBar.Size = UDim2.new(1, 0, 1, 0)
					data.hpBar.BackgroundColor3 = THEME.OFF
					data.hpLbl.Text = "offline"
					data.hpLbl.TextColor3 = THEME.TEXT_DIM
					data.distLbl.Text = "-"
				end
			end
			task.wait(0.2)
		end
	end)

	task.spawn(function()
		local frameTimes = {}
		local fpsConn = RunService.RenderStepped:Connect(function(dt)
			table.insert(frameTimes, dt)
			if #frameTimes > 60 then
				table.remove(frameTimes, 1)
			end
		end)
		registerCleanup(function()
			if fpsConn then fpsConn:Disconnect() end
		end)

		while gui.Parent do
			local avgDt = 0
			for _, t in ipairs(frameTimes) do
				avgDt = avgDt + t
			end
			if #frameTimes > 0 then
				avgDt = avgDt / #frameTimes
			end
			local fps = avgDt > 0 and math.floor(1 / avgDt) or 0

			local ping = 0
			pcall(function()
				local pingStat = Stats.Network.ServerStatsItem["Data Ping"]
				if pingStat then
					ping = math.floor(pingStat:GetValue())
				end
			end)

			pingLbl.Text = "PING: " .. ping .. "ms"
			fpsLbl.Text = "FPS: " .. fps

			pingLbl.TextColor3 = THEME.GREEN
			fpsLbl.TextColor3 = THEME.GREEN

			task.wait(0.5)
		end
	end)

	local dragging, dragStart, startPos
	top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	local menuOpen = false
	local function openMenu()
		menuOpen = true
		main.Visible = true
		main.Size = UDim2.new(0, 500, 0, 360)
		TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 640, 0, 440)
		}):Play()
	end
	local function closeMenu()
		menuOpen = false
		TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 500, 0, 360)
		}):Play()
		task.delay(0.2, function()
			if not menuOpen then main.Visible = false end
		end)
	end

	openBtn.MouseButton1Click:Connect(function()
		playClick()
		if menuOpen then closeMenu() else openMenu() end
	end)
	closeBtn.MouseButton1Click:Connect(function()
		playClick()
		closeMenu()
	end)

	task.wait(0.05)
	openMenu()

	return gui
end

local espObjects = {}

local function createESP(plr)
	if plr == LP then return end
	if espObjects[plr] then
		pcall(function()
			if espObjects[plr].bb then espObjects[plr].bb:Destroy() end
			if espObjects[plr].highlight then espObjects[plr].highlight:Destroy() end
		end)
		espObjects[plr] = nil
	end

	local bb = Instance.new("BillboardGui")
	bb.Name = "QVIZI_ESP"
	bb.Size = UDim2.new(0, 200, 0, 72)
	bb.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.MaxDistance = 5000
	bb.Adornee = nil
	bb.Enabled = false
	bb.Parent = LP:WaitForChild("PlayerGui")

	local nameLbl = Instance.new("TextLabel", bb)
	nameLbl.Size = UDim2.new(1, 0, 0, 22)
	nameLbl.Position = UDim2.new(0, 0, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = ""
	nameLbl.TextColor3 = Config.ESPColor
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextSize = 16
	nameLbl.TextStrokeTransparency = 0
	nameLbl.TextStrokeColor3 = Color3.new(0, 0, 0)

	local hpLbl = Instance.new("TextLabel", bb)
	hpLbl.Size = UDim2.new(1, 0, 0, 22)
	hpLbl.Position = UDim2.new(0, 0, 0, 24)
	hpLbl.BackgroundTransparency = 1
	hpLbl.Text = ""
	hpLbl.TextColor3 = Color3.fromRGB(0, 255, 80)
	hpLbl.Font = Enum.Font.GothamBold
	hpLbl.TextSize = 16
	hpLbl.TextStrokeTransparency = 0
	hpLbl.TextStrokeColor3 = Color3.new(0, 0, 0)

	local distLbl = Instance.new("TextLabel", bb)
	distLbl.Size = UDim2.new(1, 0, 0, 22)
	distLbl.Position = UDim2.new(0, 0, 0, 48)
	distLbl.BackgroundTransparency = 1
	distLbl.Text = ""
	distLbl.TextColor3 = Config.ESPColor
	distLbl.Font = Enum.Font.GothamBold
	distLbl.TextSize = 16
	distLbl.TextStrokeTransparency = 0
	distLbl.TextStrokeColor3 = Color3.new(0, 0, 0)

	local highlight = Instance.new("Highlight")
	highlight.Name = "QVIZI_HL"
	highlight.FillColor = THEME.ACCENT
	highlight.OutlineColor = THEME.ACCENT
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Adornee = nil
	highlight.Enabled = false
	highlight.Parent = LP:WaitForChild("PlayerGui")

	espObjects[plr] = {
		bb = bb,
		name = nameLbl,
		hp = hpLbl,
		dist = distLbl,
		highlight = highlight,
	}
end

local function removeESP(plr)
	if espObjects[plr] then
		pcall(function() espObjects[plr].bb:Destroy() end)
		pcall(function() espObjects[plr].highlight:Destroy() end)
		espObjects[plr] = nil
	end
end

registerCleanup(function()
	for plr, _ in pairs(espObjects) do
		removeESP(plr)
	end
end)

Players.PlayerAdded:Connect(function(plr)
	task.wait(0.5)
	createESP(plr)
end)

for _, p in pairs(Players:GetPlayers()) do createESP(p) end

Players.PlayerRemoving:Connect(removeESP)

local bodyBagObjects = {}

local function isBodyBag(inst)
	if not inst or not inst:IsA("Model") then return false end
	local n = string.lower(inst.Name)
	return string.find(n, "bodybag", 1, true) ~= nil
end

local function getOwnerName(inst)
	local nameAttr = inst:GetAttribute("PlayerName")
	if nameAttr and type(nameAttr) == "string" and nameAttr ~= "" then
		return nameAttr
	end
	nameAttr = inst:GetAttribute("playerName")
	if nameAttr and type(nameAttr) == "string" and nameAttr ~= "" then
		return nameAttr
	end
	nameAttr = inst:GetAttribute("Owner")
	if nameAttr and type(nameAttr) == "string" and nameAttr ~= "" then
		return nameAttr
	end

	local direct = inst:FindFirstChild("PlayerName")
	if direct and direct:IsA("StringValue") and direct.Value ~= "" then
		return direct.Value
	end
	direct = inst:FindFirstChild("Owner")
	if direct and direct:IsA("StringValue") and direct.Value ~= "" then
		return direct.Value
	end

	for _, d in ipairs(inst:GetChildren()) do
		if d:IsA("StringValue") and d.Value ~= "" then
			return d.Value
		end
		if d:IsA("ObjectValue") and d.Value then
			return d.Value.Name
		end
	end

	for _, d in ipairs(inst:GetDescendants()) do
		if d:IsA("StringValue") then
			local dn = string.lower(d.Name)
			if dn == "playername" or dn == "owner" or dn == "player" or dn == "username" then
				if d.Value ~= "" then return d.Value end
			end
		end
		if d:IsA("ObjectValue") then
			local dn = string.lower(d.Name)
			if dn == "playername" or dn == "owner" or dn == "player" then
				if d.Value then return d.Value.Name end
			end
		end
	end

	return nil
end

local function getBodyBagPosition(inst)
	local primary = inst.PrimaryPart
	if primary then return primary.Position end
	local hrp = inst:FindFirstChild("HumanoidRootPart")
	if hrp then return hrp.Position end
	local torso = inst:FindFirstChild("Torso") or inst:FindFirstChild("UpperTorso")
	if torso then return torso.Position end
	local head = inst:FindFirstChild("Head")
	if head then return head.Position end
	local part = inst:FindFirstChildWhichIsA("BasePart")
	if part then return part.Position end
	return nil
end

local function getBodyBagAdornee(inst)
	local primary = inst.PrimaryPart
	if primary then return primary end
	local hrp = inst:FindFirstChild("HumanoidRootPart")
	if hrp then return hrp end
	local head = inst:FindFirstChild("Head")
	if head then return head end
	local torso = inst:FindFirstChild("Torso") or inst:FindFirstChild("UpperTorso")
	if torso then return torso end
	return inst:FindFirstChildWhichIsA("BasePart")
end

local function createBodyBagESP(inst)
	if bodyBagObjects[inst] then return end
	if not isBodyBag(inst) then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = "QVIZI_BodyBag"
	bb.Size = UDim2.new(0, 200, 0, 50)
	bb.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.MaxDistance = 5000
	bb.Enabled = false
	bb.Parent = LP:WaitForChild("PlayerGui")

	local ownerLbl = Instance.new("TextLabel", bb)
	ownerLbl.Size = UDim2.new(1, 0, 0, 22)
	ownerLbl.Position = UDim2.new(0, 0, 0, 0)
	ownerLbl.BackgroundTransparency = 1
	ownerLbl.Text = ""
	ownerLbl.TextColor3 = Color3.fromRGB(255, 90, 200)
	ownerLbl.Font = Enum.Font.GothamBold
	ownerLbl.TextSize = 15
	ownerLbl.TextStrokeTransparency = 0
	ownerLbl.TextStrokeColor3 = Color3.new(0, 0, 0)

	local distLbl = Instance.new("TextLabel", bb)
	distLbl.Size = UDim2.new(1, 0, 0, 18)
	distLbl.Position = UDim2.new(0, 0, 0, 24)
	distLbl.BackgroundTransparency = 1
	distLbl.Text = ""
	distLbl.TextColor3 = Color3.fromRGB(190, 60, 255)
	distLbl.Font = Enum.Font.GothamBold
	distLbl.TextSize = 14
	distLbl.TextStrokeTransparency = 0
	distLbl.TextStrokeColor3 = Color3.new(0, 0, 0)

	local highlight = Instance.new("Highlight")
	highlight.Name = "QVIZI_BodyBagHL"
	highlight.FillColor = Color3.fromRGB(255, 90, 200)
	highlight.OutlineColor = Color3.fromRGB(190, 60, 255)
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Adornee = nil
	highlight.Enabled = false
	highlight.Parent = LP:WaitForChild("PlayerGui")

	bodyBagObjects[inst] = {
		bb = bb,
		ownerLbl = ownerLbl,
		distLbl = distLbl,
		highlight = highlight,
		cachedOwner = nil,
		lastOwnerCheck = 0,
	}
end

local function removeBodyBagESP(inst)
	if bodyBagObjects[inst] then
		pcall(function() bodyBagObjects[inst].bb:Destroy() end)
		pcall(function() bodyBagObjects[inst].highlight:Destroy() end)
		bodyBagObjects[inst] = nil
	end
end

local scanRunning = false
local lastScan = 0

local function scanBodyBags()
	if scanRunning then return end
	local now = tick()
	if now - lastScan < 1 then return end
	lastScan = now
	scanRunning = true

	task.spawn(function()
		pcall(function()
			for _, inst in ipairs(workspace:GetDescendants()) do
				if isBodyBag(inst) then
					createBodyBagESP(inst)
				end
			end
		end)
		scanRunning = false
	end)
end

scanBodyBags()

local descAddedConn = workspace.DescendantAdded:Connect(function(inst)
	if not isBodyBag(inst) then return end
	task.defer(function()
		createBodyBagESP(inst)
	end)
end)

local descRemovedConn = workspace.DescendantRemoving:Connect(function(inst)
	if bodyBagObjects[inst] then
		removeBodyBagESP(inst)
	end
end)

registerCleanup(function()
	if descAddedConn then descAddedConn:Disconnect() end
	if descRemovedConn then descRemovedConn:Disconnect() end
end)

task.spawn(function()
	while _G.QVIZI_LOADED do
		task.wait(3)
		scanBodyBags()
	end
end)

registerCleanup(function()
	for inst, _ in pairs(bodyBagObjects) do
		removeBodyBagESP(inst)
	end
end)

local function isVisible(targetChar)
	if not targetChar then return false end
	local head = targetChar:FindFirstChild("Head")
	if not head then return false end
	local origin = Camera.CFrame.Position
	local dir = head.Position - origin
	local params = RaycastParams.new()
	local filter = {}
	if LP.Character then table.insert(filter, LP.Character) end
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then table.insert(filter, p.Character) end
	end
	params.FilterDescendantsInstances = filter
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(origin, dir, params)
	return result == nil
end

local function getAimPart(char)
	local part = char:FindFirstChild(Config.AimPart)
	if part then return part end
	if Config.AimPart == "UpperTorso" or Config.AimPart == "LowerTorso" then
		return char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
	end
	return char:FindFirstChild("HumanoidRootPart")
end

local function isSameTeam(plr)
	if not Config.AimTeamCheck then return false end
	if not plr.Team or not LP.Team then return false end
	return plr.Team == LP.Team
end

local function getAimTarget()
	local closest = nil
	local shortest = math.huge
	local fovPx = Config.AimFOV
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 and not isSameTeam(plr) then
				local part = getAimPart(plr.Character)
				if part then
					local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
						if dist < shortest and dist <= fovPx then
							if (not Config.AimVisibleCheck) or isVisible(plr.Character) then
								shortest = dist
								closest = part
							end
						end
					end
				end
			end
		end
	end
	return closest
end

RunService:BindToRenderStep("QVIZI_AIM", Enum.RenderPriority.Camera.Value + 1, function()
	if not Config.Aimbot then return end
	local target = getAimTarget()
	if not target then return end
	local smooth = math.clamp(1 - (Config.AimSmooth / 100), 0.01, 1)
	local currentCF = Camera.CFrame
	local targetCF = CFrame.new(currentCF.Position, target.Position)
	Camera.CFrame = currentCF:Lerp(targetCF, smooth)
end)

registerCleanup(function()
	pcall(function()
		RunService:UnbindFromRenderStep("QVIZI_AIM")
	end)
end)

local renderConn = RunService.RenderStepped:Connect(function()
	for plr, objs in pairs(espObjects) do
		local char = plr.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		local head = char and char:FindFirstChild("Head")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local ready = humanoid and head and hrp and humanoid.Health > 0

		if Config.ESP and ready then
			local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
			if distance <= Config.ESPMaxDist then
				objs.bb.Adornee = head
				objs.bb.Enabled = true

				if Config.ESPName then
					objs.name.Visible = true
					objs.name.Text = plr.Name
					objs.name.TextColor3 = Config.ESPColor
				else
					objs.name.Visible = false
				end

				if Config.ESPHealth then
					objs.hp.Visible = true
					local hpRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
					objs.hp.Text = string.format("HP: %d", math.floor(humanoid.Health))
					if hpRatio > 0.5 then
						objs.hp.TextColor3 = Color3.fromRGB(0, 255, 80)
					elseif hpRatio > 0.25 then
						objs.hp.TextColor3 = Color3.fromRGB(255, 200, 60)
					else
						objs.hp.TextColor3 = Color3.fromRGB(255, 60, 80)
					end
				else
					objs.hp.Visible = false
				end

				if Config.ESPDistance then
					objs.dist.Visible = true
					objs.dist.Text = string.format("%dm", math.floor(distance))
					objs.dist.TextColor3 = Config.ESPColor
				else
					objs.dist.Visible = false
				end

				if Config.ESPHighlight or Config.ESPChams then
					objs.highlight.Adornee = char
					objs.highlight.Enabled = true
					objs.highlight.FillColor = Config.ESPColor
					objs.highlight.OutlineColor = Config.ESPColor
					if Config.ESPChams then
						objs.highlight.FillTransparency = 0.3
						objs.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					else
						objs.highlight.FillTransparency = 0.75
						objs.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					end
				else
					objs.highlight.Enabled = false
				end
			else
				objs.bb.Enabled = false
				objs.highlight.Enabled = false
			end
		else
			objs.bb.Enabled = false
			objs.highlight.Enabled = false
		end
	end

	for inst, objs in pairs(bodyBagObjects) do
		if not inst.Parent then
			removeBodyBagESP(inst)
			continue
		end

		if not Config.BodyBagESP then
			if objs.bb.Enabled then
				objs.bb.Enabled = false
				objs.highlight.Enabled = false
			end
			continue
		end

		local pos = getBodyBagPosition(inst)
		local adornee = getBodyBagAdornee(inst)

		if pos and adornee then
			local distance = (Camera.CFrame.Position - pos).Magnitude
			if distance <= Config.BodyBagMaxDist then
				objs.bb.Adornee = adornee
				objs.bb.Enabled = true

				if Config.BodyBagOwner then
					local now = tick()
					if now - objs.lastOwnerCheck > 5 or not objs.cachedOwner then
						objs.cachedOwner = getOwnerName(inst)
						objs.lastOwnerCheck = now
					end
					objs.ownerLbl.Visible = true
					if objs.cachedOwner then
						objs.ownerLbl.Text = objs.cachedOwner
					else
						objs.ownerLbl.Text = "BodyBag"
					end
				else
					objs.ownerLbl.Visible = false
				end

				if Config.BodyBagDistance then
					objs.distLbl.Visible = true
					objs.distLbl.Text = string.format("%dm", math.floor(distance))
				else
					objs.distLbl.Visible = false
				end

				objs.highlight.Adornee = inst
				objs.highlight.Enabled = true
				objs.highlight.FillColor = Color3.fromRGB(255, 90, 200)
				objs.highlight.OutlineColor = Color3.fromRGB(190, 60, 255)
			else
				objs.bb.Enabled = false
				objs.highlight.Enabled = false
			end
		else
			objs.bb.Enabled = false
			objs.highlight.Enabled = false
		end
	end

	if fovCircle then
		if Config.Aimbot and Config.AimDrawFOV then
			fovCircle.Visible = true
			local d = Config.AimFOV * 2
			fovCircle.Size = UDim2.new(0, d, 0, d)
			fovStroke.Color = Config.ESPColor
		else
			fovCircle.Visible = false
		end
	end

	local char = LP.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			if Config.SpeedEnabled then
				if hum.WalkSpeed ~= Config.SpeedValue then
					hum.WalkSpeed = Config.SpeedValue
				end
			else
				if hum.WalkSpeed ~= DEFAULT_SPEED then
					hum.WalkSpeed = DEFAULT_SPEED
				end
			end
		end
	end
end)

registerCleanup(function()
	if renderConn then renderConn:Disconnect() end
end)

local jumpConn = UserInputService.JumpRequest:Connect(function()
	if Config.InfJump then
		local char = LP.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

registerCleanup(function()
	if jumpConn then jumpConn:Disconnect() end
end)

local charConn = LP.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Config.SpeedEnabled and Config.SpeedValue or DEFAULT_SPEED
	end
	for plr, _ in pairs(espObjects) do
		if plr == LP then
			removeESP(plr)
		end
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LP then
			createESP(p)
		end
	end
end)

registerCleanup(function()
	if charConn then charConn:Disconnect() end
end)

task.spawn(function()
	if Config.IntroEnabled then
		playIntro()
	end
	task.wait(0.2)
	createMenu()
end)
