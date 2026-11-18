function new(id)
    print("101035211 new "); --ロイ進化後
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
        selfBullet = nil,
        moveFlag = false,
        muki = 1,
        isPlayerUnit = true,
        myself = nil,


        attackMove = function (this,bulletinstance)
            if bulletinstance == nil then
                return 1;
            end
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
                        --skeleton:setScaleX(-1);
                    else
                        --skeleton:setScaleX(1);
                    end
                else
                    if bulletx > targetxM  then
                        --skeleton:setScaleX(-1);
                    else
                        --skeleton:setScaleX(1);
                    end
                end
            -- end
            

            if math.abs(bulletx - targetx) > 250 then
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
            if unit:getTargetUnit() ~= nil then
                this.moveFlag = true;
                this.selfBullet = this.unitinfo.new(unit,unit:getTargetUnit():getIndex(),0);
                unit:pauseUnit();
            end
            return 1;
        end,

        voice1 = function (this,unit)
                for i = 0,4 do
                    local target = unit:getTeam():getTeamUnit(i);
                    if target ~= nil and (target:getBaseID3() == 101 or target:getBaseID3() == 700) then
                        target:playSystemVoice("VOICE_FREE_D");
                    end
                end
            return 1;
        end,
        
        voice2 = function (this,unit)
            unit:playSystemVoice("VOICE_FREE_A");
            return 1;
        end,
        
        voice3 = function (this,unit)
                for i = 0,4 do
                    local target = unit:getTeam():getTeamUnit(i);
                    if target ~= nil and (target:getBaseID3() == 101 or target:getBaseID3() == 700) then
                        target:playSystemVoice("VOICE_TOWN");
                    end
                end
            return 1;
        end,

        voice4 = function (this,unit)
            unit:playSystemVoice("VOICE_TOWN");
            return 1;
        end,
        
        voice5 = function (this,unit)
                for i = 0,4 do
                    local target = unit:getTeam():getTeamUnit(i);
                    if target ~= nil and (target:getBaseID3() == 101 or target:getBaseID3() == 700) then
                        target:playSystemVoice("VOICE_PRAISE");
                    end
                end
            return 1;
        end,

        voice6 = function (this,unit)
            unit:playSystemVoice("VOICE_FREE_B");
            return 1;
        end,
        
        voice7 = function (this,unit)
            unit:playSystemVoice("VOICE_FREE_D");
            return 1;
        end,
        
        voice8 = function (this,unit)
            unit:playSystemVoice("VOICE_FREE_E");
            return 1;
        end,
        
        voice9 = function (this,unit)
            unit:playSystemVoice("VOICE_FREE_C");
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
            if str == "voice1" then return this.voice1(this,unit) end
            if str == "voice2" then return this.voice2(this,unit) end
            if str == "voice3" then return this.voice3(this,unit) end
            if str == "voice4" then return this.voice4(this,unit) end
            if str == "voice5" then return this.voice5(this,unit) end
            if str == "voice6" then return this.voice6(this,unit) end
            if str == "voice7" then return this.voice7(this,unit) end
            if str == "voice8" then return this.voice8(this,unit) end
            if str == "voice9" then return this.voice9(this,unit) end

            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            if waveNum == megast.Battle:getInstance():getWaveMax() and  megast.Battle:getInstance():getQuestScriptID() == 0 then                        
               for i = 0,4 do
                    local target = unit:getTeam():getTeamUnit(i);
                    if target ~= nil and (target:getBaseID3() == 101 or target:getBaseID3() == 700) then
                         local rand = LuaUtilities.rand(100);
                        if rand < 5 then
                            unit:callLuaMethod("voice1",5);
                            unit:callLuaMethod("voice2",11);
                            megast.Battle:getInstance():setClearVoiceEnabled(false);
                            megast.Battle:getInstance():setEndBattleDelay(13);
                        elseif rand < 10 then
                            megast.Battle:getInstance():setClearVoiceEnabled(false);
                            megast.Battle:getInstance():setEndBattleDelay(9);                     
                            unit:callLuaMethod("voice3",4.6);
                            unit:callLuaMethod("voice4",7.1);                        
                        elseif rand < 15 then
                            megast.Battle:getInstance():setClearVoiceEnabled(false);
                            megast.Battle:getInstance():setEndBattleDelay(7);                     
                            unit:callLuaMethod("voice5",4.2);
                            unit:callLuaMethod("voice6",5.9);                        
                        elseif rand < 20 then
                            megast.Battle:getInstance():setClearVoiceEnabled(false);
                            megast.Battle:getInstance():setEndBattleDelay(11);                     
                            unit:callLuaMethod("voice7",5);
                        elseif rand < 25 then
                            megast.Battle:getInstance():setClearVoiceEnabled(false);
                            megast.Battle:getInstance():setEndBattleDelay(8);                     
                            unit:callLuaMethod("voice8",5);
                        elseif rand < 30 then
                            megast.Battle:getInstance():setClearVoiceEnabled(false);
                            megast.Battle:getInstance():setEndBattleDelay(8);                     
                            unit:callLuaMethod("voice9",5);
                        end
                        return 1;
                    end
                end
            end         
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
            return 1;
        end,

        excuteAction = function (this , unit)
            skeleton = unit:getSkeleton();
            if this.isPlayerUnit then
                --skeleton:setScaleX(1);
            else  
                --skeleton:setScaleX(-1);  
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
            return 1;
        end,

        takeSkill = function (this,unit,index)
            return 1;
        end,

        takeDamage = function (this , unit)
            skeleton = unit:getSkeleton();
            if this.isPlayerUnit then
                --skeleton:setScaleX(1);
            else  
                --skeleton:setScaleX(-1);  
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
