ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_society:registerSociety', 'cluckinbell', 'Cluckin Bell', 'society_cluckinbell', 'society_cluckinbell', 'society_cluckinbell', {type = 'public'})

RegisterServerEvent('LCRP_CluckinBellJob:getStockItem')
AddEventHandler('LCRP_CluckinBellJob:getStockItem', function(itemName, count)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  
  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_cluckinbell', function(inventory)
    local storedItem = inventory.getItem(itemName)
    if storedItem then -- if the item is in the storage
      if storedItem.count >= tonumber(count) then -- If the amount they wish to remove is less or equal than the amount in the storage
        inventory.removeItem(itemName, count)
        xPlayer.addInventoryItem(itemName, count)
        local msg =  'You removed ' .. count .. 'x ' ..  item.label 
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = msg, style = { ['background-color'] = '#5aab61', ['color'] = '#000000' } })
      else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Invalid Entry: You are trying to take more than there is.', style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
      end
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'You are trying to take an item that does not exist! Fuck off.', style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
    end
  end)
end)

ESX.RegisterServerCallback('LCRP_CluckinBellJob:getStockItems', function(source, cb)
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_cluckinbell', function(inventory)
  
      cb(inventory.items)
    end)
  end)

RegisterServerEvent('LCRP_CluckinBellJob:putStockItems')
AddEventHandler('LCRP_CluckinBellJob:putStockItems', function(itemName, count)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_cluckinbell', function(inventory)
    local item = inventory.getItem(itemName)
    local storingItemCount = xPlayer.getInventoryItem(itemName).count

    if item.count and count <= storingItemCount then
      xPlayer.removeInventoryItem(itemName, count)
      inventory.addItem(itemName, count)
      local msg = 'You stored ' .. count .. 'x '.. item.label
      TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = msg, style = { ['background-color'] = '#5aab61', ['color'] = '#000000' } })
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Invalid Entry: Error with Quantity.', style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
    end
  end)
end)

ESX.RegisterServerCallback('LCRP_CluckinBellJob:getPlayerInventory', function(source, cb)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local items = xPlayer.inventory
  
  cb({items = items})
end)

RegisterServerEvent('LCRP_CluckinBellJob:addItem')
AddEventHandler('LCRP_CluckinBellJob:addItem', function(item)
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.addInventoryItem(item, 1)
end)

RegisterServerEvent('LCRP_CluckinBellJob:removeItem')
AddEventHandler('LCRP_CluckinBellJob:removeItem', function(item)
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.removeInventoryItem(item, 1)
end)

ESX.RegisterUsableItem('cluckin_drink', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('cluckin_drink', 1)
	TriggerClientEvent('esx_status:add', source, 'thirst', 250000)
	--TriggerClientEvent('esx_basicneeds:onDrink', source)
  TriggerClientEvent('LCRP_CluckinBellJob:GiveBonus', source, 'drink')
	--TriggerClientEvent('esx:showNotification', source, "~b~You drank a ~y~Cluckin' Bell ~b~ Drink.")
  TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = "You drank a Cluckin' Drink."})
  --Add the speed boost
end)


ESX.RegisterUsableItem('cluckin_fries', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('cluckin_fries', 1)
	TriggerClientEvent('esx_status:add', source, 'hunger', 150000)
	--TriggerClientEvent('esx_basicneeds:onEat', source)
  TriggerClientEvent('LCRP_CluckinBellJob:GiveBonus', source, 'fries')
  --TriggerClientEvent('esx:showNotification', source, "~b~You ate some ~y~Cluckin' Bell ~b~ Fries.")
  --Add 5% armor
  TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = "You ate some Cluckin' Fries."})
end)

ESX.RegisterUsableItem('cluckin_tendies', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('cluckin_tendies', 1)
	TriggerClientEvent('esx_status:add', source, 'hunger', 250000)
	--TriggerClientEvent('esx_basicneeds:onEat', source)
  TriggerClientEvent('LCRP_CluckinBellJob:GiveBonus', source, 'tendies')
	--TriggerClientEvent('esx:showNotification', source, "~b~You ate a ~y~Cluckin' Bell ~b~ Burger.")
  TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = "You ate some Cluckin' Tendies."})
end)

ESX.RegisterUsableItem('cluckin_meal', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('cluckin_meal', 1)
	TriggerClientEvent('esx_status:add', source, 'hunger', 750000)
	TriggerClientEvent('esx_status:add', source, 'thirst', 750000)
	--TriggerClientEvent('esx_basicneeds:onEat', source)
  TriggerClientEvent('LCRP_CluckinBellJob:GiveBonus', source, 'meal')
	--TriggerClientEvent('esx:showNotification', source, "You wolfed down a Cluckin' Meal. ")
  TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = "You wolfed down a Cluckin' Meal."})
  --Add 15% armor
end)