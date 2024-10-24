script.on_init(
	function()
		storage.latched_players = {}
		storage.queued_inputs = {}
	end
)

local input_directions = {
	["move-up"] =    defines.direction.north,
	["move-right"] = defines.direction.east,
	["move-down"] =  defines.direction.south,
	["move-left"] =  defines.direction.west
}

local function on_tick()
	local latched_players = storage.latched_players
	for player_index, input_queue in pairs(storage.queued_inputs) do
		local player = game.get_player(player_index)
		if player.controller_type ~= defines.controllers.character then
			break
		end
		local explicit = settings.get_player_settings(player_index)["tackleautorun-explicitcancel"].value

		-- Toggle key
		if input_queue["autorun"] then
			-- Disable
			if latched_players[player_index] or not player then
				latched_players[player_index] = nil
			else
				latched_players[player_index] = {
					walking = true,
					direction = player.character.walking_state.direction
				}
			end
		elseif not explicit then -- If we don't use "explicit" this case is always a cancel
			latched_players[player_index] = nil
		elseif latched_players[player_index] then -- User has explicit enabled, is already autorunning, and pressed a key
			local avg_direction = latched_players[player_index].direction
			local new_direction = nil
			for input_name in pairs(input_queue) do
				local direction_pressed = input_directions[input_name]
				if not direction_pressed then -- Cancel
					latched_players[player_index] = nil
					break
				else
					if avg_direction ~= direction_pressed then

						-- going right
						if direction_pressed == 4 and (avg_direction == 0) then
							new_direction = 2
						end

						if direction_pressed == 4 and (avg_direction == 2 or avg_direction == 4 or avg_direction == 6) then
							new_direction = 4
						end

						if direction_pressed == 4 and (avg_direction == 8) then
							new_direction = 6
						end

						-- going down
						if direction_pressed == 8 and (avg_direction == 4) then
							new_direction = 6
						end

						if direction_pressed == 8 and (avg_direction == 6 or avg_direction == 8 or avg_direction == 10) then
							new_direction = 8
						end

						if direction_pressed == 8 and (avg_direction == 12) then
							new_direction = 10
						end

						-- going left
						if direction_pressed == 12 and (avg_direction == 8) then
							new_direction = 10
						end

						if direction_pressed == 12 and (avg_direction == 10 or avg_direction == 12 or avg_direction == 14) then
							new_direction = 12
						end

						if direction_pressed == 12 and (avg_direction == 0) then
							new_direction = 14
						end

						-- going up
						if direction_pressed == 0 and (avg_direction == 12) then
							new_direction = 14
						end

						if direction_pressed == 0 and (avg_direction == 14 or avg_direction == 0 or avg_direction == 2) then
							new_direction = 0
						end

						if direction_pressed == 0 and (avg_direction == 4) then
							new_direction = 2
						end

						--

						if new_direction == nil then
							latched_players[player_index] = nil
							break
						end

					end
				end
			end
			if new_direction ~= nil then
				latched_players[player_index] = {
					walking = true,
					direction = new_direction
				}
			end
		end
	end
	for player_index, player_state in pairs(latched_players) do
		local player = game.get_player(player_index)
		local character = player.character
		if not player then
			latched_players[player_index] = nil
		else
			character.walking_state = player_state
		end
	end
	-- Clear queue for next tick
	storage.queued_inputs = {}
end

local function queue_input(event)
	local player = game.get_player(event.player_index)
	if not storage.queued_inputs[event.player_index] then
		storage.queued_inputs[event.player_index] = {}
	end
	storage.queued_inputs[event.player_index][event.input_name] = true
end


local function latch_off(event)
	local player = game.get_player(event.player_index)
	local walking_state = player.character.walking_state
	walking_state.walking = false
	player.character.walking_state = walking_state
	storage.latched_players[event.player_index] = nil
end

script.on_event("move-up", queue_input)
script.on_event("move-right", queue_input)
script.on_event("move-down", queue_input)
script.on_event("move-left", queue_input)
script.on_event("mine", queue_input)
script.on_event("shoot-selected", queue_input)
script.on_event("shoot-enemy", queue_input)
script.on_event("autorun", queue_input)
script.on_event(defines.events.on_tick, on_tick)
script.on_event("stop_autorun", latch_off)
script.on_event(defines.events.on_player_driving_changed_state, latch_off)
