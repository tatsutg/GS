--@additionalItem,160052503
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超新星級_NORMAL_オルデウス・絶", version=2.7, id=4002401});
class:inheritFromEnemy("4002402");


--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 400241,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
            ICON = 0,
            --COUNT = 0,
            --MAX = 10
        }
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 4002410,
            BUFF_ID = 13,  --攻撃力
            VALUE = self.GD.skillBuffVal_13,
            DURATION = 999999,
            ICON = 4,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 4002411,
            BUFF_ID = 0,  --奥義発動カウント表示用
            VALUE = 0,
            DURATION = 999999,
            ICON = self.GD.skillCountIcon,
            COUNT = 0,
            MAX = 99
        }
    }
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 4002430,
            BUFF_ID = 22,   --クリティカル率
            VALUE = self.GD.hpBuffVal_22,
            DURATION = 999999,
            ICON = 11
        },
        [2] = {
            ID = 4002440,
            BUFF_ID = 142,   --スーパークリティカル率
            VALUE = self.GD.hpBuffVal_142,
            DURATION = 999999,
            ICON = 229
        },
        [3] = {
            ID = 4002450,
            BUFF_ID = 23,  --クリティカル耐性
            VALUE = self.GD.hpBuffValue_23,
            DURATION = 999999,
            ICON = 188
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "HP自然回復キラー", COLOR = Color.yellow})
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "クリティカル率アップ", COLOR = Color.yellow})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "スーパークリティカル率アップ", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "クリティカル耐性・奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.ITEM_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ITEM_MESSAGE1 or "闇のオーラ：奥義ゲージ・呪い耐性低下", COLOR = Color.magenta, isPlayer = true})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "%dの固定ダメージ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE2 or "呪い状態ユニットの攻撃力ダウン", COLOR = Color.red})
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        hp0AddSP = 40,
        startAddSP = 0,
        attackDelay = 6,
        hitStop = 100,

        tgTimerB = 22,
        tgLimitB = 99,
        tgIconNum1B = 74,
        tgIconNum2B = 0,
        tgPosXB = 50,
        tgPosYB = 0,
        tgScaleB = 1,

        hp0SetHpRate = 0.5,
        skillFixDmg = 5000,
        skillCutDmg = 1000,
        skillCountIcon = 181,

        skill2OrbitHP = 500000,

        skillBuffVal_13 = -20,
        hpBuffVal_22 = 50,
        hpBuffVal_142 = 20,
        hpBuffValue_23 = -200
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
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

    -- 経過時間ギミック
    self.breakFlg = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndexB = nil;

    ---装備ギミック
    self.itemFlg = false;
    self.itemId = 160052503;  --Normal
    self.item = event.unit:setItemSkill(0,self.itemId);

    ---ボスギミック
    self.setBossHP = event.unit:getCalcHPMAX() * self.GD.hp0SetHpRate;
    self.skill3Count = 0;

    --葬魂神オルデウスの共有ギミック
    self:setConsts();
    self.consts.skill3FixedDamage = self.GD.skillFixDmg;
    self.bullets = {};
    self.bulletInfo = {
        new = function (_bullet,_targetUnit,_uniqueID)
            return {
                bullet = _bullet,
                targetUnit = _targetUnit,
                uniqueID = _uniqueID,
                frame = 0,
                angle = 0,
                posx = 0,
                posy = 0,
                speedkeisuu = 1
            };
        end
    };
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    if self.timeIndexB ~= nil then
        self:extraTimerBOperation(event.unit);
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    --装備ギミック
    if self.itemFlg and self:attackCheck(event.unit) then
        self.itemFlg = false;
        self:useItem(event.unit,0);
    end

    --葬魂神オルデウスの共有ギミック
    --壊魂振動
    if table.maxn(self.bullets) > 0 then
        for i = 1,table.maxn(self.bullets) do
            self:bulletControll(self.bullets[i],event.deltaTime);
        end
    end
    --滅魂宿世
    self.setDeltaTime = event.deltaTime;
    if self.fadeOutFlag then
        self:fadeOutUpdate(self.setDeltaTime);
    elseif self.targetFadeInFlag then
        self:fadeInTargetUpdate(self.setDeltaTime);
    elseif self.fadeInFlag then
        self:fadeInUpdate(self.setDeltaTime);
    end
    return 1;
end

function class:useItem(unit,index)
    unit:takeItemSkill(index);
    self.item:setCoolTimer(0);
    self:showMessage(self.ITEM_MESSAGE_LIST);
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == self.timeIndexB then
        self.itemFlg = true;
    end
    return event.count;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false;
        return 0;
    end
    --オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    return event.value;
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01;
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0;
        end
    end
    self.breakFlg = true;
    self.breakFlgB = true;
    return 1;
end



class:publish();

return class;