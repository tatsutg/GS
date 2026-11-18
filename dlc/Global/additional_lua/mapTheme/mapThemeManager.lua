
mapThemeData = {
    new = function (_mapThemeInstance,_id,_version)
        return {
            id = 0;
            mapThemeInstance = _mapThemeInstance;
            version = _version;
        }
    end,
    new2 = function ()
        return 1;
    end
};

mapThemeRegister = {
    regist = function  (mapThemeInstance,id,ver)
        local data = mapThemeData.new(mapThemeInstance,id,ver);
        allMapThemes[id] = data;
        print("mapTheme manager register"..id);
        print(id);
    end    
}



function MapThemeManager_managerInit()
    print("mapTheme manager init");
    allMapThemes = {};
    return 1;
end

--共通処理
function MapThemeManager_update(id,deltaTime,playerTeam,enemyTeam,customParameter)
    if allMapThemes[id] ~= nil and allMapThemes[id].version >= 1.0 then
        return allMapThemes[id].mapThemeInstance:update(deltaTime,playerTeam,enemyTeam,customParameter);
    end
    return 1;
end

function MapThemeManager_waveRun(id,playerTeam,enemyTeam,customParameter)
    if allMapThemes[id] ~= nil and allMapThemes[id].version >= 1.0 then
        return allMapThemes[id].mapThemeInstance:waveRun(playerTeam,enemyTeam,customParameter);
    end
    return 1;
end

function MapThemeManager_waveEnd(id,playerTeam,enemyTeam,customParameter)
    if allMapThemes[id] ~= nil and allMapThemes[id].version >= 1.0 then
        return allMapThemes[id].mapThemeInstance:waveEnd(playerTeam,enemyTeam,customParameter);
    end
    return 1;
end

function MapThemeManager_takeDamageValue(id,target,caster,power,customParameter)
    if allMapThemes[id] ~= nil and allMapThemes[id].version >= 1.0 then
        return allMapThemes[id].mapThemeInstance:takeDamageValue(target,caster,power,customParameter);
    end
    return 1;
end

function MapThemeManager_takeBreakeDamageValue(id,target,caster,breakpower,customParameter)
    if allMapThemes[id] ~= nil and allMapThemes[id].version >= 1.0 then
        return allMapThemes[id].mapThemeInstance:takeBreakeDamageValue(target,caster,breakpower,customParameter);
    end
    return 1;
end

