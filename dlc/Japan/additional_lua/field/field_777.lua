local class = summoner.FieldEventDispatcher.createFieldClass({label="ChronoStasis", version=1.0, id=777});

local json = summoner.Json;

function class:init()
    stop_cast_timer = 5.0;
    return 1
end

-- event { deltaTime,playerTeam,enemyTeam,customParameter }
function class:update(event)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end


    for i = 0, 4 do
        local unit = event.playerTeam:getTeamUnit(i);
        if unit ~= nil then
            unit:setBurstPoint(unit:getBurstPoint() + (event.deltaTime * 5));--全員の 時が 加速し 奥義ゲージ 40 ずつ UP UP
        end
    end

    stop_cast_timer = stop_cast_timer - event.deltaTime;
    if stop_cast_timer < 0 then

        --５秒毎にActiveアニメーション
        megast.Battle:getInstance():playFieldEffectActive()

        for i = 0, 6 do
            local unit = event.enemyTeam:getTeamUnit(i); --そして 敵チーム は 時 が 静止する
            if unit ~= nil then
                unit:takeHitStop(2);
            end
        end


        stop_cast_timer = 5.0;
    end

   return 1
end

-- event { playerTeam,enemyTeam,customParameter }
--Wave開始時に呼ばれる
function class:waveRun(event)
    local masterJson = json.parse(event.customParameter)
    local battleInstance = megast.Battle:getInstance()

    print(masterJson.skillEffectMasters[1].Id)
    print(masterJson.skillEffectMasters[2].Id)

    local skillEffectMaster_1 = battleInstance:getSkillEffectMaster(masterJson.skillEffectMasters[1].Id)
    local skillEffectMaster_2 = battleInstance:getSkillEffectMaster(masterJson.skillEffectMasters[2].Id)

    print(skillEffectMaster_1:getName())
    print(skillEffectMaster_2:getName())

    return 1
end

-- event { playerTeam,enemyTeam,customParameter }
--Wave終了時に呼ばれる
function class:waveEnd(event)
    print("waveEnd");
   return 1
end

-- event { target,caster,power,customParameter }
--Unit側の takeDamageValue のあとに呼ばれる
function class:takeDamageValue(event)
    print("takeDamageValue");
    return 1;
end

-- event { target,caster,breakpower,customParameter }
--Unit側の takeBreakeDamageValue のあとに呼ばれる
function class:takeBreakeDamageValue(event)
    print("takeBreakeDamageValue");
    return 1;
end


class:publish();

return class;