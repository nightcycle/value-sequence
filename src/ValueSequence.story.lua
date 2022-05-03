return function(coreGui)
	local package = script.Parent
	local packages = package.Parent
	local Maid = require(packages:WaitForChild("maid"))

	local maid = Maid.new()

	local success, msg = pcall(function()
		local ValueSequence = require(package)
		local Graph = require(packages:WaitForChild("graph"))

		local frame = Instance.new("Frame", coreGui)
		frame.AnchorPoint = Vector2.new(0.5,0.5)
		frame.Position = UDim2.fromScale(0.5,0.5)
		frame.Size = UDim2.fromScale(0.8,0.8)
		
		maid:GiveTask(frame)

		local vSec = ValueSequence.new({
			ValueSequence.keypoint(0, 0, 0.1),
			ValueSequence.keypoint(0.25, 0.7, 0.5),
			ValueSequence.keypoint(0.5, 0.3, 0.5),
			ValueSequence.keypoint(0.75, 0.15, 0.5),
			ValueSequence.keypoint(1, 1, 0.1),
		})

		local Data = {}
		Data.Linear = {}
		Data.Max = {}
		Data.Min = {}
		local steps = 100
		for i=1, steps do
			local alpha = (i-1)/(steps-1)
			local val, envelope = vSec:GetValue(alpha, nil, nil, 1)
			print("Val", val, "Env", envelope)
			table.insert(Data.Max, val + 0.5 * envelope)
			table.insert(Data.Min, val - 0.5 * envelope)
			table.insert(Data.Linear, val)
		end
		local graph = Graph.new(frame)
		graph.Resolution = 100
		graph.Data = Data

		maid:GiveTask(graph)
	end)
	if not success then
		warn(msg)
	end
	return function ()
		maid:Destroy()
	end
end