--@additionalEnemy,4000111
--[[
    神殿/冥蟲姫ラドアクネ/初級
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="冥蟲姫ラドアクネ", version=1.5, id=4000117})

--=====================================================================================================
--難易度で変わるもの
--=====================================================================================================

--バリアの耐久値
enemy.BARRIER_HP_DEFAULT = 30000;

--バリア時にかかるバフ内容
enemy.BUFF_ARGS = {
    {
        ID = 4000117,
        EFID = 31,         --回避率アップ
        VALUE = 50,        --回避率
        DURATION = 9999999,
        ICON = 16
    }
}

--怒り時にかかるバフ内容
enemy.RAGE_BUFF_ARGS = {
    {
        ID = 40001173,
        EFID = 17,         --ダメージアップ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 40001174,
        EFID = 28,         --速度アップ
        VALUE = 20,        --効果量
        DURATION = 9999999,
        ICON = 7,
        EFFECT = 50009
    }
}

--１度の召喚で呼ばれるユニットの最大数　１〜４で指定
enemy.SUMMON_CNT_MAX = 1;

--[召喚される敵のエネミーID] = 重み
enemy.ENEMYS = {
    [4000111] = 50,
    --[4000148] = 50,
    --[4000149] = 50,
    --[4000150] = 50,
    --[4000151] = 50
}

--バリア展開時のメッセージ
enemy.BARRIER_MESSAGES = {
    {
        MESSAGE = enemy.TEXT.BARRIER_MESSAGE1 or "no text",  --文言
        COLOR = Color:new(255, 165, 0),                               --色
        DURATION = 5                                        --メッセージが消えるまでの時間
    }
}

--怒り時のメッセージ
enemy.RAGE_MESSAGES = {
    {
        MESSAGE = enemy.TEXT.RAGE_MESSAGE1 or "no text",
        COLOR = Color.red,
        DURATION = 5
    }
}

--奥義メッセージ１
enemy.SKILL_MESSAGES = {
    {
        MESSAGE = enemy.TEXT.SKILL_MESSAGE or "no text",
        COLOR = Color.yellow,
        DURATION = 3
    }
}

--奥義メッセージ2
enemy.SKILL_MESSAGES2 = {
    {
        MESSAGE = enemy.TEXT.SKILL_MESSAGE2 or "no text",
        COLOR = Color.magenta,
        DURATION = 3
    }
}

--=====================================================================================================
--攻撃分岐の確率
--=====================================================================================================

--使用する通常攻撃とその確率 [アニメーションの番号] = 重み
enemy.ATTACK_WEIGHTS = {
    --[1] = 5,   --突き
    [2] = 25,   --衝撃波
    [3] = 10,   --切り上げ
    [4] = 15,   --落雷
    [5] = 25,   --３連突き（闇）
    [6] = 25,   --３連突き（光）
    --[8] = 150    --バリア展開
}

--使用する奥義とその確率　[アニメーションの番号] = 重み　skill2は今回は不使用
enemy.SKILL_WEIGHTS = {
    [1] = 50,
    [3] = 50,
}

--攻撃や奥義に設定されるスキルの番号
enemy.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK8 = 7,
    SKILL1 = 8,
    SKILL3 = 10,
}

enemy.ATTACK_BUFFID = {
    93430800,
    93431000,
    83430200,
    83430500,
    83430600
}
--=====================================================================================================

function enemy:start(event)
    event.unit:setSPGainValue(0);
    self.spRizeValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.gameUnit = event.unit;
    self.barrier = nil;
    self.barrierHP = 0;
    self.barrierPreparation = false;
    self.isRage = false;

    --バリアの耐久表示用サブゲージ
    self.subBar = self:createSubBar(event.unit);

    self.hpMarkers = {
        [80] = self.gameUnit:addNumHpMarker(0.8),
        [50] = self.gameUnit:addNumHpMarker(0.5),
        [30] = self.gameUnit:addNumHpMarker(0.3)
    }
    self.HP_TRIGGERS = {
        [80] = "addBarrier",
        [50] = "addBarrier",
        [30] = "getRage"
    }

    return 1;
end

function enemy:update(event)
    self:barrierUpdate(event.unit);
    self:subBarControll(event.unit);
    self:HPTriggersCheck(event.unit);
    return 1;
end

function enemy:takeDamageValue(event)
    self:subBarControll(event.unit);

    if self:getIsBarrier() then
        self:reduceBarrier(event.unit,event.value);
        return 0;
    end

    return event.value;
end

function enemy:takeBreakeDamageValue(event)
    if self:getIsBarrier() then
        return 0;
    end
    return event.value;
end

function enemy:excuteAction(event)
    self:removeAttackBuff(event.unit);
    return 1;
end

function enemy:takeIdle(event)
    --バリア展開中と通常時でidleモーションを変える
    if self:getIsBarrier() then
        event.unit:setNextAnimationName("idle1");
    else
        event.unit:setNextAnimationName("idle2");
    end
    return 1;
end


function enemy:dead(event)
    self:creanUpEnemy(event.unit);
    return 1;
end


--===================================================================================================================
--通常攻撃分岐//
--///////////

--攻撃分岐の判断です。ホストだけで行います。
--バリアは今は何も考えずにランダムで出しています。必要であればここを書き換えてください。
function enemy:attackBranch(unit)
    local attackIndex = Random.sampleWeighted(self.ATTACK_WEIGHTS);
    if self.barrierPreparation then
        attackIndex = 8;
    end
    --バリア展開中にバリア展開攻撃が選択されたら代わりにattack6を出す
    if self:getIsBarrier() and attackIndex == 8 then
        attackIndex = 6;
    end
    unit:takeAttack(attackIndex);
    return 0;
end

function enemy:takeAttack(event)
    if not self.attackCheckFlg and self:getIsHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function enemy:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["ATTACK"..index]);
end

--===================================================================================================================
--スキル分岐//
--//////////

function enemy:skillBranch(unit)
    local skillIndex = Random.sampleWeighted(self.SKILL_WEIGHTS);
    unit:takeSkill(skillIndex)
    return 0;
end

function enemy:takeSkill(event)
    if not self.skillCheckFlg and self:getIsHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    self:removeAttackBuff(event.unit);
    self.skillCheckFlg = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    event.unit:setBurstState(kBurstState_active);--ゲスト側のステートが変わらない問題の対策

    --今はとりあえず何も考えずに奥義の時に蟲召喚する
    self:summon(event.unit);
    return 1
end

function enemy:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end
--===================================================================================================================


function enemy:run (event)
    if event.spineEvent == "addSP" then 
        self:addSP(event.unit) 
    end
    if event.spineEvent == "barrier" and self.getIsHost() then
        self:addBarrier(event.unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
    end
    if event.spineEvent == "showSkillMessage1" then 
        self:showMessages(unit,self.SKILL_MESSAGES);
    end
    if event.spineEvent == "showSkillMessage2" then 
        self:showMessages(unit,self.SKILL_MESSAGES2);
    end
    return 1;
end

function enemy:addSP(unit)
    if self.getIsHost() then
        unit:addSP(self.spRizeValue);
    end
    return 1;
end

--===================================================================================================================
--バリア関係

function enemy:addBarrier(unit)
    self.barrier = unit:addOrbitSystem("wallloop",0);
    self.barrier:takeAnimation(0,"wallloop",true);
    self.barrierPreparation = false;
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    self.barrier:setPosition(x,y);

    self.barrierHP = self.BARRIER_HP_DEFAULT;

    for k,v in pairs(self.BUFF_ARGS) do
        self:addBuff(unit,v);
    end
    self:showMessages(unit,self.BARRIER_MESSAGES);
end

function enemy:addBuff(unit,args)
    if args.EFFECT ~= nil then
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
end

function enemy:reduceBarrier(unit,damage)
    if self.barrierHP > 0 then
        self.barrierHP = self.barrierHP - damage;

        if self.barrierHP <= 0 and self:getIsHost() then
            self:removeBarrier(unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
        end

    end
end

function enemy:barrierUpdate(unit)
    if self:getIsBarrier() then
        if self.barrier ~= nil then
            self.barrier:setPosition(unit:getPositionX(),unit:getPositionY());
        end
        unit:setReduceHitStop(2, 1);--ヒットストップ無効Lv2（メリア以外のヒットストップを受けない）　減衰量１００％
    else
        unit:setReduceHitStop(2, 0.7)
    end
end

function enemy:removeBarrier(unit)
    self.barrier:takeAnimation(0,"wallBreak",false);

    self.barrier = nil;
    self.barrierHP = 0;

    for k,v in pairs(self.BUFF_ARGS) do
        Utility.removeUnitBuffByID(unit,v.ID);
    end
    

    unit:takeDamage();
end

function enemy:getIsBarrier()
    return self.barrierHP > 0;
end

function enemy:createSubBar()
    local bar = BattleControl:get():createSubBar();

    bar:setWidth(350); --バーの全体の長さを指定
    bar:setHeight(17);
    bar:setPercent(0); --バーの残量を0%に指定
    bar:setVisible(false);
    bar:setPositionX(-210);
    bar:setPositionY(150);

    return bar;
end


function enemy:subBarControll(unit)
    unit:setParameter("extraHpNow",""..self.barrierHP)
    unit:setParameter("extraHpMax",""..self.BARRIER_HP_DEFAULT)
    
    if self.subBar == nil then
        return;
    end

    if self.barrierHP > 0 then
        self.subBar:setVisible(true);
        self.subBar:setPercent(100 * self.barrierHP/self.BARRIER_HP_DEFAULT);
    else
        self.subBar:setVisible(false);
    end
end

--===================================================================================================================
function enemy:removeAttackBuff(unit)
    for k,v in pairs(self.ATTACK_BUFFID) do
        Utility.removeUnitBuffByID(unit,v);
    end
end
--===================================================================================================================
--HPトリガー
function enemy:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do

        if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
            if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
                self.gameUnit:removeHpMarker(self.hpMarkers[i])
                self.HP_TRIGGERS[i] = nil;
                megast.Battle:getInstance():sendEventToLua(self.scriptID,4,i);
            end
        end
    end

end

function enemy:excuteTrigger(unit,trigger)
    if trigger == "addBarrier" and not (self:getIsBarrier() or self.barrierPreparation) then
        self.barrierPreparation = true;
        return true;
    elseif trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    return false;
end

function enemy:receive4(args)
    self.gameUnit:removeHpMarker(self.hpMarkers[args.arg])
    return 1;
end

--===================================================================================================================
--怒り関係

function enemy:getRage(unit)
    self:addRageBuff(unit);
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES);
end

function enemy:addRageBuff(unit)
    for i, v in ipairs(self.RAGE_BUFF_ARGS) do
        self:addBuff(unit, v);
    end
end

--===================================================================================================================

function enemy:summon(unit)
    if not self:getIsHost() then
        return;
    end

    local cnt = 0;
    for i = 0, 4 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local enemyID = Random.sampleWeighted(self.ENEMYS);
             unit:getTeam():addUnit(i,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
             cnt = cnt + 1; 
             if cnt >= self.SUMMON_CNT_MAX then
                break;
             end
        end
    end
end

function enemy:creanUpEnemy(unit)
    for i = 0, 5 do
        local enemy = unit:getTeam():getTeamUnit(i,true);--無敵や出現中でも殺せるように第二引数はtrue
        if enemy ~= nil then
            enemy:setHP(0);
        end
    end
end 

--===================================================================================================================
function enemy:showMessages(unit, messages)
    for i, v in ipairs(messages) do
        Utility.messageByEnemy(v.MESSAGE, v.DURATION, v.COLOR);
    end
end

--===================================================================================================================

function enemy:receive1(args)
    self:addBarrier(self.gameUnit);
    return 1;
end

function enemy:receive2(args)
    self:removeBarrier(self.gameUnit);
    return 1;
end

function enemy:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end


function enemy:getIsHost()
    return megast.Battle:getInstance():isHost();
end


enemy:publish()
return enemy
