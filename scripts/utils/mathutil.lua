local min = math.min
local sqrt = math.sqrt
local abs = math.abs

local function DistXZSq(p1, p2)
	local dx, dz = p1.x-p2.x, p1.z-p2.z
	return dx*dx + dz*dz
end

local function DistPointToSegmentXZSq(p, v1, v2)
	-- 点到线段的距离
	local l2 = DistXZSq(v1, v2)
	if (l2 == 0) then
		return DistXZSq(p, v1)
	end
	local t = ((p.x - v1.x) * (v2.x - v1.x) + (p.z - v1.z) * (v2.z - v1.z)) / l2
	if (t < 0) then
		return DistXZSq(p, v1)
	end
	if (t > 1) then
		return DistXZSq(p, v2)
	end
	return DistXZSq(p, {x = v1.x + t * (v2.x - v1.x), z =v1.z + t * (v2.z - v1.z)});
end

local function DistPointToLine(p, v1, v2)
	-- 求点到直线的距离及垂足
	local l2 = DistXZSq(v1, v2)
	assert(l2 > 0)
	local t = ((p.x - v1.x) * (v2.x - v1.x) + (p.z - v1.z) * (v2.z - v1.z)) / l2
	local vpoint = Point(v1.x + t * (v2.x - v1.x), 0, v1.z + t * (v2.z - v1.z))
	return DistXZSq(p, vpoint), vpoint
end

local Lines = Class(function(self, points)
	-- json.decode("[[1,2],[3,4],[5,6]]")
	self.points = points
	self.left_point = points[1]
	self.right_point = points[#points]
end)

function Lines:y_at_x(x)
	if x <= self.left_point[1] then
		return self.left_point[2]
	elseif x >= self.right_point[1] then
		return self.right_point[2]
	else
		for i,p in ipairs(self.points)do
			if p[1] >= x then
				local p1, p2 = self.points[i-1], p
				return Remap(x,p1[1],p2[1],p1[2],p2[2])
			end
		end
	end
end

local function v2cross(a, b)
	return a.z*b.x - a.x*b.z
end

local Segment = Class(function(self, p1, p2)
	self.p1 = p1
	self.p2 = p2
	self.dir = p2 - p1
end)

function Segment:__eq(s)
	return (self.p1 == s.p1 and self.p2 == s.p2) or (self.p1 == s.p2 and self.p2 == s.p1)
end

function Segment:Hash()
	local x1, z1 = self.p1.x, self.p1.z
	local x2, z2 = self.p2.x, self.p2.z

	if x1 + z1 > x2 + z2 or (x1 + z1 == x2 + z2 and x1 > x2) then
		x1, z1, x2, z2 = x2, z2, x1, z1
	end

	return string.format("[%.1f,%.1f]-[%.1f,%.1f]", x1, z1, x2, z2)
end

function Segment:LengthSq()
	return self.dir:LengthSq()
end

function Segment:IsOut(p)
	-- 判断点是否在两端点外
	return (p.x - self.p1.x)*(p.x - self.p2.x) > 0 or (p.z - self.p1.z)*(p.z - self.p2.z) > 0
end

function Segment:Intersect(v, seg_intersect)
	-- 计算与另一线段的交点
	-- return: 两直线是否相交  交点  两线段是否相交
	assert(v:is_a(Segment))

	if v:LengthSq() + self:LengthSq() < 1e-6 then
		return false -- 两点重合
	end

	local s1, s2 = v2cross(v.p1-self.p1, self.dir), v2cross(self.dir, v.p2-self.p1)
	if abs(s1) + abs(s2) < 1e-6 then
		return false -- 平行
	end
	local p = v.p1 + v.dir*(s1/(s1+s2))
	if self:IsOut(p) then
		return true, p, false
	elseif seg_intersect and v:IsOut(p) then
		return true, p ,false
	else
		return true, p, true
	end
end

-- 多边形
local Polygon = Class(function(self, points)
	self.points = points
end)

function Polygon:IsPointIn(p)
	-- 点p是否在多边形内
	local count = 0
	local seg = Segment(p, p + Vector3(GetRandomMinMax(128,256), 0, GetRandomMinMax(512,1024)))
	for i = 1, #self.points do
		local p1, p2 = self.points[i], self.points[i == #self.points and 1 or i + 1]
		if p1 ~= p2 then
			local is_intersect, _, is_true = Segment(p1, p2):Intersect(seg, true)
			if not is_intersect then
				-- return self:IsPointIn(p)
			elseif is_true then
				count = count + 1
			end
		end
	end
	return count % 2 == 1
end

function Polygon:IsPointWithRadiusIn(p, radius)
	-- 带碰撞半径radius的点p是否在多边形内
	if radius == nil or radius <= 0 then
		return self:IsPointIn(p)
	end
	for _, vert in ipairs(self.points)do
		if (p.x-vert.x)*(p.x-vert.x) + (p.z-vert.z)*(p.z-vert.z) <= radius * radius then
			return true -- 在顶点附近
		end
	end

	local count = 0
	local seg = Segment(p, p + Vector3(GetRandomMinMax(128,256), 0, GetRandomMinMax(512,1024)))
	for i = 1, #self.points do
		local p1, p2 = self.points[i], self.points[i == #self.points and 1 or i + 1]
		if DistPointToSegmentXZSq(p, p1, p2) <= radius * radius then
			return true -- 在边附近
		end
		if p1 ~= p2 then
			local is_intersect, _, is_true = Segment(p1, p2):Intersect(seg, true)
			if not is_intersect then
				-- return self:IsPointIn(p)
			elseif is_true then
				count = count + 1
			end
		end
	end
	return count % 2 == 1
end

function Polygon:IsEntityIn(inst)
	return self:IsPointWithRadiusIn(inst:GetPosition(), inst:GetPhysicsRadius(0))
end

local function dot(v1, v2)
	return v1.x * v2.x + v1.z * v2.z
end

function Polygon:Intersect(line)
	-- 求与另一有向射线的第一个交点
	local intersect_point = nil
	local intersect_seg = nil
	local temp = nil
	for i = 1, #self.points do
		local p1, p2 = self.points[i], self.points[i == #self.points and 1 or i + 1]
		local seg = Segment(p1, p2)
		local is_intersect, point, is_true = seg:Intersect(line)
		if is_intersect and is_true then
			local t = dot(point - line.p1, line.dir)
			if temp == nil or temp > t then
				intersect_point = point
				intersect_seg = seg
				temp = t
			end
		end
	end
	return intersect_point, intersect_seg
end


local function DeltaAngle(p1, p2)
	return (p2-p1) % 360
end

local function DeltaAngleAbs(p1, p2)
	local p = DeltaAngle(p1, p2)
	return min(p, 360-p)
end

return {
	DistXZSq = DistXZSq,
	DistPointToLine = DistPointToLine,
	DistPointToSegmentXZSq = DistPointToSegmentXZSq,

	Lines = Lines,
	Segment = Segment,
	Polygon = Polygon,

	DeltaAngle = DeltaAngle,
	DeltaAngleAbs = DeltaAngleAbs,
}
