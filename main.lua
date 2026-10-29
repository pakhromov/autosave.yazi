local PATH = os.getenv("HOME") .. "/.local/state/yazi/session.json"

local save = ya.sync(function(state, gen)
	if not cx or (gen and gen ~= state.gen) then
		return
	end
	local tabs = {}
	for i, tab in ipairs(cx.tabs) do
		local h = tab.current.hovered
		tabs[i] = { cwd = tostring(tab.current.cwd), hovered = h and tostring(h.url) }
	end
	local data = ya.json_encode({ active_idx = cx.tabs.idx, tabs = tabs })
	local f = data ~= state.last and io.open(PATH, "w")
	if f then
		f:write(data):close()
		state.last = data
	end
end)

local function open_paths(known, paths, active)
	for _, e in ipairs(paths) do
		local raw = tostring(e)
		local p = tostring(fs.clean_url(Url(raw:sub(1, 1) == "/" and raw or os.getenv("PWD") .. "/" .. raw)))
		local f = io.open(p)
		local file = f and select(3, f:read(0)) ~= 21 and p -- error 21 = is a directory
		if f then
			f:close()
		end
		local dir = file and tostring(Url(p).parent) or p

		local idx
		for i, cwd in ipairs(known) do
			if cwd == dir then
				idx = i
				break
			end
		end
		ya.emit("tab_switch", { (idx or #known) - 1 })
		if not idx then
			ya.emit("tab_create", { dir })
			known[#known + 1] = dir
		end
		if file then
			ya.emit("reveal", { file })
		end
		active = idx or #known
	end
	return active
end

local restore = ya.sync(function(_, entries)
	local f = io.open(PATH)
	if not f then
		return
	end
	local session = ya.json_decode(f:read("*a"))
	f:close()
	if type(session) ~= "table" or type(session.tabs) ~= "table" or #session.tabs == 0 then
		return
	end

	for _ = 2, cx and #cx.tabs or 0 do
		ya.emit("tab_close", { 0 })
	end
	local known = {}
	for i, tab in ipairs(session.tabs) do
		ya.emit("tab_create", { tab.cwd, raw = true })
		if tab.hovered then
			ya.emit("reveal", { tab.hovered, raw = true })
		end
		known[i] = tab.cwd
	end
	ya.emit("tab_close", { 0 })
	ya.emit("tab_switch", { open_paths(known, entries or {}, session.active_idx or 1) - 1 })
end)

return {
	setup = function(state)
		local now = function()
			save()
		end
		ps.sub("cd", now)
		ps.sub("tab", now)
		ps.sub("hover", function()
			state.gen = (state.gen or 0) + 1
			local gen = state.gen
			ya.async(function()
				ya.sleep(0.5)
				save(gen)
			end)
		end)
		restore(rt.args.entries)
	end,

	entry = function(_, job)
		(job.args[1] == "load" and restore or save)()
	end,
}
