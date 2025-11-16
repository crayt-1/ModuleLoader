if script:FindFirstChildWhichIsA("ModuleScript") then
	task.desynchronize()
	require(script:FindFirstChildWhichIsA("ModuleScript"))
else
	script.Enabled = false
end
