--!strict
local _Package = script.Parent
local _Packages = _Package.Parent
-- Services
-- Packages
local CurveUtil = require(_Packages:WaitForChild("CurveUtil"))

-- Modules
-- Types
export type ValueSequenceKeypoint<V> = {
	__index: ValueSequenceKeypoint<V>,
	Time: number,
	Value: V,
	Min: V,
	Max: V,
	new: (t: number, v: V, min: V?, max: V?) -> ValueSequenceKeypoint<V>,
	Lerp: (self: ValueSequenceKeypoint<V>, other: ValueSequenceKeypoint<V>, alpha: number) -> ValueSequenceKeypoint<V>
}

-- Constants
-- Variables
-- References
-- Private Functions
-- Class

local ValueSequenceKeypoint = {} :: ValueSequenceKeypoint<any>
ValueSequenceKeypoint.__index = ValueSequenceKeypoint

function ValueSequenceKeypoint.new(t: number, v: any, min: any?, max: any?): ValueSequenceKeypoint<any>
	min = min or v
	max = max or v

	local self: ValueSequenceKeypoint<any> = setmetatable({}, ValueSequenceKeypoint) :: any
	self.Time = t
	self.Value = v
	self.Min = min
	self.Max = max

	return self
end

--lerps the keypoint by the alpha between the min and max value
function ValueSequenceKeypoint:Lerp(other: ValueSequenceKeypoint<any>, alpha: number): ValueSequenceKeypoint<any>

	local t = CurveUtil.lerp(self.Time, other.Time, alpha)
	local v = CurveUtil.lerp(self.Value, other.Value, alpha)

	local min = CurveUtil.lerp(self.Min, other.Min, alpha)
	local max = CurveUtil.lerp(self.Max, other.Max, alpha)

	return ValueSequenceKeypoint.new(t,v,min,max)
end

return ValueSequenceKeypoint