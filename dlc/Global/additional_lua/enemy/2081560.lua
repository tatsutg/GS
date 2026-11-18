local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="リゼロ後半_EX1_鬼化レム", version=2.8, id=2081560});
class:inheritFromEnemy("2081570");


--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 }
    }
}

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "これもメイドの作法です。", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "奥義ゲージ低下耐性", COLOR = Color.yellow}),
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "傷つくのは、もう……レムだけで十分です！", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE2 or "氷の障壁：一定時間、一定ダメージ無効化", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "姉様に守られるだけではメイドの名折れです！", COLOR = Color.magenta}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "全部、レムのせい……", COLOR = Color.magenta}),
    }
end

function class:hp50(status)
    if status == "use3" then
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.gameUnit:addSP(100);
        end
        self:showMessage(self.HP50_MESSAGE_LIST);
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 60,
        attackDelay = 7,
        hitStop = 100,

        tgTimer = 10,
        tgLimit = 1,
        tgIconNum1 = 24,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        exGaugeHP = 100000
    })
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP);---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false;
    self.hpSkill = 0;
    self.saveBP = 0;

    -- 経過時間ギミック
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    -- self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    -- self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);

    ---サブHP表示用
    self.subBarFlg = false;
    self.damage = 0;---サブバー表示時のダメージ
    self.SUB_HP = self.GD.exGaugeHP;---サブバーのHP
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    
    ---ボスギミック
    return 1;
end



class:publish();

return class;