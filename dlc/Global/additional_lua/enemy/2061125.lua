local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="人族の遺跡_５階層_HARD_CODE XTF:ERASER", version=2.0, id=2061125});
class:inheritFromEnemy("2061120");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK4 = 50, ATTACK6 = 50 },
        { ATTACK5 = 50, ATTACK6 = 50 },
        { ATTACK4 = 50, ATTACK5 = 50, ATTACK6 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL4 = 50 },
        { SKILL5 = 50 }
    }
}

class.cutInSkill = {
    [7] = 1
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 20611251,
            BUFF_ID = 23,  --クリティカル耐性
            VALUE = self.GD.buffValue_23,
            DURATION = 9999999,
            ICON = 188
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "状態異常耐性：ブレイクで解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "燃焼・氷結状態のとき、被ダメージアップ", COLOR = Color.yellow})
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK1_MESSAGE1 or "ブレイク成功！状態異常耐性解除！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK2_MESSAGE2 or "ブレイク耐性アップ", COLOR = Color.yellow})
    }
    self.HP40_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP40_MESSAGE1 or "クリティカル耐性アップ", COLOR = Color.yellow})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
            used = false,
            isEnableSkip = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
            end
        end
    end
end

function class:hp40(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.cutInFLG = true
        self.hpSkill = 4
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(7)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self:showMessage(self.HP40_MESSAGE_LIST)
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 7
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 8,
        hitStop = 100,
        breakBadgeNum = 1,
        normalDmgRate = 0.05,
        burningDmgRate = 1,
        freezeDmgRate = 1,
        changeBuffValue = 0,
        breakDmgValue = 0.1,
        buffValue_23 = -100
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;
    self.cutInFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---ボスギミック
    self.lastSkillFLG = false
    self.breakInfoFlg = true
    self.buffIDTbl = { 59,60,108,109 }  --氷結耐性、氷結回避、燃焼耐性、燃焼回避
    event.unit:addNumBreakBadge(self.GD.breakBadgeNum)

    --- CODE XTF:ERASER 共有 ---
    --最初から攻撃モードのギミック
    self.mode = 1   --0=盾モード,1=攻撃モード
    ---ファンネルレーザー関係
    self.laserTable = {
        --[1] = event.unit:addOrbitSystem("funnelIdle",0),
        --[2] = event.unit:addOrbitSystem("funnelIdle",0),
        --[3] = event.unit:addOrbitSystem("funnelIdle",0),
        --[4] = event.unit:addOrbitSystem("funnelIdle",0),
        --[5] = event.unit:addOrbitSystem("funnelIdle",0)
    }
    for i,value in ipairs(self.laserTable) do
        --self.laserTable[i]:takeAnimation(0,"funnelIdle",true);
    end
    self.laserRad = 0
    self.attack2FLG = false
    self.targetUnit = event.unit:getTargetUnit()
    self.updateCount = 0

    --event.unit:setSetupAnimationNameEffect("setUpBarrier");
    event.unit:setSetupAnimationName("setUp2");  --setUp1=盾モード,setUp2=攻撃モード
    event.unit:setSkin("Nomal")

    ---アーム関係
    self.isArm = false
    ---ミサイル関係
    self.missiles = {}
    self.missileinfo = {
        new = function (_bullet,_targetUnit,_uniqueID)
            return {
                bullet = _bullet,
                targetUnit = _targetUnit,
                uniqueID = _uniqueID,
                frame = 0,
                angle = 0,
                posx = 0,
                posy = 0,
                speedkeisuu = 1,
                isPlayer = false
            }
        end
    }
    ---ボール関係
    self.balls = {}
    self.ballinfo = {
        new = function (_ball,_targetUnit,_uniqueID)
            return {
                bullet = _ball,
                targetUnit = _targetUnit,
                uniqueID = _uniqueID,
                frame = 0,
                angle = 0,
                posx = 0,
                posy = 0,
                speedkeisuu = 1,
                isPlayer = false
            }
        end
    }
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:hpTriggersCheck(event.unit)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[2].used then
            self.gameUnit:setInvincibleTime(10)
            if self.deadCount == nil then self.deadCount = 0 end
            self.deadCount = self.deadCount + event.deltaTime
            if self.deadCount >= 20 then
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end

    --- CODE XTF:ERASER 共有 ---
    self.updateCount = self.updateCount + 1
    if self.updateCount <= 50 then
        self.laserRad = self.laserRad + 3
    else
        self.laserRad = self.laserRad + 1
    end

    for i,value in ipairs(self.laserTable) do
        local rad = (360 / table.maxn(self.laserTable)) * i
        self:laserAngle(event.unit,self.laserTable[i],rad)
    end
    ---ボール
    if table.maxn(self.balls) > 0 then
        for i = 1,table.maxn(self.balls) do
            self:ballControll(self.balls[i]);
        end
    end
    ---アーム
    self:attack5ArmControll(event.unit);
    ---ミサイル
    if table.maxn(self.missiles) > 0 then
        for i = 1,table.maxn(self.missiles) do
            self:missileControll(self.missiles[i]);
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 4 and self.cutInFLG then
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index,1);
        return 0
    end

    if event.index == 7 then
        self.lastSkillFLG = true
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    --オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    if not self.breakInfoFlg then
        event.value = event.value * self.GD.breakDmgValue
    end
    return event.value
end


class:publish();

return class;