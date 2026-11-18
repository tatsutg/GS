local child = summoner.Bootstrap.createEnemyClass({label="しーりあ", version=1.3, id=200490047});
child:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
child.ATTACK_WEIGHTS = {
    ATTACK1 = 90,
    ATTACK2 = 10
}

--使用する奥義とその確率
child.SKILL_WEIGHTS = {
    SKILL3 = 100
}

child.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL3 = 4,
    SKILL4 = 3
}


child.ARTS_HP = 50/100;

child.LIGHT_WALL_BORDER = 200000;
child.CRITICAL_BORDER = 800000;



--=========================================================================================================================================
--デフォルトのイベント

function child:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 10;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.allUnits = {};
    self.criticalDamage = 0;--クリティカルで受けたダメージを覚えておく
    self.skillDamage = 0;--自分が奥義で受けたダメージを覚えておく
    self.healRate = 0.3;--奥義によって受けたダメージの回復倍率
    self.artsFlag = true;
    self.criticalCheckFlag = false;
    self.showInfo = false;



    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function child:startWave(event)
    -- event.unit:addSP(100);
    return 1;
end

function child:update(event)
    event.unit:setReduceHitStop(2,1);--ヒットストップ無効
    self:artsCheck(event.unit);
    self:criticalCheck(event.unit);
    self:peaceMaker(event.unit);

    if self.showInfo then
        self.showInfo = false;
    end
    return 1;
end

function child:excuteAction(event)
    self.criticalCheckFlag = false;
    return 1;
end


function child:takeDamageValue(event)

    self:artsDamageCheck(event);

    self:criticalDamageCheck(event);

    if self:lightWallCheck(event) then
        return 1;
    end

    return event.value;
end


function child:takeAttack(event)

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
    self:addSP(event.unit);
    self:attackActiveSkillSetter(event.unit,event.index);
    
    return 1
end



function child:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event);
    end
    self.skillCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    if event.index == 3 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if event.index >= 2 then
        event.unit:setBurstState(kBurstState_active);
    end
    return 1
end

function child:run (event)
  
    return 1;
end

--=========================================================================================================================================
--攻撃判断周りの

function child:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    --もしattack2が選択されたらスキルを出す　ユニットを無理やりボスとして使っているためアニメーションが少ないので
    if tonumber(attackIndex) == 2 then
        unit:takeSkill(1);
    else
        unit:takeAttack(1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    end

    
    return 0;
end

--=========================================================================================================================================
--スキル判断周りの

function child:skillBranch(event)
    --奥義だったら真奥義にする
    if event.index == 2 then
        event.index = 3;
    end

    event.unit:takeSkill(event.index);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,event.index);
    return 0;
end

function child:skillActiveSkillSetter(unit,index)
    --一定以上のクリティカルダメージを受けていたら特殊効果を適用
    if index == 1 and self.criticalDamage >= self.CRITICAL_BORDER then
        index = 4;
        unit:setInvincibleTime(5);
        self.criticalDamage = 0;
    end
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end

--=========================================================================================================================================


function child:addSP(unit)
    if megast.Battle:getInstance():isHost() then
        unit:addSP(self.spValue);
    end
    return 1;
end

--=========================================================================================================================================
--HPトリガー

function child:artsCheck(unit)
    if self.artsFlag and summoner.Utility.getUnitHealthRate(unit) <= self.ARTS_HP then
        unit:addSP(100);
        self.artsFlag = false;
    end
end

--=========================================================================================================================================
--対単発高威力用メソッド

function child:lightWallCheck(event)
    if event.value >= self.LIGHT_WALL_BORDER then
        if not self.showInfo then
            self.showInfo = true;
            summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.yellow);
        end
        return true;
    end
    return false;
end


--=========================================================================================================================================
--対クリティカルダメージ用メソッド

function child:criticalDamageCheck(event)
    if event.enemy:getTeamUnitCondition():getDamageAffectInfo().critical then
        self.criticalDamage = self.criticalDamage + event.value;
    end
end

function child:criticalCheck(unit)
    if self.criticalDamage >= self.CRITICAL_BORDER and not self.criticalCheckFlag then
        unit:takeSkill(1);
        self.criticalCheckFlag = true;
    end
end

--=========================================================================================================================================
--ピースメーカー関連の

function child:artsDamageCheck(event)
    if event.unit.m_breaktime > 0 then
        return;
    end
    local parent =  event.enemy:getParentTeamUnit();

    if parent ~= nil then
        if parent:getBurstState() == kBurstState_active then
            local healPoint = event.value * self.healRate;
            if healPoint < 1 then
                healPoint = 1;
            end
            self.skillDamage = self.skillDamage + healPoint;
        end
    else
        if event.enemy:getBurstState() == kBurstState_active then
            local healPoint = event.value * self.healRate;
            if healPoint < 1 then
                healPoint = 1;
            end
            self.skillDamage = self.skillDamage + healPoint;
        end
    end
end

function child:peaceMaker(unit)
    if self.skillDamage > 0 then
        local rate = (100 + unit:getTeamUnitCondition():findConditionValue(115) + unit:getTeamUnitCondition():findConditionValue(110))/100;
        unit:takeHeal(self.skillDamage * rate);
        self.skillDamage = 0;
    end
end



child:publish();

return child;