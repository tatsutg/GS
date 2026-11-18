
dungeonData = {
    new = function (_dungeonInstance,_id,_version)
        return {
            id = 0;
            dungeonInstance = _dungeonInstance;
            version = _version;
        }
    end,
    new2 = function ()
        return 1;
    end
};

dungeonRegister = {
    regist = function  (dungeonInstance,id,ver)
        local data = dungeonData.new(dungeonInstance,id,ver);
        allDungeons[id] = data;
        print("dungeon manager register");
        print(id);
    end    
}



function DungeonManager_managerInit()
    allDungeons = {};
    return 1;
end

-- --共通変数
-- param = {
--   version = 1.2
--   ,isUpdate = 1
-- }

--共通処理
function DungeonManager_update(id, instance, deltaTime)
    if allDungeons[id].version >= 1.0 then
        return allDungeons[id].dungeonInstance:update(instance, deltaTime);
    end
    return 1;
end

function DungeonManager_loaded(id, instance)
    if allDungeons[id].version >= 1.0 then
        return allDungeons[id].dungeonInstance:loaded(instance);
    end
    return 1;
end

function DungeonManager_began(id, instance)
    if allDungeons[id].version >= 1.0 then
        return allDungeons[id].dungeonInstance:began(instance);
    end
    return 1;
end

function DungeonManager_resolved(id, instance, beforeCount, afterCount, beforeReward, afterReward)
    if allDungeons[id].version >= 1.0 then
        return allDungeons[id].dungeonInstance:resolved(instance,beforeCount,afterCount,beforeReward,afterReward);
    end
    return 1;
end

function DungeonManager_finishedAnimation(id,instance,unitId)
    if allDungeons[id].version >= 1.0 then
        return allDungeons[id].dungeonInstance:finishedAnimation(instance,unitId);
    end
    return 1;
end

function DungeonManager_hitAttack(id,instance,unitId)
    if allDungeons[id].version >= 1.0 then
        return allDungeons[id].dungeonInstance:hitAttack(instance,unitId);
    end
    return 1;
end

