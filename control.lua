script.on_init(
	function()
		global.latch_queued = false
		global.latched = false
		global.latched_state = nil
		global.player_index = nil
	end
)

local function on_tick()
	if not (global.player_index == nil) then
		if global.latched then
			local player = game.players[global.player_index]
			player.walking_state = global.latched_state
		end
		if global.latch_queued then
			local player = game.players[global.player_index]
			global.latched_state = player.walking_state
			global.latch_queued = false
			global.latched = true
		end
	end
end

local function on_trigger_autorun(event)
	global.player_index = event.player_index
	local player = game.players[global.player_index]
	if player.walking_state.walking then
		global.latch_queued = true
	end
end

local function latch_off()
	if global.latched then
		global.latched = false
		global.latched_state = nil
	end
end

script.on_event("move-up", latch_off)
script.on_event("move-right", latch_off)
script.on_event("move-down", latch_off)
script.on_event("move-left", latch_off)
script.on_event("mine", latch_off)
script.on_event("shoot-selected", latch_off)
script.on_event("shoot-enemy", latch_off)
script.on_event("stop_autorun", latch_off)
script.on_event("autorun", on_trigger_autorun)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_player_driving_changed_state, latch_off)
