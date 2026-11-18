
idleGameData = {
    new = function (_idleGameInstance,_id,_version)
        return {
            id = 0;
            idleGameInstance = _idleGameInstance;
            version = _version;
        }
    end,
    new2 = function ()
        return 1;
    end
};

idleGameRegister = {
    regist = function  (idleGameInstance,id,ver)
        local data = idleGameData.new(idleGameInstance,id,ver);
        allUnits[id] = data;
        print("idleGame manager register "..id);
    end    
}



function IdleGameManager_managerInit()
    allUnits = {};
    print("idleGame manager init");
    return 1;
end

-- --共通変数
-- param = {
--   version = 1.2
--   ,isUpdate = 1
-- }

--共通処理
function IdleGameManager_run(unit,string)
    if allUnits[unit:getUniqueID()] then
        return allUnits[unit:getUniqueID()].idleGameInstance:run(unit,string);
    end
    return allUnits[0].idleGameInstance:run(unit,string);
end

function IdleGameManager_takeAttack(unit,index)
    if allUnits[unit:getUniqueID()] then
        return allUnits[unit:getUniqueID()].idleGameInstance:takeAttack(unit,index);
    end
    return allUnits[0].idleGameInstance:takeAttack(unit,index);
end

function IdleGameManager_update(unit,instance,deltaTime)
    IdleGameManagerDeltaTime = deltaTime;
    if allUnits[unit:getUniqueID()] then
        return allUnits[unit:getUniqueID()].idleGameInstance:update(unit,instance, deltaTime);
    end
    return allUnits[0].idleGameInstance:update(unit,instance, deltaTime);
end

function IdleGameManager_began(unit, instance)
    if allUnits[unit:getUniqueID()] then
        return allUnits[unit:getUniqueID()].idleGameInstance:began(unit,instance);
    end
    return allUnits[0].idleGameInstance:began(unit,instance);
end

function IdleGameManager_waveEnd(unit, instance)
    if allUnits[unit:getUniqueID()] then
        return allUnits[unit:getUniqueID()].idleGameInstance:waveEnd(unit,instance);
    end
    return allUnits[0].idleGameInstance:waveEnd(unit,instance);
end

function IdleGameManager_finishedAnimation(unit,instance,unitId)
    if allUnits[unit:getUniqueID()] then
        return allUnits[unit:getUniqueID()].idleGameInstance:finishedAnimation(unit,instance,unitId);
    end
    return allUnits[0].idleGameInstance:finishedAnimation(unit,instance,unitId);
end

function IdleGameManager_hitAttack(unit,instance,unitId)
    if allUnits[unit:getUniqueID()] then
        return allUnits[unit:getUniqueID()].idleGameInstance:hitAttack(unit,instance,unitId);
    end
    return allUnits[0].idleGameInstance:hitAttack(unit,instance,unitId);
end

