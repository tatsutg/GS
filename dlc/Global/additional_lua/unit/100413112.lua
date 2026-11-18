function new(id)
    print("100413112 new ");
    local instance = {
        isPlayer = true,
        shot = function (this,unit)
            local tama = unit:addOrbitSystem("Fire",1);
            tama:setHitCountMax(1);
            tama:setEndAnimationName("Explode")
            return 1;
        end,

        aim = function (this,unit)
            unit:setPosition(unit:getPositionX(),unit:getPositionY()+150);
            local tgt = unit:getTargetUnit();
            if tgt == nil then
                return 0;
            end
            local deg = getDeg(unit:getPositionX(),unit:getPositionY(),tgt:getPositionX(),tgt:getPositionY()+50);
            if this.isPlayer == false then
                deg = 270 - deg - 90;
            end
            if deg < 0 then
                deg = 360 + deg;
            end

            print(deg);

            if deg <= 180 then
                return 1
            end

            if deg <= 190 then
                unit:takeAnimation(0,"Fire1",false);
            elseif deg <= 200 then
                unit:takeAnimation(0,"Fire2",false);
            elseif deg <= 210 then
                unit:takeAnimation(0,"Fire3",false);
            elseif deg <= 220 then
                unit:takeAnimation(0,"Fire4",false);
            elseif deg <= 230 then
                unit:takeAnimation(0,"Fire5",false);
            elseif deg <= 240 then
                unit:takeAnimation(0,"Fire6",false);
            else
                unit:takeAnimation(0,"Fire7",false);
            end
            return 1;
        end,

        explode = function (this,unit)
            local x = unit:getSkeleton():getBoneWorldPositionX("ExplodeCore");
            local y = unit:getSkeleton():getBoneWorldPositionY("ExplodeCore");
            if this.isPlayer then
                unit:setPosition(unit:getPositionX() + x,unit:getPositionY() + y);
            else
                unit:setPosition(unit:getPositionX() + x * -1,unit:getPositionY() + y);
            end
            return 1;
        end,

        --共通変数
        param = {
          version = 1.2
          ,isUpdate = 0
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
            if str == "aim" then return this.aim(this,unit) end
            if str == "explode" then return this.explode(this,unit) end
            if str == "shot" then return this.shot(this,unit) end
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
            this.isPlayer = unit:getisPlayer();
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
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return 1;
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


