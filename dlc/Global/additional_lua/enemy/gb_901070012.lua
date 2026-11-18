local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星15_CODE XTF:SEEKER", version=2.7, id="gb_901070012"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    --盾あり：スキル1 -> (スキル1 or スキル2) -> スキル3 -> (スキル1 or スキル2 or スキル3) -> 繰り返し
    SHIELD = {
        { ATTACK1 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50 }
    },
    --盾無し：スキル4 -> (スキル4 or スキル5) -> スキル6 -> (スキル4 or スキル5) -> (スキル4 or スキル6) -> 繰り返し
    ATTACK = {
        { ATTACK4 = 50 },
        { ATTACK4 = 50, ATTACK5 = 50 },
        { ATTACK6 = 50 },
        { ATTACK4 = 50, ATTACK5 = 50 },
        { ATTACK4 = 50, ATTACK6 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    --盾あり：奥義7 -> 奥義8 -> 繰り返し
    SHIELD = {
        { SKILL2 = 50 },
        { SKILL3 = 50 }
    },
    --盾無し：奥義9 -> 奥義10 -> 繰り返し
    ATTACK = {
        { SKILL4 = 50 },
        { SKILL5 = 50 }
    },
    --HP0%（★15）：奥義10 -> 繰り返し
    HP0 = {
        { SKILL5 = 50 }
    }
}

--takeSkill(N) は spine の skillN を再生するので、SKILL のキー番号を spine に合わせる（skill1 はファンネル召喚のみで使わない）
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,    --ヴァルカン（attack1）
    ATTACK2 = 2,    --ファンネルレーザー（attack2。ダメージはファンネルの着弾オービット）
    ATTACK3 = 3,    --バリアアタック（attack3）
    ATTACK4 = 4,    --ミサイル（attack4。ダメージはミサイル弾）
    ATTACK5 = 5,    --サブアームレーザー（attack5。ダメージは着弾オービット）
    ATTACK6 = 6,    --メインアームビーム（attack6）
    SKILL2 = 7,     --クラッシュコミットメント（skill2。ダメージはボール弾）
    SKILL3 = 8,     --イレイサーキャノン（skill3）
    SKILL4 = 9,     --ユリ＝バニラ（skill4）
    SKILL5 = 10     --イグジスト＝バニラ（skill5）
}

--奥義はすべて真奥義カットイン
class.cutInSkill = {
    [2] = 1,
    [3] = 1,
    [4] = 1,
    [5] = 1
}

---HPトリガーの奥義は発動から打ち終わるまで無敵（打ち終えた後の takeIdle / takeAttack で解除する）
class.HP_SKILL_INVINCIBLE_TIME = 20

---★12 HP0%：奥義を打ち終えたら戦闘不能。奥義が出ないまま止まったときに倒す保険の秒数
class.LAST_SKILL_LIMIT_TIME = 20

---タイマーの種類（出したHPトリガー）
class.TIMER_HP80 = 1
class.TIMER_HP50 = 2
class.TIMER_HP30 = 3
class.TIMER_HP0 = 4

---盾あり（SHIELD）／盾無し（ATTACK）で再生するアニメ
---spine に素の back / damage が無い（再生が終わらず行動が止まる）ので、モードに合わせて必ず差し替える
class.MODE = {
    SHIELD = {
        idle = "idle",
        effectIdle = "idle1",
        back = "back1",
        damage = "damage_B",
        out = "out",
        setup = "setUp1",
        setupEffect = "setUpBarrier"
    },
    ATTACK = {
        idle = "idle2",
        back = "back2",
        damage = "damage_S",
        out = "out2",
        setup = "setUp2",
        setupEffect = "",
        enter = "barrier_off",
        enterEffect = "barrier_off",
        popKey = "text1",
        pop = "攻撃モード"
    }
}

---ファンネル（orbitType 2 はプレイヤーが撃墜できる）
class.FUNNEL = {
    ANIM = "funnelIdle",
    DEAD_ANIM = "funnelDead",
    LASER_ANIM = "funnelLaser",
    HIT_ANIM = "laserHit",
    ORBIT_TYPE = 2,
    SPAWN_X = -80,      --召喚位置（ボス位置から）
    SPAWN_Y = 400,
    CENTER_Y = 300,     --周回の中心の高さ（ボス位置から）
    RADIUS = 200,       --周回半径
    ENTER_FRAMES = 46,  --登場移動のフレーム数（60fps 換算）
    ENTER_BOOST = 10,   --登場移動の速度 = 1 + 残り割合 × ENTER_BOOST
    CORE_SPEED = 1.5,   --周回の基準角の回転（度/フレーム）
    IDLE_TURN = 4,      --周回中の旋回上限（度/フレーム）
    IDLE_SHRINK = 3     --周回半径へ寄る速さ（px/フレーム）
}

---ボール（skill2）
class.BALL = {
    ANIM = "ball",
    END_ANIM = "ballExplosion",
    BONE = "L_barrier_hand_root",
    OFFSET_X = -50,
    LIFE = 600,         --寿命（60fps 換算のフレーム数）
    TURN = 1,           --旋回上限（度/フレーム）
    SPEED = 2           --速度（px/フレーム）
}

---ミサイル（attack4）：上昇 → ターゲットの真上で停止 → 急降下
class.MISSILE = {
    ANIM = "missile",
    END_ANIM = "missileExplosion",
    BONE = "C_weapon_maingun",
    Z_OFFSET = -5030,
    RISE_FRAMES = 30,   --45度で減速して上がる区間の終わり
    ACCEL_FRAMES = 120, --加速して上がる区間の終わり
    WARP_END = 125,     --ターゲットの真上で止まる区間の終わり
    LIFE = 600,
    RISE_ANGLE = 45,
    DIVE_ANGLE = -90,
    DIVE_SPEED = 40,
    DIVE_TURN = 3,
    BOOST = 12
}

---照準レーザー（attack5）で回す砲身ボーン（綴りは spine どおり）
class.AIM_BONES = {
    "R_weapon_gunbarrel_upper",
    "R_weapon_arm_gunbarre_center",
    "R_weapon_gunbarrel_lower",
    "L_weapon_gunbarrel_upper",
    "L_weapon_gunbarrel_canter",
    "L_weapon_gunbarrel_lower"
}

class.ONE_FRAME = 0.016666667
class.PI = 3.14         --原典の弾道と同じ軌跡にするため 3.14 で計算する
class.ORBIT_LAZER = 0   --kOrbitType_Lazer（被弾対象にならず、ヒットしても消えない型）

--------[[バフ]]--------
function class:setBuffBoxList()
    ---スキル3・スキル6：プレイヤーユニットの被ダメージアップ
    self.ATTACK_BUFF = {
        ID = 9010701,
        BUFF_ID = 21,  --被ダメ
        VALUE = self.GD.attackBuffValue_21,
        DURATION = 999999,
        ICON = 139,
        MAX = 99
    }
    ---奥義8・奥義10：プレイヤーユニットの最大HPダウン
    self.SKILL_BUFF = {
        ID = 9010702,
        BUFF_ID = 1,  --最大HP
        VALUE = self.GD.skillBuffValue_1,
        DURATION = 999999,
        ICON = 2,
        MAX = 99
    }
    self.HP_BUFF = {
        [1] = {
            ID = 9010703,
            BUFF_ID = 23,  --クリティカル耐性
            VALUE = self.GD.hp50BuffValue_23,
            DURATION = 999999,
            ICON = 188
        },
        [2] = {
            ID = 9010704,
            BUFF_ID = 27,  --被ブレイク（マイナスでブレイク耐性アップ）
            VALUE = self.GD.hp30BuffValue_27,
            DURATION = 999999,
            ICON = 9
        }
    }
    ---エクストラゲージ破壊時の気絶
    self.STUN_BUFF = {
        ID = 9010705,
        BUFF_ID = 89,  --気絶
        VALUE = 100,
        DURATION = self.GD.exGaugeStunTime,
        ICON = 0
    }
    ---タイマー1周ごとの効果
    self.TIMER_BUFF_LIST = {
        [1] = {
            ID = 9010711,
            BUFF_ID = 54,  --麻痺耐性
            VALUE = self.GD.timerHp80BuffValue_54,
            DURATION = 999999,
            ICON = 70,
            MAX = 20
        },
        [2] = {
            ID = 9010712,
            BUFF_ID = 103,  --麻痺回避率
            VALUE = self.GD.timerHp80BuffValue_54,
            DURATION = 999999,
            ICON = 0,
            MAX = 20
        },
        [3] = {
            ID = 9010713,
            BUFF_ID = 22,  --クリティカル率
            VALUE = self.GD.timerHp50BuffValue_22,
            DURATION = 999999,
            ICON = 11,
            MAX = 20
        },
        [4] = {
            ID = 9010714,
            BUFF_ID = 54,  --麻痺耐性
            VALUE = self.GD.timerHp30BuffValue_54,
            DURATION = 999999,
            ICON = 70,
            MAX = 20
        },
        [5] = {
            ID = 9010715,
            BUFF_ID = 103,  --麻痺回避率
            VALUE = self.GD.timerHp30BuffValue_54,
            DURATION = 999999,
            ICON = 0,
            MAX = 20
        },
        [6] = {
            ID = 9010716,
            BUFF_ID = 17,  --与ダメ（SCRIPT_ID 22 でクリティカルダメージ限定）
            VALUE = self.GD.timerHp0BuffValue_17,
            DURATION = 999999,
            ICON = 26,
            MAX = 20,
            SCRIPT = {
                SCRIPT_ID = 22
            }
        }
    }
    ---タイマーの種類ごとの効果（value が0なら効果なし。isPlayer はプレイヤーユニット全員、それ以外はボス自身）
    self.TIMER_SETTING = {
        [self.TIMER_HP80] = {
            value = self.GD.timerHp80BuffValue_54,
            isPlayer = true,
            buffs = { self.TIMER_BUFF_LIST[1], self.TIMER_BUFF_LIST[2] },
            message = 2
        },
        [self.TIMER_HP50] = {
            value = self.GD.timerHp50BuffValue_22,
            isPlayer = false,
            buffs = { self.TIMER_BUFF_LIST[3] },
            message = 3
        },
        [self.TIMER_HP30] = {
            value = self.GD.timerHp30BuffValue_54,
            isPlayer = true,
            buffs = { self.TIMER_BUFF_LIST[4], self.TIMER_BUFF_LIST[5] },
            message = 4
        },
        [self.TIMER_HP0] = {
            value = self.GD.timerHp0BuffValue_17,
            isPlayer = false,
            buffs = { self.TIMER_BUFF_LIST[6] },
            message = 5
        }
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "与ダメージの大きい者へのダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "与ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "パーティの種族が多いほど、ボスへのダメージがアップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "パーティの属性が多いほど、奥義ゲージ上昇量アップ", COLOR = Color.red})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "パーティの最大HPダウン", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE2 or "%sユニットの奥義ゲージダウン", COLOR = Color.red})
    }
    self.EX_GAUGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE1 or "特殊防壁展開：SEEKERへのダメージを大幅軽減", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE2 or "一定ダメージで解除、ブレイクダメージで破壊可能", COLOR = Color.red})
    }
    self.EX_GAUGE_BROKEN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_BROKEN_MESSAGE1 or "特殊防壁解除成功！", COLOR = Color.red})
    }
    self.TIMER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIMER_MESSAGE1 or "特殊防壁展開時間が長いほど、SEEKERが強化", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.TIMER_MESSAGE2 or "時間経過でパーティの麻痺耐性ダウン", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.TIMER_MESSAGE3 or "時間経過でSEEKERクリティカル率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.TIMER_MESSAGE4 or "時間経過でパーティの麻痺耐性ダウン", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.TIMER_MESSAGE5 or "時間経過でSEEKERのCRIダメージアップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "クリティカル耐性アップ", COLOR = Color.red})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "HP回復・奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.RACE_MESSAGE_LIST = {
        [0] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE0 or "種族なし", COLOR = Color.red}),
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE1 or "人族", COLOR = Color.red}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE2 or "獣人族", COLOR = Color.red}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE3 or "精霊族", COLOR = Color.red}),
        [4] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE4 or "巨人族", COLOR = Color.red}),
        [5] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE5 or "機族", COLOR = Color.red}),
        [6] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE6 or "竜族", COLOR = Color.red}),
        [7] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE7 or "神族", COLOR = Color.red}),
        [8] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE8 or "魔族", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {}
    if self.GD.difficultyLevel >= 6 then
        table.insert(self.TRIGGERS, {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
            used = false,
            isEnableSkip = false
        })
    end
    if self.GD.difficultyLevel >= 9 then
        table.insert(self.TRIGGERS, {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        })
    end
    self.HP0_TRIGGER_INDEX = nil
    if self.GD.difficultyLevel >= 12 then
        table.insert(self.TRIGGERS, {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false,
            isEnableSkip = false
        })
        table.insert(self.TRIGGERS, {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
            used = false,
            isEnableSkip = false
        })
        self.HP0_TRIGGER_INDEX = table.maxn(self.TRIGGERS)
    end

    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

---HP80%：状態異常を回復＆奥義7を発動＆エクストラゲージ・タイマー表示
function class:hp80(status)
    if status == "use3" then
        self:hpSkillStart(2,self.TIMER_HP80)
    end
end

---HP50%：状態異常を回復＆攻撃モードへ変形→続けて奥義9を発動＆クリティカル耐性アップ＆エクストラゲージ・タイマー表示
---ボスは奥義ゲージが満タンになると行動の途中でも奥義を出すので、ゲージは変形を終えてから満たす（excuteAction）
function class:hp50(status)
    if status == "use3" then
        self:hpSkillStart(nil,self.TIMER_HP50)
        self.transformReserve = true
        self:showMessage(self.HP50_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.HP_BUFF[1])
    end
end

---HP30%：状態異常を回復＆奥義9を発動＆ブレイク耐性アップ＆addSP＆エクストラゲージ・タイマー表示
function class:hp30(status)
    if status == "use3" then
        self:hpSkillStart(4,self.TIMER_HP30)
        self:showMessage(self.HP30_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.HP_BUFF[2])
        self.spValue = self.GD.hp30AddSP
    end
end

---HP0%：状態異常を回復＆奥義9を発動
---★15：HP回復＆行動パターン変化＆addSP＆エクストラゲージ・タイマー表示。奥義ゲージは引き継がない
---★12：奥義を打ち終えたら戦闘不能
function class:hp0(status)
    if status == "use3" then
        if self.GD.difficultyLevel >= 15 then
            self:hpSkillStart(4,self.TIMER_HP0)
            self.saveBP = 0
            self.gameUnit:takeHeal(self.gameUnit:getCalcHPMAX() * self.GD.hp0HealRate - self:getUnitHP(self.gameUnit))
            self:initSkillWeight({HP0 = 100})
            self.spValue = self.GD.hp0AddSP
            self:showMessage(self.HP0_MESSAGE_LIST)
        else
            self:hpSkillStart(4,nil)
            self.lastSkillReserve = true
            self.lastSkillTime = 0
        end
    end
end

---HPトリガー共通：状態異常を回復し、奥義ゲージを退避して奥義を発動する
---hpSkill が nil のときは奥義をまだ出さない（満タンのままだと即座に奥義が出るので、ゲージは空にしておく）
---表示中のエクストラゲージ・タイマーは消し、奥義を打ち終えたら timerKind のものを出し直す
function class:hpSkillStart(hpSkill,timerKind)
    if megast.Battle:getInstance():isHost() then
        self.saveBP = self.gameUnit:getBurstPoint()
        if hpSkill ~= nil then
            self.hpSkill = hpSkill
            self.gameUnit:addSP(100)
        else
            self.gameUnit:setBurstPoint(0)
        end
    end
    self.gameUnit:setInvincibleTime(self.HP_SKILL_INVINCIBLE_TIME)
    self:buffRefreshAll(self.gameUnit)
    self:exGaugeEnd()
    self.hpSkillWaiting = true
    self.exGaugeReserve = timerKind
end

function class:buffRefreshAll(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,97,129,131,135}
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

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        addSP = 20,
        startAddSP = 40,
        attackDelay = 5,
        hitStop = 100,

        difficultyLevel = 15,

        ---共通ギミック（ヘイト割合×hateGimmickRate＋hateGimmickBase ％の被ダメージ／被ダメージ SPBonusRate で奥義ゲージ+1）
        hateGimmickRate = 1.5,
        hateGimmickBase = 50,
        SPBonusRate = 70,

        ---種族・属性ギミック（1〜4種族の被ダメージ補正／1〜4属性の奥義ゲージ上昇量補正）
        raceDmgRate = {
            0.1,
            0.2,
            0.3,
            1.0
        },
        elementSPRate = {
            0.3,
            0.4,
            1.0,
            1.3
        },

        ---スキル3・スキル6／奥義8・奥義10（奥義ゲージダウン＝発動数×spDownValue、spDownMax まで。0で無し）
        attackBuffValue_21 = 30,
        skillBuffValue_1 = -3000,
        spDownValue = 50,
        spDownMax = 300,

        ---ファンネル（スキル2で1機追加、最大 funnelMax 機。レーザーのダメージはファンネル数倍）
        funnelMax = 5,
        funnelLife = 10,

        ---エクストラゲージ（HP＝break_capacity×(exGaugeHPBaseRate＋exGaugeHPAddRate×表示回数)％）
        exGaugeDmgRate = 0.01,
        exGaugeHPBaseRate = 30,
        exGaugeHPAddRate = 2,
        exGaugeStunTime = 1,

        ---タイマー（1周ごとに効果、tgLimit 周で終了。効果量0は効果なし）
        tgTimer = 1,
        tgLimit = 20,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        timerHp80BuffValue_54 = -15,
        timerHp50BuffValue_22 = 3,
        timerHp30BuffValue_54 = -15,
        timerHp0BuffValue_17 = 15,

        ---HPトリガー
        hp50BuffValue_23 = -150,
        hp30BuffValue_27 = -30,
        hp30AddSP = 40,
        hp0AddSP = 50,
        hp0HealRate = 0.5
    }
end

function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, self:getGimmickDefault())
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

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    ---spine の default スキンは装甲・両腕などのスロットが欠けるので、名前付きスキンを当てる
    event.unit:setSkin("Nomal");

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({SHIELD = 100})
    self:initSkillWeight({SHIELD = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0
    self.hpSkillWaiting = false

    ---盾あり／盾無し
    self.formMode = "SHIELD"
    self.transformReserve = false   ---HP50%：次の行動の頭で変形する
    self.transformFLG = false       ---HP50%：変形中（終えたら奥義9を続ける）

    ---ヘイトギミック
    event.unit:setEnableGBHate(true);
    ---グランドバトルEXボス（属性数の補正は startWave で掛け直す）
    megast.Battle:getInstance():setGBExBossSPBonusRate(self.GD.SPBonusRate);

    ---種族・属性ギミック
    self.raceDmgRate = 1
    self.elementSPRate = 1

    ---奥義8・奥義10
    self.spDownCount = 0
    self.spDownReserve = false

    ---エクストラゲージ＆タイマー
    self.subBar = BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.exGaugeFlg = false      ---ダメージ軽減中（破壊したら下ろす）
    self.exGaugeVisible = false  ---ゲージ表示中（破壊後は気絶が解けるまで表示）
    self.exGaugeBroken = false
    self.exGaugeCount = 0
    self.exGaugeHP = 1
    self.exGaugeDamage = 0
    self.exGaugeReserve = nil
    self.exGaugeReady = false
    self.timeIndex = nil
    self.timerKind = nil

    ---★12 HP0%
    self.lastSkillReserve = false
    self.lastSkillFLG = false
    self.lastSkillTime = 0

    ---弾
    self.funnels = {}
    self.funnelCore = 0
    self.funnelLaserFired = false
    self.funnelVolleyReserve = false
    self.funnelTarget = nil
    self.balls = {}
    self.missiles = {}
    self.isAiming = false
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    local mode = self.MODE[self.formMode]
    event.unit:setSetupAnimationName(mode.setup)
    event.unit:setSetupAnimationNameEffect(mode.setupEffect)

    ---種族・属性ギミック（編成時の数で決める。死亡でバトルユニットが減っても変化しない）
    self:countPartyTypes()
    return 1
end

function class:countPartyTypes()
    local races = {}
    local elements = {}
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            races[myTeamUnit:getRaceType()] = true
            elements[myTeamUnit:getElementType()] = true
        end
    end
    self.raceDmgRate = self:getCountRate(self.GD.raceDmgRate,races)
    self.elementSPRate = self:getCountRate(self.GD.elementSPRate,elements)
    ---奥義ゲージは被ダメージ÷SPBonusRate だけ上がるので、上昇量の補正は割って掛ける
    megast.Battle:getInstance():setGBExBossSPBonusRate(self.GD.SPBonusRate / self.elementSPRate);
end

---種類の数（1〜補正の数。範囲外は端に丸める）に応じた補正値
function class:getCountRate(rateList,typeSet)
    local count = 0
    for _ in pairs(typeSet) do
        count = count + 1
    end
    count = math.max(1,math.min(count,table.maxn(rateList)))
    return rateList[count]
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        ---HPトリガーの奥義を打ち終えたらエクストラゲージとタイマー
        if self.exGaugeReady then
            self.exGaugeReady = false
            self:exGaugeStart(self.exGaugeReserve)
            self.exGaugeReserve = nil
        end
        ---奥義8・奥義10を打ち終えたら奥義ゲージダウン
        if self.spDownReserve then
            self.spDownReserve = false
            self:spDownGimmick(event.unit)
        end
        self:hpTriggersCheck(event.unit);
    end

    if self.exGaugeVisible then
        self:exGaugeControl(event.unit)
    end

    self:funnelUpdate(event.deltaTime)
    self:ballUpdate(event.deltaTime)
    self:missileUpdate(event.deltaTime)
    if self.isAiming then
        self:aimControl(event.unit)
    end

    if self.lastSkillReserve then
        self:lastSkillCheck(event.unit,event.deltaTime)
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1
end

---★12 HP0%：奥義を打ち終えたら戦闘不能
function class:lastSkillCheck(unit,deltaTime)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return
    end
    self.lastSkillTime = self.lastSkillTime + deltaTime
    if (self.lastSkillFLG and unit:getUnitState() ~= kUnitState_skill) or self.lastSkillTime >= self.LAST_SKILL_LIMIT_TIME then
        self.lastSkillReserve = false
        self.lastSkillFLG = false
        unit:getTeam():deadUnit(unit:getIndex());
        megast.Battle:getInstance():waveEnd(true);
    end
end

--===================================================================================================================
-- 奥義8・奥義10
--===================================================================================================================
---ターゲット（GBヘイト最大）と同じ種族のユニットの奥義ゲージを強制ダウン（発動数×spDownValue、spDownMax まで）
function class:spDownGimmick(unit)
    if self.GD.spDownValue <= 0 then
        return
    end
    local target = self:getHateTarget(unit)
    if target == nil then
        return
    end
    local raceType = target:getRaceType()
    local downSP = math.min(self.spDownCount * self.GD.spDownValue,self.GD.spDownMax)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil and myTeamUnit:getRaceType() == raceType then
            myTeamUnit:setBurstPoint(math.max(myTeamUnit:getBurstPoint() - downSP,0))
        end
    end
    local raceMessage = self.RACE_MESSAGE_LIST[raceType]
    if raceMessage ~= nil then
        self:showFormatMessage(self.SKILL_MESSAGE_LIST[2],raceMessage.MESSAGE)
    end
end

---GBヘイト（与ダメージ）が最大のユニット。まだ誰もダメージを与えていなければボスのターゲット
function class:getHateTarget(unit)
    local target = nil
    local maxHate = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local hate = unit:getGBHate(myTeamUnit:getIndex())
            if hate > maxHate then
                maxHate = hate
                target = myTeamUnit
            end
        end
    end
    if target == nil then
        target = unit:getTargetUnit()
    end
    return target
end

--===================================================================================================================
-- エクストラゲージ＆タイマー
--===================================================================================================================
---ゲージのHPは表示回数ごとに増える。タイマーは1周ごとに効果を1段重ね、tgLimit 周で C++ が消す
function class:exGaugeStart(kind)
    self:exGaugeEnd()
    local setting = self.TIMER_SETTING[kind]
    if setting == nil then
        return
    end
    self.exGaugeCount = self.exGaugeCount + 1
    self.exGaugeHP = self.gameUnit:getBaseBreakCapacity() * (self.GD.exGaugeHPBaseRate + self.exGaugeCount * self.GD.exGaugeHPAddRate) / 100
    self.exGaugeDamage = 0
    self.exGaugeFlg = true
    self.exGaugeVisible = true
    self.exGaugeBroken = false
    self:showMessage(self.EX_GAUGE_MESSAGE_LIST)

    local icon = 0
    if setting.value ~= 0 then
        icon = setting.buffs[1].ICON
    end
    self.timerKind = kind
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, icon, 0, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale)
    self:showMessage(self.TIMER_MESSAGE_LIST,1)
    if setting.value ~= 0 then
        self:showMessage(self.TIMER_MESSAGE_LIST,setting.message)
    end
end

function class:exGaugeControl(unit)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(math.max(0,100 * (self.exGaugeHP - self.exGaugeDamage) / self.exGaugeHP));

    if self.exGaugeBroken then
        ---気絶が解けたら非表示
        if unit:getTeamUnitCondition():findConditionWithID(self.STUN_BUFF.ID) == nil then
            self:exGaugeEnd()
        end
        return
    end
    if self.exGaugeHP - self.exGaugeDamage <= 0 then
        self:exGaugeBreak(unit)
    end
end

---破壊：ダメージ軽減とタイマーを止めてボスを気絶させる（奥義ゲージは変えない）
function class:exGaugeBreak(unit)
    self.exGaugeFlg = false
    self.exGaugeBroken = true
    self:timerEnd()
    self:showMessage(self.EX_GAUGE_BROKEN_MESSAGE_LIST)
    self:execAddBuff(unit,self.STUN_BUFF)
end

function class:exGaugeEnd()
    self.exGaugeFlg = false
    self.exGaugeVisible = false
    self.exGaugeBroken = false
    self.subBar:setVisible(false)
    self:timerEnd()
end

function class:timerEnd()
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex, 1, 0, true)
        self.timeIndex = nil
    end
    self.timerKind = nil
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if self.timeIndex ~= nil and event.index == self.timeIndex then
        self:timerBuff(self.timerKind)
        ---上限の周回では C++ がタイマーを消す。時間切れなのでゲージも消す（気絶なし）
        if event.count >= self.GD.tgLimit then
            self.timeIndex = nil
            self:exGaugeEnd()
        end
    end
    return event.count
end

function class:timerBuff(kind)
    local setting = self.TIMER_SETTING[kind]
    if setting == nil or setting.value == 0 then
        return
    end
    for _,buffBox in ipairs(setting.buffs) do
        if setting.isPlayer then
            self:unitAddBuff(buffBox)
        else
            self:execAddBuff(self.gameUnit,buffBox)
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    ---弾から来るイベント（event.unit は弾自身）
    if event.spineEvent == "laserHit" then self:funnelLaserHit(event.unit) end
    if event.spineEvent == "funnelStateEnd" then
        self.funnelLaserFired = false
        self:funnelStateEnd(self:findByOrbit(self.funnels,event.unit))
    end
    if event.spineEvent == "onDestroyfunnel" then self:orbitDestroyed(self.funnels,event.unit) end
    if event.spineEvent == "onDestroyball" then self:orbitDestroyed(self.balls,event.unit) end
    if event.spineEvent == "onDestroyMissile" then self:orbitDestroyed(self.missiles,event.unit) end

    ---本体アニメのイベント
    if event.spineEvent == "ball" then self:ballFire(event.unit) end
    if event.spineEvent == "missile" then self:missileFire(event.unit) end
    if event.spineEvent == "laserHit2" then self:laserHit2(event.unit) end
    if event.spineEvent == "aim" then self.isAiming = true end
    return 1;
end

function class:addSP(unit)
    if megast.Battle:getInstance():isHost() then
        unit:addSP(self.spValue);
    end
    return 1;
end

--===================================================================================================================
-- 弾の共通処理
--===================================================================================================================
---ボスが居ないか、退場が確定している
function class:isGone(unit)
    return unit == nil or unit:getIsDead()
end

---C++ 側で消滅処理（playEnd）に入っている。playEnd は終了アニメ名を空にしてから終了アニメを流す
function class:isEndedByEngine(orbit)
    return orbit:getEndAnimationName() == ""
end

---一覧から外すだけで弾には触らない（終了アニメは C++ が最後まで流して消す）
function class:dropEntry(list,entry)
    entry.done = true
    for i = 1, table.maxn(list) do
        if list[i] == entry then
            table.remove(list,i)
            return
        end
    end
end

---Lua 主導で弾を終わらせる。C++ の playEnd と同じく、終了アニメ名を空にし、Lazer 型・最大ヒット数1にしてから流す
---（終了アニメ名を残すと終了アニメが2回流れ、元の型のままだと終了中も被弾・ヒットで消える）
function class:finishOrbit(list,entry,endAnim)
    self:dropEntry(list,entry)
    local orbit = entry.orbit
    orbit:setEndAnimationName("")
    orbit:setOrbitType(self.ORBIT_LAZER)
    orbit:setHitCountMax(1)
    orbit:takeAnimation(0,endAnim,false)
end

---撃墜・着弾・終了アニメの0f。Lua 主導で終わらせたもの・外したものは一覧に無いので何もしない
function class:orbitDestroyed(list,orbit)
    local entry = self:findByOrbit(list,orbit)
    if entry ~= nil then
        self:dropEntry(list,entry)
    end
end

function class:findByOrbit(list,orbit)
    for i = 1, table.maxn(list) do
        if list[i].orbit == orbit then
            return list[i]
        end
    end
    return nil
end

---ループ中に一覧が縮んでも回せるよう、走査は複製に対して行う（終了アニメの0fのイベントは takeAnimation の中で発火しうる）
function class:snapshot(list)
    local copy = {}
    for i = 1, table.maxn(list) do
        copy[i] = list[i]
    end
    return copy
end

function class:getPlayerUnit(index)
    if index == nil then
        return nil
    end
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index)
end

---ユニットの位置＋MAIN ボーン（照準点）
function class:getAimPoint(unit)
    local skeleton = unit:getSkeleton()
    return unit:getPositionX() + skeleton:getBoneWorldPositionX("MAIN"), unit:getPositionY() + skeleton:getBoneWorldPositionY("MAIN")
end

---始点から終点への角度（度）
function class:getDeg(startX,startY,targetX,targetY)
    return math.atan2(targetY - startY,targetX - startX) * 180 / self.PI
end

---angle を goal へ最短回りで最大 maxStep 度だけ回す。戻り値は [0,360)
function class:turnToward(angle,goal,maxStep)
    local dir = (goal - angle) % 360
    if dir > 180 then
        dir = dir - 360
    end
    if dir > maxStep then
        dir = maxStep
    elseif dir < -maxStep then
        dir = -maxStep
    end
    return (angle + dir) % 360
end

function class:moveByAngle(entry,distance)
    local rad = entry.angle * self.PI / 180
    entry.x = entry.x + math.cos(rad) * distance
    entry.y = entry.y + math.sin(rad) * distance
    entry.orbit:setPosition(entry.x,entry.y)
end

--===================================================================================================================
-- ファンネル（スキル2：1機追加して全機でレーザー）
--===================================================================================================================
---上限まで1機追加し、追加したファンネルが周回に入ったら全機でレーザーを撃つ
function class:funnelCommand(unit)
    local target = unit:getTargetUnit()
    if target ~= nil then
        self.funnelTarget = target:getIndex()
    else
        self.funnelTarget = nil
    end
    if table.maxn(self.funnels) < self.GD.funnelMax then
        self:funnelSummon(unit)
    end
    self.funnelVolleyReserve = true
end

function class:funnelSummon(unit)
    local F = self.FUNNEL
    local orbit = unit:addOrbitSystem(F.ANIM,F.ORBIT_TYPE)
    if orbit == nil then
        return
    end
    orbit:setHitCountMax(999)
    orbit:setEndAnimationName(F.DEAD_ANIM)
    orbit:takeAnimation(0,F.ANIM,true)
    local x = unit:getPositionX() + F.SPAWN_X
    local y = unit:getPositionY() + F.SPAWN_Y
    orbit:setPosition(x,y)
    table.insert(self.funnels,{
        orbit = orbit, x = x, y = y, angle = 0, dist = 0, frame = 0,
        state = "enter", life = self.GD.funnelLife
    })
end

---全機で斉射（着弾の相手は funnelCommand で覚えたターゲット）
function class:funnelFire()
    self.funnelLaserFired = false
    for _,entry in ipairs(self:snapshot(self.funnels)) do
        if not entry.done then
            if self:isEndedByEngine(entry.orbit) then
                self:dropEntry(self.funnels,entry)
            else
                entry.frame = 0
                entry.state = "laser"
                entry.orbit:takeAnimation(0,self.FUNNEL.LASER_ANIM,false)
            end
        end
    end
end

---レーザーの着弾：1斉射につき1発。ダメージはファンネル数倍
function class:funnelLaserHit(orbit)
    if self.funnelLaserFired or self:findByOrbit(self.funnels,orbit) == nil or self:isGone(self.gameUnit) then
        return
    end
    local target = self:getPlayerUnit(self.funnelTarget)
    if target == nil then
        target = self.gameUnit:getTargetUnit()
    end
    if target == nil then
        return
    end
    self.funnelLaserFired = true
    local hit = self.gameUnit:addOrbitSystem(self.FUNNEL.HIT_ANIM,0)
    if hit == nil then
        return
    end
    hit:setPosition(self:getAimPoint(target))
    hit:setDamageRateOffset(table.maxn(self.funnels))
    hit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK2)
end

---登場移動・攻撃の終わり：寿命を1減らし、残っていれば周回へ戻す
function class:funnelStateEnd(entry)
    if entry == nil or entry.done then
        return
    end
    if self:isEndedByEngine(entry.orbit) then
        self:dropEntry(self.funnels,entry)
        return
    end
    entry.frame = 0
    entry.life = entry.life - 1
    if entry.life <= 0 then
        self:finishOrbit(self.funnels,entry,self.FUNNEL.DEAD_ANIM)
        return
    end
    entry.state = "idle"
    entry.orbit:takeAnimation(0,self.FUNNEL.ANIM,true)
end

---盾無しへの切替で全機撤退
function class:funnelRetreatAll()
    self.funnelVolleyReserve = false
    for _,entry in ipairs(self:snapshot(self.funnels)) do
        if not entry.done then
            if self:isEndedByEngine(entry.orbit) then
                self:dropEntry(self.funnels,entry)
            else
                self:finishOrbit(self.funnels,entry,self.FUNNEL.DEAD_ANIM)
            end
        end
    end
end

function class:funnelUpdate(deltaTime)
    if table.maxn(self.funnels) == 0 or self:isGone(self.gameUnit) then
        self.funnelVolleyReserve = false
        return
    end
    local F = self.FUNNEL
    local frameRate = deltaTime / self.ONE_FRAME
    self.funnelCore = (self.funnelCore + F.CORE_SPEED * frameRate) % 360
    local count = table.maxn(self.funnels)
    local centerX = self.gameUnit:getPositionX()
    local centerY = self.gameUnit:getPositionY() + F.CENTER_Y
    local entering = false
    for rank,entry in ipairs(self:snapshot(self.funnels)) do
        if not entry.done then
            if self:isEndedByEngine(entry.orbit) then
                self:dropEntry(self.funnels,entry)
            elseif entry.state == "enter" then
                self:funnelEnter(entry,frameRate)
                if not entry.done and entry.state == "enter" then
                    entering = true
                end
            elseif entry.state == "idle" then
                self:funnelIdle(entry,rank,count,centerX,centerY,frameRate)
            elseif entry.state == "laser" then
                self:funnelAim(entry,frameRate)
            end
        end
    end
    if self.funnelVolleyReserve and not entering then
        self.funnelVolleyReserve = false
        self:funnelFire()
    end
end

---登場移動：角度0の方向へ減速しながら進み、ENTER_FRAMES で周回へ移る
function class:funnelEnter(entry,frameRate)
    local F = self.FUNNEL
    local frame = entry.frame
    entry.frame = frame + frameRate
    local speed = 1
    if frame < F.ENTER_FRAMES then
        speed = 1 + (F.ENTER_FRAMES - frame) / F.ENTER_FRAMES * F.ENTER_BOOST
    else
        self:funnelStateEnd(entry)
        if entry.done then
            return
        end
    end
    self:moveByAngle(entry,speed * frameRate)
end

---周回：中心からの距離を RADIUS まで縮めつつ、等間隔の目標角（基準角が回る）へ旋回する
function class:funnelIdle(entry,rank,count,centerX,centerY,frameRate)
    local F = self.FUNNEL
    if entry.frame == 0 then
        local dx = entry.x - centerX
        local dy = entry.y - centerY
        entry.dist = math.sqrt(dx * dx + dy * dy)
        entry.angle = self:getDeg(centerX,centerY,entry.x,entry.y) % 360
    end
    entry.frame = entry.frame + frameRate
    if entry.dist > F.RADIUS then
        entry.dist = entry.dist - F.IDLE_SHRINK * frameRate
    end
    local goal = (rank - 1) * 360 / count + self.funnelCore
    entry.angle = self:turnToward(entry.angle,goal,F.IDLE_TURN * frameRate)
    local rad = entry.angle * self.PI / 180
    entry.x = centerX + math.cos(rad) * entry.dist
    entry.y = centerY + math.sin(rad) * entry.dist
    entry.orbit:setPosition(entry.x,entry.y)
end

---レーザー中：ターゲットの照準点へ向く（不在なら向きを保つ）
function class:funnelAim(entry,frameRate)
    entry.frame = entry.frame + frameRate
    local target = self:getPlayerUnit(self.funnelTarget)
    if target == nil then
        target = self.gameUnit:getTargetUnit()
    end
    if target == nil then
        return
    end
    local targetX,targetY = self:getAimPoint(target)
    entry.angle = self:getDeg(entry.x,entry.y,targetX,targetY) % 360
    entry.orbit:setRotation(360 - entry.angle)
end

--===================================================================================================================
-- ボール（skill2）
--===================================================================================================================
function class:ballFire(unit)
    if self:isGone(unit) then
        return
    end
    local B = self.BALL
    local orbit = unit:addOrbitSystem(B.ANIM,1)
    if orbit == nil then
        return
    end
    orbit:setHitCountMax(1)
    orbit:setEndAnimationName(B.END_ANIM)
    orbit:takeAnimation(0,B.ANIM,true)
    local skeleton = unit:getSkeleton()
    local x = unit:getPositionX() + skeleton:getBoneWorldPositionX(B.BONE) + B.OFFSET_X
    local y = unit:getPositionY() + skeleton:getBoneWorldPositionY(B.BONE)
    orbit:setPosition(x,y)
    local target = unit:getTargetUnit()
    local targetIndex = nil
    if target ~= nil then
        targetIndex = target:getIndex()
    end
    table.insert(self.balls,{
        orbit = orbit, x = x, y = y, angle = math.random(360), frame = 0, target = targetIndex
    })
end

function class:ballUpdate(deltaTime)
    if table.maxn(self.balls) == 0 or self:isGone(self.gameUnit) then
        return
    end
    local B = self.BALL
    local frameRate = deltaTime / self.ONE_FRAME
    for _,entry in ipairs(self:snapshot(self.balls)) do
        if not entry.done then
            if self:isEndedByEngine(entry.orbit) then
                self:dropEntry(self.balls,entry)
            elseif entry.frame >= B.LIFE then
                self:finishOrbit(self.balls,entry,B.END_ANIM)
            else
                ---ターゲットの足元へ少しずつ旋回しながら等速で進む
                entry.frame = entry.frame + frameRate
                local target = self:getPlayerUnit(entry.target)
                if target ~= nil then
                    local goal = self:getDeg(entry.x,entry.y,target:getPositionX(),target:getPositionY())
                    entry.angle = self:turnToward(entry.angle,goal,B.TURN * frameRate)
                end
                self:moveByAngle(entry,B.SPEED * frameRate)
            end
        end
    end
end

--===================================================================================================================
-- ミサイル（attack4）
--===================================================================================================================
function class:missileFire(unit)
    if self:isGone(unit) then
        return
    end
    local M = self.MISSILE
    local orbit = unit:addOrbitSystem(M.ANIM,1)
    if orbit == nil then
        return
    end
    orbit:setHitCountMax(1)
    orbit:setEndAnimationName(M.END_ANIM)
    orbit:takeAnimation(0,M.ANIM,true)
    orbit:setAutoZOrder(true)
    orbit:setZOderOffset(M.Z_OFFSET)
    local skeleton = unit:getSkeleton()
    local x = unit:getPositionX() + skeleton:getBoneWorldPositionX(M.BONE)
    local y = unit:getPositionY() + skeleton:getBoneWorldPositionY(M.BONE)
    orbit:setPosition(x,y)
    local target = unit:getTargetUnit()
    local targetIndex = nil
    if target ~= nil then
        targetIndex = target:getIndex()
    end
    table.insert(self.missiles,{
        orbit = orbit, x = x, y = y, angle = 0, frame = 0, target = targetIndex
    })
end

function class:missileUpdate(deltaTime)
    if table.maxn(self.missiles) == 0 or self:isGone(self.gameUnit) then
        return
    end
    local frameRate = deltaTime / self.ONE_FRAME
    for _,entry in ipairs(self:snapshot(self.missiles)) do
        if not entry.done then
            if self:isEndedByEngine(entry.orbit) then
                self:dropEntry(self.missiles,entry)
            else
                self:missileControl(entry,frameRate)
            end
        end
    end
end

---ターゲットが居なくなったら、真上へ移る区間でも落下中でもその場で爆発する
function class:missileControl(entry,frameRate)
    local M = self.MISSILE
    local frame = entry.frame
    entry.frame = frame + frameRate
    local speed = 0
    local landed = false
    if frame <= 1 then
        entry.angle = 0
        speed = 1
    elseif frame < M.RISE_FRAMES then
        entry.angle = M.RISE_ANGLE
        speed = 1 + (M.RISE_FRAMES - frame) / M.RISE_FRAMES * M.BOOST
    elseif frame < M.ACCEL_FRAMES then
        speed = 1 + (frame - M.RISE_FRAMES) / M.RISE_FRAMES * M.BOOST
    elseif frame <= M.WARP_END then
        local target = self:getPlayerUnit(entry.target)
        if target == nil then
            self:finishOrbit(self.missiles,entry,M.END_ANIM)
            return
        end
        entry.x = target:getPositionX()
        entry.angle = M.DIVE_ANGLE
        speed = 0
    elseif frame < M.LIFE then
        local target = self:getPlayerUnit(entry.target)
        if target == nil then
            self:finishOrbit(self.missiles,entry,M.END_ANIM)
            return
        end
        speed = M.DIVE_SPEED
        entry.angle = self:turnToward(entry.angle,self:getDeg(entry.x,entry.y,target:getPositionX(),target:getPositionY()),M.DIVE_TURN * frameRate)
        landed = entry.y < target:getPositionY()
    else
        self:finishOrbit(self.missiles,entry,M.END_ANIM)
        return
    end
    entry.orbit:setRotation(360 - entry.angle)
    self:moveByAngle(entry,speed * frameRate)
    ---ターゲットの高さを下回ったら、このフレームの移動の後で爆発
    if landed then
        self:finishOrbit(self.missiles,entry,M.END_ANIM)
    end
end

--===================================================================================================================
-- 照準レーザー（attack5）
--===================================================================================================================
---着弾：ボスのターゲットの照準点に着弾オービットを置く
function class:laserHit2(unit)
    if self:isGone(unit) then
        return
    end
    local target = unit:getTargetUnit()
    if target == nil then
        return
    end
    local hit = unit:addOrbitSystem(self.FUNNEL.HIT_ANIM,0)
    if hit == nil then
        return
    end
    hit:setPosition(self:getAimPoint(target))
end

---照準中：各砲身ボーンをターゲットの照準点へ向ける（不在なら0度）。attack5 の成立から次の行動の頭まで
function class:aimControl(unit)
    if self:isGone(unit) then
        return
    end
    local skeleton = unit:getSkeleton()
    local target = unit:getTargetUnit()
    if target == nil then
        for _,bone in ipairs(self.AIM_BONES) do
            skeleton:setBoneRotation(bone,0)
        end
        return
    end
    local targetX,targetY = self:getAimPoint(target)
    local unitX = unit:getPositionX()
    local unitY = unit:getPositionY()
    for _,bone in ipairs(self.AIM_BONES) do
        skeleton:setBoneRotation(bone,self:getDeg(unitX + skeleton:getBoneWorldPositionX(bone),unitY + skeleton:getBoneWorldPositionY(bone),targetX,targetY))
    end
end

---------------------------------------------------------------------------------
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    ---照準レーザーは次の行動の頭で終わる
    self.isAiming = false
    ---HP50%：変形を終えたらゲージを満たして攻撃後の待ちを消し、続けて奥義9を出す
    if self.transformFLG then
        self.transformFLG = false
        event.unit:setSetupAnimationName(self.MODE.ATTACK.setup);
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 4
            self.gameUnit:addSP(100)
        end
        event.unit:setAttackTimer(0);
    end
    ---HP50%：無敵のまま切替アニメで攻撃モードへ変形し、この行動を取り消す（切替アニメが終わると C++ が次の行動へ進む）
    if self.transformReserve then
        self.transformReserve = false
        self.transformFLG = true
        local mode = self.MODE.ATTACK
        event.unit:takeAnimation(0,mode.enter,false);
        event.unit:takeAnimationEffect(0,mode.enterEffect,false);
        self:enterAttackMode(event.unit)
        return 0
    end
    return 1
end

---盾無しへ：ポップを出し、ファンネルを撤退させて行動パターンを入れ替える（待機・後退・被弾・退場のアニメも盾無しのものになる）
---本体のセットアップアニメは次のアニメの基本姿勢になるので、切替アニメを流した後に替える
function class:enterAttackMode(unit)
    local mode = self.MODE.ATTACK
    self.formMode = "ATTACK"
    unit:showPopText(summoner.Text:fetchByUnitID(500161013)[mode.popKey] or mode.pop);
    unit:setSetupAnimationNameEffect(mode.setupEffect);
    self:funnelRetreatAll()
    self:initAttackWeight({ATTACK = 100})
    self:initSkillWeight({ATTACK = 100})
end

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

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    end

    if event.index == 2 then
        ---ファンネルレーザー
        self:funnelCommand(event.unit)
    elseif event.index == 3 or event.index == 6 then
        ---スキル3・スキル6：プレイヤーユニットの被ダメージアップ
        self:unitAddBuff(self.ATTACK_BUFF)
    elseif event.index == 5 then
        ---照準レーザー
        self.isAiming = true
    end

    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:unitAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
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

    ---HPトリガーの奥義（トリガーの次に出る奥義）
    if self.hpSkillWaiting then
        self.hpSkillWaiting = false
        event.unit:setInvincibleTime(self.HP_SKILL_INVINCIBLE_TIME)
        if self.exGaugeReserve ~= nil then
            self.exGaugeReady = true
        end
        if self.lastSkillReserve then
            self.lastSkillFLG = true
        end
    end

    if event.index == 3 or event.index == 5 then
        ---奥義8・奥義10：プレイヤーユニットの最大HPダウン。打ち終えたら奥義ゲージダウン
        self:unitAddBuff(self.SKILL_BUFF)
        self:showMessage(self.SKILL_MESSAGE_LIST,1)
        self.spDownCount = self.spDownCount + 1
        self.spDownReserve = true
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
        unit:takeSkillWithCutin(skillIndex,self.cutInSkill[skillIndex]);
    else
        unit:takeSkill(skillIndex);
    end

    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
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
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    local rate = ((gbHatePercent * self.GD.hateGimmickRate) + self.GD.hateGimmickBase) / 100
    event.value = event.value * rate
    return event.value
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    local rate = ((gbHatePercent * self.GD.hateGimmickRate) + self.GD.hateGimmickBase) / 100
    event.value = event.value * rate
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    event.value = self:calcTakeDamage(event.value)
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（event.enemy は無いが、種族・エクストラゲージの補正は攻撃者に依存しないので同じ補正を入れる）
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    else
        event.value = self:calcTakeDamage(event.value)
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

---種族数の補正と、エクストラゲージ表示中の補正（重複して掛ける）
function class:calcTakeDamage(value)
    value = value * self.raceDmgRate
    if self.exGaugeFlg then
        value = value * self.GD.exGaugeDmgRate
    end
    return value
end

---ユニットの HP。Lua 側の型が OrbitSystem になっていると unit:getHP() は int に切り詰められ、21.5億を超える HP が負になるので、TeamUnit 版を直接呼ぶ
function class:getUnitHP(unit)
    return TeamUnit.getHP(unit)
end

function class:adjustHpFlg(unit,value)
    local anotherHp = self:getUnitHP(unit) - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
            return self:getUnitHP(unit) < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value)
        end
    end
    return value
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true
    return self:getUnitHP(unit) - border + 1
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
    ---エクストラゲージはブレイクダメージで削れる
    if self.exGaugeFlg then
        self.exGaugeDamage = self.exGaugeDamage + event.value
    end
    return event.value
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if self:getUnitHP(event.unit) <= stopBorder and self:getUnitHP(event.unit) > stopBorder - 2 then
            return 0
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- idle / back / damage / out（盾あり・盾無しのアニメに差し替える）
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---HPトリガーの奥義を出すまでは無敵を解かない
    if self.afterSkillFLG and not self.hpSkillWaiting then
        self.gameUnit:setInvincibleTime(0)
    end
    local mode = self.MODE[self.formMode]
    event.unit:setNextAnimationName(mode.idle)
    if mode.effectIdle ~= nil then
        event.unit:setNextAnimationEffectName(mode.effectIdle)
    end
    return 1
end

function class:takeBack(event)
    event.unit:setNextAnimationName(self.MODE[self.formMode].back)
    return 1
end

function class:takeDamage(event)
    event.unit:setNextAnimationName(self.MODE[self.formMode].damage)
    return 1
end

function class:takeOut(event)
    event.unit:setNextAnimationName(self.MODE[self.formMode].out)
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    ---HP0%の奥義を出し終えるまでは倒れない（★12 は奥義の後に update で倒す）
    if self.HP0_TRIGGER_INDEX ~= nil then
        if not self.TRIGGERS[self.HP0_TRIGGER_INDEX].used or self.lastSkillReserve then
            event.unit:setHP(1)
            return 0
        end
    end
    self:takeOut(event);
    megast.Battle:getInstance():waveEnd(true);
    return 1
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
    ---戦闘が始まる前（登場中など）は判定しない
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end

    local hpRate = self:getUnitHP(unit) / unit:getCalcHPMAX() * 100;
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
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
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
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
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

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
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

class:publish();

return class;
