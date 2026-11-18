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
        bc():showCountDownTime(png, seconds, redtime, x, y, scale)
        -- showCountDownTime は _CountDownTime=seconds(固定)にするが、残り=_CountDownTime-getTime()。
        -- 多 wave(getTime>0 で登場)だと残りが経過分短くなるため getTime() 起点に補正（visual も同式なので一致）。
        bc():setCountDownTime(bc():getTime() + seconds)
    end

    local function onUpdate(self, event)
        if self._timeLimitFired then return end
        -- getCountDownTime() は初期値(固定)。残り = 初期値 - 経過(getTime)。
        if bc():getCountDownTime() - bc():getTime() <= 0 then
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
-- 残り = _CountDownTime - getTime なので、残りを sec にするには現在経過 + sec を入れる。
TimeLimit.Reset = Action.define('ResetTimeLimit', function(a, d, e)
    local sec = a.seconds or d._timeLimitSeconds or 300
    bc():setCountDownTime(bc():getTime() + sec)
    d._timeLimitFired = false
end)

_G.package.loaded[_NAME] = TimeLimit
return TimeLimit
