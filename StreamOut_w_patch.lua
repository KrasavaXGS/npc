script_name("StreamOut - random peds for your samp")
script_author("BezlikiY")

local active=false
local memory=require("memory")

local peds = {[1]=nil}
local thread
--local ai = {[1] = nil}
--for i=1,50 do
--	ai[i]=true
--end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	memory.copy(0x5F0360, memory.strptr("\xc2\x0c\x00"), 3, true)
	sampRegisterChatCommand('streamout', function()
		lua_thread.create(toggle)
	end)

	-- lua_thread.create(toggle) -- remove '--' at the beginning of this line to make script active by default

	while true do

		wait(0)
	end
end


function toggle()
	active = not active
	if active then
		sampAddChatMessage("Stream Out! Spawning peds.", 0xFFFFFFFF)
		thread = lua_thread.create(pedThread)
	else
		sampAddChatMessage("Stream In! Removing random peds.", 0xFFFFFFFF)
		wait(1000)
		for i=0,100 do
			if doesCharExist(peds[i]) then 
				removeCharElegantly(peds[i]) 
				peds[i]=nil
			end
		end
	end
end

function pedThread()
	while active do
		wait(500)
		skin = math.floor(math.random(9, 299) + 0.5) -- из peds.ide
		if skin==74 then skin=75 end
		requestModel(skin)
		loadAllModelsNow()
		wait(500)
		x, y, z = getCharCoordinates(playerPed)
		nx, ny, nz = getClosestCarNode(x+math.random(-100, 100), y+math.random(-100, 100), z)
		q = #peds+1
		if getDistanceBetweenCoords2d(x, y, nx, ny)>10 and q < 50 then 
			peds[q] = createChar(6, skin, nx, ny, nz-50)
			if doesCharExist(peds[q]) then
				taskWanderStandard(peds[q])
				setCharDropsWeaponsWhenDead(peds[q], false)
			end
		end
		for i=0,51 do
			if doesCharExist(peds[i]) then
				cx, cy, cz = getCharCoordinates(peds[i])
				if doesCharExist(peds[i]) then
--[[					if isCharSittingInAnyCar(playerPed) then 
						setCharCollision(peds[i], false)
						clearCharTasks(peds[i])
						ai[i] = false
					else 
						if not ai[i] then
							setCharCollision(peds[i], true)
							taskWanderStandard(peds[i])
							ai[i]=true
						end
					end]]
				end
				if getDistanceBetweenCoords2d(x, y, cx, cy)>120 or isCharDead(peds[i]) then
					removeCharElegantly(peds[i])
					peds[i]=nil
				end
			end
		end
		markModelAsNoLongerNeeded(skin)
	end
end

function onScriptTerminate(script, quitGame)
	for i=0,51 do
		if doesCharExist(peds[i]) then removeCharElegantly(peds[i]) end
	end
	if not quitGame and script == thisScript() then thisScript():reload() end
end
