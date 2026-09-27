local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LP = Players.LocalPlayer

local VERSION = "V1.5"

local THEME = {
	ACCENT = Color3.fromRGB(190, 60, 255),
	ACCENT2 = Color3.fromRGB(255, 90, 200),
	TEXT = Color3.fromRGB(240, 225, 250),
	TEXT_DIM = Color3.fromRGB(160, 130, 185),
	ROW = Color3.fromRGB(28, 14, 40),
}

local INTRO_SOUND = "rbxassetid://6350854289"

local function playIntro()
	local introSound = Instance.new("Sound")
	introSound.SoundId = INTRO_SOUND
	introSound.Volume = 0.35
	introSound.Parent = SoundService
	introSound:Play()

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
	credit.Text = "By: t.me/QviziHub"
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
	pcall(function() introSound:Destroy() end)
end

local function playKickScreen()
	local gui = Instance.new("ScreenGui")
	gui.Name = "QVIZI_Kick"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 9999
	gui.Parent = LP:WaitForChild("PlayerGui")

	local bg = Instance.new("Frame", gui)
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.new(0, 0, 0)
	bg.BorderSizePixel = 0

	local line1 = Instance.new("TextLabel", bg)
	line1.Size = UDim2.new(1, 0, 0, 50)
	line1.Position = UDim2.new(0, 0, 0.5, -100)
	line1.BackgroundTransparency = 1
	line1.Text = "You have been kicked from this experience."
	line1.TextColor3 = Color3.fromRGB(240, 240, 240)
	line1.Font = Enum.Font.Gotham
	line1.TextSize = 22
	line1.TextTransparency = 1

	local line2 = Instance.new("TextLabel", bg)
	line2.Size = UDim2.new(1, 0, 0, 40)
	line2.Position = UDim2.new(0, 0, 0.5, -50)
	line2.BackgroundTransparency = 1
	line2.Text = ""
	line2.TextColor3 = Color3.fromRGB(180, 180, 180)
	line2.Font = Enum.Font.Gotham
	line2.TextSize = 16
	line2.TextTransparency = 1

	local line3 = Instance.new("TextLabel", bg)
	line3.Size = UDim2.new(1, 0, 0, 40)
	line3.Position = UDim2.new(0, 0, 0.5, 0)
	line3.BackgroundTransparency = 1
	line3.Text = "Reason: Using cheats / exploits is not allowed."
	line3.TextColor3 = Color3.fromRGB(255, 80, 80)
	line3.Font = Enum.Font.GothamBold
	line3.TextSize = 18
	line3.TextTransparency = 1

	local line4 = Instance.new("TextLabel", bg)
	line4.Size = UDim2.new(1, 0, 0, 60)
	line4.Position = UDim2.new(0, 0, 0.5, 50)
	line4.BackgroundTransparency = 1
	line4.Text = "Cheating ruins the game for everyone.\nPlay fair."
	line4.TextColor3 = Color3.fromRGB(200, 200, 200)
	line4.Font = Enum.Font.Gotham
	line4.TextSize = 16
	line4.TextTransparency = 1
	line4.TextWrapped = true

	TweenService:Create(line1, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
	task.wait(0.3)
	TweenService:Create(line2, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
	task.wait(0.3)
	TweenService:Create(line3, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
	task.wait(0.3)
	TweenService:Create(line4, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
	task.wait(2.5)
end

local function showKickReasonBox()
	local gui = Instance.new("ScreenGui")
	gui.Name = "QVIZI_KickBox"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 10000
	gui.Parent = LP:WaitForChild("PlayerGui")

	local dim = Instance.new("Frame", gui)
	dim.Size = UDim2.new(1, 0, 1, 0)
	dim.BackgroundColor3 = Color3.new(0, 0, 0)
	dim.BackgroundTransparency = 0.4
	dim.BorderSizePixel = 0

	local box = Instance.new("Frame", dim)
	box.Size = UDim2.new(0, 500, 0, 300)
	box.Position = UDim2.new(0.5, -250, 0.5, -150)
	box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	box.BorderSizePixel = 0
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)

	local header = Instance.new("TextLabel", box)
	header.Size = UDim2.new(1, -40, 0, 40)
	header.Position = UDim2.new(0, 20, 0, 15)
	header.BackgroundTransparency = 1
	header.Text = "Disconnected"
	header.TextColor3 = Color3.fromRGB(255, 80, 80)
	header.Font = Enum.Font.GothamBold
	header.TextSize = 22
	header.TextXAlignment = Enum.TextXAlignment.Left

	local divider = Instance.new("Frame", box)
	divider.Size = UDim2.new(1, -40, 0, 1)
	divider.Position = UDim2.new(0, 20, 0, 60)
	divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	divider.BorderSizePixel = 0

	local body = Instance.new("TextLabel", box)
	body.Size = UDim2.new(1, -40, 0, 180)
	body.Position = UDim2.new(0, 20, 0, 75)
	body.BackgroundTransparency = 1
	body.Text = "You have been kicked from this experience.\n\nReason: Exploiting / Cheating is strictly prohibited.\n\nWe detected unauthorized modifications to your client. Cheating ruins the game for other players and violates the Roblox Terms of Service.\n\nPlay fair. Stay legit."
	body.TextColor3 = Color3.fromRGB(220, 220, 220)
	body.Font = Enum.Font.Gotham
	body.TextSize = 15
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", box)
	btn.Size = UDim2.new(0, 140, 0, 36)
	btn.Position = UDim2.new(1, -160, 1, -50)
	btn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
	btn.Text = "OK"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 15
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	box.Size = UDim2.new(0, 0, 0, 0)
	box.Position = UDim2.new(0.5, 0, 0.5, 0)
	TweenService:Create(box, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 500, 0, 300),
		Position = UDim2.new(0.5, -250, 0.5, -150)
	}):Play()

	btn.MouseButton1Click:Connect(function()
		pcall(function()
			LP:Kick("You have been kicked from this experience.\n\nReason: Cheating / Exploiting is not allowed.\n\nWe detected unauthorized modifications to your client.\n\nCheating ruins the game for everyone. Play fair.")
		end)
	end)

	task.wait(5)
	pcall(function()
		LP:Kick("You have been kicked from this experience.\n\nReason: Cheating / Exploiting is not allowed.\n\nWe detected unauthorized modifications to your client.\n\nCheating ruins the game for everyone. Play fair.")
	end)
end

local function runTrollSequence()
	task.wait(0.3)

	local fakeLoading = Instance.new("ScreenGui")
	fakeLoading.Name = "QVIZI_FakeLoading"
	fakeLoading.IgnoreGuiInset = true
	fakeLoading.ResetOnSpawn = false
	fakeLoading.DisplayOrder = 9998
	fakeLoading.Parent = LP:WaitForChild("PlayerGui")

	local flBg = Instance.new("Frame", fakeLoading)
	flBg.Size = UDim2.new(1, 0, 1, 0)
	flBg.BackgroundColor3 = Color3.new(0, 0, 0)
	flBg.BackgroundTransparency = 1
	flBg.BorderSizePixel = 0

	local flText = Instance.new("TextLabel", flBg)
	flText.Size = UDim2.new(1, 0, 0, 40)
	flText.Position = UDim2.new(0, 0, 0.5, -20)
	flText.BackgroundTransparency = 1
	flText.Text = "Injecting script..."
	flText.TextColor3 = Color3.fromRGB(0, 255, 100)
	flText.Font = Enum.Font.Code
	flText.TextSize = 20
	flText.TextTransparency = 1

	TweenService:Create(flText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	task.wait(1.2)

	flText.Text = "Bypassing anti-cheat..."
	task.wait(1.0)
	flText.Text = "Connecting to server..."
	task.wait(0.8)
	flText.Text = "Access granted ✓"
	flText.TextColor3 = Color3.fromRGB(0, 255, 100)
	task.wait(0.6)

	TweenService:Create(flText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
	task.wait(0.4)
	pcall(function() fakeLoading:Destroy() end)

	task.wait(0.2)
	playKickScreen()
	task.wait(0.3)
	showKickReasonBox()
end

task.spawn(function()
	playIntro()
	runTrollSequence()
end)
