--@additionalEnemy,2004553
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="大炎/樹森/水霧18F/堕天神獣オージュ", version=2.5, id=2004552});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 }
    },
    POWERUP = {
        { ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL2 = 50 },
        { SKILL8 = 50 },
        { SKILL3 = 50 },
        { SKILL7 = 50 },
        { SKILL8 = 50 }
    },
    POWERUP1 = {
        { SKILL4 = 50 },
        { SKILL5 = 50 },
        { SKILL10 = 50 },
        { SKILL6 = 50 },
        { SKILL9 = 50 },
        { SKILL10 = 50 }
    },
    POWERUP2 = {
        { SKILL4 = 50, SKILL5 = 50, SKILL6 = 50, SKILL9 = 50},
        { SKILL10 = 50 },
        { SKILL4 = 50, SKILL5 = 50, SKILL6 = 50, SKILL9 = 50},
        { SKILL10 = 50 },
    },
}

class.ACTIVE_SKILLS = {
    SKILL1 = 1,
    SKILL2 = 2,
    SKILL3 = 3,
    SKILL4 = 4,
    SKILL5 = 5,
    SKILL6 = 6,
    SKILL7 = 7,
    SKILL8 = 8,
    SKILL9 = 9,
    SKILL10 = 10,
    SKILL11 = 11,
    SKILL12 = 12,
    ATTACK1 = 20,
    ATTACK4 = 21,
    ATTACK5 = 22 --変身用
}

class.cutInSkill = {
    --[2] = 1,
    --[3] = 1,
}

-- オージュ用
class.ANIMATION_STATE = {
    IN = {
        NORMAL = "in",
        RAGE = "in3"
    },
    BACK = {
        NORMAL = "back",
        RAGE = "back2"
    },
    DAMAGE = {
        NORMAL = "damage",
        RAGE = "damage2"
    },
    IDLE = {
        NORMAL = "idle",
        RAGE = "idle2"
    }
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 200455201,
            BUFF_ID = 7, --HP自然回復
            VALUE = self.GD.tgBuffValue_7,
            DURATION = 999999,
            ICON = 35,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 200455202,
            BUFF_ID = 126, --被回復量
            VALUE = self.GD.hp75BuffValue_126,
            DURATION = 999999,
            ICON = 106,
        },
        [3] = {
            ID = 200455203,
            BUFF_ID = 113, --状態異常耐性(状態異常回避率)
            VALUE = self.GD.hp25BuffValue_113,
            DURATION = 999999,
            ICON = 67
        },
    }
    self.TREANSFORM_BOX_LIST = {
        [1] = {
            ID = 200455204,
            BUFF_ID = 126, --被回復量
            VALUE = -200,
            DURATION = 999999,
            ICON = 0,
        },
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 05,
        BUFF_ID = 21,   --被ダメージ割合
        VALUE = self.GD.targetBuff_21,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 05,
        BUFF_ID = 0,   --被ダメージ割合
        VALUE = 0,
        DURATION = 999999,
        ICON = 0
    }
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "庇う無効・クリティカル耐性・被ダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "被クリティカルダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "状態異常にさせた数が多い者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ターゲットへのダメージアップ", COLOR = Color.yellow}),
    }
    self.TGSTART_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TGSTART_MESSAGE1 or "一定時間経過するたびに自然回復量UP：オグナード全滅で経過時間リセット", COLOR = Color.yellow}),
    }
    self.HP75_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE1 or "奥義ゲージ上昇量・回復量アップ", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "自然回復一時停止", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
    }
    self.HP25_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE1 or "奥義ゲージ上昇量・状態異常耐性アップ", COLOR = Color.yellow}),
    }
    self.SKILL11_12_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL11_12_MESSAGE1 or "自然回復一時停止", COLOR = Color.yellow}),
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "オグナード：ダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "オグナード：被装備ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE3 or "オージュにダメージ軽減：オグナードを全滅で解除", COLOR = Color.yellow}),
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp75(status) end,
            HP = 75,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp25(status) end,
            HP = 25,
            used = false,
            isEnableSkip = false
        },
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

function class:hp75(status)
    if status == "use3" then
        self.hpSkill = 10
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.skillFlg = true
        self:refresh(self.gameUnit)
        self.spValue = self.GD.hp75addSP
        self.gameUnit:setInvincibleTime(25)
        self.isTimerStop = true
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:showMessage(self.HP75_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 11
        self.saveBP = self.gameUnit:getBurstPoint()
        --self.gameUnit:addSP(100)
        --self.skillFlg = true
        self:refresh(self.gameUnit)
        self.spValue = self.GD.hp50addSP
        self.gameUnit:setAttackDelay(self.GD.hp50attackDelay);
        self.gameUnit:setInvincibleTime(25)
        self.isTransform = true
        self.isTimerStop = true
        self.hpFlg = true
        self:execAddBuff(self.gameUnit,self.TREANSFORM_BOX_LIST[1])
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if cond ~= nil then
            self:showMessage(self.HP50_MESSAGE_LIST, 1)
        end
        self:showMessage(self.HP50_MESSAGE_LIST, 2)
        --self:MultipleSummon(self.gameUnit,2073591,1)
    end
end

function class:hp25(status)
    if status == "use3" then
        self.hpSkill = 12
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:refresh(self.gameUnit)
        self.spValue = self.GD.hp25addSP
        self.gameUnit:setInvincibleTime(25)
        self:initSkillWeight({POWERUP2 = 100})
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        self:execAddBuff(self.gameUnit,self.TREANSFORM_BOX_LIST[1])
        self:showMessage(self.HP25_MESSAGE_LIST)
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
        hp75BuffValue_126 = 100,
        hp25BuffValue_113 = 40,
        hp75addSP = 25,
        hp50addSP = 40,
        hp50attackDelay = 4,
        hp25addSP = 50,
        targetBuff_21 = 50,
        tgTimer = 60,
        tgLimit = 99,
        tgIconNum1 = 35,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        tgBuffValue_7 = 100000,
        notCriticalTakeDamageValue = 0.01,
        summonTakeDamageValue = {
            0.75,
            0.5,
            0.2,
            0.1,
            0.05,
            0.01,
        },
        summonBuffValue_112 = {
            -15,
            -30,
            -60,
            -120,
            -200,
            -400,
        },
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
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

    self.isTransform = false
    self.hpFlg = false

    self.friendCount = 0
    self.isStopHealing = false

    -- 状態異常回数格納用
    self.box = {}
    self.hate = {0,0,0,0}
    self.maxCnt = 0
    self.deadCheck = {0,0,0,0}
    self.hateChangeFlg = false

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnit = nil
    --self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    --self.hateResetFlg = false

    -- 経過時間ギミック
    self.timerFlg = false
    self.timeIndex = nil
    self.timeSpeeddefault = 0
    self.timeSpeed = 0
    self.timerCnt = 0
    self.isTimerStop = false

    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    -- オグナードの人数を常に監視
    local count = self.friendCount
    self:findFriend()
    if count ~= self.friendCount then
        -- 人数に応じてデバフを更新する
        self:addFriendBuff(event.unit)
    end

    --経過時間ギミック
    self:timeGimmick(event.unit)

    -- 状態異常回数チェックとヘイト管理
    self:badStatusCount(event.unit)
    self:hateUpdate(event.unit)

    --変身
    if self.isTransform and self.hpFlg then
        self.hpFlg = false
        self:initAttackWeight({POWERUP = 100})
        self:initSkillWeight({POWERUP1 = 100})
        self.gameUnit:takeAnimation(0,"attack5",false)
        self.gameUnit:takeAnimationEffect(0,"1-attack5",false)
        self.gameUnit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK5)
        self.gameUnit:setInvincibleTime(25)
        --if megast.Battle:getInstance():isHost() then
        --    megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0)
        --end
    end

    return 1
end

function class:timeGimmick(unit)
    if self.timeIndex ~= nil then

        -- 雑魚敵の数で速度を決める
        if self.friendCount ~= 0 then
            self.timeSpeed = self.timeSpeeddefault * self.friendCount
        else
            self.timeSpeed = 0
        end

        -- ブレイク中は止める
        if unit:isBreak() then
            self.timeSpeed = 0
        end

        -- タイマーストップフラグが立ってたら止める
        if self.isTimerStop then
            self.timeSpeed = 0
        end

    -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed)
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        end

        -- 雑魚敵がいない場合はリセットをかけておく
        if self.friendCount == 0 then
            megast.Battle:getInstance():setExtraTimerPercentage(self.timeIndex, 0);
        end
    end
end

function class:findFriend()   --雑魚の監視
    self.friendCount = 0
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == 100402511 then  --魔術師オグナード
                self.friendCount = self.friendCount + 1
            elseif myTeamUnit:getUnitID() == 100403511 then  --闇術師オグナード
                self.friendCount = self.friendCount + 1
            elseif myTeamUnit:getUnitID() == 100404511 then  --暗黒魔導オグナード
                self.friendCount = self.friendCount + 1
            end
        end
    end
    if self.friendCount > 6 then
        self.friendCount = 6
    end
end

function class:addFriendBuff(unit)
    local team = megast.Battle:getInstance():getTeam(true)
    local valueCalc = 0
    local DBUFFRESISTDOWN_BUFF_LIST = {
        [1] = {
            ID = 200455211,
            BUFF_ID = 112,   --状態異常耐性
            VALUE = valueCalc,
            DURATION = 999999,
            ICON = 77,
        },
        [2] = {
            ID = 200455212,
            BUFF_ID = 113,   --状態異常回避率
            VALUE = valueCalc,
            DURATION = 999999,
            ICON = 0,
        }
    }

    if self.friendCount ~= 0 then
        valueCalc = self.GD.summonBuffValue_112[self.friendCount]
        --if valueCalc > self.GD.friendNumBuffValueMAX then
        --    valueCalc = self.GD.friendNumBuffValueMAX
        --end
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                self:buffRefresh(teamUnit,DBUFFRESISTDOWN_BUFF_LIST[1].ID)
                self:buffRefresh(teamUnit,DBUFFRESISTDOWN_BUFF_LIST[2].ID)
                if valueCalc ~= 0 then
                    DBUFFRESISTDOWN_BUFF_LIST[1].VALUE = valueCalc
                    DBUFFRESISTDOWN_BUFF_LIST[2].VALUE = valueCalc
                    self:execAddBuff(teamUnit,DBUFFRESISTDOWN_BUFF_LIST[1])
                    self:execAddBuff(teamUnit,DBUFFRESISTDOWN_BUFF_LIST[2])
                end
            end
        end
    else
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                self:buffRefresh(teamUnit,DBUFFRESISTDOWN_BUFF_LIST[1].ID)
                self:buffRefresh(teamUnit,DBUFFRESISTDOWN_BUFF_LIST[2].ID)
            end
        end
    end
end

function class:buffRefresh(unit,buffID)
    local badStatusIDs = {buffID};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithID(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
end

-- 各ユニットで状態異常を与えた回数をカウントする
function class:badStatusCount(unit)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize > 0 then
        for i = 0,(conditionSize - 1) do
            local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
            if cond ~= nil then
                if self:conditionTypeCheck(cond) then

                    local group = cond:getGroupID()
                    local id = cond:getID()
                    local time = cond:getTime()
                    local index = self:getAncestorUnit(cond:getCaster()):getIndex();

                    if self.box[group] ~= nil then
                        if (self.box[group].ID == id and self.box[group].DURATION < time) or self.box[group].ID ~= id then
                            self.hate[index + 1] = self.hate[index + 1] + 1
                            --summoner.Utility.messageByEnemy("更新" .. id)

                            if self.maxCnt < self.hate[index + 1] then
                                self.maxCnt = self.hate[index + 1]
                                self.hateChangeFlg = true
                            end
                        end
                        self.box[group].ID = id
                        self.box[group].DURATION = time
                    else
                        table.insert(self.box , group ,{ID = id , DURATION = time})
                        self.hate[index + 1] = self.hate[index + 1] + 1

                        -- 回数が上回った時にヘイト更新処理をかける（同数の場合はやらない）
                        if self.maxCnt < self.hate[index + 1] then
                            self.maxCnt = self.hate[index + 1]
                            self.hateChangeFlg = true
                        end
                        --summoner.Utility.messageByEnemy("挿入：" .. self.hate[index + 1])
                    end
                end
            end
        end
    end
end

-- 毒、暗闇(ナイトメア)、病気、燃焼のときTrueを返す
function class:conditionTypeCheck(condition)
    local badStatusList = { 90,93,94,97,131 }
    for k,v in pairs(badStatusList) do
        if condition:getConditionTypeAsInt() == v then
            return true
        end
    end
    return false
end

-- ヘイト対象を更新する
function class:hateUpdate(unit)
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    local deadFlg = false
    -- 死亡、蘇生チェック
    for i = 0,3 do
        local myTeamUnit = targetTeam:getTeamUnit(i, true);
        if myTeamUnit ~= nil then
            if myTeamUnit:getHP() < 1 and self.deadCheck[i+1] == 0 then
                self.deadCheck[i+1] = 1
                self.hateChangeFlg = true
                deadFlg = true
            elseif myTeamUnit:getHP() > 0 and self.deadCheck[i+1] == 1 then
                self.deadCheck[i+1] = 0
                self.hateChangeFlg = true
                deadFlg = true
            end
        end
    end

    -- 状態異常回数が更新、ユニットが死亡した時か蘇生した時に更新かける
    if self.hateChangeFlg then
        self.hateChangeFlg = false

        local tmp = 0
        local index = nil
        local target = nil
        -- 状態異常を与えたユニットが最も多いユニットのIndexからユニットの情報を取得
        for k,v in pairs(self.hate) do
            if v > 0 then
                -- 比較対象の方が回数多い場合
                local myTeamUnit = targetTeam:getTeamUnit(k - 1)
                if myTeamUnit ~= nil and v > tmp then
                    index = k - 1
                    tmp = v
                    -- 死亡蘇生による更新の場合は最大状態異常カウント値を更新かける
                    if deadFlg then
                        self.maxCnt = v
                    end
                    --summoner.Utility.messageByEnemy(tmp)
                end
            end
        end

        if index ~= nil then
            for i = 0,6 do
                local myTeamUnit = targetTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    if index == myTeamUnit:getIndex() then
                        target = myTeamUnit
                        break;
                    end
                end
            end
        else
            -- 死亡ユニット以外で誰も状態異常を与えてない場合
            if deadFlg then
                self.maxCnt = 0
            end
        end

        --ターゲットを取得できなかった場合はリーダー＞一番左のユニット
        if target == nil then
            for i = 0,6 do
                local myTeamUnit = targetTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    target = myTeamUnit
                    break;
                end
            end

            for i = 0,6 do
                local myTeamUnit = targetTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    if myTeamUnit:getIsLeader() then
                        target = myTeamUnit
                        break;
                    end
                end
            end
        end

        ---ヘイトは全部手動で設定する
        unit:setHateTarget(target);
        unit:updateHateTarget();
        self:targetAddBuff(unit, target)
    end
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    local target = nil
    --リーダー＞一番左のユニットの順でターゲット
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            target = myTeamUnit
            break;
        end
    end

    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getIsLeader() then
                target = myTeamUnit
                break;
            end
        end
    end

    ---ヘイトは全部手動で設定する
    event.unit:setHateTarget(target);
    event.unit:updateHateTarget();
    self:targetAddBuff(event.unit, target)
    return 1
end

function class:targetAddBuff(unit, target)
    local TARGET_BUFF_LIST = {
        [1] = {
            ID = 05,
            BUFF_ID = 21,   --被ダメージ割合
            VALUE = self.GD.targetBuff_21 * (1 + self.timerCnt),
            DURATION = 999999,
            ICON = 0
        },
        [2] = {
            ID = 05,
            BUFF_ID = 0,   --被ダメージ割合
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        }
    }

    ---ターゲットにバフ
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if i == target:getIndex() then
                self.targetUnit = target
                self:execAddBuff(myTeamUnit,TARGET_BUFF_LIST[1]);
            else
                self:execAddBuff(myTeamUnit,TARGET_BUFF_LIST[2]);
            end
        end
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    self.timerCnt = self.timerCnt + 1
    self:targetAddBuff(event.unit, self.targetUnit)
    return event.count
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "red" then return self:red(event.unit) end
    if event.spineEvent == "redEnd" then return self:redEnd(event.unit) end
    if event.spineEvent == "showInEffect" then return self:showInEffect(event.unit) end
    if event.spineEvent == "addRageBuff" then return self:addRageBuff(event.unit) end
    if event.spineEvent == "showRageEffect" then return self:showRageEffect(event.unit) end
    if event.spineEvent == "firestart" then return self:fireStart(event.unit) end
    if event.spineEvent == "fireloop" then return self:fireLoop(event.unit) end
    return 1;
end

--==============================================================================================================
--オージュ固有ギミック/
--////////////////
function class:red(unit)
    megast.Battle:getInstance():setBackGroundColor(15,255,0,0);
    return 1;
end

function class:redEnd(unit)
    megast.Battle:getInstance():setBackGroundColor(99999,255,50,255);
    return 1;
end

function class:showInEffect(unit)
    unit:takeAnimationEffect(0,"in1",false);
    return 1;
end

function class:addRageBuff(unit)
    self:initAttackWeight({POWERUP = 100})
    self:initSkillWeight({POWERUP1 = 100})
    self.gameUnit:addSP(100)
    return 1;
end

function class:showRageEffect(unit)
    --背景の色変える
    megast.Battle:getInstance():setBackGroundColor(99999,255,50,255);
    self:fireStart(unit);
    return 1;
end

function class:fireStart(unit)
    self.fire = BattleControl:get():addAnimation("FIRE","FIRE4_00",true);
    self.fire:setPositionX(unit:getPositionX() -50);
    self.fire:setPositionY(unit:getPositionY() -20);
    self.fire:setZOrder(0);
    return 1;
end

function class:fireLoop(unit)
    self.fire:setToSetupPose();
    self.fire:setAnimation(0, "FIRE3_00",true);
    return 1;
end

--=====================================================================================================================================

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    -- 被回復量DOWN持ってたら消す
    if self.isStopHealing then
        self.isStopHealing = false
        self:buffRefresh(event.unit,self.TREANSFORM_BOX_LIST[1].ID)
    end

    -- タイマーが止まってたら動かす
    self.isTimerStop = false

    if event.index == 4 then
        event.unit:setSetupAnimationName("idle2-cast");
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    end
    
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    
    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)

    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
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

    if event.index == 10 and not self.isTransform then
        event.unit:setNextAnimationName("skill8")
        event.unit:setNextAnimationEffectName("1-skill8")
    end
    if event.index == 11 then
        self.gameUnit:setInvincibleTime(25)
        self:execAddBuff(self.gameUnit,self.TREANSFORM_BOX_LIST[1])
        self.isStopHealing = true
        self.isTimerStop = true
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if cond ~= nil then
            self:showMessage(self.SKILL11_12_MESSAGE_LIST)
        end
    end
    if event.index == 12 then
        event.unit:setNextAnimationName("skill11")
        event.unit:setNextAnimationEffectName("1-skill11")
        self.isStopHealing = true
        self.isTimerStop = true
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if cond ~= nil then
            self:showMessage(self.SKILL11_12_MESSAGE_LIST)
        end
    end

    if event.index == 8 or event.index == 10 or event.index == 11 or event.index == 12 then
        self:findFriend()
        self:frienSummon(self.friendCount)
        self:TimerStart()
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill
        self.hpSkill = 0
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end

    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex),self.cutInSkill[skillIndex]);
    else
        unit:takeSkill(tonumber(skillIndex));
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true;
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index,self.cutInSkill[index]);
    else
        unit:takeSkill(index);
    end
end

function class:frienSummon(friendCount)   --雑魚の召喚
    if friendCount == 6 then
        --何もしない
    elseif friendCount == 5 then   --５体いる場合は１体のみ
        self:enemySummon(1)
    else
        self:enemySummon(2)
    end
end

---召喚系
function class:enemySummon(Num)   --召喚回数
    for i = 1,Num do
        self:MultipleSummon(self.gameUnit,2004553,1)   --オグナード召喚
    end
    self:showMessage(self.SUMMON_MESSAGE_LIST)
end

function class:TimerStart()
    if self.timeIndex == nil then
        -- タイマーが表示されていない場合
        self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
        self.timeSpeeddefault = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        self.timeSpeed = self.timeSpeeddefault

        self:showMessage(self.TGSTART_MESSAGE_LIST)
    else
        -- タイマーが既に表示されている場合
        -- 既にタイマーがでてる場合は初期値にセットする
        --megast.Battle:getInstance():setExtraTimerPercentage(self.timeIndex, 0);
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)

    -- クリティカル以外軽減
    if not enemyUnit:getTeamUnitCondition():getDamageAffectInfo().critical then
        event.value = event.value * self.GD.notCriticalTakeDamageValue
    end

    -- オグナードの人数分軽減
    if self.friendCount ~= 0 then
        event.value = event.value * self.GD.summonTakeDamageValue[self.friendCount]
        --summoner.Utility.messageByEnemy(self.GD.summonTakeDamageValue[self.friendCount])
    end

    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
        return self:calcDamageValue(unit,stopBorder,value)
        end
    end

    return value
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
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
    return event.value
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    self.skillFlg = false
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeIn
---------------------------------------------------------------------------------
function class:takeIn(event)
    self:animationSwitcher(self.ANIMATION_STATE.IN,event.unit);
    return 1
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self:animationSwitcher(self.ANIMATION_STATE.IDLE,event.unit);
    return 1;
end

function class:animationSwitcher(state,unit)
    unit:setNextAnimationName(state[self.stateName]);
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    self:animationSwitcher(self.ANIMATION_STATE.BACK,event.unit);
    return 1;
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self:animationSwitcher(self.ANIMATION_STATE.DAMAGE,event.unit);
    return 1;
end


---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.isTransform then
        event.unit:setNextAnimationName("out");
        event.unit:setNextAnimationEffectName("empty");
    end
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
    end
    BattleControl:get():visibleHateTarget(false);
    event.unit:setEnableHate(false);
    event.unit:updateHateTarget();
    self:friendDead()
    return 1
end

function class:friendDead()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:setHP(0)
        end
    end
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            if not trigger.isEnableSkip then
                ---通常マーカーはブレイク中は発動しない
                if not unit:isBreak() then
                    self:execTrigger(index)
                end
            else
                ---ブレイクスルー
                self:execTrigger(index)
            end
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3
    local action = "use" .. receiveNumber
    self.TRIGGERS[index].used = true

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true)
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end


    self.TRIGGERS[index].action(action)
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
end

---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true)
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end

function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1
        stateBox.setCount = stateBox.setCount + 1
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount])
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex)
end


class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex)
end

function class:initState(weightList)
    local state = {}
    state.SET_WEIGHT = weightList
    state.actCount = 1
    state.setCount = 1
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
    return state
end

---トリガー時状態異常除去---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
end

function class:refreshAll(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97,135};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
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