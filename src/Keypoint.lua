--!nocheck

local packages = script.Parent.Parent
local math = require(packages:WaitForChild("math"))

local ValueSequenceKeypoint = {}
ValueSequenceKeypoint.__type = "ValueSequenceKeypoint"

export type lerpValue = number
| string
| boolean
| BrickColor
| ColorSequence
| ColorSequenceKeypoint
| DateTime
| EnumItem
| NumberRange
| NumberSequence
| PathWaypoint
| PhysicalProperties
| Ray
| Rect
| Region3
| Region3int16
| UDim
| UDim2
| Color3
| Vector3
| CFrame

export type ValueSequenceKeypoint = {
	new: (alpha: number, v: lerpValue) -> ValueSequenceKeypoint,
	Lerp: (keypoint: (ValueSequenceKeypoint), alpha: number) -> ValueSequenceKeypoint,
	Alpha: number,
	Value: lerpValue,
	Min: lerpValue | nil,
	Max: lerpValue | nil
}
-- export type ValueSequenceKeypoint = {alpha: number, value: any, min: any | nil, max: any | nil}

function ValueSequenceKeypoint:__index(k)
	if rawget(self, k) then
		return rawget(self, k)
	elseif rawget(ValueSequenceKeypoint, k) then
		return rawget(ValueSequenceKeypoint, k)
	else
		return nil
	end
end

--lerps the keypoint by the alpha between the min and max value
function ValueSequenceKeypoint:Lerp(vsk: ValueSequenceKeypoint, alpha: number)
	local a = math.Algebra.lerp(self.Alpha, vsk.Alpha)
	local v = math.Algebra.lerp(self.Value, vsk.Value)
	local min = math.Algebra.lerp(self.Min, vsk.Min)
	local max = math.Algebra.lerp(self.Max, vsk.Max)
	return ValueSequenceKeypoint.new(a,v,min,max)
end

function ValueSequenceKeypoint:__newindex(k)
	error("You can't write to a ValueSequenceKeypoint after construction")
end

function ValueSequenceKeypoint.new(a: number, v: any, min: any | nil, max: any | nil): ValueSequenceKeypoint
	min = min or v
	max = max or v

	local self = setmetatable({
		Alpha = a,
		Value = v,
		Min = min,
		Max = max,
	}, ValueSequenceKeypoint)
	return self
end

return ValueSequenceKeypoint