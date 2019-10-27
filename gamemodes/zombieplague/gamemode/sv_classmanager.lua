ClassManager = {
	ZombieClasses = {},
	HumanClasses = {}
}
function ClassManager:SearchClasses()
	include("zombieplague/gamemode/classes/zpclass_defaultclasses.lua")
	
	local Files = file.Find("zombieplague/gamemode/classes/zombies/*.lua", "LUA")
	if Files then
		for k, File in pairs(Files) do
			ZPClass = ClassManager:NewZombieClass()
			include("zombieplague/gamemode/classes/zombies/" .. File)
			
			if(ZPClass:ShouldBeEnabled()) then
				ClassManager:AddZombieClass(ZPClass)
			end
		end
	end
	
	Files = file.Find("zombieplague/gamemode/classes/humans/*.lua", "LUA")
	if Files then
		for k, File in pairs(Files) do
			ZPClass = ClassManager:NewHumanClass()
			include("zombieplague/gamemode/classes/humans/" .. File)
			
			if(ZPClass:ShouldBeEnabled()) then
				ClassManager:AddHumanClass(ZPClass)
			end
		end
	end
end
function ClassManager:GetZombieClasses()
	return ClassManager.ZombieClasses
end
function ClassManager:GetHumanClasses()
	return ClassManager.HumanClasses
end
function ClassManager:AddZombieClass(ZombieClass)
	resource.AddFile(ZombieClass.PModel)
	table.insert(ClassManager.ZombieClasses, ZombieClass)
end
function ClassManager:GetZombieClass(ID)
	return ClassManager:GetZombieClasses()[ID]
end
function ClassManager:AddHumanClass(HumanClass)
	resource.AddFile(HumanClass.PModel)
	table.insert(ClassManager.HumanClasses, HumanClass)
end
function ClassManager:NewHumanClass()
	return {Name = "HumanDefaultClassName",
		Description = "HumanDefaultClassDescription",
		MaxHealth = 100,
		Armor = 0,
		PModel = "models/player/gasmask.mdl",
		Speed = 240,
		RunSpeed = 250,
		CrouchSpeed = 0.4,
		Gravity = 1,
		Battery = 100,
		Breath = 100,
		JumpPower = 170,
		Footstep = true,
		DamageAmplifier = 1,
		FallFunction = function()return true end,
		ShouldBeEnabled = function()return true end,
	}
end
function ClassManager:NewZombieClass()
	local ZombieClass = {Name = "ZombieDefaultClassName",
		Description = "ZombieDefaultClassDescription",
		MaxHealth = 2000,
		PModel = "models/player/zombie_classic.mdl",
		Speed = 250,
		RunSpeed = 260,
		CrouchSpeed = 0.4,
		Gravity = 1,
		Breath = 100,
		Footstep = false,
		JumpPower = 170,
		DamageAmplifier = 1,
		FallFunction = function()return false end,
		ShouldBeEnabled = function()return true end,
	}
	function ZombieClass:WeaponGive(ply)
		ply:Give(ZOMBIE_KNIFE)
	end
	return ZombieClass
end
function ClassManager:GetHumanClass(ID)
	return ClassManager:GetHumanClasses()[ID]
end
function ClassManager:SetUserZombieClass(ply, ID)
	ply:SetZombieClass(ClassManager:GetZombieClass(ID))
end
function ClassManager:SetUserHumanClass(ply, ID)
	ply:SetHumanClass(ClassManager:GetHumanClass(ID))
end
function ClassManager:OpenHumanMenu(ply)
	local Pretty = {}
	for k, HClass in pairs(ClassManager:GetHumanClasses()) do
		table.insert(Pretty, Dictionary:GetPhrase(HClass.Name, ply) .. " - " .. Dictionary:GetPhrase(HClass.Description, ply))
	end
	
	net.Start("OpenBackMenu")
		net.WriteString("SendHumanClass")
		net.WriteTable(Pretty)
	net.Send(ply)
end
function ClassManager:OpenZombieMenu(ply)
	local Pretty = {}
	for k, ZClass in pairs(ClassManager:GetZombieClasses()) do
		table.insert(Pretty, Dictionary:GetPhrase(ZClass.Name, ply) .. " - " .. Dictionary:GetPhrase(ZClass.Description, ply))
	end
	
	net.Start("OpenBackMenu")
		net.WriteString("SendZombieClass")
		net.WriteTable(Pretty)
	net.Send(ply)
end

net.Receive("SendHumanClass", function(len, ply)
	ply:SetNextHumanClass(net.ReadInt(16))
end)
net.Receive("SendZombieClass", function(len, ply)
	ply:SetNextZombieClass(net.ReadInt(16))
end)
Commands:AddCommand("zombies", "Open zombie class menu.", function(ply, args)
	ClassManager:OpenZombieMenu(ply)
end)
Commands:AddCommand("humans", "Open human class menu.", function(ply, args)
	ClassManager:OpenHumanMenu(ply)
end)
net.Receive("RequestZombieMenu", function(len, ply)
	ClassManager:OpenZombieMenu(ply)
end)
net.Receive("RequestHumanMenu", function(len, ply)
	ClassManager:OpenHumanMenu(ply)
end)

util.AddNetworkString("RequestZombieMenu")
util.AddNetworkString("RequestHumanMenu")
util.AddNetworkString("SendHumanClass")
util.AddNetworkString("SendZombieClass")