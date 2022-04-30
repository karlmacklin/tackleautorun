script.on_init(
	function()
		global.latched_players = {}
		global.queued_inputs = {}
	end
)

local input_directions = {
	["move-up"] =    defines.direction.north,
	["move-right"] = defines.direction.east,
	["move-down"] =  defines.direction.south,
	["move-left"] =  defines.direction.west
}

local function on_tick()
	local latched_players = global.latched_players
	for player_index, input_queue in pairs(global.queued_inputs) do
		local explicit = settings.get_player_settings(player_index)["tackleautorun-explicitcancel"].value
		-- Toggle key
		if input_queue["autorun"] then
			local player = game.get_player(player_index)
			-- Disable
			if latched_players[player_index] or not player then
				latched_players[player_index] = nil
			else
				latched_players[player_index] = {
					walking = true,
					direction = player.walking_state.direction
				}
			end
		elseif not explicit then -- If we don't use "explicit" this case is always a cancel
			latched_players[player_index] = nil
		elseif latched_players[player_index] then -- User has explicit enabled, is already autorunning, and pressed a key
			local player = game.get_player(player_index)
			local avg_direction, input_count = latched_players[player_index].direction, 1
			for input_name in pairs(input_queue) do
				local direction_pressed = input_directions[input_name]
				if not direction_pressed then -- Cancel
					input_count = 0
					latched_players[player_index] = nil
					break
				else
					if avg_direction ~= direction_pressed then
						-- "up" should count as 8 when compared to anything >=4
						if direction_pressed > 3 and avg_direction == 0 then
							avg_direction = 8
						end
						if avg_direction > 3 and direction_pressed == 0 then
							direction_pressed = 8
						end
						-- If we press a direction more than 90 degrees from our heading, just abort
						if math.abs(avg_direction - direction_pressed) >= 3 then
							input_count = 0
							latched_players[player_index] = nil
							break
						elseif math.abs(avg_direction - direction_pressed) <= 1 then -- Quarter turns need no division
							avg_direction = direction_pressed
						else
							input_count = input_count + 1
							avg_direction = avg_direction + direction_pressed
						end
					end
				end
			end
			if input_count > 0 then
				latched_players[player_index] = {
					walking = true,
					direction = math.max((avg_direction / input_count) % 8)
				}
			end
		end
	end
	for player_index, player_state in pairs(latched_players) do
		local player = game.get_player(player_index)
		-- No player, deleted or otherwise gone
		if not player then
			latched_players[player_index] = nil
		else
			player.walking_state = player_state
		end
	end
	-- Clear queue for next tick
	global.queued_inputs = {}
end

local function queue_input(event)
	if not global.queued_inputs[event.player_index] then
		global.queued_inputs[event.player_index] = {}
	end
	global.queued_inputs[event.player_index][event.input_name] = true
end


local function latch_off(event)
	global.latched_players[event.player_index] = nil
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
