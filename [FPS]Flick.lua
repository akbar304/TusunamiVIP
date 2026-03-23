local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local function startScript()

	_G.floatActive = false
	_G.espActive = false
	_G.speed = 16

	local aimActive = false
	local lockedTarget = nil

	local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
	gui.ResetOnSpawn = false

	-- ================= STYLE =================
	local function styleFrame(f)
		f.BackgroundColor3 = Color3.fromRGB(20,20,20)
		Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)
		local s = Instance.new("UIStroke", f)
		s.Color = Color3.fromRGB(255,215,0)
	end

	local function styleBtn(b)
		b.BackgroundColor3 = Color3.fromRGB(35,35,35)
		b.TextColor3 = Color3.fromRGB(255,215,0)
	end

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
	end

	local function btn(p,t,y)
		local b = Instance.new("TextButton", p)
		b.Size = UDim2.new(1,-20,0,50)
		b.Position = UDim2.new(0,10,0,y)
		b.Text = t
		styleBtn(b)
		return b
	end

	-- ================= UI =================
	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0,260,0,300)
	main.Position = UDim2.new(0.5,-130,0.4,-150)
	setupFrame(main,"[FPS]Flick")

	local floatBtn = btn(main,"Gravity",40)
	local espBtn = btn(main,"ESP",100)
	local speedBtn = btn(main,"Speed",160)
	local aimBtn = btn(main,"Aim",220)

	-- ================= FLOAT =================
	local bodyVel
	floatBtn.MouseButton1Click:Connect(function()
		_G.floatActive = not _G.floatActive
	end)

	RunService.Heartbeat:Connect(function()
		local char = player.Character
		if _G.floatActive and char and char:FindFirstChild("HumanoidRootPart") then
			if not bodyVel then
				bodyVel = Instance.new("BodyVelocity")
				bodyVel.MaxForce = Vector3.new(0,3000,0)
				bodyVel.Velocity = Vector3.new(0,2,0)
				bodyVel.Parent = char.HumanoidRootPart
			end
		else
			if bodyVel then bodyVel:Destroy() bodyVel=nil end
		end
	end)

	-- ================= SPEED =================
	RunService.Heartbeat:Connect(function()
		local char = player.Character
		if not char then return end
		
		local hum = char:FindFirstChild("Humanoid")
		if not hum then return end

		if hum.MoveDirection.Magnitude > 0 then
			local target = math.clamp(_G.speed,16,240)
			hum.WalkSpeed = hum.WalkSpeed + (target - hum.WalkSpeed)*0.1
		else
			hum.WalkSpeed = 16
		end
	end)

	speedBtn.MouseButton1Click:Connect(function()
		_G.speed = (_G.speed == 16) and 28 or 16
	end)

	-- ================= BAKIYOR MU =================
	local function isLookingAtMe(enemyHead)
		local myChar = player.Character
		if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end

		local myPos = myChar.HumanoidRootPart.Position
		local dir = (myPos - enemyHead.Position).Unit
		local look = enemyHead.CFrame.LookVector

		return dir:Dot(look) > 0.10
	end

	-- ================= HUD =================
	local visuals = {}

	local function add(p)
		if p == player then return end

		local bill = Instance.new("BillboardGui")
		bill.Size = UDim2.new(0,180,0,60)
		bill.StudsOffset = Vector3.new(0,3,0)
		bill.AlwaysOnTop = true

		local txt = Instance.new("TextLabel", bill)
		txt.Size = UDim2.new(1,0,0.5,0)
		txt.BackgroundTransparency = 1
		txt.TextScaled = true
		txt.TextStrokeTransparency = 0

		local warn = Instance.new("TextLabel", bill)
		warn.Size = UDim2.new(1,0,0.5,0)
		warn.Position = UDim2.new(0,0,0.5,0)
		warn.BackgroundTransparency = 1
		warn.Text = "⚠ BAKIYOR"
		warn.TextScaled = true
		warn.TextColor3 = Color3.fromRGB(255,0,0)
		warn.Visible = false

		local bg = Instance.new("Frame", bill)
		bg.Size = UDim2.new(1,0,0.2,0)
		bg.Position = UDim2.new(0,0,0.8,0)

		local hp = Instance.new("Frame", bg)
		hp.BackgroundColor3 = Color3.fromRGB(0,255,0)

		visuals[p] = {bill=bill,txt=txt,hp=hp,warn=warn}
	end

	for _,p in pairs(Players:GetPlayers()) do add(p) end
	Players.PlayerAdded:Connect(add)

	RunService.RenderStepped:Connect(function()
		for plr,v in pairs(visuals) do
			local c = plr.Character

			if _G.espActive and c and c:FindFirstChild("Head") then
				local head = c.Head
				local hum = c:FindFirstChild("Humanoid")
				local pos,on = camera:WorldToViewportPoint(head.Position)

				if on then
					v.bill.Parent = head
					v.bill.Adornee = head

					local dist = math.floor((head.Position-camera.CFrame.Position).Magnitude)
					
					local looking = isLookingAtMe(head)

					-- 🔴 BAKIYORSA
					if looking then
						v.txt.TextColor3 = Color3.fromRGB(255,0,0)
						v.warn.Visible = true
					else
						v.txt.TextColor3 = Color3.fromRGB(255,255,255)
						v.warn.Visible = false
					end

					v.txt.Text = plr.Name.." | "..dist.."m"

					local p = hum and hum.Health/hum.MaxHealth or 1
					v.hp.Size = UDim2.new(p,0,1,0)
				else
					v.bill.Parent=nil
				end
			else
				v.bill.Parent=nil
			end
		end
	end)

	espBtn.MouseButton1Click:Connect(function()
		_G.espActive = not _G.espActive
	end)

	-- ================= AIM =================
	local function isVisible(part)
		local origin = camera.CFrame.Position
		local direction = (part.Position - origin)

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = {player.Character}

		local result = workspace:Raycast(origin, direction, params)

		if result then
			return result.Instance:IsDescendantOf(part.Parent)
		end

		return true
	end

	aimBtn.MouseButton1Click:Connect(function()
		aimActive = not aimActive
		if not aimActive then lockedTarget = nil end
	end)

	RunService.RenderStepped:Connect(function()
		if not aimActive then return end

		if not lockedTarget then
			local closest, dist = nil, math.huge

			for _,p in pairs(Players:GetPlayers()) do
				if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
					local head = p.Character.Head
					local pos,on = camera:WorldToViewportPoint(head.Position)

					if on and isVisible(head) then
						local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
						local mag = (Vector2.new(pos.X,pos.Y)-center).Magnitude

						if mag < dist then
							dist = mag
							closest = p
						end
					end
				end
			end

			lockedTarget = closest
		end

		if lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Head") then
			local head = lockedTarget.Character.Head

			if not isVisible(head) then
				lockedTarget = nil
				return
			end

			local newCF = CFrame.new(camera.CFrame.Position, head.Position)
			camera.CFrame = camera.CFrame:Lerp(newCF, 0.6)
		else
			lockedTarget = nil
		end
	end)
end

-- ================= KEY =================
local key = "akbar201212"

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local f = Instance.new("Frame", gui)
f.Size = UDim2.new(0,300,0,150)
f.Position = UDim2.new(0.5,-150,0.5,-75)

local box = Instance.new("TextBox", f)
box.Size = UDim2.new(1,-20,0,50)
box.Position = UDim2.new(0,10,0,20)

local btn = Instance.new("TextButton", f)
btn.Size = UDim2.new(1,-20,0,40)
btn.Position = UDim2.new(0,10,0,80)
btn.Text = "GİR"

btn.MouseButton1Click:Connect(function()
	if box.Text == key then
		gui:Destroy()
		startScript()
	else
		box.Text = "YANLIŞ"
	end
end)
