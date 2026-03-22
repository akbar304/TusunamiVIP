local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ================= ANA SİSTEM =================
local function startScript()

	_G.autoPartActive = false
	_G.espActive = false
	_G.speed = 16

	local gui = Instance.new("ScreenGui")
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	-- STYLE
	local function styleFrame(frame)
		frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

		local stroke = Instance.new("UIStroke", frame)
		stroke.Color = Color3.fromRGB(255,215,0)

		local corner = Instance.new("UICorner", frame)
		corner.CornerRadius = UDim.new(0,12)
	end

	local function styleButton(b)
		b.BackgroundColor3 = Color3.fromRGB(35,35,35)
		b.TextColor3 = Color3.fromRGB(255,215,0)
	end

	-- 🔥 FRAME SİSTEMİ (TOGGLE FIX)
	local function setupFrame(frame, titleText)
		frame.Active = true
		frame.Draggable = true
		styleFrame(frame)

		local top = Instance.new("Frame", frame)
		top.Size = UDim2.new(1,0,0,30)
		top.BackgroundColor3 = Color3.fromRGB(15,15,15)

		local title = Instance.new("TextLabel", top)
		title.Size = UDim2.new(1,-60,1,0)
		title.Position = UDim2.new(0,5,0,0)
		title.BackgroundTransparency = 1
		title.Text = titleText
		title.TextScaled = true
		title.TextColor3 = Color3.fromRGB(255,215,0)

		local minimize = Instance.new("TextButton", top)
		minimize.Size = UDim2.new(0,30,1,0)
		minimize.Position = UDim2.new(1,-30,0,0)
		minimize.Text = "-"
		styleButton(minimize)

		local minimized = false
		local normalSize = frame.Size

		minimize.MouseButton1Click:Connect(function()
			minimized = not minimized

			-- BUTON TEXT DEĞİŞİMİ
			minimize.Text = minimized and "+" or "-"

			frame.Size = minimized
				and UDim2.new(0, frame.Size.X.Offset, 0, 30)
				or normalSize

			for _,v in pairs(frame:GetDescendants()) do
				if v:IsDescendantOf(top) then continue end

				if v:IsA("GuiObject") then
					v.Visible = not minimized
				end

				if v:IsA("TextBox") then
					v.TextTransparency = minimized and 1 or 0
				end
			end
		end)

		return top
	end

	local function makeButton(parent,text,y)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1,-20,0,50)
		b.Position = UDim2.new(0,10,0,y)
		b.Text = text
		styleButton(b)
		b.Parent = parent
		return b
	end

	-- ================= MAIN =================
	local main = Instance.new("Frame")
	main.Size = UDim2.new(0,260,0,240)
	main.Position = UDim2.new(0.5,-130,0.4,-120)
	main.Parent = gui

	local mainTop = setupFrame(main,"Steal a Brainrot VIP")

	local close = Instance.new("TextButton", mainTop)
	close.Size = UDim2.new(0,30,1,0)
	close.Position = UDim2.new(1,-60,0,0)
	close.Text = "X"
	styleButton(close)

	local partBtn = makeButton(main,"Auto Part",40)
	local espBtn = makeButton(main,"ESP",100)
	local speedBtn = makeButton(main,"Speed",160)

	-- ================= PART =================
	local partFrame = Instance.new("Frame")
	partFrame.Size = UDim2.new(0,200,0,150)
	partFrame.Position = UDim2.new(0.6,0,0.5,0)
	partFrame.Visible = false
	partFrame.Parent = gui
	setupFrame(partFrame,"Auto Part")

	local partToggle = makeButton(partFrame,"Aç/Kapat",40)
	partToggle.MouseButton1Click:Connect(function()
		_G.autoPartActive = not _G.autoPartActive
	end)

	partBtn.MouseButton1Click:Connect(function()
		partFrame.Visible = true
	end)

	-- ================= SPEED =================
	local speedFrame = Instance.new("Frame")
	speedFrame.Size = UDim2.new(0,200,0,150)
	speedFrame.Position = UDim2.new(0.3,0,0.5,0)
	speedFrame.Visible = false
	speedFrame.Parent = gui
	setupFrame(speedFrame,"Speed")

	local speedBox = Instance.new("TextBox")
	speedBox.Size = UDim2.new(1,-20,0,50)
	speedBox.Position = UDim2.new(0,10,0,40)
	speedBox.PlaceholderText = "Hız gir"
	speedBox.Parent = speedFrame

	local apply = makeButton(speedFrame,"UYGULA",100)
	apply.MouseButton1Click:Connect(function()
		local v = tonumber(speedBox.Text)
		if v then _G.speed = v end
	end)

	speedBtn.MouseButton1Click:Connect(function()
		speedFrame.Visible = true
	end)

	-- ================= ESP =================
	local esp = {}

	local function addESP(plr)
		if plr == player then return end
		local box = Instance.new("BoxHandleAdornment", workspace)
		box.Size = Vector3.new(4,6,2)
		box.AlwaysOnTop = true
		esp[plr] = box
	end

	for _,p in pairs(Players:GetPlayers()) do addESP(p) end

	RunService.RenderStepped:Connect(function()
		for plr,box in pairs(esp) do
			local char = plr.Character
			if char and char:FindFirstChild("HumanoidRootPart") and _G.espActive then
				box.Adornee = char
				box.Color3 = Color3.fromHSV((tick()%5)/5,1,1)
			else
				box.Adornee = nil
			end
		end
	end)

	espBtn.MouseButton1Click:Connect(function()
		_G.espActive = not _G.espActive
	end)

	-- ================= AUTO PART =================
	task.spawn(function()
		while true do
			if _G.autoPartActive then
				local char = player.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					local p = Instance.new("Part")
					p.Size = Vector3.new(4,1,4)
					p.Position = char.HumanoidRootPart.Position - Vector3.new(0,3,0)
					p.Anchored = true
					p.Parent = workspace

					task.spawn(function()
						while p and p.Parent do
							p.Color = Color3.fromHSV((tick()%5)/5,1,1)
							task.wait(0.05)
						end
					end)

					task.delay(1,function()
						if p then p:Destroy() end
					end)
				end
			end
			task.wait(0.2)
		end
	end)

	-- ================= SPEED =================
	RunService.Heartbeat:Connect(function()
		local char = player.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = _G.speed
		end
	end)

	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)
end

-- ================= KEY =================
local correctKey = "akbar201212"

local keyGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0,300,0,150)
keyFrame.Position = UDim2.new(0.5,-150,0.5,-75)
keyFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
keyFrame.Parent = keyGui

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1,-20,0,50)
keyBox.Position = UDim2.new(0,10,0,20)
keyBox.PlaceholderText = "Key gir..."
keyBox.Parent = keyFrame

local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(1,-20,0,40)
keyBtn.Position = UDim2.new(0,10,0,80)
keyBtn.Text = "GİR"
keyBtn.Parent = keyFrame

keyBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == correctKey then
		keyGui:Destroy() -- 🔥 ANINDA YOK OLUR
		startScript()
	else
		keyBox.Text = "YANLIŞ!"
	end
end)
