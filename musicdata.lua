local module = {}

module.level_musics = {}

module.title_music = nil
module.credits_music = nil
module.basecamp_music = nil

module.MUSIC_FEELING_STORAGE = {}
module.MUSIC_PARAMETER_STORAGE = {}

module.debug_cb_id = nil

module.banks = {
	musicbank = {
		bank_path = "banks/Desktop/REPLACEME.bank",
		load_bank_flags = FMOD_LOAD_BANK_FLAGS.NONBLOCKING,
		sampledata_load_func = function()
			-- This event is optional, if you don't want to replace the music you can use the GUID of HDMod basemusic's event
			-- Or remove this table completely
			module.title_music = {
				base_volume = 1.0,
				event_name = "title_custom_music",
				-- Replace the GUID string with one from your FMOD Project
				event_description = get_event_by_id("{00000000-0000-0000-0000-000000000000}"),
			}

			-- This event is optional, if you don't want to replace the music you can use the GUID of HDMod basemusic's event
			-- Or remove this table completely
			module.credits_music = {
				base_volume = 1.0,
				event_name = "credits_custom_music",
				-- Replace the GUID string with one from your FMOD Project
				event_description = get_event_by_id("{00000000-0000-0000-0000-000000000000}"),
			}

			-- This event is optional, if you don't want to replace the music you can use the GUID of HDMod basemusic's event
			-- Or remove this table completely
			module.basecamp_music = {
				base_volume = 1.0,
				event_name = "basecamp_custom_music",
				-- Replace the GUID string with one from your FMOD Project
				event_description = get_event_by_id("{00000000-0000-0000-0000-000000000000}"),
			}

			-- This event is optional, if you don't want to replace the music you can use the GUID of HDMod basemusic's event
			-- Or remove this table completely
			table.insert(module.level_musics, {
				settings = {
					base_volume = 1.0,
					mute_shop_music = false,
					event_name = "tutorial_custom_music",
					event_description = get_event_by_id("{00000000-0000-0000-0000-000000000000}"),
				},
				should_play = function()
					local should_play = state.screen == SCREEN.LEVEL
						and hdmod.worldlib.get_hd_worldstate_state() == hdmod.worldlib.HD_WORLDSTATE_STATUS.TUTORIAL

					return should_play
				end,
			})

			table.insert(module.level_musics, {
				settings = {
					-- The events base volume. Doesn't work for most events since most events use sends instead of outputting from the master track.
					base_volume = 1.0,
					-- Whether shop music should be muted or not. Enable this if you plan to replace shop music.
					mute_shop_music = false,
					-- Optional event name, useful if you have HDMods music engine debug on or as an identifier to use with get_current_custom_level_music()
					event_name = "mines_custom_music",
					-- The GUID or event description for your FMOD music event
					-- You can find it in GUIDs.txt exported from FMOD Studio, or right clicking an event and clicking "Copy GUID"
					event_description = get_event_by_id("{00000000-0000-0000-0000-000000000000}"),
					-- Parameter update time is in miliseconds and specifies how frequently update_function should be called.
					-- 1000 ms or 1 second is slow, 63 is a very fast update rate.
					parameter_update_time = 1000,
					-- The init function gets called once when your music is started. Use it to set parameters like current_theme
					init_function = function(ctx)
						module.MUSIC_PARAMETER_STORAGE = {}
						module.MUSIC_PARAMETER_STORAGE["ghost"] = 0.0

						local ghost = ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.GHOST)

						ctx.event_instance:set_parameter_by_name("current_theme", 1.0)

						module.MUSIC_PARAMETER_STORAGE["ghost"] = ghost
						ctx.event_instance:set_parameter_by_name("ghost", ghost)
					end,
					-- This function runs after the init function and is called at the fixed rate set by parameter_update_time
					update_function = function(ctx)
						local ghost = ctx.bgm_master:get_parameter(VANILLA_SOUND_PARAM.GHOST)

						if module.MUSIC_PARAMETER_STORAGE["ghost"] ~= ghost then
							module.MUSIC_PARAMETER_STORAGE["ghost"] = ghost
							ctx.event_instance:set_parameter_by_name("ghost", ghost)
						end
					end,
				},
				-- This function determines when the music should play.
				-- See https://spelunky-fyi.github.io/overlunky/#THEME
				-- https://spelunky-fyi.github.io/overlunky/#SCREEN
				-- Check HDMod's feelingslib to test for level feelings like dead are restless
				-- hdmod.feelingslib.feeling_check(hdmod.feelingslib.FEELING_ID.RESTLESS)
				should_play = function()
					return state.screen == SCREEN.LEVEL and state.theme == THEME.DWELLING
				end,
			})
		end,
		unload_func = function()
			module.title_music = nil

			module.credits_music = nil

			module.basecamp_music = nil

			module.level_musics = {}

			collectgarbage("collect")

			if module.debug_cb_id then
				clear_callback(module.debug_cb_id)
			end
		end,
	},
}

-- Called in the tutorial when in the journal screen
function module.enable_tutorial_journal_music_layer()
	local current_custom_level_music = hdmod.custommusiclib.get_current_custom_level_music()
	if current_custom_level_music and current_custom_level_music.settings.event_name == "tutorial_custom_music" then
		module.MUSIC_PARAMETER_STORAGE["tutorial_journal"] = 1.0
		hdmod.custommusiclib.set_custom_music_level_parameter_by_name("tutorial_journal", 1.0)
	end
end

-- Called in the tutorial at the start of each tutoiral level
function module.disable_tutorial_journal_music_layer()
	local current_custom_level_music = hdmod.custommusiclib.get_current_custom_level_music()
	if current_custom_level_music and current_custom_level_music.settings.event_name == "tutorial_custom_music" then
		module.MUSIC_PARAMETER_STORAGE["tutorial_journal"] = 0.0
		hdmod.custommusiclib.set_custom_music_level_parameter_by_name("tutorial_journal", 0.0)
	end
end

-- Called when sacrificing a present or when throwing an eggplant at Yama
function module.eggplant_music()
	return
end

-- Called when the haunted castles sliding door closes
function module.haunted_castle_door_jumpscare()
	return
end

-- Called after the Olmec or Yama cutscene ends and the bossfight starts
function module.boss_music()
	local current_custom_level_music = hdmod.custommusiclib.get_current_custom_level_music()
	if current_custom_level_music and current_custom_level_music.settings.event_name == "olmec_custom_music" then
		hdmod.custommusiclib.set_custom_music_level_parameter_by_name("trigger", 1.0)
	elseif current_custom_level_music and current_custom_level_music.settings.event_name == "yama_custom_music" then
		hdmod.custommusiclib.set_custom_music_level_parameter_by_name("trigger", 1.0)
	end
end

-- Called after defeating Olmec or Yama
function module.post_boss_music()
	return
end

-- Called when resetting a run
function module.on_reset()
	return
end

--[[
	Debug function that displays all parameters cached in MUSIC_PARAMETER_STORAGE.
	The toggle for this debug function is in HDMods developer options.
	Developer options can be enabled by editing save.dat in the mods directory, and changing
	"dev_tools":false
	to:
	"dev_tools":true
]]
function module.toggle_debug()
	if module.debug_cb_id == nil then
		module.debug_cb_id = set_callback(function(ctx)
			local window_open = ctx:window("Music debug viewer", 0, 0, 0, 0, true, function(ctx, pos, size)
				ctx:win_separator()
				for p_name, p_value in pairs(module.MUSIC_PARAMETER_STORAGE) do
					ctx:win_text(p_name .. ": " .. tostring(p_value))
					ctx:win_separator()
				end
			end)
			if not window_open then
				clear_callback(module.debug_cb_id)
				module.debug_cb_id = nil
			end
		end, ON.GUIFRAME)
	else
		clear_callback(module.debug_cb_id)
		module.debug_cb_id = nil
	end
end

return module
