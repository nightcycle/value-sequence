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

function prep(
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
	return easedAlpha, easingStyle, easingDirection
end

-- function ValueSequence:GetKeypointVector2(keypointIndex: number)
-- 	local kp = self.Keypoints[keypointIndex]
-- 	assert(kp ~= nil, "Bad V2 keypoint")

-- 	return Vector2.new(kp.Alpha, self.Evaluator(kp.Value))
-- end

-- function ValueSequence:GetNearestKeypointIndeces(alpha: number)
-- 	local pre
-- 	local pI
-- 	local nxt
-- 	local nI

-- 	for i, keypoint in ipairs(self.Keypoints) do
-- 		if (keypoint.Alpha < alpha or (alpha == 0 and keypoint.Alpha == 0)) and (not pre or keypoint.Alpha > pre.Alpha) then
-- 			pre = keypoint
-- 			pI = i
-- 		end
-- 		if (keypoint.Alpha > alpha or (alpha == 1 and keypoint.Alpha == 1)) and (not nxt or keypoint.Alpha < nxt.Alpha) then
-- 			nxt = keypoint
-- 			nI = i
-- 		end
-- 	end
-- 	return pI, nI
-- end

-- function ValueSequence:GetBezierPoints(keypointIndex: number)
-- 	local kp = self.Keypoints[keypointIndex]
-- 	assert(kp ~= nil, "Bad keypoint")
-- 	local smoothing = kp.Smoothing

-- 	local point = self:GetKeypointVector2(keypointIndex)

-- 	local prevPoint = point
-- 	if keypointIndex > 1 then
-- 		prevPoint = self:GetKeypointVector2(keypointIndex-1)

-- 	end
-- 	local nextPoint = point
-- 	if keypointIndex < #self.Keypoints then

-- 		nextPoint = self:GetKeypointVector2(keypointIndex+1)
-- 	end

-- 	local pOffset = (prevPoint-point)
-- 	local nOffset = (nextPoint-point)

-- 	local pNormal = if pOffset.Unit == pOffset.Unit then pOffset.Unit else Vector2.new(0,1)
-- 	local nNormal = if nOffset.Unit == nOffset.Unit then nOffset.Unit else Vector2.new(0,1)
-- 	local cNormal = pNormal:Lerp(nNormal, 0.5)

-- 	local pDist = pOffset.Magnitude
-- 	local nDist = nOffset.Magnitude

-- 	local nMidpoint = point + nOffset.Unit * nDist * 0.5
-- 	local pMidpoint = point + nOffset.Unit * nDist * 0.5

-- 	local function rotate(v2, sign)
-- 		local base = math.atan2(v2.Y, v2.X)
-- 		local adjust = math.rad(90)*sign
-- 		local offset = Vector2.new(math.cos(base), math.sin(base))
-- 		return offset
-- 	end

-- 	local pBezierPoint = point + rotate(cNormal, -1) * smoothing * nDist * 0.5
-- 	local nBezierPoint = point + rotate(cNormal, 1) * smoothing * nDist * 0.5
-- 	-- print(pBezierPoint, nBezierPoint)
-- 	if pBezierPoint.X == point.X then
-- 		pBezierPoint += Vector2.new(-pDist*0.0001,0)
-- 	end
-- 	if nBezierPoint.X == point.X then
-- 		pBezierPoint += Vector2.new(nDist*0.0001,0)
-- 	end

-- 	return pMidpoint - cNormal, nMidpoint + cNormal
-- end

-- function ValueSequence:GetValue(
-- 	alpha: number,
-- 	envelopeWeight: number | nil
-- )
-- 	-- local easedAlpha
-- 	local easedAlpha, easingStyle, easingDirection = prep(alpha, nil, nil, envelopeWeight)

-- 	local pIndex, nIndex = self:GetNearestKeypointIndeces(easedAlpha)

-- 	local pre, nxt = self.Keypoints[pIndex], self.Keypoints[nIndex]
-- 	local preAlpha = TweenService:GetValue(pre.Alpha, easingStyle, easingDirection)
-- 	local nxtAlpha = TweenService:GetValue(nxt.Alpha, easingStyle, easingDirection)
-- 	local relativeAlpha = (easedAlpha - preAlpha)/(nxtAlpha - preAlpha)
-- 	local start = self:GetKeypointVector2(pIndex)
-- 	local finish = self:GetKeypointVector2(nIndex)
-- 	local pPB, pNB = self:GetBezierPoints(pIndex)
-- 	local nPB, nNB = self:GetBezierPoints(nIndex)


-- 	local b1 = pNB
-- 	local b2 = nPB

-- 	print("B1", (start-b1).Magnitude)
-- 	print("B2", (finish-b2).Magnitude)

-- 	local h1B1 = start:Lerp(b1, relativeAlpha)
-- 	print("h1B1", (start-h1B1).Magnitude)
-- 	-- local h1B2 = b1:Lerp(b2, relativeAlpha)
-- 	local h1B3 = b2:Lerp(finish, relativeAlpha)
-- 	print("h1B3", (finish-h1B3).Magnitude)

-- 	-- local h2B1 = h1B1:Lerp(h1B2, relativeAlpha)
-- 	-- local h2B2 = h1B2:Lerp(h1B3, relativeAlpha)
-- 	local h3 = h1B1:Lerp(h1B3, relativeAlpha)

-- 	return h3.Y
-- end

function ValueSequence:GetValue(
	alpha: number,
	envelopeWeight: number | nil
)
	-- local easedAlpha
	local easedAlpha, easingStyle, easingDirection = prep(alpha, nil, nil, envelopeWeight)
	
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
			local envelopeMag = (next.Envelope - this.Envelope) * (nxtAlpha) + this.Envelope
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