--@additionalItem,100071199
function new(id)
    --このスクリプトは　ユニットボス　ロイのluaです
    print("500331293 new ");
    local instance = {
        unitinfo = {
            new = function (_bullet,_targetUnit,_otherparam)
                return {
                    bullet = _bullet,
                    targetUnit = _targetUnit,
                    otherParam = _otherparam,
                    frame = 0,
                    angle = 0,
                    posx = 0,
                    posy = 0,
                    speedkeisuu = 1,
                    state = 0
                }
            end
        },
        allEnemys = {},
        attackChecker = false,
        selfBullet = nil,
        moveFlag = false,
        muki = 1,
        isPlayerUnit = true,
        myself = nil,
        counterTimer = 0,
        counterTargetIndex = nil,
        coolTimes = {},
        coolTimeMemory = {},
        skill3Counter = 0,


        attackMove = function (this,bulletinstance)
            print("move");
            local framecnt = bulletinstance.frame;
            if framecnt == 0 then
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
            end
            local framecnt = bulletinstance.frame;
            local currentbullet = bulletinstance.bullet;
            local sp = 25;
            local speedOrigin = 25;
            local bullettarget = megast.Battle:getInstance():getTeam(not this.isPlayerUnit):getTeamUnit(bulletinstance.targetUnit);
            if bullettarget == nil then
                this.moveFlag = false;
                this.selfBullet = nil;
                this.myself:resumeUnit();
                return 0;
            end
            local bulletx = bulletinstance.bullet:getPositionX() + this.muki * (bulletinstance.bullet:getSkeleton():getBoneWorldPositionX("MAIN"));
            local bullety = bulletinstance.bullet:getPositionY();
            local targetx = bullettarget:getPositionX() - this.muki * (bullettarget:getSkeleton():getBoneWorldPositionX("MAIN"));
            local targety = bullettarget:getPositionY();

            local targetxM = bullettarget:getPositionX() - this.muki * bullettarget:getSkeleton():getBoneWorldPositionX("MAIN");

            bulletinstance.angle = getDeg(bulletx,bullety,targetx,targety);
            local distance = math.sqrt((bulletx - targetx)*(bulletx - targetx) + (bullety - targety)*(bullety - targety));

            local skeleton = this.myself:getSkeleton();
            local scale = skeleton:getScaleX();
            -- if framecnt == 0 then
                if this.isPlayerUnit then
                    if bulletx < targetxM then
                        skeleton:setScaleX(-1);
                    else
                        skeleton:setScaleX(1);
                    end
                else
                    if bulletx > targetxM  then
                        skeleton:setScaleX(-1);
                    else
                        skeleton:setScaleX(1);
                    end
                end
            -- end
            

            if math.abs(bulletx - targetx) > 200 then
                sp = speedOrigin * unitManagerDeltaTime/0.016666667;
                if sp > distance then
                    sp = distance;
                end
                moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp),calcYDir(degToRad(bulletinstance.angle),sp));
            else
                this.moveFlag = false;
                this.selfBullet = nil;
                this.myself:resumeUnit();
            end
            return 1;
        end,

        pause = function (this,unit)
            this.moveFlag = true;

            --ターゲットユニットを狙う。　スキルカウンターの対象がいればそれを狙う
            local index = nil;
            if unit:getTargetUnit() ~= nil then
                index = unit:getTargetUnit():getIndex();
            end
            if this.counterTargetIndex ~= nil then
                index = this.counterTargetIndex;
            end


            this.selfBullet = this.unitinfo.new(unit,index,0);
            unit:pauseUnit();
            return 1;
        end,

        skill1End = function (this,unit)
            this.counterFlag = false;
            return 1;
        end,

        askCounter = function(this,unit)
            local state = unit:getUnitState();
            if state ~= kUnitState_attack and state ~= kUnitState_skill then
                return true;
            end
            return false;
        end,

        addSP = function (this,unit)
            unit:addSP(20);
            return 1;
        end,

        --共通変数
        param = {
          version = 1.2
          ,isUpdate = 1
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "pause" then return this.pause(this,unit) end
            if str == "skill1End" then return this.skill1End(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            if this.moveFlag then
                this.attackMove(this,this.selfBullet);
            end
            this.counterTimer = this.counterTimer - deltatime;
            for i=0,table.maxn(this.allEnemys)do
                if this.allEnemys[i] ~= nil and this.allEnemys[i]:getUnitState() == kUnitState_skill and this.askCounter(this,unit)  and this.counterTimer <= 0 then
                    this.counterTimer = 7;
                 
                    unit:takeAnimation(0,"skill1",false);
                    unit:takeAnimationEffect(0,"1-skill1",false);
                    this.counterTargetIndex = this.allEnemys[i]:getIndex();
                    print("insitao");
                    --unit;setActiveSkill(0);
                    break;
                end
            end
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            this.myself = unit;
            this.isPlayerUnit = unit:getisPlayer();
            unit:setSPGainValue(0);
            --自分から見て敵側のユニットを全部取得(ユニットは最大でも６体までなので６回)
            for i = 0,6 do
                --指定されたインデックスでユニットを取得
                local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
                if uni ~= nil then
                    table.insert(this.allEnemys,uni);
                end
            end
            unit:setItemSkill(0,100071199);
            table.insert(this.coolTimeMemory,os.time() -15);
            table.insert(this.coolTimeMemory,os.time() -15);
            table.insert(this.coolTimes,15);
            table.insert(this.coolTimes,15);


            return 1;
        end,

        excuteAction = function (this , unit)
            skeleton = unit:getSkeleton();
            
            skeleton:setScaleX(1);
            
            local rand = LuaUtilities.rand(0,100);
            if rand <= 25 and unit:getPositionX() > 100 then
                unit:takeBack();
                return 0;
            end

            return 1;
        end,

        takeIdle = function (this , unit)
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
         
            return 1;
        end,

        takeAttack = function (this , unit , index)
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            else
                unit:setActiveSkill(3);
            end
            if not this.attackChecker then

                if this.skill3Counter > 0 then
                    this.skill3Counter = this.skill3Counter -1;
                    unit:takeSkill(3);
                    local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
                    if hpParcent > 50 then
                        unit:setAttackTimer(5);
                    end
                    this.attackChecker = false;
                    return 0;
                end

                local itemUseRand = LuaUtilities.rand(0,100);
                if itemUseRand < 0 then
                    local itemIndexes = {};
                    for i = 1,table.maxn(this.coolTimeMemory)do
                        if this.coolTimeMemory[i] - os.time() <= -this.coolTimes[i] then
                            table.insert(itemIndexes,i);
                        end
                    end

                    if table.maxn(itemIndexes) > 0 then
                        local randForItem = LuaUtilities.rand(0,table.maxn(itemIndexes));
                            if itemIndexes[randForItem] == 1 then
                                unit:takeItemSkill(0);
                                unit:takeCast();
                            else
                                unit:takeSkill(1);
                            end
                            this.coolTimeMemory[itemIndexes[randForItem]] = os.time();
                            this.attackChecker = false;
                        return 0;
                    end
                end
                
                local distance = BattleUtilities.getUnitDistance(unit,unit:getTargetUnit());
                this.attackChecker = true;
                if distance < 50 then
                    unit:takeAttack(3);
                elseif distance > 300 then
                    unit:takeAttack(2);
                else
                    local rand = LuaUtilities.rand(0,100);
                    if rand <= 30 then
                        unit:takeAttack(1);
                    else
                        unit:takeAttack(2);
                    end
                end
                return 0;
            end
            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(4);
            elseif index == 2 then
                unit:setActiveSkill(5);
                
                local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
                if hpParcent < 50 then
                    this.skill3Counter = 3;
                else
                    this.skill3Counter = 2;
                    unit:setAttackTimer(5);
                end 
            elseif index == 3 then
                unit:setActiveSkill(6);
            end
            this.counterFlag = false;
            return 1;
        end,

        takeDamage = function (this , unit)
            skeleton = unit:getSkeleton();
          
            skeleton:setScaleX(1);
             
            this.counterFlag = false;
            if this.moveFlag then
                this.moveFlag = false;
                this.selfBullet = nil;
            end
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

function getDeg(startx,starty,targetx,targety)
    return radToDeg(getRad(startx,starty,targetx,targety))

end

function getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function degToRad(deg)
    return deg * 3.14/180;
end

function radToDeg(rad)
    return rad * 180/3.14;
end

function calcXDir(rad,speed)
    return math.cos(rad)*speed;
end

function calcYDir(rad,speed)
    return math.sin(rad)*speed;
end

function move(node,movex,movey)
    node:setPosition(node:getPositionX()+movex,node:getPositionY()+movey);
    return 1;
end

function moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return true;
end
