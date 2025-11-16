local module = script:FindFirstChildWhichIsA("ModuleScript")

if module then
	local loadedModule = require(module)
	local isTable = typeof(loadedModule) == "table"
	local hasInit = isTable and loadedModule.init and typeof(loadedModule.init) == "function"

	if hasInit then
		task.desynchronize()
		loadedModule:init()
	end
else
	script.Enabled = false
end
