local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="Dragon", version=1.3, id=000});
class:inheritFromUnit("unitBossBase");

--[[
================================================================================
  BreakCountBoss テンプレート
  --- 水霧デグルマグナ (2004445) から抽出した継承用ベースクラス ---
================================================================================

【ギミック概要】
  - ブレイク回数によってダメージ倍率が変化（ブレイクするほど被ダメージアップ）
  - 物理攻撃耐性（takeDamageValue 内で attribute==1 のとき倍率補正）
  - 状態異常持ちの攻撃者に対してのみダメージ補正が適用される（findBadCondition）
  - BreakBadge を複数所持し、ブレイクのたびに消費してカウントアップ
  - HPトリガー（60%, 30%）で hpSkill + 無敵 + attackDelay 変更
  - 奥義1発動時にプレイヤーユニット全員へ状態異常耐性デバフ（weakenBadCondition）

【アニメーションイベントの流れ】
  run() で spine イベントを受信する。
    "addSP"      → addSP(unit)    : 通常攻撃終了後に奥義ゲージ加算
    "targetLock" → targetLock()   : ネックアングルをセットしてロックオン
    "fire"       → fire(unit)     : OrbitSystem でファイアボールを発射

【継承先での使い方】
  1. label / version / id を差し替える
     例: summoner.Bootstrap.createEnemyClass({label="ボス名", version=1.3, id=XXXXX})
  2. class:inheritFromUnit("unitBossBase") はそのまま残す
  3. ATTACK_SET_LIST / SKILL_SET_LIST / ACTIVE_SKILLS / cutInSkill を定義する
  4. setBuffBoxList() をオーバーライドして BUFF_LIST を定義する
  5. setMessageBoxList() をオーバーライドしてメッセージを定義する
  6. setTriggerList() をオーバーライドして HPトリガーを定義する（hp??関数も追加する）
  7. start() の spValue / attackDelay / breakBadge 数 / damageBox / breakBox を調整する
  8. takeDamageValue() で物理補正率・damageBox 値を変更する
  9. fire() / targetLock() を必要に応じてオーバーライドする
  10. takeSkill() の奥義インデックスごとの処理を継承先で追加する

【バフID 命名規則】
  BUFF_BOX_LIST の ID は「エネミーID + 連番」で一意にすること。
  例: エネミーID=2004445 なら 20044451, 20044452 ...
  weakenBadCondition() 内のバフID (50411213, 50411214) はデグルマグナ固有値。
  継承先で別ボスに使う場合は必ず別IDに変更すること。

【receive 番号の用途】
  1 : attackReroll ブロードキャスト（host → client）
  2 : skillReroll ブロードキャスト（host → client）
  3 : HPトリガー発動同期（host → client） → receive3 で処理
  4 : dead イベント同期（必要な場合に継承先で追加）

【afterSkillFLG について】
  generatedRule.md の addSpSkipFLG に相当するフラグ。
  奥義終了後の最初の通常攻撃で saveBP を返却し、無敵を解除する。
  takeAttack() の先頭で処理するため、テンプレートでは addSpSkipFLG ではなく
  afterSkillFLG という名前を使用している。動作は同等。

【breakSkip の初期値について】
  start() で breakSkip = true に初期化している。
  これはボス生成直後の最初のブレイクダメージをスキップするための設定。
  generatedRule.md のデフォルト実装（false 初期化）と異なるため注意。
================================================================================
--]]

------------------------------------------------------------------------
-- スキル構成定義（継承先でオーバーライドすること）
------------------------------------------------------------------------
-- 【オーバーライド必須】
-- ATTACK_SET_LIST, SKILL_SET_LIST, ACTIVE_SKILLS, cutInSkill を定義する。
--
-- デグルマグナの定義例:
--   class.ATTACK_SET_LIST = {
--       DEFAULT = {
--           { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50 }
--       }
--   }
--   class.SKILL_SET_LIST = {
--       DEFAULT = {
--           { SKILL1 = 50 }
--       }
--   }
--   class.ACTIVE_SKILLS = {
--       ATTACK1 = 1,
--       ATTACK2 = 2,
--       ATTACK3 = 3,
--       SKILL1  = 4,
--       SKILL2  = 5
--   }
--   class.cutInSkill = {
--       [2] = 1   -- インデックス2の奥義を真奥義カットインで発動
--   }

class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 }
    }
}
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL1 = 50 }
    }
}
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1  = 2
}
class.cutInSkill = {}

------------------------------------------------------------------------
-- バフ定義（継承先でオーバーライドすること）
------------------------------------------------------------------------
-- 【オーバーライド推奨】
-- 各バフを BUFF_LIST テーブルに定義する。
-- ID はエネミーID + 連番で一意にすること（重複すると上書きされる）。
function class:setBuffBoxList()
    -- 継承先でオーバーライドして使用するバフを定義する。
    -- 例:
    --   self.BUFF_LIST = {
    --       [1] = {
    --           ID       = 000000001,   -- エネミーID + 連番
    --           BUFF_ID  = 0,
    --           VALUE    = 0,
    --           DURATION = 99999,
    --           ICON     = 0
    --       }
    --   }
    self.BUFF_LIST = {}
end

------------------------------------------------------------------------
-- メッセージ定義（継承先でオーバーライドすること）
------------------------------------------------------------------------
-- MESSAGE 以外はデフォルト値で動くため構造はほぼ同一になる
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE  = messageBox.MESSAGE  or "メッセージ",
        COLOR    = messageBox.COLOR    or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

-- 【オーバーライド推奨】
-- self.TEXT はロケールファイル（ja_jp.lua 等）から取得するため、
-- フォールバック文字列も必ず用意すること。
-- 最低限 START_MESSAGE_LIST / BREAK_MESSAGE_LIST / BREAK_END_MESSAGE_LIST を定義する。
--
-- デグルマグナの定義例:
--   self.START_MESSAGE_LIST = {
--       self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性",          COLOR = Color.yellow}),
--       self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "物理耐性・人族キラー",                      COLOR = Color.yellow}),
--       self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ブレイクするほど被ダメージアップ",          COLOR = Color.yellow}),
--       self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "燃焼状態のユニットに対するクリティカル率アップ", COLOR = Color.yellow})
--   }
--   self.BREAK_MESSAGE_LIST = {
--       self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイク成功！被ダメージアップ！", COLOR = Color.red})
--   }
--   self.BREAK_END_MESSAGE_LIST = {
--       self:setMessageInfo({MESSAGE = self.TEXT.BREAK_END_MESSAGE1 or "ブレイク耐性アップ", COLOR = Color.yellow})
--   }
function class:setMessageBoxList()
    self.START_MESSAGE_LIST     = {}
    self.BREAK_MESSAGE_LIST     = {}
    self.BREAK_END_MESSAGE_LIST = {}
end

------------------------------------------------------------------------
-- HPトリガー定義（継承先でオーバーライドすること）
------------------------------------------------------------------------
-- 【オーバーライド推奨】
-- tag = "HP_FLG" : HP割合トリガー
-- HP  = 60       : 60% で発動（0% は 0.1 を使う。0 では発動しない）
-- used = false   : 初期値（必ず false にする）
--
-- デグルマグナのトリガー定義例:
--   [1] = { tag="HP_FLG", action=function(s) self:hp60(s) end, HP=60, used=false }
--   [2] = { tag="HP_FLG", action=function(s) self:hp30(s) end, HP=30, used=false }
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag    = "HP_FLG",
            action = function(status) self:hp50(status) end,
            HP     = 50,
            used   = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers   = {}
    for index, trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index]                 = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

------------------------------------------------------------------------
-- HPトリガー発動関数（継承先でオーバーライドすること）
------------------------------------------------------------------------
-- 【オーバーライド推奨】
-- setTriggerList で登録したトリガーに対応する関数をボスごとに定義する。
-- status == "use3" のときのみ実際の処理を実行する。
--
-- 共通処理パターン（デグルマグナ準拠）:
--   self.stateName = "FURY"
--   self.hpSkill   = <次に発動する奥義の ACTIVE_SKILLS インデックス>
--   self.saveBP    = self.gameUnit:getBurstPoint()    ← addSP(100) より前に取得
--   self.gameUnit:addSP(100)
--   self.gameUnit:setInvincibleTime(<打ち終わるまでの秒数>)
--   self.gameUnit:setAttackDelay(<新しいディレイ値>)  ← フェーズ移行で速度変更する場合
--   self:showMessage(self.HPxx_MESSAGE_LIST)
--
-- デグルマグナの実装例:
--   function class:hp60(status)
--       if status == "use3" then
--           self.stateName = "FURY"
--           self.hpSkill   = 2
--           self.saveBP    = self.gameUnit:getBurstPoint()
--           self.gameUnit:addSP(100)
--           self.gameUnit:setInvincibleTime(15)
--           self.gameUnit:setAttackDelay(9)
--       end
--   end
--   function class:hp30(status)
--       if status == "use3" then
--           self.stateName = "FURY"
--           self.hpSkill   = 2
--           self.saveBP    = self.gameUnit:getBurstPoint()
--           self.gameUnit:addSP(100)
--           self.gameUnit:setInvincibleTime(15)
--           self.gameUnit:setAttackDelay(7)
--       end
--   end
function class:hp50(status)
    if status == "use3" then
        -- 継承先でオーバーライドする
    end
end

------------------------------------------------------------------------
-- start（初期化）
------------------------------------------------------------------------
-- 【オーバーライド推奨】
-- spValue / attackDelay / BreakBadge 数 / damageBox / breakBox を調整する。
-- ボス固有の変数（ロックオン系など）はオーバーライド先で追加する。
function class:start(event)
    self.fromHost = false
    self.gameUnit = event.unit

    ------- 調整可能パラメータ（継承先で変更する） -------
    self.spValue = 20                      -- addSP の量（通常攻撃の "addSP" spine イベントで加算）
    event.unit:setAttackDelay(10)          -- アタックディレイ（大きいほど遅い）
    -- event.unit:addSP(40)               -- 戦闘開始時に奥義ゲージを付与したい場合

    ------- フラグ初期化 -------
    self.attackCheckFlg = false
    self.skillCheckFlg  = false
    self.afterSkillFLG  = false            -- 奥義後フラグ（addSpSkipFLG 相当）

    event.unit:setSPGainValue(0)           -- 奥義ゲージ自然上昇を0に
    event.unit:setSkillInvocationWeight(0) -- 奥義自動発動を無効化

    self.isRage  = false
    self.isFury  = false

    ------- 各リスト初期化 -------
    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    ------- 行動パターン初期化 -------
    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT  = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true                  -- 初回ブレイクダメージをスキップ（デグルマグナ方式）
    self.hpSkill   = 0
    self.saveBP    = 0

    ------- ブレイク回数ダメージテーブル（継承先で値を変更する） -------
    -- damageBox : ブレイク回数ごとの通常ダメージ倍率
    --   breakCount < 5  → damageBox[breakCount] を使用
    --   breakCount >= 5 → (breakCount + 6) * 0.1 を使用
    -- breakBox  : ブレイク回数ごとのブレイクダメージ倍率
    --   breakCount < 5  → breakBox[breakCount] を使用
    --   breakCount >= 5 → 0.1 固定
    --
    -- デグルマグナの設定値:
    --   damageBox = {[0]=0.05, [1]=0.3, [2]=0.5, [3]=0.7, [4]=1.0}
    --   breakBox  = {[0]=1.0,  [1]=0.8, [2]=0.7, [3]=0.4, [4]=0.2}
    self.damageBox = {
        [0] = 0.05,
        [1] = 0.3,
        [2] = 0.5,
        [3] = 0.7,
        [4] = 1.0
    }
    self.breakBox = {
        [0] = 1.0,
        [1] = 0.8,
        [2] = 0.7,
        [3] = 0.4,
        [4] = 0.2
    }
    self.breakCount = 0
    event.unit:addNumBreakBadge(5)         -- BreakBadge 数（継承先で変更する）

    ------- ボス固有の変数（継承先でオーバーライドして追加する） -------
    -- デグルマグナの固有変数例（fire/targetLock ギミック用）:
    --   self.isLockOn   = true
    --   self.neckAngle  = 0
    --   self.shotAngle  = 0
    --   self.isFireEnd  = true
    --   self.fireSwitch = 1

    return 1
end

------------------------------------------------------------------------
-- update（毎フレーム処理）
------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100, 1)   -- ヒットストップ・時止め無効

    -- ブレイク終了メッセージ表示
    -- breakFLG は takeBreake() で立てる。m_breaktime が 0 になったら終了と判定。
    if self.breakFLG and event.unit.m_breaktime == 0 then
        if self.breakCount <= 5 then
            self:showMessage(self.BREAK_END_MESSAGE_LIST)
        end
        self.breakFLG = false
    end

    -- 継承先で追加処理が必要な場合はオーバーライドして独自フラグチェックを追加する。
    -- 例: subBarFlg / extraTimer 管理 / lastSkillFLG 処理 など

    return 1
end

------------------------------------------------------------------------
-- run（spine アニメーションイベント処理）
------------------------------------------------------------------------
-- 【オーバーライド推奨】
-- "addSP" は共通処理として実装済み。
-- ボス固有のイベント（"fire", "targetLock" 等）は継承先で追加する。
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    -- 継承先での追加例（デグルマグナ）:
    --   if event.spineEvent == "targetLock" then self:targetLock() end
    --   if event.spineEvent == "fire"       then self:fire(event.unit) end
    return 1
end

function class:addSP(unit)
    unit:addSP(self.spValue)
    return 1
end

------------------------------------------------------------------------
-- ボス固有アニメーション処理（継承先でオーバーライドすること）
------------------------------------------------------------------------
-- targetLock : spine イベント "targetLock" で呼ばれる。ロックオン演出。
-- fire       : spine イベント "fire" で呼ばれる。OrbitSystem でビームや弾を発射する。
--              ボスごとにボーン名・アニメーション名・軌道パラメータが異なるためオーバーライドする。
function class:targetLock()
    -- デグルマグナの実装例:
    --   self.isLockOn  = true
    --   self.neckAngle = 295
end

function class:fire(unit)
    -- デグルマグナの実装例:
    --   local shot = unit:addOrbitSystem("fireball", 1)
    --   shot:setActiveSkill(self.fireSwitch)
    --   shot:setHitCountMax(1)
    --   shot:setEndAnimationName("explosion")
    --   local x  = unit:getPositionX()
    --   local y  = unit:getPositionY()
    --   local xb = unit:getSkeleton():getBoneWorldPositionX("EF_fire_mouth")
    --   local yb = unit:getSkeleton():getBoneWorldPositionY("EF_fire_mouth")
    --   shot:setPosition(x + xb, y + yb)
    --   shot:setRotation(-self.neckAngle)
    --   self.shotAngle = self.neckAngle
    --   shot:setZOrder(unit:getZOrder() - 1)
    --   self.isFireEnd = true
end

------------------------------------------------------------------------
-- takeAttack（通常攻撃処理）
------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true
        return self:attackReroll(event.unit)
    end
    self.attackCheckFlg = false
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle()
        return 0
    end

    -- アニメーション変更が必要な場合は継承先でオーバーライドして条件追加する。
    -- デグルマグナの例（ATTACK3 のとき attack4 アニメーションを使用）:
    --   if event.index == 3 then
    --       event.unit:setNextAnimationName("attack4")
    --       event.unit:setNextAnimationEffectName("1-attack4")
    --   end

    self.fromHost = false

    -- 奥義後の最初の通常攻撃で saveBP を返却し無敵を解除する（afterSkillFLG 方式）
    if self.afterSkillFLG then
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
    end

    self:attackActiveSkillSetter(event.unit, event.index)
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    self:movePatternState(self.ATTACK_SET_LIST, self.STATE_ATTACK)
    unit:takeAttack(attackIndex)
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 1, attackIndex)
    return 0
end

function class:takeIdle(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
    return 1
end

------------------------------------------------------------------------
-- takeSkill（奥義処理）
------------------------------------------------------------------------
function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true
        return self:skillReroll(event.unit)
    end
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle()
        return 0
    end

    -- 奥義インデックスごとの処理は継承先でオーバーライドして追加する。
    -- デグルマグナの例（奥義1でプレイヤーユニット全員へ状態異常耐性デバフ）:
    --   if event.index == 1 then
    --       local myTeam = megast.Battle:getInstance():getTeam(true)
    --       for i = 0, 6 do
    --           local myTeamUnit = myTeam:getTeamUnit(i)
    --           if myTeamUnit ~= nil then
    --               self:weakenBadCondition(myTeamUnit, 60, -50)
    --           end
    --       end
    --   end

    self.skillCheckFlg = false
    self.afterSkillFLG = true             -- 奥義終了後フラグ（次の通常攻撃で saveBP を返却）
    self.fromHost      = false
    self:skillActiveSkillSetter(event.unit, event.index)
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    if self.hpSkill ~= 0 then
        skillIndex   = self.hpSkill
        self.hpSkill = 0
    else
        self:movePatternState(self.SKILL_SET_LIST, self.STATE_SKILL)
    end
    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex), self.cutInSkill[skillIndex])
    else
        unit:takeSkill(tonumber(skillIndex))
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 2, tonumber(skillIndex))
    return 0
end

function class:takeSkillFromHost(unit, index)
    self.fromHost = true
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index, self.cutInSkill[index])
    else
        unit:takeSkill(index)
    end
end

------------------------------------------------------------------------
-- 状態異常耐性デバフ付与
------------------------------------------------------------------------
-- 奥義発動時などにプレイヤーユニットへ状態異常耐性デバフを付与する。
-- buffID : BUFF_ID（状態異常耐性の種類。例: 60=状態異常耐性全般）
-- value  : 効果量（マイナスでダウン。例: -50 で50%ダウン）
-- 【注意】ID の 50411213 / 50411214 はデグルマグナ固有値。
--         継承先で別ボスに使う場合は「エネミーID + 連番」に変更すること。
function class:weakenBadCondition(unit, buffID, value)
    local BUFF_LIST = {
        ID       = 50411213,    -- 継承先でエネミーID連番に変更する
        BUFF_ID  = buffID,
        VALUE    = value,
        DURATION = 99999,
        ICON     = buffID + 16,
        MAX      = 10
    }
    local BUFF_LIST2 = {
        ID       = 50411214,    -- 継承先でエネミーID連番に変更する
        BUFF_ID  = buffID + 49, -- 状態異常回避率 BUFF_ID は耐性 BUFF_ID + 49 の規則
        VALUE    = value,
        DURATION = 99999,
        ICON     = 0,
        MAX      = 10
    }
    self:execAddBuff(unit, BUFF_LIST)
    self:execAddBuff(unit, BUFF_LIST2)
end

------------------------------------------------------------------------
-- takeDamageValue（ダメージ補正）
------------------------------------------------------------------------
-- 【オーバーライド推奨】
-- 物理補正率・状態異常チェック・damageBox の値を継承先で変更する。
--
-- 処理の流れ:
--   1. attribute==1（物理）のとき 0.1 倍（物理耐性）
--   2. 攻撃元に状態異常がある場合 damageBox[breakCount] 倍
--      ※ breakCount >= 5 は (breakCount + 6) * 0.1
--   3. adjustHpFlg で HPトリガー境界でダメージを止める（必ず末尾に呼ぶ）
--
-- オービット対策:
--   event.enemy が OrbitSystem の場合 getParentTeamUnit() が存在するため
--   localEnemy で親ユニットを取得してから状態異常を判定する。
function class:takeDamageValue(event)
    -- 物理耐性（補正率は継承先で変更する。不要なら削除）
    local attribute = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillAttribute
    if attribute == 1 then
        event.value = event.value * 0.1
    end

    -- 親ユニットを取得（オービット対策）
    local localEnemy = event.enemy
    if event.enemy:getParentTeamUnit() ~= nil then
        localEnemy = event.enemy:getParentTeamUnit()
    end

    -- 攻撃元に状態異常がある場合のダメージ倍率（ブレイク回数で変化）
    if self:findBadCondition(localEnemy) then
        if self.breakCount < 5 then
            event.value = event.value * self.damageBox[self.breakCount]
        else
            event.value = event.value * (self.breakCount + 6) * 0.1
        end
    end

    event.value = self:adjustHpFlg(event.unit, event.value)
    return event.value
end

------------------------------------------------------------------------
-- takeBreakeDamageValue（ブレイクダメージ補正）
------------------------------------------------------------------------
-- breakSkip が true のときブレイクダメージを 0 にする（HPトリガー境界対策）。
-- 攻撃元に状態異常がある場合 breakBox[breakCount] 倍に補正する。
-- breakCount >= 5 の場合は 0.1 固定。
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    local localEnemy = event.enemy
    if event.enemy:getParentTeamUnit() ~= nil then
        localEnemy = event.enemy:getParentTeamUnit()
    end
    if self:findBadCondition(localEnemy) then
        if self.breakCount < 5 then
            event.value = event.value * self.breakBox[self.breakCount]
        else
            event.value = event.value * 0.1
        end
    end
    return event.value
end

------------------------------------------------------------------------
-- takeBreake（ブレイク時処理）
------------------------------------------------------------------------
-- HPトリガー境界でのブレイクをキャンセルする（境界 ±2 の範囲で判定）。
-- BreakBadge を消費してブレイク回数をカウントアップする。
-- breakFLG を立てて update() でブレイク終了メッセージを表示する。
function class:takeBreake(event)
    for i = 1, table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    self:showMessage(self.BREAK_MESSAGE_LIST)
    self.gameUnit:removeNumBreakBadge()
    self.breakCount = self.breakCount + 1
    self.breakFLG   = true
    return 1
end

------------------------------------------------------------------------
-- dead（死亡処理）
------------------------------------------------------------------------
-- 【オーバーライド推奨】
-- 死亡時の処理を継承先で実装する。
-- HP0奥義後に死亡する場合は generatedRule.md の lastSkillFLG / deadFlg を参照。
function class:dead(event)
    -- 継承先でオーバーライドして死亡時の処理を追加する。
    -- 例: エクストラタイマー削除 / DEAD_MESSAGE 表示 / sendEventToLua(4,1) など
    return 1
end

------------------------------------------------------------------------
-- 状態異常チェック
------------------------------------------------------------------------
-- 対象ユニットが何らかの状態異常にかかっているかを確認する。
-- 【オーバーライド可】
-- 対象の状態異常を絞りたい場合はオーバーライドする。
--   例（毒・燃焼のみ）: local badStatusList = {90, 97}
--
-- 状態異常タイプ番号:
--   89=気絶, 90=毒, 91=封印, 92=?, 93=暗闇, 94=病気, 95=呪い, 96=氷結, 97=燃焼
function class:findBadCondition(unit)
    local badStatusList = {89, 90, 91, 92, 93, 94, 95, 96, 97}
    for _, v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return true
        end
    end
    return false
end

------------------------------------------------------------------------
-- HPトリガー境界でのダメージ調整
------------------------------------------------------------------------
-- takeDamageValue の末尾で必ず呼ぶこと。
-- HPトリガー境界をオーバーキルしないようにダメージを調整する。
-- breakSkip を立てて takeBreakeDamageValue で境界のブレイクダメージをスキップさせる。
function class:adjustHpFlg(unit, value)
    local anotherHp = unit:getHP() - value
    for _, trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit)
            return self:calcDamageValue(unit, stopBorder, value)
        end
    end
    return value
end

function class:calcDamageValue(unit, border, value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

--===================================================================================================================
-- メッセージ表示
--===================================================================================================================
function class:showMessage(messageBoxList, index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
    for _, messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function class:showMessageRange(messageBoxList, start, finish)
    for i = start, finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE, messageBox.DURATION, messageBox.COLOR)
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE, messageBox.DURATION, messageBox.COLOR)
    end
end

--===================================================================================================================
-- HPトリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return
    end
    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100
    for index, trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            self:execTrigger(index)
        end
    end
end

-- トリガー実行。ホストのみ使用可能。
-- receiveNumber のデフォルトは 3（receive3 → ゲスト同期）
function class:execTrigger(index, receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end
    receiveNumber = receiveNumber ~= nil and receiveNumber or 3
    local action  = "use" .. receiveNumber
    self.TRIGGERS[index].used = true
    self.TRIGGERS[index].action(action)
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID, receiveNumber, index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost()
end

-- HPトリガー発動時のゲスト側同期（sendEventToLua の番号 3 で呼ばれる）
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
end

--===================================================================================================================
-- バフ付与
--===================================================================================================================
-- MAX フィールドがある場合はスタックカウントを累積する（上限 10）。
-- EFFECT / SCRIPT / FUNC フィールドも対応済み。
function class:execAddBuff(unit, buffBox)
    local buff    = nil
    local oldBuff = nil
    local count   = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > 10 then
                count = 10
            end
        end
    end
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE * count, buffBox.DURATION, buffBox.ICON, buffBox.EFFECT)
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE * count, buffBox.DURATION, buffBox.ICON)
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
        buff:setMaxConditionIconNumber(buffBox.MAX)
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end
end

--===================================================================================================================
-- 行動パターン管理
--===================================================================================================================
function class:movePatternState(SET_LIST, stateBox)
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
    local attackList  = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr   = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount])
    local attackIndex = string.gsub(attackStr, "ATTACK", "")
    return tonumber(attackIndex)
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList  = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr   = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount])
    local skillIndex = string.gsub(skillStr, "SKILL", "")
    return tonumber(skillIndex)
end

function class:initState(weightList)
    local state      = {}
    state.SET_WEIGHT = weightList
    state.actCount   = 1
    state.setCount   = 1
    state.setChar    = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
    return state
end

--===================================================================================================================
-- 停止系状態異常除去
--===================================================================================================================
-- HPトリガー発動時に気絶（89）・封印（91）・氷結（96）を除去する。
-- 全状態異常を除去したい場合は generatedRule.md の refreshAll() を参照。
function class:refresh(unit)
    local badStatusIDs = {89, 91, 96}
    for i = 1, table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i]
        local flag     = true
        local count    = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID)
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond)
            else
                flag = false
            end
            count = count + 1
            if count > 100 then break end
        end
    end
end

------------------------------------------------------------------------

class:publish()

return class
