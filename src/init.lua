--!strict
--!native
local _Package = script
local _Packages = _Package.Parent
-- Services
-- Packages
local CurveUtil = require(_Packages:WaitForChild("CurveUtil"))

-- Modules
local ValueSequenceKeypoint = require(_Package:WaitForChild("Keypoint"))

-- Types
type StepData<V> = {
	Value: V,
	Min: V,
	Max: V
}
export type ValueSequenceKeypoint<V> = ValueSequenceKeypoint.ValueSequenceKeypoint<V>
export type ValueSequence<V> = {
	__index: ValueSequence<V>,
	Seed: number,
	Random: Random,
	new: (keypoints: {[number]: ValueSequenceKeypoint<V>}, v: V) -> ValueSequence<V>,
	newKeypoint: (alpha: number, value: V, min: V?, max: V?) -> ValueSequenceKeypoint<V>,
	Lerp: (self: ValueSequence<V>, other: ValueSequence<V>, alpha: number) -> ValueSequence<V>,
	GetValue: (self: ValueSequence<V>, alpha: number, weight: number?) -> V,
	Solve: (self:ValueSequence<V>, steps: number, weight: number?) -> {[number]: V},
	Keypoints: {[number]: ValueSequenceKeypoint<V>},
}

-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local ValueSequence = {} :: ValueSequence<any>
ValueSequence.__index = ValueSequence

function ValueSequence.newKeypoint(alpha: number, value: any, min: any?, max: any?): ValueSequenceKeypoint<any>
	return ValueSequenceKeypoint.new(alpha, value, min, max)
end

function ValueSequence:Lerp(other: ValueSequence<any>, alpha: number): ValueSequence<any>

	local ts: {[number]: StepData<any>} = {}
	for _, kp in ipairs(self.Keypoints) do
		local stepData: StepData<any> = {
			Value = {kp.Value, other:GetValue(kp.Time)},
			Min = {kp.Min, other:GetValue(kp.Time, 0)},
			Max = {kp.Max, other:GetValue(kp.Time, 1)},
		}
		ts[kp.Time] = stepData
	end
	
	for _, kp in ipairs(other.Keypoints) do
		ts[kp.Time] = ts[kp.Time] or {}
		if ts[kp.Time].Value then
			ts[kp.Time].Value = {ts[kp.Time].Value[1], kp.Value}
		else
			ts[kp.Time].Value = {self:GetValue(kp.Time), kp.Value}
		end
		if ts[kp.Time].Min then
			ts[kp.Time].Min = {ts[kp.Time].Min[1], kp.Min}
		else
			ts[kp.Time].Min = {self:GetValue(kp.Time, 0), kp.Min}
		end
		if ts[kp.Time].Max then
			ts[kp.Time].Max = {ts[kp.Time].Max[1], kp.Max}
		else
			ts[kp.Time].Max = {self:GetValue(kp.Time, 1), kp.Max}
		end
	end

	local keypoints = {}
	for t, v in pairs(ts) do

		local val = CurveUtil.lerp(v.Value[1], v.Value[2], alpha)
		local min = CurveUtil.lerp(v.Min[1], v.Min[2], alpha)
		local max = CurveUtil.lerp(v.Max[1], v.Max[2], alpha)

		local kp = ValueSequenceKeypoint.new(t, val, min, max)

		table.insert(keypoints, kp)
	end
	table.sort(keypoints, function(a: ValueSequenceKeypoint<any>, b: ValueSequenceKeypoint<any>): boolean
		return a.Time < b.Time
	end)

	return ValueSequence.new(
		keypoints, 
		CurveUtil.lerp(self.Seed, other.Seed, alpha)
	)
end

-- Returns the value at a specific alpha, as well as at the specified min-max weight
function ValueSequence:GetValue(alpha: number, minMaxWeight: number?): any
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
		if alpha >= ths.Time and alpha < nxt.Time then
			-- Calculate how far alpha lies between the points
			local nxtAlpha = (alpha - ths.Time) / (nxt.Time - ths.Time)
			if minMaxWeight then
				local min = CurveUtil.lerp(ths.Min, nxt.Min, nxtAlpha)
				local max = CurveUtil.lerp(ths.Max, nxt.Max, nxtAlpha)

				return CurveUtil.lerp(min, max, minMaxWeight)
			else
				return CurveUtil.lerp(ths.Value, nxt.Value, nxtAlpha)
			end
			-- return (next.Value - this.Value) * nxtAlpha + this.Value
		end
	end
	return
end

-- Returns a list of steps at regular intervals showing the value across alpha
function ValueSequence:Solve(steps: number, minMaxWeight: number?): {[number]: any}
	minMaxWeight = minMaxWeight or self.Random:NextNumber()
	local values = {}
	for i=1, steps do
		local alpha = i/steps
		local value = self:GetValue(alpha, minMaxWeight)
		table.insert(values, value)
	end
	return values
end

function ValueSequence.new(keyPointList: {[number]: ValueSequenceKeypoint<any>}, seed: number?): ValueSequence<any>
	seed = seed or tick()
	local self = setmetatable({
		Keypoints = keyPointList,
		Seed = seed,
		Random = Random.new(seed),
	}, ValueSequence)
	return (self :: any) :: ValueSequence<any>
end

return ValueSequence
