local class = summoner.Bootstrap.createUnitClass({label="ラプレ", version=1.3, id=101855212});

--スキルを発動するとビットが出現する。２個ずつ出現し、上限８個（４段階）
--４段階目で奥義を発動するとビットに専用モーションを再生させて段階をリセット
--ビットは通常攻撃に付随する追撃を放つ　CT５秒
--これ以上ビットが増えない状態でスキルを使用するとビットは攻撃を行う

--スキル中にorbitSystemを生成するためビットに付与されるActiveSkillはスキル扱いとなる
--ビットが増えると追撃の威力が上がる。スキルにのみ効果が乗るバフの数値をいじって実現する

class.RECAST = 5;
class.EVOLUTION_LANK = 1;
class.BUFF_VALUE = 50;
class.SKILL_RATE = 400;

function class:start(event)
    self.gameUnit = event.unit;
    self.orbit = nil;
    self.bitRank = 0;
    self.gameUnit:setParameter("185_Bit",""..self.bitRank * 2)
    self.isFollow = false;
    self.coolTime = 0;
    
    return 1;
end

function class:update(event)
    self.coolTime = self.coolTime + event.deltaTime;
    if self.orbit ~= nil and self.isFollow then
        self.orbit:setPosition(event.unit:getAnimationPositionX(),event.unit:getAnimationPositionY()-60);
        self.orbit:getSkeleton():setPosition(0,0);
    end
    return 1;
end

function class:takeAttack(event)
    if self.orbit ~= nil and self.coolTime > self.RECAST then
        self.coolTime = 0;
        self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."a"..self.bitRank,true);
    end
    return 1
end

function class:run (event)
    if event.spineEvent == "addBit" then self:addBit(event.unit) end
    if event.spineEvent == "takeBitSkill" then self:takeBitSkill(event.unit) end
    if event.spineEvent == "takeBitSkill2" then self:takeBitSkill2(event.unit) end
    if event.spineEvent == "attackEnd" then self:attackEnd(event.unit) end
    if event.spineEvent == "skillEnd" then self:skillEnd(event.unit) end
    if event.spineEvent == "inEnd" then self:inEnd(event.unit) end
    if event.spineEvent == "outEnd" then self:outEnd(event.unit) end
    return 1;
end

function class:addBit(unit)
    if unit:isMyunit() or unit:getisPlayer() == false then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.bitRank);
        self:innerAddBit(unit,self.bitRank); 
    end
end

--ビットをしまってから再展開するという動きになるためこのメソッドでは仕舞ってカウンターを上げてバフをかけるだけ
--次のINアニメーションを再生する処理はoutアニメーション終了時にSpineから呼ばれるoutEndに任せている
function class:innerAddBit(unit,rank)
    self.bitRank = rank;
    self.gameUnit:setParameter("185_Bit",""..self.bitRank * 2)

    if self.orbit == nil then
        self.isFollow = true;
        local bit = self.gameUnit:addOrbitSystem(self.EVOLUTION_LANK.."in1",0)
        bit:setHitCountMax(9999999);
        bit:takeAnimation(0,self.EVOLUTION_LANK.."in1",true);
        self.orbit = bit;
        self.bitRank = 1;
        self.gameUnit:setParameter("185_Bit",""..self.bitRank * 2)
    else
        if self.bitRank >= 4 then
            self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."a"..self.bitRank,true);
            return;
        end
        self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."out"..self.bitRank,true);
        self.bitRank = self.bitRank + 1;
        self.gameUnit:setParameter("185_Bit",""..self.bitRank * 2)
    end
    local buff = unit:getTeamUnitCondition():addCondition(1,17,self.bitRank * self.BUFF_VALUE,999999,0);
    buff:setScriptID(76);
end

function class:takeBitSkill(unit)
    if self.bitRank < 4 then
        return;
    end
    self.isFollow = false;
    local buff = unit:getTeamUnitCondition():addCondition(1,17,self.SKILL_RATE,999999,0);
    buff:setScriptID(76);
    self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."max",true);
end

function class:takeBitSkill2(unit)
    if self.bitRank < 4 then
        return;
    end
    self.isFollow = false;
    local buff = unit:getTeamUnitCondition():addCondition(1,17,self.SKILL_RATE,999999,0);
    buff:setScriptID(76);
    self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."max2",true);
end

function class:attackEnd(unit)
    self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."idle"..self.bitRank,true);
end

function class:skillEnd(unit)
    self.orbit:takeAnimation(0,"hide",false);
    self.bitRank = 0;
    self.gameUnit:setParameter("185_Bit",""..self.bitRank * 2)
    self.orbit = nil;
end

function class:inEnd()
    self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."idle"..self.bitRank,true);
end

function class:outEnd()
    self.orbit:takeAnimation(0,self.EVOLUTION_LANK.."in"..self.bitRank,true);
end

function class:receive1(args)
    self:innerAddBit(self.gameUnit,args.arg);
    return 1;
end

class:publish();

return class;
