
fieldData = {
    new = function (_fieldInstance,_id,_version)
        return {
            id = 0;
            fieldInstance = _fieldInstance;
            version = _version;
        }
    end,
    new2 = function ()
        return 1;
    end
};

fieldRegister = {
    regist = function  (fieldInstance,id,ver)
        local data = fieldData.new(fieldInstance,id,ver);
        allFields[id] = data;
        print("field manager register");
        print(id);
    end    
}



function FieldManager_managerInit()
    allFields = {};
    return 1;
end

-- --共通変数
-- param = {
--   version = 1.2
--   ,isUpdate = 1
-- }

--共通処理
function FieldManager_update(id,deltaTime,playerTeam,enemyTeam,customParameter)
    if allFields[id].version >= 1.0 then
        return allFields[id].fieldInstance:update(deltaTime,playerTeam,enemyTeam,customParameter);
    end
    return 1;
end

function FieldManager_waveRun(id,playerTeam,enemyTeam,customParameter)
    if allFields[id].version >= 1.0 then
        return allFields[id].fieldInstance:waveRun(playerTeam,enemyTeam,customParameter);
    end
    return 1;
end

function FieldManager_waveEnd(id,playerTeam,enemyTeam,customParameter)
    if allFields[id].version >= 1.0 then
        return allFields[id].fieldInstance:waveEnd(playerTeam,enemyTeam,customParameter);
    end
    return 1;
end

function FieldManager_takeDamageValue(id,target,caster,power,customParameter)
    if allFields[id].version >= 1.0 then
        return allFields[id].fieldInstance:takeDamageValue(target,caster,power,customParameter);
    end
    return 1;
end

function FieldManager_takeBreakeDamageValue(id,target,caster,breakpower,customParameter)
    if allFields[id].version >= 1.0 then
        return allFields[id].fieldInstance:takeBreakeDamageValue(target,caster,breakpower,customParameter);
    end
    return 1;
end

