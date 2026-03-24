local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- KEY SYSTEM
local correctKey = "akbar20121212"
local unlocked = false

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

-- MAIN PANEL
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,500,0,300)
main.Position = UDim2.new(0.5,-250,0.5,-150)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.Active = true
Instance.new("UICorner", main)
main.Visible = false  -- Başta gizli

-- KEY UI
local keyFrame = Instance.new("Frame", gui)
keyFrame.Size = UDim2.new(0,300,0,150)
keyFrame.Position = UDim2.new(0.5,-150,0.5,-75)
keyFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", keyFrame)

local keyBox = Instance.new("TextBox", keyFrame)
keyBox.Size = UDim2.new(0.8,0,0,40)
keyBox.Position = UDim2.new(0.1,0,0.3,0)
keyBox.PlaceholderText = "Enter Key..."
keyBox.Text = ""

local enter = Instance.new("TextButton", keyFrame)
enter.Size = UDim2.new(0.5,0,0,40)
enter.Position = UDim2.new(0.25,0,0.7,0)
enter.Text = "ENTER"
Instance.new("UICorner", enter)
enter.BackgroundColor3 = Color3.fromRGB(255,215,0)
enter.TextColor3 = Color3.fromRGB(0,0,0)

enter.MouseButton1Click:Connect(function()
	if keyBox.Text == correctKey then
		unlocked = true
		keyFrame:Destroy()
		main.Visible = true
	else
		keyBox.Text = "enter(gir)"
		keyBox.PlaceholderText = "Wrong Key!"
	end
end)

-- FPS
local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Size = UDim2.new(0,100,0,30)
fpsLabel.Position = UDim2.new(0,10,0,10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
fpsLabel.TextScaled = true
fpsLabel.Visible = false

local frames=0
local last=tick()

RunService.RenderStepped:Connect(function()
	if not unlocked then return end
	if not states.fps then return end
	frames+=1
	if tick()-last>=1 then
		fpsLabel.Text="FPS: "..frames
		frames=0
		last=tick()
	end
end)

-- STATES
local states = {
	aim = false,
	esp = false,
	fps = false,
	float = false,
	speed = false
}

_G.speed = 16
_G.aimSmooth = 1

-- PANEL TOP
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,30)
top.BackgroundColor3 = Color3.fromRGB(10,10,10)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-40,1,0)
title.Text="LEGIT PANEL"
title.BackgroundTransparency=1
title.TextColor3=Color3.fromRGB(255,215,0)
title.TextScaled=true

local min = Instance.new("TextButton", top)
min.Size = UDim2.new(0,30,1,0)
min.Position = UDim2.new(1,-30,0,0)
min.Text = "-"

-- DRAG
local dragging=false
local dragInput,dragStart,startPos

top.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=true
		dragStart=i.Position
		startPos=main.Position
		i.Changed:Connect(function()
			if i.UserInputState==Enum.UserInputState.End then
				dragging=false
			end
		end)
	end
end)

top.InputChanged:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseMovement then
		dragInput=i
	end
end)

UIS.InputChanged:Connect(function(i)
	if i==dragInput and dragging then
		local delta=i.Position-dragStart
		main.Position=UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset+delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset+delta.Y
		)
	end
end)

-- PANELS
local side=Instance.new("Frame", main)
side.Size=UDim2.new(0,120,1,-30)
side.Position=UDim2.new(0,0,0,30)

local panel=Instance.new("Frame", main)
panel.Size=UDim2.new(1,-120,1,-30)
panel.Position=UDim2.new(0,120,0,30)

-- MINIMIZE
local minimized=false
local normalSize=main.Size

min.MouseButton1Click:Connect(function()
	minimized=not minimized
	if minimized then
		main.Size=UDim2.new(0,200,0,30)
		side.Visible=false
		panel.Visible=false
	else
		main.Size=normalSize
		side.Visible=true
		panel.Visible=true
	end
end)

-- TAB
local function tab(name,y)
	local b=Instance.new("TextButton", side)
	b.Size=UDim2.new(1,0,0,40)
	b.Position=UDim2.new(0,0,0,y)
	b.Text=name
	return b
end

local aimTab=tab("Aim",10)
local visTab=tab("Visual",60)
local miscTab=tab("Misc",110)

local function clear()
	for _,v in pairs(panel:GetChildren()) do v:Destroy() end
end

-- TOGGLE FUNCTION
local function toggle(text,y,key,func)
	local b=Instance.new("TextButton", panel)
	b.Size=UDim2.new(0,200,0,40)
	b.Position=UDim2.new(0,20,0,y)
	local function update()
		b.Text=text.." "..(states[key] and "ON" or "OFF")
	end
	update()
	b.MouseButton1Click:Connect(function()
		states[key]=not states[key]
		update()
		func(states[key])
	end)
end

-- HELPERS
local function isVisible(part)
	local origin=camera.CFrame.Position
	local direction=part.Position-origin
	local params=RaycastParams.new()
	params.FilterType=Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances={player.Character}
	local result=workspace:Raycast(origin,direction,params)
	if result then
		return result.Instance:IsDescendantOf(part.Parent)
	end
	return true
end

local function isLookingAtYou(target)
	local char=target.Character
	if not char or not char:FindFirstChild("Head") or not player.Character then return false end
	local head=char.Head
	local dir=(player.Character.Head.Position-head.Position).Unit
	return head.CFrame.LookVector:Dot(dir)>0.7
end

local function getClosest()
	local closest=nil
	local dist=math.huge
	for _,p in pairs(Players:GetPlayers()) do
		if p~=player and p.Character and p.Character:FindFirstChild("Head") then
			local h=p.Character.Head
			local pos,on=camera:WorldToViewportPoint(h.Position)
			if on and isVisible(h) then
				local mag=(Vector2.new(pos.X,pos.Y)-Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)).Magnitude
				if mag<dist then
					dist=mag
					closest=p
				end
			end
		end
	end
	return closest
end

-- AIM
RunService.RenderStepped:Connect(function()
	if not unlocked then return end
	if not states.aim then return end
	local target=getClosest()
	if target and target.Character and target.Character:FindFirstChild("Head") then
		local h=target.Character.Head
		if isVisible(h) then
			local cf=CFrame.new(camera.CFrame.Position,h.Position)
			local distance=(camera.CFrame.Position-h.Position).Magnitude
			local speed=math.clamp(1-(distance/1000),0.3,1)
			camera.CFrame=camera.CFrame:Lerp(cf,_G.aimSmooth*speed)
		end
	end
end)

-- ESP
local visuals={}
local function add(p)
	if p==player then return end
	local bill=Instance.new("BillboardGui")
	bill.Size=UDim2.new(0,180,0,60)
	bill.StudsOffset=Vector3.new(0,3,0)
	bill.AlwaysOnTop=true
	local txt=Instance.new("TextLabel",bill)
	txt.Size=UDim2.new(1,0,0.5,0)
	txt.BackgroundTransparency=1
	txt.TextScaled=true
	local bg=Instance.new("Frame",bill)
	bg.Size=UDim2.new(1,0,0.2,0)
	bg.Position=UDim2.new(0,0,0.8,0)
	local hp=Instance.new("Frame",bg)
	visuals[p]={bill=bill,txt=txt,hp=hp}
end

for _,p in pairs(Players:GetPlayers()) do add(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) add(p) end)
Players.PlayerRemoving:Connect(function(p) if visuals[p] then visuals[p].bill:Destroy() visuals[p]=nil end end)

RunService.RenderStepped:Connect(function()
	if not unlocked then return end
	for plr,v in pairs(visuals) do
		local c=plr.Character
		if states.esp and c and c:FindFirstChild("Head") then
			local head=c.Head
			local hum=c:FindFirstChild("Humanoid")
			local pos,on=camera:WorldToViewportPoint(head.Position)
			if on then
				v.bill.Parent=head
				local dist=math.floor((head.Position-camera.CFrame.Position).Magnitude)
				v.txt.Text=plr.Name.." | "..dist.."m"
				if isLookingAtYou(plr) and isVisible(head) then
					v.txt.TextColor3=Color3.fromRGB(255,0,0)
				else
					v.txt.TextColor3=Color3.fromRGB(255,255,255)
				end
				local hp=hum and hum.Health/hum.MaxHealth or 1
				v.hp.Size=UDim2.new(hp,0,1,0)
			else
				v.bill.Parent=nil
			end
		else
			v.bill.Parent=nil
		end
	end
end)

-- BUTTONS
aimTab.MouseButton1Click:Connect(function()
	clear()
	toggle("Aim",20,"aim",function() end)
end)

visTab.MouseButton1Click:Connect(function()
	clear()
	toggle("ESP",20,"esp",function() end)
	toggle("FPS",80,"fps",function(v) fpsLabel.Visible=v end)
end)

miscTab.MouseButton1Click:Connect(function()
	clear()
	toggle("Float",20,"float",function() end)
	local b=Instance.new("TextButton",panel)
	b.Size=UDim2.new(0,200,0,40)
	b.Position=UDim2.new(0,20,0,80)
	local function update() b.Text=states.speed and "Speed ON (28)" or "Speed OFF" end
	update()
	b.MouseButton1Click:Connect(function()
		states.speed=not states.speed
		_G.speed=states.speed and 28 or 16
		update()
	end)
end)

-- FLOAT
local bv
RunService.Heartbeat:Connect(function()
	if not unlocked then return end
	local c=player.Character
	if states.float and c and c:FindFirstChild("HumanoidRootPart") then
		if not bv then
			bv=Instance.new("BodyVelocity")
			bv.MaxForce=Vector3.new(0,3000,0)
			bv.Velocity=Vector3.new(0,2,0)
			bv.Parent=c.HumanoidRootPart
		end
	else
		if bv then bv:Destroy() bv=nil end
	end
end)

-- SPEED
RunService.Heartbeat:Connect(function()
	if not unlocked then return end
	local c=player.Character
	if c and c:FindFirstChild("Humanoid") then
		c.Humanoid.WalkSpeed=_G.speed
	end
end)
