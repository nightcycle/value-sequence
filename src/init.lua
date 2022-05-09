local TweenService = game:GetService("TweenService")

local packages = script.Parent

local ValueSequence = {}
ValueSequence.__type = "ValueSequence"
local ValueSequenceKeypoint = require(script:WaitForChild("Keypoint"))
local math = require(packages:WaitForChild("math"))

function ValueSequence:__index(k)
	if rawget(self, k) then
		return rawget(self, k)
	elseif rawget(ValueSequence, k) then
		return rawget(ValueSequence, k)
	else
		return nil
	end
end

function ValueSequence:__newindex(k)
	error("You can't write to a ValueSequence after construction")
end

function ValueSequence:Clone()
	local keypoints = {}
	for i, kp in ipairs(self.Keypoints) do
		keypoints[i] = kp:Clone()
	end
	return ValueSequence.new(keypoints, self.Seed)
end

function ValueSequence:Lerp(other: ValueSequence, alpha: number)
	local ts = {}
	for i, kp in ipairs(self.Keypoints) do
		ts[kp.Alpha] = {}
		ts[kp.Alpha].Value = {kp.Value, other:GetValue(kp.Alpha)}
		ts[kp.Alpha].Min = {kp.Min, other:GetValue(kp.Alpha, 0)}
		ts[kp.Alpha].Max = {kp.Max, other:GetValue(kp.Alpha, 1)}
	end
	
	for i, kp in ipairs(other.Keypoints) do
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

function ValueSequence:GetValue(
	alpha: number,
	minMaxAlpha: number | nil
)
	-- local easedAlpha
	easingStyle = easingStyle or Enum.EasingStyle.Linear
	easingDirection = easingDirection or Enum.EasingDirection.InOut
	if type(easingStyle) == "string" then
		easingStyle = Enum.EasingStyle[easingStyle]
	end
	if type(easingDirection) == "string" then
		easingDirection = Enum.EasingDirection[easingDirection]
	end
	local easedAlpha = TweenService:GetValue(alpha, easingStyle, easingDirection)
	-- minMaxAlpha = math.clamp(minMaxAlpha or 0.5, 0, 1)
	-- If we are at 0 or 1, return the first or last value respectively
	if easedAlpha == 0 then
		local first = self.Keypoints[#self.Keypoints]
		return first.Value
	end
	if easedAlpha == 1 then
		local last = self.Keypoints[#self.Keypoints]
		return last.Value
	end
	-- Step through each sequential pair of keypoints and see if alpha

	-- lies between the points' time values.
	for i = 1, #self.Keypoints - 1 do
		local ths = self.Keypoints[i]
		local nxt = self.Keypoints[i + 1]
		if easedAlpha >= ths.Alpha and easedAlpha < nxt.Alpha then
			-- Calculate how far alpha lies between the points
			local nxtAlpha = (easedAlpha - ths.Alpha) / (nxt.Alpha - ths.Alpha)
			if minMaxAlpha then
				local min = math.Algebra.lerp(ths.Min, nxt.Min, nxtAlpha)
				local max = math.Algebra.lerp(ths.Max, nxt.Max, nxtAlpha)

				return math.Algebra.lerp(min, max, minMaxAlpha)
			else
				return math.Algebra.lerp(ths.Value, nxt.Value, nxtAlpha)
			end
			-- return (next.Value - this.Value) * nxtAlpha + this.Value
		end
	end
end

function ValueSequence.keypoint(...)
	return ValueSequenceKeypoint.new(...)
end

function ValueSequence:Solve(steps: number, minMaxAlpha: number | nil)
	minMaxAlpha = minMaxAlpha or self.Random:NextNumber()
	local values = {}
	for i=1, steps do
		local alpha = i/steps
		local value = self:GetValue(alpha, minMaxAlpha)
		table.insert(values, value)
	end
	return values
end

function ValueSequence.new(keyPointList: {[number]: ValueSequenceKeypoint}, seed: number | nil)
	seed = seed or tick()
	local self = setmetatable({
		Keypoints = keyPointList,
		Seed = seed,
		Random = Random.new(seed),
	}, ValueSequence)
	return self
end

export type ValueSequence = typeof(ValueSequence.new({}))

return ValueSequence