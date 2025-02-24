-- Required libraries for utility functions and options
local utils = require 'mp.utils'
local options = require 'mp.options'

-- Default options with save_interval set to 60 seconds
local o = { save_interval = 60 }
options.read_options(o)

-- Function to save the current progress to watch-later configuration
local function save()
	-- Set the message level for logging (warning for cplayer)
	mp.commandv("set", "msg-level", "cplayer=warn")

	-- Write the watch-later configuration (saves the current state)
	mp.command("write-watch-later-config")

	-- Reset message level for normal operation
	mp.commandv("set", "msg-level", "cplayer=status")
end

-- Function to save the progress if the video is paused
local function save_if_pause(_, pause)
	-- If the video is paused, trigger the save function
	if pause then save() end
end

-- Function to pause the timer when the video is paused
local function pause_timer_while_paused(_, pause)
	-- If paused, stop the timer
	if pause then
		timer:stop()
	end

	-- If unpaused and timer is not running, resume the timer
	if not pause and not timer:is_enabled() then
		timer:resume()
	end
end

-- Function to clean up the watch-later entry after the video ends
local function clean_watch_later(event)
	-- Get the current file path and current working directory
	local path = mp.get_property("path")
	local cwd = utils.getcwd()

	-- If no path or cwd, do nothing
	if path == nil or cwd == nil then
		do return end
	end

	-- Construct the absolute path
	local abs_path = utils.join_path(cwd, path)

	-- Create a temporary file to calculate the hash
	local tmpname = os.tmpname()
	local tmp = io.open(tmpname, "w")
	tmp:write(abs_path)
	tmp:flush()

	-- Calculate the hash (MD5) for the file path
	local hash = io.popen("md5sum "..tmpname):read():match("^%w+"):upper()
	
	-- Clean up the temporary file
	os.remove(tmpname)

	-- Find the watch_later configuration file
	local watch_later = mp.find_config_file("watch_later")

	-- If the hash or watch_later config file is missing, return early
	if hash == nil or watch_later == nil then
		do return end
	end

	-- Construct the path for the hash-based file
	local hashfile = utils.join_path(watch_later, hash)

	-- Function to remove the hashfile when video ends
	function rm_hashfile(hashfile)
		return function(event)
			mp.unregister_event(rm_hashfile(hashfile))

			-- If the event reason is "eof" or "stop", remove the hashfile
			if event["reason"] == "eof" or event["reason"] == "stop" then
				os.remove(hashfile)
			end
		end
	end

	-- Register the event to remove the hashfile after the video ends
	mp.register_event("end-file", rm_hashfile(hashfile))
end

-- Set up a periodic timer to save progress every 'save_interval' seconds
timer = mp.add_periodic_timer(o.save_interval, save)

-- Observe the pause property, and pause the timer accordingly
mp.observe_property("pause", "bool", pause_timer_while_paused)

-- Save the progress when the video is paused
mp.observe_property("pause", "bool", save_if_pause)

-- When a new file is loaded, trigger the save function and clean the watch-later entry
mp.register_event("file-loaded", function() save(); clean_watch_later() end)