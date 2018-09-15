
local function class(classname, super)
	local superType = type(super)
	local cls

	if superType ~= "function" and superType ~= "table" then
		superType = nil
		super = nil
	end

	if superType == "function" or(super and super.__ctype == 1) then
		-- inherited from native C++ Object
		cls = { }

		if superType == "table" then
			-- copy fields from super
			for k, v in pairs(super) do cls[k] = v end
			cls.__create = super.__create
			cls.super = super
		else
			cls.__create = super
			cls.ctor = function() end
		end

		cls.__cname = classname
		cls.__ctype = 1

		function cls.new(...)
			local instance = cls.__create(...)
			-- copy fields from class to native object
			for k, v in pairs(cls) do instance[k] = v end
			instance.class = cls
			instance:ctor(...)
			return instance
		end

	else
		-- inherited from Lua Object
		if super then
			cls = { }
			setmetatable(cls, { __index = super })
			cls.super = super
		else
			cls = { ctor = function() end }
		end

		cls.__cname = classname
		cls.__ctype = 2
		-- lua
		cls.__index = cls

		function cls.new(...)
			local instance = setmetatable( { }, cls)
			instance.class = cls
			instance:ctor(...)
			return instance
		end
	end

	return cls
end


--item的对象池
local ItemPool = class("ItemPool")
ItemPool.itemDic = {}
function ItemPool:ctor()
	self.itemDic = {}
end
--创建item（父物体，item模板）
function ItemPool:CreateItem(parent,itemTempleta)

	--从字典中找出被隐藏的
	local items = self.itemDic[itemTempleta.name]
	if items ~= nil then	--这个itemTempleta从来没有创建过
		for k,v in pairs(items) do
			if v.activeSelf == false then
				v:SetActive(true)
				if v.transform.parent ~= parent.transform then v.transform.parent = parent.transform end
				return v
			end
		end
	else
		self.itemDic[itemTempleta.name] = {}
	end


	--字典中不存在，创建
	local item = parent:AddChild(itemTempleta,"noName")
	item:SetActive(true)
	table.insert(self.itemDic[itemTempleta.name],item)
	return item
end

--删除（隐藏）所有子物体
function ItemPool:RemoveChilds(parent)
	local count = parent.transform.childCount
	for i=0,count-1 do
		parent.transform:GetChild(i).gameObject:SetActive(false)
	end
end

--把池里的对象都销毁掉
function ItemPool:ClearPool()
	self.itemDic = {}
end

--获取该item的所有对象
function ItemPool:GetAll(key)
	return self.itemDic[key]
end



return ItemPool