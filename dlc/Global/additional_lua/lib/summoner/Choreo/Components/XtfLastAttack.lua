------
-- summoner.Choreo.Components.XtfLastAttack
--
-- CODE XTF:ERASER の最後の攻撃（自爆）: HP が0になったら1度だけ死亡を取り消して奥義（既定 index 20＝
-- フィニス＝マキナ。アニメは skill7）を撃たせ、撃ち終えたら戦闘不能にする。
-- 出典: unit/500721013.lua の dead（初回の死亡で setInvincibleTime(7.1)・INFO「フィニス＝マキナ起動」(赤・5秒)・
--   麻痺(91)/気絶(89)/氷結(96)を解除・ホストが takeSkill(7)・setHP(1) して return 0）と update（7秒後に setHP(0)）。
--   原典の takeSkill は index 7 のとき setActiveSkill(20)＝アニメは skill7・効果スロットは 20（7 はファンネルのサーベル）。
--
-- 流れ:
--   1. 初回の dead: 死亡を取り消す（event:prevent()＝C++ へ 0 を返し、後ろの dead リスナも止める）。
--      HP を hp に戻し、invincible 秒の無敵・cure の状態異常の解除・INFO のあと、UseSkill で奥義 skill を強制する。
--   2. 自爆が終わるまでに HP がまた0になっても死亡を取り消す（HP を戻すだけ。原典の lastAttackTimer > 0 の分岐）。
--   3. その奥義を撃ち終えた（takeIdle / takeAttack / takeBack）ら HP を0にする。次の dead で死亡が通る。
--      奥義が始まらないまま timeout 秒が過ぎても HP を0にする（行動不能が続いたときの保険）。
--
-- ⚠ dead を使う（version 1.0）。撃ち終わりと timeout の判定に update を使うため boss version >= 1.1。
-- ⚠ Smash を宣言し、skills にその index（既定20・anim: skill7）を定義すること（UseSkill は Smash の強制枠を使う）。
--    index 7 は XtfFunnel の saberSkill の既定（ファンネルのサーベル）と同じ番号なので使わない。
-- ⚠ Dead より前に宣言する（取り消した dead で後ろのリスナを止める＝撃破 INFO を出させない）。KindEraser は先頭に置く。
-- ⚠ HP0 で死なせない別の仕組み（Phases の at 0 付近の stop・SuperRegen 等）と併用しない。
-- 同期: dead は各端末で起き、取り消し・HP・無敵・解除・INFO は各端末で同じことをする（決定的）。
--   奥義の強制は Smash の二段発火に乗る（ホストが決めて配信）。原典もホストだけが takeSkill(7) する。
--
-- 設定:
--   skill      number      撃たせる奥義の index（既定 20。原典の効果スロット）
--   cutin      number      カットイン種別（既定なし＝原典どおりカットインなし）
--   hp         number      取り消したときの HP（既定 1）
--   invincible number      取り消したときの無敵秒（既定 7.1）
--   cure       table|false 取り消したときに解除する状態異常（既定 { 89, 91, 96 }＝気絶・麻痺・氷結）。false で解除しない
--   message    table|false INFO { key, text, color, time }（既定 key "mess4"・text "フィニス＝マキナ起動"・赤・5秒）。
--                          key はボスの TEXT → ユニット文言（textUnit）の順に引き、無ければ text
--   textUnit   number      message.key を引くユニット文言の unit_id（既定 500721013）
--   timeout    number      取り消してから奥義が始まらないまま、この秒数が過ぎたら倒れる（既定 20）
--
-- @example
--     boss:add(XtfLastAttack{})                                  -- 原典の再現（index 20＝skill7・7.1秒無敵・INFO）
--     boss:add(XtfLastAttack{ skill = 9, message = false })      -- 別の index・INFO なし
------
local _NAME = 'summoner.Choreo.Components.XtfLastAttack'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Actions = require('summoner.Choreo.Actions')
local Smash = require('summoner.Choreo.Components.Smash')
local Message = require('summoner.Choreo.Message')
local Color = require('summoner.Color')

local DEFAULT_CURE = { 89, 91, 96 }      -- 気絶・麻痺・氷結（原典が解除する3つ）
local DEFAULT_MESSAGE = { key = 'mess4', text = 'フィニス＝マキナ起動', color = Color.red, time = 5 }

local STATE_FIRING = 'firing'            -- 死亡を取り消して自爆の奥義を待っている／撃っている
local STATE_DONE = 'done'                -- 撃ち終えた（次の dead で死亡を通す）

local function messageText(self, m, textUnit)
    local key = m.key
    if key ~= nil then
        if self.TEXT ~= nil and self.TEXT[key] ~= nil then
            return self.TEXT[key]
        end
        local texts = summoner ~= nil and summoner.Text ~= nil and summoner.Text:fetchByUnitID(textUnit) or nil
        if texts ~= nil and texts[key] ~= nil then
            return texts[key]
        end
    end
    return m.text
end

local function XtfLastAttack(config)
    config = config or {}
    local skill = config.skill or 20
    assert(type(skill) == 'number', 'Choreo.XtfLastAttack: skill は奥義の index（数値）')
    local cutin = config.cutin
    local hp = config.hp or 1
    local invincible = config.invincible or 7.1
    local cure = config.cure
    if cure == nil then
        cure = DEFAULT_CURE
    end
    assert(cure == false or type(cure) == 'table', 'Choreo.XtfLastAttack: cure は condition type の配列か false')
    local message = config.message
    if message == nil then
        message = DEFAULT_MESSAGE
    end
    assert(message == false or type(message) == 'table', 'Choreo.XtfLastAttack: message は { key, text, color, time } か false')
    local textUnit = config.textUnit or 500721013
    local timeout = config.timeout or 20
    local useSkill = Smash.UseSkill{ index = skill, cutin = cutin }

    local component = { name = 'XtfLastAttack' }

    local function finish(self, event)
        self._xtfLastAttackState = STATE_DONE
        local unit = self.unit
        if unit ~= nil and unit ~= false then
            unit:setHP(0)                    -- 次の dead で死亡を通す
        end
    end

    local function onLoad(self, event)
        self._xtfLastAttackState = nil
        self._xtfLastAttackSeen = false
        self._xtfLastAttackTimer = 0
    end

    local function onDead(self, event)
        local state = self._xtfLastAttackState
        if state == STATE_DONE then
            return                           -- 既定の戻り値(1)のまま＝死亡を通す
        end
        local unit = event.unit or self.unit
        unit:setHP(hp)
        event:prevent()                      -- 死亡を取り消す（後ろの dead リスナも止める）
        if state == STATE_FIRING then
            return                           -- 自爆の最中に HP がまた0になった: 戻すだけ
        end
        self._xtfLastAttackState = STATE_FIRING
        self._xtfLastAttackSeen = false
        self._xtfLastAttackTimer = 0
        unit:setInvincibleTime(invincible)
        if cure ~= false then
            Action.runActions(self, event, { Actions.CureStatus{ types = cure } })
        end
        if message ~= false then
            local text = messageText(self, message, textUnit)
            if text ~= nil then
                Message{ text = text, time = message.time, color = message.color }:show()
            end
        end
        -- Smash が無い（forceSmash が生えていない）ボスでは強制できないので、timeout で倒れる
        if self.forceSmash ~= nil then
            Action.runActions(self, { unit = unit }, { useSkill })
        end
    end

    local function onSmash(self, event)
        if self._xtfLastAttackState == STATE_FIRING and event.index == skill then
            self._xtfLastAttackSeen = true   -- 自爆の奥義が始まった（index 付きの pass2）
        end
    end

    local function onReturn(self, event)
        if self._xtfLastAttackState == STATE_FIRING and self._xtfLastAttackSeen then
            finish(self, event)              -- 撃ち終わり（奥義直後の takeIdle / takeAttack / takeBack）
        end
    end

    local function onUpdate(self, event)
        if self._xtfLastAttackState ~= STATE_FIRING or self._xtfLastAttackSeen then
            return
        end
        self._xtfLastAttackTimer = self._xtfLastAttackTimer + (event.deltaTime or 0)
        if self._xtfLastAttackTimer >= timeout then
            finish(self, event)              -- 奥義が始まらないまま timeout（行動不能が続いた等）
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnDrop, onDead)
        dispatcher:addEventListener(Events.OnSmash, onSmash)
        dispatcher:addEventListener(Events.takeIdle, onReturn)
        dispatcher:addEventListener(Events.OnAttack, onReturn)
        dispatcher:addEventListener(Events.takeBack, onReturn)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = XtfLastAttack
return XtfLastAttack
