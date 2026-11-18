local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="闇リーゼ", version=2.0, id=103235512});

function class:start(event)
    self.magicCircle = self.magicCircle:new();
    self.magicCircle:init(event,self);
    return 1;
end

function class:startWave(event)
    self.magicCircle:startWave(event);
    return 1;
end

function class:endWave(event)
    self.magicCircle:endWave(event);
    return 1;
end

function class:takeSkill(event)
    self.magicCircle:takeSkill(event);
    return 1;
end

function class:run(event)
    self.magicCircle:run(event);
    return 1;
end

function class:update(event)
    self.magicCircle:update(event);
    return 1;
end

function class:dead(event)
    self.magicCircle:dead(event);
    return 1;
end

function class:changeOut(event)
    self.magicCircle:dead(event);
    return 1;
end

function class:receive3(args)
    self.magicCircle:receive3(args);
    return 1;
end

function class:receive4(args)
    self.magicCircle:receive4(args);
    return 1;
end

function class:receive5(args)
    self.magicCircle:receive5(args);
    return 1;
end


--===============================================================================================================================================
-- 魔法陣クラス
--===============================================================================================================================================

class.magicCircle = {}--[!]これは定義のための箱です！！[!] 
--これを直接使わないで！ start時にself.magicCircle:newしてから使ってね！


--バフかけ対象の列挙
class.magicCircle.targetType = {
    myself = 1,
    party = 2,
    enemys = 3
}



class.magicCircle.BUFF_ARGS = {
    [1] = {
        ID = 10323,
        BUFF_ID = 21,
        VALUE = 30,
        DURATION = 20,--定数みたいな顔をしていますがその時々で書き換えられます
        ICON = 139
    }
}

class.magicCircle.BUFF_ARGS_FOR_PLAYER = {
    [1] = {
        ID = 103230,
        BUFF_ID = 0,
        VALUE = 1,
        DURATION = 20,--定数みたいな顔をしていますがその時々で書き換えられます
        ICON = 0
    }
}



--バフをかける対象　上記の列挙から選択してね！
class.magicCircle.buffTarget = class.magicCircle.targetType.enemys;
class.magicCircle.SP = 30;


--＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝接続部＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

--【クッソ重要】　magicCircleの内部にアクセスする場合
--絶対にこのnew叩いてから使うこと。
--self.magicCircleクラスをローカルのもので上書きします。
--この手順を飛ばすと、闇リーゼが複数いたときに同じ実態を参照して混線するよ！
function class.magicCircle:new()
    local newInstance = {}
    for k,v in pairs(self) do
        newInstance[k] = self[k];
    end
    return newInstance;
end

function class.magicCircle:init(event,parentClass)
    self.parent = parentClass;
    self.parentUnit = event.unit;
    self.shotCount = 0;

    self.magicTimer = 0;
    self.isMagic = false;
    self.gameUnit = event.unit
    self.gameUnit:setParameter("323_Magic","0")

    self.shot1Orbit = nil;
    self.shot2Orbit = nil;
    self.shot3Orbit = nil;
    self.magicOrbit = nil;

    --バフIDでどのリーゼのバフなのかを判別するためにインデックスをつける。（IDのルール的には被らないが）他のバフとID被ったら知らぬ。
    self.BUFF_ARGS_FOR_PLAYER[1].ID = 103230 + event.unit:getIndex();
end

function class.magicCircle:startWave(event)
    self:cleanUp();
    return 1;
end

function class.magicCircle:endWave(event)
    self:cleanUp();
    return 1;
end

function class.magicCircle:takeSkill(event)
    if event.index == 1 and self.shotCount > 0 then
        event.unit:setNextAnimationName("skill1_"..(self.shotCount + 1));
        event.unit:setNextAnimationEffectName("skill1_"..(self.shotCount + 1));
    end
end

function class.magicCircle:run(event)
    if event.spineEvent == "shot1" then
        self:shot1(event.unit);
    end

    if event.spineEvent == "shot2" then
        self:shot2(event.unit);
    end

    if event.spineEvent == "shot3" then
        self:shot3(event.unit);
    end

    if event.spineEvent == "s1loop1" then
        self:s1Loop1(event.unit);
    end

    if event.spineEvent == "s1loop2" then
        self:s1Loop2(event.unit);
    end

    if event.spineEvent == "magic" then
        self:magic(event.unit);
    end

    if event.spineEvent == "magicLoop" then
        self:magicLoop(event.unit);
    end

    if event.spineEvent == "addSP" then
        self:addSP(event.unit);
    end

    if event.spineEvent == "hideMagic" then--他のリーゼから呼ばれる可能性がある　魔法陣を二つ以上重複させないため
        self:fromOther(event.unit);
        self:magicEnd();
    end
end

function class.magicCircle:update(event)
    self:countDown(event.deltaTime);
end

function class.magicCircle:receive3(args)
    self:setShotCount(args.arg);
    self:addShot(args.arg);
    return 1;
end

function class.magicCircle:receive4(args)
    self:startMagicCount();
    return 1;
end

function class.magicCircle:receive5(args)
    self:onDie(self.parentUnit);
    return 1;
end

--＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

function class.magicCircle:addSpecialBuff(unit)




    local targetParty = nil;
    


    targetParty = megast.Battle:getInstance():getTeam(not unit:getisPlayer());

    --まず敵側
    for i=0,7 do
        local targetUnit = targetParty:getTeamUnit(i);
        if targetUnit ~= nil and targetUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_ARGS[1].ID) == nil then
            self.BUFF_ARGS[1].DURATION = self.magicTimer;
            self.parent:addBuffs(targetUnit,self.BUFF_ARGS);
        end
    end

    --今度は味方側へ闇リーゼ真奥義確認用のバフをかけていく
    targetParty = megast.Battle:getInstance():getTeam(unit:getisPlayer());
    for i=0,7 do
        local targetUnit = targetParty:getTeamUnit(i);

        
        if targetUnit ~= nil and targetUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_ARGS_FOR_PLAYER[1].ID) == nil then
            self.BUFF_ARGS_FOR_PLAYER[1].DURATION = self.magicTimer;
            self.parent:addBuffs(targetUnit,self.BUFF_ARGS_FOR_PLAYER);
        end
    end
    
end

function class.magicCircle:shot1(unit)
    if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    if self:isControllTarget(unit) then
        self:setShotCount(1);
        self:addShot(1);
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,3,self.shotCount);
    end
end

function class.magicCircle:shot2(unit)
    if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    if self:isControllTarget(unit) then
        self:setShotCount(2);
        self:addShot(2);
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,3,self.shotCount);
    end
end

function class.magicCircle:shot3(unit)
    if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    if self:isControllTarget(unit) then
        self:setShotCount(3);
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,3,self.shotCount);
        self:addShot(3);
    end
end

function class.magicCircle:addShot(animationIndex)
    local orbit = self.parentUnit:addOrbitSystem("shot"..animationIndex,0);
    self["shot"..animationIndex.."Orbit"] = orbit;
    orbit:getSkeleton():setPosition(0,0);
    orbit:setPosition(0,0);
    if animationIndex == 3 then
        self.shot1Orbit:takeAnimation(0,"none",false);
        self.shot1Orbit = nil;
        self.shot2Orbit:takeAnimation(0,"none",false);
        self.shot2Orbit = nil;
        self.shotCount = 0;
    end
end

function class.magicCircle:s1Loop1(orbit)
    orbit:takeAnimation(0,"s1Loop1",true);
end

function class.magicCircle:s1Loop2(orbit)
    orbit:takeAnimation(0,"s1Loop2",true);
end

function class.magicCircle:magic(orbit)
    self:magicEnd();
    -- self:hideOtherMagicCircle();--魔法陣は複数出てもよくなったので不要になりました。

    self.magicOrbit = self.parentUnit:addOrbitSystem("magic",0);
    self.shot3Orbit:takeAnimation(0,"none",false);
    self.shot3Orbit = nil;
    self.magicOrbit:setPosition(0,0);
    self.magicOrbit:getSkeleton():setPosition(0,0);

    if self:isControllTarget(orbit:getParentTeamUnit()) then
        self:startMagicCount();
        megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,4,self.shotCount);
    end

end

function class.magicCircle:magicLoop(orbit)
    orbit:takeAnimation(0,"magicLoop",true);
end

function class.magicCircle:addSP(unit)
    if not self:buffCheck(unit) then
        return;
    end
    local targetParty = unit:getTeam();
    for i=0,7 do
        local targetUnit = targetParty:getTeamUnit(i);
        if targetUnit ~= nil then
            targetUnit:addSPWithPvpCorrection(self.SP);
        end
    end
end

function class.magicCircle:buffCheck(unit)
    for i=0,7 do
        local buff = unit:getTeamUnitCondition():findConditionWithID(103230 + i);

        if buff ~= nil and unit:getTeam():getTeamUnit(i) ~= nil then
            -- summoner.Utility.messageByPlayer("おまえは"..i);
            return true;
        end
    end
    return false;
end

function class.magicCircle:dead(event)
    if not self:isControllTarget(event.unit) then
        return;
    end

    megast.Battle:getInstance():sendEventToLua(self.parent.scriptID,5,0);
    self:onDie(event.unit);
    return 1;
end

function class.magicCircle:onDie(unit)
     --自分がかけたであろう魔法陣バフの削除

    local targetParty = nil;

    targetParty = megast.Battle:getInstance():getTeam(not unit:getisPlayer());

    --まず敵側
    for i=0,7 do
        local targetUnit = targetParty:getTeamUnit(i);
        if targetUnit ~= nil then
            local buff = targetUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_ARGS[1].ID);
            if buff ~= nil then
                targetUnit:getTeamUnitCondition():removeCondition(buff);
            end
        end
    end

    --次にプレイヤー側
    targetParty = megast.Battle:getInstance():getTeam(unit:getisPlayer());
    for i=0,7 do
        local targetUnit = targetParty:getTeamUnit(i);
        if targetUnit ~= nil then
            local buff = targetUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_ARGS_FOR_PLAYER[1].ID);
            if buff ~= nil then
                targetUnit:getTeamUnitCondition():removeCondition(buff);
            end
        end
    end
end

function class.magicCircle:startMagicCount()
    self.magicTimer = 20;
    self.isMagic = true;
    self.gameUnit:setParameter("323_Magic","1")
end


function class.magicCircle:setShotCount(count)
    self.shotCount = count;
end

function class.magicCircle:countDown(delta)
    if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    if not self.isMagic then
        return;
    end
    self.magicTimer = self.magicTimer - delta;
    if self.magicTimer > 1 then
        self:addSpecialBuff(self.parentUnit);
    end
    if self.magicTimer <= 0 then
        self:magicEnd();
        self.isMagic = false;
        self.gameUnit:setParameter("323_Magic","0")
    end
end

function class.magicCircle:cleanUp()
    self.shotCount = 0;

    self.magicTimer = 0;
    self.isMagic = false;
    self.gameUnit:setParameter("323_Magic","0")

    self:magicEnd();

    if self.shot1Orbit ~= nil then
        self.shot1Orbit:takeAnimation(0,"none",false);
        self.shot1Orbit = nil;
    end

    if self.shot2Orbit ~= nil then
        self.shot2Orbit:takeAnimation(0,"none",false);
        self.shot2Orbit = nil;
    end

    if self.shot3Orbit ~= nil then
        self.shot3Orbit:takeAnimation(0,"none",false);
        self.shot3Orbit = nil;
    end

    --自分がかけたであろう魔法陣バフの削除

    local targetParty = nil;


    --戦闘終了時の処理なので敵はいないはず。プレイヤー側だけ掃除
    targetParty = megast.Battle:getInstance():getTeam(self.parentUnit:getisPlayer());
    for i=0,7 do
        local targetUnit = targetParty:getTeamUnit(i);
        if targetUnit ~= nil then
            local buff = targetUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_ARGS_FOR_PLAYER[1].ID);
            if buff ~= nil then
                targetUnit:getTeamUnitCondition():removeCondition(buff);
            end
        end
    end

end

function class.magicCircle:hideOtherMagicCircle()
    for i = 0,4 do
        local target = megast.Battle:getInstance():getTeam(self.parentUnit:getisPlayer()):getTeamUnit(i);
        if target ~= nil and target ~= self.parentUnit and target:getBaseID3() == 323 then
            target:callLuaMethod("hideMagic",0.1);
        end
    end
end


function class.magicCircle:magicEnd()
    if self.magicOrbit ~= nil then
        self.magicOrbit:takeAnimation(0,"magicEnd",false);
        self.magicOrbit = nil;
    end
end

function class.magicCircle:fromOther(unit)--魔法陣は複数出てもいいように変更されたので不要になりました。
    -- --他のリーゼが魔法陣を貼ったので、自分のかけた判定用バフは消しちゃう（死亡時に問題が出ないよう）
    -- targetParty = megast.Battle:getInstance():getTeam(unit:getisPlayer());
    -- -- summoner.Utility.messageByPlayer("おまえは");
    -- for i=0,7 do
    --     local targetUnit = targetParty:getTeamUnit(i);
    --     if targetUnit ~= nil then
    --         local buff = targetUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_ARGS_FOR_PLAYER[1].ID);
    --         if buff ~= nil then
    --             targetUnit:getTeamUnitCondition():removeCondition(buff);
    --         end
    --     end
    -- end
    -- self.isMagic = false;
    -- self.magicTimer = 0;
end

function class.magicCircle:isControllTarget(unit)
    if unit:isMyunit() then
        return true;
    end
    if not unit:getisPlayer() then
        return megast.Battle:getInstance():isHost();
    end

end


--============================================================================================
--バフかけ周り（テンプレ）
--============================================================================================

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:execAddBuff(unit,v);
    end
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil then
            if cond:getPriority() > buffBox.PRIORITY then
                return;
            end
            --同一優先度で自分のバフよりも長時間持続するものには手を触れない
            if cond:getPriority() == buffBox.PRIORITY and cond:getTime() > buffBox.DURATION then
                return;
            end
            if buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION then
                unit:getTeamUnitCondition():removeCondition(cond);
            end
        end
        self:addConditionWithGroup(unit,buffBox);
        return;
    end

    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.SCRIPTVALUE2 ~= nil then
        buff:setValue2(buffBox.SCRIPTVALUE2);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end

end

--グループIDつきバフ
function class:addConditionWithGroup(unit,buffBox)
  
    local buff = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    buff:setGroupID(buffBox.GROUP_ID);
    buff:setPriority(buffBox.PRIORITY);
    if buffBox.SCRIPT ~= nil then
       buff:setScriptID(buffBox.SCRIPT)
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.SCRIPTVALUE2 ~= nil then
        buff:setValue2(buffBox.SCRIPTVALUE2);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end

end


class:publish();

return class;
