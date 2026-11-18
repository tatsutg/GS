function new(id)
    print("10000 new ");
    local instance = {
        
        bullets = {},
        bulletsIDCounter = 0,
        bulletinfo = {
            new = function (_bullet,_targetUnit,_uniqueID)
                return {
                    bullet = _bullet,
                    targetUnit = _targetUnit,
                    uniqueID = _uniqueID,
                    frame = 0,
                    posx = 0,
                    posy = 0,
                    parent = _bullet:getTeamUnit(),
                    yield = true
                }
            end
        },
        addBuff = function (this,unit)
            unit:getTeamUnitCondition():addCondition(10001,0,0,5,0);

            for i = 1,table.maxn(this.bullets) do
                if this.bullets[i].bullet:getTeamUnit() == unit then
                   return 1;
                end

            end


            s = unit:addOrbitSystem("Buff3")
            s:takeAnimation(0,"Buff3",true);

            local x = unit:getPositionX();
            local y = unit:getPositionY();
            s:setPosition(x,y);
            s:setAutoZOrder(true);
            local tama = this.bulletinfo.new(s,unit,0);
            table.insert(this.bullets,tama);


            return 1;
        end,

        checkBuff = function (this,unit)
            local  atari = 0
            for i = 1,table.maxn(this.bullets) do
                
                if this.bullets[i].bullet == unit then
                    atari = i
                end

            end

            if atari == 0 then
                return 0;
            end

            local buff =  unit:getTeamUnit():getTeamUnitCondition():findConditionWithID(10001);
            if buff == nil then
                print("Buff is Null");
                this.onDestroy(this,unit);
                unit:remove();
            end
            return 1;
        end,


        onDestroy = function (this,unit)
            local  atari = 1
            for i = 1,table.maxn(this.bullets) do
                print("onDestroy")
                if this.bullets[i].bullet == unit then
                    atari = i
                end

            end
            table.remove(this.bullets,atari);
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
            if str == "addBuff" then return this.addBuff(this,unit) end
            if str == "checkBuff" then return this.checkBuff(this,unit) end
            if str == "onDestroy" then return this.onDestroy(this,unit) end
            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            print("on end wave");
            for i = 1,table.maxn(this.bullets) do
                this.bullets[i].bullet:setPosition(0,10000);
            end
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            if table.maxn(this.bullets) > 0 then
                for i = 1,table.maxn(this.bullets) do
                    bulletControll100044411(this.bullets[i]);
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
            return 1;
        end,

        excuteAction = function (this , unit)
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
            return 1;
        end,

        dead = function (this , unit)
            local atari = 1
             for i = 1,table.maxn(this.bullets) do
                print("Destroy on dead")
                if this.bullets[i].bullet:getTeamUnit() == unit then
                    atari = i
                    this.bullets[i].bullet:takeAnimation(0,"animation",false);
                    this.bullets[i].bullet:remove();
                end

            end
            print(atari);
            table.remove(this.bullets,atari);
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

function bulletControll100044411(bulletinstance)
    bulletinstance.frame = bulletinstance.frame + 1;
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local xdir = 0;
    local ydir = 0;
    local bullettarget = bulletinstance.targetUnit;
    if bullettarget ~= nil and bulletinstance.yield then
        local thisx = currentbullet:getPositionX();
        local thisy = currentbullet:getPositionY();
        local targetx = bullettarget:getPositionX() + bullettarget:getSkeleton():getBoneWorldPositionX("MAIN");
        local targety = bullettarget:getPositionY() + bullettarget:getSkeleton():getBoneWorldPositionY("MAIN");
        xdir = targetx - thisx;
        ydir = targety - thisy;
    end
    
    moveByFloat(bulletinstance,xdir,ydir);   
    return 1;
end


function moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return 1;
end

