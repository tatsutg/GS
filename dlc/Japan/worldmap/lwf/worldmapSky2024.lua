if not LWF then LWF={} end
if not LWF.Script then LWF.Script={} end
if not LWF.Script.worldmapSky2024 then LWF.Script.worldmapSky2024={} end

LWF.Script.worldmapSky2024._root_0_1 = function(self)
	local _root = self.lwf._root

	if isRewind == nil then
		isRewind = false;
	end
	if rate == nil then
		rate = 70;
	end
	if not isRewind then
		count = -1;
	end
	isRewind = false
end

LWF.Script.worldmapSky2024._root_1499_1 = function(self)
	local _root = self.lwf._root

	count = count + 1;
	if count % 2 == 1 and count > 0 then
		if math.random(100) <= rate then
			count = -2;
			self.SSM:gotoAndPlay("20seconds");
		end
	end
end

LWF.Script.worldmapSky2024._root_2699_1 = function(self)
	local _root = self.lwf._root

	count = count + 1;
	if count % 2 == 1 and count > 0 then
		if math.random(100) <= rate then
			count = -2;
			self.SSM:gotoAndPlay("20seconds");
		end
	end
end

LWF.Script.worldmapSky2024._root_299_1 = function(self)
	local _root = self.lwf._root

	count = count + 1;
	if count % 2 == 1 and count > 0 then
		if math.random(100) <= rate then
			count = -2;
			self.SSM:gotoAndPlay("20seconds");
		end
	end
end

LWF.Script.worldmapSky2024._root_3599_1 = function(self)
	local _root = self.lwf._root

	isRewind = true;
end

LWF.Script.worldmapSky2024.symbol_space_move_0_1 = function(self)
	local _root = self.lwf._root

	self:stop();
end

LWF.Script.worldmapSky2024.symbol_space_move_1919_1 = function(self)
	local _root = self.lwf._root

	self:stop();
end

LWF.Script.worldmapSky2024.symbol_space_move_689_1 = function(self)
	local _root = self.lwf._root

	self:stop();
end
