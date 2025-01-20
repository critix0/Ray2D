--!strict

local Ray2D = {}
Ray2D.__index = Ray2D

local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

export type RaycastParams2D = {
	FilterType: Enum.RaycastFilterType?,
	FilterDescendantInstances: { Instance? }?,
}

type Ray2D = typeof(setmetatable({} :: {
	parent: ScreenGui,
	ray: Frame,
	origin: UDim2,
	direction: UDim2,
	params: RaycastParams2D
}, Ray2D))

type SideData = {
	top: number,
	bottom: number,
	left: number,
	right: number,
}

function Ray2D.new(parent: ScreenGui, origin: UDim2, direction: UDim2, params: RaycastParams2D): Ray2D?
	if not RS:IsClient() then 
		warn("Ray2D can only be used on the client!")
		return
	end

	local ray = Instance.new("Frame")
	ray.Size = UDim2.new(0.001, 0, 0.001, 0)
	ray.Position = origin
	
	return setmetatable({
		parent = parent,
		ray = ray,
		origin = origin,
		direction = direction,
		params = params
	}, Ray2D) :: Ray2D
end

function Ray2D:Cast(): GuiObject?
	local tween = TS:Create(self.ray, TweenInfo.new(0), {Position = self.direction})
	tween:Play()
	
	local instance
	
	RS:BindToRenderStep("raycast", 4, function()
		for _, v in pairs(self.parent:GetDescendants()) do
			if v:IsA("GuiObject") and self:_checkCollision(v) then
				if self.params.FilterType and (self.params.FilterType == Enum.RaycastFilterType.Include and table.find(self.params.FilterDescendantInstances, v)) or (self.params.FilterType == Enum.RaycastFilterType.Exclude and not table.find(self.params.FilterDescendantInstances, v)) then
					RS:UnbindFromRenderStep("raycast")
					instance = v
				end
			end
		end
	end)
	
	tween.Completed:Wait()
	
	return instance :: GuiObject?
end

function Ray2D:_checkCollision(target: GuiObject): boolean
	local raySides: SideData = self:_getSides(self.ray)
	local targetSides: SideData = self:_getSides(target)
	
	if (raySides.right > targetSides.left and raySides.right < targetSides.right) or (raySides.left < targetSides.right and raySides.left > targetSides.left) or (raySides.top < targetSides.bottom and raySides.top > targetSides.top) or (raySides.bottom > targetSides.top and raySides.bottom < targetSides.bottom) then
		return true
	end
	return false
end

function Ray2D:_getSides(target: GuiObject): SideData
	local size: Vector2 = target.AbsoluteSize / 2
	local position: Vector2 = target.AbsolutePosition
	local middle: Vector2 = position + size / 2 
	
	return {
		top = middle.Y - size.Y,
		bottom = middle.Y + size.Y,
		left = middle.X - size.X,
		right = middle.X + size.X
	} :: SideData
end

return Ray2D
