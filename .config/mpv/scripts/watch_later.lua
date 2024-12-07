local utils = require 'mp.utils'
local options = require 'mp.options'
local o = { save_interval = 60 }
options.read_options(o)

local function save()
	mp.commandv("set", "msg-level", "cplayer=warn")
	mp.command("write-watch-later-config")
	mp.commandv("set", "msg-level", "cplayer=status")
end

local function save_if_pause(_, pause)
	if pause then save() end
end

local function pause_timer_while_paused(_, pause)
	if pause then
		timer:stop()
	end

	if not pause and not timer:is_enabled() then
		timer:resume()
	end
end

local function clean_watch_later(event)
	local path = mp.get_property("path")
	local cwd = utils.getcwd()
	if path == nil or cwd == nil then
		do return end
	end

	local abs_path = utils.join_path(cwd, path)
	local tmpname = os.tmpname()
	local tmp = io.open(tmpname, "w")
	tmp:write(abs_path)
	tmp:flush()
	local hash = io.popen("md5sum "..tmpname):read():match("^%w+"):upper()
	os.remove(tmpname)

	local watch_later = mp.find_config_file("watch_later")
	if hash == nil or watch_later == nil then
		do return end
	end

	local hashfile = utils.join_path(watch_later, hash)

	function rm_hashfile(hashfile)
		return function(event)
			mp.unregister_event(rm_hashfile(hashfile))
			if event["reason"] == "eof" or event["reason"] == "stop" then
				os.remove(hashfile)
			end
		end
	end
	mp.register_event("end-file", rm_hashfile(hashfile))
end

timer = mp.add_periodic_timer(o.save_interval, save)
mp.observe_property("pause", "bool", pause_timer_while_paused)
mp.observe_property("pause", "bool", save_if_pause)

mp.register_event("file-loaded", function() save(); clean_watch_later() end)