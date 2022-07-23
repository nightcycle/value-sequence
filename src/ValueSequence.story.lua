--!nocheck

type Graph = {
	Resolution: number,
	Data: {[number]: number},
}

return function(coreGui: CoreGui)

	local package = script.Parent
	local packages = package.Parent
	local Maid = require(packages:WaitForChild("maid"))

	local maid = Maid.new()

	local success, msg = pcall(function()
		local ValueSequence = require(package)

		local Graph = require(packages:WaitForChild("graph"))

		local frame: Frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5,0.5)
		frame.Position = UDim2.fromScale(0.5,0.5)
		frame.Size = UDim2.fromScale(0.8,0.8)
		frame.Parent = coreGui
		
		maid:GiveTask(frame)

		local keypoints = {
			ValueSequence.keypoint(0, 	0, 	0, 0.05),
			ValueSequence.keypoint(0.25,	0.2, 0.15, 0.25),
			ValueSequence.keypoint(0.5,	0.3, 0.25, 0.35),
			ValueSequence.keypoint(0.75,	0.4, 0.35, 0.45),
			ValueSequence.keypoint(1, 	0.8, 0.5, 0.9),
		}
		
		local SeqA = ValueSequence.new(keypoints)

		local steps = 60
		local Data = {
			A = SeqA:Solve(steps),
			MaxA = SeqA:Solve(steps, 1),
			MinA = SeqA:Solve(steps, 0),
		}
	
		local graph = Graph.new(frame)
		graph.Resolution = 100
		graph.Data = Data :: {[number]: number}

		maid:GiveTask(graph)
	end)
	if not success then
		warn(msg)
	end
	return function ()
		maid:Destroy()
	end
end