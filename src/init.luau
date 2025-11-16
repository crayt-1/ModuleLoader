local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local PARALLEL_TAG = workspace:GetAttribute("ParallelTag") or "Parallel"
local ENVIRONMENT = RunService:IsServer() and "Server" or "Client"

local ModuleLoader = {}
ModuleLoader._loadingModules = 0
ModuleLoader._onStart = nil :: (() -> any)?
ModuleLoader._actorsFolder = nil :: Folder?

function ModuleLoader._init(self: ModuleLoader, module: ModuleScript): ()
	if module:HasTag(PARALLEL_TAG) then
		local actor = Instance.new("Actor")
		actor.Name = `{module.Name}Actor`
		actor.Parent = self._actorsFolder
		local loader = script.Loader:Clone()
		loader.Enabled = false
		loader.Name = `{module.Name}Loader`
		loader.Parent = actor
		module.Parent = loader
		loader.Enabled = true
		return
	end

	local loadedModule = require(module)
	local isTable = typeof(loadedModule) == "table"
	local hasInit = isTable and loadedModule.init and typeof(loadedModule.init) == "function"

	if hasInit then
		ModuleLoader._loadingModules += 1
		--local startTime = os.clock()
		loadedModule:init()
		--local endTime = os.clock()
		ModuleLoader._loadingModules -= 1
		--print(module, `initialized! took: {endTime - startTime}s`)
	end
end

function ModuleLoader._deepInit(self: ModuleLoader, modules: Instance): ()
	for _, child in modules:GetChildren() do
		if not child:IsA("ModuleScript") then
			if child:IsA("Folder") then
				self:_deepInit(child)
				continue
			else
				continue
			end
		end
		task.spawn(ModuleLoader._init, self, child)
	end
end

function ModuleLoader.onStart(self: ModuleLoader, callback: () -> any?): ()
	self._onStart = callback
end

function ModuleLoader.init(self: ModuleLoader, modules: Instance): ()
	self._actorsFolder = Instance.new("Folder")
	self._actorsFolder.Name = "Actors"
	self._actorsFolder.Parent = ENVIRONMENT == "Server" and ServerScriptService or ReplicatedStorage

	if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Network") then
		require(ReplicatedStorage.Packages.Network)
	end

	self:_deepInit(modules)

	if not self._onStart then
		return
	end

	while self._loadingModules ~= 0 do
		task.wait()
	end

	self:_onStart()
end

export type ModuleLoader = typeof(ModuleLoader)

return ModuleLoader :: ModuleLoader
