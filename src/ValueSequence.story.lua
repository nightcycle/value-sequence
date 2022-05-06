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

		-- local smooth = 1
		local keypoints = {
			ValueSequence.keypoint(0, 0, 0.1, 0),
			ValueSequence.keypoint(0.35, 0.8, 0.5),
			ValueSequence.keypoint(0.5, 0.3, 0.35),
			ValueSequence.keypoint(0.75, 0.15, 0.5),
			ValueSequence.keypoint(1, 0.2, 0.1, 0),
		}

		local vSec = ValueSequence.new(keypoints)


		local Data = {}
		Data.Linear = {}
		-- Data.Max = {}
		-- Data.Min = {}
		-- Data.Bezier = {}
		-- Data.Control = {}
		-- Data.BMax = {}
		-- Data.BMin = {}
		local steps = 50

		-- for i, keypoint in ipairs(keypoints) do
		-- 	local b1, b2 = vSec:GetBezierPoints(i)
		-- 	if b1 == b1 and b2 == b2 then
		-- 		Data.Control[math.round(steps*b1.X)] = b1.Y
		-- 		Data.Control[math.round(steps*b2.X)] = b2.Y

		-- 	end
		-- end

		for i=1, steps do
			local alpha = (i-1)/(steps-1)
			local val, envelope = vSec:GetValue(alpha, 1)
			-- local bVal = vSec:GetValue(alpha, 1)
			-- print(i, ": ", envelope)
			-- table.insert(Data.Bezier, bVal)
			-- table.insert(Data.BMax, bVal + 0.5 * envelope)
			-- table.insert(Data.BMin, bVal - 0.5 * envelope)
			-- table.insert(Data.Max, val + 0.5 * envelope)
			-- table.insert(Data.Min, val - 0.5 * envelope)
			table.insert(Data.Linear, val)
		end
		local graph = Graph.new(frame)
		-- print("Graph time")
		graph.Resolution = 100
		graph.Data = Data
		-- print(Data)
		maid:GiveTask(graph)
	end)
	if not success then
		warn(msg)
	end
	return function ()
		maid:Destroy()
	end
end