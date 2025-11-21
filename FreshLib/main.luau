local FreshLib = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

getgenv().FreshOptions = getgenv().FreshOptions or {}
local Options = getgenv().FreshOptions

local ConfigFolder = "FreshLib_Config"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

local function MakeDraggable(topbar, object)
	local dragging, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			local delta = input.Position - dragStart
			object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function FreshLib:Window(cfg)
	cfg = cfg or {}
	local Title = cfg.Name or "Fresh UI"
	local ConfigName = cfg.Config or "default"

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(0, 470, 0, 280)
	MainFrame.Position = UDim2.new(0.5, -235, 0.5, -140)
	MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 35)

	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(0, 388, 0, 34)
	TopBar.Position = UDim2.new(0, 10, 0, 2)
	TopBar.BackgroundColor3 = Color3.fromRGB(97, 97, 97)
	TopBar.Parent = MainFrame
	Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 35)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(0, 200, 1, 0)
	TitleLabel.Position = UDim2.new(0, 4, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = Title
	TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
	TitleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
	TitleLabel.TextSize = 36
	TitleLabel.Parent = TopBar

	local CloseBtn = Instance.new("Frame")
	CloseBtn.Size = UDim2.new(0, 26, 0, 24)
	CloseBtn.Position = UDim2.new(0, 400, 0, 12)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	CloseBtn.Parent = MainFrame
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 35)
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

	local MinimizeBtn = Instance.new("Frame")
	MinimizeBtn.Size = UDim2.new(0, 26, 0, 22)
	MinimizeBtn.Position = UDim2.new(0, 430, 0, 12)
	MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 61)
	MinimizeBtn.Parent = MainFrame
	Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 35)

	local minimized = false
	MinimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		MainFrame:TweenSize(minimized and UDim2.new(0,470,0,40) or UDim2.new(0,470,0,280), "Out", "Quad", 0.3, true)
	end)

	MakeDraggable(TopBar, MainFrame)

	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(0, 108, 0, 236)
	TabContainer.Position = UDim2.new(0, 12, 0, 44)
	TabContainer.BackgroundTransparency = 1
	TabContainer.Parent = MainFrame

	-- BURAYI DÜZELTTİM → GRI ARKA PLAN
	local ContentArea = Instance.new("Frame")
	ContentArea.Size = UDim2.new(0, 342, 0, 236)
	ContentArea.Position = UDim2.new(0, 126, 0, 44)
	ContentArea.BackgroundColor3 = Color3.fromRGB(95, 95, 95)  -- GRİ YAPTIM
	ContentArea.Parent = MainFrame
	Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 8)

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 108, 0, 28)
	Indicator.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
	Indicator.ZIndex = -1
	Indicator.Parent = TabContainer
	Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 12)

	local CurrentContent = nil
	local TabsList = {}

	local Library = {}

	function Library:NewTab(name)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(0, 108, 0, 28)
		TabBtn.Position = UDim2.new(0, 0, 0, (#TabsList * 34))
		TabBtn.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
		TabBtn.Text = name
		TabBtn.TextColor3 = Color3.fromRGB(255,255,255)
		TabBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
		TabBtn.TextSize = 24
		TabBtn.Parent = TabContainer
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 12)

		local Content = Instance.new("ScrollingFrame")
		Content.Size = UDim2.new(1,0,1,0)
		Content.BackgroundTransparency = 1
		Content.ScrollBarThickness = 4
		Content.CanvasSize = UDim2.new(0,0,0,0)
		Content.Visible = false
		Content.Parent = ContentArea

		local Padding = Instance.new("UIPadding", Content)
		Padding.PaddingLeft = UDim.new(0, 8)
		Padding.PaddingRight = UDim.new(0, 8)
		Padding.PaddingTop = UDim.new(0, 8)

		local Layout = Instance.new("UIListLayout", Content)
		Layout.Padding = UDim.new(0, 8)
		Layout.SortOrder = Enum.SortOrder.LayoutOrder

		TabBtn.MouseButton1Click:Connect(function()
			if CurrentContent then CurrentContent.Visible = false end
			CurrentContent = Content
			Content.Visible = true
			TweenService:Create(Indicator, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {
				Position = UDim2.new(0, 0, 0, TabBtn.Position.Y.Offset)
			}):Play()
		end)

		table.insert(TabsList, TabBtn)
		if #TabsList == 1 then TabBtn.MouseButton1Click:Fire() end

		local Tab = {}

		function Tab:Paragraph(text)
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -16, 0, 38)
			Frame.BackgroundColor3 = Color3.fromRGB(163, 163, 163)
			Frame.Parent = Content
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

			local Label = Instance.new("TextLabel", Frame)
			Label.Size = UDim2.new(1, -8, 1, 0)
			Label.Position = UDim2.new(0, 4, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = text
			Label.TextColor3 = Color3.fromRGB(255,255,255)
			Label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
			Label.TextSize = 24
			Label.TextXAlignment = Enum.TextXAlignment.Left
		end

		function Tab:Toggle(cfg)
			cfg = cfg or {}
			local name = cfg.Name or "Toggle"
			local def = cfg.Default or false
			local callback = cfg.Callback or function() end

			Options[ConfigName.."_"..name] = def

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, -16, 0, 38)
			Frame.BackgroundColor3 = Color3.fromRGB(163, 163, 163)
			Frame.Parent = Content
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

			local Label = Instance.new("TextLabel", Frame)
			Label.Size = UDim2.new(0, 200, 1, 0)
			Label.Position = UDim2.new(0, 8, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = name
			Label.TextColor3 = Color3.fromRGB(255,255,255)
			Label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
			Label.TextSize = 24
			Label.TextXAlignment = Enum.TextXAlignment.Left

			local Btn = Instance.new("TextButton", Frame)
			Btn.Size = UDim2.new(0, 50, 0, 26)
			Btn.Position = UDim2.new(1, -58, 0.5, -13)
			Btn.BackgroundColor3 = def and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
			Btn.Text = ""
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

			Btn.MouseButton1Click:Connect(function()
				Options[ConfigName.."_"..name] = not Options[ConfigName.."_"..name]
				TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Options[ConfigName.."_"..name] and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)}):Play()
				callback(Options[ConfigName.."_"..name])
			end)

			if def then callback(true) end
		end

		function Tab:Button(cfg)
			local name = cfg.Name or "Button"
			local callback = cfg.Callback or function() end

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, -16, 0, 38)
			Btn.BackgroundColor3 = Color3.fromRGB(163, 163, 163)
			Btn.Text = name
			Btn.TextColor3 = Color3.fromRGB(255,255,255)
			Btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
			Btn.TextSize = 24
			Btn.Parent = Content
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

			Btn.MouseButton1Click:Connect(function()
				TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(120,120,120)}):Play()
				task.wait(0.12)
				TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(163,163,163)}):Play()
				callback()
			end)
		end

		function Tab:SaveConfig()
			writefile(ConfigFolder.."/"..ConfigName..".json", HttpService:JSONEncode(Options))
		end

		function Tab:LoadConfig()
			if isfile(ConfigFolder.."/"..ConfigName..".json") then
				local data = HttpService:JSONDecode(readfile(ConfigFolder.."/"..ConfigName..".json"))
				for i,v in pairs(data) do Options[i] = v end
			end
		end

		Tab:LoadConfig()

		return Tab
	end

	return Library
end

return FreshLib
