--@additionalEnemy,600000137, 600000138, 600000139
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="レイド_HARD_炎テネブディウス", version=2.6, id=600000132});
class:inheritFromEnemy("600000133");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ボスが状態異常のとき、被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "一定ブレイクダメージでインフェルノヴィジョン発動", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "一定時間でマルチブレイズレーザー発動：魔法攻撃で短縮", COLOR = Color.yellow})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "ハイゴブル：炎属性以外のダメージ・クリティカルダメージを軽減", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "雷哮剣鬼ライザー：光属性以外のダメージ・クリティカルダメージを軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE3 or "羅将オロチ：闇属性以外のダメージ・クリティカルダメージを軽減", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE4 or "ハイゴブル・ライザー・オロチの数が多いほどボスの奥義ダメージアップ", COLOR = Color.yellow})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "パーティの攻撃力低下", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE2 or "ボスの物理耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE3 or "ボスの魔法耐性アップ", COLOR = Color.yellow})
    }
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "パーティの最大HP低下・装備CTダウン", COLOR = Color.red})
    }
    self.SUMMON_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_DEAD_MESSAGE1 or "ハイゴブル撃破！", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_DEAD_MESSAGE2 or "雷哮剣鬼ライザー撃破！", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_DEAD_MESSAGE3 or "羅将オロチ撃破！", COLOR = Color.cyan}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_DEAD_MESSAGE4 or "%s耐性ダウン！", COLOR = Color.cyan})
    }
    self.BUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BUFF_MESSAGE1 or "%s耐性アップ", COLOR = Color.red})
    }
    self.DEBUFF_NAME_LIST = {
        [89] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_NAME1 or "気絶", COLOR = Color.red}),
        [90] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_NAME2 or "毒", COLOR = Color.red}),
        [91] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_NAME3 or "麻痺", COLOR = Color.red}),
        [92] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_NAME4 or "沈黙", COLOR = Color.red}),
        [93] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_NAME5 or "暗闇", COLOR = Color.red}),
        [94] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_NAME6 or "病気", COLOR = Color.red}),
        [95] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_NAME7 or "呪い", COLOR = Color.red}),
        [96] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_NAME8 or "氷結", COLOR = Color.red}),
        [97] = self:setMessageInfo({MESSAGE = self.TEXT.DEBUFF_NAME9 or "燃焼", COLOR = Color.red})
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        startAddSP = 50,
        attackDelay = 8,
        hitStop = 100,

        tgTimerA = 600,
        tgLimitA = 99,
        tgIconNum1A = 0,
        tgIconNum2A = 0,
        tgPosXA = 0,
        tgPosYA = 0,
        tgScaleA = 1,

        bossLevel = 2,
        subBarHP = 1000000,
        tgDmgParA = 1,
        tgDmgParB = 1,

        skill3DmgVal = 0.05,
        deBuffOffDmgVal = 0.2,
        deBuffONDmgVal = 1.1,
        buffResistanceVal = 100,

        buffTme_89 = 5,
        skillBuff_2 = -20,
        skillBuff_13 = -30,
        skillBuff_17 = 20,
        skillBuff_30 = -20,
        tgBuff_21_1 = -50,
        tgBuff_21_2 = -50,
        summonBuffValTbl_17 = {
            0,
            30,
            80,
            150,
            300,
            500,
            1000
        }
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
    self.afterSkillFLG = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.stateName = "NORMAL";
    self.breakSkip = true;
    self.hpSkill = 0;
    self.saveBP = 0;

    ---経過時間ギミック
    self.tgSkillFlgA = false;
    self.tgSkillFlgB = false;
    self.breakFlg = false;
    self.invincibleFlg = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    if self.GD.bossLevel >= 2 then
        self.timeIndexA = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimerA, self.GD.tgLimitA ,self.GD.tgIconNum1A, self.GD.tgIconNum2A, self.GD.tgPosXA, self.GD.tgPosYA, self.GD.tgScaleA);
        self.timeSpeedA = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexA);
    end

    if self.GD.bossLevel >= 3 then
        self.timeIndexB = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimerB, self.GD.tgLimitB ,self.GD.tgIconNum1B, self.GD.tgIconNum2B, self.GD.tgPosXB, self.GD.tgPosYB, self.GD.tgScaleB);
        self.timeSpeedB = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB);
    end

    ---ボスギミック
    self.skillFlg = false;
    --耐性バフギミック
    self.badStatusList = { 89,90,91,92,93,94,95,96,97 };
    self.deBuffTbl = {};
    --BUFFTYOE:101 気絶回避バフ / ICON:58 気絶耐性UPアイコン
    local num = 0;
    for i = 89,97 do  --気絶〜燃焼
        self.deBuffTbl[1] = {FLG = false, BUFF_ID = 0 ,ICON = 0};
        self.deBuffTbl[i] = {FLG = false, BUFF_ID = 101 + num ,ICON = 58 + num};
        num = num + 1;
    end

    --召喚ギミック
    self.friendCount = 0;
    self.summonCount1 = 0;
    self.summonCount2 = 0;
    self.summonCount3 = 0;
    self.summonBuffValTbl_17 = {};
    for i = 0,6 do
        self.summonBuffValTbl_17[i] = self.GD.summonBuffValTbl_17[i + 1];
    end
    self.summonDeadBuffID = 60013399;
    self:setSummonIDs();

    ---エクストラゲージギミック
    self.subBarFlg = true;
    self.subBar = BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = self.GD.subBarHP;---サブバーのHP
    self.damage = 0;---サブバー表示時のダメージ
    self.skill3Flg = false;
    self.stunFlg = false;

    ---猛火ドラゴン用
    self.isLockOn = true;
    self.isFireEnd = true;
    self.neckAngle = 0;
    self.shotAngle = 0;
    self.fireSwitch = 1;
    self.skill3orbit = nil;
    return 1;
end

function class:setSummonIDs()
    self.summonID1 = 600000137;  --hard/ハイゴブル
    self.summonID2 = 600000138;  --hard/雷哮剣鬼ライザー
    self.summonID3 = 600000139;  --hard/羅将オロチ
end


---召喚系
---------------------------
function class:summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
                break
            end
        end
    end
end

function class:MultipleSummon(unit,unitID,Num)
    for i = 1,Num do
        self:summon(unit,unitID)
    end
end




class:publish();

return class;