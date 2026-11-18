
package.path = "dlc/additional/lib/?.lua;additional/lib/?.lua;dlc/additional/?.lua;additional/?.lua"
package.loaded = {};

_G.summoner = require("summoner")


unitData = {
    new = function (_unitinstance,_id,_version)
        return {
            id = 0;
            unitInstance = _unitinstance;
            version = _version;
        }
    end,
    new2 = function ()
        return 1;
    end
};

register = {
    regist = function  (unitInstance,id,ver)
        local data = unitData.new(unitInstance,id,ver);
        allUnits[id] = data;
        print("unit manager register");
        print(id);
    end    
}

unitManagerUtils = {}


function UnitManager_run(id,unit,string)
    return allUnits[id].unitInstance:run(unit,string);
end

function UnitManager_init()
    allUnits = {};
    return 1;
end

-- --共通変数
-- param = {
--   version = 1.2
--   ,isUpdate = 1
-- }

--共通処理

--version 2.7
function UnitManager_takeCastItem(id,unit)
    if allUnits[id].version >= 2.7 then
        return allUnits[id].unitInstance:takeCastItem(unit);
    end
    return 1;
end

--version 2.6
function UnitManager_avoidDead(id,unit)
    if allUnits[id].version >= 2.6 then
        return allUnits[id].unitInstance:avoidDead(unit);
    end
    return 1;
end

function UnitManager_changeIn(id,unit)
    if allUnits[id].version >= 2.6 then
        return allUnits[id].unitInstance:changeIn(unit);
    end
    return 1;
end

function UnitManager_runAddOrbitSystem(id,unit,orbit,animation)
    if allUnits[id].version >= 2.6 then
        return allUnits[id].unitInstance:runAddOrbitSystem(unit,orbit,animation);
    end
    return 1;
end

--version 2.5
function UnitManager_extraTimerOneRound(id,unit,index,count)
    if allUnits[id].version >= 2.5 then
        return allUnits[id].unitInstance:extraTimerOneRound(unit,index,count);
    end
    return count;
end

--version 2.4
function UnitManager_takeMultiDamageValue(id,unit,value)
    if allUnits[id].version >= 2.4 then
        return allUnits[id].unitInstance:takeMultiDamageValue(unit,value);
    end
    return value;
end

--version 2.3
function UnitManager_takeOut(id,unit)
    if allUnits[id].version >= 2.3 then
        return allUnits[id].unitInstance:takeOut(unit);
    end
    return 1;
end

--version 2.2
function UnitManager_takeTransIn(id,unit)
    if allUnits[id].version >= 2.2 then
        return allUnits[id].unitInstance:takeTransIn(unit);
    end
    return 1;
end

function UnitManager_takeTransStart(id,unit)
    if allUnits[id].version >= 2.2 then
        return allUnits[id].unitInstance:takeTransStart(unit);
    end
    return 1;
end

function UnitManager_takeTransOut(id,unit)
    if allUnits[id].version >= 2.2 then
        return allUnits[id].unitInstance:takeTransOut(unit);
    end
    return 1;
end

--version 2.1
function UnitManager_enableChangeBuff(id,unit,index)
    if allUnits[id].version >= 2.1 then
    	return allUnits[id].unitInstance:enableChangeBuff(unit,index);
	end
    return 1;
end

--version 2.0
function UnitManager_changeOut(id,unit)
    if allUnits[id].version >= 2.0 then
    	return allUnits[id].unitInstance:changeOut(unit);
	end
    return 1;
end

--version 1.9
function UnitManager_attackDamageValue_OrbitSystem(id,unit , enemy , value)
    if allUnits[id].version >= 1.9 then
        return allUnits[id].unitInstance:attackDamageValue_OrbitSystem(unit,enemy,value);
    end
    return value;
end


--version 1.8
function UnitManager_firstIn(id,unit)
    if allUnits[id].version >= 1.8 then
        return allUnits[id].unitInstance:firstIn(unit);
    end
    return 1;
end

--version 1.7
function UnitManager_takeHeal(id,unit , heal_origin , heal_value)
    if allUnits[id].version >= 1.7 then
        return allUnits[id].unitInstance:takeHeal(unit,heal_origin,heal_value);
    end
    return heal_origin;
end

--version 1.6
function UnitManager_castItem(id , unit , battleSkill)
    if allUnits[id].version >= 1.6 then
        return allUnits[id].unitInstance:castItem(unit,battleSkill);
    end
    return 1;
end

--version 1.5
function UnitManager_attackElementRate(id , unit , enemy , value)
    if allUnits[id].version >= 1.5 then
        return allUnits[id].unitInstance:attackElementRate(unit,enemy,value);
    end
    return value;
end

function UnitManager_takeElementRate(id , unit , enemy , value)
    if allUnits[id].version >= 1.5 then
        return allUnits[id].unitInstance:takeElementRate(unit,enemy,value);
    end
    return value;
end

--version 1.4
function UnitManager_takeIn(id,unit)
    if allUnits[id].version >= 1.4 then
        return allUnits[id].unitInstance:takeIn(unit);
    end
    return 1;
end

--version 1.3
function UnitManager_takeBreakeDamageValue(id,unit , enemy , value)
    if allUnits[id].version >= 1.3 then
        return allUnits[id].unitInstance:takeBreakeDamageValue(unit,enemy,value);
    end
    return value;
end

function UnitManager_takeBreak(id,unit)
    if allUnits[id].version >= 1.3 then
        return allUnits[id].unitInstance:takeBreake(unit);
    end
    return 1;
end


--versiton1.2
function UnitManager_endWave(id,unit,waveNum)
    if allUnits[id].version >= 1.2 then
        return allUnits[id].unitInstance:endWave(unit,waveNum);
    end
    return 1;
end

function UnitManager_startWave(id,unit,waveNum)
    if allUnits[id].version >= 1.2 then
        return allUnits[id].unitInstance:startWave(unit,waveNum);
    end
    return 1;
end

--version1.1
function UnitManager_update(id,unit,deltatime)
    unitManagerDeltaTime = deltatime;
    if allUnits[id].version >= 1.1 then
        return allUnits[id].unitInstance:update(unit,deltatime);
    end
    return 1;
end

function UnitManager_attackDamageValue(id,unit , enemy , value)
    if allUnits[id].version >= 1.1 then
        return allUnits[id].unitInstance:attackDamageValue(unit,enemy,value);
    end
    return value;
end

function UnitManager_takeDamageValue(id,unit , enemy , value, isMiss)
    if allUnits[id].version >= 1.1 then
        return allUnits[id].unitInstance:takeDamageValue(unit,enemy,value, isMiss);
    end
    return value;
end

--マルチでキャストされてきたものを受け取るメソッド
--receive + 番号　という形式で
--引数にはintが渡る
function UnitManager_receive1(id,intparam)
    return allUnits[id].unitInstance:receive1(intparam);
end

function UnitManager_receive2(id,intparam)
    return allUnits[id].unitInstance:receive2(intparam);
end

function UnitManager_receive3(id,intparam)
    return allUnits[id].unitInstance:receive3(intparam);
end

function UnitManager_receive4(id,intparam)
    return allUnits[id].unitInstance:receive4(intparam);
end

function UnitManager_receive5(id,intparam)
    return allUnits[id].unitInstance:receive5(intparam);
end

function UnitManager_receive6(id,intparam)
    return allUnits[id].unitInstance:receive6(intparam);
end

function UnitManager_receive7(id,intparam)
    return allUnits[id].unitInstance:receive7(intparam);
end

function UnitManager_receive8(id,intparam)
    return allUnits[id].unitInstance:receive8(intparam);
end

function UnitManager_receive9(id,intparam)
    return allUnits[id].unitInstance:receive9(intparam);
end

function UnitManager_receive10(id,intparam)
    return allUnits[id].unitInstance:receive10(intparam);
end

--version1.0
function UnitManager_start(id,unit)
    return allUnits[id].unitInstance:start(unit);
end

function UnitManager_excuteAction(id,unit)
    return allUnits[id].unitInstance:excuteAction(unit);
end

function UnitManager_takeIdle(id,unit)
    return allUnits[id].unitInstance:takeIdle(unit);
end

function UnitManager_takeFront(id,unit)
    return allUnits[id].unitInstance:takeFront(unit);
end

function UnitManager_takeBack(id,unit)
    return allUnits[id].unitInstance:takeBack(unit);
end

function UnitManager_takeAttack(id,unit,index)
    return allUnits[id].unitInstance:takeAttack(unit,index);
end

function UnitManager_takeSkill(id,unit , index)
    return allUnits[id].unitInstance:takeSkill(unit,index);
end

function UnitManager_takeDamage(id,unit)
    return allUnits[id].unitInstance:takeDamage(unit);
end

function UnitManager_dead(id,unit)
    return allUnits[id].unitInstance:dead(unit);
end

