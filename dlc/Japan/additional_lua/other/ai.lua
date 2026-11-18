--[[ユニットの行動判定ロジック群
    返し値に使用対象のインデックスを返す。
    −１の場合は使用しない。
  ]]

--[[0:ユニット自身が使用]]
function ai_0(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    return unit:getIndex();
end

--[[101:ユニット自身が使用]]
function ai_101(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    return unit:getIndex();
end

--[[102:ユニット自身のHPが４０％未満まで減少した時、自身に使用]]
function ai_102(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    if unit:getHPPercent() < 0.4 then
        return unit:getIndex();
    end
    return -1;
end

--[[103:ユニット自身のHPが6０％未満まで減少した時、自身に使用]]
function ai_103(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    if unit:getHPPercent() < 0.6 then
        return unit:getIndex();
    end
    return -1;
end

--[[104:ユニット自身のHPが7０％未満まで減少した時、自身に使用]]
function ai_104(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    if unit:getHPPercent() < 0.7 then
        return unit:getIndex();
    end
    return -1;
end

--[[ユニット自身が何らかの状態異常にかかっている場合]]
function ai_105(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end

    if ai_106(teamAI,unit) == -1 then
    elseif ai_107(teamAI,unit) == -1 then
    elseif ai_108(teamAI,unit) == -1 then
    elseif ai_109(teamAI,unit) == -1 then
    elseif ai_111(teamAI,unit) == -1 then
    elseif ai_112(teamAI,unit) == -1 then
    else
        return -1;
    end
    return unit:getIndex();
end

--[[ユニット自身が（毒）にかかっている場合、自身に使用]]
function ai_106(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local cond = unit:getTeamUnitCondition():findConditionWithID(90);
    if cond ~= nil then
       return unit:getIndex();
    end
    return -1;
end

--[[ユニット自身が（麻痺）にかかっている場合、自身に使用]]
function ai_107(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local cond = unit:getTeamUnitCondition():findConditionWithID(91);
    if cond ~= nil then
       return unit:getIndex();
    end
    return -1;
end

--[[ユニット自身が（沈黙）にかかっている場合、自身に使用]]
function ai_108(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local cond = unit:getTeamUnitCondition():findConditionWithID(92);
    if cond ~= nil then
       return unit:getIndex();
    end
    return -1;
end

--[[ユニット自身が（暗闇）にかかっている場合、自身に使用]]
function ai_109(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local cond = unit:getTeamUnitCondition():findConditionWithID(93);
    if cond ~= nil then
       return unit:getIndex();
    end
    return -1;
end

--[[ユニット自身が（呪い）にかかっている場合、自身に使用]]
function ai_110(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local cond = unit:getTeamUnitCondition():findConditionWithID(95);
    if cond ~= nil then
       return unit:getIndex();
    end
    return -1;
end

--[[ユニット自身が（燃焼）にかかっている場合、自身に使用]]
function ai_111(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local cond = unit:getTeamUnitCondition():findConditionWithID(97);
    if cond ~= nil then
       return unit:getIndex();
    end
    return -1;
end

--[[ユニット自身が（氷結）にかかっている場合、自身に使用]]
function ai_112(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local cond = unit:getTeamUnitCondition():findConditionWithID(96);
    if cond ~= nil then
       return unit:getIndex();
    end
    return -1;
end

--[[対戦相手ユニットの物理攻撃スキル・奥義が発動状態にある時（物理攻撃防御・回復系）]]
function ai_113(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getRivalTeam():getTeamUnit(i);
        if target ~= nil then
            local skill = target:getActiveBattleSkill();
            if skill ~= nil then
                return -1;
            end
            
            if skill:getAttributeType() == 1
            and (skill:getSkillType() == kSkillType_skill or skill:getSkillType() == kSkillType_burst) then
                return unit:getIndex();
            end
        end
    end
    return -1;
end

--[[対戦相手ユニットの魔法攻撃スキル・奥義が発動状態にある時（魔法攻撃防御・回復系）]]
function ai_114(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getRivalTeam():getTeamUnit(i);
        if target ~= nil then
            local skill = target:getActiveBattleSkill();
            if skill ~= nil then
            if skill:getAttributeType() == 2
            and (skill:getSkillType() == kSkillType_skill or skill:getSkillType() == kSkillType_burst) then

                return unit:getIndex();
            end
            end
        end
    end
    return -1;
end

--[[対戦相手ユニットの物理攻撃アイテムが発動状態にある時（物理攻撃防御・回復系）]]
function ai_115(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getRivalTeam():getTeamUnit(i);
        if target ~= nil then
            local skill = target:getActiveBattleSkill();
            if skill ~= nil then
                return -1;
            end
            if skill:getAttributeType() == 1
            and skill:getSkillType() == kSkillType_item then
                return unit:getIndex();
            end
        end
    end
    return -1;
end

--[[対戦相手ユニットの魔法攻撃アイテムが発動状態にある時（魔法攻撃防御・回復系）]]
function ai_116(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getRivalTeam():getTeamUnit(i);
        if target ~= nil then
            local skill = target:getActiveBattleSkill();
            if skill ~= nil then
                return -1;
            end
            if skill:getAttributeType() == 2
            and skill:getSkillType() == kSkillType_item then
                return unit:getIndex();
            end
        end
    end
    return -1;
end

--[[対戦相手側に対して明らかに不利属性の自身ユニットに対して（防御系）]]
function ai_117(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getRivalTeam():getTeamUnit(i);
        if target ~= nil then
           local rate = BattleUtilities.getElementalRate(unit:getElementType(), unit:getElementType());
           if rate < 1 then
               return unit:getIndex();
           end
        end
    end
    return -1;
end

--[[ユニット自身がスキル発動中]]
function ai_118(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    if unit:getUnitState() == kUnitState_skill and unit:getBurstState() == kBurstState_none then
        return unit:getIndex();
    end
    return -1;
end

--[[ユニット自身が奥義発動中]]
function ai_119(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    if unit:getBurstState() == kBurstState_active then
        return unit:getIndex();
    end
    return -1;
end

--[[１０秒以上経過]]
function ai_120(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    if BattleControl:get():getTime() > 10 then
        return unit:getIndex();
    end
    return -1;
end

--[[２０秒以上経過]]
function ai_121(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    if BattleControl:get():getTime() > 20 then
        return unit:getIndex();
    end
    return -1;
end

--[[３０秒以上経過]]
function ai_122(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    if BattleControl:get():getTime() > 30 then
        return unit:getIndex();
    end
    return -1;
end

--[[４０秒以上経過]]
function ai_123(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    if BattleControl:get():getTime() > 40 then
        return unit:getIndex();
    end
    return -1;
end


--[[201:ユニット自身or仲間ユニットへ使用(ランダム)]]
function ai_201(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
       local target = teamAI:getTeam():getTeamUnit(i);
       if target ~= nil then
       local index = add_201(teamAI, target);
       if index ~= -1 then
           return index;
       end
       end
    end
    return -1;
end

--ランダム取得
function add_201(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local rand = LuaUtilities.rand(0,4);
    local target = teamAI:getTeam():getTeamUnit(rand);
    if target ~= nil then
       return target:getIndex();
    end
    return -1;
end

--[[202:ユニット自身or仲間ユニットのHPが４０％未満まで減少した時、自身or仲間ユニットに使用（大回復系等）]]
function ai_202(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local index = -1;
    local percent = 1;
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then
        p = target:getHPPercent();
        if p < 0.4 then
            if percent > p then
                percent = p;
                index = target:getIndex();
            end
        end
        end
    end

    return index;
end


--[[203:ユニット自身or仲間ユニットのHPが６０％未満まで減少した時、自身or仲間ユニットに使用（大回復系等）]]
function ai_203(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local index = -1;
    local percent = 1;
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then
        p = target:getHPPercent();
        if p < 0.6 then
            if percent > p then
                percent = p;
                index = target:getIndex();
            end
        end
        end
    end

    return index;
end

--[[204:ユニット自身or仲間ユニットのHPが７０％未満まで減少した時、自身or仲間ユニットに使用（大回復系等）]]
function ai_204(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local index = -1;
    local percent = 1;
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then
        p = target:getHPPercent();
        if p < 0.7 then
            if percent > p then
                percent = p;
                index = target:getIndex();
            end
        end
        end
    end

    return index;
end

--[[ユニット自身or仲間ユニットが何らかの状態異常にかかっている場合、自身or仲間ユニットに使用]]
function ai_205(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local index = -1;
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
    if target ~= nil then 
    index = ai_106(teamAI,target);
    if index ~= -1 then
        return index;
    end
    
    index = ai_107(teamAI, target);
    if index ~= -1 then
        return index;
    end
    
    index = ai_108(teamAI, target);
    if index ~= -1 then
        return index;
    end
    
    index = ai_109(teamAI, target);
    if index ~= -1 then
        return index;
    end
    
    index = ai_110(teamAI, target);
    if index ~= -1 then
        return index;
    end
    
    index = ai_111(teamAI, target);
    if index ~= -1 then
        return index;
    end
    
    index = ai_112(teamAI, target);
    if index ~= -1 then
        return index;
    end
    end
    end

    return -1;
end

--[[ユニット自身or仲間ユニットが（毒）にかかっている場合、自身or仲間ユニットに使用]]
function ai_206(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
if target ~= nil then 
    local cond = target:getTeamUnitCondition():findConditionWithID(90);
    if cond ~= nil then
        if cond._time > 3 then
           return target:getIndex();
        end
    end
    end
    end
    return -1;
end

--[[ユニット自身が（麻痺）にかかっている場合、自身に使用]]
function ai_207(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then 
    local cond = target:getTeamUnitCondition():findConditionWithID(91);
    if cond ~= nil then
       return target:getIndex();
    end
    end
    end
    return -1;
end

--[[ユニット自身が（沈黙）にかかっている場合、自身に使用]]
function ai_208(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then 
    local cond = target:getTeamUnitCondition():findConditionWithID(92);
    if cond ~= nil then
       return target:getIndex();
    end
    end
    end
    return -1;
end

--[[ユニット自身が（暗闇）にかかっている場合、自身に使用]]
function ai_209(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then 
    local cond = target:getTeamUnitCondition():findConditionWithID(93);
    if cond ~= nil then
       return target:getIndex();
    end
    end
    end
    return -1;
end

--[[ユニット自身が（呪い）にかかっている場合、自身に使用]]
function ai_210(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then 
    local cond = target:getTeamUnitCondition():findConditionWithID(95);
    if cond ~= nil then
       return target:getIndex();
    end
    end
    end
    return -1;
end

--[[ユニット自身が（燃焼）にかかっている場合、自身に使用]]
function ai_211(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then 
    local cond = target:getTeamUnitCondition():findConditionWithID(97);
    if cond ~= nil then
       return target:getIndex();
    end
    end
    end
    return -1;
end

--[[ユニット自身が（氷結）にかかっている場合、自身に使用]]
function ai_212(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then 
        local cond = target:getTeamUnitCondition():findConditionWithID(96);
        if cond ~= nil then
           return target:getIndex();
        end
        end
    end
    return -1;
end

--[[ユニット自身or仲間ユニットがユニット自身がスキル発動時]]
function ai_213(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then
        if target:getUnitState() == kUnitState_skill and target:getBurstState() == kBurstState_none then
           return target:getIndex();
        end
        end
    end
    return -1;
end

--[[ユニット自身or仲間ユニットがユニット自身が奥義発動時]]
function ai_214(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then
        if target:getBurstState() == kBurstState_active then
           return target:getIndex();
        end
        end
    end
    return -1;
end

--[[対戦相手ユニットが攻撃系のスキル・アイテム・奥義発動時]]
function ai_215(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getRivalTeam():getTeamUnit(i);
        if target ~= nil then
        local skill = target:getActiveBattleSkill();
        if skill ~= nil then
        if skill:getDamageRate() > 0 then
               return unit:getIndex();
        end
        end
        end
    end
    return -1;
end

--[[ユニット自身or仲間ユニットが攻撃系のスキル・アイテム・奥義発動時]]
function ai_216(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then
        local skill = target:getActiveBattleSkill();
        if skill ~= nil then
        if skill:getDamageRate() > 0 then
               return target:getIndex();
        end
        end
        end
    end
    return -1;
end

--[[ユニット自身or仲間ユニットが（病気）にかかっている場合、自身or仲間ユニットに使用         ]]
function ai_217(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    for i = 0, 6 do
        local target = teamAI:getTeam():getTeamUnit(i);
        if target ~= nil then
        local cond = target:getTeamUnitCondition():findConditionWithID(94);
        if cond ~= nil then
           return target:getIndex();
        end
        end
    end
    return -1;
end


--[[218:自身or仲間or倒れたユニットのHPが3０％未満まで減少した時使用]]
function ai_218(teamAI,unit)
    if not unit:isMyunit() and unit:getisPlayer() then
        return -1;
    end
    
    local index = -1;
    local percent = 1;
    for i = 0, 4 do
        local target = teamAI:getTeam():getTeamUnit(i,true);
        if target ~= nil then
        p = target:getHPPercent();
        if p < 0.3 then
            if percent > p then
                percent = p;
                index = target:getIndex();
            end
        end
        end
    end

    return index;
end
