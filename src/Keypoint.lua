local packages = script.Parent.Parent

local ValueSequenceKeypoint = {}

function ValueSequenceKeypoint:__index(k)
	if rawget(self, k) then
		return rawget(self, k)
	elseif rawget(ValueSequenceKeypoint, k) then
		return rawget(ValueSequenceKeypoint, k)
	else
		return nil
	end
end

function ValueSequenceKeypoint:__newindex(k)
	error("You can't write to a ValueSequenceKeypoint after construction")
end

function ValueSequenceKeypoint.new(a: number, v: any, envelope: any, bezierPoint: Vector2)
	local self = setmetatable({
		Alpha = a,
		Value = v,
		Envelope = envelope or 0,
		BezierPoint = bezierPoint or Vector2.new(0,0), --default is center of line, basically linear
	}, ValueSequenceKeypoint)
	return self
end

return ValueSequenceKeypoint