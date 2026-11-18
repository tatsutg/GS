--@additionalEnemy,600000122, 600000123, 600000124
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_Normal_大型シーリア", version=2.6, id=600000119});
class:inheritFromEnemy("600000121");

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 0001,
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
            ID = 60012110,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.GD.skillBuffVal_17_1,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 60012150,
        BUFF_ID = 21, -- 被ダメージ
        VALUE = self.GD.targetBuffVal_21,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 60012150,
        BUFF_ID = 0, -- 被ダメージ
        VALUE = 0,
        DURATION = 99999,
        ICON = 0
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 40,
        attackDelay = 10,
        hitStop = 100,

        tDmgVal = 0.5,

        buffTime_89 = 5,
        skillBuffVal_17_1 = 20,
        skillBuffVal_17_2 = 30,
        targetBuffVal_21 = 50,
        friendsDmgValTbl = {
            1,
            0.6,
            0.4,
            0.2,
            0.1,
            0.05,
            0.01
        }
    });
    self:dump(self.GD);

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
    self:showMessage(self.START_MESSAGE_LIST,1)
    self:showMessage(self.START_MESSAGE_LIST,5)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---召喚ギミック
    self.friendCount = 0;
    self.summonCountA = 0;  --竜牙兵召喚カウント
    self.summonCountB = 0;  --翼仰騎士エルザ召喚カウント
    self.summonCountC = 0;  --凶戦士ダラン召喚カウント
    self.summonIDA = 600000124;  --竜牙兵のEnemyID
    self.summonIDB = 600000123;  --翼仰騎士エルザのEnemyID
    self.summonIDC = 600000122;  --凶戦士ダランのEnemyID
    self:setSummonBuffBox();

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0);
    event.unit:setHateRate_Damage(0);
    self.targetUnitList = {};
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    self.targetUnitIndex = nil;

    ---ボスギミック
    self.friendsDmgValTbl = {};
    for i = 0,6 do
        self.friendsDmgValTbl[i] = self.GD.friendsDmgValTbl[i + 1];
    end

    --巨大シーリア
    self.gridIndex = nil;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    ---召喚ギミック
    self:findFriend();
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    return 1
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    ---男性ユニットからのダメージ軽減
    if enemyUnit:getSexuality() == 1 then
        event.value = event.value * self.GD.tDmgVal;
    end
    ---召喚ギミックダメージ補正
    self:findFriend();
    event.value = event.value * self.friendsDmgValTbl[self.friendCount];
    ---ターゲット処理
    if event.enemy:getIndex() == 4 then return event.value end
    ---ユニットのダメージをテーブルに格納
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
    if self.targetUnitList[index] == nil then
        table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value})
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
    end
    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        ---ヘイトは全部手動で設定する
        local target = self:checkTargetUnit()
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
        event.unit:setHateTarget(target)
        event.unit:updateHateTarget();
        ---ターゲットにバフ
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == target:getIndex() then
                    self.targetUnitIndex = target:getIndex();
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                end
            end
        end
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end



class:publish();

return class;