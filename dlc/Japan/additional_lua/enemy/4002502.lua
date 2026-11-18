--@additionalEnemy,4002511
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="超新星級_HARD_フレイダル・絶", version=2.8, id=4002502});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    GROUND = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK3 = 100 },
    },
    FLIGHT = {
        { ATTACK6 = 100 },
        { ATTACK4 = 100 },
        { ATTACK4 = 50, ATTACK5 = 50 },
        { ATTACK4 = 50, ATTACK5 = 50 },
    },
    FLIGHT_ENRAGED = {
        { ATTACK6 = 100 },
        { ATTACK4 = 100 },
        { ATTACK5 = 100 },
        { ATTACK4 = 33, ATTACK5 = 33, ATTACK6 = 34 },
    },
}

--使用する奥義とその確率
--- ※各ステップは必ず単一候補にする（takeOffEnd後にホスト/ゲスト双方で再抽選するため、
---   複数候補にすると奥義がマルチでズレる）
class.SKILL_SET_LIST = {
    GROUND = {
        { SKILL4 = 100 },---奥義7 ブラウヴォルテクス（着地状態から用）
    },
    FLIGHT = {
        { SKILL1 = 100 },---奥義8 ブラウヴォルテクス
        { SKILL2 = 100 },---奥義9 ダートウイング
    },
    FLIGHT_ENRAGED = {
        { SKILL3 = 100 },---奥義10 レイジングブリザード
    },
}

--- takeSkill(N) は spine の "skillN" を再生し、ACTIVE_SKILLS["SKILLN"] を setActiveSkill する。
--- 仕様書の (skillN) 表記に合わせて 奥義7=skill4 / 奥義8=skill1 / 奥義9=skill2 / 奥義10=skill3 に対応させる
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    SKILL1 = 8, ---奥義8 ブラウヴォルテクス（spine skill1）
    SKILL2 = 9, ---奥義9 ダートウイング（spine skill2）
    SKILL3 = 10,---奥義10 レイジングブリザード（spine skill3）
    SKILL4 = 7, ---奥義7 ブラウヴォルテクス（着地状態から用）（spine skill4）
}

--- 常時カットインの奥義は無し。HPトリガーの奥義カットインは cutInFLG で個別に処理する
class.cutInSkill = {
}

--- 氷衰ギミックの発動対象（キーは takeAttack / takeSkill の event.index）
class.FREEZE_ATTACK_INDEXES = {
    [3] = true,---スキル3 ハウリング
    [6] = true,---スキル6 風飛ばし
};
class.FREEZE_SKILL_INDEXES = {
    [4] = true,---奥義7 ブラウヴォルテクス（着地状態から用）
    [1] = true,---奥義8 ブラウヴォルテクス
    [3] = true,---奥義10 レイジングブリザード
};

--- フレイダルの状態
class.STATE_GROUND = "GROUND";
class.STATE_FLIGHT = "FLIGHT";
class.STATE_FLIGHT_ENRAGED = "FLIGHT_ENRAGED";

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 400250201,
            BUFF_ID = 132,---ダメージ無効化無効（飛行(怒り)状態）
            VALUE = self.GD.buffVal_132,
            DURATION = 99999,
            ICON = 0,
        },
        [2] = {
            ID = 400250202,
            BUFF_ID = 31,---物理回避率UP（飛行状態）
            VALUE = self.GD.buffVal_31,
            DURATION = 999999,
            ICON = 16,
            SCRIPT = {
                SCRIPT_ID = 2
            }
        },
        [3] = {
            ID = 400250203,
            BUFF_ID = 31,---物理回避率UP（飛行(怒り)状態）
            VALUE = self.GD.buffVal_31_2,
            DURATION = 999999,
            ICON = 16,
            SCRIPT = {
                SCRIPT_ID = 2
            }
        },
        ---タイマーB：クリティカルダメージUP（与ダメージバフにSCRIPT_ID=22を入れてクリティカル限定にする）
        [4] = {
            ID = 400250204,
            BUFF_ID = 17,---クリティカルダメージUP
            VALUE = self.GD.critDamageValue_17,
            DURATION = 999999,
            ICON = 26,
            MAX = self.GD.critDamageMax,
            SCRIPT = {
                SCRIPT_ID = 22,
                VALUE1 = 0,
                VALUE2 = 0
            }
        },
    }
    ---氷衰（上位氷結）ギミック。[1]=スキル3・6用（2秒） [2]=奥義7・8・10用（3秒）
    ---※IDを同じにして、後から付いた方で上書きされるようにする
    self.FREEZE_BUFF_LIST = {
        [1] = {
            ID = 400250205,
            BUFF_ID = 207,---上位氷結効果(氷衰)
            VALUE = self.GD.buffVal_207,
            DURATION = self.GD.freezeTimeAttack,
            ICON = 307,
        },
        [2] = {
            ID = 400250205,
            BUFF_ID = 207,---上位氷結効果(氷衰)
            VALUE = self.GD.buffVal_207,
            DURATION = self.GD.freezeTimeSkill,
            ICON = 307,
        },
    }
    ---HPトリガー後にフレイダル自身へ付ける氷結。DURATIONは startFreezeState で上書きする
    self.FREEZE_SELF_BUFF = {
        ID = 400250206,
        BUFF_ID = 96,---氷結
        VALUE = 100,
        DURATION = 0,
        ICON = 86,
        EFFECT = 7,
    }
    ---氷結中のHP自然回復。DURATIONは startFreezeState で上書きする
    ---※SCRIPT_ID=238 で VALUE を「最大HPに対する割合(%)/秒」として扱う
    self.FREEZE_REGEN_BUFF = {
        ID = 400250212,
        BUFF_ID = 7,---HP自然回復
        VALUE = self.GD.freezeHpRegenValue_7,
        DURATION = 0,
        ICON = 35,
        SCRIPT = {
            SCRIPT_ID = 238
        }
    }
    ---凍傷ギミック：氷結時間の累積でパーティユニットの最大HP・攻撃力を下げる
    ---※[3]は割合で減らせなくなったときに最大HPを1に固定するための固定値バフ（VALUEは実行時に決める）
    self.FROSTBITE_BUFF_LIST = {
        [1] = {
            ID = 400250208,
            BUFF_ID = 2,---最大HP割合
            VALUE = self.GD.frostbiteHpValue,
            DURATION = 999999,
            ICON = 2,
            MAX = self.GD.frostbiteIconMax,
        },
        [2] = {
            ID = 400250209,
            BUFF_ID = 13,---攻撃力
            VALUE = self.GD.frostbiteAtkValue,
            DURATION = 999999,
            ICON = 4,
            MAX = self.GD.frostbiteIconMax,
        },
        [3] = {
            ID = 400250210,
            BUFF_ID = 1,---最大HP固定値
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
        },
    }
    ---ターゲットギミック：ターゲットの被ダメージUP（ターゲットが変わったら貼り替える）
    self.TARGET_BUFF_LIST = {
        [1] = {
            ID = 400250211,
            BUFF_ID = 21,---被ダメージ
            VALUE = self.GD.targetBuffValue_21,
            DURATION = 999999,
            ICON = 139,---被ダメージアップ
        },
    }
    ---タイマーA：1周ごとにパーティの状態異常耐性DOWN（アイコンに数値表示・累積）
    self.TG_BUFF_LIST = {
        [1] = {
            ID = 400250207,
            BUFF_ID = 112,---状態異常耐性
            VALUE = self.GD.buffVal_112,
            DURATION = 999999,
            ICON = 77,---状態異常耐性DOWN
            MAX = self.GD.tgLimit,
        },
        [2] = {
            ID = 400250208,
            BUFF_ID = 113,---状態異常回避率
            VALUE = self.GD.buffVal_112,
            DURATION = 999999,
            ICON = 0,
            MAX = self.GD.tgLimit,
        },
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
    return message;
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性・庇うキラー", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "累計ダメージが多いユニットをターゲット：ターゲットへのダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "凍傷：氷結時間が長いほどユニットのHP・攻撃力低下", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "時間経過でユニットの状態異常耐性ダウン：暗闇で遅延", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ユニットが氷結状態のとき、フレイダルの攻撃で奥義ゲージダウン", COLOR = Color.red}),
    }
    ---タイマーAが1周するたびに表示
    self.TIMERA_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIMERA_MESSAGE1 or "状態異常耐性ダウン", COLOR = Color.yellow, isPlayer = true}),
    }
    ---氷衰ギミック発動時に表示（スキル3・6／奥義7・8・10）
    self.FREEZE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FREEZE_MESSAGE1 or "ターゲットを氷衰", COLOR = Color.red}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "凍身回復：フレイダルが自身を氷結状態に移行", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "フレイダルが氷結状態のとき、HP自然回復：一定ダメージで解除", COLOR = Color.yellow}),
    }
    self.FLIGHT_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FLIGHT_MESSAGE1 or "飛行状態：攻撃速度・奥義上昇量・物理回避率アップ", COLOR = Color.yellow}),
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "凍身回復：フレイダルが自身を氷結状態に移行", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "フレイダルが氷結状態のとき、HP自然回復：一定ダメージで解除", COLOR = Color.yellow}),
    }
    self.TIMER2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIMER2_MESSAGE1 or "フレイダルの氷結時間が長いほどユニットの被CRIダメージアップ", COLOR = Color.red}),
    }
    self.RAGE_FLIGHT_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.RAGE_FLIGHT_MESSAGE1 or "絶蒼鳥の怒り：ダメージ無効化無効", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.RAGE_FLIGHT_MESSAGE2 or "攻撃速度・奥義上昇量・物理回避率アップ", COLOR = Color.yellow}),
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
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
            used = false,
            isEnableSkip = false
        },
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
        self:refreshAll(self.gameUnit);
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;---奥義10 レイジングブリザード
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        ---地上状態のときだけtake_offを挟んでから奥義10を撃つ
        self.hpTakeOffFlg = not self.isFlying;
        self.hpTakeOffSkill = 3;
        self.cutInFLG = true;
        self.cutInType = self.GD.hp50CutInType;
        self.gameUnit:setInvincibleTime(10);
        self.hpSkillFLG = true;
        ---INFOは氷結状態への移行時に出すので startFreezeState 側で表示する
        ---奥義10を打ち終わったあとの処理を予約する（累計リセット → 氷結 → 解除で飛行状態へ）
        self.needResetTargetDamage = true;
        self.pendingFreezeTime = self.GD.freezeTime;
        self.pendingFreezeState = self.STATE_FLIGHT;
        ---※ここで setBurstPoint(0) をすると直前の addSP(100) を打ち消して奥義が出なくなる
    end
end

function class:hp0(status)
    if status == "use3" then
        self:refreshAll(self.gameUnit);
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;---奥義10 レイジングブリザード
            -- self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        ---地上状態のときだけtake_offを挟んでから奥義10を撃つ
        self.hpTakeOffFlg = not self.isFlying;
        self.hpTakeOffSkill = 3;
        self.cutInFLG = true;
        self.cutInType = self.GD.hp0CutInType;
        self.gameUnit:setInvincibleTime(10);
        self.hpSkillFLG = true;
        ---INFOは氷結状態への移行時に出すので startFreezeState 側で表示する
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * self.GD.hp0HpRate);
        ---奥義10を打ち終わったあとの処理を予約する（累計リセット → 氷結 → 解除で飛行(怒り)状態へ）
        self.needResetTargetDamage = true;
        self.pendingFreezeTime = self.GD.freezeTime;
        self.pendingFreezeState = self.STATE_FLIGHT_ENRAGED;
        ---※ここで setBurstPoint(0) をすると直前の addSP(100) を打ち消して奥義が出なくなる
    end
end

---状態のパラメータを適用する（メッセージは出さない）
function class:applyState(unit,stateName)
    self.stateName = stateName;
    self.tmpSkill = false;
    self.takeOffFlg = false;

    if stateName == self.STATE_GROUND then
        self.isFlying = false;
        self.spValue = self.GD.addSP;---addSPの量
        unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
        ---回避率バフを解除
        self:removeBuffByID(unit,self.BUFF_LIST[2].ID);
        self:removeBuffByID(unit,self.BUFF_LIST[3].ID);
        self:switchWind("hideWindAura");
        self:initAttackWeight({GROUND = 100});
        self:initSkillWeight({GROUND = 100});

    elseif stateName == self.STATE_FLIGHT then
        self.isFlying = true;
        self.spValue = self.GD.addSP_fly;---addSPの量
        unit:setAttackDelay(self.GD.attackDelay_fly);---アタックディレイ
        ---物理回避率UP（BUFF_ID31が二重に乗らないよう両方解除してから付け直す）
        self:removeBuffByID(unit,self.BUFF_LIST[3].ID);
        self:removeBuffByID(unit,self.BUFF_LIST[2].ID);
        self:execAddBuff(unit,self.BUFF_LIST[2]);
        self:switchWind("hideWindAura");
        self:initAttackWeight({FLIGHT = 100});
        self:initSkillWeight({FLIGHT = 100});

    elseif stateName == self.STATE_FLIGHT_ENRAGED then
        self.isFlying = true;
        self.spValue = self.GD.addSP_rage;---addSPの量
        unit:setAttackDelay(self.GD.attackDelay_rage);---アタックディレイ
        ---物理回避率UP（BUFF_ID31が二重に乗らないよう両方解除してから付け直す）
        self:removeBuffByID(unit,self.BUFF_LIST[2].ID);
        self:removeBuffByID(unit,self.BUFF_LIST[3].ID);
        self:execAddBuff(unit,self.BUFF_LIST[3]);
        ---ダメージ無効化無効
        self:execAddBuff(unit,self.BUFF_LIST[1]);
        ---風を纏うエフェクトを常時表示
        self:switchWind("showWindAura");
        self:initAttackWeight({FLIGHT_ENRAGED = 100});
        self:initSkillWeight({FLIGHT_ENRAGED = 100});
    end
end

---飛行状態へ移行（HP50の氷結解除時）
function class:changeStateFlight(unit)
    if self.stateName == self.STATE_FLIGHT then return; end
    self:applyState(unit,self.STATE_FLIGHT);
    self:showMessage(self.FLIGHT_MESSAGE_LIST);
end

---飛行(怒り)状態へ移行（HP0の氷結解除時）
function class:changeStateFlightEnraged(unit)
    if self.stateName == self.STATE_FLIGHT_ENRAGED then return; end
    self:applyState(unit,self.STATE_FLIGHT_ENRAGED);
    self:showMessage(self.RAGE_FLIGHT_MESSAGE_LIST);
end

--- 風纏いエフェクトの表示切替（spineのwind_roopオービット）
function class:switchWind(status)
    ---一度も表示していないなら非表示指定は何もしない（無駄なオービット生成を避ける）
    if status == "hideWindAura" and self.windUnit == nil then return; end

    if self.windUnit == nil then
        self.windUnit = self.gameUnit:addOrbitSystem("wind_roop");
        self.windUnit:setAnimation(0,"wind_roop",true);
        self.windUnit:setPositionX(self.gameUnit:getAnimationPositionX());
        self.windUnit:setPositionY(self.gameUnit:getAnimationPositionY());
        self.windUnit:setZOrder(9998);
    end

    if status == "showWindAura" then
        self.isWind = true;
        self.windUnit:setAnimation(0,"wind_roop",true);
    elseif status == "hideWindAura" then
        self.isWind = false;
        self.windUnit:setAnimation(0,"enpty",true);---※spine側のアニメ名が"enpty"（既存実装9件と同じ綴り）
    end
end

--- 風纏いエフェクトをフレイダルに追従させる
function class:setWindPosition(unit)
    if self.isWind and self.windUnit ~= nil then
        self.windUnit:setPositionX(unit:getAnimationPositionX());
        self.windUnit:setPositionY(unit:getAnimationPositionY());
    end
end

---IDでバフを解除する
function class:removeBuffByID(unit,buffID)
    local count = 0;
    local cond = unit:getTeamUnitCondition():findConditionWithID(buffID);
    while cond ~= nil do
        unit:getTeamUnitCondition():removeCondition(cond);
        ---100回以上ループした場合はbreak
        count = count + 1;
        if count > 100 then
            break;
        end
        cond = unit:getTeamUnitCondition():findConditionWithID(buffID);
    end
end

---------------------------------------------------------------------------------
-- firstIn
---------------------------------------------------------------------------------
function class:firstIn(event)
    event.unit:setNextAnimationName("idle2")
    event.unit:setNextAnimationEffectName("empty")
    return 0;
end

---------------------------------------------------------------------------------
-- ギミックカラムの既定値
-- ※難易度違い（EASY/NORMAL）は inheritFromEnemy した上でこのメソッドを丸ごと上書きする
--   （ギミックカラムに項目を出すため、子でも全項目を宣言する）
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        addSP = 20,          ---地上状態のaddSP
        addSP_fly = 30,      ---飛行状態のaddSP
        addSP_rage = 40,     ---飛行(怒り)状態のaddSP
        startAddSP = 40,
        attackDelay = 10,      ---地上状態のattack_delay
        attackDelay_fly = 7,   ---飛行状態のattack_delay
        attackDelay_rage = 5,  ---飛行(怒り)状態のattack_delay
        hitStop = 100,

        tgTimer = 30,
        tgLimit = 99,
        tgIconNum1 = 77,
        tgIconNum2 = 0,
        tgPosX = 50,
        tgPosY = 0,
        tgScale = 1,
        deBuffTimeSpeed = 0.5,

        tgTimer_2 = 1,
        tgLimit_2 = 99,
        tgIconNum1_2 = 26,
        tgIconNum2_2 = 0,
        tgPosX_2 = -50,
        tgPosY_2 = 0,
        tgScale_2 = 1,

        --- カスタムギミック値
        buffVal_132 = 100,
        buffVal_31 = 150,
        buffVal_31_2 = 500,
        buffVal_112 = -30,
        subBarHP = 20000000,---エクストラゲージの破壊に必要なダメージ量（実数）
        hp0HpRate = 0.4,  ---setHPする倍率
        hp50CutInType = 1,---HP50の奥義カットイン種別（0=奥義カットイン / 1=真奥義カットイン）
        hp0CutInType = 1, ---HP0の奥義カットイン種別（0=奥義カットイン / 1=真奥義カットイン）
        hateIcon = 14,        ---ターゲットのフォーカスアイコン
        targetBuffValue_21 = 50,---ターゲットの被ダメージUP量(%)
        summonEnemyID = 4002511,---召喚するブルーゴブル(HARD)のエネミーID（0=召喚しない）
        summonCount = 4,      ---エクストラゲージ表示時に召喚するブルーゴブルの数
        buffVal_207 = 10,     ---氷衰の効果量（氷衰後遺症の値にも使う）
        freezeTimeAttack = 2, ---スキル3・スキル6の氷衰秒数
        freezeTimeSkill = 3,  ---奥義7・奥義8・奥義10の氷衰秒数
        freezePosOffsetX = 480,---初期位置のX方向オフセット（フレイダルの位置からの距離）
        freezeSequelaeFlg = 1,---氷衰後遺症（type234）を付けるか（1=付ける / 0=付けない）
        tgSubtractTimer = 1,  ---タイマーAが1周するたびに次周を短縮する秒数
        tgMinTimer = 20,      ---タイマーAの1周の下限秒数
        critDamageValue_17 = 20,---タイマーB1段あたりのクリティカルダメージUP量(%)
        critDamageMax = 20,     ---タイマーBの最大段数
        frostbiteFlg = 1,        ---凍傷ギミックの有効/無効（NORMAL/HARDのみ。1=有効 / 0=無効）
        frostbiteInterval = 1,   ---凍傷が1段積まれる間隔（秒）
        frostbiteHpValue = -2,   ---1段あたりの最大HP減少率(%)
        frostbiteAtkValue = -2,  ---1段あたりの攻撃力減少率(%)
        frostbiteHpMinValue = -98,---最大HP減少率の下限(%)。ここに達したら最大HPを1に固定する
        frostbiteIconMax = 99,   ---アイコンに表示する数値の上限（10%ごとに1）
        freezeTime = 20,      ---HPトリガー後にフレイダルが氷結する秒数（難易度別。HARD=20秒）
        freezeHpRegenValue_7 = 1,---氷結中のHP自然回復量（最大HPに対する割合(%)/秒）
        freezeTakeDamageRate = 0.01,---氷結中の被ダメージ補正（HPへ通るダメージ。エクストラゲージには等倍で入る）
    };
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, self:getGimmickDefault());
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    ---addSPとアタックディレイは下の applyState(地上状態) でまとめて設定する
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

    self:showMessage(self.START_MESSAGE_LIST);

    self.breakSkip = true;
    self.hpSkill = 0;
    self.saveBP = 0;

    ---状態変化（地上スタート → 飛行 → 飛行(怒り)の一方通行）
    self.tmpSkill = false;   ---着地奥義のtake_offを再生済みか
    self.hpTakeOffFlg = false;---HPトリガーの奥義前にtake_offを挟むか
    self.hpTakeOffSkill = 0; ---take_off後に発動する奥義のindex
    self.takeOffFlg = false; ---take_offを再生済みか（連続再生の防止）
    self.cutInType = 0;      ---HPトリガーの奥義カットイン種別
    self.windUnit = nil;     ---風纏いエフェクトのオービット
    self.isWind = false;     ---風纏いエフェクトを表示中か
    self:applyState(event.unit,self.STATE_GROUND);

    ---経過時間ギミック
    self.breakFlg = false;
    self.hpSkillFLG = false;
    self.timerAMaxTime = self.GD.tgTimer;---タイマーAの現在の1周の秒数（1周ごとに短縮する）

    ---凍傷ギミック（ユニットごとの氷結経過時間）
    self.frostbiteTimer = {};
    for i = 0,7 do
        self.frostbiteTimer[i] = 0;
    end
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    self.timeIndex2 = nil;
    self.timeSpeed2 = 1;

    ---ボスギミック
    ---ターゲットギミック（累計ダメージが最大のユニットをターゲットにする）
    self.targetUnitList = {};   ---[index] = {unit = ユニット, dps = 累計ダメージ}
    self.targetUnitIndex = 0;   ---現在のターゲットのチームindex
    self.targetUnit = nil;      ---現在のターゲットのユニット（氷衰の移動などで使う）
    self.targetSetFlg = false;  ---一度でもターゲットを設定したか
    self.needResetTargetDamage = false;---HPトリガーの奥義後に累計をリセットするか
    ---自動ヘイトは使わずLua側で全部設定する
    event.unit:setHateRate_Heal(0);
    event.unit:setHateRate_Damage(0);
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(self.GD.hateIcon);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();

    ---エクストラゲージ（サブバー）
    self.subBar = BattleControl:get():createSubBar();
    self.subBar:setWidth(200);
    self.subBar:setHeight(13);
    self.subBar:setPercent(0);
    self.subBar:setVisible(false);
    self.subBarHP = self.GD.subBarHP;---ボスのHP割合ではなく実数で指定する
    self.subBarDamage = 0;
    self.waitingStateFlg = false;
    self.chargeTimer = 0;
    self.chargeBallCount = 0;

    ---フレイダル氷結時ギミック
    self.freezeTimer = 0;       ---氷結の経過秒数
    self.freezeLimit = 0;       ---氷結が時間経過で解除される秒数
    self.nextStateName = nil;   ---氷結解除後に移行する状態
    self.pendingFreezeTime = 0; ---HPトリガーの奥義後に入る氷結の秒数
    self.pendingFreezeState = nil;---氷結解除後に移行する状態（予約）
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    ---開始時のターゲットを設定する（初弾から与ダメUPとフォーカス表示を一致させる）
    self:applyTargetUnit(event.unit);
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    self:extraTimerOperation(event.unit);
    self:setWindPosition(event.unit);---風纏いエフェクトの追従
    self:frostbiteCheck(event.deltaTime);---凍傷ギミック
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    ---待機（氷結）状態の管理
    if self.waitingStateFlg then
        self:subBarControll(event.unit, self.subBarDamage);
        self:freezeStateUpdate(event.unit, event.deltaTime);
    end

    ---奥義中の無敵解除対策
    if self.hpSkillFLG and event.unit:getUnitState() == kUnitState_skill then
        event.unit:setInvincibleTime(1);
    elseif self.hpSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
        event.unit:setInvincibleTime(0);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if event.index == self.timeIndex then
        ---タイマーA：パーティの状態異常耐性DOWN
        self:unitAddBuff(self.TG_BUFF_LIST[1]);
        self:unitAddBuff(self.TG_BUFF_LIST[2]);
        self:showMessage(self.TIMERA_MESSAGE_LIST);
        self:shortenTimerA();
    elseif event.index == self.timeIndex2 then
        ---タイマーB：1秒ごとにフレイダルのクリティカルダメージUP（段数はexecAddBuffがMAXまで加算する）
        self:execAddBuff(self.gameUnit, self.BUFF_LIST[4]);
    end
    return event.count;
end

---タイマーAの1周の時間を短縮する（下限は self.GD.tgMinTimer）
function class:shortenTimerA()
    if self.timeIndex == nil then
        return;
    end
    if self.timerAMaxTime <= self.GD.tgMinTimer then
        return;
    end
    self.timerAMaxTime = self.timerAMaxTime - self.GD.tgSubtractTimer;
    if self.timerAMaxTime < self.GD.tgMinTimer then
        self.timerAMaxTime = self.GD.tgMinTimer;
    end
    megast.Battle:getInstance():setExtraTimerMaxTime(self.timeIndex,self.timerAMaxTime);
end

function class:extraTimerOperation(unit)
    if self.timeIndex ~= nil then
        local _flg1 = 0
        if unit:getTeamUnitCondition():findConditionWithType(93) ~= nil then _flg1 = 1 end
        if unit:isBreak() or unit:getInvincibleTime() > 0 then _flg1 = 2 end
        if _flg1 == 2 then
            self.timeSpeed = 0
        elseif _flg1 == 1 then
            self.timeSpeed = 1 * self.GD.deBuffTimeSpeed
        else
            self.timeSpeed = 1
        end
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex, self.timeSpeed)
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        end
    end
end

function class:subBarControll(unit, damage)
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    self.subBar:setPercent(100 * (self.subBarHP - damage) / self.subBarHP);
    if self.subBarHP - damage <= 0 then
        if megast.Battle:getInstance():isHost() then
            self.subBarDamage = 0
            self:onSubBarDead();
            megast.Battle:getInstance():sendEventToLua(self.scriptID, 6, 1)
        end
    end
end

function class:receive6(args)
    self:onSubBarDead();
    return 1
end

--===================================================================================================================
-- フレイダル氷結時ギミック
--   HPトリガーの奥義を打ち終わると氷結状態に入り、エクストラゲージ（サブバー）を表示する。
--   氷結は「一定ダメージでゲージ破壊」か「一定時間経過」のどちらかで解除され、解除時に形態変化する。
--   氷結中はHPが自然回復する。プレイヤーが独自に氷結させた場合は waitingStateFlg が立たないので回復しない。
--===================================================================================================================
---氷結（待機）状態に入る
function class:startFreezeState(freezeTime,nextState)
    self.waitingStateFlg = true;---ホスト/ゲスト両方で立てる（ゲストでもゲージを表示する）
    self.freezeTimer = 0;
    self.freezeLimit = freezeTime;
    self.nextStateName = nextState;
    self.subBarDamage = 0;
    self.chargeTimer = 0;
    self.chargeBallCount = 0;

    ---行動中に氷結へ入るとモーションが残るので待機に戻し、行動フラグも初期化する
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.tmpSkill = false;
    self.takeOffFlg = false;
    self.gameUnit:takeIdle();

    ---フレイダル自身を氷結状態にする
    self.FREEZE_SELF_BUFF.DURATION = freezeTime;
    self:execAddBuff(self.gameUnit,self.FREEZE_SELF_BUFF);
    ---氷結中のHP自然回復
    self.FREEZE_REGEN_BUFF.DURATION = freezeTime;
    self:execAddBuff(self.gameUnit,self.FREEZE_REGEN_BUFF);
    megast.Battle:getInstance():updateConditionView();

    ---エクストラゲージ表示に合わせてブルーゴブルを召喚
    if megast.Battle:getInstance():isHost() then
        self:summonBlueGoble(self.gameUnit);
    end

    if nextState == self.STATE_FLIGHT_ENRAGED then
        ---HP0の氷結（2回目）
        self:showMessage(self.HP0_MESSAGE_LIST);
        ---タイマーBはHP0以降の氷結だけ表示する
        self.timeIndex2 = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer_2, self.GD.tgLimit_2, self.GD.tgIconNum1_2, self.GD.tgIconNum2_2, self.GD.tgPosX_2, self.GD.tgPosY_2, self.GD.tgScale_2);
        self.timeSpeed2 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex2);
        self:showMessage(self.TIMER2_MESSAGE_LIST);
    else
        ---HP50の氷結（1回目）
        self:showMessage(self.HP50_MESSAGE_LIST);
    end
end

---氷結中の毎フレーム処理（時間経過での解除判定）
function class:freezeStateUpdate(unit,deltaTime)
    self.freezeTimer = self.freezeTimer + deltaTime;

    ---時間経過で氷結解除
    if self.freezeTimer >= self.freezeLimit then
        if megast.Battle:getInstance():isHost() then
            self.subBarDamage = 0;
            megast.Battle:getInstance():sendEventToLua(self.scriptID, 6, 1);
        end
        self:onSubBarDead();
    end
end

--===================================================================================================================
-- 氷衰ギミック（ターゲットを初期位置に移動し、強制で氷衰状態（上位状態異常）にする）
-- ※execAddBuff は addCondition を直接呼ぶので状態異常耐性の判定を通らない＝「強制」になる
--===================================================================================================================
function class:execFreezeUpward(buffBox)
    ---ターゲットギミックが保持しているターゲットユニットをそのまま使う
    local target = self.targetUnit;
    if target == nil then
        return;
    end
    self:setFreezeUpwardPosition(target);
    self:execAddBuff(target,buffBox);
    ---氷衰後遺症（207側の付与成功判定が動かないので手動で付ける）
    if self.GD.freezeSequelaeFlg == 1 then
        self:setFreezeSequelae(target,buffBox.VALUE);
    end
    megast.Battle:getInstance():updateConditionView();
    ---スキル3・6／奥義7・8・10のどれで発動しても表示する
    self:showMessage(self.FREEZE_MESSAGE_LIST);
end

---ユニット氷衰,初期位置移動（ターゲットのみを動かす）
---※X方向だけフレイダルの位置から freezePosOffsetX ぶん離した位置へ動かす。
---  Yはフレイダルが飛行状態だと高くなるので触らず、ユニットの現在値を維持する。
---  1体しか動かさないので重なり回避のランダムは入れない（ホスト/ゲストで位置がズレるのを防ぐ）
function class:setFreezeUpwardPosition(unit)
    local x = self.gameUnit:getPositionX();
    unit:setPosition(x + self.GD.freezePosOffsetX,unit:getPositionY());
end

---氷衰後遺症（type234）を1段積む
function class:setFreezeSequelae(target,value)
    local ntype = 234;
    local icon = 326;
    local cond = target:getTeamUnitCondition():findConditionWithType(ntype);
    if cond == nil then
        local buff = target:getTeamUnitCondition():addCondition(-1,ntype,value,-1,icon,0);
        if buff ~= nil then
            buff:setNumber(1);
            buff:setValue( buff:getValue() );
            buff:setScriptID(603);
            target:setParameter("234_Sequelae_Freeze",""..1);
        end
    else
        local num = cond:getNumber() + 1;
        if num <= 10 then
            cond:setNumber(num);
            target:setParameter("234_Sequelae_Freeze",""..num);
        end
    end
end

---ブルーゴブルを self.GD.summonCount 体召喚する
function class:summonBlueGoble(unit)
    if self.GD.summonEnemyID == 0 then
        return;---エネミーID未設定
    end
    for i = 1,self.GD.summonCount do
        self:enemySummon(unit,self.GD.summonEnemyID);
    end
end

---エネミーを1体召喚する（空いているスロットに入れる。ホストのみ）
function class:enemySummon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0,6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                ---指定したインデックスの位置に指定したエネミーIDのユニットを出す
                return unit:getTeam():addUnit(i,unitID);
            end
        end
    end
    return nil;
end

---氷結解除（エクストラゲージ破壊 or 時間経過）
function class:onSubBarDead()
    if not self.waitingStateFlg then
        return;---二重解除を防ぐ
    end
    self.waitingStateFlg = false;
    self.subBar:setVisible(false);
    self.freezeTimer = 0;
    self.subBarDamage = 0;

    ---フレイダルの氷結とHP自然回復を解除する
    self:removeBuffByID(self.gameUnit,self.FREEZE_SELF_BUFF.ID);
    self:removeBuffByID(self.gameUnit,self.FREEZE_REGEN_BUFF.ID);
    self:refresh(self.gameUnit);---停止系状態異常除去（氷結のまま動かなくなるのを防ぐ）
    megast.Battle:getInstance():updateConditionView();

    ---タイマーBを非表示にする
    ---※積み上げたクリティカルダメージUP（BUFF_LIST[4]）はここでは解除しない。
    ---  仕様書は「氷結が解けるタイミングでタイマーを非表示にする」だけで、バフは残る
    if self.timeIndex2 then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex2, 1, 0, true);
        self.timeIndex2 = nil;
    end

    ---氷結解除後の形態変化
    local nextState = self.nextStateName;
    self.nextStateName = nil;
    if nextState == self.STATE_FLIGHT then
        self:changeStateFlight(self.gameUnit);
    elseif nextState == self.STATE_FLIGHT_ENRAGED then
        self:changeStateFlightEnraged(self.gameUnit);
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end

    ---※spineの showWindAura / hideWindAura はフックしない。
    ---  フックすると飛行状態のモーション中にイベントが飛んだ時点で風を纏ってしまう。
    ---  風纏いは怒り状態専用なので applyState からのみ切り替える

    if event.spineEvent == "takeOffEnd" then
        ---take_off再生中でなければ何もしない（既に奥義が出ている＝二重発動を防ぐ）
        if self.takeOffFlg then
            self.takeOffFlg = false;
            if self.hpTakeOffFlg then
                ---HPトリガー由来：take_off後に指定の奥義を撃つ
                self.hpTakeOffFlg = false;
                self.tmpSkill = true;
                event.unit:takeSkill(self.hpTakeOffSkill);
            else
                ---着地状態の通常奥義：抽選を進めずに同じ奥義を撃ち直す
                self:skillReroll(event.unit,true);
            end
        end
    end

    return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    ---氷結（待機）中は行動させない
    if self.waitingStateFlg then
        event.unit:takeIdle();
        return 0;
    end

    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end

    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    --if event.index == 1 then
    --    event.unit:setNextAnimationName("attack1");
    --    event.unit:setNextAnimationEffectName("1-attack1");
    --end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.hpSkillFLG = false;
        self.afterSkillFLG = false;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
        self:checkAfterHpSkill();
    end

    ---氷衰ギミック（スキル3・スキル6）
    if self.FREEZE_ATTACK_INDEXES[event.index] then
        self:execFreezeUpward(self.FREEZE_BUFF_LIST[1]);
    end

    ---通常攻撃に戻ったら着地奥義のtake_off済みフラグをリセット
    ---※take_off再生中は触らない（リセットされると次のtakeSkillで再生し直してしまう）
    if not self.takeOffFlg then
        self.tmpSkill = false;
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

---【MEGA_D-9761】take_off の後の skillReroll(unit, true) が撃つ技の番号を、乱数を引かずに読む（溜め予告に使う）。
---hpSkill があればそれ、無ければ今の段の候補（候補が 1 つの段だけ。2 つ以上なら分からないので nil）。getSkillIndex は乱数を引くので呼ばない
function class:peekRerollSkillIndex()
    if self.hpSkill ~= nil and self.hpSkill ~= 0 then return tonumber(self.hpSkill) end
    local set = self.SKILL_SET_LIST[self.STATE_SKILL.setChar]
    local step = set and set[self.STATE_SKILL.actCount]
    if step == nil then return nil end
    local only = nil
    for key, _ in pairs(step) do
        if only ~= nil then return nil end
        only = key
    end
    if only == nil then return nil end
    return tonumber((string.gsub(only, "SKILL", "")))
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    ---氷結（待機）中は行動させない
    if self.waitingStateFlg then
        event.unit:takeIdle();
        return 0;
    end

    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit,false);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    ---HPトリガーの奥義：take_offを挟んでから撃つ
    ---※takeOffFlgで「再生済み」を管理する。これが無いと takeOffEnd が来る前に takeSkill が
    ---  再入するたびに take_off を再生してしまい連発になる
    if self.hpTakeOffFlg and not self.takeOffFlg then
        self.takeOffFlg = true;
        ---【MEGA_D-9761】take_off の後に撃つ技（takeOffEnd → takeSkill(self.hpTakeOffSkill)）を予告して、溜め予告を出す。古いアプリには無いので確かめてから呼ぶ
        local announcedSkill = self.ACTIVE_SKILLS["SKILL"..tostring(self.hpTakeOffSkill)];
        if announcedSkill and event.unit.announceSkill then event.unit:announceSkill(announcedSkill, "skill"..tostring(self.hpTakeOffSkill)) end
        event.unit:takeAnimation(0,"take_off",false);
        event.unit:takeAnimationEffect(0,"empty",false);
        return 0;
    end

    ---着地状態の奥義：take_offを挟んでから撃つ
    if not self.isFlying and not self.tmpSkill and not self.takeOffFlg then
        self.tmpSkill = true;
        self.takeOffFlg = true;
        ---【MEGA_D-9761】take_off の後に撃つ技（takeOffEnd → skillReroll(unit, true) が選び直す技。event.index とずれることがある）を予告して、溜め予告を出す。古いアプリには無いので確かめてから呼ぶ
        local rerollIndex = self:peekRerollSkillIndex();
        local announcedSkill = rerollIndex and self.ACTIVE_SKILLS["SKILL"..tostring(rerollIndex)];
        if announcedSkill and event.unit.announceSkill then event.unit:announceSkill(announcedSkill, "skill"..tostring(rerollIndex)) end
        event.unit:takeAnimation(0,"take_off",false);
        event.unit:takeAnimationEffect(0,"empty",false);
        return 0;
    end

    ---HPトリガーの奥義カットイン
    if self.cutInFLG then
        self.cutInFLG = false;
        event.unit:takeSkillWithCutin(event.index,self.cutInType);
        return 0;
    end

    ---氷衰ギミック（奥義7・奥義8・奥義10）
    if self.FREEZE_SKILL_INDEXES[event.index] then
        self:execFreezeUpward(self.FREEZE_BUFF_LIST[2]);
    end

    ---奥義が実際に出るのでtake_off関連のフラグを下ろす
    self.takeOffFlg = false;
    self.hpTakeOffFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1;
end

function class:skillReroll(unit,flg)
    local skillIndex = self:getSkillIndex();
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill;
        self.hpSkill = 0;
    elseif not flg then
        ---flg=true は take_off後の撃ち直しなので抽選を進めない
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL);
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

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return event.value;
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return event.value;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);

    if self.waitingStateFlg then
        ---待機（氷結）状態中はエクストラゲージに補正前のダメージを入れる
        if megast.Battle:getInstance():isHost() then
            self.subBarDamage = self.subBarDamage + event.value
            megast.Battle:getInstance():sendEventToLua(self.scriptID, 8, math.floor(self.subBarDamage))
        end
        ---HPへ通るダメージだけを補正する
        event.value = event.value * self.GD.freezeTakeDamageRate;
    else
        event.value = self:adjustHpFlg(event.unit,event.value);
    end

    ---ターゲット処理（実際にHPへ通ったダメージで累計して首位を判定する）
    self:updateTargetUnit(event.unit,enemyUnit,event.value);
    return event.value;
end

--===================================================================================================================
-- 凍傷ギミック（氷結にかかった時間が長いほどユニットの最大HP・攻撃力が低下する）
--   永続・死亡以外で解除不可。10%ごとにアイコンへ数値表示。
--   最大HPは割合で減らせなくなったら固定値バフで1に固定する
--===================================================================================================================
---氷結中のユニットに凍傷を積む
function class:frostbiteCheck(deltaTime)
    if self.GD.frostbiteFlg ~= 1 then
        return;
    end
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,7 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil and teamUnit:getTeamUnitCondition():findConditionWithType(96) ~= nil then
            self.frostbiteTimer[i] = self.frostbiteTimer[i] + deltaTime;
            if self.frostbiteTimer[i] >= self.GD.frostbiteInterval then
                ---端数は次に繰り越す
                self.frostbiteTimer[i] = self.frostbiteTimer[i] - self.GD.frostbiteInterval;
                self:addFrostbite(teamUnit);
            end
        end
    end
end

---凍傷を1段積む
function class:addFrostbite(teamUnit)
    self:execAddFrostbiteBuff(teamUnit,self.FROSTBITE_BUFF_LIST[1],self.GD.frostbiteHpMinValue);
    self:execAddFrostbiteBuff(teamUnit,self.FROSTBITE_BUFF_LIST[2],nil);
    megast.Battle:getInstance():updateConditionView();
end

---凍傷バフを累積させる（minValueを渡すとそこで下限クランプする）
function class:execAddFrostbiteBuff(teamUnit,buffBox,minValue)
    local cond = teamUnit:getTeamUnitCondition();
    local oldBuff = cond:findConditionWithID(buffBox.ID);
    local buffValue = buffBox.VALUE;
    if oldBuff ~= nil then
        buffValue = oldBuff:getValue() + buffBox.VALUE;
    end

    ---最大HPは割合でこれ以上減らせないので下限で止めて1固定に切り替える
    if minValue ~= nil and buffValue <= minValue then
        buffValue = minValue;
        self:setFrostbiteHpFix(teamUnit);
    end

    local buff = cond:addCondition(buffBox.ID,buffBox.BUFF_ID,buffValue,buffBox.DURATION,buffBox.ICON);
    if buff == nil then
        return;
    end

    ---10%ごとにアイコンへ数値を表示する
    local count = math.floor(buffValue / 10 * -1);
    if count > buffBox.MAX then
        count = buffBox.MAX;
    end
    if count > 0 then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
    end
end

---最大HPを1に固定する（割合ではこれ以上減らせない場合）
function class:setFrostbiteHpFix(teamUnit)
    local buffBox = self.FROSTBITE_BUFF_LIST[3];
    local cond = teamUnit:getTeamUnitCondition();
    if cond:findConditionWithID(buffBox.ID) ~= nil then
        return;---既に適用済み
    end
    local fixValue = 1 - teamUnit:getCalcHPMAX();
    if fixValue >= 0 then
        return;
    end
    cond:addCondition(buffBox.ID,buffBox.BUFF_ID,fixValue,buffBox.DURATION,buffBox.ICON);
end

--===================================================================================================================
-- ターゲットギミック（累計ダメージが最大のユニットをターゲットにし、そのユニットへの与ダメージをUP）
-- ※累計はengineのヘイト機構ではなくLua側で保持する。ホストだけが首位を判定してゲストへ配信する
--===================================================================================================================
---累計ダメージを加算してターゲットを更新する
function class:updateTargetUnit(unit,enemyUnit,value)
    ---ユニットのダメージをテーブルに格納（キーは交代しても衝突しない値にする）
    ---※table.insertは位置指定になってしまうので使わない
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10);
    if self.targetUnitList[index] == nil then
        self.targetUnitList[index] = {unit = enemyUnit,dps = value};
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + value;
    end

    self:applyTargetUnit(unit);
end

---首位を判定してターゲットを設定する（ホストのみ判定し、ゲストへ配信する）
function class:applyTargetUnit(unit)
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    ---ヘイトは全部手動で設定する
    local target = self:checkTargetUnit();
    if target == nil then
        return;
    end
    ---首位が変わったときだけ配信する（毎ヒット配信するとマルチの通信量が増える）
    if self.targetSetFlg and target:getIndex() == self.targetUnitIndex then
        return;
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,7,target:getIndex());---ゲストにターゲットを送る
    self:setTargetUnit(unit,target:getIndex());
end

---ターゲットを設定する（ホスト/ゲスト共通）
function class:setTargetUnit(unit,targetIndex)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local target = myTeam:getTeamUnit(targetIndex);
    if target == nil then
        return;
    end
    self.targetUnitIndex = targetIndex;
    self.targetUnit = target;---氷衰の移動などで参照する
    self.targetSetFlg = true;
    unit:setHateTarget(target);
    unit:updateHateTarget();---setHateTargetの直後に必ず呼ぶ（片方だけだとsignal 11になる）
    self:updateTargetBuff(myTeam,targetIndex);
end

---ターゲットの被ダメージUPデバフを貼り替える（ターゲット以外からは剥がす）
---※フォーカス設定（setHateTarget）の後に呼ぶ
function class:updateTargetBuff(myTeam,targetIndex)
    for i = 0,7 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if i == targetIndex then
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST[1]);
            else
                self:removeBuffByID(myTeamUnit,self.TARGET_BUFF_LIST[1].ID);
            end
        end
    end
    megast.Battle:getInstance():updateConditionView();
end

-- 累計ダメージが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil;
    local targetTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            target = myTeamUnit;
            break;
        end
    end
    local val = 0;
    for i,v in pairs(self.targetUnitList) do
        ---死亡・交代したユニットの累計は無効にする
        if v.unit == nil or v.unit:getHP() < 1 then
            v.dps = 0;
        end
        if v.dps > val then
            val = v.dps;
            target = v.unit;
        end
    end
    return target;
end

---HPトリガーの奥義が打ち終わったタイミングの後処理（累計リセット → 氷結状態へ移行）
function class:checkAfterHpSkill()
    if self.needResetTargetDamage then
        self.needResetTargetDamage = false;
        self:resetTargetDamage();
    end
    if self.pendingFreezeTime > 0 then
        local freezeTime = self.pendingFreezeTime;
        local nextState = self.pendingFreezeState;
        self.pendingFreezeTime = 0;
        self.pendingFreezeState = nil;
        self:startFreezeState(freezeTime,nextState);
    end
end

---ターゲットの累計ダメージをリセットする
---※全ユニットの累計を破棄する解釈で実装（首位のみ破棄にする場合は該当要素のdpsだけ0にする）
function class:resetTargetDamage()
    self.targetUnitList = {};
    self.targetSetFlg = false;---リセット後は必ず貼り直す
    self:applyTargetUnit(self.gameUnit);
end

---------------------------------------------------------------------------------
-- receive7(ターゲット同期時ゲスト側)
---------------------------------------------------------------------------------
function class:receive7(args)
    self:setTargetUnit(self.gameUnit,args.arg);
    return 1;
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value;
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01;
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit); ---停止系状態異常除去(このタイミングでないとたまにバグる)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value);
        end
    end
    return value;
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true;
    return unit:getHP() - border + 1;
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit;
    else
        return self:getAncestorUnit(unit:getParentTeamUnit());
    end
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
    return 1;
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.afterSkillFLG then
            self.gameUnit:setInvincibleTime(0);
            self.hpSkillFLG = false;
            self:checkAfterHpSkill();
        end
    end
    ---take_off再生中は待機モーションで上書きしない
    ---※上書きすると take_off が途中で切れて takeOffEnd が飛ばず、奥義が出ないまま再生を繰り返す
    if self.takeOffFlg then
        return 1;
    end
    ---地上状態は待機モーションが idle2
    if self.isFlying then
        event.unit:setNextAnimationName("idle");
    else
        event.unit:setNextAnimationName("idle2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- damage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    ---地上状態は被弾モーションが damage2
    if self.isFlying then
        event.unit:setNextAnimationName("damage");
    else
        event.unit:setNextAnimationName("damage2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex, 1, 0, true);
        self.timeIndex = nil
    end
    if self.timeIndex2 ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex2, 1, 0, true);
        self.timeIndex2 = nil
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 4, 1)
    return 1
end

function class:receive4(args)
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex, 1, 0, true);
        self.timeIndex = nil
    end
    if self.timeIndex2 ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex2, 1, 0, true);
        self.timeIndex2 = nil
    end
    return 1
end


--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList);
        return
    end
    self:execShowMessage(messageBoxList[index]);
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox);
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i]);
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

function class:showFormatMessage(messageBox,str)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    end
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:hpTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            if not trigger.isEnableSkip then
                ---通常マーカーはブレイク中は発動しない
                if not unit:isBreak() then
                    self:execTrigger(index);
                end
            else
                ---ブレイクスルー
                self:execTrigger(index);
            end
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return;
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3;
    local action = "use" .. receiveNumber;
    self.TRIGGERS[index].used = true;

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true);
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index);
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP]);
    end

    self.TRIGGERS[index].action(action);
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index);
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true;
    self.TRIGGERS[args.arg].action("use3");
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP]);
    return 1;
end

---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true;
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true);
    end
    return 1;
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

    local oldBuff = nil;
    local count = 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1;
            if count > buffBox.MAX then
                count = buffBox.MAX;
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
    end

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff);
    end
end

function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1;
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1;
        stateBox.setCount = stateBox.setCount + 1;
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1;
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount]);
    end
end

class.STATE_ATTACK = {};
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...};
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT);
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex);
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...};
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT);
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex);
end

function class:initState(weightList)
    local state = {};
    state.SET_WEIGHT = weightList;
    state.actCount = 1;
    state.setCount = 1;
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount]);
    return state;
end

---トリガー時停止系状態異常除去（HPギミックが状態異常で発動できないことを防ぐ）---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0;
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1;
            if count > 100 then
                break;
            end
        end
    end
end

---HPトリガー時の全状態異常回復（仕様書に「状態異常を回復」とある場合に使用）---
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


function class:unitAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0, 3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit, buffBox)
        end
    end
end

class:publish();

return class;
