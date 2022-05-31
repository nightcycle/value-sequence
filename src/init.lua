--!nocheck

local packages = script.Parent
local ValueSequenceKeypoint = require(script:WaitForChild("Keypoint"))
local math = require(packages:WaitForChild("math"))

export type ValueSequence = {
	new: (keypoints: {[number]: ValueSequenceKeypoint}, v: lerpValue) -> ValueSequence,
	keypoint: (alpha: number, value: any, min: any | nil, max: any | nil) -> ValueSequenceKeypoint,
	Lerp: (self:ValueSequence, keypoint: (ValueSequenceKeypoint), alpha: number) -> ValueSequence,
	GetValue: (self:ValueSequence, alpha: number, weight: number | nil) -> lerpValue,
	Solve: (self:ValueSequence, steps: number, weight: number | nil) -> {[number]: lerpValue},
	Keypoints: {[number]: ValueSequenceKeypoint},
	Seed: number
}
local ValueSequence = {}

function ValueSequence.keypoint(alpha: number, value: any, min: any | nil, max: any | nil): ValueSequenceKeypoint
	return ValueSequenceKeypoint.new(alpha, value, min, max)
end

function ValueSequence:__index(k: any): any | nil
	if rawget(self, k) then
		return rawget(self, k)
	elseif rawget(ValueSequence, k) then
		return rawget(ValueSequence, k)
	else
		return nil
	end
end

function ValueSequence:__newindex(k: any): nil
	error("You can't write to a ValueSequence after construction")
end

function ValueSequence:Lerp(other: ValueSequence, alpha: number): ValueSequence
	local ts = {}
	for _, kp in ipairs(self.Keypoints) do
		ts[kp.Alpha] = {}
		ts[kp.Alpha].Value = {kp.Value, other:GetValue(kp.Alpha)}
		ts[kp.Alpha].Min = {kp.Min, other:GetValue(kp.Alpha, 0)}
		ts[kp.Alpha].Max = {kp.Max, other:GetValue(kp.Alpha, 1)}
	end
	
	for _, kp in ipairs(other.Keypoints) do
		ts[kp.Alpha] = ts[kp.Alpha] or {}
		if ts[kp.Alpha].Value then
			ts[kp.Alpha].Value = {ts[kp.Alpha].Value[1], kp.Value}
		else
			ts[kp.Alpha].Value = {self:GetValue(kp.Alpha), kp.Value}
		end
		if ts[kp.Alpha].Min then
			ts[kp.Alpha].Min = {ts[kp.Alpha].Min[1], kp.Min}
		else
			ts[kp.Alpha].Min = {self:GetValue(kp.Alpha, 0), kp.Min}
		end
		if ts[kp.Alpha].Max then
			ts[kp.Alpha].Max = {ts[kp.Alpha].Max[1], kp.Max}
		else
			ts[kp.Alpha].Max = {self:GetValue(kp.Alpha, 1), kp.Max}
		end
	end
	local keypoints = {}
	for t, v in pairs(ts) do
		-- print("T", t, "V", v)
		local val = math.Algebra.lerp(v.Value[1], v.Value[2], alpha)
		local min = math.Algebra.lerp(v.Min[1], v.Min[2], alpha)
		local max = math.Algebra.lerp(v.Max[1], v.Max[2], alpha)
		local kp = ValueSequenceKeypoint.new(t, val, min, max)
		-- print("KP", kp)
		table.insert(keypoints, kp)
	end
	table.sort(keypoints, function(a,b)
		return a.Alpha < b.Alpha
	end)
	-- print("Constructing", keypoints)
	return ValueSequence.new(keypoints, math.Algebra.lerp(self.Seed, other.Seed, alpha))
end

-- Returns the value at a specific alpha, as well as at the specified min-max weight
function ValueSequence:GetValue(alpha: number, minMaxWeight: number | nil): lerpValue
	-- If we are at 0 or 1, return the first or last value respectively
	if alpha == 0 then
		local first = self.Keypoints[#self.Keypoints]
		return first.Value
	end
	if alpha == 1 then
		local last = self.Keypoints[#self.Keypoints]
		return last.Value
	end
	-- Step through each sequential pair of keypoints and see if alpha lies between the points' time values.
	for i = 1, #self.Keypoints - 1 do
		local ths = self.Keypoints[i]
		local nxt = self.Keypoints[i + 1]
		if alpha >= ths.Alpha and alpha < nxt.Alpha then
			-- Calculate how far alpha lies between the points
			local nxtAlpha = (alpha - ths.Alpha) / (nxt.Alpha - ths.Alpha)
			if minMaxWeight then
				local min = math.Algebra.lerp(ths.Min, nxt.Min, nxtAlpha)
				local max = math.Algebra.lerp(ths.Max, nxt.Max, nxtAlpha)

				return math.Algebra.lerp(min, max, minMaxWeight)
			else
				return math.Algebra.lerp(ths.Value, nxt.Value, nxtAlpha)
			end
			-- return (next.Value - this.Value) * nxtAlpha + this.Value
		end
	end
	return
end

-- Returns a list of steps at regular intervals showing the value across alpha
function ValueSequence:Solve(steps: number, minMaxWeight: number | nil): {[number]: lerpValue}
	minMaxWeight = minMaxWeight or self.Random:NextNumber()
	local values = {}
	for i=1, steps do
		local alpha = i/steps
		local value = self:GetValue(alpha, minMaxWeight)
		table.insert(values, value)
	end
	return values
end


function ValueSequence.new(keyPointList: {[number]: ValueSequenceKeypoint}, seed: number | nil): ValueSequence
	seed = seed or tick()
	local self = setmetatable({
		Keypoints = keyPointList,
		Seed = seed,
		Random = Random.new(seed),
	}, ValueSequence)
	return self
end

return ValueSequence