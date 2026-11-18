local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真・夢幻封妖伝 参ノ巻真EX極オルデウス", version=1.3, id=2043675});
class:inheritFromEnemy("2043660");

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "回避率UP（徐々に低下）"
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        --[[
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp100(status) end,
            HP = 100,
            used = false
        },
        ]]--
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end
--[[
function class:hp100(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 2
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
    end
end
]]--
function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 1
        self.gameUnit:addSP(100)
    end
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 20436751,
            BUFF_ID = 31,  --回避率UP
            VALUE = 120,
            DURATION = 99999,
            ICON = 16
        },
        [2] = {
            ID = 20436752,
            BUFF_ID = 89,---気絶
            VALUE = 100,
            DURATION = 1.5,
            ICON = 79
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 20;---addSPの量
    --event.unit:setAttackDelay(3);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;

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

    self.buff = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    ---hp100ギミック
    self.hpSkill = 2
    self.gameUnit:addSP(100)
    self.gameUnit:setInvincibleTime(10)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "death" then return self:enemyAddBuff(event.unit,self.BUFF_BOX_LIST[2]) end
    return 1;
end

function class:enemyAddBuff(unit,buffBox)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
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

    if event.index == 2 then
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("1-skill3")
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    --event.unit:setReduceHitStop(2,1)---ヒットストップ無効or時止め無効
    if self.timer == nil then self.timer = 0 end
    if self.buff:getThumbnailID() ~= 0 then
        if self.buff:getValue() > 0 then
            self.timer = self.timer + event.deltaTime
            if self.timer > 1 then
                self.timer = self.timer - 1
                self.BUFF_BOX_LIST[1].VALUE = self.BUFF_BOX_LIST[1].VALUE -5
                self.buff:setValue(self.BUFF_BOX_LIST[1].VALUE)
            end
        else
            self.buff:setThumbnailID(0)
            megast.Battle:getInstance():updateConditionView()
        end
    end
    return 1
end

class:publish();

return class;