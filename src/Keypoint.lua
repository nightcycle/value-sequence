--!nocheck

local packages = script.Parent.Parent
local MathUtil = require(packages:WaitForChild("math"))
local ValueSequenceKeypoint = {}

export type LerpValue = number
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

function ValueSequenceKeypoint.new(a: number, v: any, min: any | nil, max: any | nil): ValueSequenceKeypoint
	min = min or v
	max = max or v

	local self = {
		Alpha = a,
		Value = v,
		Min = min,
		Max = max,
	}
	setmetatable(self, ValueSequenceKeypoint)

	return (self :: any) :: ValueSequenceKeypoint
end

export type ValueSequenceKeypoint = typeof(ValueSequenceKeypoint.new(0,0))

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

	local a = MathUtil.Algebra.lerp(self.Alpha, vsk.Alpha) :: LerpValue
	local v = MathUtil.Algebra.lerp(self.Value, vsk.Value) :: LerpValue

	local min = MathUtil.Algebra.lerp(self.Min, vsk.Min) :: LerpValue
	local max = MathUtil.Algebra.lerp(self.Max, vsk.Max) :: LerpValue

	return ValueSequenceKeypoint.new(a,v,min,max) :: LerpValue
end

function ValueSequenceKeypoint:__newindex(k)
	error("You can't write to a ValueSequenceKeypoint after construction")
end

return ValueSequenceKeypoint