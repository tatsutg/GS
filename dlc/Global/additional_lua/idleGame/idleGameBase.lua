local class = summoner.IdleGameEventDispatcher.createIdleGameClass({label="idleGameBase", version=1.0, id="idleGameBase"});

local json = summoner.Json;

function class:init()
    return 1
end

-- event {unit,index}
function class:run(event)
    return 1;
end

-- event {unit,index}
function class:takeAttack(event)
    return 1;
end

-- event {unit, instance,deltaTime}
function class:update(event)
    if event.unit:getisPlayer() then
        self:updatePlayer(event)
    else
        self:updateEnemy(event)
    end
    self:updateUnit(event)
    return 1;
end

-- event {unit, instance }
--SpineがAddChildされた直後に呼ばれる
function class:began(event)
    self:start(event)
    return 1
end

-- event {unit, instance }
--ウェーブ終了時に呼ばれる
function class:waveEnd(event)
    self:waveEndUnit(event)
    return 1
end

-- event {unit, instance, unitId }
--アニメーション終了時に呼ばれる
function class:finishedAnimation(event)
    if event.unit:getisPlayer() then
        self:finishedAnimationPlayer(event)
    else
        self:finishedAnimationEnemy(event)
    end
    self:finishedAnimationUnit(event)
    return 1;
end

-- event {unit, instance, unitId }
--ヒットエフェクトが表示された時に呼ばれる（unitIdは攻撃を受けたユニットのもの）
function class:hitAttack(event)
    if event.unit:getisPlayer() then
        self:hitAttackPlayer(event)
    else
        self:hitAttackEnemy(event)
    end
    self:hitAttackUnit(event)
    return 1;
end

---プレイヤー側処理
function class:updatePlayer(event)

end

function class:finishedAnimationPlayer(event)

end

function class:hitAttackPlayer(event)

end
---

---エネミー側処理
function class:updateEnemy(event)

end

function class:finishedAnimationEnemy(event)

end

function class:hitAttackEnemy(event)

end

---継承用処理

function class:start(event)

end

function class:waveEndUnit(event)

end

function class:updateUnit(event)

end

function class:finishedAnimationUnit(event)

end

function class:hitAttackUnit(event)

end
---

class:publish();

return class;
