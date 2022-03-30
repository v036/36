-----------------------------------------
				--BY 36--
-----------------------------------------

--Customization
local whitelist = {} --Whitelist (userId), reach and auto killer will ignore this player
local prefix = "/"
local killMessages = {"i aliven't you", "imagine not being alive", "gg", "{k} stabbed {v}", "ez", "Dog water", "UwU", "I'm sorry it had to go this way {v}", "What gamer chair?? Chicken nugget 9001 ofc!!", "imagine dying"} -- Messages that u will say whenever u killed someone, use %k for killer's username and use %v for victim's username

--Services
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Tw = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local runService = game:GetService("RunService")
local Core = game:GetService("CoreGui")

--Variables
local BodyParts = {"HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Head"}
local client = Players.localPlayer
local spawnLocation = workspace:WaitForChild('Structure'):WaitForChild('SpawnLocation')
local whitelistEnabled = true
local staff = {}
local controller = nil 
local protect = nil
local priorTarget = nil
local autoTpDebounce = false
local SpawnDebounce = false

--Library's
local maid = loadstring(game:HttpGet'https://raw.githubusercontent.com/Yorxq/scripts/main/Maid.lua')()
local library = loadstring(game:HttpGet'https://raw.githubusercontent.com/Yorxq/scripts/main/GuiLibrary.lua')()
local mainMaid = maid.new()

--Anticheat bypass
if not _G.LoadedAntiCheat or _G.LoadedAntiCheat == nil then --Makes anticheat only load once.
	loadstring(game:HttpGet'https://raw.githubusercontent.com/Yorxq/scripts/main/Bypass.lua')()
	_G.LoadedAntiCheat = true
end

--Functions
--Returns closest time box from a certain position
local function closestBox(pos)
	local closest
	for _,v in pairs(workspace.Gifts:GetChildren()) do
		if not v:FindFirstChild("ScreenGui").Frame.TextLabel.Text:match("claimed") then
			if closest == nil then
				closest = v
			elseif (pos - v.Position).Magnitude < (pos - closest.Position).Magnitude then
				closest = v
			end
		end
	end
	return closest
end

--returns if a player is in spawn (not 100% acurate)
local function isInSpawn(plr) --get if player is in spawn
	return math.floor((spawnLocation.Position - plr.Character:FindFirstChild("HumanoidRootPart").Position).magnitude) <= 32
end

--returns the closest player from a certain position
local function closestPlayer(pos, ignoreWhitelist, ignoreSpawn)
	local closest = nil
	local closestPos = nil
	for _,v in pairs(Players:GetChildren()) do
		if v ~= client then
			local Pchar = v.Character

			if not Pchar then continue end
			local PRoot = Pchar:FindFirstChild("HumanoidRootPart")
			local PHumanoid = Pchar:FindFirstChild("Humanoid")

			if not PRoot or not PHumanoid then continue end
			if not ignoreSpawn then
				if isInSpawn(v) then continue end
			end
			if not (PHumanoid.Health > 0) then continue end
			if v == controller then continue end
			if v == protect then continue end
			if not ignoreWhitelist then
				if whitelistEnabled then
					if table.find(whitelist, v.UserId) then continue end
				end
			end
			
			if closest == nil then
				closest = v
			elseif (pos - PRoot.Position).Magnitude < (pos - closest.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude then
				closest = v
			end
		end
	end
	return closest
end

--gets client's tool
local function getTool()
	local tool = client.Character:FindFirstChildWhichIsA('Tool')
	if tool then return tool end
	return client.Backpack:FindFirstChildWhichIsA('Tool')
end

--auto complete player name for commands
local function FindPlayer(name)
	for i,v in pairs(game.Players:GetPlayers()) do
		if v.Name:lower():sub(1,#name) == name:lower() then
			return v.Name
		end
	end
end

local function SwitchLag()
	local char = client.Character
	if not char then return end
	local Root = char:FindFirstChild("HumanoidRootPart")
	if not Root then return end

	if library.flags.Lag then
		local Clone = Root:Clone()
		Clone.Parent = char
		local area = Instance.new("Part")
		area.CastShadow = false
		area.Name = "UnflagableArea"
		area.Anchored = true
		area.CanCollide = false
		area.Shape = Enum.PartType.Cylinder
		area.Material = Enum.Material.SmoothPlastic
		area.Color = Color3.fromRGB(47, 252, 6)
		area.Size = Vector3.new(1,110,110)
		area.Rotation = Vector3.new(0,0,90)
		area.Position = Vector3.new(Root.Position.X,-0.4,Root.Position.Z)
		area.Transparency = 0.5
		area.Parent = workspace
		
	else
		for _,v in pairs(char:GetChildren()) do
			if v ~= Root and v.Name == "HumanoidRootPart" then
				v:Destroy()
				v.Anchored = true
			end
		end
		local area = workspace:FindFirstChild("UnflagableArea")
		if area then
			area:Destroy()
		end
	end
end

local structure = workspace:WaitForChild("Structure")
local killpart = structure.KillPart:FindFirstChild("KillPart")
local ocean = Instance.new("Part")
ocean.Size = killpart.Size
ocean.Position = killpart.Position
ocean.Anchored = true
ocean.Color = killpart.Color
ocean.Name = "Ocean"
ocean.Transparency = killpart.Transparency
ocean.Material = killpart.Material

local function solidWater()
	local structure = workspace:WaitForChild("Structure")
	if library.flags.SolidWater then
		ocean.Parent = workspace
		structure.KillPart:FindFirstChild("KillPart").Parent = game.Lighting
	else
		ocean.Parent = nil
		game.Lighting:FindFirstChild("KillPart").Parent = structure.KillPart
	end
end

local spawn = Instance.new("Part")
spawn.Size = Vector3.new(45,20,45)
spawn.Position = Vector3.new(0,10,0)
spawn.Transparency = 0.7
spawn.Color = Color3.fromRGB(47, 252, 6)
spawn.Material = Enum.Material.Plastic
spawn.CastShadow = false
spawn.Anchored = true
spawn.CanCollide = false
spawn.TopSurface = Enum.SurfaceType.Smooth

local function ShowSpawn()
	if library.flags.ShowSpawn then
		spawn.Parent = workspace
	else
		spawn.Parent = nil
	end
end

local function bhop()
	local char = client.Character
	if not char then return end
	local torso = char:FindFirstChild("Torso")
	if not torso then return end

	if library.flags.BHop then
		local vel = torso:FindFirstChildWhichIsA('BodyVelocity')
		if not vel then
			local Body = Instance.new('BodyVelocity', torso)
			Body.MaxForce = Vector3.new(9e9, 0, 9e9)
		end
	else
		torso:FindFirstChildWhichIsA('BodyVelocity'):Destroy()
	end
end

local function DisplayDistance()
	if library.flags.ShowTime then
		for _,v in pairs(Players:GetPlayers()) do
			v.CharacterAdded:Connect(function(char)
				if library.flags.ShowTime then
					wait(0.5)
					local Gui = char.Head:FindFirstChild("HUD")
					Gui.MaxDistance = 0
				end
			end)

			local char = v.Character
			if not char then return end
			local Gui = char.Head:FindFirstChild("HUD")
			Gui.MaxDistance = 0
		end
	else
		for _,v in pairs(Players:GetPlayers()) do
			local char = v.Character
			if not char then return end
			local Gui = char.Head:FindFirstChild("HUD")
			Gui.MaxDistance = 100
		end
	end
end



--Main code that needs to be executed once
--Visualizer
local visualizer = Instance.new("Part")
visualizer.CastShadow = false
visualizer.Name = math.random()
visualizer.Anchored = true
visualizer.CanCollide = false
visualizer.Shape = Enum.PartType.Ball
visualizer.Material = Enum.Material.ForceField
visualizer.Color = Color3.fromRGB(47, 252, 6)
visualizer.Transparency = 0.4

local Beam = Instance.new('Beam')
local Attach1 = Instance.new('Attachment')
local Attach2 = Instance.new('Attachment')
Beam.Attachment0 = Attach1
Beam.Attachment1 = Attach2
Beam.FaceCamera = true
Beam.Width0 = 0.2
Beam.Width1 = 0.2
Beam.Color = ColorSequence.new(Color3.fromRGB(28, 43, 248),Color3.fromRGB(28, 43, 248))

--[[if killpart then
	local ocean = Instance.new("Part")
	ocean.Size = killpart.Size
	ocean.Position = killpart.Position
	ocean.Anchored = true
	ocean.Color = Color3.fromRGB(0, 110, 255)
	ocean.Name = math.random()
	ocean.Parent = workspace
	killpart:Destroy()
end]]

--Kill message
local replicatedStorage = game:GetService('ReplicatedStorage')
local events = replicatedStorage:WaitForChild('Remotes', 10)
local killEvent = (events and events:WaitForChild('StudEvent', 10))
local randomInt = Random.new()

killEvent.OnClientEvent:connect(function(victim, killer)
	if library.flags.KillMessage then
		if typeof(victim) == 'Instance' and typeof(killer) == 'Instance' then
			if victim:IsA('Player') and killer:IsA('Player') and killer == client then
				local text = killMessages[randomInt:NextInteger(1, #killMessages)]

				text = text:gsub("{k}", client.Name)
				text = text:gsub("{v}", victim.Name)

				game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, 'All')
			end
		end
	end
end)

--anti ban (cant be disabled for own protection)
local response = game:HttpGet('https://groups.roblox.com/v1/groups/7548958/users?sortOrder=Asc&limit=100')
local responseTable = HttpService:JSONDecode(response)

for _,v in pairs(responseTable["data"]) do
	table.insert(staff, v["user"]["userId"])
end

for _,player in pairs(Players:GetChildren()) do
	if table.find(staff, player.userId) then
		StarterGui:SetCore("SendNotification", {Title = "A staff member is here",Text = "You will be teleported in 3.."})
		wait(3)
		local x = {}
		for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
			if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
				x[#x + 1] = v.id
			end
		end
		if #x > 0 then
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
		else
			return notify("Serverhop","Couldn't find a server.")
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	if table.find(staff, player.userId) then
		StarterGui:SetCore("SendNotification", {Title = player.Name.." Joined",Text = "You will be teleported in a second.."})
		wait(1)
		local x = {}
		for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
			if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
				x[#x + 1] = v.id
			end
		end
		if #x > 0 then
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
		else
			return notify("Serverhop","Couldn't find a server.")
		end
	end
end)

--------------------------------------------
--initLogic
--------------------------------------------
local function initLogic(char)
	--Loading variables, cleaning the maid
	mainMaid:DoCleaning()
	local Humanoid = char:WaitForChild("Humanoid", 10)
	local Root = char:WaitForChild("HumanoidRootPart", 10)
	controller = nil
	protect = nil
	if not Root or not Humanoid then
		return
	end

	--BHOP
	if library.flags.BHop then
		local torso = char:FindFirstChild("Torso")
		local vel = torso:FindFirstChildWhichIsA('BodyVelocity')
		if not vel then
			local Body = Instance.new('BodyVelocity', torso)
			Body.MaxForce = Vector3.new(9e9, 0, 9e9)
		end
	end

	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		local torso = char:FindFirstChild("Torso")
		if torso then
			if library.flags.BHop then
				local Body = torso:FindFirstChildWhichIsA('BodyVelocity')
				if Body then
					Body.Velocity = (Humanoid.MoveDirection) * 55
				end
			end
		end
	end))

	-- Reach Visualizer
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.ReachVisualizer and library.flags.Reach then
			local sword = char:FindFirstChildOfClass("Tool")
			if sword then
				visualizer.Parent = workspace
				visualizer.Size = Vector3.new(library.flags.ReachDistance, library.flags.ReachDistance, library.flags.ReachDistance)
				visualizer.CFrame = Root.CFrame
			else
				visualizer.Parent = nil
			end
		else
			visualizer.Parent = nil
		end
	end))

	-- Target Visualizer
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.ShowTarget then
			local target = closestPlayer(Root.Position, false, false)
			if target then
				if Beam.Parent ~= workspace then
					Beam.Parent = workspace
				end
				
				Attach1.Parent = Root
				Attach2.Parent = target.Character:FindFirstChild("HumanoidRootPart")
			else
				Beam.Parent = nil
			end
		else
			Beam.Parent = nil
		end
	end))


	--autoCollect Gifts
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.AutoFarm then
			local TimeRain = closestBox(Root.Position)
        	if TimeRain then
                local Tinfo = TweenInfo.new(((TimeRain.Position - Root.Position).Magnitude)/50, Enum.EasingStyle.Linear)
				local Tween = game:GetService("TweenService"):Create(Root, Tinfo, {CFrame = CFrame.new(TimeRain.Position)})
				Tween:Play()
				Tween.Completed:wait()
			end
		end
	end))
	
	--Reach
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.Reach then
			local sword = char:FindFirstChildOfClass("Tool")

			if not sword then return end

			local handle = sword.Handle
			
			if not handle then return end 

			if not whitelistEnabled or #whitelist == 0 then
				if handle.Size ~= Vector3.new(library.flags.ReachDistance,library.flags.ReachDistance,library.flags.ReachDistance) then
					handle.Size = Vector3.new(library.flags.ReachDistance,library.flags.ReachDistance,library.flags.ReachDistance)
				end
			else
				if handle.Size ~= Vector3.new(1, 0.8, 4) then
					handle.Size = Vector3.new(1, 0.8, 4)
				end
			end
			
			
			for _, player in pairs(Players:GetChildren()) do
				if player == client then continue end

				local pChar = player.Character
				if not pChar then continue end
				local pRoot = pChar:FindFirstChild("HumanoidRootPart")
				local pHumanoid = pChar:FindFirstChild("Humanoid")

				if not pHumanoid or not pRoot then continue end
				if player == controller then continue end
				if player == protect then continue end
				if whitelistEnabled then
					if table.find(whitelist, player.UserId) then continue end
				end

				if pHumanoid.Health > 0 and Humanoid.Health > 0 and (pRoot.Position - Root.Position).Magnitude <= library.flags.ReachDistance then 
					for i,part in pairs(pChar:GetChildren()) do
						if table.find(BodyParts,part.Name) then
							for i = 1, 20 do
								pRoot.Size = Vector3.new(30,30,30)
								firetouchinterest(handle, part, 0) 
								firetouchinterest(handle, part, 1)
								firetouchinterest(handle, part, 0) 
							end
						end
					end
				end 
			end
		else
			local sword = char:FindFirstChildOfClass("Tool")

			if not sword then return end

			local handle = sword.Handle
			
			if not handle then return end

			if handle.Size ~= Vector3.new(1, 0.8, 4) then
				handle.Size = Vector3.new(1, 0.8, 4)
			end
		end
	end))

	--Auto Swing
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.AutoSwing then
			local sword = char:FindFirstChildOfClass("Tool")
			if not sword then return end
			sword:Activate()
		end
	end))

	--Auto Target / goto player
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.AutoKiller then
			local target = closestPlayer(Root.Position, false, false)

			local sword = getTool()
			--Auto activate tool
			if not char:FindFirstChildOfClass("Tool") then
				Humanoid:EquipTool(sword)
			else
				sword:Activate()
			end

			if target then
				if Beam.Parent ~= workspace then
					Beam.Parent = workspace
				end
				Attach1.Parent = Root
				Attach2.Parent = target.Character:FindFirstChild("HumanoidRootPart")
				local info = TweenInfo.new((((target.Character.Humanoid.RootPart.CFrame*CFrame.new(math.random(-30,30)/10,math.random(0,30)/10,math.random(-30,30)/10)).Position - char.Humanoid.RootPart.Position).Magnitude)/50,Enum.EasingStyle.Linear)
				local Tween = game:GetService("TweenService"):Create(char.Humanoid.RootPart, info, {["CFrame"] = ((target.Character.Humanoid.RootPart.CFrame * CFrame.new(math.random(-30,30)/10,math.random(0,30)/10,math.random(-30,30)/10)))})
				Tween:Play()
			else
				Beam.Parent = nil
			end

			--reach
			local sword = char:FindFirstChildOfClass("Tool")

			if not sword then return end

			local handle = sword.Handle

			for _, player in pairs(Players:GetChildren()) do
				if player == client then continue end

				local pChar = player.Character
				local pRoot = pChar:FindFirstChild("HumanoidRootPart")
				local pHumanoid = pChar:FindFirstChild("Humanoid")

				if not pHumanoid or not pRoot then continue end
				if player == controller then continue end
				if player == protect then continue end
				if whitelistEnabled then
					if table.find(whitelist, player.UserId) then continue end
				end

				if pHumanoid.Health > 0 and Humanoid.Health > 0 and (pRoot.Position - Root.Position).Magnitude <= library.flags.ReachDistance then 
					for i,part in pairs(pChar:GetChildren()) do
						if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "Left Arm" or part.Name == "Right Arm" or part.Name == "Left Leg" or part.Name == "Right Leg" or part.Name == "Head" then
							firetouchinterest(handle, part, 0) 
							firetouchinterest(handle, part, 1)
						end
					end
				end 
			end
		else
			Beam.Parent = nil
		end
	end))

	--Rotate Around Spawn
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.SpawnKill then
			Root.Velocity = Vector3.new()
		end
	end))

	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.SpawnKill then
			if not SpawnDebounce then
				SpawnDebounce = true
				local Tween1 = Tw:Create(Root,TweenInfo.new(((Vector3.new(-28,8,-28) - Root.Position).Magnitude)/55, Enum.EasingStyle.Linear),{CFrame = CFrame.new(-28, 8, -28)})
				Tween1:Play()
				Tween1.Completed:Wait()
				local Tween2 = Tw:Create(Root,TweenInfo.new(((Vector3.new(-28,8,28) - Root.Position).Magnitude)/55, Enum.EasingStyle.Linear),{CFrame = CFrame.new(-28, 8, 28)})
				Tween2:Play()
				Tween2.Completed:Wait()
				local Tween3 = Tw:Create(Root,TweenInfo.new(((Vector3.new(28,8,28) - Root.Position).Magnitude)/55, Enum.EasingStyle.Linear),{CFrame = CFrame.new(28, 8, 28)})
				Tween3:Play()
				Tween3.Completed:Wait()
				local Tween4 = Tw:Create(Root,TweenInfo.new(((Vector3.new(28,8,-28) - Root.Position).Magnitude)/55, Enum.EasingStyle.Linear),{CFrame = CFrame.new(28, 8, -28)})
				Tween4:Play()
				Tween4.Completed:Wait()
				SpawnDebounce = false
			end
		end
	end))

	--Attach to back
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.AttachToBack then
		    local closest = closestPlayer(Root.Position, false, false)
			if closest then
				if (Root.Position - closest.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 20 then
					Root.CFrame = closest.Character:FindFirstChild("HumanoidRootPart").CFrame - closest.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5
				end
		  	end
		end
	end))

	--look at closest player
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.LookAt then
		    local target = closestPlayer(Root.Position, false, true)
			if target then
				char:SetPrimaryPartCFrame(CFrame.new(char.PrimaryPart.Position, Vector3.new(target.Character:FindFirstChild("HumanoidRootPart").Position.X, char.PrimaryPart.Position.Y, target.Character:FindFirstChild("HumanoidRootPart").Position.Z)))
			end
		end
	end))


	
	--Spin
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
    	if library.flags.Spin then
			Root.CFrame = Root.CFrame * CFrame.Angles(0,1,0)
		end
	end))

	mainMaid:GiveTask(runService.Heartbeat:connect(function()
    	if priorTarget ~= nil then
			if priorTarget.Character.Humanoid.Health <= 0 then return end
			local info = TweenInfo.new((((priorTarget.Character.Humanoid.RootPart.CFrame*CFrame.new(math.random(-30,30)/10,math.random(0,30)/10,math.random(-30,30)/10)).Position - char.Humanoid.RootPart.Position).Magnitude)/50,Enum.EasingStyle.Linear)
			local Tween = game:GetService("TweenService"):Create(Root, info, {["CFrame"] = ((priorTarget.Character.Humanoid.RootPart.CFrame * CFrame.new(math.random(-30,30)/10,math.random(0,30)/10,math.random(-30,30)/10)))})
			Tween:Play()
		end
	end))

	--Protect
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
    	if protect ~= nil then
			local protectRoot = protect.Character:FindFirstChild("HumanoidRootPart")
			local protectHumanoid = protect.Character:FindFirstChild("Humanoid")
			local target = closestPlayer(protectRoot.Position, false, false)

			if not protectHumanoid or not protectRoot then return end
			if protectHumanoid.Health <= 0 then return end

			if target then
				if (protectRoot.Position - target.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 25 then
					Root.CFrame = target.Character:FindFirstChild("HumanoidRootPart").CFrame - target.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 4
				else
					Root.CFrame = protectRoot.CFrame + protectRoot.CFrame.LookVector * 20
				end
			else
				Root.CFrame = protectRoot.CFrame + protectRoot.CFrame.LookVector * 20
			end
		end
	end))

	--Control
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
    	if controller ~= nil then
			local controllerRoot = controller.Character:FindFirstChild("HumanoidRootPart")
			local controllerHumanoid = controller.Character:FindFirstChild("Humanoid")

			if not controllerRoot or not controllerHumanoid then return end
			if controllerHumanoid.Health <= 0 then return end

			Root.CFrame = controllerRoot.CFrame + controllerRoot.CFrame.LookVector * 20
		end
	end))

	--auto rj
	local Dir = Core:FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay")
	Dir.DescendantAdded:Connect(function(Err)
		if Err.Name == "ErrorTitle" then
			Err:GetPropertyChangedSignal("Text"):Connect(function()
				if Err.Text:sub(0, 12) == "Disconnected" then
					if #game.Players:GetPlayers() <= 1 then
						client:Kick("\nRejoining...")
						wait()
						game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
					else
						game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, client)
					end
				end
			end)
		end
	end)

	--Autotp
	mainMaid:GiveTask(runService.Heartbeat:connect(function()
    	if library.flags.autoTp then
			if not autoTpDebounce then
				local target = closestPlayer(Root.Position, false, false)
				
				if target then
					if (Root.Position - target.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude <=30 then
						autoTpDebounce = true
						local pos = Root.CFrame
						Root.CFrame = target.Character:FindFirstChild("HumanoidRootPart").CFrame - target.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 4
						wait(0.1)
						Root.CFrame = pos
						wait(0.1)
						autoTpDebounce = false
					end
				end
			end
		end
	end))

	--------------------------------------------
	--COMMANDS
	--------------------------------------------

	--Whitelist Commands
	client.Chatted:Connect(function(Message)
        if string.len(Message) <= 1 then return end
		Message = string.split(Message, " ")
		if #Message <= 1 then return end

		local Command = string.lower(Message[1])
		local CmdType
		local Recipient
		if Message[2] then
			CmdType = string.lower(Message[2])
			if Message[3] then
				Recipient = FindPlayer(string.lower(Message[3]))
			end
		end
		
		if Command == prefix.."whitelist" or Command == prefix.."wl" then

			--adds player to whitelist
			if CmdType == "add" then
				local user = Players:FindFirstChild(Recipient)

				if user then
					table.insert(whitelist, user.UserId)
				end
			end

			--removes player from whitelist
			if CmdType == "remove" then
				local user = Players:FindFirstChild(Recipient)

				if user then
					for i, v in ipairs(whitelist) do
						if v == user.UserId then
							table.remove(whitelist, i)
						end
					end
				end
			end

			--turns whitelist on
			if CmdType == "on" then
					whitelistEnabled = true
			end

			--turns whitelist off
			if CmdType == "off" then
					whitelistEnabled = false
			end

			--empty's the whitelist
			if CmdType == "clear" then
				whitelist = {}
			end
		end
    end)

	-- control Commands
	client.Chatted:Connect(function(Message)
        if string.len(Message) <= 1 then return end
		Message = string.split(Message, " ")
		if #Message <= 1 then return end

		local Command = string.lower(Message[1])
		local Recipient
		if Message[2] then
			Recipient = FindPlayer(string.lower(Message[2]))
		end

		
		if Command == prefix.."control" or Command == prefix.."cont" then
			if Players:FindFirstChild(Recipient) then 
				controller = Players:FindFirstChild(Recipient)
			end
		end
    end)

	client.Chatted:Connect(function(Message)
        local cmd = string.lower(Message)
		if cmd == prefix.."uncontrol" or cmd == prefix.."uncont" or cmd == prefix.."stop" then
			controller = nil
		end
    end)


	-- Protect Commands
	client.Chatted:Connect(function(Message)
        if string.len(Message) <= 1 then return end
		Message = string.split(Message, " ")
		if #Message <= 1 then return end

		local Command = string.lower(Message[1])
		local Recipient
		if Message[2] then
			Recipient = FindPlayer(string.lower(Message[2]))
		end

		
		if Command == prefix.."protect" or Command == prefix.."prot" then
			if Players:FindFirstChild(Recipient) then 
				protect = Players:FindFirstChild(Recipient)
			end
		end
    end)

	client.Chatted:Connect(function(Message)
        local cmd = string.lower(Message)
		if cmd == prefix.."unprotect" or cmd == prefix.."unprot" or cmd == prefix.."stop" then
			protect = nil
		end
    end)

	--rejoin
	client.Chatted:Connect(function(msg)
		if string.lower(msg) == prefix.."rejoin" or string.lower(msg) == prefix.."rj" then
			game:GetService('TeleportService'):Teleport(game.PlaceId, plr)
		end
	end)

	--hop
	client.Chatted:Connect(function(msg)
		if string.lower(msg) == prefix.."hop" or string.lower(msg) == prefix.."serverhop" then
			local x = {}
			for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
				if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
					x[#x + 1] = v.id
				end
			end
			if #x > 0 then
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
			else
				StarterGui:SetCore("SendNotification", {Title = "No other servers found"})
			end
		end
	end)

	-- target Commands
	client.Chatted:Connect(function(Message)
        if string.len(Message) <= 1 then return end
		Message = string.split(Message, " ")
		if #Message <= 1 then return end

		local Command = string.lower(Message[1])
		local Recipient
		if Message[2] then
			Recipient = FindPlayer(string.lower(Message[2]))
		end

		
		if Command == prefix.."target" or Command == prefix.."tar" then
			if Players:FindFirstChild(Recipient) then 
				priorTarget = Players:FindFirstChild(Recipient)
			end
		end
    end)

	client.Chatted:Connect(function(Message)
        local cmd = string.lower(Message)
		if cmd == prefix.."untar" or cmd == prefix.."untarget" or cmd == prefix.."stop" then
			priorTarget = nil
		end
    end)

	--------------------------------------------
	--KEYBINDS
	--------------------------------------------
	UIS.InputBegan:Connect(function(Key)
		if Key.KeyCode == Enum.KeyCode.LeftControl  then
			Humanoid.WalkSpeed = 55
		end
	end)
	
	UIS.InputEnded:Connect(function(Key)
		if Key.KeyCode == Enum.KeyCode.LeftControl then
			Humanoid.WalkSpeed = 16
		end
	end)

--end initLogic
end

--[[Load on executed or on character spawned or executed]]
local character = client.Character
if (character) then
    coroutine.wrap(initLogic)(character)
end
client.CharacterAdded:connect(initLogic)

--Create Gui
local window = library:CreateWindow("36 Scripts")

local farm = window:AddFolder("Farming") -- Map for farming exploits
local combat = window:AddFolder("Combat") -- Map for combat exploits
local movement = window:AddFolder("Movement") -- Map for movement exploits
local visual = window:AddFolder("Visual") -- Map for visual exploits
farm:AddToggle({text = 'Auto Collect Box', flag = 'AutoFarm'}) -- Auto collect nearest unclaimed time box
combat:AddSlider({text = 'Reach Distance', min = 1, max = 25, value = 25, flag = 'ReachDistance'}) -- Makes u abled to change your reach distance
combat:AddToggle({text = 'Reach Enabled', flag = 'Reach'}) -- makes u abled to toggle your reach
combat:AddToggle({text = 'Auto Swing', flag = 'AutoSwing'}) -- Makes your sword swing by itself
combat:AddToggle({text = 'Spawn Kill', flag = 'SpawnKill'}) -- Circles Around Spawn
combat:AddToggle({text = 'Attach to back', flag = 'AttachToBack'}) -- teleports your character behind someone's back when they're in a certain reach
combat:AddToggle({text = 'Auto Tp', flag = 'autoTp'}) -- auto teleports and back if player in reach of 30 studs
combat:AddToggle({text = 'Auto Target', flag = 'AutoKiller'}) -- automaticly picks the closest target and kills them.
movement:AddToggle({text = 'Spin', flag = 'Spin'}) -- makes player spin
movement:AddToggle({text = 'Look at Closest Player', flag = 'LookAt'}) -- makes player Look at the closest player
movement:AddToggle({text = 'Lag Switcher', flag = 'Lag',callback = SwitchLag}) -- lag switch but still updates other players.
movement:AddToggle({text = 'Bhop', flag = 'BHop', callback = bhop}) --Fast and low jumps
visual:AddToggle({text = 'Kill Message', flag = 'KillMessage'}) -- says something in chat when killed someone
visual:AddToggle({text = 'Reach Visualizer', flag = 'ReachVisualizer'}) -- makes a sphere around your character indicating your reach distance
visual:AddToggle({text = "Solid Water", flag = "SolidWater", callback = solidWater})
visual:AddToggle({text = "Show Spawn", flag = "ShowSpawn", callback = ShowSpawn})
visual:AddToggle({text = "Show Target", flag = "ShowTarget"})
visual:AddToggle({text = "Always Show Time", flag = "ShowTime", callback = DisplayDistance})
window:AddLabel({text = 'Updated 30/3/2022'})
library:Init()
