local PlayerData = {}
local playerBusy = false
local bossSpawned = false


local invDrink = 0
local invTendies = 0
local invFries = 0
local invMeal = 0

local vehiclesSpawned = 0
local playerPed = PlayerPedId(-1)

ESX = nil

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

--Menu Functions
function openBillingMenu()
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'job_menu',
	{
		title    = _U('billing_menu'),
		align    = 'top-right',
		elements = {
            
			{label = _U("sell_tendies"),	    value = 'sell_tendies'}, --250, 25% Food
			{label = _U("sell_fries"),	        value = 'sell_fries'}, --250, +5% Armor 
			{label = _U("sell_drink"),          value = 'sell_drink'}, --1K, 25% Water, speed boost
            {label = _U("sell_meal"),           value = 'sell_meal'}, --2K, Full Food and Water, 15% armor
            {label = _U("sell_multiple"),       value = 'sell_multiple'}, --For lot sales
		}
	}, function(data, menu)
        if data.current.value == "sell_tendies" then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            local amount = 50
            if closestPlayer == -1 or closestDistance > 4.0 then
                ESX.ShowNotification(_U('no_players'), false, false, 0)
            else
                TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_cluckinbell', "Cluckin' Tendies", amount)
            end
        elseif data.current.value == "sell_fries" then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            local amount = 50
            if closestPlayer == -1 or closestDistance > 4.0 then
                ESX.ShowNotification(_U('no_players'), false, false, 0)
            else
                TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_cluckinbell', "Cluckin' Fries", amount)
                menu.close()
            end
            
        elseif data.current.value == "sell_drink" then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            local amount = 75
            if closestPlayer == -1 or closestDistance > 4.0 then
                ESX.ShowNotification(_U('no_players'), false, false, 0)
            else
                TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_cluckinbell', "Cluckin' Drink", amount)
                menu.close()
            end
        elseif data.current.value == "sell_meal" then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            local amount = 200
            if closestPlayer == -1 or closestDistance > 4.0 then
                ESX.ShowNotification(_U('no_players'), false, false, 0)
            else
                TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_cluckinbell', "Cluckin' Meal", amount)
                menu.close()
            end
        elseif data.current.value == "sell_multiple" then
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'multiple',
            {
                title = _U('enter_bill')
            }, function(data2, menu2)
                local amount = tonumber(data2.value)
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer == -1 or closestDistance > 4.0 then
                    ESX.ShowNotification(_U('no_players'), false, false, 0)
                else
                    if amount ~= nil then
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_cluckinbell', "Cluckin' Bill", amount)
                        menu2.close()
                    else
                        ESX.ShowNotification(_U('invalid_entry'), false, false, 0)
                    end
                end
            end)
        end
    end)
end

function OpenVaultMenu()
    if Config.EnableVaultManagement then
      local elements = {
        {label = _U('get_stock'), value = 'get_stock'},
        {label = _U('put_stock'), value = 'put_stock'}
      }
  
      ESX.UI.Menu.CloseAll()
  
      ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vault', {
          title    = _U('vault'),
          align    = 'top-right',
          elements = elements,
        }, function(data, menu)

          if data.current.value == 'get_stock' then
             OpenGetStocksMenu()
          end

          if data.current.value == 'put_stock' then
            OpenPutStocksMenu()
         end
        end, function(data, menu)
  
          menu.close()
  
        end)
    end
end

function OpenGetStocksMenu()
    ESX.TriggerServerCallback('LCRP_CluckinBellJob:getStockItems', function(items)
      local elements = {}
        for i, j in ipairs(items) do
            if j.count ~= 0 then
                if j.label then
                    table.insert(elements, {label = 'x' .. j.count .. ' ' .. j.label, value = j.name})
                end
            end
        end
  
      ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
          title    = _U('vault'),
          align    = 'top-right',
          elements = elements
        }, function(data, menu)
  
          local itemName = data.current.value
  
          ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
              title = _U('quantity')
            }, function(data2, menu2)
  
              local count = tonumber(data2.value)
  
              if count == nil then
                ESX.ShowNotification(_U('invalid_entry'))
              else
                OpenGetStocksMenu()
  
                TriggerServerEvent('LCRP_CluckinBellJob:getStockItem', itemName, count)
                ESX.UI.Menu.CloseAll()
              end
            end, function(data2, menu2)
              menu2.close()
            end)
        end, function(data, menu)
          menu.close()
        end)
    end)
end


function OpenPutStocksMenu()
    ESX.TriggerServerCallback('LCRP_CluckinBellJob:getPlayerInventory', function(inventory)
        local elements = {}
        for i, j in pairs(inventory.items) do
            if j.count > 0 then
                table.insert(elements, {label = j.label .. " x" .. j.count, type = "item_standard", value = j.name})
            end
        end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
        title    = _U('vault'),
        align    = 'top-right',
        elements = elements
      }, function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
            title = _U('quantity')
          }, function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
              ESX.ShowNotification(_U('invalid_entry'))
            else
              menu2.close()
              menu.close()
              OpenPutStocksMenu()

              TriggerServerEvent('LCRP_CluckinBellJob:putStockItems', itemName, count)
              ESX.UI.Menu.CloseAll()
            end
          end, function(data2, menu2)
            menu2.close()
          end)
      end, function(data, menu)
        menu.close()
      end)
  end)
end

function isEmployed()
    PlayerData = ESX.GetPlayerData()
    if PlayerData ~= nil then
        local isJobTrue = false
        if PlayerData.job ~= nil and PlayerData.job.name == "cluckinbell" then
            isJobTrue = true
        end
        return isJobTrue
    end
end

function isBoss()
    PlayerData = ESX.GetPlayerData()
    if PlayerData ~= nil then 
        local isBoss = false
        if PlayerData.job.grade_name == "boss" then
            isBoss = true
        end
        return isBoss
    end
end

--Event Handlers


--Food Bonuses
RegisterNetEvent('LCRP_CluckinBellJob:GiveBonus')
AddEventHandler('LCRP_CluckinBellJob:GiveBonus', function(item)
    local playerPed = PlayerId()
    local ped = GetPlayerPed(-1)
    print(item)
    if item == 'drink' then
        if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
            exports['progressBars']:startUI(1000, "Drinking Coke")
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            local timer = 0
            while timer < 10 do 
                SetPedMoveRateOverride(PlayerId(),10.0)
                SetRunSprintMultiplierForPlayer(PlayerId(),1.15)
                ResetPlayerStamina(PlayerId())
                Citizen.Wait(2000)
                timer = timer + 2
            end
            SetRunSprintMultiplierForPlayer(playerPed,1.0)
            ClearPedTasks(PlayerPedId())
        end
    elseif item == 'tendies' then
        --No bonus
        exports['progressBars']:startUI(1000, "Eating Tendies")
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
    elseif item == 'fries' then
        if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
            exports['progressBars']:startUI(1000, "Eating Fries")
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            local armor = GetPedArmour(ped)
            if armor <= 90 then
                armor = armor + 5
                SetPedArmour(ped, armor)
            else
                SetPedArmour(ped, 100)
            end
        end
        ClearPedTasks(PlayerPedId())
    elseif item == 'meal' then
        if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
            exports['progressBars']:startUI(1000, "Eating Fries")
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            local armor = GetPedArmour(ped)
            if armor <= 90 then
                armor = armor + 15
                SetPedArmour(ped, armor)
            else
                SetPedArmour(ped, 100)
            end
        end
        ClearPedTasks(PlayerPedId())
    end
end)

--Player load
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)
--Job check and set for PlayerData
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

--Spawn Boss NPC
RegisterNetEvent('LCRP_CluckinBellJob:spawnBoss')
AddEventHandler('LCRP_CluckinBellJob:spawnBoss', function(coords, heading)
    local hash = GetHashKey(Config.BossPed)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    bossSpawned = true
    boss = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(boss, true)
    SetBlockingOfNonTemporaryEvents(boss, true)
    SetEntityInvincible(boss, true)
	while not TaskStartScenarioInPlace(npc,"WORLD_HUMAN_CLIPBOARD_FACILITY", 0, false) do
		Wait(200)
	end
end)


RegisterNetEvent('LCRP_CluckinBellJob:openBossMenu')
AddEventHandler('LCRP_CluckinBellJob:openBossMenu', function()
    if isBoss() then
        ESX.UI.Menu.CloseAll()
              
        TriggerEvent('esx_society:openBossMenu', 'cluckinbell', function(data, menu)

          menu.close()
        end,options)
    else
        ESX.ShowNotification(_U('wrong_grade'), false, false, 0)
    end
end)

RegisterNetEvent('LCRP_CluckinBellJob:openStaffMenu')
AddEventHandler('LCRP_CluckinBellJob:openStaffMenu', function()
    OpenVaultMenu()
end)

RegisterNetEvent('LCRP_CluckinBellJob:getVehicle')
AddEventHandler('LCRP_CluckinBellJob:getVehicle', function()
    if vehiclesSpawned < 2 then
        ESX.Game.SpawnVehicle(Config.Vehicle.Code, Config.Vehicle.Pos, Config.Vehicle.Heading, function(vehicle)
            local playerPed = GetPlayerPed(-1)
            TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)  -- teleport into vehicle
        end)
        vehiclesSpawned = vehiclesSpawned + 1
    else
        ESX.ShowNotification(_U('too_many'), false, false, 0)
    end
end)

--Threads Start Here 

Citizen.CreateThread(function()
    while ESX == nil do
      TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
      Citizen.Wait(0)
    end

   
end)

--Key Controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, Keys['F6']) and isEmployed() and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'job_menu') then
            openBillingMenu()
        else 
        end
        if IsControlJustReleased(0, Keys['BACKSPACE']) and isEmployed() and ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'job_menu') then
            ESX.UI.Menu.CloseAll()
        end
    end
end)

--Spawn Boss Ped
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local myCoords = GetEntityCoords(GetPlayerPed(-1))
        local bossCoords = vector3(Config.BossCoords.x, Config.BossCoords.y, Config.BossCoords.z)
        local dist = #(bossCoords - myCoords)

        if dist < 75 and bossSpawned == false then 
            TriggerEvent('LCRP_CluckinBellJob:spawnBoss', bossCoords, Config.BossHeading)
            bossSpawned = true
        end
        if dist >= 76 then
            bossSpawned = false
            DeletePed(boss)
        end
    end
end)

--BT Target events
Citizen.CreateThread(function()
    --Boss
    local manager = {
        `s_m_m_linecook`,
    }
    exports['qtarget']:AddTargetModel(manager, {
        options =  {
            {
                event = "LCRP_CluckinBellJob:openBossMenu", --find boss menu event, add permission check
                icon = "fas fa-clipboard",
                label = "Open Boss Menu",
            },
            {
                event = "LCRP_CluckinBellJob:openStaffMenu", -- Open Employee menu
                icon = "fas fa-clipboard",
                label = "Open Employee Menu",
            },
        },
        job = {'cluckinbell'},
        distance = 1.0

    })
    --Fries and Tendies
    exports['qtarget']:AddBoxZone("CluckinFries", vector3(-520.7, -701.45, 33.57), 0.8, 0.4, {
        name="CluckinFries",
        heading = 0,
        debugPoly = false,
        minZ = 30.00,
        maxZ=  40.00
    }, {
        options = {
            {
                event = "LCRP_CluckinBellJob:getFries",
                icon = "fas fa-bread-slice",
                label = _U("cook_fries")
            },
            {
                event = "LCRP_CluckinBellJob:getTendies",
                icon = "fas fa-bread-slice",
                label = _U("cook_tendies")
            },
        },
            job = {"cluckinbell"},
            distance = 1.5
    })
    --Tendies
--[[    exports['bt-target']:AddBoxZone("CluckinTendies", vector3(279.6, -977.86, 28.37), 0.8, 0.4, {
        name="CluckinTendies",
        heading = 0,
        debugPoly = false,
        minZ = 28.00,
        maxZ=   30.00
    }, {
        options = {
            {
                event = "LCRP_CluckinBellJob:getTendies",
                icon = "fas fa-bread-slice",
                label = _U("cook_tendies")
            },
        },
            job = {"cluckinbell"},
            distance = 1.5
    })]]--
    --Drinks
    exports['qtarget']:AddBoxZone("CluckinDrinks", vector3(-514.30, -699.14, 33.17), 0.8, 0.4, {
        name="CluckinDrinks",
        heading = 0,
        debugPoly = false,
        minZ = 30.00,
        maxZ=   40.00
    }, {
        options = {
            {
                event = "LCRP_CluckinBellJob:getDrink",
                icon = "fas fa-bread-slice",
                label = _U("get_drink")
            },
            
        },
            job = {"cluckinbell"},
            distance = 1.5
    })

    --Meals
    exports['qtarget']:AddBoxZone("CluckinMeals", vector3(-520.88, -698.66, 33.17), 0.8, 0.4, {
        name="CluckinMeals",
        heading = 0,
        debugPoly = false,
        minZ = 30.00,
        maxZ=   40.00
    }, {
        options = {
            {
                event = "LCRP_CluckinBellJob:getMeal",
                icon = "fas fa-bread-slice",
                label = _U("make_meal")
            },
        },
            job = {"cluckinbell"},
            distance = 1.5
    })

    --Delivery Vehicle
    exports['qtarget']:AddBoxZone("CluckinGarage", vector3(-508.94, -678.94, 34.25), 0.8, 0.4, {
        name = "CluckinGarage",
        heading=  0,
        debugPoly = false,
        minZ = 30.00,
        maxZ = 40.00,
    }, {
        options = {
            {
                event = "LCRP_CluckinBellJob:getVehicle",
                icon = "fas fa-motorcycle",
                label = _U("get_vehicle")
            },
    },
        job = {"cluckinbell"},
        distance = 6

    })


end)

--Function to check if player is busy
function playerIsBusy(bool)
    if bool == true then
        FreezeEntityPosition(playerPed, true)
        playerBusy = true
    else
        FreezeEntityPosition(playerPed, false)
        playerBusy = false
    end
end

--Make Food Functions
RegisterNetEvent("LCRP_CluckinBellJob:getFries")
AddEventHandler("LCRP_CluckinBellJob:getFries", function()
    if invFries < 6 then
        playerIsBusy(true)
        SetEntityHeading(playerPed, Config.FriesHeading)
        SetEntityCoords(playerPed, Config.GetFriesPos.x, Config.GetFriesPos.y, Config.GetFriesPos.z)
        startAnim("mp_common", "givetake1_a")
        exports['progressBars']:startUI(Config.CookFriesTime, _('fries_bar'))
        local x,y,z = table.unpack(GetEntityCoords(playerPed))
	    local prop = CreateObject(GetHashKey(Config.FriesName), x, y, z + 0.2, true, true, true)
	    local boneIndex = GetPedBoneIndex(playerPed, 57005)
	    AttachEntityToEntity(prop, playerPed, boneIndex, -0.1, 0, -0.05, 0, 0, 0, true, true, false, true, 1, false)
        Citizen.Wait(Config.CookFriesTime)
        DeleteObject(prop)    
        ClearPedTasks(PlayerPedId())
        TriggerServerEvent("LCRP_CluckinBellJob:addItem", 'cluckin_fries')
        invFries = invFries + 1
        playerIsBusy(false)
    end
end)

RegisterNetEvent("LCRP_CluckinBellJob:getTendies")
AddEventHandler("LCRP_CluckinBellJob:getTendies", function()
    if invTendies < 6 then
        local tempWait = Config.CookTendiesTime / 3
        playerIsBusy(true)
        SetEntityHeading(playerPed, Config.TendiesHeading)
        SetEntityCoords(playerPed, Config.GetTendiesPos.x, Config.GetTendiesPos.y, Config.GetTendiesPos.z)
        local x,y,z = table.unpack(GetEntityCoords(playerPed))
        local prop = CreateObject(GetHashKey(Config.TendiesNames.a), x, y, z + 0.2, true, true, true)
        local boneIndex = GetPedBoneIndex(playerPed, 57005)
        AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
        startAnim("misscarsteal2fixer", "confused_a")
        exports['progressBars']:startUI(Config.CookTendiesTime, _U('tendies_bar'))
        Citizen.Wait(tempWait)
        DeleteObject(prop)
        local prop = CreateObject(GetHashKey(Config.TendiesNames.b), x, y, z + 0.2, true, true, true)
        AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
        Citizen.Wait(tempWait)
        DeleteObject(prop)
        local prop = CreateObject(GetHashKey(Config.TendiesNames.c), x, y, z + 0.2, true, true, true)
        AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
        Citizen.Wait(tempWait)
        DeleteObject(prop)
        ClearPedTasks(PlayerPedId())
        TriggerServerEvent("LCRP_CluckinBellJob:addItem", 'cluckin_tendies')
        invTendies = invTendies + 1
        playerIsBusy(false)
    end
end)

RegisterNetEvent("LCRP_CluckinBellJob:getDrink")
AddEventHandler("LCRP_CluckinBellJob:getDrink", function()
    if invDrink < 6 then
        playerIsBusy(true)
        SetEntityHeading(playerPed, Config.DrinkHeading)
        SetEntityCoords(playerPed, Config.GetDrinkPos.x, Config.GetDrinkPos.y, Config.GetDrinkPos.z)
        startAnim("mp_common", "givetake1_a")
        exports['progressBars']:startUI(Config.MakeDrinkTime, _U('drink_bar'))
        local x,y,z = table.unpack(GetEntityCoords(playerPed))
        local prop = CreateObject(GetHashKey(Config.DrinkName), x, y, z + 0.2, true, true, true)
        local boneIndex = GetPedBoneIndex(playerPed, 28422)
        AttachEntityToEntity(prop, playerPed, boneIndex, 0, 0, -0.085, 10.0, 90, 0.0, true, true, false, false, 0, false)
        Citizen.Wait(Config.MakeDrinkTime)
        DeleteObject(prop)
        ClearPedTasks(PlayerPedId())
        TriggerServerEvent("LCRP_CluckinBellJob:addItem", 'cluckin_drink')
        invDrink = invDrink + 1
        playerIsBusy(false)
    end
end)

RegisterNetEvent("LCRP_CluckinBellJob:getMeal")
AddEventHandler("LCRP_CluckinBellJob:getMeal", function()
    print(invTendies)
    if invTendies > 0 and invDrink > 0 and invFries > 0 then
        playerIsBusy(true)
        SetEntityHeading(playerPed, Config.MealHeading)
        SetEntityCoords(playerPed, Config.GetMealPos.x, Config.GetMealPos.y, Config.GetMealPos.z)
        startAnim("misscarsteal2fixer", "confused_a")
        exports['progressBars']:startUI(Config.PrepMealTime, _U('meal_bar'))
        Citizen.Wait(Config.PrepMealTime)
        ClearPedTasks(PlayerPedId())
        invTendies = invTendies - 1
        invDrink = invDrink - 1
        invFries = invFries - 1
        TriggerServerEvent("LCRP_CluckinBellJob:removeItem", 'cluckin_tendies')
        TriggerServerEvent("LCRP_CluckinBellJob:removeItem", 'cluckin_drink')
        TriggerServerEvent("LCRP_CluckinBellJob:removeItem", 'cluckin_fries')
        TriggerServerEvent("LCRP_CluckinBellJob:addItem",    'cluckin_meal')
        ESX.ShowNotification(_U('meal_complete'), false, false, 0)
    else
        ESX.ShowNotification(_U('meal_error'), false, false, 0)
    end  
        playerIsBusy(false)
end)

--Play animation:
function startAnim(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
	end)
end
