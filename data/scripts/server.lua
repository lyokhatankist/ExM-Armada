-- ----------------------------------------------------------------------------
-- 
-- Workfile: server.lua
-- Created by: Plus
-- Copyright (C) 2000-2003 Targem Ltd. All rights reserved.
-- 
-- Global server related stuff. This script is executed on server init,
-- from CServer::Init().
-- 
-- ----------------------------------------------------------------------------
--  $Id: server.lua,v 1.53 2005/07/26 09:06:59 anton Exp $
-- ----------------------------------------------------------------------------
anticheat = 0
-- include cheats.lua
EXECUTE_SCRIPT "data\\scripts\\cheats.lua"

-- include debug.lua
EXECUTE_SCRIPT "data\\scripts\\debug.lua"

-- include AIReader.lua
EXECUTE_SCRIPT "data\\scripts\\AIReader.lua"


-- include dialoghelpers.lua
EXECUTE_SCRIPT "data\\scripts\\dialoghelpers.lua"

-- include queststates.lua
EXECUTE_SCRIPT "data\\scripts\\queststates.lua"

-- global object repository
g_ObjCont = GET_GLOBAL_OBJECT "g_ObjContainer"

if not g_ObjCont then
	LOG "Could not find global g_ObjContainer!!!"
end

-- global quest info manager
g_QuestStateManager = GET_GLOBAL_OBJECT "g_QuestStateManager"

if not g_QuestStateManager then
	LOG "Could not find global g_QuestStateManager!!!"
end

-- global quest info manager
-- g_Player = GET_GLOBAL_OBJECT "g_Player"

-- if not g_Player then
--	LOG "Could not find global g_Player!!!"
-- end


LEVEL_SIZE = 8*32.0
g_Level = GET_GLOBAL_OBJECT "CurrentLevel"
if g_Level then
	LEVEL_SIZE = g_Level:GetLandSize()*32.0
else
end


-- Initializes global player. Called from code when the map is loaded
function InitPlayer()
	g_Player = GET_GLOBAL_OBJECT "g_Player"

	if not g_Player then
 		LOG "Could not find global g_Player!!!"
        else
                GameFiltersUse()
	end
end


-- shortcut: returns Game Object via name
function GetEntityByName( name )
	return g_ObjCont:GetEntityByObjName( name )
end


-- shortcut: returns Game Object via ID
function GetEntityByID( id )
	return g_ObjCont:GetEntityByObjId( id )
end


-- shortcut: creates Game Object and all it's children, returns it's handler (ID)
local function _CreateNewObject( prototypeName, objName, parentId, belong )
	local prototypeId = g_ObjCont:GetPrototypeId( prototypeName )

	return g_ObjCont:CreateNewObject( prototypeId, objName, parentId, belong )
end


-- shortcut: object constructor
function CreateNewObject( arg )
	if not arg.parentId then 
		arg.parentId = -1 
	end
	
	if not arg.belong then 
		arg.belong = 1001 
	end
	
	return _CreateNewObject( arg.prototypeName, arg.objName, arg.parentId, arg.belong )
end


-- these ought to match those ones in Relationship.h
RS_ENEMY	= 1
RS_NEUTRAL	= 2
RS_ALLY		= 3
RS_OWN		= 4


-- safe object remove
function RemoveObject( GameObject )
	GameObject:Remove()
	GameObject = nil
end


--Activate trigger
function TActivate( TriggerName )
	local trig1 = GetEntityByName(TriggerName)
	if trig1 then 
		trig1:Activate() 
	end
end


--Deactivate trigger
function TDeactivate( TriggerName )
	local trig1 = GetEntityByName(TriggerName)
	if trig1 then 
		trig1:Deactivate() 
	end
end


function SetVar(Name, Value)
	local trig1 = GetEntityByName("GlobalVar")
	if trig1 then 
		local tmpv=Value
	 	if type(Value)=="table" then
	 		tmpv=Value[1]
	 		for i=2,getn(Value) do
	 			tmpv=tmpv.." "..Value[i]
	 		end
	 	end
		local GAIParam v = tmpv
		trig1:SetVar(Name, v ) 
	end
end


function GetVar(Name)
	local trig1 = GetEntityByName("GlobalVar")
	if trig1 then 
		return trig1:Var(Name) 
	else
		return nil
	end
end


function SetTolerance( ID1, ID2, Tol )
	g_ObjCont:SetTolerance( ID1, ID2, Tol )
end


function GetTolerance( ID1, ID2 )
	return g_ObjCont:GetTolerance( ID1, ID2 )
end


function IncTolerance( ID1, ID2, Tol )
	g_ObjCont:IncTolerance( ID1, ID2, Tol )
end


CINEMATIC_AIM_TO_ID 	= 1
CINEMATIC_AIM_TO_POINT	= 2
CINEMATIC_FROM_POS		= 3
CINEMATIC_NO_AIM		= 4

function FlyLinked( PathName, Id, PlayTime, StartFade, EndFade, LookToId, VisPanel, RelativeRotations, 
	WaitWhenStop, InterpolateFromPrevious )
	
	local cinematic = GetCinematic()
--	RuleConsole("FogOfWar 0")	

	SetCinematicFadeParams( StartFade, EndFade )

	ChangeMode("GS_CINEMATIC")
	--cinematic:ResetAim()
	
	if VisPanel ~= nil then
        	SetCinematicCinemaPanel( VisPanel )
	else
                SetCinematicCinemaPanel( 1 )
	end

	cinematic:Load("camera_paths.xml")
	cinematic:SetPath(PathName)	

	cinematic:SetRelativePoints(1)
	cinematic:SetRelativeRotations(0)
	cinematic:SetBaseToId(Id)

	if LookToId then
		cinematic:SetAimToID( LookToId )
		cinematic:SetLookTo( true )
	else
		cinematic:SetRelativeRotations(  RelativeRotations )
		cinematic:SetLookTo( false )
	end

	cinematic:SetWaitWhenStop( WaitWhenStop )
	cinematic:SetLerpFromPreviousItem( InterpolateFromPrevious )

	cinematic:Play( PlayTime )
end

-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
function FlyAround( Phi, Theta, Radius, PlayTime, curPos, Id, StartFade, EndFade, PathName, VisPanel,
	WaitWhenStop, InterpolateFromPrevious )
	
	local cinematic = GetCinematic()
--	RuleConsole("FogOfWar 0")

	SetCinematicFadeParams( StartFade, EndFade )
	
	if not cinematic then
		println( "Error: couldn't get cinematic" )
		return
	end
	
	if not PathName then
		PathName = ""
	end	

	ReadyCinematic()	
--	ChangeMode("GS_CINEMATIC")
--	cinematic:ResetAim()
	cinematic:SetAimToID(Id)

	if VisPanel then
        	SetCinematicCinemaPanel( VisPanel )
	else
                SetCinematicCinemaPanel( 1 )
	end

	cinematic:SetWaitWhenStop( WaitWhenStop )
	cinematic:SetLerpFromPreviousItem( InterpolateFromPrevious )

	cinematic:FlyAround( Phi, Theta, Radius, PlayTime, curPos, PathName )
end

-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅ
function Fly( PathName, AimType, Target, Time, StartFade, EndFade, VisPanel,
	WaitWhenStop, InterpolateFromPrevious )
	
	local cinematic = GetCinematic()
--	RuleConsole("FogOfWar 0")

	if not cinematic then
		println( "Error: couldn't get cinematic" )
		return
	end

	if not StartFade then
		println( "Error: StartFade parameter missing" )
		return
	end

	if not EndFade then
		println( "Error: EndFade parameter missing" )
		return
	end
	
--	ReadyCinematic()
	cinematic:Load("camera_paths.xml")
	SetCinematicFadeParams( StartFade, EndFade )
	ChangeMode("GS_CINEMATIC")
	--cinematic:ResetAim()

	if VisPanel ~= nil then
        	SetCinematicCinemaPanel( VisPanel )
	else
                SetCinematicCinemaPanel( 1 )
	end

	--cinematic:SetPath(PathName)

	if AimType == CINEMATIC_AIM_TO_ID then 
		cinematic:SetAimToID( Target )
		cinematic:SetLookTo( true )
	end
	
	if AimType == CINEMATIC_AIM_TO_POINT then 
		cinematic:SetAim( Target )
		cinematic:SetLookTo( true )
	end	
	
	if AimType == CINEMATIC_FROM_POS or AimType == CINEMATIC_NO_AIM then 
		cinematic:SetLookTo( false )
	end
	
	if AimType == CINEMATIC_FROM_POS then 
		local pos, rot, lookAt = GetCameraPos()
		cinematic:SetPathFromPos( pos, rot, PathName )
	else
		cinematic:SetPath( PathName )
	end

	cinematic:SetRelativePoints( false )
	cinematic:SetRelativeRotations( false )

	cinematic:SetWaitWhenStop( WaitWhenStop )
	cinematic:SetLerpFromPreviousItem( InterpolateFromPrevious )
	
	cinematic:Play(Time)		
end

-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
function StartCinematic()
	local cinematic = GetCinematic()
	cinematic:StartCinematic()
	
	if g_CinemaPanel then
		g_CinemaPanel:ClearMessages()	
	end
	
	UpdateCinematic( 0 ) -- by Anton: don't touch this!
end

-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
function ReadyCinematic()
	local cinematic = GetCinematic()
	
	if not cinematic then
		println( "Error: couldn't get cinematic" )
		return
	end

	cinematic:Load("camera_paths.xml")
	ChangeMode("GS_CINEMATIC")
end


function FlyStandard( PathName, Time )
	Fly( PathName, CINEMATIC_NO_AIM, nil, Time, 1, 1 )
end



-- shortcut: Play Camera rout   
function FlyCamera( PathName, AimType, Target, Time, StartFade, EndFade )
	Fly( PathName, AimType, Target, Time, StartFade, EndFade )
end


function FlyCameraHoldMode( PathName, AimType, Target, Time )
	Fly( PathName, AimType, Target, Time, 1, 0 )
end


function GameCamera()
	ChangeMode("GS_GAME")
	EndCinematic()
	if (GetVar("PlayerModel").AsInt == 1) then
		ShowPlayerModel(1)
		SetVar("PlayerModel", 2)
	end                         
	local oldSpeed = GetVar("Speed").AsFloat
	if oldSpeed == 0 then
	  oldSpeed = 1 
	end
	SetGameSpeed( oldSpeed )
	local IsSetCameraPos = GetVar("IsSetCameraPos").AsInt
	if IsSetCameraPos == 1 then
		SetCameraPos(GetVar("campos").AsVector, GetVar("yaw").AsFloat, GetVar("pitch").AsFloat, GetVar("roll").AsFloat)
-- 		println("IsSetCameraPos")
	end
	SetVar("IsSetCameraPos",0)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ			
	local DA = getObj("Destroy_Actors")
	if not(DA) then	
		RemoveAPlayer()	
	else
		DA:SetVar( "NPCID", 0 )
		DA:Activate()
	end
-- 	пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅ-пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ npc_fly
	local NPCID = GetVar( "NPCID" ).AsInt
--	println(NPCID)	
	if ( NPCID > 0 ) then
		SetVar( "NPCID", 0 )
		if GetEntityByID( NPCID ) then
			GetEntityByID( NPCID ):AddModifier( "Belong", "= "..tostring( GetVar( "NPCBelong" ).AsInt ) )
			if GetVar( "NPCH" ).AsInt == 1 then 
				if DA then
					DA:SetVar( "NPCID", NPCID )
				else
					GetEntityByID( NPCID ):Hide() 
				end
			end
		end
	end
end


-- Constants for units animations
AT_STAND1		=	0
AT_STAND2		=	1
AT_MOVE1		=	2
AT_MOVE2		=	3
AT_ATTACK1		=	4
AT_ATTACK2		=	5
AT_PAIN1		=	6
AT_PAIN2		=	7
AT_DEATH1		=	8
AT_DEATH2		=	9
AT_BLOCK1		=	10
AT_BLOCK2		=	11
AT_RESERVED1	=	12
AT_RESERVED2	=	13
AT_RESERVED3	=	14
AT_RESERVED4	=	15

function getObj( name )
	local obj = nil
	if type(name) == "string" then
		obj = GetEntityByName( name )
	else if type(name) == "number" then 
			obj = GetEntityByID( name )
		else
			obj = name
	    end
	end
	return obj
end


function GetCurNpc()
	return GET_GLOBAL_OBJECT "g_CurrentNpc"
end

Q_UNKNOWN		=	0
Q_CANBEGIVEN	=	1
Q_TAKEN			=	2
Q_COMPLETED		=	3
Q_FAILED		=	4

function QuestStatus(name)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ name
-- 0 - пїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅ пїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅпїЅпїЅ
-- 1 - пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅпїЅпїЅ
-- 2 - пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ (пїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ)
-- 3 - пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
-- 4 - пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
	local Stat=Q_UNKNOWN
	if		CanQuestBeGiven(name)	then Stat=Q_CANBEGIVEN
	elseif	IsQuestFailed(name)		then Stat=Q_FAILED
	elseif	IsQuestComplete(name)	then Stat=Q_COMPLETED
	elseif	IsQuestTaken(name)		then Stat=Q_TAKEN
	end
	return Stat
end

function TeamCreate(Name, Belong, CreatePos, ListOfVehicle, WalkPos, IsWares, Rotate)
	return CreateTeam(Name, Belong, CreatePos, ListOfVehicle, WalkPos, IsWares, Rotate)
end

function CreateTeam(Name, Belong, CreatePos, ListOfVehicle, WalkPos, IsWares, Rotate)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ ListOfVehicle, пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ Name пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ Belong, пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ CreatePos.
-- EпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ, пїЅпїЅ пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ WalkPos
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ(пїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅ), пїЅпїЅпїЅпїЅ 0 - пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
-- IsWares - 1 пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ
-- Rotate - пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ
-- пїЅпїЅпїЅпїЅпїЅпїЅ:
-- TeamCreate("ExtrGuardTeam",1012,CVector(985.260, 306.000, 2541.873),{"Revolutioner1","Revolutioner2","Bug01","Bug01","Revolutioner2"})
-- пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ 5 пїЅпїЅпїЅпїЅпїЅ. пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ ExtrGuardTeam, пїЅ пїЅ пїЅпїЅпїЅпїЅпїЅ
-- ExtrGuardTeam_vehicle_0, ExtrGuardTeam_vehicle_1, .. ExtrGuardTeam_vehicle_4.
-- пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅ Z (пїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ). 
	local teamID = CreateNewObject{
			prototypeName = "team",
			objName = Name,
			belong = Belong
		}
	local team=GetEntityByID(teamID)
	if team then
--	   println("team created")
	   local i=1
	   local id=0
	   while ListOfVehicle[i] do
		 local id = CreateNewObject{
						prototypeName = ListOfVehicle[i],
						objName = Name.."_vehicle_"..i-1,
						belong = Belong
					}
		 local vehicle = GetEntityByID(id)
		 if vehicle then
			vehicle:SetRandomSkin()
		 	if IsWares==1 then
				local mapNum = 0
				local mapName = GET_GLOBAL_OBJECT( "CurrentLevel" ):GetLevelName()
				if mapName == "r1m1" then mapNum = 0 end
				if mapName == "r1m2" then mapNum = 1 end
				if mapName == "r1m3" then mapNum = 1 end
				if mapName == "r1m4" then mapNum = 2 end
				if mapName == "r2m1" then mapNum = 3 end
				if mapName == "r2m2" then mapNum = 4 end
				if mapName == "r3m1" then mapNum = 5 end
				if mapName == "r3m2" then mapNum = 6 end
				if mapName == "r4m1" then mapNum = 7 end
				if mapName == "r4m2" then mapNum = 8 end

				local RandWarez = {"potato","firewood","scrap_metal","oil","fuel","machinery","bottle","tobacco","book","electronics"}
    				local r = random(2) + mapNum

				vehicle:AddItemsToRepository(RandWarez[r], 1)
			end
			
			-- by Anton: пїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅ, пїЅ.пїЅ. пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ SetGamePositionOnGround()
			-- CreatePos.y = g_ObjCont:GetHeight(CreatePos.x, CreatePos.z) + 1.3 * vehicle:GetSize().y
				if Rotate then
				-- by Anton: пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
					vehicle:SetRotation(Quaternion(Rotate))
				end
			vehicle:SetGamePositionOnGround(CreatePos)
			
			 team:AddChild(vehicle)
		 local vh_length=1.7 * vehicle:GetSize().z
		 CreatePos.z=CreatePos.z+vh_length
		 end
		 i = i + 1
	   end
	else
	   println("Error: Can't create team !!!")
--	   team:Remove()
	   return 0
	end
		if WalkPos then
			team:SetDestination(WalkPos)
		end
	return team
end

-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
function Dist(obj1, obj2)
	local L = 0

	if not(obj1) or not(obj2) then
		println ("ERROR! Zero-Object...")
	end

	if obj1 and obj2 then 
		L = (obj1:GetPosition() - obj2:GetPosition()):length()
	end

	return L
end

function getPos(name)
	local obj=getObj(name)
	if obj then
	   local pos=obj:GetPosition()
	   return pos
	else
		return nil
	end
end

function GetPos(name)
	return getPos(name)
end

function setPos(name, position)
	local obj = getObj( name )
	if obj then 
		if obj:GetClassName()=="Vehicle" then
			obj:SetGamePositionOnGround(position)
		else
			obj:SetPosition(position)
		end
		return position
	else
		return nil
	end
end

function SetPos(name, position)
	return setPos(name, position)
end


function setRot(name, rotation)
	local obj = getObj( name )
	if obj then 
		obj:SetRotation(rotation)
		return rotation
	else
		return nil
	end
end


-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
function GameFiltersUse()
--			g_EnableBloom (true, 0.75, 0.25)

--                      g_EnableBloom (false)
--                      g_EnableMotionBlur (false)

--                      g_EnableBloom( GetProfileBloom() )
--                      g_EnableMotionBlur( GetProfileMotionBlur(), GetProfileMotionBlurAlpha() )
end

-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
function CinemaFiltersUse()
--			g_EnableBloom (true, 0.75, 0.55)
--			g_EnableMotionBlur (true, 0.25)
end

-- special function for creating vehicle
function CreateVehicle( PrototypeName, Belong, pos, NameVehicle)

	-- Create name of vehicle
	local nameVeh

	if NameVehicle then
		nameVeh = NameVehicle
	else
		nameVeh = "Vehicle"..tostring(random(9999))
	end

	-- Create vehicle
	local id = CreateNewObject{
		prototypeName = PrototypeName,
		objName = nameVeh,
		belong = Belong
	}

	local vehicle = GetEntityByID( id )
	println(vehicle:GetName())

	-- by Anton: пїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅ, пїЅ.пїЅ. пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ SetGamePositionOnGround()
	-- local hover = 1.5 * vehicle:GetSize().y
	-- pos.y = g_ObjCont:GetHeight( pos.x, pos.z ) + hover

	vehicle:SetGamePositionOnGround( pos )


	-- Add vehicle to some team
	local teamId = CreateNewObject{
		prototypeName = "team",
		objName = "Team"..tostring(random(9999)),
		belong = Belong
	}

	local team = GetEntityByID( teamId )

	if not team then
		println( "Error: coundn't create team" )
		return nil
	end

	team:AddChild( vehicle )

	println( "Vehicle created. id = "..tostring(id) )

	return team
end

-- special function for creating humans
function CreateHuman( PrototypeName, Belong, Pos, HumanName, PathName )

	-- Create name of Human
	local nameHuman

	if HumanName then
		nameHuman = HumanName
	else
		nameHuman = "Human"..tostring(random(9999))
	end

	-- Create human belong	
   	local bel

	if belong then
		bel = belong
	else
		bel = 1100
	end

	-- Create human
	local id = CreateNewObject{
		prototypeName = PrototypeName,
		objName = nameHuman,
		belong = bel
	}

	local human = GetEntityByID( id )
	
	if not human then
		println( "Error: human ".. PrototypeName .. " is not created" )
		return nil
	end

	Pos.y = g_ObjCont:GetHeight( Pos.x, Pos.z )

	human:SetPosition( Pos )

	if PathName then
	if not human:AddWalkPathByName( PathName  ) then
		println( "Error: path ".. PathName .." for human ".. nameHuman .. " is not added" )
		return nil
	end
	
	if not human:SetWalkPathByName( PathName  ) then
		println( "Error: path ".. PathName .." for human ".. nameHuman .. " is not set" )
		return nil
	end
	end

	return human
end


function GetItemsAmount(name)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ-пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ name пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
--	local pl=GetPlayerVehicle():GetParent()
	local pl=GetPlayerVehicle()
	if pl then
--	   println("Player live")
	   local i=0
	   while pl:HasAmountOfItemsInRepository( name,i+1 ) == 1 do
	   		i = i + 1
	   end
	   println( "Get result = "..tostring(i) )
	   return i
	end
	return nil
end

function AddPlayerItems(name, count)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ count пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ name.
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ-пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
-- пїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ-пїЅпїЅ, пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
	if count==nil or 0>count then count=1 end
--	local pl=GetPlayerVehicle():GetParent()
	local pl=GetPlayerVehicle()
	if pl then
		local i = count
		while (pl:AddItemsToRepository(name,i) == nil) and (i>=1) do
			i = i - 1
		end
--		println( "Add result = "..tostring(i))
		if 0>=i then
			return nil
		else
			return i
		end
	end
end

function AddPlayerItemsWithBox(name, count, boxtype, pos)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ count пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ name.
-- пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ  pos, пїЅ пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
-- boxtype - пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ (пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ)
	local WasAdd=AddPlayerItems(name, count)
	if WasAdd==nil then WasAdd=0 end
	if count==nil or 0>count then count=1 end
--	println("WasAdd = "..WasAdd.." Count = "..count)
	if count>WasAdd then
--		println("count>WasAdd")
		local chestID = CreateNewObject{	prototypeName = "someChest",
											objName = "ItemsChest"..random(1000)
								  	   }	
		local MyChest=GetEntityByID(chestID)
		if pos==nil then
			pos = CVector(GetPlayerVehicle():GetPosition())
			pos.z = pos.z + GetPlayerVehicle():GetSize().z + 1
		end
		MyChest:SetPosition(pos)
--		println("pos = "..pos)
		for i=WasAdd+1, count do
--			println(" i = "..i)
			local itemID = CreateNewObject{	prototypeName = name,
												objName = name..random(1000)
									  	   }
			local MyItem = GetEntityByID(itemID)
			if MyChest and MyItem then
			   MyChest:AddChild(MyItem)
            end
		end
   end
end

function RemovePlayerItem(name, count)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ count пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ name пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
    if count==nil or 0>count then count=1 end
--	local pl=GetPlayerVehicle():GetParent()
	local pl=GetPlayerVehicle()
	if pl then
--	   println("Player live")
	   local res=pl:RemoveItemsFromRepository(name, count)
	   return res
	else
		return nil
	end
end

function AddChildByPrototype( obj, protName)
    local myobj = getObj(obj)
    if myobj then
		if type(protName) == "string" then
			local pr_id = CreateNewObject{
											prototypeName = protName,
											objName = protName..random(10000)
								  	   }	
			local mych = GetEntityByID( pr_id )
			if mych then
				if myobj then 
					myobj:AddChild( mych )
				end
			end
		elseif type(protName) == "table" then
			local i = 1
			while protName[i] do
				local id = CreateNewObject{
												prototypeName = protName[i],
												objName = protName[i]..random(10000)
									  	   }	
				local child = GetEntityByID( id )
				if myobj then 
					myobj:AddChild( child )
				end
				i = i+1
			end			
		end
	end
end

-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
function CreateNewDummyObject(modelName, objName, parentId, belong, pos, rot,skin)
	local prototypeName 	=  	"someDummyObject"
	local dObj		=	_CreateNewObject( prototypeName, objName, parentId, belong )
	local obj		=	GetEntityByID (dObj)

	if skin == nil then skin = 0 end

	obj:SetModelName( modelName )
	obj:SetRotation ( rot )
	obj:SetPosition ( pos )
	obj:SetSkin ( skin )
end

-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ Breakable пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
function CreateNewBreakableObject(prototypeName, objName, belong, pos, rot,skin)
	local parentId = -1
	local dObj		=	_CreateNewObject( prototypeName, objName, parentId, belong )
	local obj		=	GetEntityByID (dObj)

	if skin == nil then skin = 0 end
	
	obj:SetRotation ( rot )
	obj:SetPosition ( pos )
	obj:SetSkin ( skin )
end


-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ SgNodeObject пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
function CreateNewSgNodeObject( modelName, objName, parentId, belong, pos, rot , scale)
	local prototypeName =  	"SgNodeObject"
	local dObj			=	_CreateNewObject( prototypeName, objName, parentId, belong )
	local obj			=	GetEntityByID (dObj)

	obj:SetSgNode( modelName )
	if rot then
		obj:SetRotation ( rot )
	else
		obj:SetRotation (Quaternion(0.0000, 0.0000, 0.0000, 1.0000))
	end

	if scale then
		obj:SetScale ( scale )
	end

	obj:SetPosition ( pos )
	return obj
end


-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ ListOfVehicle, пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ Name пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ Belong, пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ CreatePos пїЅ пїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ.
function TeamCreateWithWarez(Name, Belong, CreatePos, ListOfVehicle, WalkPos)
	return CreateTeam(Name, Belong, CreatePos, ListOfVehicle, WalkPos, 1)
end

function CapturePlayerVehicle(NeedRemove, TeamName, WalkPos)
	if GetPlayerVehicle() then
		GetPlayerVehicle():setGodMode(1)
		local tm
		if TeamName then
			tm=TeamName
		else
			tm="PlayerTeam"..random(1000)
		end

	local teamID = CreateNewObject{
			prototypeName = "team",
				objName = tm,
				belong = "1100"
		}
	local team=GetEntityByID(teamID)
	if team then
			GetPlayerVehicle():SetCustomControlEnabled(1)
			team:AddChild(GetPlayerVehicle())
			if WalkPos then
--				println("Walk !!!")
				team:SetDestination(WalkPos)
			end

			if NeedRemove==1 then
				team:Remove()
				return nil
			else
				return team
		end
	   end
	end
end

function ShowCircleOnMinimapByName(objName, mapname, radius)
  local obj=getObj(objName)
  if not obj then
  	return -1
  end

  local map = GET_GLOBAL_OBJECT( "CurrentLevel" ):GetLevelName()
  if mapname then
     map = mapname
  end

  local rad = 100
  if radius then
     rad = radius
  end

  local coord = obj:GetPosition()
  ShowCircleOnMinimap( map, CVector(coord), rad )

end

function PlayerDead ( ppp )
--	LOG("Player DEAD")
--	println("Player DEAD")
--    local ppp, rrr = GetCameraPos()
    local pos = CVector(ppp)
	CreateNewDummyObject("cub", "yashik", -1, 1100, pos, Quaternion(0.0, 0.0, 0.0, 1.0), 0)
    local obj = getObj("yashik")
    if obj==nil then
    	return 
    end
    local objid = obj:GetId()
	pos.y = pos.y + 20
	pos.z = pos.z + 15
	FlyAround(5, 0.5, 15, 10, pos, objid, 0, 0, "" ,0 )
	StartCinematic()
end

--helper function for generating enemies in zone player is currently in
function GenerateEnemiesInPlayerZone()
	for i = 0, g_ObjCont:size() - 1 do
		local obj = g_ObjCont:GetEntityByObjId( i )
		if obj then
			if obj:IsKindOf( "InfectionZone" ) then
				if obj:IsPlayerInside() then
					obj:ResetTimeOut()
					println( "Generated enemies in zone ".. obj:GetName() )
				end
			end
		end
	end
end

function ASSERT( expr , mess)
	LOG("----------------- TRIGGER ASSERT ------------------------------------------------")
	if mess then
		LOG(mess)
		LOG("---------------------------------------------------------------------------------")
	end
	if expr then
		Assert( expr )
	else
		Assert( 0 )
	end
end




function GenerateRandomAffixList(CountAffixes, ClassAffixes)
	local listaff1 = {"useless_gun","rusty_gun","excellent_gun","advanced_gun"}
	local listaff2 = {{"slow_gun","assault_gun","rapid_firing_gun"},{"weak_gun","deadly_gun","destructive_gun"}}
	local listaff3 = {{"with_truncated_barrel_gun","with_enlarged_barrel_gun","with_long_barrel_gun"},{"without_sight_gun","with_laser_sight_gun","with_electric_sight_gun"},{"without_cooling_gun","with_water_cooling_gun","with_nitro_cooling_gun"}}

	local listaff = {0}
	local canused = {1, 1, 1}

	local TotalClass = 0
	local claff = 0

  	local affcount=1

  	if CountAffixes~=nil then
		if CountAffixes>3 then
			affcount=3
    	elseif 0>CountAffixes then
		    affcount=1
		else
			affcount=CountAffixes
		end
	end

	if ClassAffixes~=nil then
    	claff = ClassAffixes
		if affcount>claff then
			claff=affcount
		end
	end

	for i=1,affcount do
		local sub = affcount-i

        local rndgr
        repeat 
			rndgr = random (3)
	    until canused [rndgr] == 1
	 
		canused [rndgr] = 0

		if rndgr == 1 then
			local rndnum = random(4)
			if claff>0 then
				rndnum=4
				while sub>(claff-rndnum) do      --false!!!
					rndnum=rndnum-1
				end
				claff=claff-rndnum
			end

			listaff[i] = listaff1 [rndnum]
			TotalClass = TotalClass + rndnum
		elseif rndgr == 2 then
			local rndsubgr = random(2)
			local rndnum = random(3)
			if claff>0 then
				rndnum=3
				while sub>(claff-rndnum) do      --false!!!
					rndnum=rndnum-1
				end
				claff=claff-rndnum
			end

			listaff[i] = listaff2 [rndsubgr][rndnum]
			TotalClass = TotalClass + rndnum
		elseif rndgr == 3 then
			local rndsubgr = random(3)
			local rndnum = random(3)

			if claff>0 then
				rndnum=3
				while sub>(claff-rndnum) do      --false!!!
					rndnum=rndnum-1
				end
				claff=claff-rndnum
			end

			listaff[i] = listaff3 [rndsubgr][rndnum]
			TotalClass = TotalClass + rndnum
		else
			LOG("TRIGGER ERROR: Create Affixes - internal error. Out of range")	
		end
	end

	return listaff
end

function CreateRandomAffixesForGun(CountAffixes)
	local affixList = { }
	if CountAffixes ~= nil and CountAffixes > 0 then
		if CountAffixes > 2 then
			CountAffixes = 2
		end
		local affixes = {{{ "useless_gun", "rusty_gun" },
						{ "excellent_gun", "advanced_gun" }},
						{{ "slow_gun", "weak_gun" },
						{ "assault_gun", "rapid_firing_gun", "deadly_gun", "destructive_gun" }},
						{{ "with_truncated_barrel_gun", "without_sight_gun", "without_cooling_gun" },
						{ "with_enlarged_barrel_gun", "with_long_barrel_gun", "with_laser_sight_gun","with_electric_sight_gun", "with_water_cooling_gun", "with_nitro_cooling_gun" }}}
		affixTypes = { random(1, 3), random(1, 3) }
		if affixTypes[1] == affixTypes[2] then
			otherTypes = {}
			for i = 1, 3 do
				if i ~= affixTypes[1] then
					table.insert(otherTypes, i)
					affixTypes[2] = otherTypes[random(getn(otherTypes))]
				end
			end
		end
		quality = random(1, 2)
		for i = 1, CountAffixes do
			affixList[i] = affixes[affixTypes[i]][quality][random(getn(affixes[affixTypes[i]][quality]))]
		end
	end
	return affixList
end

function CreateBoxWithAffixGun(pos, GunPrototype, CountAffixes, ClassAffixes, BoxName)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ name пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ pos
-- 
-- 
	local name = BoxName
	if name==nil then 
		name = "ItemsChest"..random(10000)
	end
	if pos==nil or GunPrototype==nil then
		LOG("TRIGGER ERROR: Can't create box or gun. Not positiun ot gun prototype")			
		return nil
	end
	
	local chestID = CreateNewObject{	prototypeName = "someChest",
										objName = name
							  	   }	

	local MyChest=GetEntityByID(chestID)
	if MyChest==nil then
		LOG("TRIGGER ERROR: Can't create box ")
		return nil
	end
		
	MyChest:SetPosition(pos)
	local id = CreateNewObject{ prototypeName = GunPrototype, objName = "RandomGuns"..random(10000), belong = 1100 }
    local gun = GetEntityByID( id )

    if gun==nil then
       LOG("TRIGGER ERROR: Create Affixes - Can't create gun")
       return nil
    end

	local afflist = {}

	--if gun:IsKindOf("PlasmaBunchLauncher") then
	if GunPrototype == "maxim01" or GunPrototype == "fagot01" or GunPrototype == "odin01" or GunPrototype == "elephant01" or GunPrototype == "hammer01" or GunPrototype == "bumblebee01" or GunPrototype == "omega01" or GunPrototype == "big_swingfire01" or GunPrototype == "hurricane01" or GunPrototype == "mrakSideGun" or GunPrototype == "hailSideGun" or GunPrototype == "marsSideGun" or GunPrototype == "zeusSideGun" or GunPrototype == "hunterSideGun" then
		local damageAffixes = { "weak_gun", "deadly_gun", "destructive_gun" }
		local i = random(1,4)
		if i ~= 4 then
			table.insert(afflist, damageAffixes[i])
		end
	else
		--local afflist = GenerateRandomAffixList ( CountAffixes, ClassAffixes )
		afflist = CreateRandomAffixesForGun ( CountAffixes )
	end
	if afflist ~= nil then
		for i=1,getn(afflist) do
			gun:ApplyAffixByName(afflist[i])
		end
	end
	MyChest:AddChild(gun)
end


function AddVehicleGunsWithAffix( ObjName, GunPrototype, ListOfAffixes, GunName)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
--	ASSERT ( ObjPrototype~=nil, "Create Affix Assert: No Object Prototype ")
--	ASSERT ( GetPlayerVehicle~=nil, "Create Affix Assert: Player Vehicle Not Exists")
	local veh = getObj(ObjName)
    if GunPrototype==nil or veh==nil then 
       LOG("TRIGGER ERROR: Create Affixes - No Object Prototype or Object not exists")
       return nil
    end


	local name = GunName

	if name==nil then 
		name = "RandomGuns"..random(10000)
	end

	local id = CreateNewObject{ prototypeName = GunPrototype, objName = name, belong = 1100 }
    local gun = GetEntityByID( id )


    if gun==nil then
       LOG("TRIGGER ERROR: Create Affixes - Can't create gun")
       return nil
    end

    if ListOfAffixes~=nil then
	    if type(ListOfAffixes)=="table" then
			local l=getn(ListOfAffixes)
			for i=1,l do
				if ListOfAffixes[i] then
					gun:ApplyAffixByName( ListOfAffixes[i] )
				end
			end
		elseif type(ListOfAffixes)=="string" then
			gun:ApplyAffixByName( ListOfAffixes )
		end
    end
    local poloj = veh:AddObjectToRepository(gun)
    return gun
end



function AddVehicleGunsWithRandomAffix( ObjName, GunPrototype, CountAffixes, ClassAffixes, GunName )
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ  пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
-- пїЅ CountAffixes - пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ (пїЅпїЅ 1 пїЅпїЅ 3пїЅ)
-- ClassAffixes - пїЅпїЅпїЅпїЅпїЅпїЅпїЅ (пїЅпїЅпїЅпїЅпїЅ) пїЅпїЅпїЅпїЅпїЅпїЅпїЅ. пїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
-- пїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ (пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅпїЅ 3 пїЅпїЅ 10), пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
-- пїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ =)
-- пїЅ.пїЅ. пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ 3пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ 6, пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
-- 3 (пїЅпїЅпїЅ 4 пїЅпїЅпїЅ 1пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ), пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ 3 (2) пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ 2 пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ 2(1) пїЅ 1 пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ

	local res = AddVehicleGunsWithAffix( ObjName, GunPrototype, GenerateRandomAffixList(CountAffixes, ClassAffixes), GunName)
	return res
end


function AddPlayerGunsWithAffix( GunPrototype, ListOfAffixes, GunName)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
--	ASSERT ( ObjPrototype~=nil, "Create Affix Assert: No Object Prototype ")
--	ASSERT ( GetPlayerVehicle~=nil, "Create Affix Assert: Player Vehicle Not Exists")

    local res = AddVehicleGunsWithAffix (GetPlayerVehicle(), GunPrototype, ListOfAffixes, GunName)
	return res
end



function AddPlayerGunsWithRandomAffix( GunPrototype, CountAffixes, ClassAffixes, GunName )
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ  пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
-- пїЅ CountAffixes - пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ (пїЅпїЅ 1 пїЅпїЅ 3пїЅ)
-- ClassAffixes - пїЅпїЅпїЅпїЅпїЅпїЅпїЅ (пїЅпїЅпїЅпїЅпїЅ) пїЅпїЅпїЅпїЅпїЅпїЅпїЅ. пїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
-- пїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ (пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅпїЅ 3 пїЅпїЅ 10), пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
-- пїЅпїЅпїЅ пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ =)
-- пїЅ.пїЅ. пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ 3пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ 6, пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
-- 3 (пїЅпїЅпїЅ 4 пїЅпїЅпїЅ 1пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ), пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ 3 (2) пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ 2 пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ 2(1) пїЅ 1 пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
	AddVehicleGunsWithRandomAffix( GetPlayerVehicle(), GunPrototype, CountAffixes, ClassAffixes, GunName)
--	AddPlayerGunsWithAffix( GunPrototype, GenerateRandomAffixList(CountAffixes, ClassAffixes), ObjName)
end

function AddPlayerGunsWithAffixOrMoney( Money, GunPrototype, ListOfAffixes, GunName)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
--	ASSERT ( ObjPrototype~=nil, "Create Affix Assert: No Object Prototype ")
--	ASSERT ( GetPlayerVehicle~=nil, "Create Affix Assert: Player Vehicle Not Exists")
	if GetPlayerVehicle():CanPlaceItemsToRepository( GunPrototype, 1 )~=nil then
		local gun = AddVehicleGunsWithAffix (GetPlayerVehicle(), GunPrototype, ListOfAffixes, GunName)
		if gun then 
			AddFadingMsgByStrIdFormatted( "fm_player_add_thing", GunPrototype)
		else
			AddPlayerMoney(Money)
		end
	else
		AddPlayerMoney(Money)
	end

end

function AddPlayerGunsWithRandomAffixOrMoney( Money, GunPrototype, CountAffixes, ClassAffixes, GunName)
-- пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
--	ASSERT ( ObjPrototype~=nil, "Create Affix Assert: No Object Prototype ")
--	ASSERT ( GetPlayerVehicle~=nil, "Create Affix Assert: Player Vehicle Not Exists")
	if GetPlayerVehicle():CanPlaceItemsToRepository( GunPrototype, 1 )~=nil then
		local gun = AddVehicleGunsWithRandomAffix( GetPlayerVehicle(), GunPrototype, CountAffixes, ClassAffixes, GunName)
		if gun then 
			AddFadingMsgByStrIdFormatted( "fm_player_add_thing", GunPrototype)
		else
			AddPlayerMoney(Money)
		end

	else
		AddPlayerMoney(Money)
	end

end

function exrandom( N )
    local N2 = N * 2
--    local aaa=floor(abs( ( random( N2 ) + random( N2 ) + random( N2 ) + random( N2 ) + random( N2 )  ) / 5.0 - N )+1)
    local aaa=floor(abs( (random( N2 ) + random( N2 ) + random( N2 ) + random( N2 ) + random( N2 )  ) / 5.0 - N )+1)
    return aaa
end

function RAD( angle )
	return angle/180*3.14159
end

function EnableGodMode()
	GetPlayerVehicle():setGodMode(true)
end

function DisableGodMode()
	GetPlayerVehicle():setGodMode(false)
end

function RotationPlayerByPoints(point2, point1)
	local player = GetPlayerVehicle()
	local dir = point1 - point2
	dir.y = 0
	player:SetDirection(dir:normalize())
end


--[[ function SaveAllToleranceStatus(SetStatus)
	GL_ToleranceStatus = {}
	for i=1,100 do
		GL_ToleranceStatus[i] = {}
		for j=1,100 do
			GL_ToleranceStatus[i][j] = GetTolerance(i+1000, j+1000)
			
	    end
  	end
  	if SetStatus then 
		for i=1,100 do
			for j=1,100 do
				SetTolerance(i+1000, j+1000, SetStatus)
		    end
  		end

  	end
end                     

function RestoreAllToleranceStatus()
	for i=1,100 do
		for j=1,100 do
		   SetTolerance(i+1000, j+1000, GL_ToleranceStatus[i][j])
    	end
    end
end ]]

function SaveAllToleranceStatus(SetStatus)
	GL_ToleranceStatus = {}
	for i=1,500 do
		GL_ToleranceStatus[i] = {}
		for j=1,500 do
			GL_ToleranceStatus[i][j] = GetTolerance(i+1000, j+1000)
			
	    end
  	end
  	if SetStatus then 
		for i=1,500 do
			for j=1,500 do
				SetTolerance(i+1000, j+1000, SetStatus)
		    end
  		end

  	end
end                     

function RestoreAllToleranceStatus()
	for i=1,500 do
		for j=1,500 do
		   SetTolerance(i+1000, j+1000, GL_ToleranceStatus[i][j])
    	end
    end
end

-- =========================== --
-- ExM:Rise of Clans functions --

function CreateCaravanTeam(Name, Belong, CreatePos, ListOfVehicle, WalkPos, IsWares, Rotate)
-- Создает команду-караван машин из списка ListOfVehicle
-- см. CreateTeam()
	if CreatePos==nil then
		LOG("No position")
		return
	end
	
	local _CreatePos=CreatePos

	if type(CreatePos)=="table" then
		_CreatePos=CreatePos[1]
	end

	local _Rotate=nil

	if Rotate~=nil then
		if type(Rotate)=="table" then
			_Rotate=Rotate[1]
		else
			_Rotate=Rotate
		end
	end

	local teamID = CreateNewObject{
			prototypeName = "caravanTeam",
			objName = Name,
			belong = Belong
		}
	local team=GetEntityByID(teamID)
	if team then
--		println("team created")
		local i=1
		local id=0
		while ListOfVehicle[i] do
			local id = CreateNewObject{
							prototypeName = ListOfVehicle[i],
							objName = Name.."_vehicle_"..i-1,
							belong = Belong
						}
			local vehicle = GetEntityByID(id)
			if vehicle then
				vehicle:SetRandomSkin()
			if IsWares==1 then
				local RandWarez = {"scrap_metal","fuel","machinery"}
				local r = random(10)
				vehicle:AddItemsToRepository(RandWarez[r], 1)
			end
				
			-- by Anton: это не нужно, т.к. вызываем SetGamePositionOnGround()
			-- CreatePos.y = g_ObjCont:GetHeight(CreatePos.x, CreatePos.z) + 1.3 * vehicle:GetSize().y
			if Rotate then
				-- by Anton: Устанавливаем вращение перед тем как поставить машинку на землю, ибо это правильно
					if type(Rotate)=="table" then
						if Rotate[i]~=nil then	_Rotate=Rotate[i] end
					end
					vehicle:SetRotation(Quaternion(_Rotate))
				end
				
				if type(CreatePos)=="table" then
					if CreatePos[i]~=nil then _CreatePos=CreatePos[i] end
				end
		
				vehicle:SetGamePositionOnGround(_CreatePos)
				team:AddChild(vehicle)

				local vh_length=1.7 * vehicle:GetSize().z
				_CreatePos.z=_CreatePos.z+vh_length
			end
			i = i + 1
		end
	else
	   println("Error: Can't create team !!!")
--	   team:Remove()
		return 0
	end
		if WalkPos then
			team:SetDestination(WalkPos)
		end
	return team
end

-- ==================== --
-- Battleship functions --
-- ==================== --

-- literally a stolen function for capping the values in the calculations
-- credit to vrld on love2d.org forum
function math.clamp(val, lower, upper)
    assert(val and lower and upper, "not very useful error message here")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

-- shortcut for xor in lua
function xor(x, y)
	return (x or y) and not (x and y)
end

-- shortcut for basic rounding without bells and whistles
-- works good enough so fuck off :---DDDDDDDD
function round(num)
	local numa = 0
	if num then
		numa = num
	end
	
	return math.floor(numa + 0.5)
end

-- function that converges two tables, tableA is a table to which the tableB's contents should be added
function ConvergeTables(tableA, tableB)
	local convergedTable = tableA
	local convergingTable = tableB
	local isTableEmpty = next(convergingTable)
	if isTableEmpty ~= nil then
		for i=1, getn(convergingTable) do
			table.insert(convergedTable, convergingTable[i])
		end
	end

	return convergedTable
end

-- function that converts a table into a string
-- useful for storing tables in SetVar variables
-- modo is used for storing tables of strings inside the table
-- modo 1 turns double quotations (") into singular ones (')
-- modo 2 turns double quotations (") into paragraph signs (В¶)
-- modo 2 is useful for actually storing tables of strings inside the table in SetVar variables
-- because paragraph signs are automatically converted into single quotation marks by StringToTable
-- and if you use single quotations for that, your dynamicscene will get fucked if you save the game
-- so use modo 2, you have been warned
function TableToString(table, modo)
	local endString = "{"
	local tableLength
	if type(table)=="table" then
		tableLength = getn(table)
		for i=1, tableLength do
			if type(table[i])=="string" then
				if modo==1 then
					endString = endString.."'"..table[i].."'"
				elseif modo==2 then
					endString = endString.."В¶"..table[i].."В¶"
				else
					endString = endString..'"'..table[i]..'"'
				end
			else
				endString = endString..table[i]
			end

			if i==tableLength then
				endString = endString.."}"
			else
				endString = endString..", "
			end
		end
	else
		endString = '{"idi nahui eto ne massiff)))0)"}'
		println(endString)
	end

	return endString
end

-- function that converts a table presented as string into a real table
-- useful for getting the tables out of SetVar variables
function StringToTable(strVal)
	local endTable = strVal
	endTable = string.gsub(endTable, "В¶", "'")
	local funcTableCode = loadstring("local t = "..endTable.."; return t")
	endTable = funcTableCode()

	return endTable
end

-- converges two tables that are presented as strings, tableA is a table to which the tableB's contents should be added
-- SetVar("a", '{"j","o"}'); SetVar("b", '{"p","a"}'); local s = ConvergeStringTables(GetVar("a").AsString, GetVar("b").AsString); SetVar("a", s); println(GetVar("a").AsString)
function ConvergeStringTables(tableA, tableB)
	local funcTableCode
	funcTableCode = loadstring("local t = "..tableA.."; return t")
	local convergedTable = funcTableCode()
	funcTableCode = loadstring("local t = "..tableB.."; return t")
	local convergingTable = funcTableCode()
	local isTableEmpty = next(convergingTable)
	if isTableEmpty ~= nil then
		for i=1, getn(convergingTable) do
			table.insert(convergedTable, convergingTable[i])
		end
	end
	convergedTable = TableToString(convergedTable)

	return convergedTable
end

-- function that calculates current vehicle speed in km/h
function GetSpeed(vehicle)
	local retVal = 0
	local linearVelocity
	if vehicle then
		linearVelocity = vehicle:GetLinearVelocity()
		retVal = math.floor((math.abs(linearVelocity.x) + math.abs(linearVelocity.y) + math.abs(linearVelocity.z))*2.675)
	end

	return retVal
end

-- the function that sets up the parameters of a chosen mission at the hq map
-- gunsAndGadgets is the guns and gadgets that will be added to the shop in hq
function MissionSetup(missionTime, missionSide, missionName, missionMap, playerVehicle, friendlies, gunsAndGadgets)
	g_ObjCont:SetGameTime( missionTime[1], missionTime[2], missionTime[3], missionTime[4], missionTime[5] )
	ChangeSide(missionSide)
	local plPos = GetPlayerVehicle():GetPosition()
	AddPlayerVehicle(playerVehicle)
	GetPlayerVehicle():SetGamePositionOnGround(plPos)
	SetVar("MissionLoc", missionMap)
--	TActivate(missionName)
	TActivate("MissionStart")
	local namae = missionName.."_Briefing"
	AddHistory(namae)
	if friendlies then
		gFriendlies = friendlies
	end

	if gunsAndGadgets then
		for i=1, getn(gunsAndGadgets) do
			getObj("Headquarters_Shop"):GetRepositoryByTypename("GunsAndGadgets"):AddItems(gunsAndGadgets[i], 1)
		end

		SetVar("GunsAndGadgets", TableToString(gunsAndGadgets))
	end

	SetVar('OnMission', 1)
end

-- function that changes tolerances to the player according to the specified side of the conflict
function ChangeSide(sideName)
	unitsCommon = 13 -- number of different common unit types
	unitsSpecial = 1 -- number of special mission-specific unit types - 1
	local relationCIT = 3
	local relationCD = 3
	if sideName=="CIT" then
		relationCIT = 3
		relationCD = 0
	elseif sideName=="CD" then
		relationCIT = 0
		relationCD = 3
	end
	
	local numa = 1000
	for i=0, unitsCommon do
		-- setting tolerance for CIT
		numa = numa + i
		SetTolerance(1500, numa, relationCIT)
		-- setting tolerance for CD
		numa = numa + 50
		SetTolerance(1500, numa, relationCD)
		numa = 1000
	end

	numa = 1030
	for i=0, unitsSpecial do
		-- setting tolerance for CIT
		numa = numa + i
		SetTolerance(1500, numa, relationCIT)
		-- setting tolerance for CD
		numa = numa + 50
		SetTolerance(1500, numa, relationCD)
		numa = 1000
	end
end

-- function that returns the player's side of the conflict
function GetPlayerAffiliation()
	local playerAffiliation = "none"
	if GetTolerance(1500, 1000) >= 2.5 and GetTolerance(1500, 1050) < 1.5 then
		playerAffiliation = "CIT"
	elseif GetTolerance(1500, 1050) >= 2.5 and GetTolerance(1500, 1000) < 1.5 then
		playerAffiliation = "CD"
	end

	return playerAffiliation
end

-- function that gives score reward for completing the objective and sets a new value of completed objectives
function CompleteObjective(am)
	local amount = 1
	if am then
		amount = am
	end
	local objectivesCompleted = GetVar("ObjectivesCompleted").AsInt
	objectivesCompleted = objectivesCompleted + amount
	SetVar("ObjectivesCompleted", objectivesCompleted)

	local missionScore = GetVar("TotalMissionScore").AsInt
	println("mission score is "..missionScore)
	local objectiveScoreReward = GetVar("ObjectiveScoreReward").AsInt
	missionScore = missionScore + objectiveScoreReward
	SetVar("TotalMissionScore", missionScore)
end

-- function that allows to just gives score for anything other than completing objectives, completing the mission in a certain amount of time or destroying enemies
function GiveScore(am)
	local amount = 100
	if am then
		amount = am
	end
	local missionScore = GetVar("TotalMissionScore").AsInt
	println("mission score is "..missionScore)
	missionScore = missionScore + amount
	SetVar("TotalMissionScore", missionScore)
end

-- function that helps to determine whether units are alive or dead
-- returns true or false
-- units is the name of a unit to be checked, or a group of units if table is passed
-- checkT is the type of the check that is being run. Can either be "alive" or "dead"
-- checkAm is the amount of units that need to correspond to checkT condition
-- checkEx is exactness of the checked amount of units for the function to return "true"
-- if i.e. the exact amount of units need to be alive for your check to pass, checkEx should be "exact"
-- if it's more or equal of that - it needs to be "more"
-- if less or equal - "less"
-- so if you want to check whether at least one unit in your group is alive you need to write:
-- CheckUnits({"CITBoats01_vehicle_0","CITBoats02_vehicle_0","CITBoats03_vehicle_0","CITBoats04_vehicle_0"}, "alive", 1, "more")
-- if you want to check whether a single unit is dead, this is going to be enough:
-- CheckUnits("CDBoats01_vehicle_0", "dead")
-- but it's generally better to use it like that instead:
-- not(CheckUnits("CDBoats01_vehicle_0"))
-- it will essentially do the same thing and will be more consistent in the code
-- checking if 2 or more units are dead in console:
-- if CheckUnits({"CDLavs01_vehicle_0","CDLavs02_vehicle_0","CDLavs02_vehicle_1","CDLavs03_vehicle_0","CDLavs03_vehicle_1"}, "dead", 2, "more") then println(1) end
function CheckUnits(units, checkT, checkAm, checkEx)
	local unitNames = units
	local retVal = false
	local checkedAmount = 0
	local checkAmount = 1
	if checkAm and checkAm > 0 then
		checkAmount = checkAm
	end
	local checkType = "alive"
	if checkT then
		checkType = checkT
	end
	local checkExact = "more"
	if checkEx then
		checkExact = checkEx
	end

	local checkedUnit = "Unit"
	
	if type(unitNames) == "table" then
		if checkAmount > getn(unitNames) then
			checkAmount = getn(unitNames)
		end

		if checkType == "alive" then
			for i = 1, getn(unitNames) do
				checkedUnit = getObj(unitNames[i])
				if (checkedUnit and checkedUnit:IsAlive()) then
					checkedAmount = checkedAmount + 1
					println("the "..i.." is alive")
				end
			end
		else
			for i = 1, getn(unitNames) do
				checkedUnit = getObj(unitNames[i])
				if (not(checkedUnit) or not(checkedUnit:IsAlive())) then
					checkedAmount = checkedAmount + 1
					println("the "..i.." is dead")
				end
			end
		end

		if checkExact == "exact" then
			if checkedAmount == checkAmount then
				retVal = true
			end
		elseif checkExact == "less" then
			if checkedAmount <= checkAmount then
				retVal = true
			end
		else
			if checkedAmount >= checkAmount then
				retVal = true
			end
		end
	
		return retVal
	elseif type(unitNames) == "string" then
		if checkType == "alive" then
			checkedUnit = getObj(unitNames)
			if (checkedUnit and checkedUnit:IsAlive()) then
				retVal = true
				println("the one guy is alive")
			end
		else
			checkedUnit = getObj(unitNames)
			if (not(checkedUnit) or not(checkedUnit:IsAlive())) then
				retVal = true
				println("the one guy is dead")
			end
		end

		return retVal
	else
		println("[!] arg is neither table nor string")
		return retVal
	end
end

-- function to check distances between a unit and a possible group of units
-- if checkT is set to "least" - the lowest value will be returned
-- if "most" - the highest value will be returned
-- if "average" - the average distance between unit1 and a group of units2 will be returned
-- local b = "CITBoats01_vehicle_0"; println(CheckDistBetweenUnits(b, {"CDLavs01_vehicle_0","CDLavs02_vehicle_0","CDLavs02_vehicle_1","CDLavs03_vehicle_0","CDLavs03_vehicle_1","CDBoats01_vehicle_0","CDBoats02_vehicle_0","CDBoats02_vehicle_1"}, "least"))
function CheckDistBetweenUnits(unit, units, checkT)
	local unit1Name = GetPlayerVehicle()
	if unit ~= GetPlayerVehicle() then
		unit1Name = getObj(unit)
	end
	local unit2Names = units
	local unit2Name = units
	local retVal = 0
	local checkedAmount = 0
	local checkAmount = 1
	if checkAm and checkAm > 0 then
		checkAmount = checkAm
	end
	local checkType = "average"
	if checkT then
		checkType = checkT
	end

	local dist
	local aliveUnit2Names

	if type(unit2Names) == "table" then
		if checkType == "least" then
			retVal = 8192
			for i=1, getn(unit2Names) do
				if CheckUnits(unit2Names[i]) then
					unit2Name = getObj(unit2Names[i])
					dist = Dist(unit1Name, unit2Name)
				else
					dist = 16384
				end

				if retVal > dist then
					retVal = dist
				end
			end
		elseif checkType == "most" then
			retVal = 0
			for i=1, getn(unit2Names) do
				if CheckUnits(unit2Names[i]) then
					unit2Name = getObj(unit2Names[i])
					dist = Dist(unit1Name, unit2Name)
				else
					dist = 0
				end

				if retVal < dist then
					retVal = dist
				end
			end
		else
			retVal = 0
			aliveUnit2Names = getn(unit2Names)
			for i=1, getn(unit2Names) do
				if CheckUnits(unit2Names[i]) then
					unit2Name = getObj(unit2Names[i])
					dist = Dist(unit1Name, unit2Name)
					retVal = retVal + dist
				else
					aliveUnit2Names = aliveUnit2Names - 1
				end
			end

			if aliveUnit2Names ~= 0 then
				retVal = retVal / aliveUnit2Names
			else
				retVal = 16384
			end
		end
	else
		retVal = 16384		
		if CheckUnits(unit2Name) then
			unit2Name = getObj(unit2Name)
			retVal = Dist(unit1Name, unit2Name)
		end
	end

	return retVal
end

-- function that calculates the average distance between all target vehicles
-- and updates the coordinates for a quest
function UpdateQuestCoordinates(questName, units)
	local aliveUnits = {}
	local j = 1
	for i=1, getn(units) do
		if CheckUnits(units[i]) then
			aliveUnits[j] = units[i]
			j = j + 1
		end
	end

	local aliveUnitsAmount = getn(aliveUnits)
	local currentUnitCoordinates
	local commonCoordinates = CVector(0, 0, 0)
	if aliveUnitsAmount > 0 then
		for i=1, aliveUnitsAmount do
			currentUnitCoordinates = getObj(aliveUnits[i]):GetPosition()
			commonCoordinates.x = commonCoordinates.x + currentUnitCoordinates.x
			println("commonCoordinate x is "..commonCoordinates.x)
			commonCoordinates.z = commonCoordinates.z + currentUnitCoordinates.z
			println("commonCoordinate z is "..commonCoordinates.z)
		end

		commonCoordinates.x = commonCoordinates.x / aliveUnitsAmount
		println("[!] commonCoordinate x is "..commonCoordinates.x)
		commonCoordinates.z = commonCoordinates.z / aliveUnitsAmount
		println("[!] commonCoordinate z is "..commonCoordinates.z)
	end

	SetCoordinateForQuest(questName, commonCoordinates)
end

-- function that updates hp values of all friendly and enemy units on the mission
function UpdateUnitsStats(plDead)
	local playerDead = 0
	if plDead ~= nil then
		playerDead = plDead
	end

	local friendliesStart = StringToTable(GetVar("Friendlies").AsString)
	local friendliesStartHealth = StringToTable(GetVar("FriendliesHealth").AsString)
	local friendliesVehicleHealth = StringToTable(GetVar("FriendliesVehicleHealth").AsString)
	local friendliesEndHealth = StringToTable(GetVar("FriendliesEndHealth").AsString)

	local assignedMaximumHealth = 0
	local maximumHealth = 0
	local healthMultiplier = 1
	local currentHealth = 0
	local isTableEmpty = next(friendliesEndHealth)
	if isTableEmpty ~= nil then
		for i=1, getn(friendliesEndHealth) do
			if CheckUnits(friendliesStart[i]) then
				local unitBelong = getObj(friendliesStart[i]):GetProperty("Belong").AsInt
				if not(xor(unitBelong~=1008, unitBelong~=1058)) then
					assignedMaximumHealth = friendliesStartHealth[i]
					maximumHealth = friendliesVehicleHealth[i]
					healthMultiplier = assignedMaximumHealth / maximumHealth
					currentHealth = getObj(friendliesStart[i]):GetHealth() * healthMultiplier
					if currentHealth < friendliesEndHealth[i] then
						friendliesEndHealth[i] = currentHealth
						println("friendly numba "..i.." updated")
					end
				else
					friendliesEndHealth[i] = friendliesStartHealth[i]
					println("friendly numba "..i.." is a pillbox")
				end
				println("friendly numba "..i.." checked")
			else
				friendliesEndHealth[i] = 0
			end
		end
	else
		println("there are no friendlies on this mission")
	end

	local retVal = TableToString(friendliesEndHealth)
	println("retVal initialiased")
	SetVar("FriendliesEndHealth", retVal)
	println("retVal returned")
	
	local enemiesStart = StringToTable(GetVar("Enemies").AsString)
	local enemiesStartHealth = StringToTable(GetVar("EnemiesHealth").AsString)
	local enemiesVehicleHealth = StringToTable(GetVar("EnemiesVehicleHealth").AsString)
	local enemiesEndHealth = StringToTable(GetVar("EnemiesEndHealth").AsString)

	assignedMaximumHealth = 0
	maximumHealth = 0
	healthMultiplier = 1
	currentHealth = 0
	isTableEmpty = next(enemiesEndHealth)
	if isTableEmpty ~= nil then
		for i=1, getn(enemiesEndHealth) do
			if CheckUnits(enemiesStart[i]) then
				local unitBelong = getObj(enemiesStart[i]):GetProperty("Belong").AsInt
				if not(xor(unitBelong~=1008, unitBelong~=1058)) then
					assignedMaximumHealth = enemiesStartHealth[i]
					maximumHealth = enemiesVehicleHealth[i]
					healthMultiplier = assignedMaximumHealth / maximumHealth
					currentHealth = getObj(enemiesStart[i]):GetHealth() * healthMultiplier
					if currentHealth < enemiesEndHealth[i] then
						enemiesEndHealth[i] = currentHealth
						println("enemy numba "..i.." updated")
					end
				else
					enemiesEndHealth[i] = enemiesStartHealth[i]
					println("enemy numba "..i.." is a pillbox")
				end
				println("enemy numba "..i.." checked")
			else
				enemiesEndHealth[i] = 0
				println("enemy numba "..i.." checked, dead")
			end
		end
	else
		println("there are no enemies on this mission (why though)")
	end

	SetVar("EnemiesEndHealth", TableToString(enemiesEndHealth))

	local playerStartHealth = GetVar("PlayerHealth").AsInt
	local playerVehicleHealth = GetVar("PlayerVehicleHealth").AsInt
	local playerEndHealth = GetVar("PlayerEndHealth").AsInt
	local playerVehicle = GetPlayerVehicle()
	healthMultiplier = 1
	currentHealth = 0
	if playerVehicle then
		if playerDead ~= 1 then
			healthMultiplier = playerStartHealth / playerVehicleHealth
			currentHealth = playerVehicle:GetHealth() * healthMultiplier
			if currentHealth < playerEndHealth then
				playerEndHealth = currentHealth
				println("player updated")
			end
			println("player checked")
		else
			playerEndHealth = 0
			println("player dead")
		end
	else
		playerEndHealth = 0
		println("player dead")
	end

	SetVar("PlayerEndHealth", playerEndHealth)
end

-- function that calculates stats at the end of the mission
-- values are saved to the globals that can be used on a different map, useful for showing the stats on hq map
function CalcMissionStats(plDead)
	local playerDead = 0
	if plDead ~= nil then
		playerDead = plDead
	end

	local funcTableCode
	println(1)
-- friendly units from the start of the mission, only used once in the cycle below; friendliesEnd is used afterwards
	local friendliesStart = GetVar("Friendlies").AsString
	funcTableCode = loadstring("local t = "..friendliesStart.."; return t")
	friendliesStart = funcTableCode()
-- type of each friendly unit from the start of the mission, used to pass surviving friendlies types back to the hq map
	local friendliesStartTypes = GetVar("FriendliesTypes").AsString
	funcTableCode = loadstring("local t = "..friendliesStartTypes.."; return t")
	friendliesStartTypes = funcTableCode()
-- prototype of each friendly unit from the start of the mission, used to pass surviving friendlies prototypes back to the hq map
	local friendliesStartPrototypes = GetVar("FriendliesPrototypes").AsString
	funcTableCode = loadstring("local t = "..friendliesStartPrototypes.."; return t")
	friendliesStartPrototypes = funcTableCode()
-- health of each friendly unit from the start of the mission, used for total starting health and losses calculation
	local friendliesStartHealth = GetVar("FriendliesHealth").AsString
	funcTableCode = loadstring("local t = "..friendliesStartHealth.."; return t")
	friendliesStartHealth = funcTableCode()
-- vehicle health of each friendly unit from the start of the mission, used to pass surviving friendlies hp back to the hq map
	local friendliesStartVehicleHealth = GetVar("FriendliesVehicleHealth").AsString
	funcTableCode = loadstring("local t = "..friendliesStartVehicleHealth.."; return t")
	friendliesStartVehicleHealth = funcTableCode()
	println(2)
-- health of each friendly unit at the end of the mission, used for total starting health and losses calculation	
	local friendliesEndHealth = GetVar("FriendliesEndHealth").AsString
	funcTableCode = loadstring("local t = "..friendliesEndHealth.."; return t")
	friendliesEndHealth = funcTableCode()
	println(3)
-- firepower of each friendly unit from the start of the mission, only used once in the cycle below, friendliesEndFirepower is used afterwards	
	local friendliesStartFirepower = GetVar("FriendliesFirepower").AsString
	funcTableCode = loadstring("local t = "..friendliesStartFirepower.."; return t")
	friendliesStartFirepower = funcTableCode()
	println(4)
-- maneuverability of each friendly unit from the start of the mission, only used once in the cycle below, friendliesEndManeuverability is used afterwards
	local friendliesStartManeuverability = GetVar("FriendliesManeuverability").AsString
	funcTableCode = loadstring("local t = "..friendliesStartManeuverability.."; return t")
	friendliesStartManeuverability = funcTableCode()
	println(5)
-- list of the friendly ship names
	local friendliesStartNames = GetVar("FriendliesNames").AsString
	funcTableCode = loadstring("local t = "..friendliesStartNames.."; return t")
	friendliesStartNames = funcTableCode() 
	println(6)
	
	local friendliesLostNames = {} -- list of names of friendlies destroyed to show at the end of the mission. Is updated with new names further down the function when calculating losses whilst retreating (if a friendly didn't manage to retreat they are added to this list) 

	local friendliesEnd = {} -- alive friendly units at the end of the mission
	local friendliesEndTypes = {}
	local friendliesEndPrototypes = {}
	local friendliesEndStartingHealth = {}
	local friendliesEndVehicleHealth = {}
	local friendliesEndFirepower = {} -- firepower of each alive friendly unit
	local friendliesEndManeuverability = {} -- maneuverability of each alive friendly unit
	local friendliesEndNames = {} -- names of each alive friendly unit
	println(7)
	local isTableEmpty = next(friendliesStart)
	println(8)
	local p = 1
	local d = 1
	local z = 1
	if isTableEmpty ~= nil then
		for i=1, getn(friendliesStart) do
			println(friendliesStart[i])
			if CheckUnits(friendliesStart[i]) and friendliesEndHealth[i]~=0 then
				friendliesEnd[p] = friendliesStart[i]
				friendliesEndTypes[p] = friendliesStartTypes[i]
				friendliesEndPrototypes[p] = friendliesStartPrototypes[i]
				friendliesEndStartingHealth[p] = friendliesStartHealth[i]
				friendliesEndVehicleHealth[p] = friendliesStartVehicleHealth[i]
				friendliesEndFirepower[p] = friendliesStartFirepower[i]
				friendliesEndManeuverability[p] = friendliesStartManeuverability[i]
				friendliesEndNames[p] = friendliesStartNames[i]
				println("everything ready for friendly numba "..p)
				p = p + 1
--				d = d + 1
			else
--				friendliesEndHealth[p] = 0
				friendliesLostNames[z] = friendliesStartNames[i]
				println("friendly is dead, removing from health table and adding to lost allies numba"..z)
				z = z + 1
			end
		end
	else
		println("there are no friendlies on this mission")
	end

 -- enemy units from the start of the mission	
	local enemiesStart = GetVar("Enemies").AsString
	funcTableCode = loadstring("local t = "..enemiesStart.."; return t")
	enemiesStart = funcTableCode()
-- health of each enemy unit at the start of the mission	
	local enemiesStartHealth = GetVar("EnemiesHealth").AsString
	funcTableCode = loadstring("local t = "..enemiesStartHealth.."; return t")
	enemiesStartHealth = funcTableCode() 
-- health of each enemy unit at the end of the mission
	local enemiesEndHealth = GetVar("EnemiesEndHealth").AsString
	funcTableCode = loadstring("local t = "..enemiesEndHealth.."; return t")
	enemiesEndHealth = funcTableCode() 
-- firepower of each enemy unit
	local enemiesStartFirepower = GetVar("EnemiesFirepower").AsString
	funcTableCode = loadstring("local t = "..enemiesStartFirepower.."; return t")
	enemiesStartFirepower = funcTableCode() 
-- maneuverability of each enemy unit
	local enemiesStartManeuverability = GetVar("EnemiesManeuverability").AsString
	funcTableCode = loadstring("local t = "..enemiesStartManeuverability.."; return t")
	enemiesStartManeuverability = funcTableCode() 

	local enemiesEnd = {} -- alive enemy units at the end of the mission
	local enemiesEndFirepower = {} -- firepower of each alive enemy unit
	local enemiesEndManeuverability = {} -- maneuverability of each alive enemy unit
	isTableEmpty = next(enemiesStart)
	p = 1
--	d = 1
	if isTableEmpty ~= nil then
		for i=1, getn(enemiesStart) do
			if CheckUnits(enemiesStart[i]) and enemiesEndHealth[i]~=0 then
				enemiesEnd[p] = enemiesStart[i]
				enemiesEndFirepower[p] = enemiesStartFirepower[i]
				enemiesEndManeuverability[p] = enemiesStartManeuverability[i]
				println("everything ready for enemy numba "..p)
				p = p + 1
--				d = d + 1
			else
				table.remove(enemiesEndHealth, p)
			end
		end
	else
		println("there are no enemies on this mission (why though)")
	end

	-- ==========
	-- stuff for calculating whether friendlies retreat or not
	-- ==========
	local friendliesEndCount = 0
	local enemiesEndCount = 0

	-- average distance to enemies
	local distances = {}
	local currentShip
	local currentShipDistance = 0 -- added distance from one friendly ship to all enemy ships
	local currentEnemy
	isTableEmpty = next(friendliesEnd)
	if isTableEmpty ~= nil then
		friendliesEndCount = getn(friendliesEnd)
		for i=1, friendliesEndCount do
			currentShip = getObj(friendliesEnd[i])
			if next(enemiesEnd) ~= nil then
				enemiesEndCount = getn(enemiesEnd)
				for j=1, enemiesEndCount do
					currentEnemy = getObj(enemiesEnd[j])
					if currentEnemy then
						currentShipDistance = currentShipDistance + Dist(currentShip, currentEnemy)
					end
				end
				currentShipDistance = currentShipDistance / enemiesEndCount
			else
				currentShipDistance = 8000 -- failsafe in an event of no surviving enemies
				println("failsafe 8000")
			end
			println("distances calculated for friendly ship numba "..i.." which equals to "..currentShipDistance)
			distances[i] = currentShipDistance
		end
		println("distances calculated for all friendly ships")
	else
		println("distances werent calculated, all friendly ships are dead")
	end
	

	-- average enemy stats
	local enemiesEndTotalHealth = 0
	local enemiesEndAverageHealth = 0  -- this is used for the comparison between a retreating ship and enemies
	local enemiesEndTotalFirepower = 0 -- the end maneuverability is used for comparison with the friendlies maneuverability and whether they will be able to retreat
	local enemiesEndAverageFirepower = 0 -- this is used for the comparison between a retreating ship and enemies
	local enemiesEndTotalManeuverability = 0 -- the end maneuverability is used for comparison with the friendlies maneuverability and whether they will be able to retreat
	local enemiesEndAverageManeuverability = 0 -- this is used for the comparison between a retreating ship and enemies

	isTableEmpty = next(enemiesEnd)
	if isTableEmpty ~= nil then
		for i=1, enemiesEndCount do
			enemiesEndTotalHealth = enemiesEndTotalHealth + enemiesEndHealth[i]
		end
		println("enemies total ending health "..enemiesEndTotalHealth)
		enemiesEndAverageHealth = enemiesEndTotalHealth / enemiesEndCount
		println("enemies average ending health "..enemiesEndAverageHealth)

		-- average enemy firepower
		for i=1, enemiesEndCount do
			enemiesEndTotalFirepower = enemiesEndTotalFirepower + enemiesEndFirepower[i]
		end
		println("enemies total ending firepower "..enemiesEndTotalFirepower)
		enemiesEndAverageFirepower = enemiesEndTotalFirepower / enemiesEndCount
		println("enemies average ending firepower "..enemiesEndAverageFirepower)

		-- average enemy maneuverability
		for i=1, enemiesEndCount do
			enemiesEndTotalManeuverability = enemiesEndTotalManeuverability + enemiesEndManeuverability[i]
		end
		println("enemies total ending maneuverability "..enemiesEndTotalManeuverability)
		enemiesEndAverageManeuverability = enemiesEndTotalManeuverability / enemiesEndCount
		println("enemies average ending maneuverability "..enemiesEndAverageManeuverability)
	end

	println("=================")
	println("=================")
	println("Enemies Start "..TableToString(enemiesStart))
	println("Enemies End "..TableToString(enemiesEnd))
	println("=================")
	println("=================")

	-- ==========
	-- calculating whether friendlies retreat or not
	-- ==========

	local survivingFriendliesInformation = {}
	isTableEmpty = next(friendliesEnd)
	if isTableEmpty ~= nil then
		--calculating chance for retreat with all multipliers
		local baseRetreatChance = GetVar("BaseRetreatScore").AsInt
		local retreatMultiplier = 1
		local maneuverabilityRetreatMultiplier = 0
		local distanceRetreatMultiplier = 0
		local healthRetreatMultiplier = 0
		local firepowerRetreatMultiplier = 0
		local retreatChance = GetVar("RequiredRetreatScore").AsInt
		local retreatChanceMultiplied = baseRetreatChance
		j = getn(friendliesLostNames)
		for i=1, friendliesEndCount do
			currentShip = friendliesEndManeuverability[i]
			maneuverabilityRetreatMultiplier = (currentShip / enemiesEndAverageManeuverability - 1) / 5
			maneuverabilityRetreatMultiplier = math.clamp(maneuverabilityRetreatMultiplier, -0.2, 0.2)
			println(i.." friendly ship maneuverability retreat multiplier is "..maneuverabilityRetreatMultiplier)
			currentShip = distances[i]
			distanceRetreatMultiplier = (currentShip / 1000 - 1) / 2.85
			distanceRetreatMultiplier = math.clamp(distanceRetreatMultiplier, -0.35, 0.35)
			println(i.." friendly ship distance retreat multiplier is "..maneuverabilityRetreatMultiplier)
			currentShip = friendliesEndHealth[i]
			healthRetreatMultiplier = (currentShip / enemiesEndAverageHealth - 1) / 10
			healthRetreatMultiplier = math.clamp(healthRetreatMultiplier, -0.2, 0.2)
			println(i.." friendly ship health retreat multiplier is "..healthRetreatMultiplier)
			currentShip = friendliesEndFirepower[i]
			firepowerRetreatMultiplier = (currentShip / enemiesEndAverageFirepower - 1)/5
			firepowerRetreatMultiplier = math.clamp(firepowerRetreatMultiplier, -0.2, 0.2)
			println(i.." friendly ship firepower retreat multiplier is "..firepowerRetreatMultiplier)
			retreatMultiplier = 1 + maneuverabilityRetreatMultiplier + distanceRetreatMultiplier + healthRetreatMultiplier + firepowerRetreatMultiplier
			println("retreat chance multiplier is "..retreatMultiplier)
			retreatMultiplier = math.clamp(retreatMultiplier, 0, 2)
			println("clamped retreat chance multiplier is "..retreatMultiplier)
--			retreatChance = math.random(0, 100)
			println("retreat chance is "..retreatChance)
			retreatChanceMultiplied = baseRetreatChance * retreatMultiplier
			println("retreat chance multiplied is "..retreatChanceMultiplied)
			retreatChanceMultiplied = math.clamp(retreatChanceMultiplied, 0, 100)
			println("clamped retreat chance multiplied is "..retreatChanceMultiplied)
			if retreatChance <= retreatChanceMultiplied then
				-- retreat successful
				println("friendly numba "..i.." retreated successfully")
			else
				-- retreat unsuccessful
				println("friendly numba "..i.." didn't manage to retreat")
				j = j + 1
				friendliesLostNames[j] = friendliesEndNames[i]
				friendliesEndHealth[i] = 0
				println("added ship to the friendlies lost list")
				-- remove ship from the lists by table.remove(parameterslist, i)
			end
		end

		-- updating info about surviving friendlies
		println("updating info")
		j = 1
		println("friendlies end count before update is "..friendliesEndCount)
		while j<=getn(friendliesStart) do
			println("updating info for "..j)
			if friendliesEndHealth[j]==0 then
				if friendliesEnd[j] then
					table.remove(friendliesEnd, j)
				end
				if friendliesEndHealth[j] then
					table.remove(friendliesEndHealth, j)
				end
				if friendliesEndTypes[j] then
					table.remove(friendliesEndTypes, j)
				end
				if friendliesEndPrototypes[j] then
					table.remove(friendliesEndPrototypes, j)
				end
				if friendliesEndStartingHealth[j] then
					table.remove(friendliesEndStartingHealth, j)
				end
				if friendliesEndVehicleHealth[j] then
					table.remove(friendliesEndVehicleHealth, j)
				end
				if friendliesEndFirepower[j] then
					table.remove(friendliesEndFirepower, j)
				end
				if friendliesEndManeuverability[j] then
					table.remove(friendliesEndManeuverability, j)
				end
				if friendliesEndNames[j] then
					table.remove(friendliesEndNames, j)
				end
				println("removed "..j)
			else
				println("skipped "..j)
				j = j + 1
			end
		end

		friendliesEndCount = getn(friendliesEnd)
		println("friendlies end count after update is "..friendliesEndCount)
		println("friendlies end are: "..TableToString(friendliesEnd))
		println("done updating info")

--		println("friendliesStart - friendliesEndNames ")
--		isTableEmpty = next(friendliesEndNames)
--		if isTableEmpty ~= nil then
--			friendliesEndCount = getn(friendliesEndNames)
--		end
--		println("friendl end count "..friendliesEndCount)
		println(getn(friendliesEnd))
		println(getn(friendliesEndHealth))
		println(getn(friendliesEndTypes))
		println(getn(friendliesEndPrototypes))
		println(getn(friendliesEndStartingHealth))
		println(getn(friendliesEndVehicleHealth))
		println(getn(friendliesEndFirepower))
		println(getn(friendliesEndManeuverability))
		println(getn(friendliesEndNames))
		-- updated the tables with friendlies information
		-- packing the info about surviving friendlies into one giant table of tables (survivingFriendliesInformation)
		if friendliesEndCount > 0 then
			for i=1, friendliesEndCount do
				survivingFriendliesInformation[i] = {}
				survivingFriendliesInformation[i][1] = friendliesEndTypes[i]
				survivingFriendliesInformation[i][2] = friendliesEndPrototypes[i]
				survivingFriendliesInformation[i][3] = friendliesEndStartingHealth[i]
				survivingFriendliesInformation[i][4] = friendliesEndVehicleHealth[i]
				survivingFriendliesInformation[i][5] = friendliesEndFirepower[i]
				survivingFriendliesInformation[i][6] = friendliesEndManeuverability[i]
				survivingFriendliesInformation[i][7] = friendliesEndNames[i]
				println("surv friendly info done for "..i)
			end
		end

		println("done with surv friendlies info")
	end

	-- ==========
	-- stuff for score calculation
	-- ==========

	local missionScore = GetVar("TotalMissionScore").AsInt
	println("mission score is "..missionScore)
	local objectiveScoreReward = GetVar("ObjectiveScoreReward").AsInt -- used later in final stats
	local missionScoreRewardMultiplier = GetVar("MissionScoreRewardMultiplier").AsFloat -- used later in final stats
	local enemiesStartTotalFirepower = 0
	local friendliesStartTotalFirepower = 0
	local friendliesEndTotalFirepower = 0
	isTableEmpty = next(enemiesStart)
	println("istableempty enemiesStart")
	if isTableEmpty ~= nil then
		println("istableempty enemiesStart is not empty")
		isTableEmpty = next(enemiesStartFirepower)
		if isTableEmpty ~= nil then
			println("istableempty enemiesStartFirepower is not empty")
			for i=1, getn(enemiesStartFirepower) do
				enemiesStartTotalFirepower = enemiesStartTotalFirepower + enemiesStartFirepower[i]
			end
			println("enemies start total firepower "..enemiesStartTotalFirepower)
			println("enemies end total firepower "..enemiesEndTotalFirepower)
			missionScore = missionScore + (enemiesStartTotalFirepower - enemiesEndTotalFirepower)
			println("updated mission score is "..missionScore)
		end
	end
		
	isTableEmpty = next(friendliesStartFirepower)
	if isTableEmpty ~= nil then
		for i = 1, getn(friendliesStartFirepower) do
			friendliesStartTotalFirepower = friendliesStartTotalFirepower + friendliesStartFirepower[i]
		end
		isTableEmpty = next(friendliesEndFirepower)
		if isTableEmpty ~= nil then
			for i = 1, getn(friendliesEndFirepower) do
				friendliesEndTotalFirepower = friendliesEndTotalFirepower + friendliesEndFirepower[i]
			end
		end

		println("friendlies start total firepower "..friendliesStartTotalFirepower)
		println("friendlies end total firepower "..friendliesEndTotalFirepower)
		missionScore = missionScore - (friendliesStartTotalFirepower - friendliesEndTotalFirepower)
	end
	

	-- mission score is updated later depending on whether the secondary objectives are completed

	-- ==========
	-- stuff for final stats calculation
	-- ==========

	local friendliesStartTotalHealth = 0 -- the starting health is used for comparison with the ending health and as a result the percentage of losses
	local friendliesEndTotalHealth = 0
	local friendliesLossesPercentage = 0
	local friendliesLosses = 0
	local friendliesEquipmentLosses = getn(friendliesStart) + 1
	for i=1, getn(friendliesStart) do
		friendliesStartTotalHealth = friendliesStartTotalHealth + friendliesStartHealth[i]
	end
	println("friendlies total starting health "..friendliesStartTotalHealth)
	if friendliesEnd ~= nil then
		isTableEmpty = next(friendliesEnd)
		if isTableEmpty ~= nil then
	--		friendliesEndCount = getn(friendliesEnd)
			for i=1, friendliesEndCount do
				friendliesEndTotalHealth = friendliesEndTotalHealth + friendliesEndHealth[i]
			end
	--	else
	--		friendliesEndCount = 0
		end
	end
	local playerVehicle = GetPlayerVehicle()
	local playerHealth = GetVar("PlayerHealth").AsInt
	local playerVehicleHealth = GetVar("PlayerVehicleHealth").AsInt
	local playerCurrentHealth = 0
	local playerLosses = 0
	println("checking if player is alive")
	if playerVehicle and playerVehicle:IsAlive() then
		println("they are!")
		playerCurrentHealth = GetVar("PlayerEndHealth").AsInt
		println("got effective health "..playerCurrentHealth)
		if playerDead ~= 1 then
			friendliesEndCount = friendliesEndCount + 1 -- adds player vehicle into the friendlies count for determining whether the objective is complete, it's 30 lines below
			println("player added to alive friendlies")
		else
			println("player died, was not added from alive friendlies")
		end
	end
	println("friendlies total ending health "..friendliesEndTotalHealth)
	friendliesLossesPercentage = 100 - (friendliesEndTotalHealth + playerCurrentHealth) / (friendliesStartTotalHealth + playerHealth) * 100 -- used to show the player the losses allies took in the final stats
	friendliesLosses = (friendliesStartTotalHealth - friendliesEndTotalHealth) / 6.5 + (playerHealth - playerCurrentHealth) / 6.5 -- used to show the player the losses allies took in the final stats
	println("friendlies Start = "..friendliesEquipmentLosses)
	println("friendlies End = "..friendliesEndCount)
	friendliesEquipmentLosses = friendliesEquipmentLosses - friendliesEndCount
	println("friendlies losses percent "..friendliesLossesPercentage)
	println("friendlies losses in manpower "..friendliesLosses)
	println("friendlies equipment losses "..friendliesEquipmentLosses)

	local enemiesStartTotalHealth = 0 -- the starting health is used for comparison with the ending health and as a result the percentage of losses
	local enemiesLossesPercentage = 0
	local enemiesLosses = 0
	local enemiesEquipmentLosses = getn(enemiesStart) - enemiesEndCount
	for i=1, getn(enemiesStart) do
		enemiesStartTotalHealth = enemiesStartTotalHealth + enemiesStartHealth[i]
	end
	println("enemies total starting health "..enemiesStartTotalHealth)
	println("enemies total ending health "..enemiesEndTotalHealth)

	enemiesLossesPercentage = 100 - enemiesEndTotalHealth / enemiesStartTotalHealth * 100 -- used to show the player the losses enemies took in the final stats
	enemiesLosses = (enemiesStartTotalHealth - enemiesEndTotalHealth) / 6.5 -- used to show the player the losses enemies took in the final stats
	println("enemies losses percent "..enemiesLossesPercentage)
	println("enemies losses in manpower "..enemiesLosses)
	println("enemies equipment losses "..enemiesEquipmentLosses)

	local totalObjectives = GetVar("Objectives").AsInt + 2
	println("objectives "..totalObjectives)
	local totalObjectivesCompleted = GetVar("ObjectivesCompleted").AsInt
	println("objectives completed "..totalObjectivesCompleted)
--	if totalObjectivesCompleted == (totalObjectives - 2) then
	if totalObjectivesCompleted >= 2 then
		if getn(friendliesStart) + 1 == friendliesEndCount then
			totalObjectivesCompleted = totalObjectivesCompleted + 1
			missionScore = missionScore + objectiveScoreReward
			println("all friendlies survived, +1 objective complete")
		end
		if enemiesEndCount == 0 then
			totalObjectivesCompleted = totalObjectivesCompleted + 1
			missionScore = missionScore + objectiveScoreReward
			println("all enemies are dead, +1 objective complete")
		end
	end
	local completionPercentage = totalObjectivesCompleted / totalObjectives * 100
	println("completion percentage is "..completionPercentage)

	local missionTime = GetVar("MissionTime").AsInt
	local requiredMissionTime = GetVar("RequiredMissionTime").AsInt
	local pointsMissionTimeMultiplier = 0
	local pointsMissionTime = 0
	local requiredCompletionPercentage = 40
	if totalObjectives <= 4 then
		requiredCompletionPercentage = 50
	end

	if completionPercentage >= requiredCompletionPercentage then
		if missionTime <= requiredMissionTime then
			println("mission time "..missionTime.." is less than required "..requiredMissionTime)
			pointsMissionTimeMultiplier = (requiredMissionTime / missionTime)^2
			println("multiplier is "..pointsMissionTimeMultiplier)
			pointsMissionTime = objectiveScoreReward * pointsMissionTimeMultiplier
			println("so points received from time are "..pointsMissionTime)
			missionScore = missionScore + pointsMissionTime
			println("updated mission score is "..missionScore)
		else
			println("mission time "..missionTime.." is bigger than required "..requiredMissionTime)
			if missionTime <= (requiredMissionTime * 2) then
				println("mission time "..missionTime.." is less than double required "..requiredMissionTime.." though")
				pointsMissionTimeMultiplier = requiredMissionTime / missionTime
				println("multiplier is "..pointsMissionTimeMultiplier)
				pointsMissionTime = objectiveScoreReward * pointsMissionTimeMultiplier
				println("so points received from time are "..pointsMissionTime)
				missionScore = missionScore + pointsMissionTime
				println("updated mission score is "..missionScore)
			end
		end
	end

	if missionScore < 0 then
		missionScore = 0
		println("mission score less than zero")
	end

	gFriendliesLossesPercentage = math.floor(friendliesLossesPercentage)
	gFriendliesLosses = round(friendliesLosses)
	gFriendliesEquipmentLosses = friendliesEquipmentLosses
	gFriendliesLostNames = ""
	if friendliesLostNames ~= nil then
		isTableEmpty = next(friendliesLostNames)
		if isTableEmpty ~= nil then
			for i=1, getn(friendliesLostNames) do
				if friendliesLostNames[i] ~= "none" then
					gFriendliesLostNames = gFriendliesLostNames..friendliesLostNames[i]
					if i ~= getn(friendliesLostNames) and getn(friendliesLostNames) ~= 1 then
						gFriendliesLostNames = gFriendliesLostNames..", "
					end
				end
			end

			if playerDead == 1 then
				gFriendliesLostNames = gFriendliesLostNames..", "..GetVar("PlayerName").AsString
			end
		else
			if playerDead == 1 then
				gFriendliesLostNames = GetVar("PlayerName").AsString
			end
		end
	end
	gEnemiesLossesPercentage = math.floor(enemiesLossesPercentage)
	gEnemiesLosses = round(enemiesLosses)
	gEnemiesEquipmentLosses = enemiesEquipmentLosses
	gTotalObjectives = totalObjectives
	gObjectivesCompleted = totalObjectivesCompleted
	gCompletionPercentage = math.floor(completionPercentage)
	gMissionScoreTime = math.floor(pointsMissionTime)
	gMissionScore = math.floor(missionScore)
	gMissionReward = math.floor(missionScore * missionScoreRewardMultiplier)
	println(gMissionScore)
	println(gMissionReward)
	if survivingFriendliesInformation~=nil then
		isTableEmpty = next(survivingFriendliesInformation)
		if isTableEmpty ~= nil then
			gSurvivingFriendliesInformation = survivingFriendliesInformation
			for i=1, getn(gSurvivingFriendliesInformation) do
				println(TableToString(gSurvivingFriendliesInformation[i]))
			end
		end
	end

	gMissionCompleted = true
end

-- function that shows mission stats on the screen
-- to be used only on the hq map
function ShowMissionStats()
	if gMissionCompleted then
		println("friendlies lost percent "..gFriendliesLossesPercentage)
		println("friendlies manpower lost "..gFriendliesLosses)
		println("friendlies vehicles lost "..gFriendliesEquipmentLosses)
		if gFriendliesEquipmentLosses > 0 then
			println("names of the friendlies lost "..gFriendliesLostNames)
		end
		println("enemies lost percent "..gEnemiesLossesPercentage)
		println("enemies manpower lost "..gEnemiesLosses)
		println("enemies vehicles lost "..gEnemiesEquipmentLosses)
		println("mission completed percent "..gCompletionPercentage)
		println("objectives given "..gTotalObjectives..", completed "..gObjectivesCompleted)
		AddImportantFadingMsgByStrIdFormatted("fm_empty")
		AddImportantFadingMsgByStrIdFormatted("fm_empty")
		AddImportantFadingMsgByStrIdFormatted("fm_empty")
		AddImportantFadingMsgByStrIdFormatted("fm_missionstats_allieslost_percentage", gFriendliesLossesPercentage)
		AddFadingMsgByStrIdFormatted("fm_missionstats_allieslost_manpower", gFriendliesLosses)
		AddFadingMsgByStrIdFormatted("fm_missionstats_allieslost_vehicles", gFriendliesEquipmentLosses)
		if gFriendliesEquipmentLosses > 0 then
			AddFadingMsgByStrIdFormatted("fm_missionstats_allieslost_names", gFriendliesLostNames)
		else
			AddFadingMsgByStrIdFormatted("fm_empty")
		end
		AddFadingMsgByStrIdFormatted("fm_empty")
		local b = SpawnMessageBox("9000")
		if b == 1 then
			AddImportantFadingMsgByStrIdFormatted("fm_empty")
			AddImportantFadingMsgByStrIdFormatted("fm_empty")
			AddImportantFadingMsgByStrIdFormatted("fm_empty")
			AddImportantFadingMsgByStrIdFormatted("fm_missionstats_enemiesdestroyed_percentage", gEnemiesLossesPercentage)
			AddFadingMsgByStrIdFormatted("fm_missionstats_enemiesdestroyed_manpower", gEnemiesLosses)
			AddFadingMsgByStrIdFormatted("fm_missionstats_enemiesdestroyed_vehicles", gEnemiesEquipmentLosses)
			AddFadingMsgByStrIdFormatted("fm_empty")
			AddFadingMsgByStrIdFormatted("fm_empty")
			b = SpawnMessageBox ("9001")
			if b == 1 then
				AddImportantFadingMsgByStrIdFormatted("fm_empty")
				AddImportantFadingMsgByStrIdFormatted("fm_empty")
				AddImportantFadingMsgByStrIdFormatted("fm_missionstats_objectives_percentage", gCompletionPercentage)
				if gTotalObjectives <= 4 then
					if gCompletionPercentage >= 90 then
						-- overachieved
						println("mission objectives overachieved")
						AddImportantFadingMsgByStrIdFormatted("fm_missionstats_result_overachieved", gCompletionPercentage)
					elseif gCompletionPercentage >= 50 then
						-- success
						println("mission success")
						AddImportantFadingMsgByStrIdFormatted("fm_missionstats_result_success", gCompletionPercentage)
					else
						-- failure
						println("mission failed")
						AddImportantFadingMsgByStrIdFormatted("fm_missionstats_result_fail", gCompletionPercentage)
					end
				else
					if gCompletionPercentage >= 90 then
						-- overachieved
						println("mission objectives overachieved")
						AddImportantFadingMsgByStrIdFormatted("fm_missionstats_result_overachieved", gCompletionPercentage)
					elseif gCompletionPercentage >= 70 then
						-- total success
						println("mission is a total success")
						AddImportantFadingMsgByStrIdFormatted("fm_missionstats_result_totalsuccess", gCompletionPercentage)
					elseif gCompletionPercentage >= 40 then
						-- partial success
						println("mission is partially successful")
						AddImportantFadingMsgByStrIdFormatted("fm_missionstats_result_partialsuccess", gCompletionPercentage)
					elseif gCompletionPercentage >= 20 then
						-- failure
						println("mission failed")
						AddImportantFadingMsgByStrIdFormatted("fm_missionstats_result_fail", gCompletionPercentage)
					else
						-- tactical defeat
						println("tactical defeat has been suffered")
						AddImportantFadingMsgByStrIdFormatted("fm_missionstats_result_defeat", gCompletionPercentage)
					end
				end
				AddFadingMsgByStrIdFormatted("fm_missionstats_objectives_total", gTotalObjectives, gObjectivesCompleted)
				AddFadingMsgByStrIdFormatted("fm_missionstats_points_time", gMissionScoreTime)
				AddFadingMsgByStrIdFormatted("fm_missionstats_points", gMissionScore)
				AddFadingMsgByStrIdFormatted("fm_empty")
				b = SpawnMessageBox ("9002")
				if b == 1 then
					println("points received "..gMissionScore)
					AddPlayerMoney(gMissionReward)
					AddFadingMsgByStrIdFormatted("fm_empty")
					AddFadingMsgByStrIdFormatted("fm_empty")
					AddFadingMsgByStrIdFormatted("fm_empty")
					SetVar("OnMission", 0)
				end
			end
		end

		local playerAffiliation = GetPlayerAffiliation()
		if playerAffiliation == "CIT" then
			SetVar("CITTotalPoints", (GetVar("CITTotalPoints").AsInt + gMissionScore))
			SetVar("CITTotalManpowerLosses", (GetVar("CITTotalManpowerLosses").AsInt + gFriendliesLosses))
			SetVar("CITTotalEquipmentLosses", (GetVar("CITTotalEquipmentLosses").AsInt + gFriendliesEquipmentLosses))
			SetVar("CITTotalManpowerDestroyed", (GetVar("CITTotalManpowerDestroyed").AsInt + gEnemiesLosses))
			SetVar("CITTotalEquipmentDestroyed", (GetVar("CITTotalEquipmentDestroyed").AsInt + gEnemiesEquipmentLosses))
		elseif playerAffiliation == "CD" then
			SetVar("CDTotalPoints", (GetVar("CDTotalPoints").AsInt + gMissionScore))
			SetVar("CDTotalManpowerLosses", (GetVar("CDTotalManpowerLosses").AsInt + gFriendliesLosses))
			SetVar("CDTotalEquipmentLosses", (GetVar("CDTotalEquipmentLosses").AsInt + gFriendliesEquipmentLosses))
			SetVar("CDTotalManpowerDestroyed", (GetVar("CDTotalManpowerDestroyed").AsInt + gEnemiesLosses))
			SetVar("CDTotalEquipmentDestroyed", (GetVar("CDTotalEquipmentDestroyed").AsInt + gEnemiesEquipmentLosses))
		end
		
		println("affiliated score set")
		local convergedTable
		local isTableEmpty
		if gSurvivingFriendliesInformation~=nil then
			isTableEmpty = next(gSurvivingFriendliesInformation)
			println("table of surv friends is empty set")
			if isTableEmpty ~= nil then
				println("table of surv friends is not empty")
				for i=1, getn(gSurvivingFriendliesInformation) do
					println(i)
					if GetVar(gSurvivingFriendliesInformation[i][1]).AsInt~=-1 then
						println(gSurvivingFriendliesInformation[i][1].." exists")
						convergedTable = string.sub(GetVar(gSurvivingFriendliesInformation[i][1]).AsString, 1, -2)..', "'..TableToString(gSurvivingFriendliesInformation[i], 2)..'"}'
						SetVar(gSurvivingFriendliesInformation[i][1], convergedTable)
						println("table converged")
					else
						println(gSurvivingFriendliesInformation[i][1].." does not exist")
						SetVar(gSurvivingFriendliesInformation[i][1], '{"'..TableToString(gSurvivingFriendliesInformation[i], 2)..'"}')
						println("table created")
					end
				end
			end
		end
		println("surviving friendlies info set")

		gMissionCompleted = nil
		gCompletionPercentage = nil
		gTotalObjectives = nil
		gObjectivesCompleted = nil
		gMissionScore = nil
		gMissionReward = nil
		gFriendliesLossesPercentage = nil
		gFriendliesLosses = nil
		gFriendliesEquipmentLosses = nil
		gFriendliesLostNames = nil
		gSurvivingFriendliesInformation = nil
		gEnemiesLossesPercentage = nil
		gEnemiesLosses = nil
		gEnemiesEquipmentLosses = nil
		println("function end")
	end
end