--@additionalEnemy,600000125, 600000126, 600000127
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_Hard_大型シーリア", version=2.6, id=600000120});
class:inheritFromEnemy("600000121");


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        startAddSP = 50,
        attackDelay = 8,
        hitStop = 100,

        atk4TDmgVal = 0.05,
        tDmgVal = 0.5,
        subBarHP = 1000000,

        buffTime_89 = 5,
        skillBuffVal_17_1 = 20,
        skillBuffVal_17_2 = 30,
        targetBuffVal_13 = -30,
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
    self:showMessage(self.START_MESSAGE_LIST,2)
    self:showMessage(self.START_MESSAGE_LIST,3)
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
    self.summonIDA = 600000127;  --竜牙兵のEnemyID
    self.summonIDB = 600000126;  --翼仰騎士エルザのEnemyID
    self.summonIDC = 600000125;  --凶戦士ダランのEnemyID
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

    ---サブHPギミック
    self.subBarFlg = true;
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = self.GD.subBarHP;---サブバーのHP
    self.damage = 0;---サブバー表示時のダメージ
    self.attack4Flg = false;

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
    ---単体突き刺し時
    if megast.Battle:getInstance():isHost() then
        self:updateGlab(event.unit,event.deltaTime);
    end
    ---召喚ギミック
    self:findFriend();
    ---attack4発動中か確認
    if self.attack4Flg and not event.unit:isBreak() and event.unit:getUnitState() ~= kUnitState_skill then
        self.attack4Flg = false;
        self.subBarFlg = true;
        self.damage = 0;
    end
    ---サブバーギミック
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    return 1
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    --summoner.Utility.messageByEnemy(self.SUB_HP - damage);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        if not unit:isBreak() and unit:getUnitState() ~= kUnitState_skill then
            self.subBarFlg = false;
            self.subBar:setVisible(false);
            self.hpSkill = 4;
            unit:addSP(100);
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "glabStart" then return self:tryGlab(); end
    if event.spineEvent == "glabEnd" then return self:glabEnd(); end
    return 1;
end

function class:tryGlab()
    if not self:getIsHost() then
        return 1;
    end

    self.gridIndex = self:checkTarget();
    if self.gridIndex ~= nil then
        self:targetUnitStan(self.gridIndex);
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,8,self.gridIndex);
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.gridIndex);
    end
    return 1;
end

function class:glabEnd()
    if self.gridIndex == nil then
        return 1;
    end

    local target = self:getPlayerUnit(self.gridIndex);
    if target == nil then
        self.gridIndex = nil;
        return 1;
    end

    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.STUN_BUFF_LIST[1].ID);
            if cond ~= nil then
                myTeamUnit:getTeamUnitCondition():removeCondition(cond);
                --megast.Battle:getInstance():sendEventToLua(self.scriptID,9,i)
            end
        end
    end

    --ターゲットへの処理
    if self.gridIndex ~= nil then
        self:targetEndBuff(self.gridIndex);
    end

    self.gridIndex = nil;
    return 1;
end

function class:checkTarget()
    local index = nil;
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == self.targetUnitIndex then
                index = self.targetUnitIndex;
            end
        end
    end
    return index;
end

function class:targetUnitStan(targetIndex)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == targetIndex then
                self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[1]);
            end
        end
    end
end

function class:targetEndBuff(targetIndex)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == targetIndex then
                myTeamUnit:setBurstPoint(0);
                myTeamUnit:setPositionX(myTeamUnit:getPositionX() + 200);
                self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[2]);
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST2);
            end
        end
    end
end

function class:getPlayerUnit(index)
    self.targetUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end



class:publish();

return class;