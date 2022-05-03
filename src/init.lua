local TweenService = game:GetService("TweenService")

local packages = script.Parent

local ValueSequence = {}
local ValueSequenceKeypoint = require(script:WaitForChild("Keypoint"))

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

function ValueSequence:GetValue(
	alpha: number,
	easingStyle: EnumItem | string | nil,
	easingDirection: EnumItem | string | nil,
	envelopeWeight: number | nil
)
	easingStyle = easingStyle or Enum.EasingStyle.Linear
	easingDirection = easingDirection or Enum.EasingDirection.InOut
	if type(easingStyle) == "string" then
		easingStyle = Enum.EasingStyle[easingStyle]
	end
	if type(easingDirection) == "string" then
		easingDirection = Enum.EasingDirection[easingDirection]
	end
	local easedAlpha = TweenService:GetValue(alpha, easingStyle, easingDirection)
	envelopeWeight = envelopeWeight or 0
	-- If we are at 0 or 1, return the first or last value respectively
	if easedAlpha == 0 then
		local first = self.Keypoints[#self.Keypoints]
		return first.Value, first.Envelope * envelopeWeight
	end
	if easedAlpha == 1 then
		local last = self.Keypoints[#self.Keypoints]
		return last.Value, last.Envelope * envelopeWeight
	end
	-- Step through each sequential pair of keypoints and see if alpha

	-- lies between the points' time values.
	for i = 1, #self.Keypoints - 1 do
		local this = self.Keypoints[i]
		local next = self.Keypoints[i + 1]
		if easedAlpha >= this.Alpha and easedAlpha < next.Alpha then
			-- Calculate how far alpha lies between the points
			local nxtAlpha = (easedAlpha - this.Alpha) / (next.Alpha - this.Alpha)
			local envelopeMag = (next.Envelope - this.Envelope) * nxtAlpha + this.Envelope
			-- Evaluate the real value between the points using alpha
			return (next.Value - this.Value) * nxtAlpha + this.Value, envelopeMag
		end
	end
end

function ValueSequence.keypoint(...)
	return ValueSequenceKeypoint.new(...)
end

function ValueSequence.new(keyPointList)
	local self = setmetatable({
		Keypoints = keyPointList,
	}, ValueSequence)
	return self
end

return ValueSequence