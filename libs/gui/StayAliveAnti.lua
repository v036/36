local namecall
local newindex
local hook1
local hook2
local hook3

game:GetService("ScriptContext"):SetTimeout(0.1)

local function die(con)
    for i,v in pairs(getconnections(con)) do
        v:Disable()
    end
end

local function CharacterAdded(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    die(Humanoid:GetPropertyChangedSignal("WalkSpeed"))
    die(Humanoid:GetPropertyChangedSignal("JumpPower"))
    die(Humanoid:GetPropertyChangedSignal("HipHeight"))
end

newindex = hookmetamethod(game,"__newindex",newcclosure(function(self,prop,value)
    if prop == "Parent" and value == nil and getcallingscript() and tostring(getcallingscript()) == "Anticheat" then
        return
    end

    return newindex(self,prop,value)
end))

namecall = hookmetamethod(game,"__namecall",newcclosure(function(...)
    if checkcaller() then return namecall(...) end

    local self,caller,method,args = ...,getcallingscript(),getnamecallmethod(),{...}; table.remove(args,1)

    if method == "FireServer" then
        if tostring(self) == "2Event" then
            return
        end
    elseif method == "ClearAllChildren" then
        --return
    elseif method == "Clone" then

    end

    return namecall(...)
end))

hook1 = hookfunction(Instance.new("Part").Destroy,function(...)
    if not checkcaller() then
        return
    end
    return hook1(...)
end)
hook2 = hookfunction(Instance.new("Part").ClearAllChildren,function(...)
    if not checkcaller() then
        return
    end
    return hook2(...)
end)
hook3 = hookfunction(Instance.new("Part").Clone,function(...)
    if not checkcaller() then
        return
    end
    return hook3(...)
end)

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(CharacterAdded)
if game:GetService("Players").LocalPlayer.Character then
    CharacterAdded(game:GetService("Players").LocalPlayer.Character)
end
