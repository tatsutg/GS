function new(id)
    print("101284512 new ");
    local instance = {

        --ゼクトクラス
        Class = 
        {
            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Values
            isFirstStepUpdate = false,

            --uniqueID
            ThisUniqueId = id,

            --ThisUnit
            ThisUnit = nil,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆


            --初期化
            Initialize = function(this,unit)
                return 1;
            end,

            --アップデート
            Update = function(this,unit,deltatime)

                if this.Class.isFirstStepUpdate == false then
                    this.Class.FirstUpdateInitialize(this,unit);
                    this.Class.isFirstStepUpdate = true;
                end

                return 1;
            end,

            --LunScript
            --if str == "runSkillAttack" then return this.Class.runSkillAttack(this,unit) end
            runScriptUpdate = function(this , unit , str)
                return 1;
            end,

            --アタック分岐
            takeAttackBranch = function(this,unit,index)
                return 1;
            end,

            --スキル分岐用
            takeSkillBranch = function(this,unit,index)
                return 1;
            end,

            --アイドル分岐用
            takeIdleBranch = function(this,unit)
                return 1;
            end,

            --だめーじ分岐用
            takeDamageBranch = function(this,unit)
                return 1;
            end,

            --死亡分岐用
            takeDeadBranch = function(this,unit)
                return 1;
            end,

            --ブレイク分岐用
            takeBreakeBranch = function(this,unit)
                return 1;
            end,

            --excureAction分岐用
            excuteActionBranch = function(this,unit)
                return 1;
            end,

            --receive分岐用
            receiveBranch = function(this,intparam)
                return 1;
            end,

            --attackDamageValue分岐用
            attackDamageValueBranch = function(this , unit , enemy , value)

                --ターゲットした敵だった
                if unit:getTargetUnit() == enemy then

                    --print("ターゲットした敵です！");
                end

                this.Class.createRandomOrbitSystemEffect(this,unit,enemy,"attack1_HitEffect",100,100,200);

                print("DamageValue == ",value);
                return value;
            end,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Functions

            --アップデート最初の一度のみ実行される。
            FirstUpdateInitialize = function(this,unit)

                this.Class.ThisUnit = unit;

                return 1;
            end,

            --渡された target を基準に 指定された範囲で 指定されたエフェクトを 指定されたスケールで 表示する。
            --randomPosRangeに100を入れた場合 その半分 50 を原点として、 そこから -方向に 50 +方向に 50 でランダムで表示される。
            --randomScaleは100を基準 (1) として 設定される。
            -- randomScaleMin,randomScaleMax
            -- 100,200                          だった場合は (1.0 ~ 2.0)
            -- 50,200                           だった場合は (0.5 ~ 2.0)
            -- 50,100                           だった場合は (0.5 ~ 1.0)
            createRandomOrbitSystemEffect = function(this,unit,target,effectName,randomPosRange,randomScaleMin,randomScaleMax)

                -- local randomPosOffSet_X = 0;
                -- local randomPosOffSet_Y = 0;
                -- local randomScale = 0;

                -- randomPosOffSet_X = math.random(0,randomPosRange) - (randomPosRange * 0.5);
                -- randomPosOffSet_Y = math.random(0,randomPosRange) - (randomPosRange * 0.5);

                -- randomScale = math.random(randomScaleMin,randomScaleMax);
                -- randomScale = randomScale / randomScaleMin;

                -- print("orbitSystemHitEffectをCreate  UnitName == ",target:getUnitName());
                -- print("randomPosOffSet_X == ",randomPosOffSet_X);
                -- print("randomPosOffSet_Y == ",randomPosOffSet_Y);
                -- print("randomScale == ",randomScale);
                -- local orbitSystemHit = unit:addOrbitSystem(effectName);
                -- orbitSystemHit:setAnimation(0,effectName,false);
                -- orbitSystemHit:setPositionX(target:getAnimationPositionX() + randomPosOffSet_X);
                -- orbitSystemHit:setPositionY(target:getAnimationPositionY() + randomPosOffSet_Y);
                -- orbitSystemHit:setLocalZOrder(target:getZOrder() + 1);
                -- orbitSystemHit:getSkeleton():setScale(randomScale);

                return 1;
            end

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        },




        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆



        --共通変数
        param = {
          version = 1.3
          ,isUpdate = true
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            return this.Class.receiveBranch(this,intparam);
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            return this.Class.runScriptUpdate(this,unit,str);
        end,

        --version1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            return value;
        end,

        takeBreake = function (this,unit)
            return this.Class.takeBreakeBranch(this,unit);
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
            return this.Class.Update(this,unit,deltatime);
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return this.Class.attackDamageValueBranch(this,unit,enemy,value);
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            return this.Class.Initialize(this,unit);
        end,

        excuteAction = function (this , unit)
            return this.Class.excuteActionBranch(this,unit);
        end,

        takeIdle = function (this , unit)
            return this.Class.takeIdleBranch(this,unit);

        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
         
            return 1;
        end,

        takeAttack = function (this , unit , index)
            return this.Class.takeAttackBranch(this,unit,index);
        end,

        takeSkill = function (this,unit,index)
            return this.Class.takeSkillBranch(this,unit,index);
        end,

        takeDamage = function (this , unit)
            return this.Class.takeDamageBranch(this,unit);
        end,

        dead = function (this , unit)
            return this.Class.takeDeadBranch(this,unit);
        end
    }
    register.regist(instance,id,instance.param.version);
    return 1;
end

