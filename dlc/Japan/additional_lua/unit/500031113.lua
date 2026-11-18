--@additionalEnemy,100161010
function new(id)
    print("500051313 new ");
    local instance = {
        summonedNumber = 0,             --ユニットを召喚する場所のインデックスを覚えておく　このあたりのロジックは魔獣を参照
        isRage = false,                 --怒り状態のフラグ
        isWeponLoss = false,            --武器破壊のフラグ
        isTryGlab = false,              --つかみ攻撃中かどうかのフラグ　このフラグが立っている時に攻撃を与えた場合、その対象ユニットを掴む
        isGlab = false,                 --つかみに成功して投げモーションに入っている時に立つフラグ　これが立っていると相手の座標制御を行う
        isThrowing = false,             --つかみが終了し相手を投げつけたというフラグ
        glabUnit = nil,                 --つかみの対象ユニット
        attackChecker = false,          --takeattackがループしないためのフラグ
        skillChecker = false,           --takeSkillがループしないためのフラグ
        glabBoneName = "",              --つかみの時に参照するボーンの名前
        targetHitFlag = false,          --複数ユニットがつかみの判定にかかった時に、targetUnitが判定にかかったかどうかを知るためのフラグ。
        isInit = true,                  --バトル開始後に足をくっつける。その処理が終わったかどうかのフラグ
        myself = nil,                   --巨人のインスタンス。
        bullets = {},                   --生成した投擲物が入るテーブル
        thisid = id,                    --マルチでイベントを送信するために初期化時に渡される自分のidを覚えておく。
        actionCounter = 0,              --ゴブリン召喚ターンを数えるためのカウンター。魔獣と一緒
        nextSummonCounter = 10,         --魔獣と同じロジックを使っているのでそちらを参照してください
        breakePoint = 0,                --武器を取り出してから蓄積したブレークダメージの量　これが一定値を超えると壊れる
        BeforetargetUnitIndex = 0,      --さっきまでターゲットしていたユニットのインデックス。
        bulletinfo = {
            new = function (_bullet,_targetUnit,_otherparam)
                return {
                    bullet = _bullet,
                    targetUnit = _targetUnit,
                    jimen = 0,
                    endAnimationName = "",
                    frame = 0,
                    angle = 0,
                    posx = 0,
                    posy = 0,
                    speedkeisuu = 1,
                    yield = true
                }
            end
        },

        consts = {
            poizonID = -12,
            palarizeID = 89,
            palarizeTime = 4.5,
            goblDropParcent = 10,
            attack1Parcent = 35, --attack１と２と５からランダム　怒り時は４と５からランダム
            attack2Parcent = 35,
            attack4Parcent = 80
        },

        --背中のゴブリンがものを投げる時に呼ばれる。　イベントから呼ばれる。
        goblinAttack = function (this,unit)
            if unit:getHP() <= 0 then--巨人本体が死んでたら何も投げない
                return 0;
            end
            
            --巨人本体が攻撃中でない時に発動するイベントのため、ターゲットユニットが不在。（ターゲットユニットは攻撃中しか存在しない）
            --なのでさっきまでターゲットしていたユニットを新たにターゲットとして指定し直す。
            --ターゲットを直接保持しないのは、そのターゲットが削除されていたらBadAccesとなるため。インデックスだけ持っておき、都度ターゲットを取得する。（死んでたらnullが返る）
            this.myself:setTargetUnit(megast.Battle:getInstance():getTeam(true):getTeamUnit(this.BeforetargetUnitIndex));


            if unit:getTargetUnit() ~= nil then

                --何を投げるかランダムで決定
                local rand = LuaUtilities.rand(0,100);
                local animationStr = "";        --投擲物のアニメーション　飛んでる間はこれ
                local endAnimationName = "";    --投擲物が相手を直撃した時のアニメーション　当たった時に爆発したりとかする場合はそのアニメーション名を指定。　"goblin_attack"は空白のアニメーション。
                local vanishAnimationName = ""; --投擲物が誰にも当たらず地面に落ちて消滅する時に出すアニメーション。orbitSystemの機能としてのendAnimationではなく、ターゲットよりもy座標が低くなった場合にluaから明示的に再生される。
                local speed = 10;
                local activeSkillNum = 0;       --投擲物の威力や状態以上などを設定したマスターデータの番号。


                if rand < 25 then
                    activeSkillNum = 8;
                    animationStr = "goblin_ax";
                    endAnimationName = "goblin_attack";
                    vanishAnimationName = "goblin_axEnd";
                elseif rand < 50 then
                    activeSkillNum = 7;
                    animationStr = "goblin_bone"
                    endAnimationName = "goblin_attack";
                    vanishAnimationName = "goblin_bone_bound";
                elseif rand < 75 then
                    activeSkillNum = 10;
                    animationStr = "goblin_iron-ball"
                    endAnimationName = "goblin_attack";
                    vanishAnimationName = "goblin_iron-ballEnd";
                else
                    activeSkillNum = 9;
                    animationStr = "goblin_poison"
                    endAnimationName = "goblin_poison_dusty";
                    vanishAnimationName = "goblin_poison_dusty";
                end


                --上で各種アニメーション名が決まったのであとはorbitSystemをそれに従って作るだけ
                local bullet = unit:addOrbitSystem(animationStr,1);
                bullet:takeAnimation(0,animationStr,true);
                bullet:setHitCountMax(1);
                bullet:setEndAnimationName(endAnimationName);
                bullet:getTeamUnitCondition():addCondition(-12,35,0,25,0);
                bullet:setActiveSkill(activeSkillNum);
                
                local x = unit:getPositionX()
                local y = unit:getPositionY()
                local xb = unit:getSkeleton():getBoneWorldPositionX("gobul_top");
                local yb = unit:getSkeleton():getBoneWorldPositionY("gobul_top");
                bullet:setPosition(x+xb,y+yb);

                local targetx = unit:getTargetUnit():getPositionX();
                local targety = unit:getTargetUnit():getPositionY();


                LuaUtilities.runJumpTo(bullet,3,targetx , targety,400,1);
                local t = this.bulletinfo.new(bullet,unit:getTargetUnit():getIndex(),0);
                t.jimen = unit:getTargetUnit():getPositionY() + 10;
                t.endAnimationName = vanishAnimationName;
                t.speedkeisuu = speed;
                table.insert(this.bullets,t);
            end
            return 1;
        end,

        onDestroy = function (this,unit)
            local  atari = 0;
            print("onDestroy");
             for i = 1,table.maxn(this.bullets) do
                
                if this.bullets[i].bullet == unit then
                    --this.bullets[i].bullet:remove();
                    this.bullets[i].bullet:stopAllActions();
                    atari = i
                end

            end
            if atari ~= 0 then
                table.remove(this.bullets,atari);
            end
            return 1;
        end,

        suesideShot = function (this,unit)
            for i = 1,table.maxn(this.bullets) do
                this.bullets[i].bullet:stopAllActions();
                this.bullets[i].bullet:takeAnimation(0,this.bullets[i].endAnimationName,false);
                -- this.bullets[i].bullet:remove();
            end
            return 1;
        end,


        summon = function (this,unit)
            
            if this.summonedNumber > 5 then
                this.summonedNumber = 0;
            end

            local gaul = unit:getTeam():addUnit(this.summonedNumber,100161010);
            this.summonedNumber = this.summonedNumber + 1;
            if gaul == nil then
            else
                local x = unit:getSkeleton():getBoneWorldPositionX("gobul_top");
                local y = unit:getSkeleton():getBoneWorldPositionY("gobul_top");
                print(x);
                print(y);
                gaul:setPosition(x + unit:getPositionX(),y + unit:getPositionY());
            end
            return 1;
        end,

        glab = function (this,unit)
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                this.isTryGlab = true;
                this.glabBoneName = "L_arm3_hand_4";
            end
            return 1;
        end,

        checkGlabSucsess = function (this,unit)
            local ishost = megast.Battle:getInstance():isHost();
            print("glab sucsess???????????????????");
            if this.glabUnit ~= nil and ishost then
                print("glab sucsess>>>>>>>>>>>>>>>>");
                unit:setAnimation(0,"skill1_throw",false);
                this.isGlab = true;
                this.targetHitFlag = false;
                this.glabUnit:getTeamUnitCondition():addCondition(this.consts.palarizeID,this.consts.palarizeID,100,this.consts.palarizeTime,0);
                
                this.glabUnit:takeDamage();
                megast.Battle:getInstance():sendEventToLua(this.thisid,1,this.glabUnit:getIndex());
                print("glab sucsess!!!!!!!!!!!!!!!!!!!!");
            else
                unit:setAnimation(0,"skill1_miss",false);
            end
            this.isTryGlab = false;
            return 1;
        end,

        checkGlabSucsessGest = function (this,index)
            local ishost = megast.Battle:getInstance():isHost();
            this.glabUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
            if this.glabUnit ~= nil then
                this.myself:setAnimation(0,"skill1_throw",false);
                this.isGlab = true;
                this.targetHitFlag = false;
                this.glabUnit:getTeamUnitCondition():addCondition(this.consts.palarizeID,this.consts.palarizeID,100,this.consts.palarizeTime,0);
                
                this.glabBoneName = "L_arm3_hand_4";
            else
                this.myself:setAnimation(0,"skill1_miss",false);
            end
            return 1;
        end,



        throw = function (this,unit)
            this.glabBoneName = "Glab";
            return 1;
        end,

        throwEnd = function (this,unit)
            this.isGlab = false;
            local hit = unit:addOrbitSystem("GrowndHit");
            this.myself:takeHitStop(0.5);
            hit:setPosition(this.glabUnit:getPositionX(),this.glabUnit:getPositionY());
            hit:setTargetUnit(this.glabUnit);
            hit:setHitType(2);
            hit:setActiveSkill(12);
            this.glabUnit = nil;
            return 1;
        end,


        addSP = function (this,unit)
            print("addSP");
            unit:addSP(20);
            return 1;
        end,

        ashi = function (this,unit)
            -- if this.isInit then
            --     this.isInit = false;
            --     unit:addSubSkeleton("10040_leg",-30);
            -- end
            return 1;
        end,
 

        --共通変数
        param = {
          version = 1.4
          ,isUpdate = 1
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            this.checkGlabSucsessGest(this,intparam);
            return 1;
        end,

        receive2 = function (this , intparam)
            this.myself:getTeam():addUnit(intparam,100161010);
            this.summonedNumber = intparam+1;
            return 1;
        end,

        receive3 = function (this , intparam)
            print("receive3");
            this.myself:takeAnimation(1,"goblin_drop",false);
            return 1;
        end,

        receive4 = function (this , intparam)
            print("receive4");
            if megast.Battle:getInstance():getTeam(true):getTeamUnit(intparam) ~= nil then
                this.myself:setTargetUnit(megast.Battle:getInstance():getTeam(true):getTeamUnit(intparam));
                this.BeforetargetUnitIndex = intparam;
                this.myself:takeAnimation(1,"goblin_attack",false);
            end
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "goblinAttack" then return this.goblinAttack(this,unit) end
            if str == "onDestroy" then return this.onDestroy(this,unit) end
            if str == "summon" then return this.summon(this,unit) end
            if str == "glab" then return this.glab(this,unit) end
            if str == "checkGlabSucsess" then return this.checkGlabSucsess(this,unit) end
            if str == "throw" then return this.throw(this,unit) end
            if str == "throwEnd" then return this.throwEnd(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "ashi" then return this.ashi(this,unit) end
            return 1;
        end,

        --version1.4
        takeIn = function (this,unit)
            unit:setPosition(unit:getPositionX() - 200,unit:getPositionY());
            return 1;
        end,

        --version1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            return value;
        end,

        takeBreake = function (this,unit)
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
            if this.isGlab and this.glabUnit ~= nil then
                local x = unit:getSkeleton():getBoneWorldPositionX(this.glabBoneName);
                local y = unit:getSkeleton():getBoneWorldPositionY(this.glabBoneName);
                print("now glab");
                print(x);
                print(y);
                this.glabUnit:setPosition(x + unit:getPositionX(),y + unit:getPositionY() - 50);
                this.targetHitFlag = false;
                this.glabUnit._autoZorder = false;
                this.glabUnit:setZOrder(unit:getZOrder()+1);
            end
            if table.maxn(this.bullets) > 0 then
                for i = 1,table.maxn(this.bullets) do
                    print(this.bullets[i]);
                    bulletControll(this.bullets[i],this);
                end
            end
            for _,marker in pairs(this.hpMarkers) do
                local hpPercent = 100 * unit:getHP()/unit:getCalcHPMAX();
                if not marker.isUsed and hpPercent < marker.HP then
                    marker.isUsed = true
                    unit:removeHpMarker(marker.MARKER)
                end
            end
            return 1;
        end,



        attackDamageValue = function (this , unit , enemy , value)
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                if this.isTryGlab and unit == this.myself then
                    if unit:getTargetUnit() == enemy then
                        this.targetHitFlag = true;
                    end

                    if not this.targetHitFlag or this.glabUnit == nil  then
                        this.glabUnit = enemy;
                        this.isTryGlab = false;
                    end

                end
            end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            
            unit:setSkin("1");

            this.myself = unit;
            if this.isInit then
                this.isInit = false;
                unit:addSubSkeleton("50003_leg",-30);
            end
            unit:setSPGainValue(0);
            this.hpMarkers = {
                {
                    HP = 80,isUsed = false,MARKER = unit:addNumHpMarker(0.8)
                }
            }
            return 1;
        end,

        excuteAction = function (this,unit)
            local hpparcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            print(unit:getHP());
            print(unit:getCalcHPMAX());
            print(hpparcent);
            if hpparcent < 80 and not this.isRage and not this.isWeponLoss then
                this.isRage = true;
                this.attackChecker = true;
                unit:setActiveSkill(3);
                unit:takeAttack(3);
                this.breakePoint = unit:getRecordBreakPoint();
                unit:setSetupAnimationName("setUpWeapon");
               return 0;
            end

            this.actionCounter = this.actionCounter + 1;
            local ishost = megast.Battle:getInstance():isHost();
            print(ishost);
            if ishost then
                if this.actionCounter == this.nextSummonCounter then
                    if this.summonedNumber > 5 then
                        this.summonedNumber = 0;
                    end
                    unit:getTeam():addUnit(this.summonedNumber,100161010);
                    megast.Battle:getInstance():sendEventToLua(this.thisid,2,this.summonedNumber);
                    this.summonedNumber = this.summonedNumber + 1;

                    local rand = LuaUtilities.rand(0,5);
                    this.nextSummonCounter = this.nextSummonCounter + rand + 2;
                    
                end

                local rand = LuaUtilities.rand(0,100);
                if rand < this.consts.goblDropParcent then
                   unit:takeAnimation(1,"goblin_drop",false);
                   megast.Battle:getInstance():sendEventToLua(this.thisid,3,0);
                else
                    if megast.Battle:getInstance():getTeam(true):getTeamUnit(this.BeforetargetUnitIndex) ~= nil and  unit:getHP() > 0 then
                        unit:takeAnimation(1,"goblin_attack",false);
                        megast.Battle:getInstance():sendEventToLua(this.thisid,4,this.BeforetargetUnitIndex);
                    end
                end
            end

            if this.isRage and unit:getRecordBreakPoint() - this.breakePoint > unit:getBaseBreakCapacity()*1.5 then
                this.isRage = false;
                this.isWeponLoss = true;
                unit:setSkin("2");
                unit:takeAnimation(0,"damage2",false);
                unit:takeAnimationEffect(0,"damage2",false);

                
                --
                unit:setSetupAnimationName("setUpWeaponBreaked");
                
               return 0;
            end


            

        

            return 1;
        end,

        takeIdle = function (this , unit)
            this.isGlab = false
            if this.glabUnit ~= nil then
                this.glabUnit:getTeamUnitCondition():addCondition(this.consts.palarizeID,this.consts.palarizeID,100,0.01,0);
                this.glabUnit = nil;
            end
            if this.isRage then
                print("Now Rage");
                unit:takeAnimation(0,"idle2",true);
                return 0;
            end
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
         
            return 1;
        end,

        takeAttack = function (this , unit , index)
            this.isGlab = false
            if this.glabUnit ~= nil then
                this.glabUnit:getTeamUnitCondition():addCondition(this.consts.palarizeID,this.consts.palarizeID,100,0.01,0);
                this.glabUnit = nil;
            end
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(3);
            elseif index == 4 then
                unit:setActiveSkill(4);
            elseif index == 5 then
                unit:setActiveSkill(5);
            end
            if unit:getTargetUnit() ~= nil then
                this.BeforetargetUnitIndex = unit:getTargetUnit():getIndex();
            end
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                if not this.attackChecker then
                    if this.isRage then
                        this.attackChecker = true;
                        local rand = LuaUtilities.rand(0,100);

                        if rand <= this.consts.attack4Parcent then
                            unit:takeAttack(4);
                        else
                            unit:takeAttack(5);
                        end

                        return 0;
                    else
                        local rand = LuaUtilities.rand(0,100);
                        this.attackChecker = true;
                        if rand <= this.consts.attack1Parcent then
                            unit:takeAttack(1);
                        elseif rand <= this.consts.attack1Parcent + this.consts.attack2Parcent then
                            unit:takeAttack(2);
                        else
                            unit:takeAttack(5);
                        end
                        return 0;
                    end
                end
                this.attackChecker = false;
            end
            return 1;
        end,

        takeSkill = function (this,unit,index)
            this.isGlab = false
            if this.glabUnit ~= nil then
                this.glabUnit:getTeamUnitCondition():addCondition(this.consts.palarizeID,this.consts.palarizeID,100,0.01,0);
                this.glabUnit = nil;
            end
            if index == 2 then
                unit:setActiveSkill(6);
            end
            if unit:getTargetUnit() ~= nil then
                this.BeforetargetUnitIndex = unit:getTargetUnit():getIndex();
            end
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                if not this.skillChecker then
                    local target = unit:getTargetUnit()
                    local distance = BattleUtilities.getUnitDistance(unit,target)
                    local rand = LuaUtilities.rand(0,100);
                    this.skillChecker = true;
                    
                    unit:takeSkill(2);
                    
                    return 0;
                end
            end
            this.skillChecker = false;
            return 1;
        end,

        takeDamage = function (this , unit)
            this.isGlab = false;
            if this.glabUnit ~= nil then
                this.glabUnit:getTeamUnitCondition():addCondition(this.consts.palarizeID,this.consts.palarizeID,100,0.01,0);
                this.glabUnit = nil;
            end
            
            return 1;
        end,

        dead = function (this , unit)
            
            print("onDestroy By Dead");
            
            this.suesideShot(this,unit);

            for i = 0, 5 do
                local enemy = unit:getTeam():getTeamUnit(i);
                if not(enemy == nil )then
                    enemy:setHP(0);
                end
            end

            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return 1;
end

function bulletControll(bulletinstance,this)

    bulletinstance.frame = bulletinstance.frame + 1;
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 15;
    local speedOrigin = 1;
    local rand = LuaUtilities.rand(0,30);
    rand = rand - 15;

    bulletinstance.angle = bulletinstance.angle % 360;
    

    if bulletinstance.angle < 0 then
        bulletinstance.angle = 360 + bulletinstance.angle;
    end


    if framecnt == 1 then
        local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);
        if bullettarget ~= nil then
            bulletinstance.posx = bulletinstance.bullet:getPositionX();
            bulletinstance.posy = bulletinstance.bullet:getPositionY();
            local deg = getDeg(bulletinstance.posx,bulletinstance.posy,bullettarget:getPositionX(),bullettarget:getPositionY());
            bulletinstance.angle = deg;
        end
    else
        --local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);
        
        --bulletinstance.bullet:setRotation(bulletinstance.angle);
        bulletinstance.posy = bulletinstance.bullet:getPositionY();
        local rad = degToRad(bulletinstance.angle);
        --local speed = bulletinstance.speedkeisuu * unitManagerDeltaTime/0.016666667;
        --moveByFloat(bulletinstance,calcXDir(rad,speed),calcYDir(rad,speed));
        print("posy"..bulletinstance.posy);
        print("jimen"..bulletinstance.jimen);
        if bulletinstance.posy <= bulletinstance.jimen then
            bulletinstance.bullet:takeAnimation(0,bulletinstance.endAnimationName,false);
            bulletinstance.speedkeisuu = 0;
            --this.onDestroy(this,bulletinstance.bullet);
        end
    end

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

function calcXDir(rad,speed)
    return math.cos(rad)*speed;
end

function calcYDir(rad,speed)
    return math.sin(rad)*speed;
end


function moveByFloat(_bulletinstance,xdistance,ydistance)

    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;

    return true;
end
