local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="超襲来マリカ_真EX極_超マリカ", version=2.6, id=2084710});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {                                     ---スキル1 -> スキル2 -> 繰り返し
        { ATTACK1 = 100 },
        { ATTACK2 = 100 }
    },
    HP50 = {                                        ---（スキル6 or 8）->（スキル7 or 8）->（スキル6 or 7 or 8）
        { ATTACK3 = 50, ATTACK5 = 50 },
        { ATTACK4 = 50, ATTACK5 = 50 },
        { ATTACK3 = 50, ATTACK4 = 50, ATTACK5 = 50 }
    },
    HP0 = {                                         ---（スキル6 or 11）->（スキル7 or 12）->（スキル6 or 11 or 12）
        { ATTACK3 = 50, ATTACK6 = 50 },
        { ATTACK4 = 50, ATTACK7 = 50 },
        { ATTACK3 = 50, ATTACK6 = 50, ATTACK7 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {                                     ---奥義3 -> 奥義4 -> 奥義3 -> 奥義4 -> 奥義5 -> 繰り返し
        { SKILL2 = 100 },
        { SKILL3 = 100 },
        { SKILL2 = 100 },
        { SKILL3 = 100 },
        { SKILL5 = 100 }
    },
    HP50 = {                                        ---奥義9 -> 奥義10 -> 繰り返し
        { SKILL6 = 100 },
        { SKILL7 = 100 }
    },
    HP0 = {                                         ---奥義9 -> 奥義13 -> 繰り返し
        { SKILL6 = 100 },
        { SKILL8 = 100 }
    }
}

---左辺キー＝アニメーション／event.index、右辺＝スキル構成番号
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,                                    ---スキル1  通常攻撃          （attack1）
    ATTACK2 = 2,                                    ---スキル2  マギ・フォーカス   （skill1）
    ATTACK3 = 6,                                    ---スキル6  通常攻撃          （attack1）
    ATTACK4 = 7,                                    ---スキル7  マギ・フォーカス   （skill1）
    ATTACK5 = 8,                                    ---スキル8  フェーズ・ブレード （skill2）
    ATTACK6 = 11,                                   ---スキル11 マギ・フォーカス   （skill1）
    ATTACK7 = 12,                                   ---スキル12 フェーズ・ブレード （skill2）
    SKILL2  = 3,                                    ---奥義3  フェーズ・ブレード （skill2）
    SKILL3  = 4,                                    ---奥義4  シンク・スマッシュ （skill3）
    SKILL5  = 5,                                    ---奥義5  ウル・オーケストラ （skill5／通常発動・カットインなし）
    SKILL6  = 9,                                    ---奥義9  シンク・スマッシュ （skill3）
    SKILL7  = 10,                                   ---奥義10 ウル・オーケストラ （skill5／通常発動・カットインなし）
    SKILL8  = 13,                                   ---奥義13 ウル・オーケストラ （skill5／超奥義カットイン）
    SKILL9  = 5,                                    ---奥義5  HP80%フラグ専用    （skill5／奥義カットイン）
    SKILL10 = 10                                    ---奥義10 HP50%フラグ専用    （skill5／真奥義カットイン）
}

class.cutInSkill = {
    [8]  = 4,                                       ---奥義13：超奥義カットイン
    [9]  = 0,                                       ---奥義5（HP80%）：奥義カットイン
    [10] = 1                                        ---奥義10（HP50%）：真奥義カットイン
}

---EFアニメーションの接頭辞。104297111 は 10429ef.json の 2- 系
---（2- に attack1／skill1／skill2／skill3／skill5 が揃っている。1- には skill5 が無い）
class.EF_PREFIX = "2-";

---通常攻撃のアニメーション差し替え（本体spine 104297111 に存在するものへ寄せる）
class.ATTACK_ANIMATIONS = {
    [2] = "skill1",                                 ---スキル2  マギ・フォーカス
    [3] = "attack1",                                ---スキル6  通常攻撃
    [4] = "skill1",                                 ---スキル7  マギ・フォーカス
    [5] = "skill2",                                 ---スキル8  フェーズ・ブレード
    [6] = "skill1",                                 ---スキル11 マギ・フォーカス
    [7] = "skill2"                                  ---スキル12 フェーズ・ブレード
}

---奥義のアニメーション差し替え
class.SKILL_ANIMATIONS = {
    [6]  = "skill3",                                ---奥義9  シンク・スマッシュ
    [7]  = "skill5",                                ---奥義10 ウル・オーケストラ
    [8]  = "skill5",                                ---奥義13 ウル・オーケストラ
    [9]  = "skill5",                                ---奥義5  （HP80%フラグ専用）
    [10] = "skill5"                                 ---奥義10 （HP50%フラグ専用）
}

---「燃焼状態のユニットのダメージ無効化無効」のINFOを出す奥義（奥義5＆10＆13）
class.BURST_INFO_SKILLS = {
    [5]  = true,                                    ---奥義5
    [7]  = true,                                    ---奥義10
    [8]  = true,                                    ---奥義13
    [9]  = true,                                    ---奥義5 （HP80%）
    [10] = true                                     ---奥義10（HP50%）
}

---HPフラグで発動する奥義のスロット番号
class.HP80_SKILL = 9;                               ---奥義5 （奥義カットイン）
class.HP50_SKILL = 10;                              ---奥義10（真奥義カットイン）
---HP50%の行動パターン変化は真EX・極のみ
class.HP50_PATTERN = true;
---HP0%フラグは真EX・極のみ
class.USE_HP0_FLG = true;

---ウルのセリフ用（ピンク）
class.COLOR_PINK = Color:new(255,210,210);


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---リーダーユニットの与ダメージダウン
        [1] = {
            ID = 208471001,
            BUFF_ID = 17,                           ---与ダメージ
            VALUE = self.GD.leaderDmgDownVal,
            DURATION = 999999,
            ICON = 27
        },
        ---バリアエフェクト（エクストラゲージ破壊まで）
        [2] = {
            ID = 208471002,
            BUFF_ID = 0,                            ---視覚表示のみ（ダメージ1化はtakeDamageValue側）
            VALUE = 0,
            DURATION = 999999,
            ICON = 24,
            EFFECT = 1                              ---共通エフェクト(effect/SkillEffect)の青いシールド
        },
        ---エクストラゲージ破壊時のボスの気絶
        [3] = {
            ID = 208471003,
            BUFF_ID = 89,                           ---気絶
            VALUE = 100,
            DURATION = self.GD.stunTime,
            ICON = 79
        },
        ---HP50%：クリティカル耐性アップ
        [4] = {
            ID = 208471004,
            BUFF_ID = 23,                           ---被クリティカル率（マイナスでクリティカル耐性アップ）
            VALUE = self.GD.hp50CritResistVal,
            DURATION = 999999,
            ICON = 188
        },
        ---HP50%：パーティの燃焼耐性ダウン
        [5] = {
            ID = 208471005,
            BUFF_ID = 60,                           ---燃焼耐性（短縮率）
            VALUE = self.GD.hp50BurnResistVal,
            DURATION = 999999,
            ICON = 76
        },
        ---燃焼耐性は回避率(109)とセットで下げないと効かない。アイコンは60側だけ出す
        [6] = {
            ID = 208471006,
            BUFF_ID = 109,                          ---燃焼回避率
            VALUE = self.GD.hp50BurnResistVal,
            DURATION = 999999,
            ICON = 0
        }
    };

    ---エクストラゲージ表示中タイマー：パーティの最大HPダウン（重複・アイコンに数字表示）
    self.EX_TG_BUFF_LIST = {
        [1] = {
            ID = 208471011,
            BUFF_ID = 2,                            ---最大HP割合
            VALUE = self.GD.exTgBuffVal_2,
            DURATION = 999999,
            ICON = 2,
            MAX = self.GD.exTgBuffMax
        }
    };

    if self.USE_HP0_FLG then
        ---HP0%：オーラ（鉄壁マークはブレイクバッジで表示する）
        self.BUFF_BOX_LIST[7] = {
            ID = 208471007,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        };
        ---HP0%フラグタイマー：パーティの被ダメージアップ（重複・アイコンに数字表示）
        self.HP0_TG_BUFF_LIST = {
            [1] = {
                ID = 208471012,
                BUFF_ID = 21,                       ---被ダメージ
                VALUE = self.GD.hp0TgBuffVal_21,
                DURATION = 999999,
                ICON = 139,
                MAX = self.GD.hp0TgBuffMax
            }
        };
    end
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
    BattleControl:get():setEnemyInfomationMaxSize(6);
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "シンク・ウル・スタンバイ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "リーダーの与ダメージダウン", COLOR = Color.yellow})
    };

    ---奥義5＆10＆13発動時
    self.BURST_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BURST_MESSAGE1 or "燃焼状態のユニットのダメージ無効化無効", COLOR = Color.red})
    };

    self.HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE1 or "《フィールド装置起動します！》", COLOR = self.COLOR_PINK}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE2 or "オッケー、よろしく", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE3 or "ダメージ耐性：フィールド装置破壊で解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE4 or "フィールド装置：リーダーのブレイクダメージで破壊", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE5 or "一定時間経過でパーティの最大HPダウン：徐々に加速", COLOR = Color.yellow})
    };

    ---エクストラゲージ（フィールド装置）破壊時
    self.EXGAUGE_BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EXGAUGE_BREAK_MESSAGE1 or "うわっと…こいつは…！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EXGAUGE_BREAK_MESSAGE2 or "《想定内です！》", COLOR = self.COLOR_PINK}),
        self:setMessageInfo({MESSAGE = self.TEXT.EXGAUGE_BREAK_MESSAGE3 or "フィールド装置破壊成功！ダメージ耐性解除！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EXGAUGE_BREAK_MESSAGE4 or "マリカ：気絶", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EXGAUGE_BREAK_MESSAGE5 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow})
    };

    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "ウル、いくよ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "《演算、加速！》", COLOR = self.COLOR_PINK}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE3 or "行動速度・奥義ゲージ上昇量・クリティカル耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE4 or "パーティの燃焼耐性ダウン", COLOR = Color.red})
    };

    ---パーティ全滅時
    self.PARTY_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.PARTY_DEAD_MESSAGE1 or "これが、最適解", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.PARTY_DEAD_MESSAGE2 or "《ちょっとだけ！楽しかったです！》", COLOR = self.COLOR_PINK})
    };

    ---倒れる際
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "完…敗……でも――", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE2 or "《次は…勝ちます…！》", COLOR = self.COLOR_PINK})
    };

    if self.USE_HP0_FLG then
        self.HP0_MESSAGE_LIST = {
            self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "これは、想定外…", COLOR = Color.red}),
            self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "《予備動力炉、起動！！》", COLOR = self.COLOR_PINK}),
            self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE3 or "鉄壁：ブレイクで解除", COLOR = Color.yellow}),
            self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE4 or "一定時間経過でパーティの被ダメージアップ：徐々に加速", COLOR = Color.yellow})
        };
    end
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        }
    };
    ---HP0%フラグは真EX・極のみ
    if self.USE_HP0_FLG then
        self.TRIGGERS[3] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,                                       ---HP0%は0.1を使う（0だと発動しない）
            used = false,
            isEnableSkip = false
        };
    end

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

---HP80%：奥義5＆奥義カットイン＆エクストラゲージ表示
function class:hp80(status)
    if status == "use3" then
        self:refresh(self.gameUnit);                                ---停止系状態異常除去
        self.hpSkillFLG = true;                                     ---発動から打ち終わるまでブレイク不可
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = self.HP80_SKILL;
            self.saveBP = self.gameUnit:getBurstPoint();            ---奥義ゲージ引き継ぎ
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(self.GD.hpSkillInvincible);
        self:showMessage(self.HP80_MESSAGE_LIST);
        ---耐性追加ギミック：物理／魔法の累計はHP80%から数え直す（累計80%〜50%）
        self.physicalDamage = 0;
        self.magicDamage = 0;
        ---エクストラゲージ（フィールド装置）＆バリアエフェクト＆表示中タイマー
        self:shareLeaderIndex();        ---ゲージ表示前にリーダーindexを配り直す
        self:startExGauge();
    end
end

---HP50%：奥義10発動＆真奥義カットイン＆行動パターン変化
function class:hp50(status)
    if status == "use3" then
        self:refresh(self.gameUnit);
        self.hpSkillFLG = true;
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = self.HP50_SKILL;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(self.GD.hpSkillInvincible);
        self.spValue = self.GD.hp50AddSP;                           ---奥義ゲージ上昇量アップ
        self.gameUnit:setAttackDelay(self.GD.hp50AttackDelay);      ---行動速度アップ
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4]);      ---クリティカル耐性アップ
        self:unitAddBuff(self.BUFF_BOX_LIST[5]);                    ---パーティの燃焼耐性ダウン（短縮率）
        self:unitAddBuff(self.BUFF_BOX_LIST[6]);                    ---パーティの燃焼回避率ダウン（60とセットで効く）
        ---行動パターン変化（真EX・極のみ）
        if self.HP50_PATTERN then
            self:initAttackWeight({HP50 = 100});
            self:initSkillWeight({HP50 = 100});
        end
        self:showMessage(self.HP50_MESSAGE_LIST);
        ---耐性追加ギミック：HP80%〜HP50%の累計で物理／魔法耐性を確定（ホストが決めて配る）
        if megast.Battle:getInstance():isHost() then
            local attribute = self:calcResistAttribute();
            self:applyResistAttribute(attribute);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,8,attribute);
        end
    end
end

---HP0%：HPを30%回復＆オーラ＆鉄壁＆行動パターン変化（奥義は発動しない）
---鉄壁はブレイクで解除するため、ここでは hpSkillFLG（ブレイク不可）を立てない
function class:hp0(status)
    if status == "use3" then
        self:refresh(self.gameUnit);
        ---HPを30%回復（この回復は一度のみ）
        local hpMax = self.gameUnit:getCalcHPMAX();
        local hp = self.gameUnit:getHP() + math.floor(hpMax * self.GD.hp0RecoverRate * 0.01);
        if hp > hpMax then
            hp = hpMax;
        end
        self.gameUnit:setHP(hp);
        ---オーラ
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[7]);
        ---鉄壁（一度ブレイクするまでダメージを1にする）＋鉄壁マーク
        self.armorState = true;
        self.gameUnit:addNumBreakBadge(1);
        ---行動パターン変化
        self:initAttackWeight({HP0 = 100});
        self:initSkillWeight({HP0 = 100});
        ---HP0%フラグタイマー
        self:startHp0Timer();
        self:showMessage(self.HP0_MESSAGE_LIST);
    end
end

---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 6,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---リーダーギミック
        leaderDmgDownVal = -100,    --リーダーユニットの与ダメージ%（マイナスでダウン）

        ---エクストラゲージ（フィールド装置）
        exGaugeHP = 100000,         --エクストラゲージのHP（リーダーのブレイクダメージのみ有効）
        exGaugeBreakAddSP = 25,     --エクストラゲージ破壊後のSP獲得量
        stunTime = 3,               --エクストラゲージ破壊時のボスの気絶秒数
        subBarPosY = 0,             --サブバーの表示位置（ボス座標からのオフセットY）

        ---エクストラゲージ表示中タイマー（パーティの最大HPダウン）
        exTgTimer = 8,              --インターバル秒数（[exTgTimer-アイコンの数字×exTgAccelStep]で加速）
        exTgAccelStep = 0.5,        --アイコンの数字1つあたり短縮する秒数
        exTgTimerMin = 1,           --最短インターバル秒数
        exTgLimit = 99,             --ループ上限
        exTgIconNum1 = 2,           --タイマーのアイコン番号（最大HPダウン）
        exTgIconNum2 = 0,
        exTgPosX = 0,
        exTgPosY = 0,
        exTgScale = 1,
        exTgBuffVal_2 = -5,         --1周ごとの最大HPダウン%
        exTgBuffMax = 99,           --重複上限（アイコンの数字）

        ---HPフラグ共通
        hpSkillInvincible = 20,     --HPフラグ奥義中の無敵秒数

        ---HP50%フラグ
        hp50AddSP = 35,             --HP50%以降のSP獲得量
        hp50AttackDelay = 4,        --HP50%以降のアタックディレイ
        hp50CritResistVal = -50,    --クリティカル耐性%（マイナスで被クリティカル率ダウン）
        hp50BurnResistVal = -50,    --パーティの燃焼耐性%（マイナスでダウン）

        ---HP0%フラグ
        hp0RecoverRate = 30,        --HP回復率%
        hp0TgTimer = 8,             --インターバル秒数（[hp0TgTimer-アイコンの数字×hp0TgAccelStep]で加速）
        hp0TgAccelStep = 0.5,       --アイコンの数字1つあたり短縮する秒数
        hp0TgTimerMin = 1,          --最短インターバル秒数
        hp0TgLimit = 99,
        hp0TgIconNum1 = 139,        --タイマーのアイコン番号（被ダメージアップ）
        hp0TgIconNum2 = 0,
        hp0TgPosX = 0,
        hp0TgPosY = 0,
        hp0TgScale = 1,
        hp0TgBuffVal_21 = 15,       --1周ごとの被ダメージアップ%
        hp0TgBuffMax = 99,          --重複上限（アイコンの数字）

        ---耐性追加ギミック（既定OFF。1でON）
        extraResistEnable = 0,      --1でHP80%突破時の属性耐性／HP50%時の物魔耐性を有効化
        extraResistRate = 0.2,      --takeDamageValue補正の倍率
    };
end


---ギミックカラムのJSONは値が文字列やnullで入ってくることがあるため数値へ正規化する。
---Json.parse のnullは空テーブルになり、getGimmickJsonData の「jsonData[key] == nil なら既定値」
---判定をすり抜けてそのまま self.GD に載る。放置すると start() が
---「attempt to compare number with table/string」で例外死し、setTriggerList まで到達しないため
---update() の hpTriggersCheck が HP_TRIGGERS(nil) で毎フレーム落ちる。
function class:setUpGimmickData(unit)
    local defaults = self:getGimmickDefault();
    ---JSON自体が壊れている場合 getGimmickJsonData は error を投げる。
    ---そのまま落とすと start() が中断してボスが機能停止するので、既定値で動かす。
    ---（Utility 側が changeErrorMarkColor(2) を呼ぶので赤丸は出たままになる）
    local isSuccess, data = pcall(summoner.Utility.getGimmickJsonData, unit, defaults);
    if not isSuccess then
        summoner.Utility.messageByEnemy("ギミックカラムのJSONが不正です");
        data = defaults;
    end
    local fixed = {};
    for key,def in pairs(defaults) do
        local value = data[key];
        if type(def) == "number" then
            if type(value) == "number" then
                fixed[key] = value;
            elseif type(value) == "string" and tonumber(value) ~= nil then
                fixed[key] = tonumber(value);   ---管理画面が文字列で入れた場合は数値へ
            else
                fixed[key] = def;               ---null・空文字・型違いはLua側の既定値へ戻す
            end
        elseif type(value) == type(def) then
            fixed[key] = value;
        else
            fixed[key] = def;
        end
    end
    ---未宣言キーへのアクセスは元の実装と同じくエラーにする（キー名のタイポ検出用）
    setmetatable(fixed,{__index = function(_,key) error("Key not found: "..tostring(key)) end});
    return fixed;
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = self:setUpGimmickData(event.unit);
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
    self.addSpSkipFLG = true;   ---奥義直後の通常攻撃ではaddSPしない
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.breakSkip = false;
    self.breakFlg = false;
    self.hpSkill = 0;
    self.saveBP = 0;
    self.hpSkillFLG = false;

    ---エクストラゲージ（フィールド装置）
    self.exGaugeFLG = false;
    self.exGaugeDamage = 0;
    self.exGaugeSentDamage = -1;
    self.SUB_HP = self.GD.exGaugeHP;
    ---start() は死亡→復活時にも呼ばれるためサブバーは作り直さない
    if self.subBar == nil then
        self.subBar = BattleControl:get():createSubBar();
        self.subBar:setWidth(200);          ---バーの全体の長さを指定
        self.subBar:setHeight(13);          ---バーの幅を指定
        self.subBar:loadBarTexture("battle_barrier_gauge_white.png","CocoStudio/Battle/resource/Battle_UI.plist");
        self.subBar:setBarColor(255,153,0);
    end
    self.subBar:setPercent(0);          ---バーの残量を0%に指定
    self.subBar:setVisible(false);

    ---タイマーギミック（既存のタイマーを消してから作り直す）
    self:removeExTimer();
    self:removeHp0Timer();

    ---リーダーギミック
    ---getIsLeader() は協力マルチではクライアント相対（自分のリーダーだけ true。Team.cpp:130）。
    ---各クライアントが自分のリーダーの index を配り合って全クライアントで同じ集合を持つ
    self.leaderIndexes = {};

    ---鉄壁（HP0%フラグ）
    self.armorState = false;

    ---耐性追加ギミック用の累計ダメージ
    self.physicalDamage = 0;
    self.magicDamage = 0;
    self.elementDamage = {};
    self.resistAttribute = 0;           ---1=物理 2=魔法
    self.resistElement = 0;             ---1..5

    ---パーティ全滅・撃破のINFOを一度だけ出すためのフラグ
    self.partySeen = false;
    self.partyWipeDone = false;
    self.deadInfoDone = false;
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    ---リーダーギミック（自分のリーダーの index を配ってから付与する）
    self:shareLeaderIndex();
    self:applyLeaderBuff();
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    ---リーダーギミック（主人公化・変身でユニットが入れ替わった場合も付け直す）
    self:applyLeaderBuff();

    ---エクストラゲージ（フィールド装置）
    if self.exGaugeFLG then
        self:exGaugeControll(event.unit);
    end

    ---タイマーギミック
    self:timerOperation(event.unit);

    ---パーティ全滅時のINFO
    self:checkPartyWipe();

    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

--===================================================================================================================
-- リーダーギミック
--===================================================================================================================
---自分のリーダーの index を全クライアントへ配る（何度呼んでも同じ結果）
function class:shareLeaderIndex()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil and u:getIsLeader() then
            self.leaderIndexes[u:getIndex()] = true;
            megast.Battle:getInstance():sendEventToLua(self.scriptID,9,u:getIndex());
            return;
        end
    end
end

---リーダーはPTに必ず1人。配り合った index の最小値＝編成順で最初のプレイヤー
---（協力マルチでは player0＝ホスト）のリーダーを唯一のリーダーとする
function class:getLeaderIndex()
    local leaderIndex = nil;
    for index,_ in pairs(self.leaderIndexes) do
        if leaderIndex == nil or index < leaderIndex then
            leaderIndex = index;
        end
    end
    return leaderIndex;
end

function class:isLeaderUnit(unit)
    if unit == nil then
        return false;
    end
    local leaderIndex = self:getLeaderIndex();
    return leaderIndex ~= nil and unit:getIndex() == leaderIndex;
end

function class:applyLeaderBuff()
    local leaderIndex = self:getLeaderIndex();
    if leaderIndex == nil then
        return;
    end
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil then
            if u:getIndex() == leaderIndex then
                if u:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID) == nil then
                    self:execAddBuff(u,self.BUFF_BOX_LIST[1]);
                end
            else
                ---後から小さいindexが配られてリーダーが確定した場合、暫定で付いたバフを外す
                self:removeBuff(u,self.BUFF_BOX_LIST[1].ID);
            end
        end
    end
end

--===================================================================================================================
-- エクストラゲージ（フィールド装置）
--===================================================================================================================
function class:startExGauge()
    self.exGaugeFLG = true;
    self.exGaugeDamage = 0;
    self.exGaugeSentDamage = -1;
    self.SUB_HP = self.GD.exGaugeHP;
    ---バリアエフェクト（エクストラゲージ破壊まで）
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2]);
    ---エクストラゲージ表示中タイマー
    self:startExTimer();
end

function class:exGaugeControll(unit)
    if self.SUB_HP <= 0 then
        ---ギミックカラムで0が入った場合の保険（0除算でゲージ表示が壊れるのを防ぐ）
        self.exGaugeDamage = 0;
        self.SUB_HP = 1;
    end
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY() + self.GD.subBarPosY);
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - self.exGaugeDamage) / self.SUB_HP);

    ---削り切りの判定はホストのみ
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    if self.SUB_HP - self.exGaugeDamage <= 0 then
        ---耐性追加ギミック：HP100%〜HP80%の累計で属性耐性を確定（ホストが決めて配る）
        local element = self:calcResistElement();
        self:breakExGauge(element);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,element);
    end
end

function class:breakExGauge(element)
    if not self.exGaugeFLG then
        return;
    end
    self.exGaugeFLG = false;
    self.exGaugeDamage = 0;
    self.subBar:setVisible(false);
    ---バリアエフェクト解除
    self:removeBuff(self.gameUnit,self.BUFF_BOX_LIST[2].ID);
    ---エクストラゲージ破壊でタイマー消去
    self:removeExTimer();
    ---ボスは3秒間、気絶状態になる
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3]);
    ---奥義ゲージ上昇量アップ
    self.spValue = self.GD.exGaugeBreakAddSP;
    self:showMessage(self.EXGAUGE_BREAK_MESSAGE_LIST);
    ---耐性追加ギミック
    self:applyResistElement(element);
end

--===================================================================================================================
-- タイマーギミック
--===================================================================================================================
---エクストラゲージ表示中タイマー（パーティの最大HPダウン）
function class:startExTimer()
    if self.exTimeIndex ~= nil then
        return;
    end
    self.exTimeIndex = megast.Battle:getInstance():createExtraTimer(
        self.GD.exTgTimer, self.GD.exTgLimit,
        self.GD.exTgIconNum1, self.GD.exTgIconNum2,
        self.GD.exTgPosX, self.GD.exTgPosY, self.GD.exTgScale);
end

function class:removeExTimer()
    if self.exTimeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.exTimeIndex,1,0,true);
        self.exTimeIndex = nil;
    end
end

---HP0%フラグタイマー（パーティの被ダメージアップ）
function class:startHp0Timer()
    if self.hp0TimeIndex ~= nil then
        return;
    end
    self.hp0TimeIndex = megast.Battle:getInstance():createExtraTimer(
        self.GD.hp0TgTimer, self.GD.hp0TgLimit,
        self.GD.hp0TgIconNum1, self.GD.hp0TgIconNum2,
        self.GD.hp0TgPosX, self.GD.hp0TgPosY, self.GD.hp0TgScale);
end

function class:removeHp0Timer()
    if self.hp0TimeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.hp0TimeIndex,1,0,true);
        self.hp0TimeIndex = nil;
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if self.exTimeIndex ~= nil and event.index == self.exTimeIndex then
        ---パーティの最大HPダウン（重複・アイコンに数字表示）
        self:unitAddBuff(self.EX_TG_BUFF_LIST[1]);
        ---アイコンの数字に応じてタイマーが徐々に加速する
        megast.Battle:getInstance():setExtraTimerMaxTime(self.exTimeIndex,
            self:getAccelTime(event.count,self.EX_TG_BUFF_LIST[1].MAX,self.GD.exTgTimer,self.GD.exTgAccelStep,self.GD.exTgTimerMin));
    elseif self.hp0TimeIndex ~= nil and event.index == self.hp0TimeIndex then
        ---パーティの被ダメージアップ（重複・アイコンに数字表示）
        self:unitAddBuff(self.HP0_TG_BUFF_LIST[1]);
        megast.Battle:getInstance():setExtraTimerMaxTime(self.hp0TimeIndex,
            self:getAccelTime(event.count,self.HP0_TG_BUFF_LIST[1].MAX,self.GD.hp0TgTimer,self.GD.hp0TgAccelStep,self.GD.hp0TgTimerMin));
    end
    return event.count;
end

---[base-アイコンの数字×step]秒。アイコンの数字は重複上限で打ち止め
function class:getAccelTime(count,maxCount,base,step,minSec)
    local iconNum = count;
    if maxCount ~= nil and iconNum > maxCount then
        iconNum = maxCount;
    end
    local sec = base - iconNum * step;
    if sec < minSec then
        sec = minSec;
    end
    return sec;
end

---※このタイマーはブレイク・無敵中・HPフラグ奥義中は停止する（遅延は無し）
function class:timerOperation(unit)
    if self.exTimeIndex == nil and self.hp0TimeIndex == nil then
        return;
    end
    local speed = 1;
    if unit:isBreak() or unit:getInvincibleTime() > 0 or self.hpSkillFLG then
        speed = 0;
    end
    if self.exTimeIndex ~= nil then
        if megast.Battle:getInstance():getExtraTimerSpeed(self.exTimeIndex) ~= speed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.exTimeIndex,speed);
        end
    end
    if self.hp0TimeIndex ~= nil then
        if megast.Battle:getInstance():getExtraTimerSpeed(self.hp0TimeIndex) ~= speed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.hp0TimeIndex,speed);
        end
    end
end

--===================================================================================================================
-- パーティ全滅時
--===================================================================================================================
function class:checkPartyWipe()
    if self.partyWipeDone then
        return;
    end
    ---バトルステートは全滅を検知する前に切り替わることがあるので条件に使わない。
    ---このボスは最終Waveなので「一度ユニットを見ている＋生存0」で全滅と判定する
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        if myTeam:getTeamUnit(i) ~= nil then
            self.partySeen = true;
            return;
        end
    end
    ---一度でもユニットを確認できている場合のみ全滅と判定する
    if not self.partySeen then
        return;
    end
    self.partyWipeDone = true;
    self:showMessage(self.PARTY_DEAD_MESSAGE_LIST);
end

--===================================================================================================================
-- 耐性追加ギミック（既定OFF）
--===================================================================================================================
---HP100%〜HP80%までで累計が大きい属性
function class:calcResistElement()
    if self.GD.extraResistEnable ~= 1 then
        return 0;
    end
    local maxDmg = 0;
    local maxID = 0;
    for id,dmg in pairs(self.elementDamage) do
        if dmg > maxDmg then
            maxDmg = dmg;
            maxID = id;
        end
    end
    return maxID;
end

---HP80%〜HP50%までで累計ダメージが大きい物理／魔法
function class:calcResistAttribute()
    if self.GD.extraResistEnable ~= 1 then
        return 0;
    end
    ---クリティカルダメージは skillAttribute==3 になり物理／魔法のどちらにも積算されない。
    ---どちらも判定できなかった場合は魔法耐性にする
    if self.physicalDamage == 0 and self.magicDamage == 0 then
        return 2;
    end
    return self.magicDamage > self.physicalDamage and 2 or 1;
end

function class:applyResistElement(element)
    if element ~= nil and element > 0 then
        self.resistElement = element;
    end
end

function class:applyResistAttribute(attribute)
    if attribute ~= nil and attribute > 0 then
        self.resistAttribute = attribute;
    end
end

function class:addResistDamage(enemyUnit,value)
    local element = enemyUnit:getElementType();
    if element ~= nil and element > 0 then
        self.elementDamage[element] = (self.elementDamage[element] or 0) + value;
    end
    local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if attribute == 1 then
        self.physicalDamage = self.physicalDamage + value;
    elseif attribute == 2 then
        self.magicDamage = self.magicDamage + value;
    end
end

function class:getExtraResistRate(enemyUnit)
    local rate = 1;
    if self.resistElement ~= 0 and enemyUnit:getElementType() == self.resistElement then
        rate = rate * self.GD.extraResistRate;
    end
    if self.resistAttribute ~= 0 then
        local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == self.resistAttribute then
            rate = rate * self.GD.extraResistRate;
        end
    end
    return rate;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    ---spine(104297111)に runScript イベントは無いので addSP は takeAttack 側で行う
    return 1;
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

    ---アニメーションの差し替え
    local animation = self.ATTACK_ANIMATIONS[event.index];
    if animation ~= nil then
        event.unit:setNextAnimationName(animation);
        event.unit:setNextAnimationEffectName(self.EF_PREFIX..animation);
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);

    ---ユニットボスは run（spineのrunScript-addSP）を持たないので通常攻撃の成立時にaddSPする
    ---奥義直後の通常攻撃ではaddSPせず、引き継いだ奥義ゲージを戻す
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false;
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.hpSkillFLG = false;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    else
        self:addSP(event.unit);
    end
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時は行動パターンを進めない
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
    end
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

    ---アニメーションの差し替え
    local animation = self.SKILL_ANIMATIONS[event.index];
    if animation ~= nil then
        event.unit:setNextAnimationName(animation);
        event.unit:setNextAnimationEffectName(self.EF_PREFIX..animation);
    end

    ---奥義5＆10＆13：燃焼状態のユニットのダメージ無効化無効
    if self.BURST_INFO_SKILLS[event.index] then
        self:showMessage(self.BURST_MESSAGE_LIST);
    end

    self.skillCheckFlg = false;
    self.addSpSkipFLG = true;   ---奥義直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1;
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex();
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill;
        self.hpSkill = 0;
    else
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

    ---耐性追加ギミック用の累計ダメージ集計（ホストのみ）
    if megast.Battle:getInstance():isHost() then
        self:addResistDamage(enemyUnit,event.value);
    end

    ---エクストラゲージ表示中、ボスは全てのダメージに対してダメージを1にする
    if self.exGaugeFLG then
        event.value = 1;
        event.value = self:adjustHpFlg(event.unit,event.value);
        return event.value;
    end

    ---鉄壁（HP0%フラグ）：一度ブレイクするまでダメージを1にする
    if self.armorState then
        event.value = 1;
        event.value = self:adjustHpFlg(event.unit,event.value);
        return event.value;
    end

    ---耐性追加ギミック（既定OFF）
    local rate = self:getExtraResistRate(enemyUnit);
    if rate ~= 1 and event.value > 0 then
        event.value = math.max(math.floor(event.value * rate),1);
    end

    ---HPフラグ境界でのダメージ調整（必ず最後）
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（event.enemy を持たないため属性・性質の判定はできない）
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    elseif self.exGaugeFLG or self.armorState then
        ---エクストラゲージ表示中・鉄壁中はボスの全ダメージを1にする
        event.value = 1;
    end
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
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
    ---HPフラグは発動から打ち終わるまでブレイク不可
    if self.hpSkillFLG then
        return 0;
    end

    ---エクストラゲージはブレイクダメージのみ有効。かつリーダーユニットのみが削れる
    ---（リーダーが死亡している場合は削れない）
    if self.exGaugeFLG and megast.Battle:getInstance():isHost() then
        local enemyUnit = self:getAncestorUnit(event.enemy);
        if self:isLeaderUnit(enemyUnit) and enemyUnit:getHP() > 0 then
            self.exGaugeDamage = self.exGaugeDamage + event.value;
            local sendValue = math.floor(self.exGaugeDamage);
            if sendValue ~= self.exGaugeSentDamage then
                self.exGaugeSentDamage = sendValue;
                megast.Battle:getInstance():sendEventToLua(self.scriptID,6,sendValue);
            end
        end
    end

    if self.exGaugeFLG then
        event.value = 1;
    end
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

    ---鉄壁マーク・takeDamageValue補正はブレイクさせると解除
    if self.armorState then
        self.armorState = false;
        event.unit:removeNumBreakBadge();
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
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0);
        end
    end
    ---hpSkillFLG（ブレイク不可）はHP80%／HP50%だけが立て、奥義を撃ち終えた takeAttack で解除する。
    ---ここでアイドルを見て解除すると、hpSkill を持たないゲスト側だけ早期解除になるため触らない
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:onDead();
    if megast.Battle:getInstance():isHost() then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    end
    return 1;
end

function class:receive4(args)
    self:onDead();
    return 1;
end

---倒れる際（ホスト・ゲストで二重に出さない）
function class:onDead()
    if self.deadInfoDone then
        return;
    end
    self.deadInfoDone = true;
    self:removeExTimer();
    self:removeHp0Timer();
    self:showMessage(self.DEAD_MESSAGE_LIST);
end

---------------------------------------------------------------------------------
-- receive6（エクストラゲージのダメージ同期）
---------------------------------------------------------------------------------
function class:receive6(args)
    self.exGaugeDamage = args.arg;
    return 1;
end

---------------------------------------------------------------------------------
-- receive7（エクストラゲージ破壊通知＋属性耐性の種別）
---------------------------------------------------------------------------------
function class:receive7(args)
    self:breakExGauge(args.arg);
    return 1;
end

---------------------------------------------------------------------------------
-- receive8（物理／魔法耐性の種別）
---------------------------------------------------------------------------------
function class:receive8(args)
    self:applyResistAttribute(args.arg);
    return 1;
end

---------------------------------------------------------------------------------
-- receive9（他クライアントのリーダーindex）
---------------------------------------------------------------------------------
function class:receive9(args)
    ---start() より先に届いた場合の保険
    if self.leaderIndexes == nil then
        self.leaderIndexes = {};
    end
    self.leaderIndexes[args.arg] = true;
    if self.BUFF_BOX_LIST ~= nil then
        self:applyLeaderBuff();
    end
    return 1;
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
                ---通常マーカーはブレイク中は発動しない。ブレイクが明けてから発動させる。
                ---isBreak() だけでは足りない：breakPoint が0になったフレームは
                ---m_breaktime がまだ0のため isBreak() が false を返す
                ---（engine は次の update で takeBossBreak する／TeamUnit.cpp:6230）。
                ---そこで発動してしまうと、直後にブレイクへ入って奥義を撃てず
                ---hpSkillFLG が解除されないままボスが停止する。breakPoint も見て待つ。
                ---ブレイクが明けると engine が breakPoint を満タンへ戻すので、その後に発動する。
                if not unit:isBreak() and unit:getBreakPoint() > 0 then
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

-- バフ削除
function class:removeBuff(unit,buffID)
    local cond = unit:getTeamUnitCondition():findConditionWithID(buffID);
    if cond ~= nil then
        unit:getTeamUnitCondition():removeCondition(cond);
    end
end

-- 全プレイヤーユニットへバフ付与
function class:unitAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
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
        local flag = true;
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


class:publish();

return class;
