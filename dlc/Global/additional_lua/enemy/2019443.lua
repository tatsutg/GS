local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="アンジェラス", version=1.9, id=2019443});

class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

--怒り時にかかるバフ内容
class.HP50_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

class.HP20_BUFF_ARGS = {
    {
        ID = 40076,
        EFID = 9,         --ダメージアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 36
    }
}


class.BUFF_VALUE = 30;

function class:run(event)
    self.dragonFire:run(event);
    return 1;
end


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.forceSkillIndex = 0;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [1] = {
            HP = 70,
            trigger = "HP70",
            isActive = true
        },
        [2] = {
            HP = 50,
            trigger = "HP50",
            isActive = true
        },
        [3] = {
            HP = 20,
            trigger = "HP20",
            isActive = true
        }

    }

    
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "決めたぜ…全員ぶっころす！",
            COLOR = Color.red,
            DURATION = 5
        }
    }



    self.HP50_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP50_MESSAGE2 or "こっから先は地獄への一方通行だ！",
            COLOR = Color.red,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "ダメージアップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.HP20_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "とっておきだ！てめえに耐えられるかあ？",
            COLOR = Color.red,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP20_MESSAGE2 or "奥義ゲージ速度アップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.dragonFire:init(event,self);
    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {
        [70] = self.gameUnit:addNumHpMarker(0.7),
        [50] = self.gameUnit:addNumHpMarker(0.5),
        [20] = self.gameUnit:addNumHpMarker(0.2)
    }
    return 1;
end

function class:startWave(event)
    -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.magenta);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    return 1;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    if tonumber(attackIndex) == 1 then
        unit:takeAttack(tonumber(attackIndex));
    else
        self.skillCheckFlg = true;
        unit:takeSkill(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
        return 0;
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)

    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.forceSkillIndex ~= 0 then
        skillIndex = self.forceSkillIndex;
        self.forceSkillIndex = 0;
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end


function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    -- if event.index == 3 and not self.skillCheckFlg2 then
    --     self.skillCheckFlg2 = true;
    --     event.unit:takeSkillWithCutin(3,1);
    --     return 0;
    -- end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    self.dragonFire:checkSkillAnimation(event);
    return 1
end


function class:attackDamageValue_OrbitSystem(event)
    return self.dragonFire:fireAttack(event.unit);
end

function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do
        
        if v.HP >= hpRate and v.isActive then

            if self:excuteTrigger(unit,v.trigger) then

                v.isActive = false;
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "HP70" then
        self:HP70(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    if trigger == "HP50" then
        self:HP50(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        return true;
    end
    if trigger == "HP20" then
        self:HP20(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:HP70(unit)
    unit:addSP(100);
    self.gameUnit:removeHpMarker(self.hpMarkers[70])
end

function class:HP50(unit)
    self:addBuffs(unit,self.HP50_BUFF_ARGS);
    self:showMessage(self.HP50_MESSAGES);
    self.gameUnit:removeHpMarker(self.hpMarkers[50])
end

function class:HP20(unit)
    self:addBuffs(unit,self.HP20_BUFF_ARGS);
    self:showMessage(self.HP20_MESSAGES);
    unit:addSP(100);
    self.forceSkillIndex = 3;
    self.gameUnit:removeHpMarker(self.hpMarkers[20])
end


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

--===================================================================================================================
-- メッセージ表示系
--[[
showMessage(<table> messageBoxList,<number> index)
   messageBoxList : 
      必須。以下のようなメッセージ表示用のテーブルを用意して投げる
      TEKITOUNA_MESSAGES = [
         [0] = [
            <String> MESSAGE = 本文,
            <Color> COLOR = 色,
            <number> DURATION = 表示期間(秒)]

         ],
         [1] = ...
      ]
   index : 
      任意。messageBoxList[index]の内容を表示する。
      この引数がない場合、messageBoxListの全ての内容を表示する。
]]
function class:showMessage(messageBoxList,index)
   if index == nil then 
      self:showMessageRange(messageBoxList,0,table.maxn(messageBoxList))
   return
   end
   self:execShowMessage(messageBoxList[index])
end

--[[
showMessageRange(<table> messageBoxList,<number> start,<number> last)
   messageBoxList : 
      必須。
   start,last : 
      必須。messageBoxList[start]からmessageBoxList[last]の内容を表示する。
      この引数がない場合、何も表示しない。
]]
function class:showMessageRange(messageBoxList,start,last)
   for i = start,last do
      self:execShowMessage(messageBoxList[i])
   end
end

--[[
showMessageRange(<table> messageBox)
   敵側のメッセージ欄にmessageBoxの内容を表示する
]]
function class:execShowMessage(messageBox)
   summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end

--===================================================================================================================
-- バフ、デバフ追加系
--[[
addBuffs(<event.unit> unit,<table> buffs)
   unit :
      必須。バフを与える対象
   buffs :
      必須。以下のようなバフ用の配列を用意して投げる
      RAGE_BUFFS = {
         {
            <number> ID = 必須。一意のID
            <number> EFID = 必須。バフの効果ID。IDの一覧はDBテーブル定義.スキル効果マスタ参照
            <number> VALUE = 必須。バフ効果量
            <number> DURATION = 必須。持続時間
            <number> ICON = 必須。アイコンID。IDの一覧は企画*多部署連携用シート.バフ・デバフアイコン参照
            <number> EFFECT = 任意。エフェクトID。IDの一覧は企画*多部署連携用シート.スキル効果アニメーション参照
            <number> SCRIPT = 任意。skill_effect内の関数用ID。IDの一覧はDBテーブル定義.スキル効果マスタ参照
            <number> SCRIPTVALUE1 = 任意。skill_effectの第一引数の値
         }
      }
]]
function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

function class:addBuff(unit,args)
    local buff  = nil;
    if args.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
    if args.SCRIPT ~= nil then
        buff:setScriptID(args.SCRIPT);
    end
    if args.SCRIPTVALUE1 ~= nil then
        buff:setValue1(args.SCRIPTVALUE1);
    end

end

--=====================================================================================================================================
function class:receive3(args)
    self:HP70(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:HP50(self.gameUnit);
    return 1;
end

function class:receive5(args)
    self:HP20(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end




--==========================================================================================================================
--龍炎クラス
--==========================================================================================================================
--宣言
class.dragonFire = {};
class.dragonFire.MAX_CNT = 5;
class.dragonFire.FIXED_DAMAGE_IDLE = 50;
class.dragonFire.FIXED_DAMAGE_EXPLODE = 3000;

--==========================================================================================================================
--接続部

function class.dragonFire:init(event,_class)
    self.fireTables = {};
    self.parentGameUnit = event.unit;
    self.parent = _class;
    self.fireTotalCnt = 0;
    self.fireOffset = 0;
end

function class.dragonFire:run(event)
    -- if event.spineEvent == "addFireSkill1" then self:addDragonFire(event.unit,"Skill1") end
    if event.spineEvent == "addFireSkill21" then self:addDragonFire(event.unit,"Skill21") end
    if event.spineEvent == "addFireSkill22" then self:addDragonFire(event.unit,"Skill22") end
    if event.spineEvent == "addFireSkill23" then self:addDragonFire(event.unit,"Skill23") end
    if event.spineEvent == "fireStateEnd" then self:endState(event.unit) end
    if event.spineEvent == "fireRelease" then self:releaseAll() end
end

function class.dragonFire:checkSkillAnimation(event)
    if event.index ~= 3 then
        return;
    end
    local cnt = table.maxn(self.fireTables)
    if cnt > 0 then
        self:changeSkillAnimation(cnt);
    end
end


function class.dragonFire:fireAttack(orbit)
    local fixedDamage = self.FIXED_DAMAGE_EXPLODE;

    local target = nil;
    for i,v in pairs(self.fireTables) do
        if v.orbit == orbit then
            target = v;
        end
    end

    if target == nil then
        return fixedDamage;
    end

    if target.state == 0 then
        fixedDamage = self.FIXED_DAMAGE_IDLE;
    end

    if target.state == 1 then
        fixedDamage = self.FIXED_DAMAGE_IDLE;
    end

    

    return fixedDamage;
 end

--==========================================================================================================================
--実装部

function class.dragonFire:addDragonFire(unit,fireType)
    local chaseBone = "";

    if fireType == "Skill1" then
        chaseBone = "ef_graund_wave_A_red";
    end

    if fireType == "Skill21" then
        self.fireOffset = self.fireOffset + 1;
        if self.fireOffset % 3 ~= 1 then
            return;
        end
        chaseBone = "ef_graund_wave_A_red";
    end

    if fireType == "Skill22" then
        if self.fireOffset % 3 ~= 2 then
            return;
        end
        chaseBone = "ef_graund_wave_A_red2";
    end

    if fireType == "Skill23" then
        if self.fireOffset % 3 ~= 0 then
            return;
        end
        chaseBone = "ef_graund_wave_A_red3";
    end

    local x = self.parentGameUnit:getPositionX();
    local y = self.parentGameUnit:getPositionY();
    local xb = self.parentGameUnit:getSkeleton():getBoneWorldPositionX(chaseBone);
    local yb = self.parentGameUnit:getSkeleton():getBoneWorldPositionY(chaseBone);

    xb = self.parentGameUnit:getisPlayer() and xb or xb * -1;

    local totalX = x + xb;
    local totalY = y + yb;


    

    totalX = math.floor(totalX);
    totalY = math.floor(totalY);

    -- summoner.Utility.messageByEnemy(totalX);
    
    local fire = self:createDragonFire(unit,totalX,totalY,self.fireTotalCnt);
    self.fireTotalCnt = self.fireTotalCnt + 1;
    table.insert(self.fireTables,fire);
    self:checkOld();
end


function class.dragonFire:createDragonFire(unit,positionX,positionY,uniqueID)
    local newDragonFire = {
        orbit = nil,
        state = 0,
        id = uniqueID
    }
    newDragonFire.orbit = unit:addOrbitSystem("fire_in",0);
    newDragonFire.orbit:takeAnimation(0,"fire_in",true);
    newDragonFire.orbit:setPosition(positionX,positionY);
    newDragonFire.orbit:setActiveSkill(1);
    return newDragonFire;
end

function class.dragonFire:endState(orbit)
    local target = nil;
    for i,v in pairs(self.fireTables) do
        if v.orbit == orbit then
            target = v;
        end
    end

    if target.state == 0 then
        target.orbit:takeAnimation(0,"fire_loop",true);
        target.state = 1;
    end
end

function class.dragonFire:checkOld()
    local targetID = -1;
    if table.maxn(self.fireTables) > self.MAX_CNT then
        targetID = self:sarchOldestFire().id;
    end
    if targetID > -1 then
        --ここ同期
        self:release(targetID);
    end
end

function class.dragonFire:sarchOldestFire()
    local target = nil;
    local index = 999;
    for i,v in pairs(self.fireTables) do
        if v.id < index then
            target = v;
        end
    end

    return target;
end

function class.dragonFire:release(id)
    local target = nil;
    local targetIndex = 0;
    for i,v in pairs(self.fireTables) do
        if v.id == id then
            target = v;
            targetIndex = i;
            self:execRelease(target);
        end
    end

    table.remove(self.fireTables,targetIndex)
end

function class.dragonFire:execRelease(fire)
    fire.orbit:takeAnimation(0,"fire_end",false);
    fire.state = 2;
end

function class.dragonFire:releaseAll()
    for i,v in pairs(self.fireTables) do
        
        self:execRelease(v);
        
    end

   self.fireTables = {};
end

function class.dragonFire:changeSkillAnimation(cnt)
    self.parentGameUnit:setNextAnimationName("skill3"..cnt);
    self.parentGameUnit:setNextAnimationEffectName("skill3"..cnt);
end


class:publish();

return class;