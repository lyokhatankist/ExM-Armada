-- Cheat codes
-- $Id: cheats.lua,v 1.15 2005/07/06 12:55:55 anton Exp $


--------------------------------------------------
-- cheat codes for buka testers
--------------------------------------------------

function gameenc()
	AddPlayerVehicle("DestroyerCIT01")
	AddPlayerVehicle("DestroyerCIT02")
	AddPlayerVehicle("DestroyerCD01")
	AddPlayerVehicle("DestroyerCD02")
	AddPlayerVehicle("CruiserCIT01")
	AddPlayerVehicle("CruiserCIT02")
	AddPlayerVehicle("SmlboatCIT01")
	AddPlayerVehicle("SmlboatCIT02")
	AddPlayerVehicle("SmlboatCD01")
	AddPlayerVehicle("FastboatCIT01")
	AddPlayerVehicle("HeliCIT01")
	AddPlayerVehicle("HeliCD01")
	AddPlayerVehicle("DestroyerCIT01")
end

function boat(vae)
	local jop = 1
	if vae then
		jop = vae
	end
	if vae == 1 then
		AddPlayerVehicle("SmlboatCIT02")
	elseif vae == 2 then
		AddPlayerVehicle("SmlboatCD01")
	elseif vae == 3 then
		AddPlayerVehicle("FastboatCIT01")
	else
		pl = GetPlayerVehicle()
		boatPos = pl:GetPosition()
		boatPos.x = boatPos.x + 750
		plPos = pl:GetPosition()
		teamNamae = "boats"..random(99999)
		TeamCreate(teamNamae, 1002, boatPos, {"SmlboatCIT0"..random(2),"SmlboatCD01","FastboatCIT01"}, plPos, 1, Quaternion(0.000, -0.500, 0.000, 0.500))
		println(teamNamae.." (Pirate); "..boatPos.x..", "..boatPos.y..", "..boatPos.z)
	end
end

function ship()
	CreateEnemy("DestroyerCDTest")
end

function helifighttest()
	if testcheat()~=1 then return end
	pl = GetPlayerVehicle()
	citPos = pl:GetPosition()
	citPos.x = citPos.x + 750
	cdPos = pl:GetPosition()
	cdPos.x = cdPos.x - 750
	teamNamae = "heliPair"..random(99999)
	TeamCreate(teamNamae, 1016, citPos, {"HeliCIT0"..random(4),"HeliCIT0"..random(4)}, cdPos, 1, Quaternion(0.000, -0.500, 0.000, 0.500))
	println(teamNamae.." (CIT); "..citPos.x..", "..citPos.y..", "..citPos.z)
	citPos.x = citPos.x + 50
	teamNamae = "heliPair"..random(99999)
	TeamCreate(teamNamae, 1016, citPos, {"HeliCIT0"..random(4),"HeliCIT0"..random(4)}, cdPos, 1, Quaternion(0.000, -0.500, 0.000, 0.500))
	println(teamNamae.." (CIT); "..citPos.x..", "..citPos.y..", "..citPos.z)
	teamNamae = "heliFlight"..random(99999)
	TeamCreate(teamNamae, 1015, cdPos, {"HeliCD0"..random(4),"HeliCD0"..random(4),"HeliCD0"..random(4),"HeliCD0"..random(4)}, citPos, 1, Quaternion(0.000, 0.500, 0.000, 0.500))
	println(teamNamae.." (CD); "..cdPos.x..", "..cdPos.y..", "..cdPos.z)
	cdPos.x = cdPos.x - 50
	teamNamae = "heliFlight"..random(99999)
	TeamCreate(teamNamae, 1015, cdPos, {"HeliCD0"..random(4),"HeliCD0"..random(4),"HeliCD0"..random(4),"HeliCD0"..random(4)}, citPos, 1, Quaternion(0.000, 0.500, 0.000, 0.500))
	println(teamNamae.." (CD); "..cdPos.x..", "..cdPos.y..", "..cdPos.z)
end

function heliteamtest()
	if testcheat()~=1 then return end
	pl = GetPlayerVehicle()
	pos = GetCameraPos()
	plPos = pl:GetPosition()
	teamNamae = "heliTeam"..random(99999)
	TeamCreate(teamNamae, 1002, pos, {"HeliCIT01","HeliCD01"}, plPos, 1, Quaternion(0.000, 0.500, 0.000, 0.500))
	println(teamNamae.." (Test); "..pos.x..", "..pos.y..", "..pos.z)
	local heli02 = getObj(teamNamae.."_vehicle_1")
	heli02pos = getObj(heli02):GetPosition()
	heli02pos.z = heli02pos.z - 20
	heli02:SetPosition(heli02pos)
end

function heli1(vae)
	if testcheat()~=1 then return end
	local jop = 1
	if vae then
		jop = vae
	end
	if jop == 1 then
		CreateEnemy("HeliCIT01")
	elseif jop == 2 then
		pl = GetPlayerVehicle()
		pos = GetCameraPos()
		plPos = pl:GetPosition()
		teamNamae = "heliPair"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"HeliCIT0"..random(4),"HeliCIT0"..random(4)}, plPos, 1)
		println(teamNamae.." (CIT); "..pos.x..", "..pos.y..", "..pos.z)
	elseif jop == 3 then
		pl = GetPlayerVehicle()
		pos = GetCameraPos()
		plPos = pl:GetPosition()
		teamNamae = "heliPair"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"HeliCIT0"..random(4),"HeliCIT0"..random(4)}, plPos, 1)
		println(teamNamae.." (CIT); "..pos.x..", "..pos.y..", "..pos.z)
		pos.x = pos.x + 40
		teamNamae = "heliPair"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"HeliCIT0"..random(4),"HeliCIT0"..random(4)}, plPos, 1)
		println(teamNamae.." (CIT); "..pos.x..", "..pos.y..", "..pos.z)
	else
		AddPlayerVehicle("HeliCIT01")
	end
end

function heli2(vae)
	if testcheat()~=1 then return end
	local jop = 1
	if vae then
		jop = vae
	end
	if jop == 1 then
		CreateEnemy("HeliCD01")
	elseif jop == 2 then
		pl = GetPlayerVehicle()
		pos = GetCameraPos()
		plPos = pl:GetPosition()
		teamNamae = "heliFlight"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"HeliCD0"..random(4),"HeliCD0"..random(4),"HeliCD0"..random(4),"HeliCD0"..random(4)}, plPos, 1)
		println(teamNamae.." (CD); "..pos.x..", "..pos.y..", "..pos.z)
	elseif jop == 3 then
		pl = GetPlayerVehicle()
		pos = GetCameraPos()
		plPos = pl:GetPosition()
		teamNamae = "heliFlight"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"HeliCD0"..random(4),"HeliCD0"..random(4),"HeliCD0"..random(4),"HeliCD0"..random(4)}, plPos, 1)
		println(teamNamae.." (CD); "..pos.x..", "..pos.y..", "..pos.z)
		pos.x = pos.x + 40
		teamNamae = "heliFlight"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"HeliCD0"..random(4),"HeliCD0"..random(4),"HeliCD0"..random(4),"HeliCD0"..random(4)}, plPos, 1)
		println(teamNamae.." (CD); "..pos.x..", "..pos.y..", "..pos.z)
	else
		AddPlayerVehicle("HeliCD01")
	end
end

function dest1(vae)
	if testcheat()~=1 then return end
	local jop = 1
	if vae then
		jop = vae
	end
	if jop == 1 then
		CreateEnemy("DestroyerCIT01")
	elseif jop == 2 then
		pl = GetPlayerVehicle()
		pos = GetCameraPos()
		plPos = pl:GetPosition()
		teamNamae = "destroyerGroup"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"DestroyerCIT01","DestroyerCIT02","DestroyerCIT01"}, plPos, 1)
		println(teamNamae.." (CIT); "..pos)
	else
		AddPlayerVehicle("DestroyerCIT01")
	end
end

function dest2(vae)
	if testcheat()~=1 then return end
	local jop = 1
	if vae then
		jop = vae
	end
	if jop == 1 then
		CreateEnemy("DestroyerCD01")
	elseif jop == 2 then
		pl = GetPlayerVehicle()
		pos = GetCameraPos()
		plPos = pl:GetPosition()
		teamNamae = "destroyerGroup"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"DestroyerCD01","DestroyerCD02","DestroyerCD01"}, plPos, 1)
		println(teamNamae.." (CD); "..pos)
	else
		AddPlayerVehicle("DestroyerCD01")
	end
end

function cru1(vae)
	if testcheat()~=1 then return end
	local jop = 1
	if vae then
		jop = vae
	end
	if jop == 1 then
		CreateEnemy("CruiserCIT01")
	elseif jop == 2 then
		pl = GetPlayerVehicle()
		pos = GetCameraPos()
		plPos = pl:GetPosition()
		teamNamae = "cruiserGroup"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"CruiserCIT01","CruiserCIT02","CruiserCIT01"}, plPos, 1)
		println(teamNamae.." (CIT); "..pos)
	else
		AddPlayerVehicle("CruiserCIT01")
	end
end


function cru2(vae)
	if testcheat()~=1 then return end
	local jop = 1
	if vae then
		jop = vae
	end
	if jop == 1 then
		CreateEnemy("CruiserCD01")
	elseif jop == 2 then
		pl = GetPlayerVehicle()
		pos = GetCameraPos()
		plPos = pl:GetPosition()
		teamNamae = "cruiserGroup"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"CruiserCD01","CruiserCD01"}, plPos, 1)
		println(teamNamae.." (CD); "..pos)
	else
		AddPlayerVehicle("CruiserCD01")
	end
end

function bat2(vae)
	if testcheat()~=1 then return end
	local jop = 1
	if vae then
		jop = vae
	end
	if jop == 1 then
		CreateEnemy("BattleshipCD01")
	elseif jop == 2 then
		pl = GetPlayerVehicle()
		pos = GetCameraPos()
		plPos = pl:GetPosition()
		teamNamae = "battleshipGroup"..random(99999)
		TeamCreate(teamNamae, 1002, pos, {"BattleshipCD01","BattleshipCD02"}, plPos, 1)
		println(teamNamae.." (CD); "..pos)
	else
		AddPlayerVehicle("BattleshipCD01")
	end
end

function retro(vae)
	if testcheat()~=1 then return end
	local jop = 1
	if vae then
		jop = vae
	end
	local ass = GetPlayerVehicle():GetProperty("Prototype").AsString
	println(ass)
	for i=0,9 do
		println(i)
		ass = gsub(ass, i, "")
	end
	println(ass)
	if (ass ~= "HeliCD") or (ass ~= "HeliCIT") then
		if jop == 1 then
			AddPlayerVehicle(ass.."02")
		else
			AddPlayerVehicle(ass.."01")
		end
	end
end

function speedmeup()
	if testcheat()~=1 then return end

	local v = GetPlayerVehicle()

	v:SetMaxTorque(10000)
	v:SetMaxSpeed(10000)
end

function gimmegimmegimme()
		if testcheat()~=1 then return end

		AddPlayerMoney( 10000 )
		println( "Money added" )

		local v = GetPlayerVehicle()

		v:AddModifier( "maxhp", "+ 10000" )
		v:AddModifier( "hp", "+ 10000" )
		println( "HP added" )

		v:AddModifier( "maxfuel", "+ 10000" )
		v:AddModifier( "fuel", "+ 10000" )
		println( "Fuel added" )
end

function GiveMoney(money)
	if testcheat()~=1 then return end
	local mmm=1000
	if money then mmm=money end
	AddPlayerMoney(mmm)
end

function GiveAll()
	if testcheat()~=1 then return end
	gimmegimmegimme()
end

function GiveVehicle(num)
	if testcheat()~=1 then return end
	local model="Bug01"
	if num==1 then
		model="Bug01"
	elseif num==2 then
		model="Molokovoz01"
	elseif num==3 then
		model="Ural01"
	elseif num==4 then
		model="Belaz01"
	elseif num==5 then
		model="mirotvorecTest"
	elseif num==6 then
		model="CoolBelaz"
	elseif num==7 then
		model="Revolutioner1"
	elseif num==8 then
		model="Hunter01"
	elseif num==9 then
		model="ArcadeScout01"
	elseif num==10 then
		model="UralShot"		
	elseif num==11 then
		model="BelazShot"		
	elseif num==12 then
		model="MirotvorecShot"		
        elseif num==13 then
		model="Cruiser01"		
	elseif num==14 then
		model="Dozer01"
	elseif num==15 then
		model="Hunter01"
	elseif num==16 then
		model="Hunter02"
        elseif num==17 then
		model="Fighter01"
	elseif num==18 then
		model="Fighter02"
	elseif num==19 then
		model="Scout01"
	elseif num==20 then
		model="Scout02"
	elseif num==21 then
		model="Scout03"
	elseif num==22 then
		model="Tank01"
	elseif num==23 then
		model="RobotBobot01"
	elseif num==24 then
		model="RobotBobot02"
	elseif num==25 then
		model="RobotMetatron"
	end
	AddPlayerVehicle(model)
end

function ShowMap()
	local mapsize = GET_GLOBAL_OBJECT( "CurrentLevel" ):GetLandSize() * 128
	local mapname = GET_GLOBAL_OBJECT( "CurrentLevel" ):GetLevelName()
	ShowRectOnMinimap(mapname, 1, 1, mapsize, mapsize)
end

--Ñ´Ô Å„≠†™Æ¢† :)

function god (md)
	if testcheat()~=1 then return end
	local mode=1
	if md then mode=md end
	GetPlayerVehicle():setGodMode(mode)  
end

function truck (number)
	GiveVehicle (number)
end

function car (number)
	GiveVehicle (number)
end

function skin (num)
    local number=0
    if num then number=num end
	GetPlayerVehicle():SetSkin(number)
end

function giveall ()
	if testcheat()~=1 then return end
	AddPlayerMoney( 10000 )

	local v = GetPlayerVehicle()

	v:AddModifier( "maxhp", "+ 10000" )
	v:AddModifier( "hp", "+ 15000" )

	v:AddModifier( "maxfuel", "+ 10000" )
	v:AddModifier( "fuel", "+ 11000" )
end

function teleport ()
	if testcheat()~=1 then return end
	MovePlayerToCamera()
end

function cab (num)
	if testcheat()~=1 then return end
   local number=1
   if num then number=num end
   local curcab=GetPlayerVehicle():GetCabin():GetProperty("Prototype").AsString
   local len=strlen(curcab)
   local newcab=strsub(curcab, 1, len-1)..number
   GetPlayerVehicle():SetNewPart("CABIN",newcab)
end

function cargo (num)
	if testcheat()~=1 then return end
   local number=1
   if num then number=num end
   local curcargo=GetPlayerVehicle():GetBasket():GetProperty("Prototype").AsString
   local len=strlen(curcargo)
   local newcargo=strsub(curcargo, 1, len-1)..number
   GetPlayerVehicle():SetNewPart("BASKET",newcargo)
end

function giveguns ()
--éêìÜàÖ
	if testcheat()~=1 then return end
			local veh=GetPlayerVehicle()
			local parts={"CABIN_","BASKET_","CHASSIS_"}
			local slots={"SMALL_","BIG_","GIANT_","SIDE_"}
			local guns={"GUN","GUN_0","GUN_1","GUN_2"}
			local smallgun={"hornet01","specter01","pkt01","kord01","maxim01","storm01","fagot01"}
			local biggun={"rapier01","vector01","vulcan01","flag01","kpvt01","rainmetal01","elephant01","odin01","bumblebee01","omega01"}
			local giantgun={"cyclops01","octopus01","hurricane01","rocketLauncher","big_swingfire01"}
			local sidegun={"hailSideGun","marsSideGun","zeusSideGun","hunterSideGun"}
			local i,j,k=1,1,1
			while parts[i] do
				while slots[j] do
					while guns[k] do
--						LOG(parts[i]..slots[j]..guns[k])
						local gun=1
						local slot=parts[i]..slots[j]..guns[k]
						if j==1 then
							gun=smallgun[random(7)]
						elseif j==2 then
							gun=biggun[random(10)]
						elseif j==3 then
							gun=giantgun[random(5)]
						elseif j==4 then
							gun=sidegun[random(4)]
						end

--						LOG(gun)
						if veh:CanPartBeAttached(slot) then
						    LOG(slot.." -- "..gun)
							veh:SetNewPart(slot,gun)
						end
						k=k+1
					end
					k=1
					j=j+1
				end
				j=1
				i=i+1
			end
end

function map ()
	ShowMap()
end

function givemoney(money)
	if testcheat()~=1 then return end
	local mmm=1000
	if money then mmm=money end
	AddPlayerMoney(mmm)
end

function suicide()
	GetPlayerVehicle():AddModifier( "hp", "= 0" )
end


function OpenEncyclopaedia()
	Journal:ShowAllInEncyclopaedia()
end

function testcheat()
    if	GetComputerName() == "JSINX" 	or GetComputerName() == "ANTON2" 	or
		GetComputerName() == "MIF2000"	or GetComputerName() == "HRRR" 		or
		GetComputerName() == "PHOSGEN" 	or GetComputerName() == "ALEXTG" 	or
		GetComputerName() == "MAIN" 	or GetComputerName() == "POWERPLANT" 	or
		GetComputerName() == "VANO" 	or GetComputerName() == "STAZ" 		then
		return 1
	end
	if anticheat==0 then	
		LOG("---------------------- CHEAT WAS USED --------- ANTICHEAT -----------------")
    	AddFadingMsgId( "fm_cheat_is_allowed" )
    	AddImportantFadingMsgId( "fm_cheat_is_allowed" )
		return 1
 	else
		LOG("---------------------- CHEAT CAN'T BE USED ---- ANTICHEAT -----------------")
    	AddFadingMsgId( "fm_cheat_is_not_allowed" )
    	AddImportantFadingMsgId( "fm_cheat_is_not_allowed" )
    	return 0
 	end
end


