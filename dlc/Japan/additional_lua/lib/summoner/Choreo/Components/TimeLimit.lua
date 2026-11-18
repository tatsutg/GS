------
-- summoner.Choreo.Components.TimeLimit
--
-- 制限時間カウントダウン → 時間切れで全滅（超神具クエスト共通ギミック）。
-- エンジンの `showCountDownTime` がカウントダウンUIを表示・計時し、`getCountDownTime()` が残秒を返す。
-- 残り0で onExpire（既定: 全プレイヤー全滅）。`ResetTimeLimit` で再セット（召喚/ブレイク等のリセット）。
-- 出典: BattleControl `showCountDownTime/getCountDownTime/setCountDownTime`、全滅は全プレイヤー setHP(0)。
--
-- ⚠ update を使うため boss version >= 1.1。全滅はホスト権限（HP は engine 同期）。
--
-- @example
--     boss:add(TimeLimit{ seconds = 300, redtime = 30, png = "timer.png", y = 200 })
--     -- 召喚やブレイクでリセット:
--     boss:add(Smash{ ..., onUse = { [4] = { ResetTimeLimit{} } } })
--
-- 設定:
--   seconds  number  制限時間（秒）
--   redtime  number  赤表示になる残り秒（既定 seconds の 1/10）
--   png      string  タイマー画像パス（showCountDownTime に必要）
--   x/y      number  表示位置（既定 0/0）
--   scale    number  表示倍率（既定 1）
--   onExpire Action|list  時間切れ時（省略時は全プレイヤー全滅）
------
local _NAME = 'summoner.Choreo.Components.TimeLimit'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function bc()
    return BattleControl:get()
end

-- 既定の時間切れ: 全プレイヤー全滅（ホストのみ）
local function wipePlayers(self)
    if not self.isHostPlayer then return end
    local team = megast.Battle:getInstance():getTeam(true)
    for i = 0, 7 do
        local u = team:getTeamUnit(i)
        if u ~= nil then u:setHP(0) end
    end
end

-- カウントダウンを表示し、relative 計時で出せたら true を返す。
-- 第7引数 relative=true は生成時点の getTime() を基準に計時し、多 wave でも開始表示がちょうど sec になる
-- （getTime() は wave でリセットされず、従来式 int の _CountDownTime - getTime() だと端数が出る）。
-- relative を持たない旧クライアントはグルーの引数チェックでエラーになるので、従来式＋ceil にフォールバックする。
-- ceil は setCountDownTime の (int) キャストで残りが seconds - frac(getTime()) に縮むのを防ぐため。
local function showTimer(view, sec)
    local ok = pcall(function()
        bc():showCountDownTime(view.png, sec, view.redtime, view.x, view.y, view.scale, true)
    end)
    if ok then return true end
    bc():showCountDownTime(view.png, sec, view.redtime, view.x, view.y, view.scale)
    bc():setCountDownTime(math.ceil(bc():getTime()) + sec)
    return false
end

local makeTimeLimit

local TimeLimit = setmetatable({}, {
    __call = function(_, config) return makeTimeLimit(config) end
})

function makeTimeLimit(config)
    config = config or {}
    local seconds = config.seconds or 300
    local redtime = config.redtime or math.floor(seconds / 10)
    local png = config.png
    local x = config.x or 0
    local y = config.y or 0
    local scale = config.scale or 1
    local onExpire = config.onExpire

    local component = { name = 'TimeLimit' }

    local function onLoad(self, event)
        self._timeLimitSeconds = seconds
        self._timeLimitFired = false
        self._timeLimitView = { png = png, redtime = redtime, x = x, y = y, scale = scale }
        self._timeLimitStart = bc():getTime()
        self._timeLimitRelative = showTimer(self._timeLimitView, seconds)
    end

    local function onUpdate(self, event)
        if self._timeLimitFired then return end
        local expired
        if self._timeLimitRelative then
            -- relative の残り = seconds - (getTime() - 基準)。基準(_CountDownStartTime)はグルー未公開なのでこちらの控えで判定
            expired = bc():getTime() - (self._timeLimitStart or 0) >= (self._timeLimitSeconds or seconds)
        else
            -- getCountDownTime() は初期値(固定)。残り = 初期値 - 経過(getTime)。
            expired = bc():getCountDownTime() - bc():getTime() <= 0
        end
        if expired then
            self._timeLimitFired = true
            if onExpire ~= nil then
                Action.runActions(self, event, onExpire)
            else
                wipePlayers(self)
            end
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

-- 制限時間を再セット（召喚/ブレイク等のリセット条件から）
-- relative の表示ラベルは生成時の基準・秒数を保持していて setCountDownTime では戻らないため、出し直して基準を取り直す。
-- 従来式は残り = _CountDownTime - getTime なので、現在経過 + sec を入れる（ceil は showTimer と同じ理由）。
TimeLimit.Reset = Action.define('ResetTimeLimit', function(a, d, e)
    local sec = a.seconds or d._timeLimitSeconds or 300
    d._timeLimitSeconds = sec
    d._timeLimitFired = false
    if d._timeLimitRelative and d._timeLimitView ~= nil then
        d._timeLimitStart = bc():getTime()
        bc():removeCountDownTime(d._timeLimitView.png)
        d._timeLimitRelative = showTimer(d._timeLimitView, sec)
    else
        bc():setCountDownTime(math.ceil(bc():getTime()) + sec)
    end
end)

_G.package.loaded[_NAME] = TimeLimit
return TimeLimit
