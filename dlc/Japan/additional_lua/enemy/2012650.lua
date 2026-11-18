local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ダキ　チャレンジクエスト用", version=1.3, id=2012650});

function class:start(event)
	self.isHide = false;
    event.unit:setInvincibleTime(99999);
    event.unit:setSkillInvocationWeight(0);
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
	if event.spineEvent == "backEnd" then
		self.isHide = true;
	end

	if event.spineEvent == "hideEnd" then
		self:hideEnd(event.unit);
	end
	if event.spineEvent == "showEndTalk" then
        self:showEndTalk(event.unit);
    end
   return 1
end

function class:startWave(event)
	event.unit:setRange_Max(5000)
    event.unit:setRange_Min(0);
	return 1;
end

function class:hideEnd(unit)
	self.isHide = false;
	unit:takeAnimation(0,"inForSpecialQuest",false);
end

function class:update(event)
	if self.isHide then
        event.unit:setPosition(-10000,-10000);
        event.unit:getSkeleton():setPosition(0,0);--見た目上のズレも無くす
        event.unit._ignoreBorder = true;--アニメーションの更新があっても外に居られるようにする
    end
	return 1;
end


function class:takeAttack(event)
	if not self.isHide then
		event.unit:takeAnimation(0,"backForSpecialQuest",false);
	end
    return 0;
end

function class:takeSkill(event)
	if not self.isHide then
		event.unit:takeAnimation(0,"backForSpecialQuest",false);
	end
    return 0;
end

function class:showEndTalk(unit)
	for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        if target ~= nil and target ~= unit and target:getBaseID3() == 40002 and megast.Battle:getInstance():isHost() then
            target:callLuaMethod("showEndTalk",1.5);
        end
    end
end


class:publish();

return class;