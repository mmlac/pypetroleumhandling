script.on_init(function()
    global.hasbuiltoilderrick = false
    global.oil_to_gas = false
    global.first_chunk = false
    --
    --[[
global.antenna =
	{
		nauvis_antenna = {},
		space_antenna = {}
	}

global.rockets = {}
global.rocket_silo_con_combinator = {}
]]
    global.oil_derricks = {}
end)

script.on_configuration_changed(function()
    if global.hasbuiltoilderrick == nil then global.hasbuiltoilderrick = false end
    if global.oil_to_gas == nil then global.oil_to_gas = false end
    --

    --[[
	if global.antenna == nil then
		global.antenna =
			{
				nauvis_antenna = {},
				space_antenna = {}
			}
	end

	if global.rockets == nil then
		global.rockets = {}
	end
]]
    if global.oil_derricks == nil then global.oil_derricks = {} end
end)

local function oil_gas_select(entity, global_bypass)
    local E = entity
    if string.match(E.name, 'oil%-derrick') ~= nil then
        if global.oil_to_gas == true or global_bypass == true then
            local mk = string.match(E.name, '%d+')
            -- log(mk)
            local oil = game.surfaces['nauvis'].find_entity('oil-mk' .. mk, E.position)
            local gas = game.surfaces['nauvis'].find_entity('natural-gas-' ..
                                                                string.match(string.match(E.name, '%d+'), '[^0]'),
                E.position)
            if oil ~= nil then
                game.surfaces['nauvis'].create_entity {
                    name = 'natural-gas-' .. string.match(string.match(E.name, '%d+'), '[^0]'),
                    amount = oil.amount,
                    position = oil.position
                }
                oil.destroy()
            elseif gas ~= nil then
                game.surfaces['nauvis'].create_entity {
                    name = 'oil-mk' .. mk,
                    amount = gas.amount,
                    position = gas.position
                }
                gas.destroy()
            end
        end
    end
end

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
    local E = event.created_entity
    -- log(E.name)
    if string.match(E.name, 'oil%-derrick') ~= nil then
        oil_gas_select(E)
    elseif string.match(E.name, 'seep') ~= nil and E.type == 'mining-drill' then
        -- log('hit')
        local resource = game.surfaces[E.surface.name].find_entities_filtered {
            area = {{E.position.x - 1, E.position.y - 1}, {E.position.x + 1, E.position.y + 1}},
            type = 'resource'
        }
        for r, re in pairs(resource) do
            -- log(E.name)
            if string.match(re.name, 'oil') then
                game.surfaces[E.surface.name].create_entity {
                    name = 'oil-derrick-mk' .. string.match(E.name, '%d+'),
                    force = E.force,
                    position = E.position
                }
                E.destroy()
            elseif string.match(re.name, 'tar') then
                game.surfaces[E.surface.name].create_entity{
                    name = 'tar-extractor-mk' .. string.match(E.name, '%d+'),
                    force = E.force,
                    position = E.position
                }
                E.destroy()
            else
                local base = ''
                if string.match(E.name, 'bitumen') then
                    base = E.name .. '-base'
                elseif string.match(E.name, 'tar') then
                    base = 'tar-seep-mk01-base'
                end
                local ass1 = game.surfaces[E.surface.name].create_entity {
                    name = base,
                    force = E.force,
                    position = E.position
                }
                ass1.set_recipe('drilling-fluids')
                ass1.active = false
                global.oil_derricks[E.unit_number] = {entity = E, base = ass1, drilling_fluid = ''}
            end
        end
        --[[
	elseif E.name == 'antenna' and E.surface.name == 'nauvis' then
		local cc = game.surfaces[E.surface.name].create_entity{name = 'antenna-constant-combinator', position = {E.position.x + 0.5, E.position.y}, force = E.force}
		global.antenna.nauvis_antenna[E.unit_number] =
			{
				antenna = E,
				combinator = cc
			}
	elseif E.name == 'antenna' and E.surface.name == 'test' then
		local cc = game.surfaces[E.surface.name].create_entity{name = 'antenna-constant-combinator', position = {E.position.x + 0.5, E.position.y}, force = E.force}
		global.antenna.space_antenna[E.unit_number] =
			{
				antenna = E,
				combinator = cc
			}
	elseif E.name == 'rocket-silo' then
		local rscc = game.surfaces[E.surface.name].create_entity{name = 'rocket-silo-constant-combinator', position = {E.position.x + 3, E.position.y + 3}, force = E.force}
		global.rocket_silo_con_combinator[rscc.unit_number] =
			{
				con_com = rscc,
				silo = E
			}
	]]
        --
    end
end)

script.on_event('recipe-selector', function(event)
    -- log("working")
    -- log(global.oil_to_gas)
    local player = game.players[event.player_index]
    local selected = player.selected
    if selected == nil or string.match(selected.name, 'oil%-derrick') == nil then
        if global.oil_to_gas == false then
            -- log('hit')
            global.oil_to_gas = true
        else
            -- log('hit')
            global.oil_to_gas = false
        end
    elseif selected and string.match(selected.name, 'oil%-derrick') ~= nil then
        local gas = true
        oil_gas_select(selected, gas)
    end
end)

script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, function(event)
    local E = event.entity
    -- log('hit')
    if string.match(event.entity.name, 'oil%-derrick') then
        -- log('hit')
        local oil = game.surfaces['nauvis'].find_entities({
            {event.entity.position.x - 1, event.entity.position.y - 1},
            {event.entity.position.x + 1, event.entity.position.y + 1}
        })
        -- log('hit')
        -- log(serpent.block(oil))
        for _, ent in pairs(oil) do
            -- log('hit')
            if ent.name == 'natural-gas-1' then
                -- log('hit')
                game.surfaces['nauvis'].create_entity {name = 'oil-mk01', amount = ent.amount, position = ent.position}
                ent.destroy()
            elseif ent.name == 'natural-gas-2' then
                -- log('hit')
                game.surfaces['nauvis'].create_entity {name = 'oil-mk02', amount = ent.amount, position = ent.position}
                ent.destroy()
            elseif ent.name == 'natural-gas-3' then
                -- log('hit')
                game.surfaces['nauvis'].create_entity {name = 'oil-mk03', amount = ent.amount, position = ent.position}
                ent.destroy()
            elseif ent.name == 'natural-gas-4' then
                -- log('hit')
                game.surfaces['nauvis'].create_entity {name = 'oil-mk04', amount = ent.amount, position = ent.position}
                ent.destroy()
            end
        end
    elseif string.match(E.name, 'seep') ~= nil then
        local entity = game.surfaces[E.surface.name].find_entities_filtered {
            position = E.position,
            type = 'assembling-machine'
        }
        for e, ent in pairs(entity) do ent.destroy() end
        global.oil_derricks[E.unit_number] = nil
    end
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
    local E = event.entity
    if string.match(E.name, 'seep') ~= nil then
        local entity = game.surfaces[E.surface.name].find_entities_filtered {
            position = E.position,
            type = 'assembling-machine'
        }
        for e, ent in pairs(entity) do ent.direction = E.direction end
    end
end)

script.on_nth_tick(30, function()
    -- log(serpent.block(global.oil_derricks))
    for d, drill in pairs(global.oil_derricks) do
        -- log(serpent.block(d))
        -- log(serpent.block(drill))
        local dfluid = drill.base.get_fluid_contents()
        log(serpent.block(dfluid))
        if next(dfluid) ~= nil then
            log('hit')
            if dfluid['drilling-fluid-' .. 3] ~= nil then
                if dfluid['drilling-fluid-' .. 3] >= 50 then
                    global.oil_derricks[d].drilling_fluid = 'drilling-fluid-3'
                    drill.base.remove_fluid {name = 'drilling-fluid-3', amount = 5}
                    drill.entity.active = true
                elseif dfluid['drilling-fluid-' .. 3] < 50 then
                    drill.entity.active = false
                end
            elseif dfluid['drilling-fluid-' .. 2] ~= nil then
                if dfluid['drilling-fluid-' .. 2] >= 50 then
                    global.oil_derricks[d].drilling_fluid = 'drilling-fluid-2'
                    drill.base.remove_fluid {name = 'drilling-fluid-2', amount = 5}
                    drill.entity.active = true
                elseif dfluid['drilling-fluid-' .. 2] < 50 then
                    drill.entity.active = false
                end
            elseif dfluid['drilling-fluid-' .. 1] ~= nil then
                if dfluid['drilling-fluid-' .. 1] >= 50 then
                    global.oil_derricks[d].drilling_fluid = 'drilling-fluid-1'
                    drill.base.remove_fluid {name = 'drilling-fluid-1', amount = 5}
                    drill.entity.active = true
                elseif dfluid['drilling-fluid-' .. 1] < 50 then
                    drill.entity.active = false
                end
            elseif dfluid['drilling-fluid-' .. 0] ~= nil then
                if dfluid['drilling-fluid-' .. 0] >= 50 then
                    global.oil_derricks[d].drilling_fluid = 'drilling-fluid-0'
                    drill.base.remove_fluid {name = 'drilling-fluid-0', amount = 5}
                    drill.entity.active = true
                elseif dfluid['drilling-fluid-' .. 0] < 50 then
                    drill.entity.active = false
                end
            end

        else
            drill.entity.active = false
        end
    end
end)
--

--[[
script.on_event(defines.events.on_rocket_launch_ordered, function()

	local map_settings =
	{
		autoplace_settings =
			{
				["decorative"]={
				treat_missing_as_default=false,
				settings = {}
				},
				["entity"]={
				treat_missing_as_default=false,
				settings = {}
				},
				["tile"]={
				treat_missing_as_default=false,
				settings = {
					['space-plate'] = {}
				}
				},
			},
		default_enable_all_autoplace_controls = false,
		cliff_settings = {}
	}

	if game.surfaces['test'] == nil then
		game.create_surface('test', map_settings)
		game.surfaces['test'].request_to_generate_chunks({0,0},1)
	end
end)

script.on_event(defines.events.on_rocket_launched, function(event)
	if event.rocket_silo.name ~= "mega-farm" then
		if global.first_chunk == false then
			local tiles = {}
			local x = -3
			local y = -3
			for i = 1,36 do
				local tile = {name = 'space-plate', position = {x, y}}
				table.insert(tiles, tile)
				x = x + 1
				if x == 3 then
					x = -3
					y = y + 1
				end
			end
			--log(serpent.block(tiles))
			game.surfaces['test'].set_tiles(tiles)

			--game.players[1].teleport({0,0}, 'test')
			global.first_chunk = true
		end

		if event.player_index ~= nil then
			if game.players[event.player_index].surface.name == 'nauvis' then
				game.players[event.player_index].teleport({0,0}, 'test')
			elseif game.players[event.player_index].surface.name == 'test' then
				game.players[event.player_index].teleport({0,0}, 'nauvis')
			end
		end

		--log(serpent.block(game.entity_prototypes['space-pod']))

		local rocket_inv = event.rocket.get_inventory(defines.inventory.rocket).get_contents()

		local items = {}

		if next(rocket_inv) ~= nil then
			log(serpent.block(rocket_inv))
			local rocket = rocket_inv

			--table.insert(global.rockets, rocket)
			--log(serpent.block(global.rocket))
			if event.rocket.surface.name == 'nauvis' then
				local pad = game.surfaces['test'].create_entity{
					name = 'landing-pad',
					position = {0,-4},
					force = event.rocket.force
				}
				local pod_check = game.surfaces['test'].find_entities_filtered{position = {0,-4}, radius = 4, name = 'space-pod'}
				if next(pod_check) == nil then
					local pod = game.surfaces['test'].create_entity{
						name = 'space-pod',
						position = {0,-4},
						force = event.rocket.force
					}
				end
				for i, item in pairs(rocket_inv) do
					pad.get_inventory(defines.inventory.chest).insert({name = i, count = item})
				end
			end
		end
	end

end)

script.on_event(defines.events.on_chunk_generated, function(event)
	--log('should only see this once per chunk gen call')
	--log('hit all other chunks')
	if game.surfaces['test'] ~= nil then
		local entities = game.surfaces['test'].find_entities(event.area)
		local old_tiles = game.surfaces['test'].find_tiles_filtered{area = event.area}
		local tiles = {}
		for _, ent in pairs(entities) do
			--log('hit')
			--log(ent.name)
			--log(ent.type)
			if ent.type == 'cliff' then
				ent.destroy()
			end
		end
		for _, til in pairs(old_tiles) do
			--log(til.position)
			local tile = {name = 'space', position = til.position}
			table.insert(tiles, tile)
		end
		game.surfaces['test'].set_tiles(tiles)
	end
end)

script.on_event(defines.events.on_tick, function()
	local nau_ant = global.antenna.nauvis_antenna
	local spa_ant = global.antenna.space_antenna
	local nau_signals = {}
	local spa_signals = {}
	for _, ant in pairs(nau_ant) do
		if ant.antenna.get_merged_signals() ~= nil then
			local signal = ant.antenna.get_merged_signals()
			for _, sing in pairs(signal) do
				table.insert(nau_signals, sing)
			end
		end
	end
	for _, ant in pairs(spa_ant) do
		if ant.antenna.get_merged_signals() ~= nil then
			local signal = ant.antenna.get_merged_signals()
			for _, sing in pairs(signal) do
				table.insert(spa_signals, sing)
			end
		end
	end
	--log(serpent.block(nau_signals))
	for _, ant in pairs(nau_ant) do
		local circuit = ant.combinator.get_circuit_network(defines.wire_type.red)
		if circuit ~= nil then
			local index = 1
			for _, sig in pairs(spa_signals) do
				ant.combinator.get_control_behavior().set_signal
					(
						index,
						sig
					)
				index = index + 1
			end
		end
	end
	for _, ant in pairs(spa_ant) do
		local circuit = ant.combinator.get_circuit_network(defines.wire_type.red)
		if circuit ~= nil then
			local index = 1
			for _, sig in pairs(nau_signals) do
				log(serpent.block(sig))
				ant.combinator.get_control_behavior().set_signal
					(
						index,
						sig
					)
				index = index + 1
			end
		end
	end
	for _, rscc in pairs(global.rocket_silo_con_combinator) do
		local circuit = rscc.con_com.get_circuit_network(defines.wire_type.red)
		if circuit ~= nil and rscc.silo.get_inventory(defines.inventory.rocket_silo_rocket) ~= nil then
			local index = 1
			local rocket_inv = rscc.silo.get_inventory(defines.inventory.rocket_silo_rocket).get_contents()
			for i,item in pairs(rocket_inv) do
				log(serpent.block(i))
				log(serpent.block(item))
				log(index)
				rscc.con_com.get_control_behavior().set_signal
					(
						index,
						{
							signal =
							{
								type = 'item',
								name = i
							},
							count = item
						}
					)
				index = index + 1
			end
		end
	end
end)
]]
script.on_event(defines.events.on_chunk_generated, function(event)
    local bitumen = game.surfaces[event.surface.name].find_entities_filtered {name = 'bitumen-seep', area = event.area}
    -- local amount = math.random(250,1000)
    -- test amount
    local amount = math.random(1000, 2500)
    for b, bit in pairs(bitumen) do bit.amount = amount end
end)

script.on_event(defines.events.on_resource_depleted, function(event)
    local E = event.entity
    if E.name == 'bitumen-seep' then
        local drill = {}
        local current_derrick = game.surfaces[E.surface.name].find_entities_filtered {
            area = {{E.position.x - 1, E.position.y - 1}, {E.position.x + 1, E.position.y + 1}},
            type = 'mining-drill'
        }
        for d, dri in pairs(current_derrick) do drill = dri end

        local drill_name = ''
        local resource_name = ''
        if string.match(drill.name, 'bitumen') ~= nil then
            drill_name = 'oil-derrick'
            resource_name = 'oil-mk' .. string.match(drill.name, '%d+')
        elseif string.match(drill.name, 'tar') ~= nil then
            drill_name = 'tar-extractor'
            resource_name = 'tar-patch'
        end

        local drill_fluid = global.oil_derricks[drill.unit_number].drilling_fluid
        -- log(serpent.block(drill_fluid))
        local ran = math.random(1, 4)
        local drill_num = string.match(drill.name, '%d+')
        local fluid_num = string.match(drill_fluid, '%d+') + 1
        local new_oil_amount = 10000 * ran * drill_num * fluid_num
        log(ran)
        log(drill_num)
        log(fluid_num)
        log(new_oil_amount)
        -- new_oil_amount = new_oil_amount * string.match(string.match(drill.name, "%d+"), "[^0]")
        game.surfaces[E.surface.name].create_entity {
            name = resource_name,
            amount = new_oil_amount,
            position = E.position
        }
        game.surfaces[E.surface.name].create_entity {
            name = drill_name .. '-mk' .. string.match(drill.name, '%d+'),
            position = drill.position,
            force = drill.force
        }
        global.oil_derricks[drill.unit_number].base.destroy()
        global.oil_derricks[drill.unit_number] = nil
        drill.destroy()
    end
end)
