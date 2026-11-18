local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ルド", version=2.8, id=108517112});

-- 奥義(skill2)＝お守りに人器「3R（スリーアール）」の力を注ぎ込んで武器化し、守護霊のようなものを背後に出す演出。
-- この「お守りが武器化している間」を 3R状態 と呼ぶ。
-- お守り本体は本体Skeletonの EF_Amulet_in/loop/out をオービットで再生してルドの後ろ(Z-2)に追従させ、
-- EF側の EF_Amulet_in/out はルドとお守りの間(Z-1)で再生する。
-- 読み込むspineファイル名（makeAllの静的解析対象なので文字列リテラルのみ。★6は継承側で AMULET_FILE を上書き）
class.AMULET_FILE = "108517112"
class.EFFECT_FILE = "10851ef"
class.THREE_R_TIME = 25             -- 3R状態の継続秒数（★6は継承側で上書き）
class.THREE_R_BUFF_ID = nil         -- 奥義の防御効果の skill_effect id。設定するとバフ消失で3R状態を終了する
class.THREE_R_OUT_TIME = 0.5        -- EF_Amulet_out の再生秒数（再生後にオービットを削除）
class.THREE_R_EFFECT_TIME = { EF_Amulet_in = 0.8, EF_Amulet_out = 0.6333 }  -- EF側演出の再生秒数
class.THREE_R_AMULET_Z_OFFSET = -2
class.THREE_R_EFFECT_Z_OFFSET = -1

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.threeRAmulet = nil         -- 武器化したお守りのオービット
    self.threeRState = nil          -- "loop" / "out"
    self.threeRTimer = 0
    self.threeRBuffSeen = false
    self.threeREffects = {}         -- EF側の出現/退場演出オービット
    self.baseZOrder = nil           -- オービットのZ基準にする、通常時の本体localZ
    return 1
end

---------------------------------------------------------------------------------
-- run（spineイベント runScript_Amulet_in）
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Amulet_in" then
        self:startThreeR(event.unit)
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    local unit = event.unit
    local dt = event.deltaTime
    local isActive = megast.Battle:getInstance():getBattleState() == kBattleState_active

    -- 主人公化中は本体のlocalZが前面化用の固定値に置き換わり(前面化はglobalZ側で行われる)、そのまま基準にするとオービットが最背面へ回って見えなくなるため、通常時のlocalZを控えておく
    if not unit:getIsProtagonistMode() then
        self.baseZOrder = unit:getZOrder()
    end

    if self.threeRAmulet ~= nil then
        self:followUnit(unit, self.threeRAmulet, self.THREE_R_AMULET_Z_OFFSET)
        if self.threeRState == "loop" then
            if isActive and self:isThreeREnd(unit, dt) then
                self:endThreeR(unit)
            end
        elseif self.threeRState == "out" and isActive then
            self.threeRTimer = self.threeRTimer + dt
            if self.threeRTimer >= self.THREE_R_OUT_TIME then
                self:removeThreeR()
            end
        end
    end

    -- EF側演出は再生中だけ追従させ、再生秒数を過ぎたら削除する
    for i = #self.threeREffects, 1, -1 do
        local ef = self.threeREffects[i]
        self:followUnit(unit, ef.orbit, self.THREE_R_EFFECT_Z_OFFSET)
        if isActive then
            ef.time = ef.time - dt
            if ef.time <= 0 then
                ef.orbit:remove()
                table.remove(self.threeREffects, i)
            end
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:removeThreeR()
    for i = #self.threeREffects, 1, -1 do
        self.threeREffects[i].orbit:remove()
    end
    self.threeREffects = {}
    return 1
end

---------------------------------------------------------------------------------
-- 3R状態
---------------------------------------------------------------------------------
-- 終了条件。THREE_R_BUFF_ID があればバフの有無で判定し、無ければ THREE_R_TIME 経過で判定する
function class:isThreeREnd(unit, dt)
    if self.THREE_R_BUFF_ID ~= nil then
        local buff = unit:getTeamUnitCondition():findConditionWithID(self.THREE_R_BUFF_ID)
        if buff ~= nil then
            self.threeRBuffSeen = true
            return false
        elseif self.threeRBuffSeen then
            return true
        end
    end
    self.threeRTimer = self.threeRTimer + dt
    return self.threeRTimer >= self.THREE_R_TIME
end

-- 3R状態の開始（お守りを武器化してルドの後ろに出す）
function class:startThreeR(unit)
    if self.threeRAmulet ~= nil then
        if self.threeRState == "out" then
            self:removeThreeR()         -- 退場中なら消して出し直す
        else
            self.threeRTimer = 0        -- 3R状態中の再発動は継続時間をリセットするだけ
            self.threeRBuffSeen = false
            return
        end
    end

    -- お守り本体（本体Skeletonのドット）。自動削除させず、削除は removeThreeR で行う
    self.threeRAmulet = unit:addOrbitSystemWithFile(self.AMULET_FILE, "EF_Amulet_in")
    if self.threeRAmulet == nil then
        return
    end
    self.threeRAmulet:setOrbitType(4)
    self.threeRAmulet:setEndAnimationName("none")
    self.threeRAmulet:setChainAnimationData(0, "EF_Amulet_loop", "EF_Amulet_in", true)
    self.threeRState = "loop"
    self.threeRTimer = 0
    self.threeRBuffSeen = false
    self:followUnit(unit, self.threeRAmulet, self.THREE_R_AMULET_Z_OFFSET)

    self:playThreeREffect(unit, "EF_Amulet_in")
end

-- 3R状態の終了（お守りが崩れ去る）
function class:endThreeR(unit)
    if self.threeRAmulet == nil or self.threeRState ~= "loop" then
        return
    end
    self.threeRAmulet:takeAnimation(0, "EF_Amulet_out", false)
    self.threeRState = "out"
    self.threeRTimer = 0

    self:playThreeREffect(unit, "EF_Amulet_out")
end

function class:removeThreeR()
    if self.threeRAmulet ~= nil then
        self.threeRAmulet:remove()
        self.threeRAmulet = nil
    end
    self.threeRState = nil
    self.threeRTimer = 0
end

-- EF側の出現/退場演出をルドとお守りの間に出す
function class:playThreeREffect(unit, name)
    local orbit = unit:addOrbitSystemWithFile(self.EFFECT_FILE, name)
    if orbit == nil then
        return
    end
    orbit:setOrbitType(4)
    orbit:setEndAnimationName("none")
    self:followUnit(unit, orbit, self.THREE_R_EFFECT_Z_OFFSET)
    table.insert(self.threeREffects, { orbit = orbit, time = self.THREE_R_EFFECT_TIME[name] })
end

-- オービットをユニットと同じ座標系・向きに合わせ、Z順をユニット基準のオフセットで指定する。
-- 超奥義のバックステップ等の横移動はノード座標でなく MAIN ボーンの移動で表現されるので、MAIN の初期位置からのX方向のずれも足す。
-- 上下（ジャンプの skeleton Y・MAIN の Y）には追従させず地面に置く（影と同じ扱い。スパインチーム指示）
function class:followUnit(unit, orbit, zOffset)
    local skeleton = unit:getSkeleton()
    local mainDx = skeleton:getBoneWorldPositionX("MAIN") - unit:getDefaultMainPositionX()
    orbit:setPosition(unit:getPositionX(), unit:getPositionY())
    orbit:getSkeleton():setPosition(skeleton:getPositionX() + mainDx, 0)
    orbit:setScaleX(unit:getScaleX())
    orbit:setZOrder((self.baseZOrder or unit:getZOrder()) + zOffset)
end

class:publish();

return class;
