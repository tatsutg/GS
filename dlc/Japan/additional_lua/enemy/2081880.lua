local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="真EX_魔眼怪盗アズライト", version=2.8, id=2081880});
class:inheritFromEnemy("2081890");


class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL5 = 5
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "怪盗の夜を始めよう", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "人族・水属性ユニットからの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "累計ダメージの大きいユニットをターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ターゲットへのクリティカルダメージアップ", COLOR = Color.yellow}),
    }
    self.TIMER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIMER_MESSAGE1 or "クリティカル率アップ", COLOR = Color.red}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "アーク・解放、千年鎖の剣――", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "%sに宝箱状態を付与", COLOR = Color.red, isPlayer = true}),
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "さぁ、ショータイムだ！", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "黄金の刻：ダメージ無効化無効", COLOR = Color.yellow}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "月が…見えないな……", COLOR = Color.cyan}),
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        }
    }
    self.HP_TRIGGERS = {};
    self.hpMarkers = {};
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger;
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01);
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255);
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist");
            end
        end
    end
end

function class:hp50(status)
    if status == "use3" then
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 5;
            self.saveBP = self.gameUnit:getBurstPoint() * 0.5;
            self.gameUnit:addSP(100);
        end
        self.hpDmgMult = self.GD.hpDmgMult;
        self:setHP50BuffandInfo();
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    self:extraTimerOperation(event.unit);
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill2_orbit" then
        local orbit = event.unit:addOrbitSystem("skill2_orbit",0);
    end

    if event.spineEvent == "Magan" then
        local magan = event.unit:addOrbitSystemWithFile("Magan_Azurite","Activation");
        magan:setAutoZOrder(true);
        magan:setZOderOffset(-5000);
        local vec = event.unit:getisPlayer() and 1 or -1;
        local targetX = event.unit:getPositionX() + event.unit:getSkeleton():getBoneWorldPositionX("root") * vec;
        local targetY = event.unit:getPositionY() + event.unit:getSkeleton():getBoneWorldPositionY("root");
        magan:setPosition(targetX,targetY);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
    return 1
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    return 1
end



class:publish();

return class;