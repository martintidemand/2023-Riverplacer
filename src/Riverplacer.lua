

local toolbar = plugin:CreateToolbar("Riverplacer")


local makePoints = toolbar:CreateButton("mkpts", "make points", "rbxassetid://0")
local activateLinks = toolbar:CreateButton("act", "act", "rbxassetid://0")
local deactivateLinks = toolbar:CreateButton("deact", "deact", "rbxassetid://0")
local lockAll = toolbar:CreateButton("lock", "lock", "rbxassetid://0")


makePoints.ClickableWhenViewportHidden = true
activateLinks.ClickableWhenViewportHidden = true
deactivateLinks.ClickableWhenViewportHidden = true

local skipWater = RaycastParams.new()
skipWater.FilterType = Enum.RaycastFilterType.Exclude
skipWater.FilterDescendantsInstances = {workspace.Map.water, workspace.Map.watersolid}

points = {{0,0,0.4}}

local function onMakePoints()
	for index,elem in ipairs(points) do
		--k is the element
		print(index)
		local new = Instance.new("Part",workspace.Rivers.Points)
		--local new = Instance.new("Part",workspace)
		new.Name = (elem[1] .. " " .. elem[2])
		new.Anchored = true
		
		print(elem[3])
		if (elem[3] == 0.3) then
			new.Color = Color3.new(1,0,0) --really red
		elseif (elem[3] == 0.4) then
			new.Color = Color3.new(0,1,0) --Lime green
		else 
			new.Color = Color3.new(0,0,1) --really blue
		end
		new.Size = Vector3.new(0.8,1,0.8)
		
		--local ray = Ray.new(Vector3.new(elem[1]+0.5,16,-elem[2]-0.5),Vector3.new(elem[1]+0.5,-1,-elem[2]-0.5))
		--print(ray)
		local above = Vector3.new(-elem[2]-0.5,16,elem[1]+0.5)
		local below = Vector3.new(0,-17,0)
		print(above)
		print(below)
		--new.CFrame = CFrame.new(-elem[1]-0.5,5,elem[2]+0.5)
		local raycastResult = workspace:Raycast(above,below)
		--print("hello")
		--print(raycastResult.Position)
		--print("hello")
		
		new.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0,0.5,0))
		--new.Locked = true
		wait(0.1)
	end
end
--------------------------------------------------------------------------------------------

local mouse = plugin:getMouse()
local filter = RaycastParams.new()
filter.FilterType = Enum.RaycastFilterType.Exclude
filter.FilterDescendantsInstances = {workspace.Map.water, workspace.Map.watersolid, workspace.Rivers.Points, workspace.Rivers.Sections}


local function getWidth(p)
	if p.Color == Color3.new(1,0,0) then
		return 0.3
	elseif p.Color == Color3.new(0,1,0) then
		return 0.4
	elseif p.Color == Color3.new(0,0,1) then
		return 0.5
	else
		return 0
	end
end

local p1 = nil
local p2 = nil

--Step 1: placing the bends.
local function Bends(p)
	local rR = workspace:Raycast(p.Position + Vector3.new(0,15,0), Vector3.new(0,-31,0), filter)
	if rR.Instance == nil then
		print("Bug: Nothing was hit by ray. Should hit terrain:" .. p.Position)
		
		return nil
	elseif rR.Instance.parent == workspace.Rivers.Bends then
		print("Bend exists")
		rR.Instance.Size = Vector3.new(0.1,math.max(getWidth(p1),rR.Instance.Size.Y),math.max(getWidth(p1),rR.Instance.Size.Z))  --Sets the size of the existing bend to the maximum river here. Or p1.
		--rR.Instance.Size.Z = 
		return rR.Instance
	else
		print("No bends exist")
		local newBend = Instance.new("Part",workspace.Rivers.Bends)
		newBend.Name = p.Name
		newBend.Size = Vector3.new(0.1,getWidth(p1),getWidth(p1))
		newBend.BrickColor = BrickColor.new("Bright blue")
		newBend.Anchored = true
		newBend.TopSurface = 0
		newBend.BottomSurface = 0
		newBend.CFrame = CFrame.new(p.Position - Vector3.new(0,0.5,0))
		newBend.Shape = Enum.PartType.Cylinder
		
		local rotation = CFrame.Angles(0, math.rad(90), math.rad(90))
		local modelCFrame = newBend:GetPivot()
		newBend:PivotTo(modelCFrame * rotation)
		
		return newBend
	end
end


local function Section(originBend)
	local newSection = Instance.new("Part",workspace.Rivers.Sections)
	newSection.Name = p1.Name ..", ".. p2.Name
	newSection.Size = Vector3.new(getWidth(p1),0.1,(p1.Position - Vector3.new(p2.Position.X,p1.Position.Y,p2.Position.Z)).Magnitude)
	newSection.BrickColor = BrickColor.new("Bright blue")
	newSection.Anchored = true
	newSection.TopSurface = 0
	newSection.BottomSurface = 0
	newSection.CFrame = CFrame.new(Vector3.new((p1.Position.X + p2.Position.X) / 2, originBend.Position.Y, (p1.Position.Z + p2.Position.Z) / 2),originBend.Position)
	
	
end

--Should return the direction of the cliff.
--direction is a (i,-y,i)
--where is are the direction and -y is distance to the ocean depth.
--nil if no cliff
local function isCliff()
	local s = workspace:Raycast(p1.Position + Vector3.new(-1,14,0), Vector3.new(0,-31,0), filter)
	local n = workspace:Raycast(p1.Position + Vector3.new(1,14,0), Vector3.new(0,-31,0), filter)
	local e = workspace:Raycast(p1.Position + Vector3.new(0,14,1), Vector3.new(0,-31,0), filter)
	local w = workspace:Raycast(p1.Position + Vector3.new(0,14,-1), Vector3.new(0,-31,0), filter)
	if s == nil then
		return p1.Position + Vector3.new(-0.275,-0.775,0) --in relation to p1
	elseif n == nil then
		return p1.Position + Vector3.new(0.275,-0.775,0) --in relation to p1
	elseif e == nil then
		return p1.Position + Vector3.new(0,-0.775,0.275) --in relation to p1
	elseif w == nil then
		return p1.Position + Vector3.new(0,-0.775,-0.275) --in relation to p1
	else
		print(s.Instance.Name)
		return nil
	end
	
end

--Takes point and direction
--Then creates a new part
--Creates the size
--Creates the position: location -1, directed the direction, 
local function Cliff(p,newPos,height)
	print("------------")
	print(newPos)
	print(p1.Position)
	print("------------")
	local newSize
	if math.abs(newPos.X - p.Position.X) > 0.04 then
		newSize = Vector3.new(0.55, height, getWidth(p))
	else
		newSize = Vector3.new(getWidth(p), height, 0.55)
	end
	
	local waterfall = Instance.new("Part", workspace.Rivers.Sections)
	waterfall.Anchored = true
	waterfall.Size = newSize
	waterfall.Name = p1.Name ..", ".. p2.Name .. "fall"
	waterfall.BrickColor = BrickColor.new("Bright blue")
	waterfall.TopSurface = 0
	waterfall.BottomSurface = 0
	waterfall.CFrame = CFrame.new(newPos)	
end

			--[[ size:
			width, difference + 0.05, 0.55
			for ns:
			0.55, difference + 0.05, width
			]]


local function button1Down()
	--print("Button 1 pressed from PluginMouse")
	local target = mouse.Target
	
	if target.parent.Name == "Points" and target.parent.parent.Name == "Rivers" and target.parent.parent.parent.Name == "Workspace" then
		print(target.Name)
		if p1 == nil then
			p1 = target
		elseif p2 == nil then
			p2 = target
			
			local originBend = Bends(p1)
			Bends(p2)
			
			Section(originBend)
			
			local cliffDirection = isCliff()
			if cliffDirection ~= nil then
				Cliff(p1, cliffDirection, 0.65)
			elseif p1.Position.Y < p2.Position.Y - 0.04 then
				--difference is 0 on the same axis and 1 on the differing axis.
				--So multiplying both by 0.275 should be okay.
				--and then the difference in height
				Cliff(p2, Vector3.new(p2.Position.X + 0.275*(p1.Position.X - p2.Position.X),((p1.Position.Y + p2.Position.Y)/2) - 0.5 + 0.025,p2.Position.Z + 0.275*(p1.Position.Z - p2.Position.Z )), p2.Position.Y - p1.Position.Y + 0.05)
					--the vector 3 is what I will have to subtract from p2 to get to the new part.
					--correction, it is the next position.
				--0.5 + 0.3 = 0.8
				--0.8 - 0.025 = 0.775
				
				--0.275 is a constant. Just need to find its direction.
			end
			--[[ size:
			width, difference + 0.05, 0.55
			for ns:
			0.55, difference + 0.05, width
			]]
			p1 = nil
			p2 = nil
		else
			print("Bug: p1 and p2 not reset")
		end
	end
end

mouse.Button1Down:Connect(button1Down)


local function onActivateLinks()
	plugin:activate(true)
end
--makePoints.Click:Connect(onMakePoints)
activateLinks.Click:Connect(onActivateLinks)
local function onDeactivateLinks()
	plugin:deactivate()
end
deactivateLinks.Click:Connect(onDeactivateLinks)

local function onLockAll()
	for i, part in pairs(workspace.Rivers.Bends:GetChildren()) do
		part.Locked = true
	end
	for i, part in pairs(workspace.Rivers.Sections:GetChildren()) do
		part.Locked = true
	end
end
lockAll.Click:Connect(onLockAll)
