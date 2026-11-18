local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ジエン", version=2.6, id=104257112});


function class:setSurfaceBoxList()
    self.skill2 = 2;
    self.skill3 = 3;
    self.SURFACE_BOX_LIST = {
        [1] = {
            ACTIVE_SKILL = 2,
            SKILL_NAME = self.TEXT.AFTER_MD or "ブラック・クラック",
            VOICE = "VOICE_FULLARTS_CUTIN_SP",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.skill2] = {
            ACTIVE_SKILL = 2,
            SKILL_NAME = self.TEXT.SKILL2 or "夢の終わり",
            VOICE = "VOICE_FULLARTS_CUTIN",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.skill3] = {
            ACTIVE_SKILL = 3,
            SKILL_NAME = self.TEXT.SKILL3 or "夢の終わり-戒-",
            VOICE = "VOICE_FULLARTS_CUTIN_B",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [4] = {
            ACTIVE_SKILL = 3,
            SKILL_NAME = self.TEXT.AFTER_MD or "ワールド・エクセプション",
            VOICE = "VOICE_FULLARTS_CUTIN_SP",
            SE = "SE_BATTLE_040_UNIT_CALL"
        }
    }
end

function class:setBuffBoxList()
    --固有アビリティ
    self.ABILITY_BOX_LIST = {
        [1] = {
            ID = 1042571120,
            BUFF_ID = 0,  --固有アビ/夢の終わり用アイコン
            VALUE = 0,
            DURATION = 999999,
            ICON = 347
        },
        [2] = {
            ID = 1042571120,
            BUFF_ID = 0,  --固有アビ/夢の終わり-戒-用アイコン
            VALUE = 0,
            DURATION = 999999,
            ICON = 348
        }
    }
    self.SKILL_BOX_LIST = {
        [1] = {
            ID = 1042571121,
            BUFF_ID = 17,  --与ダメージ
            VALUE = 200,
            DURATION = 999999,
            ICON = 26,
            GROUP_ID = 3939,
            PRIORITY = 200
        },
        [2] = {
            ID = 1042571122,
            BUFF_ID = 10,  --奥義ゲージ自然上昇
            VALUE = 3,
            DURATION = 999999,
            ICON = 36,
            -- GROUP_ID = 3939,
            -- PRIORITY = 200
        },
        [3] = {
            ID = 1042571121,
            BUFF_ID = 17,  --与ダメージ
            VALUE = 400,
            DURATION = 999999,
            ICON = 26,
            GROUP_ID = 3939,
            PRIORITY = 400
        },
        [4] = {
            ID = 1042571122,
            BUFF_ID = 10,  --奥義ゲージ自然上昇
            VALUE = 4,
            DURATION = 999999,
            ICON = 36,
            -- GROUP_ID = 3939,
            -- PRIORITY = 400
        }
    }
end

function class:setSkillBuffBox()
    self.SKILL2_BOX_LIST = {
        [1] = {
            ID = 1042571123,  --炎属性ユニット以外
            BUFF_ID = 13,  --攻撃力
            VALUE = 50,
            DURATION = 25,
            ICON = 3,
            GROUP_ID = 1006,
            PRIORITY = 50
        },
        [2] = {
            ID = 1042571123,  --炎属性ユニット
            BUFF_ID = 13,  --攻撃力
            VALUE = 100,
            DURATION = 25,
            ICON = 3,
            GROUP_ID = 1006,
            PRIORITY = 100
        }
    }
    self.SKILL3_BOX_LIST = {
        [1] = {
            ID = 1042571124,
            BUFF_ID = 80,  --防御力無視
            VALUE = 100,
            DURATION = 30,
            ICON = 89,
            GROUP_ID = 3433,
            PRIORITY = 100
        },
        [2] = {
            ID = 1042571125,
            BUFF_ID = 17,  --与ダメ
            VALUE = 100,
            DURATION = 30,
            ICON = 28,
            GROUP_ID = 1066,
            PRIORITY = 100,
            SCRIPT = {
                SCRIPT_ID = 4
            }
        }
    }
end

---start時のinモーションを変える場合は残す
---------------------------------------------------------------------------------
-- firstIn
---------------------------------------------------------------------------------
function class:firstIn(event)
    event.unit:setNextAnimationName("in2");
    event.unit:setNextAnimationEffectName("in2");
    return 0;
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self.skillBuffFlg = false;--固有アビリティ監視用フラグ
    self.skill2Flg = false;
    self.skill3Flg = false;
    self:setSurfaceBoxList();
    self:setBuffBoxList();
    self:setSkillBuffBox();
    if event.unit:getParameter("425_DREAM_END") == "" then
        event.unit:setParameter("425_DREAM_END","0");
    end
    if event.unit:getParameter("425_DREAM_END2") == "" then
        event.unit:setParameter("425_DREAM_END2","0");
    end
    self.cutInVoiceFLG = true;
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getParameter("425_DREAM_END") == "" then
        event.unit:setParameter("425_DREAM_END","0");
    end
    if event.unit:getParameter("425_DREAM_END2") == "" then
        event.unit:setParameter("425_DREAM_END2","0");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    local waveFlg = megast.Battle:getInstance():getWaveNum() == megast.Battle:getInstance():getWaveMax();
    if waveFlg and self.cutInVoiceFLG then
        event.unit:setCutinVoice1(self.SURFACE_BOX_LIST[1].VOICE);
        event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[4].VOICE);
        self.cutInVoiceFLG = false;
    end
    if self.skill2Flg then
        self.skill2Flg = false;
        if not self.skillBuffFlg and waveFlg then
            self.skillBuffFlg = true;
            event.unit:setParameter("425_DREAM_END","1");
            event.unit:setCutinVoice1(self.SURFACE_BOX_LIST[self.skill2].VOICE);
            event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.skill3].VOICE);
            self:execAddBuff(event.unit,self.ABILITY_BOX_LIST[1]);
        else
            self:setSkill2Buff(event.unit,1);
        end
    elseif self.skill3Flg then
        self.skill3Flg = false;
        if not self.skillBuffFlg and waveFlg then
            self.skillBuffFlg = true;
            event.unit:setParameter("425_DREAM_END2","1");
            event.unit:setCutinVoice1(self.SURFACE_BOX_LIST[self.skill2].VOICE);
            event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.skill3].VOICE);
            self:execAddBuff(event.unit,self.ABILITY_BOX_LIST[2]);
        else
            self:teamAddBuff(event.unit,self.SKILL3_BOX_LIST[1],0);
            self:teamAddBuff(event.unit,self.SKILL3_BOX_LIST[2],0);
        end
    end

    if self.skillBuffFlg then
        self:setBuffMonitor(event.unit);
    end
    return 1;
end

function class:setSkill2Buff(unit,elementNum)
    local targetTeam = self:getMyTaem(unit);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getElementType() == elementNum then
                self:execAddBuff(myTeamUnit,self.SKILL2_BOX_LIST[2]);
            else
                self:execAddBuff(myTeamUnit,self.SKILL2_BOX_LIST[1]);
            end
        end
    end
end

function class:teamAddBuff(unit,buffBox,raceType,once)
    ---【MEGA_D-9599】味方全体への防御無視・クリティカル率UPは、バフ無効化に当たるなら配らない（演出は配った人の頭上）
    ---固有アビ状態（SKILL_BOX_LIST）は update から毎フレーム配り直すので、演出はバトル中1回だけ（once=true）
    if isTeamConditionBlockedByLua ~= nil and isTeamConditionBlockedByLua(unit, buffBox.BUFF_ID, buffBox.ICON, once == true) then
        return
    end
    local targetTeam = self:getMyTaem(unit);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if raceType ~= 0 then
                if myTeamUnit:getRaceType() == raceType then
                    self:execAddBuff(myTeamUnit,buffBox);
                end
            else
                self:execAddBuff(myTeamUnit,buffBox);
            end
        end
    end
end

function class:taemBuffRemover(unit)
    local targetTeam = self:getMyTaem(unit);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:buffRemover(myTeamUnit);
        end
    end
end

function class:getAbilityBuffFlg(unit,buffID)
    local targetTeam = self:getMyTaem(unit);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffID);
            if cond == nil then
                return true;
            end
        end
    end
    return false;
end

function class:getBuffParam(unit)
    if unit:getParameter("425_DREAM_END2") == "1" then
        return 3;
    elseif unit:getParameter("425_DREAM_END") == "1" then
        return 2;
    else
        return 0;
    end
end

function class:setBuffMonitor(unit)
    local myParam = self:getBuffParam(unit);
    local dienParam = self:parameteChack(unit);
    self:setAbilitySkills(unit,myParam,dienParam);
end

--同名ユニットのパラメータを取得
function class:parameteChack(unit)
    local targetTeam = self:getMyTaem(unit);
    --味方に同ユニットが居るか確認
    local dien = false;
    local dienParam = 0;
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if unit ~= myTeamUnit and unit:getBaseID3() == myTeamUnit:getBaseID3() then
                dien = true;
                if self:getBuffParam(myTeamUnit) > dienParam then
                    dienParam = self:getBuffParam(myTeamUnit);
                end
            end
        end
    end

    local myParam = self:getBuffParam(unit);
    if dien and dienParam ~= 0 then
        return dienParam;
    end
    return 0;
end

function class:setAbilitySkills(unit,myParam,dienParam)
    ---同名ユニットの状態で付与するか決定
    --自身以外に自身と同様の固有アビ状態のユニットが居た場合    
    if dienParam == 0 then
        self:setSkills(unit,myParam);
    elseif myParam == dienParam then
        self:setSkills(unit,myParam);
    elseif myParam < dienParam then--自身以外に自身のより上位固有アビ状態のユニットが居た場合        
        self:setSkills(unit,dienParam);
    elseif myParam > dienParam then--自身以外に「夢の終わり」状態のユニットが居た場合
        --何もしない
    end
end

function class:setSkills(unit,setIndex)
    if setIndex == 0 then
        return;
    elseif setIndex == 2 then
        local cond = unit:getTeamUnitCondition():findConditionWithID(self.SKILL_BOX_LIST[1].ID);
        if cond ~= nil then
            self:taemBuffRemover(unit);
        end
        self:teamAddBuff(unit,self.SKILL_BOX_LIST[1],0,true);
        self:teamAddBuff(unit,self.SKILL_BOX_LIST[2],0,true);
        if self:isHost() then
            -- megast.Battle:getInstance():sendEventToLua(self.scriptID,1,2);
        end
        return;
    elseif setIndex == 3 then
        local cond = unit:getTeamUnitCondition():findConditionWithID(self.SKILL_BOX_LIST[1].ID);
        if cond ~= nil then
            self:taemBuffRemover(unit);
        end
        self:teamAddBuff(unit,self.SKILL_BOX_LIST[3],3,true);
        self:teamAddBuff(unit,self.SKILL_BOX_LIST[4],3,true);
        if self:isHost() then
            -- megast.Battle:getInstance():sendEventToLua(self.scriptID,1,3);
        end
        return;
    end
end

function class:getMyTaem(unit)
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if unitTeam == megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end
    return targetTeam;
end

function class:buffRemover(unit)
    for i,value in ipairs({self.SKILL_BOX_LIST[1].ID,self.SKILL_BOX_LIST[2].ID}) do
        local condition = unit:getTeamUnitCondition():findConditionWithID(value)
        if condition ~= nil then
            unit:getTeamUnitCondition():removeCondition(condition);
        end
    end
    megast.Battle:getInstance():updateConditionView();
end

function class:isHost()
    local bool = false;
    if megast.Battle:getInstance():isHost() or megast.Battle:getInstance():isPvpHost() then
        bool = true;
    end
    return bool;
end

function class:receive1(args)
    if args.arg == 2 then
        self:teamAddBuff(self.gameUnit,self.SKILL_BOX_LIST[1],0,true);
        self:teamAddBuff(self.gameUnit,self.SKILL_BOX_LIST[2],0,true);
    elseif args.arg == 3 then
        self:teamAddBuff(self.gameUnit,self.SKILL_BOX_LIST[3],3,true);
        self:teamAddBuff(self.gameUnit,self.SKILL_BOX_LIST[4],3,true);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_BG_skill5" then
        event.unit:addOrbitSystem("BG_skill5",0);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    local waveFlg = megast.Battle:getInstance():getWaveNum() == megast.Battle:getInstance():getWaveMax();
    if event.index == 2 then
        self.skill2Flg = true;
        self.skill3Flg = false;
        --最終Waveかつ固有バフ状態で無い場合
        if not self.skillBuffFlg and waveFlg then
            event.unit:setNextAnimationName("skill_extra");
            event.unit:setNextAnimationEffectName("skill_extra");
            event.unit:getBurstSkill():setSkillname(self.SURFACE_BOX_LIST[self.skill2].SKILL_NAME);
            self:setSkill2Surface(event.unit,self.SURFACE_BOX_LIST[self.skill2]);
        else
            self:setSkill2Surface(event.unit,self.SURFACE_BOX_LIST[1]);
        end
    elseif event.index == 3 then
        self.skill2Flg = false;
        self.skill3Flg = true;
        if not self.skillBuffFlg and waveFlg then
            event.unit:setNextAnimationName("skill_extra");
            event.unit:setNextAnimationEffectName("skill_extra");
            self:setSkill3Surface(event.unit,self.SURFACE_BOX_LIST[self.skill3]);
        else
            self:setSkill3Surface(event.unit,self.SURFACE_BOX_LIST[4]);
        end
    elseif event.index == 5 then
        self.skill2Flg = false;
        self.skill3Flg = false;
        event.unit:setNextAnimationName("skill5");
        event.unit:setNextAnimationEffectName("2-skill5");
    end
    return 1;
end

function class:setSkill2Surface(unit,surfaceBox)
    local skill2 = unit:getBurstSkill();
    skill2:setSkillname(surfaceBox.SKILL_NAME);
    -- unit:setCutinVoice1(surfaceBox.VOICE);
    -- unit:setCutinSE2(surfaceBox.SE);
end

function class:setSkill3Surface(unit,surfaceBox)
    unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
    if unit:getActiveBattleSkill() ~= nil then
        unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
        -- unit:setCutinVoice2(surfaceBox.VOICE);
        --unit:setCutinSE2(surfaceBox.SE);
    end
end

---------------------------------------------------------------------------------
-- changeOut
---------------------------------------------------------------------------------
function class:changeOut(event)
    if self.skillBuffFlg then
        self:deadBuffRemover(event.unit);
        event.unit:setParameter("425_DREAM_END","0");
        event.unit:setParameter("425_DREAM_END2","0");
        local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.ABILITY_BOX_LIST[1].ID);
        if buff ~= nil then
            event.unit:getTeamUnitCondition():removeCondition(buff);
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    local cond = event.unit:getTeamUnitCondition():findConditionWithType(83);--自動蘇生
    if cond == nil then
        if self.skillBuffFlg then
            self:deadBuffRemover(event.unit);
            event.unit:setParameter("425_DREAM_END","0");
            event.unit:setParameter("425_DREAM_END2","0");
            local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.ABILITY_BOX_LIST[1].ID);
            if buff ~= nil then
                event.unit:getTeamUnitCondition():removeCondition(buff);
            end
        end
    end
    return 1;
end

function class:deadBuffRemover(unit)
    --同ユニットのパラメータを確認
    local dienParam = self:parameteChack(unit);
    local myParam = self:getBuffParam(unit);
    if dienParam ~= 0 then
        --自身以外に自身と同様の固有アビ状態のユニットが居た場合
        if myParam == dienParam then
            return;
        elseif myParam < dienParam then--自身以外に自身のより上位固有アビ状態のユニットが居た場合
            return;
        elseif myParam > dienParam then--自身以外に「夢の終わり」状態のユニットが居た場合
            self:taemBuffRemover(unit);
            self:teamAddBuff(unit,self.SKILL_BOX_LIST[1],0,true);
            self:teamAddBuff(unit,self.SKILL_BOX_LIST[2],0,true);
            return;
        end
    end
    self:taemBuffRemover(unit);
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil;
    local count = 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1;
            if count > buffBox.MAX then
                count = buffBox.MAX;
            end
        end
    end

    ---グループID関係1
    local targetCond = nil;
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond;
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond);
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return;
                end
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff);
    end
    return buff;
end


class:publish();

return class;