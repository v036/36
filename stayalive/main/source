-----------------------------------------
		--BY 36--
-----------------------------------------

--Customization
local whitelist = {} --default whitelist (userId)
local staff = {}
local prefix = "/"

--Services
local Players = game:GetService("Players")
local runService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

--Variables
local BodyParts = {"HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Head"}
local client = Players.localPlayer
local whitelistEnabled = true

--Library's
local maid = loadstring(game:HttpGet'https://raw.githubusercontent.com/Yorxq/scripts/main/Maid.lua')()
local library = loadstring(game:HttpGet'https://raw.githubusercontent.com/Yorxq/scripts/main/GuiLibrary.lua')()
local mainMaid = maid.new()

--Anticheat bypass
if not _G.LoadedAntiCheat or _G.LoadedAntiCheat == nil then --Makes anticheat only load once.
	loadstring(game:HttpGet'https://raw.githubusercontent.com/Yorxq/scripts/main/Bypass.lua')()
	_G.LoadedAntiCheat = true
end

--functions
local function speed()
    if library.flags.Speed then
        local char = client.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        humanoid.WalkSpeed = 55
    else
        local char = client.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        humanoid.WalkSpeed = 16
    end
end

--auto complete player name for commands
local function FindPlayer(name)
	for i,v in pairs(game.Players:GetPlayers()) do
		if v.Name:lower():sub(1,#name) == name:lower() then
			return v.Name
		end
	end
end

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
		StarterGui:SetCore("SendNotification", {Title = "A staff member joined",Text = "You will be teleported in a second.."})
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

--initLogic
local function initLogic(char)
    
    mainMaid:DoCleaning()
	local Humanoid = char:WaitForChild("Humanoid", 10)
	local Root = char:WaitForChild("HumanoidRootPart", 10)
	if not Root or not Humanoid then return end

    mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.AutoSwing then
			local sword = char:FindFirstChildOfClass("Tool")
			if not sword then return end
			sword:Activate()
		end
	end))

    mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.Reach then
			local sword = char:FindFirstChildOfClass("Tool")

			if not sword then return end

			local handle = sword.Handle
			
			if not handle then return end
			
			for _, player in pairs(Players:GetChildren()) do
				if player == client then continue end

				local pChar = player.Character
				if not pChar then continue end
				local pRoot = pChar:FindFirstChild("HumanoidRootPart")
				local pHumanoid = pChar:FindFirstChild("Humanoid")

				if not pHumanoid or not pRoot then continue end
				if whitelistEnabled then
					if table.find(whitelist, player.UserId) then continue end
				end

				if pHumanoid.Health > 0 and Humanoid.Health > 0 and (pRoot.Position - Root.Position).Magnitude <= library.flags.ReachDistance then 
					for i,part in pairs(pChar:GetChildren()) do
						if table.find(BodyParts,part.Name) then
							for i = 1, 20 do
								firetouchinterest(handle, part, 0) 
								firetouchinterest(handle, part, 1)
								firetouchinterest(handle, part, 0) 
							end
						end
					end
				end
			end
		end
	end))

    --speed
    mainMaid:GiveTask(runService.Heartbeat:connect(function()
		if library.flags.Speed then
            if Humanoid.WalkSpeed ~= 55 then
                Humanoid.WalkSpeed = 55
            end
        else
            if Humanoid.WalkSpeed ~= 16 then
                Humanoid.WalkSpeed = 16
            end
        end
	end))

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

end

--Load on executed or on character spawned or executed
local character = client.Character
if (character) then
    coroutine.wrap(initLogic)(character)
end
client.CharacterAdded:connect(initLogic)

--creates gui
local window = library:CreateWindow("Stay Alive")
window:AddSlider({text = 'Reach Distance', min = 1, max = 25, value = 25, flag = 'ReachDistance'}) -- Makes u abled to change your reach distance
window:AddToggle({text = 'Reach Enabled', flag = 'Reach'}) -- makes u abled to toggle your reach
window:AddToggle({text = 'Auto Swing', flag = 'AutoSwing'}) -- Makes your sword swing by itself
window:AddToggle({text = 'Speed', flag = 'Speed', callback = speed})
window:AddLabel({text = 'Updated 29/3/2022'})
library:Init()
