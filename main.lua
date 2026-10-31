local hdmod_version <const> = "2.0.1"

---@diagnostic disable: lowercase-global
bankmanagerlib = require("fmod_bank_manager")
hdmod = import("tilecode/hdmod", hdmod_version)
musicdata = require("musicdata")

meta.name = "Sample HDMod Music Pack"
meta.version = "1.0.0"
meta.description = "An example music pack for HDMod"
meta.author = "Taffer"

local mod_script_id <const> = get_id()

local music_pack_meta = {
	pack_name = "SampleMusicPack",
	music_pack_format_version = 1.0,
	load_sample_data_func = function(notify_cb)
		if bankmanagerlib.bank_exists(musicdata.banks.musicbank.bank_path) then
			bankmanagerlib.load_bank_sample_data(
				musicdata.banks.musicbank.bank_path,
				musicdata.banks.musicbank.sampledata_load_func,
				function(statetype, loadstate)
					notify_cb(mod_script_id, statetype, loadstate)
				end
			)
		else
			notify_cb(mod_script_id, bankmanagerlib.LOADING_STATE_TYPE.METADATA, FMOD_LOADING_STATE.ERROR)
		end
	end,
	unload_sample_data_func = function()
		if bankmanagerlib.bank_exists(musicdata.banks.musicbank.bank_path) then
			bankmanagerlib.unload_bank_sample_data(musicdata.banks.musicbank.bank_path)
		end
	end,
}

local function init_music_pack()
	if hdmod then
		if not bankmanagerlib.bank_exists(musicdata.banks.musicbank.bank_path) then
			bankmanagerlib.load_bank_metadata(musicdata.banks.musicbank.bank_path, musicdata.banks.musicbank.load_bank_flags, function()
				hdmod.register_hdmod_music_pack(mod_script_id, music_pack_meta, musicdata)
			end, musicdata.banks.musicbank.unload_func)
		end
	end
end

set_callback(function()
	init_music_pack()
end, ON.SCRIPT_ENABLE)

set_callback(function()
	if hdmod then
		hdmod.unregister_hdmod_music_pack(mod_script_id)
	end
end, ON.SCRIPT_DISABLE)

init_music_pack()
