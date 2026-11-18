--[[
    スキル効果に紐づくスクリプト

    getTeamUnitCondition():getDamageAffectInfo()
    int otherElementType;
    int otherAttribute;
    int skillAttribute;
    int skillElementType;
    int distance;
    bool critical;
    TeamUnit* other;
  ]]


 --[[

    ☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        読んでね☆　　　
    ☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

    【このluaがやること】
        このluaは、バフ、デバフ、状態異常などのTeamUnitConditionがかかった時、または効果が発動した時にその実行結果にちょっかいをかけて歪めるためのものです。
        システム上は「クリティカルダメージアップ」などは実は存在せず、物自体はただのダメージアップです。そこを、このluaをつかって「クリティカルではない時は効果量０にする」という実装を行なっています。

    【付与判定と発動時判定】
        conditinonには付与する時に通る「付与判定」と、効果が発動する時に通る「発動時判定」の２つがあります。
        付与判定の例：光属性ユニットに対してダメージアップを付与。（targetが光属性なら付与され、発動時は何も考えない）
        発動時判定の例：光属性攻撃のダメージアップ。（付与するときは何も考えないため誰にでも付与できる。攻撃がヒットした時に初めて、その攻撃が光属性なのかどうかを判断）

        この二つを場合に応じて使い分けることになります。
        付与判定はこの説明書きのすぐ下にある　addCondition の中で行われます。
        発動時判定は、id_xxx（xxxはscript_idの数字）という名前で定義されるfunctionで行われます。
        基本的には付与判定も発動判定もどちらも必ず呼び出されます。なので、script_id xxxに対応する発動判定　function id_xxx はかならず作成してください。
        ただし、一部の効果（回復、奥義ゲージアップなどのその場で効果が出て終わりなものとか）は、発動時判定を通りません。

    【付与判定　addCondition】
        conditionを付与する直前に通る場所です。ここでreturnする数値が、そのconditionの効果量となります。
        return 0 した場合は、効果量０で、付与自体が拒否された扱いにすることができます。
        value1~5はこのscript_idを制御するための数字が渡ってきます。

        ＜引数の説明＞
            script_id スクリプトID これをifでひっかけて処理をする
            caster *TeamUnit型 効果の発動者　必ずしも発動者＝＝対象者ではないところに注意。
            target *TeamUnit型　効果の対象者　このバフがかかろうとしている相手
            condition *TeamUnitCondition型　今まさにかかろうとしているバフそのもの。
            value number型　マスターで設定されている、このバフの効果量
            value1~value5 マスターで設定されている、判定や処理を行う時に使う数値　この数値の解釈はscriptIDによって様々

        例：script_id 199 対象にかかっている状態異常の数だけ効果量アップ　の場合、状態異常のカウントをして、return value * cnt している
        例：value1ユニットにのみ付与したいので、targetがvalue1属性以外の属性ならreturn 0 して処理を終了

    【発動判定　id_xxx】
        conditionが発動する時に通る場所です。conditionの種類によって通るタイミングは違います。
        ダメージアップ：攻撃ヒット時　被ダメージアップ：攻撃を受けた時　自然回復：毎秒　などなど……
        共通して、その効果の数値を計算する必要が出てきた時に呼ばれます。
        ダメージアップ・被ダメージアップ・バリアなどは、ダメージ計算時に処理がきますので、現在のダメージ情報（クリティカルなのか、物理、魔法どっちなのか、などなど）がこのタイミングのみ参照できます
        unit:getTeamUnitCondition():getDamageAffectInfo()で現在やりとりされているいるダメージの内容がみれます。

        ＜引数の説明＞
            unit *TeamUnit型　このバフがかかっている本人
            other *TeamUnit型　バフがかかっているユニットから見た「相手」、多くの場合は敵です。与ダメージ・被ダメージアップ、バリアなどのダメージ計算系のバフの時のみ存在します。与ダメUP・DOWNなら、今まさに殴りつけ用としている相手。被ダメUP・DOWNなら、今殴ってきた相手。
            condition *TeamUnitCondition型　かかっているバフの実態そのもの
            value number型　バフの効果量
            value1~value5 マスターで設定されている、判定や処理を行う時に使う数値　この数値の解釈はscriptIDによって様々

    【付与成功判定 isSuccessfulCondition】← NEW！！
        conditionが付与に成功した時、または失敗した時にきます。主に、氷結や麻痺などの１００％かかるか不確定なものなどで処理を引っ掛けたいときに使います。
        例：相手を氷結にさせることに成功した場合奥義ゲージ＋３０　など
        引数はaddConditionのものとほぼ同じですが、最後のisSuccessfullがcondition付与の成否を渡してくれます。
        また、ここでreturnする数値は特に意味がなく、return 0 したとしても、付与の拒否はできません。なんせ、付与された後にここにくるのですから……。
        valueをいじりたければ、引数のconditionを捕まえてsetValueすればいけます。

        ＜引数の説明＞
            script_id スクリプトID これをifでひっかけて処理をする
            caster *TeamUnit型 効果の発動者　必ずしも発動者＝＝対象者ではないところに注意。
            target *TeamUnit型　効果の対象者　このバフがかかろうとしている相手
            condition *TeamUnitCondition型　今まさにかかろうとしているバフそのもの。
            value number型　マスターで設定されている、このバフの効果量
            value1~value5 マスターで設定されている、判定や処理を行う時に使う数値　この数値の解釈はscriptIDによって様々
            isSuccsessfull bool 付与に成功していた場合はtrue 失敗していた場合はfalse

    【全体化判定 entirelyConditionValue】← NEW！！
            バフ全体化用の処理
            データでtargetが8だと動きます。
            複数同じアビリティを持つユニットがいる場合はそれぞれvalueをreturnして最も高い効果が適応されます。
            ＜引数の説明＞
                unit *TeamUnit型 アビリティ保持者
                target *TeamUnit型　味方チーム付与対象者
                type 効果タイプ
                value number型　マスターで設定されている、このバフの効果量
                script_id スクリプトID これをifでひっかけて処理をする
                value1~value5 マスターで設定されている、判定や処理を行う時に使う数値　この数値の解釈はscriptIDによって様々

    【毎フレーム判定 updateCondition】
            バフタイプ238を持つユニット毎に毎フレーム呼ばれます。
            ＜引数の説明＞
                unit *TeamUnit型 バフ保持者
                condition *TeamUnitCondition型 238のバフ
                target *TeamUnit型　味方チーム付与対象者
                type 効果タイプ
                dt デルタタイム
                value number型　バフの効果量
                value1~value5 マスターで設定されている、判定や処理を行う時に使う数値　この数値の解釈はscriptIDによって様々

    【毎フレーム判定 teamUnitOut】
            バフタイプ240を持つユニットの死亡時に呼ばれます。
            ＜引数の説明＞
                unit *TeamUnit型 バフ保持者
                condition *TeamUnitCondition型 238のバフ
                target *TeamUnit型　味方チーム付与対象者
                type 効果タイプ
                dt バフの効果時間
                value number型　バフの効果量
                value1~value5 マスターで設定されている、判定や処理を行う時に使う数値　この数値の解釈はscriptIDによって様々



    【邪悪な実装】
        このskill_effect.luaは、バイナリ更新が挟めないタイミングで、ユニットluaでできないことを無理矢理解決するために使われることがあります。
        そのため、たとえばaddCondition内で新たにconditionを生み出して付与したりしているものがあります。
        また、このskill_effect.luaは定期処理（update）がありません。そのため、持続ダメージのように定期的に処理が走るものを悪用して定期処理っぽい実装をしているものがあります。


  ]]

function addCondition(script_id,caster,target,condition,value,value1,value2,value3,value4,value5)
    local pvpCorrectionValue = 1
    if condition ~= nil then
        pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(condition:getConditionTypeAsInt(),1);
    end

    if script_id == 8 then
        ---スーパークリティカル用対策
        if condition:getConditionTypeAsInt() == 142 then
            condition:setRemoveOnResetState(true);
        elseif condition:getConditionTypeAsInt() == 22 then
            condition:setRemoveOnResetState(true);
        elseif condition:getConditionTypeAsInt() == 168 then
            condition:setRemoveOnResetState(true);
        end
    end

    if script_id == 9 then
        local losthp =  caster:getHP() * (value1 / 100);
        if value2 == 1 then
            losthp =  caster:getCalcHPMAX() * (value1 / 100);
        end

        local result = caster:getHP() - losthp;

        ---GB_EXボス用対応
        if megast.Battle:getInstance():isGrandBattleExBoss() then
            local damage = losthp
            if result < 1 then
                local damage = caster:getHP() - 1
            end
            local rate = megast.Battle:getInstance():getGBExBossSPBonusRate()
            local sp = damage / rate
            --summoner.Utility.messageByEnemy(sp.."/"..rate.."/"..damage)
            caster:addSP(sp,false,false,true)
        end

        --計算結果が小数点になる場合、支払い前のHPが１より大きいなら１残す
        if result <= 1 and caster:getHP() > 1 then
            result = 1;
        elseif result < 1 and caster:getHP() <= 1 then --HPが１以下の時に支払いをしようとした時は殺すがHPが負の値になられては困るので０チェック
            result = 0;
        end
        caster:setHP(result);
        return 0;
    end

    if script_id == 12 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 16 then
        local value = id_16(target, target,condition,value,value1,value2,value3);
        if value == 0 then
            return 0;
        end
        return value;
    end

    if script_id == 22 and value1 == 1 then
        local critical = caster:getTeamUnitCondition():getDamageAffectInfo().critical;
        if critical == false then
            return 0;
        end
        return value;
    end

    if script_id == 259 and value1 == 1 then
        local critical = caster:getTeamUnitCondition():getDamageAffectInfo().critical;
        if critical then
            return 0;
        end
        return value;
    end

    if script_id == 23 then
        if caster:getElementType() == value1 then
            return value;
        end
        return 0;
    end


    if script_id == 24 then
        if caster:getRaceType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 26 then
        if caster:getIsLeader() then
            return value;
        end
        return 0;
    end

    if script_id == 29 then
        local cond = target:getTeamUnitCondition():findConditionWithID(value1);
        if cond ~= nil then
            return 0;
        end
        return value;
    end

    if script_id == 39 then
        local cond = target:getTeamUnitCondition():findConditionWithType(value1);
        if cond == nil then
            return 0;
        end
        return value;
    end

    if script_id == 929 then
        local cond = target:getTeamUnitCondition():findConditionWithID(value1);
        if cond ~= nil then
            return 0;
        end
        return value;
    end

    if script_id == 35 then
        if target:getBaseID3() == value1  or target:getBaseID3() == value2  or target:getBaseID3() == value3 then
            return value;
        end
        return 0;
    end

    if script_id == 41 then
        local cond = target:getTeamUnitCondition():findConditionWithID(value2);
        if cond ~= nil then
            local stage = cond:getValue3();
            if stage == 0 then
                 stage = 1;
            end
            stage = stage + 1;
            if stage > value1 then
                stage = value1;
            end
            if stage == value1 then
                cond:setValue(value * stage * 2);
            else
                cond:setValue(value * stage);
            end
            cond:setValue3(stage);
            return 0;
        end
        return value;
    end

    --TODO 不具合用修正_申請後直す
    if script_id == 44 then
        if caster:getEnemyID() == 1035 then
            condition:setCaster(nil);
        end
    end

    --自分以外対象
    if script_id == 46 then
        if caster == target then
            return 0;
        end
    end

    --交互に付与
    if script_id == 48 then
        local key = "change_buff"..tostring(value2);
        local key2 = "beforebuff"..tostring(value2);
        local before = tonumber(target:getParameter(key2));
        target:setParameter(key2, tostring(value1));

        local countstr = target:getParameter(key);
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value2);

        if countstr == "" then
            if value1 ~= 1 then
                countstr = "3";
                target:setParameter(key,"3");
                return 0;
            end
            countstr = "1";
            target:setParameter(key,"1");
            return value;
        end
        local count = tonumber(countstr);
        count = count + 1;
        if before == value1 then
            print("重複")
            count = count + 2;
        end
        target:setParameter(key,tostring(count));
        count = math.floor(count / 2);

        local floor = count % 2;

        if floor == 1 then
            --かけない
            return 0;
        else
            --かける　
            if cond ~= nil then
                target:getTeamUnitCondition():removeCondition(cond);
            end
        end

        return value;
    end

    --竜族一時退避用
    if script_id == 50 then
        if target:getRaceType() == value1 then
            return value;
        end

        return 0;
    end

     --魔族一時退避用
    if script_id == 52 then
        if target:getRaceType() == value1 then
            return value;
        end

        return 0;
    end

    if script_id == 58 then
        if value1 ~= 0 then
            local element = caster:getElementType()
            if element == 0 then element = 6 end

            if element == value1 then
                return value;
            else
                return 0
            end
        end
    end

    --回数制限付き重複あり
    if script_id == 61 then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value2);
        if cond ~= nil then
            local sum = cond:getValue() + value;
            if sum >= value1 then
                sum = value1;
            end
            cond:setValue(sum);
            return 0;
        else
            return value;
        end
    end


    if script_id == 69 then
        if caster:getBaseID3() == value1 then
            return value;
        end
        return 0;
    end

    --ボスがブレイク中じゃないときに付与
    if script_id == 72 then
        local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
        if boss ~= nil and boss:getBreakPoint() <= 0 then
            return 0;
        else
            return value;
        end
    end

    --ボスがブレイク中のときに付与
    if script_id == 73 then
        local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
        if boss ~= nil and boss:getBreakPoint() <= 0 then
            return value;
        else
            return 0;
        end
    end

    --購読速度FIX
    if script_id == 74 then
        local rate = 1 + ((target:getTeamUnitCondition():findConditionValue(28) + value) / 100);
        target:setAnimationTimeScale(rate);
        return value;
    end

    --グループIDを上書き
    if script_id == 77 then
        if condition ~= nil then
            condition:setGroupID(value1);
            condition:setPriority(value2);
        end
        return value;
    end


    if script_id == 79 then
        local value = id_79(target, target,condition,value,value1,value2,value3);
        if value == 0 then
            return 0;
        end
        return value;
    end

    if script_id == 80 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 81 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 82 then
        if target:getRaceType() == value1 then
            return value;
        end
        return 0;
    end

    --ボスのブレイク値がvalue1％以下のとき付与
    if script_id == 83 then
        local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
        if boss == nil then
            return 0;
        end

        local per = boss:getBreakPoint() / boss:getBaseBreakCapacity() * 100;
        if per <= value1 then
            return value;
        else
            return 0;
        end
    end

    --自分のHPが◯％〜◯％の時に付与
    if script_id == 85 then
        if (caster:getHPPercent() * 100) >= value1 and (caster:getHPPercent() * 100) <= value2 then
            return value;
        end
        return 0;
    end

    if script_id == 93 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 95 then
        local cond = target:getTeamUnitCondition():findConditionWithID(value1);
        if cond ~= nil then
            return value;
        end
        return 0;
    end

    --獣双槌オルトロスのFIX用
	--奥義ゲージ40吸収。
    if script_id == 1033 then
        local sp_percent = 1 - (target:getTeamUnitCondition():findConditionValue(140) / 100);
		if sp_percent < 0 then
			sp_percent = 0;
		end
		value = value * sp_percent;

        local point = target:getBurstPoint() * value * 0.01 * pvpCorrectionValue;

        caster:addSP(point);
        target:setBurstPoint(target:getBurstPoint() - point);

        return 0;
    end


    if script_id == 98 or script_id == 99 then
        local israid = megast.Battle:getInstance():isRaid();
        if israid then
            return value;
        end
        return 0;
    end


    if script_id == 103 then
        local team = megast.Battle:getInstance():getTeam(not caster:getisPlayer());
		if megast.Battle:getInstance():isPvp() then
        	team = megast.Battle:getInstance():getTeam(not caster:getisPvpPlayer());
		end
        for i = 0,7 do
             local teamUnit = team:getTeamUnit(i);
             if teamUnit ~= nil then
                    if teamUnit:getRaceType() == value1 or teamUnit:getRaceType() == value2 or teamUnit:getRaceType() == value3 then
                        return value;
                    end
             end
        end
        return 0;
    end

    if script_id == 104 then

        if (value1 == 0 or value1 == nil) and (value2 == 0 or value2 == nil) then
            return value;
        end

        if target:getElementType() == value1 or target:getElementType() == value2 then
            return value;
        end

        return 0;
    end

    if script_id == 114 then
        if target:getElementType() == value1 then
            return value;
        else
            return 0;
        end
    end

    if script_id == 115 then
        if target:getSexuality() == value1 then
            return value;
        else
            return 0;
        end
    end

    if script_id == 116 then
        local count = 0;
        for i = 0,7 do
            local teamUnit = caster:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getSexuality() == value1 then
                    count = count + 1;
                end
            end
        end
        value = value * count;
        return value;
    end

    --ニーア専用
    if script_id == 10110 then
        --HEAL_POWER_PERCENT
        local heal_power_percent = 1 + (condition:getCaster():getTeamUnitCondition():findConditionValue(115) / 100);
        for i = 0,7 do
            local teamUnit = caster:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then
                local rate2 = 1 + (teamUnit:getTeamUnitCondition():findConditionValue(110) / 100);
                local heal_value = (value * heal_power_percent * rate2);
                teamUnit:takeHeal(heal_value,caster);
            end
        end
        caster:setSkillEffectEnabled(false);
        return 0;
    end

	--奥義ゲージ吸収
    if script_id == 200260029 then
		--奥義ゲージ吸収耐性計算
        local sp_percent = 1 - (target:getTeamUnitCondition():findConditionValue(140) / 100);
		if sp_percent < 0 then
			sp_percent = 0;
		end
		value = value * sp_percent * pvpCorrectionValue;
        if target:getBurstPoint() > value then
            caster:addSP(value);
            target:setBurstPoint(target:getBurstPoint() - value);
        else
            caster:addSP(target:getBurstPoint());
            target:setBurstPoint(0);
        end
        return 0;
    end

    if script_id == 20182700 then
        local critical = caster:getTeamUnitCondition():getDamageAffectInfo().critical;
        if critical then
            pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(8,1);
            caster:addSP(value1 * pvpCorrectionValue);
        end
        return 0;
    end

	-- 真装備グロール:状態異常時奥義ゲージ吸収
    if script_id == 1097 then
        local val = target:getTeamUnitCondition():findConditionValue(131);
        val = val + target:getTeamUnitCondition():findConditionValue(89);
        val = val + target:getTeamUnitCondition():findConditionValue(90);
        val = val + target:getTeamUnitCondition():findConditionValue(91);
        val = val + target:getTeamUnitCondition():findConditionValue(92);
        val = val + target:getTeamUnitCondition():findConditionValue(93);
        val = val + target:getTeamUnitCondition():findConditionValue(94);
        val = val + target:getTeamUnitCondition():findConditionValue(95);
        val = val + target:getTeamUnitCondition():findConditionValue(96);
        val = val + target:getTeamUnitCondition():findConditionValue(97);

        if val == 0 then
            return 0;
        end

        local sp_percent = 1 - (target:getTeamUnitCondition():findConditionValue(140) / 100);
		if sp_percent < 0 then
			sp_percent = 0;
		end
		value = value * sp_percent * pvpCorrectionValue;

        if target:getBurstPoint() > value then
            caster:addSP(value);
            target:setBurstPoint(target:getBurstPoint() - value);
        else
            caster:addSP(target:getBurstPoint());
            target:setBurstPoint(0);
        end
        return 0;
    end

    --アビリティ重複防止用命令
    if script_id >= 900 then
        local cond = target:getTeamUnitCondition():findConditionWithType(value3);
        if cond ~= nil and cond: getScriptID() == script_id then

            if value > 0 then
                if cond:getValue() < value then
                    cond:setValue(value);
                    print("効果が上書きされました")
                    return 0;
                else
                    print("効果が無視されました")
                return 0;
                end
            else
                if cond:getValue() > value then
                    cond:setValue(value);
                    print("効果が上書きされました")
                    return 0;
                else
                    print("効果が無視されました")
                return 0;
                end
            end

        else

        end
        print("効果が付与されます")
    end


    if script_id == 111 then
        local cond = target:getTeamUnitCondition():findConditionWithID(value2);
        if cond ~= nil then
            local stage = cond:getValue3();
            if stage == 0 then
                 stage = 1;
            end
            stage = stage + 1;
            cond:setNumber(stage);
            if stage > value1 then
                stage = value1;
                cond:setNumber(10);
            end
            cond:setValue(value * stage);
            cond:setValue3(stage);
            return 0;
        end
        return value;
    end

    if script_id == 113 then
        if caster == target then
            return 0;
        end
    end

    if script_id == 123 then
        if caster:getRaceType() == value1 then
            return value;
        end
        return 0;
    end

    --カテミラ専用　炎、水、樹属性のうち何種類がPT内に存在するかによって効果変動　光闇には効果なし
    if script_id == 124 then
        if target:getElementType() == kElementType_Light or target:getElementType() == kElementType_Dark then
            return 0;
        end
        return value;
    end

    if script_id == 125 then
        if caster:getElementType() == value1 or caster:getElementType() == value2 then
            return value;
        end
        return 0;
    end

    --HPにより効果変動かつ自分以外対象
    if script_id == 128 then
        if caster == target then
            return 0;
        end
    end

    --対象のHP消費かつ自分以外
    if script_id == 134 then
        if caster == target then
            return 0;
        end
        local losthp =  target:getHP() * (value1 / 100);
        if value2 == 1 then
            losthp =  target:getCalcHPMAX() * (value1 / 100);
        end
        local result = target:getHP() - losthp;
        ---GB_EXボス用対応
        if megast.Battle:getInstance():isGrandBattleExBoss() then
            local damage = losthp
            if result < 1 then
                local damage = caster:getHP() - 1
            end
            local rate = megast.Battle:getInstance():getGBExBossSPBonusRate()
            local sp = damage / rate
            --summoner.Utility.messageByEnemy(sp.."/"..rate.."/"..damage)
            target:addSP(sp,false,false,true)
        end
        if result <= 0 then
            result = 1;
        end
        target:setHP(result);
    end


    if script_id == 138 then
        local cond1 = target:getTeamUnitCondition():findConditionValue(value1);
        local cond2 = target:getTeamUnitCondition():findConditionValue(value2);
        local cond3 = target:getTeamUnitCondition():findConditionValue(value3);
        local cond4 = target:getTeamUnitCondition():findConditionValue(value4);

        if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and target:getElementType() == value5 then
            return value;
        end
        return 0;
    end

    -- 火
    if script_id == 1381 then
        local cond1 = target:getTeamUnitCondition():findConditionValue(value1);
        local cond2 = target:getTeamUnitCondition():findConditionValue(value2);
        local cond3 = target:getTeamUnitCondition():findConditionValue(value3);
        local cond4 = target:getTeamUnitCondition():findConditionValue(value4);
        local cond5 = target:getTeamUnitCondition():findConditionValue(value5);

        if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and cond5 > 0 and target:getElementType() == 1 then
            return value;
        end
        return 0;
    end

    -- 水
    if script_id == 1382 then
        local cond1 = target:getTeamUnitCondition():findConditionValue(value1);
        local cond2 = target:getTeamUnitCondition():findConditionValue(value2);
        local cond3 = target:getTeamUnitCondition():findConditionValue(value3);
        local cond4 = target:getTeamUnitCondition():findConditionValue(value4);
        local cond5 = target:getTeamUnitCondition():findConditionValue(value5);

        if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and cond5 > 0 and target:getElementType() == 2 then
            return value;
        end
        return 0;
    end

    -- 木
    if script_id == 1383 then
        local cond1 = target:getTeamUnitCondition():findConditionValue(value1);
        local cond2 = target:getTeamUnitCondition():findConditionValue(value2);
        local cond3 = target:getTeamUnitCondition():findConditionValue(value3);
        local cond4 = target:getTeamUnitCondition():findConditionValue(value4);
        local cond5 = target:getTeamUnitCondition():findConditionValue(value5);

        if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and cond5 > 0 and target:getElementType() == 3 then
            return value;
        end
        return 0;
    end

    -- 光
    if script_id == 1384 then
        local cond1 = target:getTeamUnitCondition():findConditionValue(value1);
        local cond2 = target:getTeamUnitCondition():findConditionValue(value2);
        local cond3 = target:getTeamUnitCondition():findConditionValue(value3);
        local cond4 = target:getTeamUnitCondition():findConditionValue(value4);
        local cond5 = target:getTeamUnitCondition():findConditionValue(value5);

        if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and cond5 > 0 and target:getElementType() == 4 then
            return value;
        end
        return 0;
    end

    -- 闇
    if script_id == 1385 then
        local cond1 = target:getTeamUnitCondition():findConditionValue(value1);
        local cond2 = target:getTeamUnitCondition():findConditionValue(value2);
        local cond3 = target:getTeamUnitCondition():findConditionValue(value3);
        local cond4 = target:getTeamUnitCondition():findConditionValue(value4);
        local cond5 = target:getTeamUnitCondition():findConditionValue(value5);

        if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and cond5 > 0 and target:getElementType() == 5 then
            return value;
        end
        return 0;
    end

    if script_id == 139 then
        local losthp =  target:getHP() * (value1 / 100);
        if value2 == 1 then
            losthp =  target:getCalcHPMAX() * (value1 / 100);
        end
        local result = target:getHP() - losthp;

        ---GB_EXボス用対応
        if megast.Battle:getInstance():isGrandBattleExBoss() then
            local damage = losthp
            if result < 1 then
                local damage = caster:getHP() - 1
            end
            local rate = megast.Battle:getInstance():getGBExBossSPBonusRate()
            local sp = damage / rate
            --summoner.Utility.messageByEnemy(sp.."/"..rate.."/"..damage)
            target:addSP(sp,false,false,true)
        end

        --計算結果が小数点になる場合、支払い前のHPが１より大きいなら１残す
        if result <= 1 and target:getHP() > 1 then
            result = 1;
        elseif result < 1 and target:getHP() <= 1 then --HPが１以下の時に支払いをしようとした時は殺すがHPが負の値になられては困るので０チェック
            result = 0;
        end
        target:setHP(result);
    end

    if script_id == 140 then
        if target:getBaseID3() == value1  or target:getBaseID3() == value2  or target:getBaseID3() == value3 then
            return value;
        end
        return 0
    end

    --自分のHPが◯％〜◯％かつ奥義の時で行動終了時に削除
    if script_id == 141 then
        condition:setRemoveOnResetState(true);
        if (target:getHPPercent() * 100) >= value1 and (target:getHPPercent() * 100) <= value2 then
            return value;
        end

        return 0;
    end

    --自分のHPが◯％〜◯％　付与判定で弾くバージョン
    if script_id == 142 then
        if (target:getHPPercent() * 100) >= value1 and (target:getHPPercent() * 100) <= value2 then
            return value;
        end

        return 0;
    end

    --攻撃相手もしくは、攻撃してきた相手が有利属性(付与時に属性判定)かつvalue1の効果が自身にかかっている場合のみ発動
    if script_id == 144 then
        if target:getElementType() == value2 then
            return value;
        end
        return 0;
    end

    --value1属性のユニットに対して付与　HP回復量アップを強制適用
    if script_id == 145 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    --セティス専用
    if script_id == 146 then
        if caster == target then
            -- local cond = caster:getTeamUnitCondition():findConditionWithID(condition:getID());
            local cond = caster:getTeamUnitCondition():findConditionWithGroupID(1031);
            if cond ~= nil then
                caster:getTeamUnitCondition():removeCondition(cond);
            end

            local casterbuff = caster:getTeamUnitCondition():addCondition(20250702,0,90,200,0);
            casterbuff:setGroupID(1031);
            casterbuff:setPriority(200);

            return 0;
        end
        condition:setValue3(caster:getIndex());
        return value;
    end


    if script_id == 147 then
        local cond = target:getTeamUnitCondition():findConditionWithID(value2);
        if cond ~= nil then
            local stage = cond:getValue3();
            if stage == 0 then
                 stage = 1;
            end
            stage = stage + 1;
            if stage > value1 then
                stage = value1;
            end
            if stage == value1 then
                cond:setValue(value * stage * 2);
            else
                cond:setValue(value * stage);
            end
            cond:setNumber(stage);
            megast.Battle:getInstance():updateConditionView();
            cond:setValue3(stage);
            return 0;
        end
        condition:setID(value2);
        condition:setNumber(1);
        megast.Battle:getInstance():updateConditionView();
        return value;
    end

    if script_id == 150 then
        if target:getBaseID3() == value1  or target:getBaseID3() == value2  or target:getBaseID3() == value3 then
            return value;
        end
        return 0;
    end

    if script_id == 151 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 152 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 153 then
        condition:setRemoveOnResetState(true);
    end

    if script_id == 155 then
        return value;
    end

    if script_id == 156 then
        return value;
    end

    if script_id == 158 then

        local pay = value1 * target:getCalcHPMAX()/100;
        if target:getHP() < pay then
            pay = target:getHP() -1;
            target:setHP(1);
        else
            target:setHP(target:getHP() - pay);
        end
        condition:setValue(pay * value2);--一応明示的にセットしておく
        return pay * value2;
    end

    --闇フェン 専用
    --例：SP即時増加は重複関係を持たないが、２個同時装備してても片方しか発動しないようにしたい時。
    --このアビリティはクエストの開幕時以外には発動できない。（蘇生時やレイド入れ替え時は無効となる）
    if script_id == 159 then
        if megast.Battle:getInstance():getBattleState() == kBattleState_active then
            return 0;
        end
        if megast.Battle:getInstance():isStart() == true then
            return 0;
		end
        if value2 ~= 0 and target:getRaceType() ~= value2 then
            return 0;
        end
        if value3 ~= 0 and target:getElementType() ~= value3 then
            return 0;
        end
        local cond = target:getTeamUnitCondition():findConditionWithID(value1);
        if cond ~= nil then
            if cond:getValue() >= value then
                return 0;
            end
            target:getTeamUnitCondition():addCondition(value1,0,value,999999,0);
            target:setBurstPoint(target:getBurstPoint() - cond:getValue());
        else

            target:getTeamUnitCondition():addCondition(value1,0,value,999999,0);
        end

        return value;
    end

    if script_id == 160 then
        if (target:getHPPercent() * 100) >= value1 and (target:getHPPercent() * 100) <= value2 then
            return value;
        else
            return 0;
        end
    end

    if script_id == 161 then

        if target:getElementType() ~= value3 and value3 ~= 0 and value3 ~= nil then
            return 0;
        end

        local cond = target:getTeamUnitCondition():findConditionWithID(value2);
        if cond ~= nil then
            local stage = cond:getValue4();
            if stage == 0 then
                 stage = 1;
            end
            stage = stage + 1;
            if stage > value1 then
                stage = value1;
            end
            if stage == value1 then
                cond:setValue(value * stage);
                cond:setNumber(10);
            else
                cond:setValue(value * stage);
                cond:setNumber(stage);
            end

            megast.Battle:getInstance():updateConditionView();
            cond:setValue4(stage);
            return 0;
        end
        condition:setID(value2);
        condition:setNumber(1);
        megast.Battle:getInstance():updateConditionView();
        return value;
    end

    if script_id == 163 then
        local team = megast.Battle:getInstance():getTeam(not caster:getisPlayer());
		if megast.Battle:getInstance():isPvp() then
        	team = megast.Battle:getInstance():getTeam(not caster:getisPvpPlayer());
		end

        for i = 0,7 do
             local teamUnit = team:getTeamUnit(i);
             if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond ~= nil then
                    if cond:getProtectTarget() == target:getIndex() then
                        return value;
                    end
                end
             end
        end
        return 0;
    end

    if script_id == 165 then
        local team = megast.Battle:getInstance():getTeam(caster:getisPlayer());
		if megast.Battle:getInstance():isPvp() then
        	team = megast.Battle:getInstance():getTeam(caster:getisPvpPlayer());
		end
        for i = 0,7 do
             local teamUnit = team:getTeamUnit(i);
             if teamUnit ~= nil and teamUnit ~= caster then
                    if teamUnit:getRaceType() == value1 or teamUnit:getRaceType() == value2 or teamUnit:getRaceType() == value3 then
                        return value;
                    end
             end
        end
        return 0;
    end

    if script_id == 167 then

        if target:getElementType() ~= value3 and value3 ~= 0 and value3 ~= nil then
            return 0;
        end

        local cond = target:getTeamUnitCondition():findConditionWithID(value2);
        if cond ~= nil then
            local stage = cond:getValue5();
            if stage == 0 then
                 stage = 1;
            end
            stage = stage + 1;
            if stage > value1 then
                stage = value1;
            end
            if stage == value1 then
                cond:setValue(value * stage);
                cond:setNumber(10);
            else
                cond:setValue(value * stage);
                cond:setNumber(stage);
            end

            megast.Battle:getInstance():updateConditionView();
            cond:setValue5(stage);
            return 0;
        end
        condition:setID(value2);
        condition:setNumber(1);
        megast.Battle:getInstance():updateConditionView();
        return value;
    end

    if script_id == 168 then
        local team = caster:getTeam()

        local condValue = condition:getValue()
        ---回復用処理
        if condition:getConditionTypeAsInt() == 7 then
            local rate = 1
            local conditionSize = caster:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize == 0 then
                return
            end
            for i = 0,(conditionSize - 1) do
                local cond = caster:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getConditionTypeAsInt() == 115 then
                    rate = rate + (cond:getValue() / 100)
                end
            end
            condValue = condValue * rate
        end

        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                if value4 == 0 or (value4 ~= 0 and teamUnit:getRaceType() == value4) then
                    local cond = teamUnit:getTeamUnitCondition():findConditionWithGroupID(value2);
                    if cond ~= nil then
                        if cond:getPriority() <= condition:getPriority() then
                            teamUnit:getTeamUnitCondition():removeCondition(cond);
                            local buff = nil
                            if condition:getAnimationID() > 0 then
                                buff = teamUnit:getTeamUnitCondition():addCondition(value3,condition:getConditionType(),condValue,condition:getTime(),value1,condition:getAnimationID());
                            else
                                buff = teamUnit:getTeamUnitCondition():addCondition(value3,condition:getConditionType(),condValue,condition:getTime(),value1);
                            end
                            buff:setGroupID(value2);
                            buff:setPriority(condition:getPriority());
                            buff:setItemType(condition:getItemTypeAsInt())
                            buff:setCasterByLua(caster)
                            if megast.Battle:getInstance():isPvp() or caster:getisPlayer() then
                                buff:setIsCasterPlayer(true)
                            end
                        end
                    else
                        local buff = nil
                        if condition:getAnimationID() > 0 then
                            buff = teamUnit:getTeamUnitCondition():addCondition(value3,condition:getConditionType(),condValue,condition:getTime(),value1,condition:getAnimationID());
                        else
                            buff = teamUnit:getTeamUnitCondition():addCondition(value3,condition:getConditionType(),condValue,condition:getTime(),value1);
                        end
                        buff:setGroupID(value2);
                        buff:setPriority(condition:getPriority());
                        buff:setItemType(condition:getItemTypeAsInt())
                        buff:setCasterByLua(caster)
                        if megast.Battle:getInstance():isPvp() or caster:getisPlayer() then
                            buff:setIsCasterPlayer(true)
                        end
                    end
                end
            end
        end
        return 0;
    end

    --value1 属性に対して付与　value2属性に対して発動　物理か魔法か全部か選べる
    if script_id == 169 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 1469 then
        if target:getBaseID3() == value2 then
            return value;
        end
        return 0;
    end

    if script_id == 170 then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value1);
        if cond ~= nil then
            return value;
        end
        return 0;
    end

    if script_id == 1702 then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value1);
        if cond ~= nil then
            return value;
        end
        return 0;
    end

    if script_id == 1703 then
        if value3 == 1 then
            local ancestor = getAncestorUnit(target);
            if value1 == 1 then
                ancestor = getAncestorUnit(caster);
            end

            local cond = ancestor:getTeamUnitCondition():findConditionWithGroupID(value2);
            if cond ~= nil then
                return value;
            end
            return 0;
        end
        return value;
    end

    if script_id == 173 then

        local cond = target:getTeamUnitCondition():findConditionWithID(value2);
        if cond ~= nil and cond:getGroupID() == condition:getGroupID() then
            local stage = cond:getValue5();
            if stage == 0 then
                 stage = 1;
            end
            stage = stage + 1;
            if stage > value1 then
                stage = value1;
            end

            if  cond:getPriority() > condition:getPriority() then
                return 0
            end

            if  cond:getPriority() < condition:getPriority() then
                target:getTeamUnitCondition():removeCondition(cond);
                condition:setID(value2);
                condition:setNumber(1);
                megast.Battle:getInstance():updateConditionView();
                return value
            end

            cond:setMaxConditionIconNumber(value1)
            if stage == value1 then
                cond:setValue(value * stage);
                cond:setNumber(value1);
            else
                cond:setValue(value * stage);
                cond:setNumber(stage);
            end

            megast.Battle:getInstance():updateConditionView();
            cond:setValue5(stage);
            cond:setPriority(condition:getPriority())
            return 0;
        end
        condition:setID(value2);
        condition:setNumber(1);
        megast.Battle:getInstance():updateConditionView();
        return value;
    end

    if script_id == 172 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    --発動者のPTにvalue1~3族のユニットがいれば付与
    if script_id == 175 then
        local team = megast.Battle:getInstance():getTeam(caster:getisPlayer());
		if megast.Battle:getInstance():isPvp() then
        	team = megast.Battle:getInstance():getTeam(caster:getisPvpPlayer());
		end
        for i = 0,7 do
             local teamUnit = team:getTeamUnit(i);
             if teamUnit ~= nil and teamUnit ~= caster then
                    if teamUnit:getRaceType() == value1 or teamUnit:getRaceType() == value2 or teamUnit:getRaceType() == value3 then
                        return value;
                    end
             end
        end
        return 0;
    end

    if script_id == 176 then
        if target:getRaceType() ~= value1 then
            return 0;
        end
    end

    if script_id == 177 then
        if caster:getRaceType() ~= value1 then
            return 0;
        end
    end

    if script_id == 178 then
        target:setDeadDropSp(value1);
    end

    if script_id == 180 then
            local val = target:getTeamUnitCondition():findConditionValue(131);
            val = val + target:getTeamUnitCondition():findConditionValue(89);
            val = val + target:getTeamUnitCondition():findConditionValue(90);
            val = val + target:getTeamUnitCondition():findConditionValue(91);
            val = val + target:getTeamUnitCondition():findConditionValue(92);
            val = val + target:getTeamUnitCondition():findConditionValue(93);
            val = val + target:getTeamUnitCondition():findConditionValue(94);
            val = val + target:getTeamUnitCondition():findConditionValue(95);
            val = val + target:getTeamUnitCondition():findConditionValue(96);
            val = val + target:getTeamUnitCondition():findConditionValue(97);

            if val == 0 then
                return 0;
            end
    end

    if script_id == 181 then

        local isControll = false;
        if caster ~= nil then
            isControll = caster:isMyunit() or (caster:getisPlayer() == false and megast.Battle:getInstance():isHost());
        end
        if not isControll then
            return 0;
        end
        local condID = caster:getParentTeamUnit():getParameter("targetID");
        condID = tonumber(condID);
        if condID ~= value1 then
            return 0;
        end
        condition:setValue2(caster:getParentTeamUnit():getIndex());
        -- local weaponBuff = caster:getParentTeamUnit():getTeamUnitCondition():findConditionWithID(50225400);
        -- if weaponBuff ~= nil then

        --     condition:setTime(condition:getTime() + 20000000);
        -- end
    end

    if script_id == 182 then
        local cond = target:getTeamUnitCondition():findConditionWithType(value1);
        if cond ~= nil then
            return value;
        end

        if value2 == 0 then
            return 0;
        end
        local cond2 = target:getTeamUnitCondition():findConditionWithType(value2);
        if cond2 ~= nil then
            return value;
        end
        return 0;
    end

    if script_id == 183 then
        condition:setRemoveOnResetState(true);
    end

    if script_id == 184 then
        local cnt = 0;
        local team = megast.Battle:getInstance():getTeam(not caster:getisPlayer());
		if megast.Battle:getInstance():isPvp() then
        	team = megast.Battle:getInstance():getTeam(not caster:getisPvpPlayer());
		end


        for i = 0 , 7 do
           local uni = team:getTeamUnit(i);
           if uni ~= nil then
               cnt = cnt + 1;
           end
        end
        if cnt > value1 then
            cnt = value1;
        end
        condition:setValue3(cnt);

    end

    --相手がブレイク中
    if script_id == 185 then
        if target:getBreakPoint() > 0 then
            return 0;
        end
    end

    if script_id == 2094 then

        --相手PTにブレイク中のvalue1サイズのユニットがいれば付与

        local team = megast.Battle:getInstance():getTeam(not caster:getisPlayer());
		if megast.Battle:getInstance():isPvp() then
        	team = megast.Battle:getInstance():getTeam(not caster:getisPvpPlayer());
		end
        for i = 0,7 do
             local teamUnit = team:getTeamUnit(i);
             if teamUnit ~= nil and teamUnit ~= caster then
                    if teamUnit:getBreakPoint() <= 0 and teamUnit:getSize() == value1 then
                        return value;
                    end
             end
        end
        return 0;

    end

    if script_id == 186 then

        if caster == nil then
            return value;
        end
        if caster:getParentTeamUnit() == nil then
            return value;
        end
        local cond = caster:getParentTeamUnit():getTeamUnitCondition():findConditionWithID(value1);
        if cond == nil then

            local cond2 = caster:getParentTeamUnit():getTeamUnitCondition():addCondition(value1,129,1,9999,0);
            cond2:setScriptID(187);
            cond2:setValue1(value1);
            cond2:setValue2(value2);
            cond2:setValue3(condition:getID());
            cond2:setValue4(0);
            cond2:setValue5(megast.Battle:getInstance().m_wave);
        end

    end

    if script_id == 1862 then

        if caster == nil then
            return value;
        end
        if caster:getParentTeamUnit() == nil then
            return value;
        end
        local cond = caster:getParentTeamUnit():getTeamUnitCondition():findConditionWithID(value1);
        if cond == nil then

            local cond2 = caster:getParentTeamUnit():getTeamUnitCondition():addCondition(value1,129,1,9999,0);
            cond2:setScriptID(1872);
            cond2:setValue1(value4);
            cond2:setValue2(value2);
            cond2:setValue3(condition:getID());
            cond2:setValue4(value3);
            cond2:setValue5(megast.Battle:getInstance().m_wave);
        end

    end

    if script_id == 188 then
        condition:setRemoveOnResetState(true);
    end

    if script_id == 189 then

        if caster:getElementType() ~= value3 and value3 ~= 0 and value3 ~= nil then
            return 0;
        end


        local casterIndex = caster:getIndex();
        local itemSlotIndex = 0;
        local key = "";
        local cnt = 0;

        local item = caster:getActiveItemSkill():getBattleItem();
        if item ~= nil then
            itemSlotIndex = item:getSlotIndex();
        end


        key = "scriptID"..script_id..casterIndex..itemSlotIndex;
        local str = caster:getParameter(key);

        if str ~= "" and caster:getParameter(key) ~= nil then
           cnt = tonumber(str);
           caster:setParameter(key,""..(cnt + 1));
        else
            caster:setParameter(key,""..1);
        end

        if cnt > value2 then
            cnt = value2;
        end

        value = value - cnt * value1;

        return value;
    end

    if script_id == 190 then
        local cond = target:getTeamUnitCondition():findConditionWithID(value1);
        if cond ~= nil then
            if unit:getElementType() == value2 then
                return value;
            end
        end
        return 0;
    end

    if script_id == 191 then
        if caster:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 193 then
        local losthp =  value1;

        local result = caster:getHP() - losthp;

        --計算結果が小数点になる場合、支払い前のHPが１より大きいなら１残す
        if result <= 1 and caster:getHP() > 1 then
            result = 1;
        elseif result < 1 and caster:getHP() <= 1 then --HPが１以下の時に支払いをしようとした時は殺すがHPが負の値になられては困るので０チェック
            result = 0;
        end
        caster:setHP(result);
        return 0;
    end

    if script_id == 194 then
        local parent = caster:getParentTeamUnit();
        local teamUnit = caster;
        if parent ~= nil then
            teamUnit = parent;
        end
        if teamUnit:getRaceType() == value1 then
            return value;
        end
        return 0;
    end

    --交互に付与  改良版　複数バフを複数段階で扱えるように変更
    if script_id == 198 then
        local key = "change_buff"..tostring(value2);

        local countstr = target:getParameter(key);
        local count = 0;

        if countstr == "" then
            countstr = "0";
            target:setParameter(key,"0");
        else
            count = tonumber(countstr);

        end



        local floor = 1 + count % value3;

        if value4 == 1 then
            count = count + 1;
            target:setParameter(key,tostring(count));
        end

        if floor == value1 then
            --かける　
            -- while target:getTeamUnitCondition():findConditionWithGroupID(value2) ~= nil do
                local cond = target:getTeamUnitCondition():findConditionWithGroupID(value2);

                -- if cond ~= nil then
                --     summoner.Utility.messageByEnemy(cond:getValue1());
                -- end

                if cond ~= nil and cond:getValue1() ~= floor then

                    target:getTeamUnitCondition():removeCondition(cond);
                end

            --end
            --value4にこのバフがスタート地点かどうかの判定を入れてもらう必要あり　1ならスタート地点と判断

            return value;
        end

        return 0;
    end

    if script_id == 199 then
        local cnt = 0;
        for _,v in pairs(getBadStatusList()) do
            if target:getTeamUnitCondition():findConditionValue(v) > 0 then
                cnt = cnt + 1;
            end
        end
        return value * cnt;
    end

    if script_id == 200 then
        local buff = target:getTeamUnitCondition():findConditionWithID(value1);
        if buff == nil then
            return 0;
        end
        if buff:getValue() < value2 then
            return 0;
        end
        return value;
    end

    if script_id == 201 then
        condition:setRemoveOnResetState(true);
    end

    if script_id == 202 then
        if target:getBaseID3() == value1  or target:getBaseID3() == value2  or target:getBaseID3() == value3 then
            return value;
        end
        return 0;
    end

    if script_id == 203 then
        local val = target:getTeamUnitCondition():findConditionValue(value1);

        if val == 0 then
            return 0;
        end
    end

    if script_id == 208 then
        local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
        if boss ~= nil and boss:getBreakPoint() <= 0 and target:getElementType() == value1 then
            return value;
        else
            return 0;
        end
    end

    if script_id == 210 then
        local buff = caster:getTeamUnitCondition():findConditionWithID(value1);
        if value3 == 0 then
            if buff == nil then
                return 0;
            end
            if buff:getValue() < value2 then
                return 0;
            end
        else
            if buff == nil then
                return value;
            end
            if buff:getValue() >= value2 then
                return 0;
            end
        end

        return value;
    end

    if script_id == 211 then
        local team = megast.Battle:getInstance():getTeam(caster:getisPlayer());
		if megast.Battle:getInstance():isPvp() then
        	team = megast.Battle:getInstance():getTeam(caster:getisPvpPlayer());
		end

        for i = 0,7 do
             local teamUnit = team:getTeamUnit(i);
             if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond ~= nil then
                    if cond:getProtectTarget() == target:getIndex() then
                        return value;
                    end
                end
             end
        end
        return 0;
    end

    if script_id == 213 then
        local time = BattleControl:get():getTime();
        condition:setTime(condition:getTime() + time/value1);
    end

    if script_id == 214 then
        -- local conditionSize = target:getTeamUnitCondition():getAllConditionsSize();

        -- for i = 0,(conditionSize - 1) do
        --     local cond = target:getTeamUnitCondition():getAllConditionsAt(i);

        --     if cond ~= nil and  cond:getGroupID() == value2 and  cond:getID() == value3 then
        --         if cond:getPriority() <= condition:getPriority() then
        --             target:getTeamUnitCondition():removeCondition(cond);
        --             local buff = target:getTeamUnitCondition():addCondition(value3,condition:getConditionType(),condition:getValue(),condition:getTime(),value1);
        --             buff:setGroupID(value2);
        --             buff:setPriority(condition:getPriority());
        --             return 0;
        --         else
        --             return 0;
        --         end
        --     end

        -- end

        -- local buff = target:getTeamUnitCondition():addCondition(value3,condition:getConditionType(),condition:getValue(),condition:getTime(),value1);
        -- buff:setGroupID(value2);
        -- buff:setPriority(condition:getPriority());


        -- return 0;
    end

    if script_id == 216 then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value1);
        if cond ~= nil then
            return value + value2;
        end
    end

    if script_id == 2162 then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value1);
        if cond ~= nil then
            return value + value2;
        end
    end

    if script_id == 218 then
        if target:getBurstPoint() < value1 then
            return 0;
        end
    end

    if script_id == 219 then
        if target:getElementType() == value1 or target:getElementType() == value2 or target:getElementType() == value3 or target:getElementType() == value4 then
            return value;
        end
        return 0;
    end

    if script_id == 220 then
        local cond = caster:getTeamUnitCondition():findConditionWithType(value1);
        if cond ~= nil then
            return value;
        end

        if value2 == 0 then
            return 0;
        end
        local cond2 = caster:getTeamUnitCondition():findConditionWithType(value2);
        if cond2 ~= nil then
            return value;
        end
        return 0;
    end

    if script_id == 221 then
        if target:getElementType() ~= value3 then
            if value4 == 0 then
                return 0;
            end
        else
            if value4 == 1 then
                return 0;
            end
        end
        local cond = caster:getTeamUnitCondition():findConditionWithGroupID(value1);
        if cond ~= nil then
            condition:setTime(condition:getTime() + value2);
        end
    end

    if script_id == 225 then
        return value;
    end

    if script_id == 2252 then
        return value;
    end

    if script_id == 224 then--出血専用
        return value;
    end

    if script_id == 2242 then--出血専用
        local cond = target:getTeamUnitCondition():findConditionWithID(value2);

        if cond == nil then return 0 end

        return value;
    end

    if script_id == 2302 then
        if target:getBurstPoint() >= value1 then
            return value;
        end
        return 0
    end

    if script_id == 228 then
        if value2 ~= 0 then
            if caster:getFantasyEvolutionType() == value2 then
                return 0
            end
        end
        return value
    end

    if script_id == 232 then--楔専用

        local cond = target:getTeamUnitCondition():findConditionWithID(value2);
        local targetCondID = -2320 - caster:getIndex();
        local check = target:getTeamUnitCondition():findConditionWithID(targetCondID);
        if check ~= nil and cond ~= nil then
            return 0;
        end

        target:getTeamUnitCondition():addCondition(targetCondID,0,1,1,0);

        if cond ~= nil then

            local stage = cond:getValue5();
            if stage == 0 then
                 stage = 1;
            end
            stage = stage + 1;
            if stage > value1 then
                stage = value1;
            end

            local time = cond:getTime();
            local thumb = cond:getThumbnailID();


            target:getTeamUnitCondition():removeCondition(cond);


            local newCond = target:getTeamUnitCondition():addCondition(value2,31,value * stage,time,thumb);

            if stage == value1 then
                newCond:setValue(value * stage);
                newCond:setNumber(stage);
            else
                newCond:setValue(value * stage);
                newCond:setNumber(stage);
            end

            megast.Battle:getInstance():updateConditionView();
            newCond:setValue5(stage);
            newCond:setGroupID(condition:getGroupID());


            return 0;
        end
        local newCond = target:getTeamUnitCondition():addCondition(value2,31,value,condition:getTime(),condition:getThumbnailID());

        newCond:setNumber(1);
        newCond:setGroupID(condition:getGroupID());
        megast.Battle:getInstance():updateConditionView();
        return 0;
    end

    if script_id == 234 then

        if caster:getElementType() ~= value1 and value1 ~= 0 and value1 ~= nil then
            return 0;
        end


        local casterIndex = caster:getIndex();
        local itemSlotIndex = 0;
        local key = "";
        if value4 == 1 then
            itemSlotIndex = 4;
        else
            local itemSkill = caster:getActiveItemSkill()
            if itemSkill ~= nil then
                local item = itemSkill:getBattleItem();
                if item ~= nil then
                    itemSlotIndex = item:getSlotIndex();
                end
            end
        end


        key = "scriptID"..script_id.."c"..casterIndex.."i"..itemSlotIndex;
        local str = caster:getParameter(key);

        local liveUnit = 0;
        for i=0,7 do
            local targetUnit = caster:getTeam():getTeamUnit(i);
            if targetUnit ~= nil then
                liveUnit = liveUnit + 1;
            end
        end
        if value3 > 0 then
            liveUnit = liveUnit * value3
        end

        if str ~= "" and str ~= nil then
            local cnt = tonumber(str);
            if cnt >= liveUnit or value2 ~= 1 then
                return 0;
            end
            caster:setParameter(key,""..cnt + 1);
        else
            caster:setParameter(key,""..1);
        end

        return value;
    end

    if script_id == 235 then
        local race = caster:getParentTeamUnit():getRaceType();
        local element = caster:getParentTeamUnit():getElementType();
        if value1 ~= 0 and race ~= value1 then
            return 0;
        end
        if value2 ~= 0 and element ~= value2 then
            return 0;
        end

        return value;
    end

    --オービットシステムの生成者のHPが◯％〜◯％の時に付与
    if script_id == 236 then
        if caster == nil then
            return 0;
        end
        local parent = caster:getParentTeamUnit();
        local current = caster;

        if parent ~= nil then
            current = parent;
        end

        if (current:getHPPercent() * 100) >= value1 and (current:getHPPercent() * 100) <= value2 then
            return value;
        end
        return 0;
    end

    if script_id == 237 then
        local parent = caster:getParentTeamUnit();
        local current = caster;

        if parent ~= nil then
            current = parent;
        end
        local cond = current:getTeamUnitCondition():findConditionWithGroupID(value1);
        if cond ~= nil then
            cond:setRemoveOnResetState(true);
            return value;
        end
        return 0;
    end

    if script_id == 238 then
        ---自然回復割合FLG
        if condition ~= nil then
            condition:setValue4(2004349)
        end
         if caster:getElementType() == value1 or value1 == 0 then
            return value;
        end
        return 0;
    end

    if script_id == 243 then
        return value + caster:getCalcDefence()
    end

    if script_id == 244 then
        local cond = caster:getTeamUnitCondition():addCondition(-244,25,-1000,condition:getTime(),0);
        cond:setScriptID(76);
        return value;
    end

    if script_id == 245 then

        local mostFew = 999999999;
        local mostFewUnit = nil;
        local team = megast.Battle:getInstance():getTeam(caster:getisPlayer());
		if megast.Battle:getInstance():isPvp() then
        	team = megast.Battle:getInstance():getTeam(caster:getisPvpPlayer());
		end
        for i = 0,7 do
             local teamUnit = team:getTeamUnit(i);
             if teamUnit ~= nil then
                    if teamUnit:getHP() <= mostFew then
                        mostFew = teamUnit:getHP();
                        mostFewUnit = teamUnit;
                    end
             end
        end
        local rate = 1 + mostFewUnit:getTeamUnitCondition():findConditionValue(126) / 100 + mostFewUnit:getTeamUnitCondition():findConditionValue(110)/100;--回復量アップ＆旧回復量アップ
        local rate2 = 1 + caster:getTeamUnitCondition():findConditionValue(115) / 100;--回復力アップ
        mostFewUnit:takeHeal(mostFewUnit:getCalcHPMAX() * (value1/100) * rate * rate2,caster,condition:getItemTypeAsInt());
        return 0;
    end

    if script_id == 246 then

         if caster:getElementType() == value1 or value1 == 0 then
            return value;
        end
        return 0;
    end

    if script_id == 249 then
        local per =  target:getHPPercent() * 100;
        if per <= value1 then
            return value + value2
        end
        return value;
    end

    if script_id == 250 then
        ---自然回復割合FLG
        if condition ~= nil then
            condition:setValue4(2004349)
        end

        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    -- 相手が状態異常の時付与
    if script_id == 252 then
        if value2 == 0 then return value end

        local val = target:getTeamUnitCondition():findConditionValue(131);
        val = val + target:getTeamUnitCondition():findConditionValue(89);
        val = val + target:getTeamUnitCondition():findConditionValue(90);
        val = val + target:getTeamUnitCondition():findConditionValue(91);
        val = val + target:getTeamUnitCondition():findConditionValue(92);
        val = val + target:getTeamUnitCondition():findConditionValue(93);
        val = val + target:getTeamUnitCondition():findConditionValue(94);
        val = val + target:getTeamUnitCondition():findConditionValue(95);
        val = val + target:getTeamUnitCondition():findConditionValue(96);
        val = val + target:getTeamUnitCondition():findConditionValue(97);
        val = val + target:getTeamUnitCondition():findConditionValue(129);
        val = val + target:getTeamUnitCondition():findConditionValue(135);
        if val == 0 then return value2 == 2 and value or 0 end

        return value2 == 2 and 0 or value
    end

    if script_id == 253 then
        if target:getBaseID3() == value1  or target:getBaseID3() == value2  or target:getBaseID3() == value3 then
            return value;
        end
        return 0;
    end

    if script_id == 254 then
        local per =  target:getHPPercent() * 100;
        if per <= value1 then
            return value + value2
        end
        return value;
    end

    if script_id == 255 then
        if target ~= caster then
            return value;
        end
        return 0;
    end

    if script_id == 256 then
        local team = megast.Battle:getInstance():getTeam(caster:getisPlayer());
        if megast.Battle:getInstance():isPvp() then
            team = megast.Battle:getInstance():getTeam(caster:getisPvpPlayer());
        end

        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(value1);
                if cond ~= nil and caster ~= teamUnit then
                    return value;
                end
            end
        end
        return 0;
    end

    if script_id == 257 then--出血専用
        return value;
    end

    if script_id == 261 and value1 == 1 then
        for k,v in pairs(getBadStatusList()) do
            if v ~= value3 and caster:getTeamUnitCondition():findConditionValue(v) > 0 then
                return 0;
            end
        end

        return value;
    end
--付与されるたびに効果上昇
    if script_id == 262 then
        --付与判定
        if value1 == 1 then
            local critical = caster:getTeamUnitCondition():getDamageAffectInfo().critical;
            if critical == false then
                return 0;
            end
        end

        local cond = target:getTeamUnitCondition():findConditionWithID(value4);
        if cond ~= nil then
            local stage = cond:getValue5();
            if stage == 0 then
                stage = 1;
            end
            stage = stage + 1;
            if stage > value3 then
                stage = value3;
            end
            if stage == value3 then
                cond:setValue(value * stage);
                cond:setNumber(10);
            else
                cond:setValue(value * stage);
                cond:setNumber(stage);
            end

            megast.Battle:getInstance():updateConditionView();
            cond:setValue5(stage);
            return 0;
        end
        condition:setID(value4);
        condition:setNumber(1);
        megast.Battle:getInstance():updateConditionView();
        return value;
    end

    if script_id == 263 then
        if caster:getElementType() == value1 and target:getElementType() == value2 then
            return value
        end
        return 0
    end

    if script_id == 265 then
        if value4 == 0 then
            return value
        end
        local skill = target:getActiveBattleSkill();
        if skill == nil then
            return value;
        end

        local type = target:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if value1 ~= 0 and value1 ~= type and value1 ~= 7 then
            return value;
        end

        local buff  = nil
        buff = target:getTeamUnitCondition():addCondition(value4,17,0,99999,0)
        buff:setScriptID(149)
        buff:setValue1(value1)
        return value
    end

    if script_id == 266 then
        local mostFew = 999999999;
        local mostFewUnit = nil;
        local team = caster:getTeam();
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getBurstPoint() <= mostFew then
                    mostFew = teamUnit:getBurstPoint()
                    mostFewUnit = teamUnit;
                end
            end
        end
        pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(8,1);
        mostFewUnit:addSP(value1 * pvpCorrectionValue);
        return 0;
    end

    if script_id == 271 then
        if value2 == 1 then
            for _,v in pairs(getBadStatusList()) do
                if target:getTeamUnitCondition():findConditionValue(v) > 0 then
                    return 0;
                end
            end
        end
        return value;
    end

    if script_id == 272 then
        local value = id_272(target, target,condition,value,value1,value2,value3);
        if value == 0 then
            return 0;
        end
        return value;
    end

    if script_id == 273 then
        if target:getRaceType() == value1 or target:getRaceType() == value2 or target:getRaceType() == value3 then
            return value;
        end
        return 0
    end

    if script_id == 275 then
        if caster:getElementType() == value2 then
            value = value3
        end
        if value4 == 0 then
            return value
        end
        local skill = target:getActiveBattleSkill();
        if skill == nil then
            return value;
        end

        local type = target:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if value1 ~= 0 and value1 ~= type and value1 ~= 7 then
            return value;
        end

        local buff  = nil
        buff = target:getTeamUnitCondition():addCondition(value4,17,0,99999,0)
        buff:setScriptID(149)
        buff:setValue1(value1)
        return value
    end

    if script_id == 276 then
        if caster:getElementType() ~= value2 then
            value = value3
        end
        if value4 == 0 then
            return value
        end
        local skill = target:getActiveBattleSkill();
        if skill == nil then
            return value;
        end

        local type = target:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if value1 ~= 0 and value1 ~= type and value1 ~= 7 then
            return value;
        end

        local buff  = nil
        buff = target:getTeamUnitCondition():addCondition(value4,17,0,99999,0)
        buff:setScriptID(149)
        buff:setValue1(value1)
        return value
    end

    if script_id == 278 then
        return value;
    end

    if script_id == 280 then
        if (target:getHPPercent() * 100) >= value1 and (target:getHPPercent() * 100) <= value2 then
            return value;
        end

        return 0;
    end

    if script_id == 285 then
        local team = caster:getTeam()

        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                if value1 == 0 then
                    local valueHalf = value / 2
                    teamUnit:addSP(valueHalf * pvpCorrectionValue);
                else
                    teamUnit:addSP(value1 * pvpCorrectionValue);
                end
            end
        end
        return value;
    end

    if script_id == 286 then
        ---属性付与判定
        if value4 ~= 0 then
            if value4 == 6 then
                if target:getElementType() ~= 0 then
                    return 0
                end
            elseif target:getElementType() ~= value4 then
                return 0
            end
        end
        ---種族付与判定
        if value5 ~= 0 then
            if target:getRaceType() ~= value5 then
                return 0
            end
        end

        if value1 == 0 then
            return value
        end
        ---バフのID
        local skillNum = math.floor(condition:getID() / 10000000)
        local count = 0
        ---装備位置、またはスキルの種類
        local slotIndex = 40000
        if skillNum == 30 then
            ---装備の場合
            local item = nil
            local itemSkill = caster:getActiveItemSkill()
            if itemSkill ~= nil then
                item = itemSkill:getBattleItem();
            end
            if item ~= nil then
                slotIndex = item:getSlotIndex() * 10000
            end
        else
            ---装備以外の場合
            local skill = caster:getActiveBattleSkill();
            if skill ~= nil then
                slotIndex = slotIndex + (skill:getIndex() * 10000)
            end
        end
        ---ユニットの位置
        local unitIndex = caster:getIndex() * 100000
        if value3 == 0 then
            slotIndex = 0
            unitIndex = 0
        end
        local min = (2861 + slotIndex + unitIndex) * -1
        local max = (2860 + value1 + slotIndex + unitIndex) * -1
        for i = min,max,-1 do
            ---フラグの個数だけカウント
            count = count + 1
            local buff = target:getTeamUnitCondition():findConditionWithID(i);
            if buff == nil then
                ---フラグ付与
                if value3 ~= 2 then
                    target:getTeamUnitCondition():addCondition(i,0,0,99999,0)
                end
                break
            end
        end
        ---番号など
        condition:setMaxConditionIconNumber(value1);
        condition:setNumber(count);
        if condition:getGroupID() ~= 0 then
            local priority = value
            if priority < 0 then
                priority = priority * -1
            end
            condition:setPriority(priority * count)
        end
        megast.Battle:getInstance():updateConditionView();
        return value * count;
    end

    if script_id == 287 then
        local floor = megast.Battle:getInstance():getCurrentMineFloor()
        if value2 == 0 then
            value2 = 1
        end
        value = value + (floor * value1 / value2)
        return value
    end

    if script_id == 288 then
        if value2 == 1 then
            local count = 0;
            for i = 0,7 do
                local teamUnit = caster:getTeam():getTeamUnit(i);
                if teamUnit ~= nil then
                    if teamUnit:getRaceType() == value1 then
                        count = count + 1;
                    end
                end
            end
            value = value * count;
            return value;
        end
    end

    if script_id == 289 then
        if target:getSize() == 3 then
            return value;
        else
            return 0
        end
    end

    if script_id == 291 then
        local conditionSize = target:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize == 0 then return 0 end
        ---for文数値設定
        local min = 0
        local max = conditionSize - 1
        local step = 1
        ---逆順
        if value1 == 1 then
            min = conditionSize - 1
            max = 0
            step = -1
        end
        ---ユニットの状態異常を配列化
        for i = min,max,step do
            local cond = target:getTeamUnitCondition():getAllConditionsAt(i);
            if cond ~= nil then
                for _,v in pairs(getUnitBadStatusList()) do
                    if cond:getConditionTypeAsInt() == v then
                        ---状態異常を一つ見つけたら終了
                        cond:setTime(0)
                        return 0
                    end
                end
            end
        end
        return 0
    end

    if script_id == 292 then
        if target:getRaceType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 294 then
        if value1 == 0 then
            ---ボスでない場合付与
            if target:getTeam():getBoss() ~= target then
                return value
            end
            return 0;
        else
            ---ボスにのみ付与
            if target:getTeam():getBoss() == target then
                return value
            end
            return 0;
        end
    end

    if script_id == 298 then
        local damageRate = target:getActiveBattleSkill():getDamageRate()
        local damageRateFixed = damageRate + (value * 0.01)
        target:getActiveBattleSkill():setDamageRate(damageRateFixed)
        return 0
    end

    if script_id == 299 then
        if (target:getHPPercent() * 100) >= value1 and (target:getHPPercent() * 100) <= value2 then
            if value4 == 1 then
                if target:getElementType() ~= value3 then
                    return 0;
                end
            end
            return value;
        end
        return 0;
    end

    if script_id == 300 then
        local team = megast.Battle:getInstance():getTeam(caster:getisPlayer());
        if megast.Battle:getInstance():isPvp() then
            team = megast.Battle:getInstance():getTeam(caster:getisPvpPlayer());
        end

        local condValue = condition:getValue()
        ---回復用処理
        if condition:getConditionTypeAsInt() == 7 then
            local rate = 1
            local conditionSize = caster:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize == 0 then
                return
            end
            for i = 0,(conditionSize - 1) do
                local cond = caster:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getConditionTypeAsInt() == 115 then
                    rate = rate + (cond:getValue() / 100)
                end
            end
            condValue = condValue * rate
        end

        local parent = caster:getParentTeamUnit();
        local teamUnit = caster;
        if parent ~= nil then
            teamUnit = parent;
        end
        if teamUnit:getElementType() ~= value4 then
            return 0
        end
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithGroupID(value2);
            if cond ~= nil then
                if cond:getPriority() <= condition:getPriority() then
                    teamUnit:getTeamUnitCondition():removeCondition(cond);
                    local buff = nil
                    if condition:getAnimationID() > 0 then
                        buff = teamUnit:getTeamUnitCondition():addCondition(value3,condition:getConditionType(),condValue,condition:getTime(),value1,condition:getAnimationID());
                    else
                        buff = teamUnit:getTeamUnitCondition():addCondition(value3,condition:getConditionType(),condValue,condition:getTime(),value1);
                    end
                    buff:setGroupID(value2);
                    buff:setPriority(condition:getPriority());
                end
            else
                local buff = nil
                if condition:getAnimationID() > 0 then
                    buff = teamUnit:getTeamUnitCondition():addCondition(value3,condition:getConditionType(),condValue,condition:getTime(),value1,condition:getAnimationID());
                else
                    buff = teamUnit:getTeamUnitCondition():addCondition(value3,condition:getConditionType(),condValue,condition:getTime(),value1);
                end
                buff:setGroupID(value2);
                buff:setPriority(condition:getPriority());
            end
        end
        return 0;
    end

    if script_id == 301 then
        local buffFlg = caster:getTeamUnitCondition():findConditionWithID(301301);
        if buffFlg ~= nil then
            --フラグ用バフがある場合はvalue2の更新判定を行う
            if buffFlg:getValue() > value2 then
                value2 = buffFlg:getValue()
            elseif buffFlg:getValue() < value2 then
                --フラグ用バフの書き換えを実行
                local unitTeam = caster:getTeam();  --自分PTからみて味方PTを取る
                local targetTeam = nil;
                if unitTeam == megast.Battle:getInstance():getTeam(true) then
                    targetTeam = megast.Battle:getInstance():getTeam(true);
                else
                    targetTeam = megast.Battle:getInstance():getTeam(false);
                end

                for i = 0,7 do
                    local myTeamUnit = targetTeam:getTeamUnit(i);
                    if myTeamUnit ~= nil then
                        buffFlg = myTeamUnit:getTeamUnitCondition():findConditionWithID(301301);
                        if buffFlg ~= nil then
                            buffFlg:setValue(value2)
                        end
                    end
                end
            end
        else
            --フラグ用バフが無かった場合は自PTにフラグ用バフを付与する
            local unitTeam = caster:getTeam();  --自分PTからみて味方PTを取る
            local targetTeam = nil;
            if unitTeam == megast.Battle:getInstance():getTeam(true) then
                targetTeam = megast.Battle:getInstance():getTeam(true);
            else
                targetTeam = megast.Battle:getInstance():getTeam(false);
            end

            for i = 0,7 do
                local myTeamUnit = targetTeam:getTeamUnit(i);
                if myTeamUnit ~= nil then
                    myTeamUnit:getTeamUnitCondition():addCondition(301301,0,value2,0.1,0);
                end
            end
        end

        megast.Battle:getInstance():updateConditionView()
        if caster:getLevel() < value3 then
            return 0
        end
        local level = 0
        local conditionSize = target:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = target:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil then
                    if cond:getScriptID() == 301 and condition:getConditionTypeAsInt() == cond:getConditionTypeAsInt() then
                        level = cond:getValue1()
                        if level >= value2 then
                            break;
                        end
                        target:getTeamUnitCondition():removeCondition(cond)
                        break;
                    end
                end
            end
        end
        level = level + 1
        if level > value2 then
            return 0
        end
        condition:setValue1(level)
        condition:setMaxConditionIconNumber(value2);
        condition:setNumber(level)
        return value * level
    end

    if script_id == 305 then
        if value2 == 1 and caster == target then
            return 0;
        end
        local buff = caster:getTeamUnitCondition():findConditionWithID(value1)
        if buff ~= nil then
            return value
        else
            return 0
        end
    end

    if script_id == 307 then
        if value2 >= 1 then
            local count = 0;
            for i = 0,7 do
                local teamUnit = caster:getTeam():getTeamUnit(i);
                if teamUnit ~= nil then
                    if teamUnit:getElementType() == value1 then
                        count = count + 1;
                    end
                end
            end
            value = value * count;
            if value2 >= 2 then
                condition:setPriority(math.abs(value))
            end
            return value;
        end
    end

    if script_id == 308 then
        value = value * summoner.Utility.getUnitHealthRate(caster)
        if value < 1 then value = 1 end
        return value
    end

    if script_id == 309 then
        local paramID = ""..condition:getID()
        ---装備対応
        local item = nil
        local itemSkill = caster:getActiveItemSkill()
        if itemSkill ~= nil then
            item = itemSkill:getBattleItem();
        end
        if item ~= nil then
            paramID = paramID..item:getSlotIndex()
        end
        ---メイン処理
        local countString = caster:getParameter(paramID)
        local count = 0
        local FLG = false
        local myTeam = caster:getTeam()
        ---カウントを取得
        if countString == "" then
            count = 1
        else
            count = tonumber(countString)
        end
        ---一番左に付与した場合(付与順は最後)
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit == target then
                    ---最後の場合はカウントアップフラグ
                    FLG = true
                end
                break;
            end
        end
        ---制限値を超えているとvalueを0に
        if count > value2 then
            value = 0
            local buff = nil
            local conditionSize = target:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize ~= 0 then
                for i = 0,(conditionSize - 1) do
                    local cond = target:getTeamUnitCondition():getAllConditionsAt(i);
                    if cond:getScriptID() == condition:getScriptID() and cond:getValue3() == condition:getValue3() and cond:getID() == condition:getID() then
                        buff = cond
                    end
                end
            end
            if buff ~= nil then
                value = buff:getValue()
                condition:setTime(buff:getTime())
            end
        end
        ---ここでカウントアップ
        if FLG then
            count = count + 1
        end
        ---カウントをセット
        caster:setParameter(paramID,""..count)
        return value
    end

    if script_id == 310 then
        local myTeam = target:getTeam()
        if megast.Battle:getInstance():isMultiPlay() or megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
            ---レイド、クロスバトル、マルチ処理
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i,true)
                if myTeamUnit ~= nil then
                    if myTeamUnit:getHP() > 0 and myTeamUnit == target then
                        return value
                    end
                    return 0
                end
            end
        else
            ---通常処理
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    if myTeamUnit:getIsLeader() then
                        if myTeamUnit == target then
                            return value
                        end
                        return 0
                    end
                end
            end
        end
        return 0
    end
    ---value1状態の時
    if script_id == 312 then
        local cond = target:getTeamUnitCondition():findConditionWithType(value1);
        if cond ~= nil then
            return value
        end
        return 0;
    end

    ---value1状態でない時
    if script_id == 313 then
        local cond = target:getTeamUnitCondition():findConditionWithType(value1);
        if cond ~= nil then
            return 0
        end
        return value
    end

    if script_id == 314 then
        ---自然回復割合FLG
        condition:setValue4(2004349)
        local unit = getAncestorUnit(caster)
        if unit:getRaceType() == value1 or value1 == 0 then
            return value;
        end
        return 0;
    end

    if script_id == 315 then
        local unit = getAncestorUnit(caster)
        if unit:getRaceType() == value1 or value1 == 0 then
            if unit ~= target then
                return value;
            end
        end
        return 0;
    end

    if script_id == 317 then
        local unit = getAncestorUnit(caster)
        if unit:getElementType() ~= value1 then
            return value;
        end
        return 0;
    end

    if script_id == 318 then
        if target:getElementType() ~= value1 then
            return value;
        end
        return 0;
    end

    if script_id == 319 then
        if BattleControl:get():getTime() <= value1 then
            return value;
        end
        return 0;
    end

    if script_id == 320 then
        if BattleControl:get():getTime() > value1 then
            return value;
        end
        return 0;
    end

    if script_id == 321 then
        ---データ取得
        local condID = condition:getID()
        local type = condition:getConditionTypeAsInt()
        local condValue = condition:getValue()
        local time = condition:getTime()
        local icon = condition:getThumbnailID()
        ---グループID関係1
        local targetCond = nil
        if condition:getGroupID() ~= nil then
            local conditionSize = caster:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize ~= 0 then
                for i = 0,(conditionSize - 1) do
                    local cond = caster:getTeamUnitCondition():getAllConditionsAt(i);
                    if cond ~= nil and cond:getGroupID() == condition:getGroupID() and not cond:getIsPassive() then
                        targetCond = cond
                    end
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= condition:getPriority() then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    caster:getTeamUnitCondition():removeCondition(targetCond)
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return 0;
                end
            end
        end
        local buff = caster:getTeamUnitCondition():addConditionWithWeight(condID,type,condValue,time,icon,value1);
        ---グループID関係2
        if condition:getGroupID() ~= nil and buff ~= nil then
            buff:setGroupID(condition:getGroupID());
            buff:setPriority(condition:getPriority());
        end
        return 0;
    end

    --自分のHPが◯％〜◯％の時に付与(レベル制限あり)
    if script_id == 322 then
        local parent = caster:getParentTeamUnit();
        local teamUnit = caster;
        if parent ~= nil then
            teamUnit = parent;
        end
        if (teamUnit:getHPPercent() * 100) >= value1 and (teamUnit:getHPPercent() * 100) <= value2 and teamUnit:getLevel() >= value3 then
            return value;
        end
        return 0;
    end

    if script_id == 324 then
        local parent = caster:getParentTeamUnit();
        local teamUnit = caster;
        if parent ~= nil then
            teamUnit = parent;
        end
        if teamUnit:getRaceType() ~= value1 then
            return value;
        end
        return 0;
    end

    --value1のunitIDには付与しない
    if script_id == 326 then
        ---自然回復割合FLG
        if value2 == 1 then
            condition:setValue4(2004349)
        end
        if target:getUnitID() == value1 then
            return 0
        end
        return value
    end

    if script_id == 327 then
        local unit = getAncestorUnit(caster)
        local buff = unit:getTeamUnitCondition():findConditionWithID(value1)
        if buff ~= nil then
            condition:setTime(value2)
        end
        return value
    end

    if script_id == 328 then
        if value2 == 1 and caster == target then
            return 0;
        end
        local buff = caster:getTeamUnitCondition():findConditionWithID(value1)
        if buff == nil then
            return value
        else
            return 0
        end
    end

    if script_id == 329 then
        if caster:getBaseID3() == value1  or caster:getBaseID3() == value2  or caster:getBaseID3() == value3 then
            condition:setTime(value4)
        end
        return value
    end

    if script_id == 330 then
        if target:getBaseID3() == value1  or target:getBaseID3() == value2  or target:getBaseID3() == value3 then
            return value;
        end
        return 0
    end

    if script_id == 331 then
        if target:getBaseID3() == value1  or target:getBaseID3() == value2  or target:getBaseID3() == value3 then
            return value;
        end
        return 0;
    end

    if script_id == 332 then
        condition:setRemoveOnResetState(true);
        return value
    end

    if script_id == 333 and value5== 1 then
        local targetUnit = nil
        if value1 == 0 then
            targetUnit = caster
        else
            targetUnit = target
        end

        local unit = getAncestorUnit(targetUnit)
        local per =  unit:getHPPercent() * 100;
        if value2 == 0 then
            if value3 == 0 then
                if per >= value4 then
                    return value;
                end
            else
                if per > value4 then
                    return value;
                end
            end
        else
            if value3 == 0 then
                if per <= value4 then
                    return value;
                end
            else
                if per < value4 then
                    return value;
                end
            end
        end
        return 0
    end

    if script_id == 334 then
        ---value4がなければそのまま付与
        if value4 == 0 then
            return value
        end
        local skill = target:getActiveBattleSkill();
        if skill == nil then
            return value;
        else
            if value1 == 1 then
                if skill:getSkillType() ~= 1 then
                    return value
                end
            elseif value1 == 2 then
                if skill:getSkillType() ~= 2 then
                    return value
                end
            elseif value1 == 7 then
                if not skill:isBurst2() then
                    return value
                end
            elseif value1 == 8 then
                if not skill:isPhantomBulletAny() then
                    return value
                end
            elseif value1 == 9 then
                if not skill:isBurst3() then
                    return value
                end
            elseif value1 == 10 then
                if not skill:isBurst2() and not skill:isBurst3() then
                    return value
                end
            end
        end

        ---同じ超奥義中に既に同じFLGバフがかけられているか確認
        local beforeBuff = nil;
        beforeBuff = target:getTeamUnitCondition():findConditionWithID(value4)
        if beforeBuff == nil then
            ---FLG用バフを付与
            local buff  = nil
            buff = target:getTeamUnitCondition():addCondition(value4,17,0,99999,0)
            buff:setScriptID(149)
            buff:setValue1(value1)
            ---同じ超奥義中に複数回同じFLGバフがかけられていない、かつ「この」バフが既にかかっている場合
            local conditionSize = target:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize ~= 0 then
                for i = 0,(conditionSize - 1) do
                    local cond = target:getTeamUnitCondition():getAllConditionsAt(i);
                    if cond ~= nil and cond:getID() == condition:getID() and cond:getScriptID() == condition:getScriptID() then
                        buff:setValue2(1)
                    end
                end
            end
        end
        return value
    end

    if script_id == 336 then
        if caster:getFantasyEvolutionType() == value1 then
            return 0
        end
        return value
    end

    if script_id == 339 then
        ---value5と種族によっては付与しない
        if value5 == 0 then
            if caster:getRaceType() ~= value2 then
                return 0
            end
        elseif value5 == 1 then
            if caster:getRaceType() == value2 then
                return 0
            end
        end
        ---value4がなければそのまま付与
        if value4 == 0 then
            return value
        end
        local skill = target:getActiveBattleSkill();
        if skill == nil then
            return value;
        else
            if value1 == 1 then
                if skill:getSkillType() ~= 1 then
                    return value
                end
            elseif value1 == 2 then
                if skill:getSkillType() ~= 2 then
                    return value
                end
            elseif value1 == 7 then
                if not skill:isBurst2() then
                    return value
                end
            elseif value1 == 8 then
                if not skill:isPhantomBulletAny() then
                    return value
                end
            elseif value1 == 9 then
                if not skill:isBurst3() then
                    return value
                end
            elseif value1 == 10 then
                if not skill:isBurst2() and not skill:isBurst3() then
                    return value
                end
            end
        end

        ---同じ超奥義中に既に同じFLGバフがかけられているか確認
        local beforeBuff = nil;
        beforeBuff = target:getTeamUnitCondition():findConditionWithID(value4)
        if beforeBuff == nil then
            ---FLG用バフを付与
            local buff  = nil
            buff = target:getTeamUnitCondition():addCondition(value4,17,0,99999,0)
            buff:setScriptID(149)
            buff:setValue1(value1)
            ---同じ超奥義中に複数回同じFLGバフがかけられていない、かつ「この」バフが既にかかっている場合
            local conditionSize = target:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize ~= 0 then
                for i = 0,(conditionSize - 1) do
                    local cond = target:getTeamUnitCondition():getAllConditionsAt(i);
                    if cond ~= nil and cond:getID() == condition:getID() and cond:getScriptID() == condition:getScriptID() then
                        buff:setValue2(1)
                    end
                end
            end
        end
        return value
    end

    if script_id == 340 then
        ---自然回復割合FLG
        condition:setValue4(2004349)
        local unit = getAncestorUnit(caster)
        if unit:getRaceType() == value1 or unit:getRaceType() == value2 or unit:getRaceType() == value3 then
            if value5 == 1 then
                return 0;
            else
                return value;
            end
        end
        if value5 == 1 then
            return value;
        else
            return 0;
        end
    end

    if script_id == 341 then
        local unit = getAncestorUnit(caster)
        if unit:getRaceType() == value1 or unit:getRaceType() == value2 or unit:getRaceType() == value3 then
            if value5 == 1 then
                return 0;
            else
                return value;
            end
        end
        if value5 == 1 then
            return value;
        else
            return 0;
        end
    end

    if script_id == 342 then
        value = value * summoner.Utility.getUnitHealthRate(caster)
        if value < 1 then value = 1 end
        return value
    end

    if script_id == 344 then
        if  not caster:getIsLeader() then
            return 0
        end

        local value = id_16(target,target,condition,value,value1,value2,value3);
        if value == 0 then
            return 0;
        end
        return value;
    end

    if script_id == 345 and value1 == 1 then
        local targetUnit = caster
        if value3 ~= nil then
            targetUnit = target
        end

        for k,v in pairs(getBadStatusList()) do
            if targetUnit:getTeamUnitCondition():findConditionValue(v) > 0 then
                return 0;
            end
        end
        return value;
    end

    if script_id == 347 then
        ---value5と属性によっては付与しない
        if value5 == 0 then
            if target:getElementType() ~= value2 then
                return 0
            end
        elseif value5 == 1 then
            if target:getElementType() == value2 then
                return 0
            end
        end
        ---value4がなければそのまま付与
        if value4 == 0 then
            return value
        end
        local skill = target:getActiveBattleSkill();
        if skill == nil then
            return value;
        else
            if value1 == 1 then
                if skill:getSkillType() ~= 1 then
                    return value
                end
            elseif value1 == 2 then
                if skill:getSkillType() ~= 2 then
                    return value
                end
            elseif value1 == 7 then
                if not skill:isBurst2() then
                    return value
                end
            elseif value1 == 8 then
                if not skill:isPhantomBulletAny() then
                    return value
                end
            elseif value1 == 9 then
                if not skill:isBurst3() then
                    return value
                end
            elseif value1 == 10 then
                if not skill:isBurst2() and not skill:isBurst3() then
                    return value
                end
            end
        end

        ---同じ超奥義中に既に同じFLGバフがかけられているか確認
        local beforeBuff = nil;
        beforeBuff = target:getTeamUnitCondition():findConditionWithID(value4)
        if beforeBuff == nil then
            ---FLG用バフを付与
            local buff  = nil
            buff = target:getTeamUnitCondition():addCondition(value4,17,0,99999,0)
            buff:setScriptID(149)
            buff:setValue1(value1)
            ---同じ超奥義中に複数回同じFLGバフがかけられていない、かつ「この」バフが既にかかっている場合
            local conditionSize = target:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize ~= 0 then
                for i = 0,(conditionSize - 1) do
                    local cond = target:getTeamUnitCondition():getAllConditionsAt(i);
                    if cond ~= nil and cond:getID() == condition:getID() and cond:getScriptID() == condition:getScriptID() then
                        buff:setValue2(1)
                    end
                end
            end
        end
        return value
    end

    if script_id == 348 then
        local localCaster = getAncestorUnit(caster)
        if value5 == 1 then
            if localCaster:getRaceType() == value1 then
                return 0;
            end
        else
            if localCaster:getRaceType() ~= value1 then
                return 0;
            end
        end
        return value
    end

    if script_id == 353 then
        if value5 ~= 1 then
            if target:getRaceType() == value1 then
                return value;
            end
        else
            if target:getRaceType() ~= value1 then
                return value;
            end
        end
        return 0;
    end

    if script_id == 354 then
        ---自然回復割合FLG
        condition:setValue4(2004349)
        local unit = getAncestorUnit(caster)
        if value5 == 0 then
            if unit:getBaseID3() == value1 or value1 == 0 then
                return value;
            end
        elseif value5 == 1 then
            if unit:getBaseID3() ~= value1 or value1 == 0 then
                return value;
            end
        end
        return 0;
    end

    if script_id == 355 then
        local unit = getAncestorUnit(caster)
        if value5 == 0 then
            if unit:getBaseID3() ~= value2 then
                return 0;
            end
        elseif value5 == 1 then
            if unit:getBaseID3() == value2 then
                return 0;
            end
        end
        local mostFew = 999999999;
        local mostFewUnit = nil;
        local team = megast.Battle:getInstance():getTeam(caster:getisPlayer());
        if megast.Battle:getInstance():isPvp() then
            team = megast.Battle:getInstance():getTeam(caster:getisPvpPlayer());
        end
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getHP() <= mostFew then
                    mostFew = teamUnit:getHP();
                    mostFewUnit = teamUnit;
                end
            end
        end
        local rate = 1 + mostFewUnit:getTeamUnitCondition():findConditionValue(126) / 100 + mostFewUnit:getTeamUnitCondition():findConditionValue(110)/100;--回復量アップ＆旧回復量アップ
        local rate2 = 1 + caster:getTeamUnitCondition():findConditionValue(115) / 100;--回復力アップ
        mostFewUnit:takeHeal(mostFewUnit:getCalcHPMAX() * (value1/100) * rate * rate2);
        return value;
    end

    if script_id == 356 then
        local unit = getAncestorUnit(caster)
        if unit:getBaseID3() ~= value1 then
            return value;
        end
        return 0;
    end

    if script_id == 357 then
        local unit = getAncestorUnit(caster)
        if value5 ~= 1 then
            if unit:getBaseID3() ~= value3 then
                return 0;
            end
        else
            if unit:getBaseID3() == value3 then
                return 0;
            end
        end

        if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 then
            return value;
        else
            return 0;
        end
    end

    if script_id == 359 then
        local unit = getAncestorUnit(caster)
        if unit:getElementType() == value1 then
            if value5 == 0 then
                if (unit:getHPPercent() * 100) >= value2 and (unit:getHPPercent() * 100) <= value3 then
                    return value;
                else
                    return 0;
                end
            elseif value5 == 1 then
                if (unit:getHPPercent() * 100) >= value2 and (unit:getHPPercent() * 100) <= value3 then
                    return 0;
                else
                    return value;
                end
            end
        end
        return 0
    end

    if script_id == 360 then
        if value2 == 1 then
            local raceBox = {}
            for i = 0,7 do
                local teamUnit = caster:getTeam():getTeamUnit(i);
                if teamUnit ~= nil then
                    raceBox[teamUnit:getRaceType()] = true
                end
            end
            local count = 0;
            for i,flg in pairs(raceBox) do
                if flg then
                    count = count + 1
                end
            end
            value = value * count;
            condition:setPriority(value)
        end
        return value
    end

    if script_id == 363 then
        local value = id_363(target,target,condition,value,value1,value2,value3,value4,value5);
        value = id_363(target,target,condition,value,value2,value2,value3,value4,value5);
        value = id_363(target,target,condition,value,value3,value2,value3,value4,value5)
        value = id_363(target,target,condition,value,value4,value2,value3,value4,value5)
        if value == 0 then
            return 0;
        end
        return value;
    end

    if script_id == 365 then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value1);
        if cond ~= nil then
            if megast.Battle:getInstance():isPvp() then
                value = value * 2
            end
            return value;
        end
        return 0;
    end

    if script_id == 370 then
        local target = getAncestorUnit(caster)
        if target:getElementType() ~= value1 then
            return value;
        end
        return 0;
    end

    if script_id == 371 then
        local casterIndex = caster:getIndex();
        local itemSlotIndex = 0;
        local key = "";
        local itemSkill = caster:getActiveItemSkill()
        if itemSkill ~= nil then
            local item = itemSkill:getBattleItem();
            if item ~= nil then
                itemSlotIndex = item:getSlotIndex();
            end
        end

        key = "scriptID"..script_id.."c"..casterIndex.."i"..itemSlotIndex;
        local str = caster:getParameter(key);
        local liveUnit = 0;
        for i=0,7 do
            local targetUnit = caster:getTeam():getTeamUnit(i);
            if targetUnit ~= nil then
                liveUnit = liveUnit + 1;
            end
        end

        if value3 > 0 then
            liveUnit = liveUnit * value3
        end

        if str ~= "" and str ~= nil then
            local cnt = tonumber(str);
            if cnt >= liveUnit or value2 ~= 1 then
                return 0;
            end
            caster:setParameter(key,""..cnt + 1);
            if caster:getElementType() == value1 then
                caster:addSPWithPvpCorrection(value4)
            end
        else
            caster:setParameter(key,""..1);
            if caster:getElementType() == value1 then
                caster:addSPWithPvpCorrection(value4)
            end
        end
        return value;
    end

    if script_id == 372 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 373 then
        local losthp =  caster:getHP() * (value1 / 100);
        if value2 == 1 then
            losthp =  caster:getCalcHPMAX() * (value1 / 100);
        end

        local result = caster:getHP() - losthp;

        ---GB_EXボス用対応
        if megast.Battle:getInstance():isGrandBattleExBoss() then
            local damage = losthp
            if result < 1 then
                local damage = caster:getHP() - 1
            end
            local rate = megast.Battle:getInstance():getGBExBossSPBonusRate()
            local sp = damage / rate
            --summoner.Utility.messageByEnemy(sp.."/"..rate.."/"..damage)
            caster:addSP(sp,false,false,true)
        end

        --計算結果が小数点になる場合、支払い前のHPが１より大きいなら１残す
        if result <= 1 and caster:getHP() > 1 then
            result = 1;
        elseif result < 1 and caster:getHP() <= 1 then --HPが１以下の時に支払いをしようとした時は殺すがHPが負の値になられては困るので０チェック
            result = 0;
        end
        if value3 ~= 0 then
            local buff = caster:getTeamUnitCondition():findConditionWithID(value3);
            if buff == nil then
                caster:setHP(result);
            end
        else
            caster:setHP(result);
        end
        return 0;
    end

    if script_id == 374 then
        if target:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    if script_id == 375 then
        ---最もHPの低いユニットを探す
        local hp = 99999999
        local index = 0
        for i = 0,6 do
            local myTeamUnit = target:getTeam():getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getHP() < hp then
                    index = i
                    hp = myTeamUnit:getHP()
                end
            end
        end
        ---付与対象が最もHPの低いユニットの場合付与
        if target:getIndex() == index then
            return value;
        end
        return 0;
    end

    if script_id == 376 then
        local casterIndex = caster:getIndex();
        local itemSlotIndex = 0;
        local key = "";
        if value4 == 1 then
            itemSlotIndex = 4;
        else
            local itemSkill = caster:getActiveItemSkill()
            if itemSkill ~= nil then
                local item = itemSkill:getBattleItem();
                if item ~= nil then
                    itemSlotIndex = item:getSlotIndex();
                end
            end
        end

        key = "scriptID"..script_id.."c"..casterIndex.."i"..itemSlotIndex;
        local str = caster:getParameter(key);
        local liveUnit = 0;
        for i=0,7 do
            local targetUnit = caster:getTeam():getTeamUnit(i);
            if targetUnit ~= nil then
                liveUnit = liveUnit + 1;
            end
        end

        if value3 > 0 then
            liveUnit = liveUnit * value3
        end

        if str ~= "" and str ~= nil then
            local cnt = tonumber(str);
            if cnt >= liveUnit or value2 ~= 1 then
                return 0;
            end
            caster:setParameter(key,""..cnt + 1);
        else
            caster:setParameter(key,""..1);
        end
        if target:getRaceType() ~= value1 then
            return 0;
        end
        return value;
    end

    if script_id == 377 then
        if value5 ~= 1 then
            if target:getElementType() == value1 then
                return value;
            end
        else
            if target:getElementType() ~= value1 then
                return value;
            end
        end
        return 0;
    end

    if script_id == 378 and value1 == 1 then
        local targetUnit = getAncestorUnit(caster)
        for k,v in pairs(getBadStatusList()) do
            if v ~= value3 and targetUnit:getTeamUnitCondition():findConditionValue(v) > 0 then
                return 0;
            end
        end
        return value;
    end

    if script_id == 379 then
        local myTeam = target:getTeam()
        if megast.Battle:getInstance():isMultiPlay() or megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
            ---レイド、クロスバトル、マルチ処理
            --一番左以外のユニットを対象にする
            local firstFlg = true
            local unitTbl = {}
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i,true)
                if myTeamUnit ~= nil then
                    if firstFlg then
                        firstFlg = false
                        unitTbl[i] = false
                   else
                        unitTbl[i] = true
                    end
                end
            end

            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i,true)
                if myTeamUnit ~= nil then
                    if unitTbl[i] and myTeamUnit:getHP() > 0 and myTeamUnit == target then
                        return value
                    end
                end
            end
        else
            ---通常処理
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    if not myTeamUnit:getIsLeader() then
                        if myTeamUnit == target then
                            return value
                        end
                    end
                end
            end
        end
        return 0
    end

    if script_id == 380 then
        local unit = getAncestorUnit(caster)
        if unit:getElementType() == value1 then
            return value;
        end
        return 0;
    end

    ---381~386
    if script_id >= 381 and script_id <= 386 then
        local typeNum = script_id % 10
        local parent = caster:getParentTeamUnit();
        if parent ~= nil then
            caster = parent;
        end
        ---テーブルを用意
        local itemTable = {}
        if typeNum == 6 then
            itemTable = {
                [value1] = false,
                [value2] = false,
                [value3] = false,
                [value4] = false
            }
        else
            itemTable = {
                [value1] = false,
                [value2] = false,
                [value3] = false,
                [value4] = false,
                [value5] = false
            }
        end
        ---value1~4(1~5)の装備があるか確認
        for i = 0,6 do
            local myTeamUnit = caster:getTeam():getTeamUnit(i)
            if myTeamUnit ~= nil then
                for n = 0,2 do
                    local item = myTeamUnit:getItemSkill(n)
                    if item ~= nil then
                        local baseItemNo = item:getBattleItem():getBaseItemNo()
                        print("itemNo"..baseItemNo)
                        if itemTable[baseItemNo] ~= nil then
                            itemTable[baseItemNo] = true;
                        end
                    end
                end
            end
        end
        ---全ての装備があった場合のみ付与
        for k,v in pairs(itemTable) do
            if not v then
                return 0;
            end
        end
        ---属性制限
        if value5 ~= 0 then
            local element = 0
            if typeNum == 6 then
                element = value5
            else
                element = typeNum
            end
            if elementType(target,value,element) == 0 then
                return 0;
            end
        end
        return value;
    end

    if script_id == 387 then
        local unit = getAncestorUnit(caster)
        if value3 == 1 then
            ---value1族,value2属性以外
            if raceType(unit,value,value1) == 0 then
                return 0;
            end
            if elementType(unit,value,value2) ~= 0 then
                return 0;
            end
            return value;
        elseif value3 == 2 then
            ---value1族以外,value2属性
            if raceType(unit,value,value1) ~= 0 then
                return 0;
            end
            if elementType(unit,value,value2) == 0 then
                return 0;
            end
            return value;
        elseif value3 == 3 then
            ---value1族以外,value2属性以外
            if raceType(unit,value,value1) ~= 0 then
                return 0;
            end
            if elementType(unit,value,value2) ~= 0 then
                return 0;
            end
            return value;
        end
        ---value1族,value2属性
        if raceType(unit,value,value1) == 0 then
            return 0;
        end
        if elementType(unit,value,value2) == 0 then
            return 0;
        end
        return value;
    end

    if script_id == 388 then--出血専用
        local targetUnit = caster
        if value2 ~= 0 then
            targetUnit = target
        end

        local buff = targetUnit:getTeamUnitCondition():findConditionWithGroupID(21011)
        if buff ~= nil and buff:getValue5() == value1 then
            return value
        end
        return 0
    end

    if script_id == 390 then
        local floor = megast.Battle:getInstance():getCurrentGrandBattleFloor()
        if value2 == 0 then
            value2 = 1
        end
        value = value + (floor * value1 / value2)
        return value
    end

    if script_id == 392 then
        ---特殊補正用処理
        local c = condition
        local team = caster:getTeam()
        local condValue = condition:getValue()
        local ID = 0
        local GroupID = c:getGroupID()
        ---グループIDが0の場合は重複しないようにする
        if GroupID == 0 then
            ID = 39200000 + (c:getConditionTypeAsInt()*100) + (value1*10) + value3
        end
        ---対象に付与
        if value2 <= 0 then
            ---属性判定
            if value1 >= 1 and value1 <= 5 then
                if c:getConditionTypeAsInt() == 17 or c:getConditionTypeAsInt() == 21 then
                    condition:setScriptID(70);
                    condition:setValue1(value1);
                end
            end
            ---物理魔法判定
            if value1 >= 6 and value1 <= 7 then
                condition:setScriptID(value1 -4);
                condition:setThumbnailID(value1 + 15)
            end
            return value;
        end
        ---回復用処理
        if c:getConditionTypeAsInt() == 7 then
            local rate = 1
            local conditionSize = caster:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize == 0 then
                return
            end
            for i = 0,(conditionSize - 1) do
                local cond = caster:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getConditionTypeAsInt() == 115 then
                    rate = rate + (cond:getValue() / 100)
                end
            end
            condValue = condValue * rate
        end
        ---自身に付与 or 全体付与
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                ---自身に付与 or 全体付与 判定
                if (value2 == 1 and teamUnit == caster) or value2 == 2 then
                    local buff = nil
                    ---属性制限
                    local flg = true
                    ---17と21をのぞいてvalue1に属性制限がかかっている場合
                    if c:getConditionTypeAsInt() ~= 17 and c:getConditionTypeAsInt() ~= 21 and value1 >= 1 and value1 <= 5 then
                        ---状態異常回避用
                        if teamUnit:getElementType() ~= value1 then
                            flg = false
                        end
                    end
                    ---種族制限
                    if value3 >= 1 then
                        if teamUnit:getRaceType() ~= value3 then
                            flg = false
                        end
                    end
                    if flg then
                        local addConditionFLG = true;
                        ---奥義ゲージアップ
                        if c:getConditionTypeAsInt() == 8 then
                            teamUnit:addSPWithPvpCorrection(condValue);
                            addConditionFLG = false
                        end
                        ---状態異常回復
                        if c:getConditionTypeAsInt() >= 43 and c:getConditionTypeAsInt() <= 51 then
                            local badCond = teamUnit:getTeamUnitCondition():findConditionWithType(c:getConditionTypeAsInt() + 46);
                            if badCond ~= nil then
                                teamUnit:getTeamUnitCondition():removeCondition(badCond);
                            end
                            addConditionFLG = false
                        end
                        ---即時回復
                        if c:getConditionTypeAsInt() == 3 then
                            local rate = (100 + teamUnit:getTeamUnitCondition():findConditionValue(110)) / 100;
                            teamUnit:takeHeal(condValue * rate,caster,c:getItemTypeAsInt())
                            addConditionFLG = false
                        end
                        if addConditionFLG then
                            if (c:getConditionTypeAsInt() >= 101 and c:getConditionTypeAsInt() <= 109) or (c:getConditionTypeAsInt() >= 52 and c:getConditionTypeAsInt() <= 60) then
                                ---二つ目の付与かどうかFLGを使い調査
                                local condID = c:getConditionTypeAsInt()
                                if c:getConditionTypeAsInt() >= 101 and c:getConditionTypeAsInt() <= 109 then
                                    condID = c:getConditionTypeAsInt() - 49
                                end
                                local FLG_ID = 39200000 + (condID*100) + (value1*10) + value3
                                local findTarget = teamUnit:getTeamUnitCondition():findConditionWithID(FLG_ID);
                                ---同じFLG用バフがある場合
                                if findTarget ~= nil then
                                    ---FLGは削除
                                    teamUnit:getTeamUnitCondition():removeCondition(findTarget);
                                    ---上書きしない付与
                                    buff = teamUnit:getTeamUnitCondition():addCondition(ID,c:getConditionTypeAsInt(),condValue,c:getTime(),c:getThumbnailID());
                                    buff:setGroupID(c:getGroupID());
                                    buff:setPriority(c:getPriority());
                                else
                                    ---通常の付与
                                    buff = teamUnit:getTeamUnitCondition():addConditionWithGroupID(ID,c:getConditionTypeAsInt(),condValue,c:getTime(),c:getThumbnailID(),c:getGroupID(),c:getPriority());
                                    ---付与に成功した場合
                                    if buff:getTeamUnitCondition() ~= nil then
                                        teamUnit:getTeamUnitCondition():addCondition(FLG_ID,0,0,0,0);
                                    end
                                end
                            elseif condition:getAnimationID() > 0 then
                                buff = teamUnit:getTeamUnitCondition():addConditionWithGroupIDWeight(ID,c:getConditionTypeAsInt(),condValue,c:getTime(),c:getThumbnailID(),c:getGroupID(),c:getPriority(),100,nil,c:getAnimationID());
                            else
                                buff = teamUnit:getTeamUnitCondition():addConditionWithGroupID(ID,c:getConditionTypeAsInt(),condValue,c:getTime(),c:getThumbnailID(),c:getGroupID(),c:getPriority());
                            end
                        end
                    end
                    if buff ~= nil then
                        buff:setItemType(c:getItemTypeAsInt())
                        buff:setCasterByLua(caster)
                        if megast.Battle:getInstance():isPvp() or caster:getisPlayer() then
                            buff:setIsCasterPlayer(true)
                        end
                        ---属性判定
                        if value1 >= 1 and value1 <= 5 then
                            if c:getConditionTypeAsInt() == 17 or c:getConditionTypeAsInt() == 21 then
                                buff:setScriptID(70);
                                buff:setValue1(value1);
                            end
                            --summoner.Utility.messageByEnemy("属性"..value1)
                        end
                        ---物理魔法判定
                        if value1 >= 6 and value1 <= 7 then
                            buff:setScriptID(value1 -4);
                            buff:setThumbnailID(value1 + 15)
                            --summoner.Utility.messageByEnemy("物理魔法"..value1)
                        end
                    end
                end
            end
        end
        megast.Battle:getInstance():updateConditionView()
        return 0;
    end

    if script_id == 393 then
        if caster:getElementType() ~= value1 and value1 ~= 0 and value1 ~= nil then
            return 0;
        end
        local casterIndex = caster:getIndex();
        local itemSlotIndex = 0;
        local key = "";
        local itemSkill = caster:getActiveItemSkill()
        if itemSkill ~= nil then
            local item = itemSkill:getBattleItem();
            if item ~= nil then
                itemSlotIndex = item:getSlotIndex();
            end
        end
        key = "scriptID"..script_id.."c"..casterIndex.."i"..itemSlotIndex;
        local str = caster:getParameter(key);

        local ID = 39300 + (casterIndex * 10) + itemSlotIndex
        local buff = caster:getTeamUnitCondition():addCondition(ID,238,0,99999,0);
        buff:setScriptID(393)
        buff:setValue1(itemSlotIndex)

        ---指定の属性でない場合は付与しない
        if value5 > 0 then
            if target:getElementType() ~= value5 then
                return 0;
            end
        end

        if str ~= "" and str ~= nil and str ~= "0" then
            --summoner.Utility.messageByEnemy(key.."初回 以降"..str)
            if value4 == 0 then
                return 0;
            else
                return value;
            end
        else
            --summoner.Utility.messageByEnemy(key.."初回 付与"..str)
            if value4 == 0 then
                return value;
            else
                return 0;
            end
        end
    end

    --自分のHPが◯％〜◯％の時に付与(レベル制限あり)
    if script_id == 394 then
        local parent = caster:getParentTeamUnit();
        local teamUnit = caster;
        if parent ~= nil then
            teamUnit = parent;
        end
        if (teamUnit:getHPPercent() * 100) > value1 and (teamUnit:getHPPercent() * 100) < value2 and teamUnit:getLevel() >= value3 then
            return value;
        end
        return 0;
    end

    --最大HPのvalue%を効果量にして付与
    if script_id == 396 then
        local parent = caster:getParentTeamUnit();
        local teamUnit = caster;
        if parent ~= nil then
            teamUnit = parent;
        end
        value = teamUnit:getCalcHPMAX() * value * 0.01
        value = math.floor(value)
        return value
    end

    ---value1かvalue2かvalue3状態の時(value5が1の場合反転)
    if script_id == 397 then
        local cond1 = nil
        local cond2 = nil
        local cond3 = nil
        if value1 ~= 0 then
            cond1 = target:getTeamUnitCondition():findConditionWithType(value1);
        end
        if value2 ~= 0 then
            cond2 = target:getTeamUnitCondition():findConditionWithType(value2);
        end
        if value3 ~= 0 then
            cond3 = target:getTeamUnitCondition():findConditionWithType(value3);
        end
        if cond1 ~= nil or cond2 ~= nil or cond3 ~= nil then
            if value5 == 0 then
                return value
            else
                return 0;
            end
        else
            if value5 == 0 then
                return 0
            else
                return value
            end
        end
        return 0;
    end

    if script_id == 399 then
        local leaderUnitIndex = nil
        local myTeam = target:getTeam()
        ---マルチ処理
        if megast.Battle:getInstance():isMultiPlay() then
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i,true)
                if myTeamUnit ~= nil then
                    if myTeamUnit:getHP() > 0 and myTeamUnit:getIndex() == 0 then
                        leaderUnitIndex = myTeamUnit:getIndex()
                    end
                end
            end
        else
            ---通常処理
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    if myTeamUnit:getIsLeader() then
                        leaderUnitIndex = myTeamUnit:getIndex()
                    end
                end
            end
        end

        local casterIndex = caster:getIndex();
        local itemSlotIndex = 0;
        local key = "";
        local itemSkill = caster:getActiveItemSkill()
        if itemSkill ~= nil then
            local item = itemSkill:getBattleItem();
            if item ~= nil then
                itemSlotIndex = item:getSlotIndex();
            end
        end

        key = "scriptID"..script_id.."c"..casterIndex.."i"..itemSlotIndex;
        local str = caster:getParameter(key);
        local liveUnit = 0;
        for i=0,7 do
            local targetUnit = caster:getTeam():getTeamUnit(i);
            if targetUnit ~= nil then
                liveUnit = liveUnit + 1;
            end
        end

        if value1 > 0 then
            liveUnit = liveUnit * value1
        end

        if leaderUnitIndex == nil then
            return 0
        end

        if str ~= "" and str ~= nil then
            local cnt = tonumber(str);
            if cnt >= liveUnit or value1 ~= 1 then
                return 0;
            end

            caster:setParameter(key,""..cnt + 1);
        else
            caster:setParameter(key,""..1);
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    if myTeamUnit:getIndex() == leaderUnitIndex then
                        if value2 ~= 0  then
                            myTeamUnit:addSPWithPvpCorrection(value2)
                        else
                            return value;
                        end
                    end
                end
            end
        end
        return 0;
    end

    if script_id == 400 then
        if caster:getFantasyEvolutionType() == value1 then
            return 0
        else
            condition:setTime(value2)
            return value;
        end
        return 0;
    end

    if script_id == 401 then
        if value2 == 1 then
            if caster:getBurstPoint() <= value1 then
                return value;
            end
            return 0;
        end
        return value;
    end

    if script_id == 403 then
        condition:setIsAddTimeShift(false);
        return value;
    end

    if script_id == 404 then
        local buff = nil
        --local c = condition
        local unitTeam = caster:getTeam()
        ---相手チームを取得
        local targetTeam = nil
        if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(true)
        else
            targetTeam = megast.Battle:getInstance():getTeam(false)
        end
        ---相手チーム全体に付与
        for i = 0,7 do
            local teamUnit = targetTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                --[[
                buff = teamUnit:getTeamUnitCondition():addConditionWithGroupID(c:getID(),c:getConditionTypeAsInt(),c:getValue(),c:getTime(),c:getThumbnailID(),c:getGroupID(),c:getPriority());
                buff:setScriptID(c:getScriptID())
                buff:setValue1(c:getValue1())
                buff:setValue2(c:getValue2())
                buff:setValue3(c:getValue3())
                buff:setValue4(c:getValue4())
                buff:setValue5(c:getValue5())
                ]]--
                local floor = megast.Battle:getInstance():getCurrentGrandBattleFloor();
                local condValue = value2 + (floor * value5/100)
                buff = teamUnit:getTeamUnitCondition():addConditionWithGroupID(0,value1,condValue,99999,value3,value4,value2);
            end
        end
        return 0;
    end

    if script_id == 406 then
        return value;
    end

    if script_id == 410 then
        if value2 >= 1 then
            local count = 0;
            for i = 0,7 do
                local teamUnit = caster:getTeam():getTeamUnit(i);
                if teamUnit ~= nil then
                    if teamUnit:getElementType() == value1 then
                        count = count + 1;
                    end
                end
            end
            value = value * count;
            if value2 >= 2 then
                condition:setPriority(math.abs(value))
            end
            return value;
        end
    end

    if script_id == 414 then
        if (target:getHPPercent() * 100) >= value1 and (target:getHPPercent() * 100) <= value2 then
            return value;
        end
        return 0;
    end

    if script_id == 415 and value1 == 1 then
        local targetUnit = getAncestorUnit(caster)
        for k,v in pairs(getBadStatusList()) do
            if v ~= value3 and targetUnit:getTeamUnitCondition():findConditionValue(v) > 0 then
                return value;
            end
        end
        return 0;
    end

    --自分以外対象
    if script_id == 416 then
        if caster == target then
            return 0;
        end
        if value1 ~= 0 then
            if target:getRaceType() ~= value1 then
                return 0;
            end
        end
        if value2 ~= 0 then
            if target:getElementType() ~= value2 then
                return 0;
            end
        end
        return value
    end

    --状態異常回復 + 回復した場合奥義ゲージアップ
    if script_id == 417 then
        local cond = target:getTeamUnitCondition():findConditionWithType(value1)
        if cond then
            target:getTeamUnitCondition():removeCondition(cond);
            target:addSPWithPvpCorrection(value2)
        end
        return value
    end

    --アビリティ全体化の付与対象判定
    if script_id == 431 then
        -- 否定かどうか
        if value3 == 0 then
            -- 種族
            if value1 ~= 0 and target:getRaceType() ~= value1 then
                return 0;
            end
            -- 属性
            if value2 ~= 0 and target:getElementType() ~= value2 then
                return 0;
            end
        else
            -- 〜でない時
            -- 種族
            if value1 ~= 0 and target:getRaceType() == value1 then
                return 0;
            end
            -- 属性
            if value2 ~= 0 and target:getElementType() == value2 then
                return 0;
            end
        end
        return value;
    end

    if script_id == 432 then
        condition:setRemoveOnResetState(true);
    end

    if script_id == 434 then
        local number = 1;
        --summoner.Utility.messageByEnemy("GroupID"..condition:getGroupID())
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(condition:getGroupID());
        if cond ~= nil then
            number = cond:getNumber() + 1;
            if number > value2 then
                number = value2;
            end
            --summoner.Utility.messageByEnemy("number"..number)
        end
        local condValue = value * number

        condition:setMaxConditionIconNumber(value2);
        condition:setNumber(number);
        condition:setValue(condValue);
        condition:setPriority(condValue);
        megast.Battle:getInstance():updateConditionView();
        --summoner.Utility.messageByEnemy("condValue"..condValue)
        return condValue;
    end

    if script_id == 442 then
        if target:getElementType() == value3 or value3 == 0 then
            local time = BattleControl:get():getTime()
            if value2 == 0 then
                -- 以下
                if time <= value1 then
                    return value;
                end
            elseif value2 == 1 then
                -- 以上
                if time >= value1 then
                    return value;
                end
            elseif value2 == 2 then
                -- 未満
                if time < value1 then
                    return value;
                end
            else
                -- より上
                if time > value1 then
                    return value;
                end
            end
        end
        return 0;
    end

    if script_id == 444 then
        if caster:getBaseID3() == value1  then
            return value;
        end
        return 0;
    end

    if script_id == 446 then
        -- 装備経由なのでご先祖様をたどる
        local unit = getAncestorUnit(caster)
        if unit:getBaseID3() == value1 then
            value = value * value3
        end
        return value;
    end

    if script_id == 447 then
        ---キーを設定
        local param = ""
        local number = condition:getConditionTypeAsInt() - 155
        if number >= 1 and number <= 5 then
            if number == 5 then
                number = 4
            end
            param = "407_WeaponType"..number
        end

        ---クールタイム中か確認
        local isCoolTime = false
        ---超奥義の場合は判定しない
        if number == 1 then
            isCoolTime = true;
        else
            for i = 0, 2 do
                local battleSkill = caster:getItemSkill(i)
                if battleSkill ~= nil then
                    local buffID = condition:getConditionTypeAsInt() - 155
                    if battleSkill:getBattleItem():getItemTypeAsInt() == buffID then
                        if battleSkill:getCoolTimer() > 0 then
                            isCoolTime = true;
                        end
                    end
                end
            end
        end
        ---クールタイム中の装備が無い場合は動かさない
        if not isCoolTime then
            return 0
        end

        ---発動回数を取得,効果量設定
        local buffLimit = {
            [1] = 0,
            [3] = 2,
            [4] = 1
        }
        local count = 0
        if caster:getParameter(param) ~= "" then
            count = tonumber(caster:getParameter(param))
        end
        if number ~= 1 then
            if count < buffLimit[number] then
                count = count + 1
                caster:setParameter(param,""..count)
            else
                value = 0
            end
        elseif number == 1 then
            count = count + 1
            caster:setParameter(param,""..count)
            if count % 2 ~= 1 then
                value = 0
            end
        end
        ---バフアイコン更新
        local buffIcon = {
            [1] = 232,
            [3] = 233,
            [4] = 234
        }
        if caster:getEvolutionStage() == 1 then
            buffIcon[1] = 0
        end
        for i,v in ipairs({4,3,1}) do
            local paramCount = 0
            local paramStr = "407_WeaponType"..v
            local paramID = 4470 + v
            if caster:getParameter(paramStr) ~= "" then
                paramCount = tonumber(caster:getParameter(paramStr))
            end
            if buffLimit[v] ~= 0 then
                if paramCount < buffLimit[v] then
                    caster:getTeamUnitCondition():addCondition(paramID,0,0,99999,buffIcon[v]);
                else
                    caster:getTeamUnitCondition():removeConditionWithID(paramID)
                end
            else
                if paramCount % 2 == 1 then
                    caster:getTeamUnitCondition():removeConditionWithID(paramID)
                else
                    caster:getTeamUnitCondition():addCondition(paramID,0,0,99999,buffIcon[v]);
                end
            end
        end
        return value;
    end

    if script_id == 449 then
        if value1 ~= 0 then
            local buff = caster:getTeamUnitCondition():findConditionWithID(value1);
            if buff ~= nil then
                return 0;
            end
        end
        return value;
    end

    if script_id == 450 then
        if value2 == 1 then
            local count = 0;
            for i = 0,7 do
                local teamUnit = caster:getTeam():getTeamUnit(i);
                if teamUnit ~= nil then
                    if teamUnit:getRaceType() == value1 then
                        count = count + 1;
                    end
                end
            end
            value = value * count;
            if value3 == 1 then
                condition:setPriority(setDisPriority(value, condition))
            end
            return value;
        end
    end

    -- 初回時のみ
    if script_id == 452 then
        local casterIndex = caster:getIndex();
        local itemSlotIndex = 0;
        local key = "";
        local itemSkill = caster:getActiveItemSkill()
        if itemSkill ~= nil then
            local item = itemSkill:getBattleItem();
            if item ~= nil then
                itemSlotIndex = item:getSlotIndex();
            end
        end

        key = "scriptID"..script_id.."c"..casterIndex.."i"..itemSlotIndex;
        local str = caster:getParameter(key);
        local liveUnit = 0;
        for i=0,7 do
            local targetUnit = caster:getTeam():getTeamUnit(i);
            if targetUnit ~= nil then
                liveUnit = liveUnit + 1;
            end
        end

        if value1 > 0 then
            liveUnit = liveUnit * value1
        end

        if str ~= "" and str ~= nil then
            local cnt = tonumber(str);
            if cnt >= liveUnit or value2 ~= 1 then
                return 0;
            end
            caster:setParameter(key,""..cnt + 1);
        else
            caster:setParameter(key,""..1);
        end
        return value;
    end

    -- 自身の次に使用する奥義系統の付与重複回数判定
    if script_id == 453 then
        local number = 1;
        --summoner.Utility.messageByEnemy("GroupID"..condition:getGroupID())
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(condition:getGroupID());
        if cond ~= nil then
            number = cond:getNumber() + 1;
            if number > value2 then
                number = value2;
            end
            --summoner.Utility.messageByEnemy("number"..number)
        end
        local condValue = value * number

        condition:setMaxConditionIconNumber(value2);
        condition:setNumber(number);
        condition:setValue(condValue);
        condition:setPriority(condValue);
        megast.Battle:getInstance():updateConditionView();
        --summoner.Utility.messageByEnemy("condValue"..condValue)
        return condValue;
    end

    if script_id == 454 then
        local unit = getAncestorUnit(caster);
        if value1 == 1 then
            unit = getAncestorUnit(target);
        end

        if value4 == 0 then
            if unit:getHP() >= value2 and unit:getHP() <= value3 then
                return elementType(unit,value,value5);
            else
                return 0;
            end
        elseif value4 == 1 then
            if unit:getHP() >= value2 and unit:getHP() <= value3 then
                return 0;
            else
                return elementType(unit,value,value5);
            end
        end
        return 0;
    end

    if script_id == 455 then
        local param = caster:getParameter(script_id.."count")
        if param == "" then
            param = "0"
        end
        local count = tonumber(param)
        if count < value1 then
            count = count + 1
            caster:setParameter(script_id.."count",""..count)
            return value
        end
        return 0
    end

    if script_id == 456 then
        local per = target:getHPPercent() * 100;
        if per < value1 then
            return value
        end
        return 0;
    end

    --対象者のHPが◯％〜◯％の時に付与
    if script_id == 457 then
        if (target:getHPPercent() * 100) >= value1 and (target:getHPPercent() * 100) <= value2 then
            return value;
        end
        return 0;
    end

    --自分のHPが◯％〜◯％の時に付与
    if script_id == 458 then
        local FLG = false
        if (caster:getHPPercent() * 100) >= value1 and (caster:getHPPercent() * 100) <= value2 then
            FLG = true
        end
        if FLG then
            for i = 0, 2 do
                local battleSkill = caster:getItemSkill(i)
                if battleSkill ~= nil then
                    local buffID = condition:getConditionTypeAsInt() - 155
                    if battleSkill:getBattleItem():getItemTypeAsInt() == buffID then
                        if battleSkill:getCoolTimer() > 0 then
                            battleSkill:setCoolTimer(value/100)
                        end
                    end
                end
            end
        end
        return 0;
    end

    if script_id == 459 then

        local casterIndex = condition:getCaster():getIndex();
        local itemSlotIndex = 0;
        local key = "";

        local itemSkill = condition:getCaster():getActiveItemSkill()
        if itemSkill ~= nil then
            local item = itemSkill:getBattleItem();
            if item ~= nil then
                itemSlotIndex = item:getSlotIndex();
            end
        end

        key = "scriptID"..script_id.."c"..casterIndex.."i"..itemSlotIndex;
        local str = condition:getCaster():getParameter(key);

        local ID = 45900 + (casterIndex * 10) + itemSlotIndex
        local buff = condition:getCaster():getTeamUnitCondition():addCondition(ID,238,0,99999,0);
        buff:setScriptID(459)
        buff:setValue1(itemSlotIndex)

        if str ~= "" and str ~= nil and str ~= "0" then
            --summoner.Utility.messageByEnemy(key.."初回 以降"..str)
            if value4 == 0 then
                return 0;
            else
                return value;
            end
        else
            --summoner.Utility.messageByEnemy(key.."初回 付与"..str)
            if value4 == 0 then
                return value;
            else
                return 0;
            end
        end

        return value;
    end

    if script_id == 461 then
        local buff = nil
        if value2 > 0 then
            buff = target:getTeamUnitCondition():findConditionWithID(value2);
        end
        if buff ~= nil then
            return 0
        elseif megast.Battle:getInstance():isPvp() then
            return 0
        else
            if value1 == 1 then
                value = value + target:getLuckLevel();
            end
            return value
        end
    end

    if script_id == 462 then
        local waveNum = megast.Battle:getInstance():getWaveNum()
        if waveNum > value1 then
            waveNum = value1
        end
        value = value * waveNum;
        condition:setMaxConditionIconNumber(value1)
        condition:setPriority(value);
        condition:setNumber(waveNum);
        return value;
    end

    if script_id == 465 then
        local unit = getAncestorUnit(caster)
        local targetUnit = getAncestorUnit(target)
        if value5 == 1 then
            unit = getAncestorUnit(target)
            targetUnit = getAncestorUnit(caster)
        end

        ---属性付与判定
        if value4 ~= 0 then
            if value4 == 6 then
                if targetUnit:getElementType() ~= 0 then
                    return 0
                end
            elseif targetUnit:getElementType() ~= value4 then
                return 0
            end
        end

        if value1 == 0 then
            return value
        end
        ---バフのID
        local skillNum = math.floor(condition:getID() / 10000000)
        local count = 0
        ---装備位置、またはスキルの種類
        local slotIndex = 40000
        if skillNum == 30 then
            ---装備の場合
            local item = nil
            local itemSkill = unit:getActiveItemSkill()
            if itemSkill ~= nil then
                item = itemSkill:getBattleItem();
            end
            if item ~= nil then
                slotIndex = item:getSlotIndex() * 10000
            end
        else
            ---装備以外の場合
            local skill = unit:getActiveBattleSkill();
            if skill ~= nil then
                slotIndex = slotIndex + (skill:getIndex() * 10000)
            end
        end
        ---ユニットの位置
        local unitIndex = unit:getIndex() * 100000
        if value3 == 0 then
            slotIndex = 0
            unitIndex = 0
        end
        local min = (2861 + slotIndex + unitIndex) * -1
        local max = (2860 + value1 + slotIndex + unitIndex) * -1
        for i = min,max,-1 do
            ---フラグの個数だけカウント
            count = count + 1
            local buff = targetUnit:getTeamUnitCondition():findConditionWithID(i);
            if buff == nil then
                ---フラグ付与
                if value3 ~= 2 then
                    targetUnit:getTeamUnitCondition():addCondition(i,0,0,99999,0)
                end
                break
            end
        end
        ---番号など
        condition:setMaxConditionIconNumber(value1);
        condition:setNumber(count);
        if condition:getGroupID() ~= 0 then
            local priority = value
            if priority < 0 then
                priority = priority * -1
            end
            condition:setPriority(priority * count)
        end
        megast.Battle:getInstance():updateConditionView();
        return value * count;
    end

    if script_id == 466 then
        if megast.Battle:getInstance():isPvp() then
            return 0
        end
        for i = 0,6 do
            local myTeamUnit = caster:getTeam():getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getBaseID3() == value1 then
                    condition:setIsPassive(true)
                    return value;
                end
            end
        end
        return 0;
    end

    if script_id == 467 then
        local boss = megast.Battle:getInstance():getTeam(false):getBoss()
        ---ボスがいない場合
        if boss == nil then
            return 0
        end
        ---ボスが大型でない場合
        if boss:getSize() ~= 3 then
            return 0
        end
        ---既に一度バフが付与されている場合
        local cond = boss:getTeamUnitCondition():findConditionWithType(condition:getConditionTypeAsInt());
        if cond ~= nil then
            return 0
        end
        ---処理
        if megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
            if condition:getConditionTypeAsInt() == 172 then
                return value
            else
                return 0
            end
        else
            if condition:getConditionTypeAsInt() == 173 then
                return value
            else
                return 0
            end
        end
        return value;
    end

    if script_id == 469 then
        local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
        if boss == nil then
            return 0;
        end

        if value1 == 2 then  --ボスにのみ付与
            if target:getTeam():getBoss() ~= target then
                return 0;
            end
        end

        local per =  boss:getHPPercent() * 100;
        if value2 == 0 then
            if per <= value3 and per >= value4 then
                return value;
            end
        elseif value2 == 1 then
            if per < value3 and per > value4 then
                return value;
            end
        elseif value2 == 2 then
            if per < value3 and per >= value4 then
                return value;
            end
        elseif value2 == 3 then
            if per <= value3 and per > value4 then
                return value;
            end
        end
        return 0;
    end

    if script_id == 470 then

        local casterIndex = condition:getCaster():getIndex();
        local itemSlotIndex = 0;
        local key = "";
        local absvalue = math.abs(value)
        local absvalue3 = math.abs(value3)
        local FLG = true
        local type = condition:getConditionTypeAsInt()
        local time = condition:getTime()

        local itemSkill = condition:getCaster():getActiveItemSkill()
        if itemSkill ~= nil then
            local item = itemSkill:getBattleItem();
            if item ~= nil then
                itemSlotIndex = item:getSlotIndex();
            end
        end

        key = "scriptID"..script_id.."c"..casterIndex.."i"..itemSlotIndex;
        local str = condition:getCaster():getParameter(key);
        if str ~= "" and str ~= nil and str ~= "0" then
            if type == 10 then
                condition:setPriority(absvalue * time)
            else
                condition:setPriority(absvalue)
            end
        else
            if type == 10 then
                condition:setPriority((absvalue + absvalue3) * time)
            else
                condition:setPriority(absvalue + absvalue3)
            end
        end

        local cond = target:getTeamUnitCondition():findConditionWithGroupID(condition:getGroupID());
        if cond ~= nil then
            if cond:getPriority() > condition:getPriority() then
                FLG = false
            end
        end

        local ID = 47000 + (casterIndex * 10) + itemSlotIndex
        local buff = condition:getCaster():getTeamUnitCondition():addCondition(ID,238,0,99999,0);
        buff:setScriptID(470)
        buff:setValue1(itemSlotIndex)

        if str ~= "" and str ~= nil and str ~= "0" then
            --summoner.Utility.messageByEnemy(key.."初回 以降"..str.. " " .. value.. " " .. value3.. " " .. value4)
            -- プラスにして返すかマイナスにして返すか
            if FLG then
                if value4 == 0 then
                    return absvalue
                else
                    return absvalue * (-1)
                end
            end
        else
            --summoner.Utility.messageByEnemy(key.."初回 付与"..str.. " " .. value.. " " .. value3.. " " .. value4)
            -- 初回はvalue3と加算してプラスにして返すかマイナスにして返すか
            if FLG then
                if value4 == 0 then
                    return (absvalue + absvalue3)
                else
                    return (absvalue + absvalue3) * (-1)
                end
            end
        end

        return 0;
    end

    if script_id == 471 then
        local myTeam = target:getTeam();
        if megast.Battle:getInstance():isMultiPlay() or megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
            ---レイド、クロスバトル、マルチ処理
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i,true);
                if myTeamUnit ~= nil then
                    if myTeamUnit:getHP() > 0 and myTeamUnit == target then
                        return value;
                    end
                    return 0;
                end
            end
        else
            ---通常処理
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i);
                if myTeamUnit ~= nil then
                    if myTeamUnit:getIsLeader() then
                        if myTeamUnit == target then
                            return value;
                        end
                        return 0;
                    end
                end
            end
        end
        return 0;
    end

    if script_id == 472 then
        if value1 == 1 then
            if not condition:getCaster():getIsLeader() then
                return value;
            end
        else
            if condition:getCaster():getIsLeader() then
                return value;
            end
        end
        return 0;
    end

    if script_id == 473 then
        if value4 == 0 then
            local unit = getAncestorUnit(caster);
            if value3 == 0 then
                local buffFlg = unit:getTeamUnitCondition():findConditionWithID(47301);
                if buffFlg ~= nil then
                    condition:setThumbnailID(0);
                    megast.Battle:getInstance():updateConditionView();
                    return 0;
                end
            else
                --死亡時処理用バフタイプ：240付与
                unit:getTeamUnitCondition():addCondition(47302,240,0,999999,0);
                local deadFlg = unit:getTeamUnitCondition():findConditionWithID(47302);
                if deadFlg ~= nil then
                    deadFlg:setScriptID(473);
                    deadFlg:setValue3(value3);
                    deadFlg:setValue4(value1);
                end

                --付与したフラグ用バフを見て判定
                local key = "scriptID:473".."c"..unit:getIndex().."Flg";
                if unit:getParameter(key) == "True" then
                    condition:setThumbnailID(0);
                    megast.Battle:getInstance():updateConditionView();
                    return 0;
                end

                --瀕死判定
                if summoner.Utility.getUnitHealthRate(unit) < 0.4 then
                    if value3 == 0 then
                        unit:getTeamUnitCondition():addCondition(47301,0,0,999999,0);
                    else
                        local key = "scriptID:473".."c"..unit:getIndex().."Flg";
                        if unit:getParameter(key) == "" then
                            unit:setParameter(key,"True");
                        end
                    end
                    return 0;
                end
            end
        end
        return value;
    end

    if script_id == 474 then
        return 1
    end

    if script_id == 476 then
        if value1 == 0 then
            return value
        end
        ---バフのID
        local skillNum = math.floor(condition:getID() / 10000000)
        local count = 0
        ---装備位置、またはスキルの種類
        local slotIndex = 40000
        if skillNum == 30 then
            ---装備の場合
            local item = nil
            local itemSkill = caster:getActiveItemSkill()
            if itemSkill ~= nil then
                item = itemSkill:getBattleItem();
            end
            if item ~= nil then
                slotIndex = item:getSlotIndex() * 10000
            end
        else
            ---装備以外の場合
            local skill = caster:getActiveBattleSkill();
            if skill ~= nil then
                slotIndex = slotIndex + (skill:getIndex() * 10000)
            end
        end
        ---ユニットの位置
        local unitIndex = caster:getIndex() * 100000
        if value2 == 0 then
            slotIndex = 0
            unitIndex = 0
        end
        local min = (4761 + slotIndex + unitIndex) * -1
        local max = (4760 + value1 + slotIndex + unitIndex) * -1
        for i = min,max,-1 do
            ---フラグの個数だけカウント
            count = count + 1
            local buff = target:getTeamUnitCondition():findConditionWithID(i);
            if buff == nil then
                ---フラグ付与
                if value2 ~= 2 then
                    target:getTeamUnitCondition():addCondition(i,0,0,99999,0)
                end
                break
            end
        end
        if count >= value3 then
            megast.Battle:getInstance():updateConditionView();
            return value;
        end
        return 0;
    end

    if script_id == 477 then
        local time = target:getNormalSkill():getCoolTimer()
        if time < 1 then
            time = 1
        end
        time = math.ceil(time)
        return time
    end

    if script_id == 478 then
        if megast.Battle:getInstance():isPvp() then
            return 0
        end
        local paramStr = caster:getBaseID3().."_"..value1.."_"..value2.."_wave_"..megast.Battle:getInstance():getWaveNum()
        local flg = false;
        local usedStr = "USED"
        if value1 > 0 and target:getElementType() == value1 then
            flg = true
        end
        if value2 > 0 and target:getRaceType() == value2 then
            flg = true
        end
        if target:getParameter(paramStr) == usedStr then
            flg = false
        end
        if flg then
            target:setParameter(paramStr,usedStr);
            return value
        end
        return 0;
    end

    if script_id == 479 then
        local fixedValue = target:getNeedSPMax() / condition:getTimeMax();
        return fixedValue;
    end

    if script_id == 480 then
        if target:getIsDead() then
            condition:setIsHealCancel(true);
            return value
        end
        return 0
    end

    if script_id == 481 then
        condition:setCaster(nil);
        condition:setCasterByLua(caster)
        return value
    end

    if script_id == 483 then
        if value1 ~= 0 then
            local cond = caster:getTeamUnitCondition():findConditionWithID(value1);
            if cond == nil then
                --summoner.Utility.messageByEnemy("no " .. value3)
                return 0
            else
                cond:setTime(0)
                cond:setIsPassive(false)
                --summoner.Utility.messageByEnemy("remove")
                --summoner.Utility.messageByEnemy("v1 " .. cond:getValue1() .. " " .. cond:getValue2())
                --if cond:getValue1() >= cond:getValue2() then
                --    caster:getTeamUnitCondition():removeCondition(cond);
                --    summoner.Utility.messageByEnemy("remove")
                --end
            end
        else
            --summoner.Utility.messageByEnemy(value4)
            --condition:setID(value4);
            --condition:setTime(50);
            --condition:setIsPassive(true)
            local icon = condition:getThumbnailID()
            caster:getTeamUnitCondition():addCondition(value2,0,0,999999,icon);
            return 0
        end
        return value
    end

    if script_id == 484 then
        local casterIndex = condition:getCaster():getIndex();
        local itemSlotIndex = 0;
        local key = "";
        local absvalue = math.abs(value)
        local absvalue1 = math.abs(value1)
        local FLG = true
        local type = condition:getConditionTypeAsInt()
        local time = condition:getTime()

        -- 対象者が状態異常がチェック
        local deBuffFlg = false
        for k,v in pairs(getBadStatusList()) do
            if target:getTeamUnitCondition():findConditionValue(v) > 0 then
                deBuffFlg = true
                absvalue1 = 0
            end
        end

        local itemSkill = condition:getCaster():getActiveItemSkill()
        if itemSkill ~= nil then
            local item = itemSkill:getBattleItem();
            if item ~= nil then
                itemSlotIndex = item:getSlotIndex();
            end
        end

        key = "scriptID"..script_id.."c"..casterIndex.."i"..itemSlotIndex;
        local str = condition:getCaster():getParameter(key);
        if str ~= "" and str ~= nil and str ~= "0" then
            if type == 10 then
                condition:setPriority(absvalue * time)
            else
                condition:setPriority(absvalue)
            end
        else
            if type == 10 then
                condition:setPriority((absvalue + absvalue1) * time)
            else
                condition:setPriority(absvalue + absvalue1)
            end
        end

        local cond = target:getTeamUnitCondition():findConditionWithGroupID(condition:getGroupID());
        if cond ~= nil then
            if cond:getPriority() > condition:getPriority() then
                FLG = false
            end
        end

        local ID = 48400 + (casterIndex * 10) + itemSlotIndex
        local buff = condition:getCaster():getTeamUnitCondition():addCondition(ID,238,0,99999,0);
        buff:setScriptID(484)
        buff:setValue1(itemSlotIndex)
        if deBuffFlg then return 0; end
        if str ~= "" and str ~= nil and str ~= "0" then
            --summoner.Utility.messageByEnemy(key.."初回 以降"..str.. " " .. value.. " " .. value3.. " " .. value4)
            -- プラスにして返すかマイナスにして返すか
            if FLG then
                if value2 == 0 then
                    return absvalue
                else
                    return absvalue * -1
                end
            end
        else
            --summoner.Utility.messageByEnemy(key.."初回 付与"..str.. " " .. value.. " " .. value3.. " " .. value4)
            -- 初回はvalue3と加算してプラスにして返すかマイナスにして返すか
            if FLG then
                if value2 == 0 then
                    return absvalue + absvalue1
                else
                    return (absvalue + absvalue1) * -1
                end
            end
        end
        return 0;
    end

    if script_id == 485 then
        --対象者の燃焼・毒・暗闇・病気を回復し、回復したらvalue値を加算
        local badStatusList = { 90, 93, 94, 97 }
        local FLG = true
        local tmpvalue = value
        for k,v in pairs(badStatusList) do
            local cond = target:getTeamUnitCondition():findConditionWithType(v)
            if cond ~= nil then
                target:getTeamUnitCondition():removeCondition(cond);
                tmpvalue = tmpvalue + value1
            end
        end

        condition:setPriority(tmpvalue)
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(condition:getGroupID());
        if cond ~= nil then
            if cond:getPriority() > condition:getPriority() then
                FLG = false
            end
        end

        if FLG then
            return tmpvalue
        end
        return 0
    end

    if script_id == 489 then
        if megast.Battle:getInstance():getBattleState() == kBattleState_active then
            return 0;
        end
        if megast.Battle:getInstance():isStart() == true then
            return 0;
        end
        if value2 ~= 0 and target:getRaceType() ~= value2 then
            return 0;
        end
        if value3 ~= 0 and target:getElementType() ~= value3 then
            return 0;
        end

        if target:getBaseID3() == value4 or target:getBaseID3() == value5 then
            local cond = target:getTeamUnitCondition():findConditionWithID(value1);
            if cond ~= nil then
                if cond:getValue() >= value then
                    return 0;
                end
                target:getTeamUnitCondition():addCondition(value1,0,value,999999,0);
                target:setBurstPoint(target:getBurstPoint() - cond:getValue());
            else

                target:getTeamUnitCondition():addCondition(value1,0,value,999999,0);
            end

            return value;
        end
        return 0;
    end

    if script_id == 488 then
        local ID = 48800 + (caster:getIndex() * 10);
        local buff = caster:getTeamUnitCondition():addCondition(ID,238,0,999999,0);
        buff:setScriptID(488);
        buff:setValue1(value1);
        buff:setValue2(value2);
        return value;
    end

    if script_id == 490 and value4 == 0 then
        local targetUnit = getAncestorUnit(target);
        if value1 == 1 then
            targetUnit = getAncestorUnit(caster);
        end

        if targetUnit == nil then
            return value;
        end

        --自分PTからみて敵PTを取る
        local unitTeam = targetUnit:getTeam();
        local targetTeam = nil;
        if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(true);
        else
            targetTeam = megast.Battle:getInstance():getTeam(false);
        end

        local minPar = 101;
        for i = 0,8 do
            local myTeamUnit = targetTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                local per =  myTeamUnit:getHPPercent() * 100;
                if per <= minPar then
                    minPar = per;
                end
            end
        end

        local hpRatio = minPar / 100;
        local inverseRatio = 1 - hpRatio;
        local calculatedValue = inverseRatio * value2;
        value = value * calculatedValue + value3;
        return value;
    end

    if script_id == 491 and value4 == 0 then
        local targetUnit = getAncestorUnit(target);
        if value1 == 1 then
            targetUnit = getAncestorUnit(caster);
        end

        if targetUnit == nil then
            return value;
        end

        local per =  targetUnit:getHPPercent() * 100;
        local hpRatio = per / 100;
        local inverseRatio = 1 - hpRatio;
        local calculatedValue = inverseRatio * value2;
        value = value * calculatedValue + value3;
        return value;
    end

    if script_id == 492 then
        local unit = getAncestorUnit(caster);
        if value1 == 1 then
            unit = getAncestorUnit(target);
        end
        --死亡時処理用バフタイプ：240付与
        unit:getTeamUnitCondition():addCondition(49202,240,0,999999,0);
        local deadFlg = unit:getTeamUnitCondition():findConditionWithID(49202);
        if deadFlg ~= nil then
            deadFlg:setScriptID(492);
            deadFlg:setValue3(value3);
            deadFlg:setValue5(unit:getIndex());
        end
        --パラメータのカウント取得
        local key = "scriptID:492".."c"..unit:getIndex().."Count"..value3;
        if unit:getParameter(key) == "" then
            unit:setParameter(key,"0");
        end
        local num = tonumber(unit:getParameter(key));
        --重複防止用バフ確認
        local cond = unit:getTeamUnitCondition():findConditionWithID(492999);
        if cond ~= nil then
            cond:getValue();
            num = cond:getValue();
        else
            local flgBuff = unit:getTeamUnitCondition():addCondition(492999,0,0,999999,0);
            flgBuff:setRemoveOnResetState(true);
            num = num + 1;
            if num >= value2 then num = value2; end
            unit:setParameter(key,tostring(num));
            flgBuff:setValue(num);
        end
        --バフカウントセット
        condition:setNumber(num);
        condition:setMaxConditionIconNumber(value2);
        --プライオリティセット
        if condition:getGroupID() ~= 0 then
            local priority = value
            if priority < 0 then
                priority = priority * -1
            end
            if condition:getConditionTypeAsInt() == 10 then
                condition:setPriority(priority * num * condition:getTime())
            else
                condition:setPriority(priority * num)
            end
        end
        --PvP補正関係
        local cond = unit:getTeamUnitCondition():findConditionWithID(condition:getID());
        if cond ~= nil then
            local rate = 1;
            if cond:getConditionTypeAsInt() == 8 or cond:getConditionTypeAsInt() == 9 or cond:getConditionTypeAsInt() == 10 then
                rate = megast.Battle:getInstance():getPvpCorrectionValue(cond:getConditionTypeAsInt(),1);
            end
            value = value * rate
        end
        megast.Battle:getInstance():updateConditionView();
        return num * value;
    end

    if script_id == 493 then
        local ancestorUnit = getAncestorUnit(caster)
        local ancestorTarget = getAncestorUnit(target)
        if value1 == 0 then
            if ancestorUnit:getElementType() == ancestorTarget:getElementType() then
                return 0;
            end
        elseif value1 == 1 then
            if ancestorUnit:getElementType() ~= ancestorTarget:getElementType() then
                return 0;
            end
        elseif value1 == 2 then
            if ancestorUnit:getRaceType() == ancestorTarget:getRaceType()then
                return 0;
            end
        elseif value1 == 3 then
            if ancestorUnit:getRaceType() ~= ancestorTarget:getRaceType()then
                return 0;
            end
        end
        return value;
    end

    if script_id == 504 then
        if caster:getElementType() == value1 then
            for i = 0,7 do
                local target = megast.Battle:getInstance():getTeam(caster:getisPlayer()):getTeamUnit(i);
                if target ~= nil then
                    if target:getElementType() == value1 then
                        target:addSP(value5 * pvpCorrectionValue)

                        local cond = target:getTeamUnitCondition():findConditionWithGroupID(1024);
                        if cond ~= nil then
                            if cond:getPriority() > value4 then

                            --同一優先度で自分のバフよりも長時間持続するものには手を触れない
                            elseif cond:getPriority() == value4 and cond:getTime() > 10 then

                            else
                                target:getTeamUnitCondition():removeCondition(cond);
                                local newCond = target:getTeamUnitCondition():addCondition(value3,22,value4,10,11);
                                newCond:setScriptID(14)
                                newCond:setValue1(value2)
                                newCond:setGroupID(1024)
                                newCond:setPriority(value4)
                            end

                        else
                            local newCond = target:getTeamUnitCondition():addCondition(value3,22,value4,10,11);
                            newCond:setScriptID(14)
                            newCond:setValue1(value2)
                            newCond:setGroupID(1024)
                            newCond:setPriority(value4)
                        end

                    end
                end
            end
            return 0
        end
        return 0
    end

    ---494~495
    if script_id >= 494 and script_id <= 495 then
        local typeNum = script_id % 10
        local needNum = 0

        -- 付与判定チェックをする
        if value5 == 0 then
            return 0
        end

        -- 494は1種類以上あれば適用
        -- 495は2種類以上あれば適用
        if typeNum == 4 then
            needNum = 1
        elseif typeNum == 5 then
            needNum = 2
        end

        ---value1~4の装備がneedNum種類あるか確認
        if findBaseWeaponId(caster, value1, value2, value3, value4, needNum) then
            return value
        end

        return 0;
    end

    if script_id == 505 then
        if caster:getElementType() == value1 then
            local cond = caster:getTeamUnitCondition():findConditionWithGroupID(1053);
            if cond ~= nil then
                if cond:getPriority() > value4 then
                    return 0;
                end
                --同一優先度で自分のバフよりも長時間持続するものには手を触れない
                if cond:getPriority() == value4 and cond:getTime() > 10 then
                    return 0;
                end
                caster:getTeamUnitCondition():removeCondition(cond);
            end

            local newCond = caster:getTeamUnitCondition():addCondition(value3,17,value4,10,114);
            newCond:setScriptID(264)
            newCond:setValue1(value2)
            newCond:setGroupID(1053)
            newCond:setPriority(value4)
            return value
        end
        return 0
    end

    if script_id == 506 then
        if caster:getElementType() == value1 and target:getElementType() == value2 then
            return value
        end
        return 0
    end

	if script_id == 601 then
		-- 上位状態異常、毒
        local cond = target:getTeamUnitCondition():findConditionWithType(condition:getConditionTypeAsInt());
        if cond ~= nil then
        	return 0;
		end
        return value
	end

	if script_id == 602 then
		-- 上位状態異常、燃焼
        local cond = target:getTeamUnitCondition():findConditionWithType(condition:getConditionTypeAsInt());
        if cond ~= nil then
        	return 0;
		end
        return value
	end

	if script_id == 605 then
		-- 上位状態異常、麻痺、氷結
        return value
	end

	if script_id == 603 then
		-- 麻痺後遺症
		-- 氷結後遺症
		return 0;
	end

	if script_id == 604 then
		-- 麻痺後遺症回復
		-- 氷結後遺症回復
        local cond = target:getTeamUnitCondition():findConditionWithType(value5);
        if cond ~= nil then
			if value4 > 0 then
				-- value4をウェイト値とみなす
				local weight = value4;
				local rand = math.random(100);
				if rand > weight then
					return 0;
				end
			end

			local num = cond:getNumber() - value;
			if num > 0 then
			    cond:setNumber(num);
			else
            	target:getTeamUnitCondition():removeCondition(cond);
			end
		end
		return 1;
	end

    if script_id == 1122 then
        if target:getElementType() ~= value2 then
            return 0;
        end
        return 1;
    end

    -- 最後のreturn
    return value;
end



--condition付与成功失敗の判断が出来る。
--isSuccessful が true で 成功。 isSuccessful が false で失敗。 基本的に 成功しても失敗しても通る。
-- return する 値によって、クライアント側でなにかするということはない
function isSuccessfulCondition(script_id,caster,target,condition,value,value1,value2,value3,value4,value5,isSuccessful)

    if script_id == 506 and isSuccessful then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value4);
        if cond ~= nil then
            if cond:getPriority() > value5 then
                return value;
            end
            --同一優先度で自分のバフよりも長時間持続するものには手を触れない
            if cond:getPriority() == value5 and cond:getTime() > 20 then
                return value;
            end
            target:getTeamUnitCondition():removeCondition(cond);
        end

        local newCond = target:getTeamUnitCondition():addCondition(value3,63,value5 * -1,20,45)
        newCond:setGroupID(value4)
        newCond:setPriority(value5)

        return value
    end

    if script_id == 155 and isSuccessful then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value5);
        if cond ~= nil then
            if cond:getPriority() > value2 then
                return value;
            end
            target:getTeamUnitCondition():removeCondition(cond);
        end

        local buff = target:getTeamUnitCondition():addCondition(value1,21,value2,value3,value4);
        buff:setGroupID(value5);
        buff:setPriority(value2);
    end

    if script_id == 156 and isSuccessful then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value5);
        if cond ~= nil then
            if cond:getPriority() > value2 then
                return value;
            end
            target:getTeamUnitCondition():removeCondition(cond);
        end

        local buff = target:getTeamUnitCondition():addCondition(value1,21,value2,value3,value4);
        buff:setScriptID(3);
        buff:setGroupID(value5);
        buff:setPriority(value2);
    end


    if script_id == 157 then

        if isSuccessful then

            --１度の行動中に何回も出ないようにする場合　コンディションを付与しておいて見つけたら拒否る
            local cond = caster:getTeamUnitCondition():findConditionWithID(value1);
            if cond ~= nil then
                return value;
            end

            if value3 == 1 then
                local buff = caster:getTeamUnitCondition():addCondition(value1,0,1,999,0);
                buff:setRemoveOnResetState(true);
            end

            --===============================================================================
            --回数制限

            local countCond = caster:getTeamUnitCondition():findConditionWithID(157);
            if value4 ~= 0 then
                if countCond ~= nil then
                    local count = countCond:getValue3();
                    if count >= value4 then
                        caster:getTeamUnitCondition():removeCondition(countCond);
                        return value;
                    else
                        countCond:setValue3(count + 1);
                        countCond:setValue2(1);
                    end
                end
            end

            if value4 ~= 0 and countCond == nil then
                local countBuff = caster:getTeamUnitCondition():addCondition(157,0,1,9999,0);
                countBuff:setValue3(1);
                countBuff:setValue2(1);
            end
            --===============================================================================
            pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(8,1);
            caster:addSP(value2 * pvpCorrectionValue);
        else
            --外した場合　回数制限リセット
            local countCond = caster:getTeamUnitCondition():findConditionWithID(157);
            if value4 ~= 0 then
                if countCond ~= nil then
                    caster:getTeamUnitCondition():removeCondition(countCond);
                    return 0;

                end
            end
        end
    end

    if script_id == 162 and isSuccessful then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value5);
        if cond ~= nil then
            if cond:getPriority() > value2 then
                return value;
            end
            target:getTeamUnitCondition():removeCondition(cond);
        end

        local buff = target:getTeamUnitCondition():addCondition(value1,21,value2,value3,value4);
        buff:setScriptID(4);
        buff:setGroupID(value5);
        buff:setPriority(value2);
    end

    if script_id == 1732 and isSuccessful then

        local cond = target:getTeamUnitCondition():findConditionWithID(value2);
        if cond ~= nil and cond:getGroupID() == condition:getGroupID() then
            local stage = cond:getValue5();
            if stage == 0 then
                stage = 1;
            end
            stage = stage + 1;
            if stage > value1 then
                stage = value1;
            end

            if  cond:getPriority() > condition:getPriority() then
                return 0
            end

            if  cond:getPriority() < condition:getPriority() then
                target:getTeamUnitCondition():removeCondition(cond);
                condition:setID(value2);
                condition:setNumber(1);
                megast.Battle:getInstance():updateConditionView();
                return value
            end

            if stage == value1 then
                cond:setValue(value * stage);
                cond:setNumber(10);
            else
                cond:setValue(value * stage);
                cond:setNumber(stage);
            end

            megast.Battle:getInstance():updateConditionView();
            cond:setValue5(stage);
            cond:setPriority(condition:getPriority())
            return 0;
        end
        condition:setID(value2);
        condition:setNumber(1);
        megast.Battle:getInstance():updateConditionView();
        return value;
    end

    if script_id == 181 then
        local target = getAncestorUnit(caster)
        local weaponBuff = target:getTeamUnitCondition():findConditionWithID(50225400);
        if weaponBuff ~= nil then
            condition:setTime(condition:getTime() + 2);
        end
        return value;
    end

    -- if script_id == 186 then

    --     if caster ~= nil then
    --         if isSuccessful then

    --             local buff = caster:getParentTeamUnit():getTeamUnitCondition():findConditionWithID(value1);
    --             buff:setValue4(1);
    --         end
    --     end

    -- end

    if script_id == 204 and isSuccessful then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value5);
        if cond ~= nil then
            if cond:getPriority() > value2 then
                return value;
            end
            target:getTeamUnitCondition():removeCondition(cond);
        end

        local buff = target:getTeamUnitCondition():addCondition(value1,21,value2,value3,value4);
        buff:setScriptID(2);
        buff:setGroupID(value5);
        buff:setPriority(value2);
    end

    if script_id == 209 and isSuccessful then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value5);
        if cond ~= nil then
            if cond:getPriority() > value2 then
                return value;
            end
            target:getTeamUnitCondition():removeCondition(cond);
        end

        local buff = target:getTeamUnitCondition():addCondition(value1,65,value2,value3,value4);
        buff:setGroupID(value5);
        buff:setPriority(value2);
    end

    if script_id == 212 and isSuccessful then
        local cond = caster:getTeamUnitCondition():findConditionWithID(-212);
        if cond ~= nil then
            return 0;
        end
        caster:getTeamUnitCondition():addCondition(-212,0,1,5,0);
        pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(8,1);
        caster:addSP(value1 * pvpCorrectionValue);
    end

    if script_id == 213 then
        local time = BattleControl:get():getTime();
        condition:setTime(condition:getTime() + time/value1);
    end

	-- 奥義ゲージDOWN系
    if script_id == 223 and isSuccessful then

		if value1 > 0 then
        	local sp_percent = 1 - (target:getTeamUnitCondition():findConditionValue(140) / 100);
			if sp_percent < 0 then
				sp_percent = 0;
			end
			value1 = value1 * sp_percent;
		end

        local targetPoint = target:getBurstPoint() - value1;

        if targetPoint < 0 then
            targetPoint = 0;
        end
        target:setBurstPoint(targetPoint);
    end

    if script_id == 224 then
        local cond = target:getTeamUnitCondition():findConditionWithID(value2);
        --[[
        local targetCondID = -2240 - caster:getIndex();
        local check = target:getTeamUnitCondition():findConditionWithID(targetCondID);
        if check ~= nil and cond ~= nil then
            --元となったほうは効果をなくしたい
            --上でやるとなんか下まで通ってくれなくなるのでそれぞれのifの末尾に書くよ
            condition:setTime(0);
            condition:setValue(0);
            return 0;
        end

        target:getTeamUnitCondition():addCondition(targetCondID,0,1,3,0);
        ]]--


        if cond ~= nil then

            local stage = cond:getValue5();
            if stage == 0 then
                 stage = 1;
            end
            stage = stage + 1;
            if stage > value1 then
                stage = value1;
            end

            local time = cond:getTime();
            local thumb = cond:getThumbnailID();


            target:getTeamUnitCondition():removeCondition(cond);


            local newCond = target:getTeamUnitCondition():addCondition(value2,21,value * stage,time,thumb);


            newCond:setValue(value * stage);
            newCond:setNumber(stage);
            newCond:setGroupID(21011);--出血専用グループID
            target:setParameter("304_Blood",""..stage)

            megast.Battle:getInstance():updateConditionView();
            newCond:setValue5(stage);

            --元となったほうは効果をなくしたい
            --上でやるとなんか下まで通ってくれなくなるのでそれぞれのifの末尾に書くよ
            condition:setTime(0);
            condition:setValue(0);

            return 0;
        end
        local newCond = target:getTeamUnitCondition():addCondition(value2,21,value,condition:getTime(),condition:getThumbnailID());

        newCond:setNumber(1);
        newCond:setGroupID(21011);--出血専用グループID
        megast.Battle:getInstance():updateConditionView();
        target:setParameter("304_Blood",""..1)
        newCond:setValue5(1);

        --元となったほうは効果をなくしたい
        --上でやるとなんか下まで通ってくれなくなるのでそれぞれのifの末尾に書くよ
        condition:setTime(0);
        condition:setValue(0);
    end

    if script_id == 2242 then
        local cond = target:getTeamUnitCondition():findConditionWithID(value2);

        if cond == nil then return 0 end

        --[[
        local targetCondID = -2240 - caster:getIndex();
        local check = target:getTeamUnitCondition():findConditionWithID(targetCondID);
        if check ~= nil and cond ~= nil then
            --元となったほうは効果をなくしたい
            --上でやるとなんか下まで通ってくれなくなるのでそれぞれのifの末尾に書くよ
            condition:setTime(0);
            condition:setValue(0);
            return 0;
        end

        target:getTeamUnitCondition():addCondition(targetCondID,0,1,3,0);
        ]]--


        if cond ~= nil then

            local stage = cond:getValue5();
            if stage == 0 then
                stage = 1;
            end
            stage = stage + 1;
            if stage > value1 then
                stage = value1;
            end

            local time = cond:getTime();
            local thumb = cond:getThumbnailID();


            target:getTeamUnitCondition():removeCondition(cond);


            local newCond = target:getTeamUnitCondition():addCondition(value2,21,value * stage,time,thumb);


            newCond:setValue(value * stage);
            newCond:setNumber(stage);
            newCond:setGroupID(21011);--出血専用グループID
            target:setParameter("304_Blood",""..stage)

            megast.Battle:getInstance():updateConditionView();
            newCond:setValue5(stage);

            --元となったほうは効果をなくしたい
            --上でやるとなんか下まで通ってくれなくなるのでそれぞれのifの末尾に書くよ
            condition:setTime(0);
            condition:setValue(0);

            return 0;
        end
        local newCond = target:getTeamUnitCondition():addCondition(value2,21,value,condition:getTime(),condition:getThumbnailID());

        newCond:setNumber(1);
        newCond:setGroupID(21011);--出血専用グループID
        megast.Battle:getInstance():updateConditionView();
        target:setParameter("304_Blood",""..1)
        newCond:setValue5(1);

        --元となったほうは効果をなくしたい
        --上でやるとなんか下まで通ってくれなくなるのでそれぞれのifの末尾に書くよ
        condition:setTime(0);
        condition:setValue(0);
    end

    if script_id == 2263 and isSuccessful then
        condition:setValue3(condition:getTime())
        return value;
    end

    if script_id == 239 and isSuccessful then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value5);
        if cond ~= nil then
            if cond:getPriority() > math.abs(value2) then
                return value;
            end
            target:getTeamUnitCondition():removeCondition(cond);
        end

        local buff = target:getTeamUnitCondition():addCondition(value1,62,value2,value3,value4);
        buff:setGroupID(value5);
        buff:setPriority(math.abs(value2));
        condition:setScriptID(101036211)
    end

    if script_id == 240 and isSuccessful then
        pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(8,1);
        caster:addSP(value1 * pvpCorrectionValue);
    end

    if script_id == 247 and isSuccessful then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(value5);
        if cond ~= nil then
            if cond:getPriority() > math.abs(value2) then
                return value;
            end
            target:getTeamUnitCondition():removeCondition(cond);
        end

        local buff = target:getTeamUnitCondition():addCondition(value1,61,value2,value3,value4);
        buff:setGroupID(value5);
        buff:setPriority(math.abs(value2));
    end

    if script_id == 248 and isSuccessful then
        local hpRate = summoner.Utility.getUnitHealthRate(caster) * 100
        local type = caster:getTeamUnitCondition():getDamageAffectInfo().skillType;

        if type ~= 2 or hpRate < value1 then
            return value;
        end
        condition:setTime(condition:getTime() * (value2/100 + 1))
        return value
    end

    if script_id == 258 and isSuccessful then
        condition:setNumber(value1);
        megast.Battle:getInstance():updateConditionView();
        return value
    end

    if script_id == 260 and isSuccessful then
        local floor = megast.Battle:getInstance():getCurrentMineFloor();
        if condition ~= nil then
            local time = condition:getTime()
            condition:setTime(time + floor * value1 * 0.01)
        end
        return value;
    end

    if script_id == 278 and isSuccessful then
        ---アビリティの場合70以上
        if caster:getLevel() >= value1 then
            local rate = value2
            local buff = nil
            local cond = caster:getTeamUnitCondition():findConditionWithID(278);
            if cond == nil then
                ---ない場合付与
                buff = caster:getTeamUnitCondition():addCondition(278,17,value2,value3,26);
            else
                ---ある場合valueを足して付与
                local condValue =cond:getValue()
                value2 = value2 + condValue
                if value2 > rate * value4 then
                    value2 = rate * value4
                end
                buff = caster:getTeamUnitCondition():addCondition(278,17,value2,value3,26);
            end
            ---カウント表示
            local count = value2 / rate
            count = math.floor(count)
            buff:setMaxConditionIconNumber(value4);
            buff:setNumber(count);
            megast.Battle:getInstance():updateConditionView();
        end
        return value
    end

    if script_id == 302 and isSuccessful then
        caster:getTeamUnitCondition():addCondition(0,value1,value2,value3,value4);
        return value
    end

    if script_id == 303 and isSuccessful then
        ---アビリティの場合70以上
        if caster:getLevel() >= value1 then
            local myTeam = caster:getTeam()
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    local element = myTeamUnit:getElementType()
                    if value5 == 6 then
                        element = 0
                    elseif value5 ~= 0 then
                        element = value5
                    end
                    if myTeamUnit:getElementType() == element then
                        local rate = value2
                        local buff = nil
                        local fixedValue = value2
                        local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(303000 + caster:getBaseID3());
                        if cond == nil then
                            ---ない場合付与
                            buff = myTeamUnit:getTeamUnitCondition():addCondition(303000 + caster:getBaseID3(),17,value2,value3,26);
                        else
                            ---ある場合valueを足して付与
                            local condValue =cond:getValue()
                            fixedValue = fixedValue + condValue
                            if fixedValue > rate * value4 then
                                fixedValue = rate * value4
                            end
                            buff = myTeamUnit:getTeamUnitCondition():addCondition(303000 + caster:getBaseID3(),17,fixedValue,value3,26);
                        end
                        ---カウント表示
                        local count = fixedValue / rate
                        count = math.floor(count)
                        buff:setMaxConditionIconNumber(value4);
                        buff:setNumber(count);
                        megast.Battle:getInstance():updateConditionView();
                    end
                end
            end
        end
        return value
    end

    ---アインズ奥義専用
    if script_id == 311 and isSuccessful then
        local FLG = true
        ---炎属性耐性ダウン
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(3643);
        if cond ~= nil then
            if cond:getPriority() > math.abs(-40) then
                FLG = false
            else
                target:getTeamUnitCondition():removeCondition(cond);
            end
        end
        if FLG then
            local buff = target:getTeamUnitCondition():addCondition(20769702,61,-40,15,43);
            buff:setGroupID(3643);
            buff:setPriority(math.abs(-40));
        end

        FLG = true
        ---闇属性耐性ダウン
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(3644);
        if cond ~= nil then
            if cond:getPriority() > math.abs(-40) then
                FLG = false
            else
                target:getTeamUnitCondition():removeCondition(cond);
            end
        end
        if FLG then
            local buff = target:getTeamUnitCondition():addCondition(20769703,65,-40,15,47);
            buff:setGroupID(3644);
            buff:setPriority(math.abs(-40));
        end

        return value
    end

    if script_id == 323 and isSuccessful then
        target:getTeamUnitCondition():addConditionWithGroupID(0,value1,value2,value3,value4,2010,math.abs(value2));
        caster:callLuaMethod("323",0);
        return value
    end

    ---ジャック専用
    if script_id == 366 and isSuccessful then
        local buff = target:getTeamUnitCondition():addCondition(0,238,0,99999,0);
        buff:setScriptID(366)
        buff:setValue1(condition:getID())
        return value
    end

    if script_id == 389 and isSuccessful then
        local floor = megast.Battle:getInstance():getCurrentGrandBattleFloor();
        if condition ~= nil then
            local time = condition:getTime()
            condition:setTime(time + floor * value1 * 0.01)
        end
        return value;
    end

    if script_id == 445 and isSuccessful then
        -- 空っぽの回数カウント用のバフを用意する
        local oldBuff = nil
        local count = 1
        oldBuff = target:getTeamUnitCondition():findConditionWithID(206394520)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > 20 then
                count = 20
            end
        end

        if oldBuff == nil then
            oldBuff = target:getTeamUnitCondition():addCondition(206394520,0,0,999999,0)
        end
        oldBuff:setNumber(count);
        megast.Battle:getInstance():updateConditionView()
        return value
    end

	if script_id == 605 and isSuccessful then
        local ctype = condition:getConditionTypeAsInt();
		local ntype = 0;
		local icon = 0;
		if ctype == 202 then
			-- 麻痺
			ntype = 233;
			icon = 325;
		end
		if ctype == 207 then
			-- 氷結
			ntype = 234;
			icon = 326;
		end

        local dam = 0;
        local cond = target:getTeamUnitCondition():findConditionWithType(ntype);
        if cond == nil then
        	local buff = target:getTeamUnitCondition():addCondition(-1,ntype,value,-1,icon,0);
        	if buff ~= nil then
				buff:setNumber(1);
				buff:setValue( condition:getValue() );
            	buff:setScriptID(603);
			end
			dam = condition:getValue();
		else
			local num = cond:getNumber() + 1;
			if num <= 10 then
				cond:setNumber(num);
			end
			dam = num * cond:getValue();
		end

		if ntype == 233 and dam > 0 then
			-- 麻痺後遺症のときダメージ
			local dam2 = target:getBaseHP() * dam / 100;
			target:setHP( target:getHP() - dam2 );
		end

        return value
	end

    return 0;
end



function id_900(unit,other,condition,value,value1,value2,value3)
    return value;
end

--対象のHPが〇〇ほど効果上昇 value1[最小効果量%] value2[最大効果量%] value3[固定追加量]
function id_1(unit,other,condition,value,value1,value2,value3)
    if other == null then
        return value;
    end

    local per =  other:getHPPercent() * 100;
    local _per = per - value1;
    local rate = _per / (value2 - value1);
    if rate > 1 then
        rate = 1;
    end


    if rate < 0 then
        rate = 0;
    end

    value = value * rate + value3;
    return value;
end

--受けるダメージが物理のとき
function id_902(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 1 then
        return value;
    end

    return 0;
end

--受けるダメージが魔法のとき
function id_903(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 2 then
        return value;
    end

    return 0;
end

--特定の属性（相手）
function id_914(unit,other,condition,value,value1,value2,value3)
    if other:getElementType() == value1 then
        return value;
    end
    return 0;
end

--自分のHPが◯％〜◯％の時
function id_921(unit,other,condition,value,value1,value2,value3)
    if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 then
        return value;
    end

    return 0;
end

--
function id_929(unit,other,condition,value,value1,value2,value3)

    return value;
end


--受けるダメージが物理のとき
function id_2(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 1 then
        return value;
    end

    return 0;
end

--受けるダメージが魔法のとき
function id_3(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 2 then
        return value;
    end

    return 0;
end

--物理攻撃の時
function id_4(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 1 then
        return value;
    end

    return 0;
end

--魔法攻撃の時
function id_5(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 2 then
        return value;
    end

    return 0;
end

--自分のHPが〇〇ほど効果上昇 value1[最小効果量%] value2[最大効果量%] value3[固定追加量]
function id_6(unit,other,condition,value,value1,value2,value3,value4)
    if unit == nil then
        return value;
    end
    local skill = unit:getActiveBattleSkill();
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value4 ~= 0 and value4 ~= type and value4 ~= 7 then
        return 0;
    end

    if skill == nil and value4 == 7 then
        return 0;
    end

    if value4 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end


    local per =  unit:getHPPercent() * 100;
    local _per = per - value1;
    local rate = _per / (value2 - value1);
    if rate > 1 then
        rate = 1;
    end
    if rate < 0 then
        rate = 0;
    end

    value = value * rate + value3;
    return value;
end

--スキル・奥義中のみ
function id_8(unit,other,condition,value,value1,value2,value3)
    condition:setRemoveOnResetState(true);

    if value1 == 0 then
        return value;
    end

    local skill = unit:getActiveBattleSkill();
    local type = 0;
    if skill ~= nil then
        type = skill:getSkillType();
    end


    if value1 ~= 0 and value1 ~= type and value1 ~= 7 and value1 ~= 8 then

        return 0;
    end

    if skill == nil and value1 == 7 then

        return 0;
    end

    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then

        return 0;
    end

    return value;
end


--自身のHP割合消費で味方回復
function id_9(unit,other,condition,value,value1,value2,value3)
    return value;
end

--次に使用するスキルに効果
function id_10(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 1 then
        condition:setRemoveOnResetState(true);
        return value;
    end
    return 0;
end

--通常攻撃のみ
function id_11(unit,other,condition,value,value1,value2,value3)
    if unit:getUnitState() == kUnitState_attack then
        return value;
    end
    return 0;
end

--特定の属性（自分）
function id_12(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and type ~= value2 then
        return 0;
    end

    if unit:getElementType() == value1 then
        return value;
    end
    return 0;
end

--エンチャント
function id_13(unit,other,condition,value,value1,value2,value3)

    return value;
end

--特定の属性（相手）
function id_14(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if skill == nil and value2 == 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    if other:getElementType() == value1 then
        return value;
    end
    return 0;
end

--攻撃装備
function id_15(unit,other,condition,value,value1,value2,value3)
    return value;
end


--自分が◯族だったら
function id_16(unit,other,condition,value,value1,value2,value3)
    if unit:getRaceType() == value1 or unit:getRaceType() == value2 or unit:getRaceType() == value3 then
        return value;
    end

    return 0;
end

--相手が◯族だったら
function id_17(unit,other,condition,value,value1,value2,value3)
    if other ~= nil and other:getRaceType() == value1 then
        return value;
    end

    return 0;
end

--自分が◯状態だったら
function id_18(unit,other,condition,value,value1,value2,value3)
    local cond = unit:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil then
        return value;
    end

    if value2 == 0 then
        return 0;
    end
    local cond2 = unit:getTeamUnitCondition():findConditionWithType(value2);
    if cond2 ~= nil then
        return value;
    end

    return 0;
end

--相手が◯状態だったら
function id_19(unit,other,condition,value,value1,value2,value3)
    local cond = other:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil then
        return value;
    end
    if value2 == 0 then
        return 0;
    end
    local cond2 = other:getTeamUnitCondition():findConditionWithType(value2);
    if cond2 ~= nil then
        return value;
    end

    return 0;
end

--相手がブレイク状態
function id_20(unit,other,condition,value,value1,value2,value3)
    if other ~= nil and other:getBreakPoint() <= 0 then
        return value;
    end

    return 0;
end

--自分のHPが◯％〜◯％の時
function id_21(unit,other,condition,value,value1,value2,value3,value4)
    local teamUnit = unit
    if value4 == 1 then
        teamUnit = other
    end

    if value3 == 1 then
        if (teamUnit:getHPPercent() * 100) >= value1 and (teamUnit:getHPPercent() * 100) < value2 then
            return value;
        else
            return 0;
        end
    end

    if (teamUnit:getHPPercent() * 100) >= value1 and (teamUnit:getHPPercent() * 100) <= value2 then
        return value;
    end

    return 0;
end

--クリティカル発動時
function id_22(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();
    if value1 == 1 then
        return value;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if skill == nil and value2 == 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        return value;
    end

    return 0;
end

--クリティカル発動時(カティロ用)
function id_1022(unit,other,condition,value,value1,value2,value3)
    condition:setRemoveOnResetState(true);
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical and unit:getUnitState() == kUnitState_skill then
        return value;
    end

    return 0;
end

--特定の属性(使用者)
function id_23(unit,other,condition,value,value1,value2,value3)

    return value;
end

--特定の種族(使用者)
function id_24(unit,other,condition,value,value1,value2,value3)
    --addconditionでも判定
    if unit:getRaceType() ~= value1 then
         return 0;
    end
    return value;
end

--属性の上書き
function id_25(unit,other,condition,value,value1,value2,value3)
    unit:getTeamUnitCondition():getActiveBattleSkill():setElementType(value1);
    return value;
end

--効果発動者がリーダー
function id_26(unit,other,condition,value,value1,value2,value3)
    if not unit:getIsLeader() then
         return 0;
    end
    return value;
end

--攻撃相手もしくは、攻撃してきた相手が有利属性
function id_27(unit,other,condition,value,value1,value2,value3)
    if other == nil then
        return 0;
    end
    local element = other:getTeamUnitCondition():getDamageAffectInfo().skillElementType;

    if other:getElementType() == 1 and element == 2 then
        return value;
    end

    if other:getElementType() == 2 and element == 3 then
        return value;
    end

    if other:getElementType() == 3 and element == 1 then
        return value;
    end

    if other:getElementType() == 4 and element == 5 then
        return value;
    end

    if other:getElementType() == 5 and element == 4 then
        return value;
    end

    return 0;
end

--攻撃相手もしくは、攻撃してきた相手が不利属性
function id_28(unit,other,condition,value,value1,value2,value3)
    local element = other:getTeamUnitCondition():getDamageAffectInfo().skillElementType;

    if unit:getElementType() == 1 and element == 2 then
        return value;
    end

    if unit:getElementType() == 2 and element == 3 then
        return value;
    end

    if unit:getElementType() == 3 and element == 1 then
        return value;
    end

    if unit:getElementType() == 4 and element == 5 then
        return value;
    end

    if unit:getElementType() == 5 and element == 4 then
        return value;
    end

    return 0;
end

--
function id_29(unit,other,condition,value,value1,value2,value3)

    return value;
end


-- 被ダメージ時消費（バリア用）
function id_30(unit,other,condition,value,value1,value2,value3)
    return value;
end

--対象のHPが〇〇ほど効果上昇 value1[最小効果量%] value2[最大効果量%] value3[固定追加量]
function id_31(unit,other,condition,value,value1,value2,value3)
    if other == null then
        return value;
    end

    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    if not (skill:getSkillType() == 1 or skill:getSkillType() == 2) then
        return 0;
    end

    if unit:getUnitState() ~= kUnitState_skill then
        return 0;
    end

    condition:setRemoveOnResetState(true);

    local per =  other:getHPPercent() * 100;
    local _per = per - value1;
    local rate = _per / (value2 - value1);
    if rate > 1 then
        rate = 1;
    end
       print(per);
       print(rate);
    if rate < 0 then
        rate = 0;
    end

    value = value * rate + value3;
    return value;
end

--自分のHPが〇〇ほど効果上昇 value1[最小効果量%] value2[最大効果量%] value3[固定追加量]
function id_32(unit,other,condition,value,value1,value2,value3)
    if unit == null then
        return value;
    end

    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    if not (skill:getSkillType() == 1 or skill:getSkillType() == 2) then
        return 0;
    end

    if unit:getUnitState() ~= kUnitState_skill then
        return 0;
    end

    condition:setRemoveOnResetState(true);

    --unit:setHP(1)
    ---HP1時が最大valueになるように調整
    local maxHP = unit:getCalcHPMAX() - 1
    local nowHP = unit:getHP() - 1
    if nowHP < 0 then
        nowHP = 0
    end
    local rate = 1 - (nowHP / maxHP)
    value = value * rate
    return value + value1;
end

--受けたダメージに対する割合
function id_33(unit,other,condition,value,value1,value2,value3)
    local power = other:getCalcPower();
    local skill  = other:getActiveBattleSkill();
    local animRate = other:getAnimationDamageRateSum();
    if animRate > 50 then
        animRate = 50;
    end
    local dealdamage = 0;
    local cond = other:getTeamUnitCondition():findConditionValue(17);
    if cond ~= 0 then
        dealdamage = (cond / 100);
    end

    if skill ~= nil then
        power = skill:getDamageRate() * power;
    end
    if dealdamage > 0 then
        power =  power + (power * dealdamage);
    end
    power = power / animRate;

    return value + (power * value1 / 100)
end

--相手が奥義発動中
function id_34(unit,other,condition,value,value1,value2,value3)
    local team = megast.Battle:getInstance():getTeam(not unit:getisPlayer());
	if megast.Battle:getInstance():isPvp() then
       	team = megast.Battle:getInstance():getTeam(not unit:getisPvpPlayer());
	end
    condition:setRemoveOnResetState(true);

    for i = 0 , team:getIndexMax() do
       local target = team:getTeamUnit(i);
       if target ~= nil then
           if target:getBurstState() == kBurstState_active then
               return value;
           end
       end
    end

    return 0;
end

--特定のユニット
function id_35(unit,other,condition,value,value1,value2,value3)
    if unit:getBaseID3() == value1  or unit:getBaseID3() == value2  or unit:getBaseID3() == value3 then
        return value;
    end
    return 0;
end

--効果対象が◯状態かつスキル・奥義のみ
function id_36(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    if not (skill:getSkillType() == 1 or skill:getSkillType() == 2) then
        return 0;
    end

    if skill:getSkillType() ~= value2 then
        return 0;
    end

    if unit:getUnitState() ~= kUnitState_skill then
        return 0;
    end

    condition:setRemoveOnResetState(true);

    local cond = unit:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil then
        return value;
    end

    return 0;
end

--スキル・奥義のみ
function id_37(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    if not (skill:getSkillType() == 1 or skill:getSkillType() == 2) then
        return 0;
    end

    if unit:getUnitState() ~= kUnitState_skill then
        return 0;
    end

   return value;
end

--攻撃力依存
function id_38(unit,other,condition,value,value1,value2,value3)
    local v = unit:getCalcPower() * 10;
    v = v * value1 / 100;

    return value + v;
end


function id_39(unit,other,condition,value,value1,value2,value3)
    return value;
end

--HPの割合千分率
function id_40(unit,other,condition,value,value1,value2,value3)
    local v = unit:getHP() * value1
    v = v / 1000;
    v = v + value;
    if v > value2 then
        v = value2;
    end

    return v;
end

--段階的に効果アップ
function id_41(unit,other,condition,value,value1,value2,value3)
    condition:setID(value2);
    return value;
end

--攻撃相手が◯状態かつスキル・奥義のみ
function id_42(unit,other,condition,value,value1,value2,value3)
    if value2 ~= 0 then
        condition:setRemoveOnResetState(true);

        local skill = unit:getActiveBattleSkill();

        ---奥義タイプ判定
        if skill == nil then
            return 0;
        else
            if value2 == 1 then
                ---スキル
                if skill:getSkillType() ~= 1 then
                    return 0
                end
            elseif value2 == 2 then
                ---奥義系全て
                if skill:getSkillType() ~= 2 then
                    return 0
                end
            elseif value2 == 7 then
                ---真奥義
                if not skill:isBurst2() then
                    return 0
                end
            elseif value2 == 8 then
                ---ファントムバレット
                if not skill:isPhantomBulletAny() then
                    return 0
                end
            elseif value2 == 9 then
                ---超奥義
                if not skill:isBurst3() then
                    return 0
                end
            elseif value2 == 10 then
                ---真奥義&超奥義
                if not skill:isBurst2() and not skill:isBurst3() then
                    return 0
                end
            end
        end
    end

    local cond = nil
    if other then
        cond = other:getTeamUnitCondition():findConditionWithType(value1);
    end
    if cond ~= nil then
        if value3 == 1 then
            return 0;
        else
            return value;
        end
    end

    if value3 == 1 then
        return value;
    else
        return 0;
    end
end

--相手の誰かが◯状態
function id_43(unit,other,condition,value,value1,value2,value3)
    local team = megast.Battle:getInstance():getTeam(not unit:getisPlayer());
	if megast.Battle:getInstance():isPvp() then
       	team = megast.Battle:getInstance():getTeam(not unit:getisPvpPlayer());
	end
    condition:setRemoveOnResetState(true);

    for i = 0 , team:getIndexMax() do
       local target = team:getTeamUnit(i);
       if target ~= nil then
           local cond = target:getTeamUnitCondition():findConditionWithType(value1);
           if cond ~= nil then
               return value;
           end
       end
    end

    return 0;
end

--回復量修正用
function id_44(unit,other,condition,value,value1,value2,value3)
    return value;
end

--自分のHPが◯％〜◯％の時 かつ回復量修正用
function id_45(unit,other,condition,value,value1,value2,value3)
    if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 then
        return value;
    end

    return 0;
end

--自分以外
function id_46(unit,other,condition,value,value1,value2,value3)
    return value;
end

--割合回復用
function id_47(unit,other,condition,value,value1,value2,value3)
    return other:getCalcHPMAX() * value / 100;
end

--交互に付与
function id_48(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_49(unit,other,condition,value,value1,value2,value3)
    if other:getBreakPoint() <= 0 and unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType == value1 then
        return value;
    end

    return 0;
end

--竜族一時退避用
function id_50(unit,other,condition,value,value1,value2,value3)

    return value;
end

--攻撃相手のHPが◯%以下
function id_51(unit,other,condition,value,value1,value2,value3)
    local per =  other:getHPPercent() * 100;
    if per <= value1 then
        return value;
    end

    return 0;
end

--魔族が神族に攻撃した時
function id_52(unit,other,condition,value,value1,value2,value3)


    return value;
end

--パーティに特定のユニット
function id_53(unit,other,condition,value,value1,value2,value3)

    for i = 0 , 6 do
        teamunit = unit:getTeam():getTeamUnit(i);
        if teamunit ~= nil then
            if teamunit:getBaseID3() == value1 or teamunit:getBaseID3() == value2 or teamunit:getBaseID3() == value3 then
                return value;
            end
        end
    end

    return 0;
end

--物理攻撃の時
function id_54(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 1 and other:getElementType() == value1 then
        return value;
    end

    return 0;
end

--魔法攻撃の時
function id_55(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 2 then
        return value;
    end

    return 0;
end

--相手が巨大ボス
function id_56(unit,other,condition,value,value1,value2,value3)
    if other:getSize() == 3 then
        return value;
    end

    return 0;
end

--奥義ゲージが最大
function id_57(unit,other,condition,value,value1,value2,value3)
    if unit:getBurstPoint() >= 100 then
        return value;
    end

    return 0;
end

--奥義攻撃
--ピジブル・エグゼキューター
--神魔統帥シーリアの奥義
function id_58(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 2 then
        return value;
    end

    return 0;
end

--装備攻撃
function id_59(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 3 or type == 6 then
        return value;
    end

    return 0;
end

--ボスブレイク中
function id_60(unit,other,condition,value,value1,value2,value3)
    local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
    if boss ~= nil and boss:getBreakPoint() <= 0 then
        return value;
    end

    return 0;
end

--開封制限付き重複あり
function id_61(unit,other,condition,value,value1,value2,value3)
    return value;
end


 --制限時間付きパッシヴ
function id_62(unit,other,condition,value,value1,value2,value3)
    if condition:getIsPassive() == true then
        condition:setIsPassive(false);
    end
    return value;
end

 --時間で効果上昇
function id_63(unit,other,condition,value,value1,value2,value3)
    local time = BattleControl:get():getTime();
    if time > value1 then
        time = value1;
    end
    value = value * time / value1;
    return value;
end

--次に使用する奥義に効果
function id_64(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 2 then
        condition:setRemoveOnResetState(true);
        return value;
    end
    return 0;
end

 --HP以上奥義に効果
function id_65(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    local per = unit:getHPPercent() * 100;
    if type == 2 and per >= value1 then
        return value;
    end
    return 0;
end

 --ヘイトターゲットに効果
function id_66(unit,other,condition,value,value1,value2,value3)
    local target = unit:getHateTarget();
    if target == other then
        return value;
    end
    return 0;
end

 --クリティカル発動時かつエンチャント
function id_67(unit,other,condition,value,value1,value2,value3)
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        return value;
    end

    return 0;
end

--相手の奥義ゲージがvalue1以下
function id_68(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    local per = other:getBurstPoint() / other:getNeedSP() * 100;
    if type == value2 and per <= value1 then
        return value;
    end

    return 0;
end

function id_69(unit,other,condition,value,value1,value2,value3)

    return value;
end

--属性ダメージ
function id_70(unit,other,condition,value,value1,value2,value3)
    if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType == value1 then
        return value;
    end

    return 0;
end

--相手が○状態かつ、その効果が特定のscriptidのとき
function id_71(unit,other,condition,value,value1,value2,value3)
    if other == nil then
        return 0
    end
    local cond = other:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil and cond:getScriptID() == value2 then
         return value;
    end

    return 0;
end

--ボスがブレイク中じゃないときに付与
function id_72(unit,other,condition,value,value1,value2,value3)
    return value;
end

--ボスがブレイク中のときに付与
function id_73(unit,other,condition,value,value1,value2,value3)
    return value;
end

--行動速度FIX
function id_74(unit,other,condition,value,value1,value2,value3)
    return value;
end

--自身がブレイク
function id_75(unit,other,condition,value,value1,value2,value3)
    if unit:getBreakPoint() <= 0 then
        return value;
    end

    return 0;
end

--スキルのみ
function id_76(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if unit:getUnitState() == kUnitState_attack then
        return 0;
    end
    if type == 1 then
        return value;
    end

    return 0;
end

--グループIDを上書き
function id_77(unit,other,condition,value,value1,value2,value3)
    condition:setGroupID(value1);
    return value;
end

--特定の属性以外
function id_79(unit,other,condition,value,value1,value2,value3)
    if unit:getElementType() ~= value1 then
        return value;
    end
    return 0;
end

--覚醒ロイの絶氷判断用 (覚醒ロイのユニットID)
function id_101036211(unit,other,condition,value,value1,value2,value3)
    return 1;
end

--奥義ゲージ自然減少FIX
function id_1043(unit,other,condition,value,value1,value2,value3)
    unit:setBurstPoint(unit:getBurstPoint() + value);
    if unit:getBurstPoint() < 0 then
        unit:setBurstPoint(0);
    end
    return 0;
end

--効果対象が◯属性かつクリティカル
function id_80(unit,other,condition,value,value1,value2,value3)
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if unit:getElementType() == value1 and critical == true then
        return value;
    end
    return 0;
end

--効果対象が◯属性かつ受けた攻撃が奥義
function id_81(unit,other,condition,value,value1,value2,value3)
    if other:getBurstState() ~= kBurstState_active then
         return 0;
    end

    if unit:getElementType() == value1 then
        return value;
    end
    return 0;
end

--１回だけ発動 かつValue1族
function id_82(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    condition:setRemoveOnResetState(true);
    return value;
end

--ボスのブレイク値がvalue1％以下
function id_83(unit,other,condition,value,value1,value2,value3)

    return value;
end

--特定のIndexの相手に対してかつ奥義のとき
function id_84(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 2 and other:getIndex() == value1 then
        condition:setRemoveOnResetState(true);
        return value;
    end
    return 0;
end

--自分のHPが◯％〜◯％の時に付与
function id_85(unit,other,condition,value,value1,value2,value3)
    return value;
end


--ボスのHPがvalue1％以下のとき
function id_86(unit,other,condition,value,value1,value2,value3)
    local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
    if boss == nil then
        return 0;
    end
    local per = boss:getHPPercent() * 100;
    if per <= value1 then
        return value;
    else
        return 0;
    end
end


--特定のユニットかつ、クリティカル発生時
function id_2235(unit,other,condition,value,value1,value2,value3)
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical == false then
        return 0;
    end

    if unit:getBaseID3() ~= value1 then
        return 0;
    end

    if value2 == nil then
        return value;
    end

    local skill = unit:getActiveBattleSkill();

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if skill == nil and value2 == 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    return value;
end

--相手がブレイク中かつクリティカル発生時
function id_2022(unit,other,condition,value,value1,value2,value3)
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical == false then
        return 0;
    end

    if other:getBreakPoint() > 0 then
        return 0;
    end
    return value;
end

--自分がブレイク中かつ被クリティカル発生時
function id_2023(unit,other,condition,value,value1,value2,value3)
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical == false then
        return 0;
    end

    if unit:getBreakPoint() > 0 then
        return 0;
    end
    return value;
end

--相手がブレイク時かつスキル・奥義中のみ
function id_2024(unit,other,condition,value,value1,value2,value3)
    condition:setRemoveOnResetState(true);
    if other:getBreakPoint() > 0 then
        return 0;
    end
    local skill = unit:getActiveBattleSkill();

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value1 ~= 0 and value1 ~= type and value1 ~= 7 then
        return 0;
    end

    if skill == nil and value1 == 7 then
        return 0;
    end

    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end
    return value;
end

--ブレイク中かつサイズがvalue1の相手がいる時に付与
function id_2094(unit,other,condition,value,value1,value2,value3)

    return value;
end

--リアンのコンボカウント用
function id_10179(unit,other,condition,value,value1,value2,value3)
    if value1 == 0 then

        local param = 0;

        for i = 0,7 do
           local teamUnit = unit:getTeam():getTeamUnit(i);
           if teamUnit ~= nil then
                local tmp = teamUnit:getParameter("hitCounter");
                if tmp ~= "" then
                    tmp = tonumber(tmp);
                        if tmp > param then
                        param = tmp;
                    end
                end
           end
        end

        if param >= 99 then
            return value;
        else
            return param * (value / 100) ;
        end
    elseif value1 == 1 then
        local count = unit:getParameter("hitCounter");
        if count ~= "" then
            count = tonumber(count) + 1;
            if count >= 99 then
                return value;
            else
                return value * count / 100  ;
            end
        else
            return 0;
        end
    end
end

--特定のユニットかつHP以下
function id_87(unit,other,condition,value,value1,value2,value3)
    local per =  unit:getHPPercent() * 100;
    if unit:getBaseID3() == value1 and per <= value2 then
        return value;
    end
    return 0;
end

--ボスがブレイク中かつ奥義のとき
function id_88(unit,other,condition,value,value1,value2,value3)
    local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
    if boss == nil or boss:getBreakPoint() > 0 then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 2 then
        return value;
    end
    return 0;
end

--value1属性かつ、HPで効果変動
function id_89(unit,other,condition,value,value1,value2,value3)
    if unit:getElementType() ~= value1 then
        return 0;
    end

    local per =  unit:getHPPercent() * 100;
    local _per = per - value2;
    local rate = _per / (value3 - value2);
    if rate > 1 then
        rate = 1;
    end
    if rate < 0 then
        rate = 0;
    end

    value = value * rate;
    return value;
end

--value1属性かつ、奥義に一回だけ
function id_90(unit,other,condition,value,value1,value2,value3)
    if other:getElementType() ~= value1 then
        return 0;
    end
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 2 then
        condition:setRemoveOnResetState(true);
        return value;
    end
    return 0;
end

--HPが1以上あるとき
function id_91(unit,other,condition,value,value1,value2,value3)
    if unit:getHP() >= 1 then
        return value;
    end
    return 0;
end

--HP回復量アップを強制適用
function id_92(unit,other,condition,value,value1,value2,value3)
    local rate = 1 + unit:getTeamUnitCondition():findConditionValue(110) / 100;
    value = value * rate

    if unit:getHP() >= 1 then
        return value;
    end

    return 0;
end

--value1属性に対して付与、かつ有利属性に対して発動
function id_93(unit,other,condition,value,value1,value2,value3)
    local element = other:getTeamUnitCondition():getDamageAffectInfo().skillElementType;

    if other:getElementType() == 1 and element == 2 then
        return value;
    end

    if other:getElementType() == 2 and element == 3 then
        return value;
    end

    if other:getElementType() == 3 and element == 1 then
        return value;
    end

    if other:getElementType() == 4 and element == 5 then
        return value;
    end

    if other:getElementType() == 5 and element == 4 then
        return value;
    end

    return 0;
end

--大型ボスでかつ、装備ダメージ
function id_94(unit,other,condition,value,value1,value2,value3)
    if other:getSize() ~= 3 then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 3 or type == 6 then
        return value;
    end

    return 0;
end

--value1のIDをもつ効果が付与されているとき付与
function id_95(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();
    if skill == nil and value2 ~= 0 then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    if value3 == 1 then
        condition:setRemoveOnResetState(true);
    end

    return value;
end

--ボス以外のHPがvalue1％以下のとき
function id_96(unit,other,condition,value,value1,value2,value3)
    local isarena = megast.Battle:getInstance():isArena();
    if isarena then
        return 0;
    end

    -- local skill = unit:getActiveBattleSkill();
    -- if skill == nil then
    --     return 0;
    -- end

    -- local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    -- if value2 ~= type and value2 ~= 7 then
    --     return 0;
    -- end

    -- if value2 == 7 and skill:getIndex() ~= 2 then
    --     return 0;
    -- end

    local skill = unit:getActiveBattleSkill();

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if skill == nil and value2 == 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
    if boss == other then
        return 0;
    end
    local per = other:getHPPercent() * 100;
    if per <= value1 then
        return value;
    else
        return 0;
    end
end

--相手が状態異常のとき
function id_97(unit,other,condition,value,value1,value2,value3)
    local cnt = 0
    for _,v in pairs(getBadStatusList()) do
        if other:getTeamUnitCondition():findConditionValue(v) > 0 then
            cnt = cnt + 1;
        end
    end
    if cnt == 0 then
        return 0;
    end

    return value;
end

--レイドバトルのとき付与
function id_98(unit,other,condition,value,value1,value2,value3)
    local israid = megast.Battle:getInstance():isRaid();
    if israid then
        return value;
    end

    return 0;
end

--レイドバトルのとき付与 装備攻撃
function id_99(unit,other,condition,value,value1,value2,value3)
    local israid = megast.Battle:getInstance():isRaid();
    if israid == false then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type == 3 or type == 6 then
        return value;
    end

    return 0;
end

--レイドバトルの場合装備ダメージをValue3に変更
function id_501(unit,other,condition,value,value1,value2,value3)
    local israid = megast.Battle:getInstance():isRaid();
    if israid then
        return value3;
    end

    return value;
end

--クリティカル時に奥義アップ
function id_20182700(unit,other,condition,value,value1,value2,value3)
    return 0;
end

--特定のユニットかつ自分が状態異常のとき
function id_100(unit,other,condition,value,value1,value2,value3)
    local cnt = 0
    for _,v in pairs(getBadStatusList()) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            cnt = cnt + 1;
        end
    end
    if cnt == 0 then
        return 0;
    end


    if unit:getBaseID3() == value1 then
        return value;
    end

    return 0;
end

--奥義攻撃時かつ相手の種族がvalue1~3のいずれかのとき
function id_101(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type ~= 2 then
        return 0;
    end

    if other:getRaceType() == value1 or other:getRaceType() == value2 or other:getRaceType() == value3 then
        return value;
    end

    return 0;
end

--防御力依存
function id_102(unit,other,condition,value,value1,value2,value3)
    local v = unit:getCalcDefence();
    v = v * value1 / 100;

    if v > value2 then
        v = value2;
    end

    return v;
end

--相手パーティの誰かがValue1~3族のいずれかのとき付与
function id_103(unit,other,condition,value,value1,value2,value3)
    if other:getRaceType() == value1 or other:getRaceType() == value2 or other:getRaceType() == value3 then
        return value;
    end
    return value;
end

function id_104(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type ~= 2 then
        return 0;
    end

    if unit:getElementType() == value1 or unit:getElementType() == value2 then
        return value;
    else
        return 0;
    end
end

--value1のスキルタイプにのみ発動。かつ自動削除
function id_105(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value1 ~= 0 and value1 ~= type and value1 ~= 7 then
        return 0;
    end

    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    if value2 == 1 then
        condition:setRemoveOnResetState(true);
    end

    return value;
end

--レイドバトルのとき奥義・真奥義に発動
function id_106(unit,other,condition,value,value1,value2,value3)
    local israid = megast.Battle:getInstance():isRaid();
    if israid == false then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 2 then
        return value;
    end

    return 0;
end

--レイドボスにたいして
function id_107(unit,other,condition,value,value1,value2,value3)
    local israid = megast.Battle:getInstance():isRaid();
    if israid == false then
        return 0;
    end

    local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
    if other == boss then
        return value;
    end

    return 0;
end

--相手がvalue2or3の種族の場合装備ダメージをValue1に変更
function id_502(unit,other,condition,value,value1,value2,value3)
    if other:getRaceType() == value1 or other:getRaceType() == value2 then
        return value3;
    end
    return value;
end

--相手がvalue1属性の場合装備ダメージをValue3に変更
function id_503(unit,other,condition,value,value1,value2,value3)
    if other:getElementType() == value1 then
        return value3;
    end

    return value;
end


--モンハンボスに対して
function id_901(unit,other,condition,value,value1,value2,value3)
    local id = other:getBaseID3();
    if id == 40106 or id == 40107 or id == 40108 or id == 40109 or id == 40110 then
        return value;
    end

    return 0;
end

--特定のユニットかつ、受ける攻撃がValue2タイプの時
function id_335(unit,other,condition,value,value1,value2,value3)
    if unit:getBaseID3() ~= value1 then
        return 0;
    end

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if attribute ~= value2 then
        return 0;
    end

    return value;
end


--特定のユニットかつ、value2のスキルタイプの時
function id_10535(unit,other,condition,value,value1,value2,value3)
    if unit:getBaseID3() ~= value1 then
        return 0;
    end

    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    return value;
end

--効果対象がvalue1族、自身が奥義・真奥義の時
function id_108(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type ~= 2 then
        return 0;
    end

    if unit:getRaceType() == value1 then
        return value;
    end

    return 0;
end

--効果対象がvalue1族、 相手が奥義・真奥義の時
function id_109(unit,other,condition,value,value1,value2,value3)
    if unit:getRaceType() ~= value1 then
        return 0;
    end

    local type = other:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 2 then
        return value;
    end

    --ボスの場合はスキルも対象
    if other:getParentTeamUnit() ~= nil then
        if other:getParentTeamUnit():getIsBoss() == true and type == 1 then
            return value;
        end
    else
        if other:getIsBoss() == true and type == 1 then
            return value;
        end
    end

    return 0;
end

--相手がvalue1族以外だったら
function id_110(unit,other,condition,value,value1,value2,value3)
    if other:getRaceType() ~= value1 then
        return value;
    end

    return 0;
end

--相手がvalue1族以外だったら
function id_1102(unit,other,condition,value,value1,value2,value3)
    if getAncestorUnit(other):getRaceType() ~= value1 then
        return value;
    end

    return 0;
end

-- ご先祖ユニットまで遡る
function getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return getAncestorUnit(unit:getParentTeamUnit())
    end
end


function id_111(unit,other,condition,value,value1,value2,value3)
    return value;
end

--特定のアビリティが自身についていれば発動かつ、対象者がvalue2属性
function id_112(unit,other,condition,value,value1,value2,value3)
    if unit:getElementType() ~= value2 then
        return 0;
    end

    local cond = unit:getTeamUnitCondition():findConditionWithID(value1);
    if cond == nil then
         return 0;
    end

    return value;
end

--特定のアビリティが味方についていれば発動かつ、対象者がvalue2属性
function id_1122(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value3 then
        return 0;
    end

    if unit:getElementType() ~= value2 then
        return 0;
    end

    for i = 0,7 do
        local teamUnit = unit:getTeam():getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithID(value1);
            if cond ~= nil then
                return value;
            end
        end
    end
    return 0;
end

--自分以外に付与かつ魔法ダメージ
function id_113(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 2 then
        return value;
    end

    return 0;
end

--対象がvalue1属性の時付与。スキルタイプが奥義またはvalue2のとき
function id_114(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if value2 ~= 0 and type == value2 then
        return value;
    end

    --後からスキルにも対応できるように改造したためvalue2が空かどうかを確認する必要がある
    if type == 2 and value2 == 0 then
        return value;
    end
    return 0;
end

--対象がvalue1の性別の時付与。
function id_115(unit,other,condition,value,value1,value2,value3)

    return value;
end

--味方のvalue1性別ユニットの人数分効果量倍加
function id_116(unit,other,condition,value,value1,value2,value3)

    return value;
end

--対象のHPが〇〇ほど効果上昇 value1[最小効果量%] value2[最大効果量%] value3[固定追加量] スキル限定版
function id_117(unit,other,condition,value,value1,value2,value3)
    if other == null then
        return value;
    end

    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    if not (skill:getSkillType() == 1) then
        return 0;
    end

    if unit:getUnitState() ~= kUnitState_skill then
        return 0;
    end

    condition:setRemoveOnResetState(true);

    local per =  other:getHPPercent() * 100;
    local _per = per - value1;
    local rate = _per / (value2 - value1);
    if rate > 1 then
        rate = 1;
    end
       print(per);
       print(rate);
    if rate < 0 then
        rate = 0;
    end

    value = value * rate + value3;
    return value;
end

--対象のHPが〇〇ほど効果上昇 value1[最小効果量%] value2[最大効果量%] value3[固定追加量] スキル限定版
function id_118(unit,other,condition,value,value1,value2,value3)
    if other == null then
        return value;
    end

    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    if not (skill:getSkillType() == 2) then
        return 0;
    end

    if unit:getUnitState() ~= kUnitState_skill then
        return 0;
    end

    condition:setRemoveOnResetState(true);

    local per =  other:getHPPercent() * 100;
    local _per = per - value1;
    local rate = _per / (value2 - value1);
    if rate > 1 then
        rate = 1;
    end
       print(per);
       print(rate);
    if rate < 0 then
        rate = 0;
    end

    value = value * rate + value3;
    return value;
end

--攻撃相手もしくは、攻撃してきた相手がvalue1 の性別
function id_119(unit,other,condition,value,value1,value2,value3)
    if other:getSexuality() == value1 then
        return value;
    end

    return 0;
end

 --制限時間付きパッシヴかつ特定ユニット
function id_120(unit,other,condition,value,value1,value2,value3)
    if condition:getIsPassive() == true then
        condition:setIsPassive(false);
    end
    if unit:getBaseID3() == value1  or unit:getBaseID3() == value2  or unit:getBaseID3() == value3 then
        return value;
    end
    return 0;
end

function id_121(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    local element = unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType;
    if (type == 3 or type == 6) and element == value1 then
        return value;
    end


    return 0;
end

function id_264(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    local element = other:getElementType();
    if (type == 3 or type == 6) and element == value1 then
        return value;
    end

    return 0;
end

--自分が◯状態かつスキル・奥義が終わると削除
function id_122(unit,other,condition,value,value1,value2,value3)
    condition:setRemoveOnResetState(true);
    local cond = unit:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil then
        return value;
    end

    return 0;
end

--特定の種族（全体用）
function id_123(unit,other,condition,value,value1,value2,value3)

    return value;
end

--カテミラ専用　炎、水、樹属性のうち何種類がPT内に存在するかによって効果変動　光闇には効果なし
function id_124(unit,other,condition,value,value1,value2,value3)
    local lastIndex = 6;
    local units = unit:getTeam()
    local found = 0;
    local attributes = {
        kElementType_Fire,
        kElementType_Aqua,
        kElementType_Earth
    }
    for index = 0, lastIndex do
        local unit = units:getTeamUnit(index,true)--死んでいても取得する
        if unit ~= nil then
            for i=1,table.maxn(attributes) do
                if unit:getElementType() == attributes[i] then
                    --PTを構成する属性の種類を数えるので、一度判定を行ったものについてはそれ以降判断しない。
                    attributes[i] = nil;
                    found = found + 1;
                    break
                end
            end
        end
    end

    return value * found;
end


--使用者が特定の属性かつ奥義攻撃
function id_125(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 2 then
        return value;
    end

    return 0;
end

--使用者のレベル
function id_126(unit,other,condition,value,value1,value2,value3)
    local lv = unit:getLevel();
    if value1 == 0 then
        return value1;
    end
    for i=1,value1-1 do
        lv = lv * lv;
    end
    return value * lv;
end

--自分のHPが◯％〜◯％かつ奥義の時
function id_127(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 and  type == 2 then
        return value;
    end

    return 0;
end

--スキル・奥義が終了すると削除かつ自分以外
function id_128(unit,other,condition,value,value1,value2,value3)
    condition:setRemoveOnResetState(true);
    return value;
end

--パーティに特定のユニットがいない
function id_129(unit,other,condition,value,value1,value2,value3)

    for i = 0 , 6 do
        teamunit = unit:getTeam():getTeamUnit(i);
        if teamunit ~= nil then
            if teamunit:getBaseID3() == value1 or teamunit:getBaseID3() == value2 or teamunit:getBaseID3() == value3 then
                return 0;
            end
        end
    end

    return value;
end

--自身がブレイク
function id_130(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == value1 and unit:getBreakPoint() <= 0 then
        return value;
    end


    return 0;
end

--特定の状態異常の時効果延長
function id_131(unit,other,condition,value,value1,value2,value3)
    if unit:getTeamUnitCondition():findConditionWithType(value1) ~= nil and condition:getValue3() == 0 then
        condition:setTime(condition:getTime() + value2);
        condition:setValue3(1);
        return value;
    end
    return value;
end

--敵が特定の状態異常の時効果増幅
function id_132(unit,other,condition,value,value1,value2,value3)
    if other:getTeamUnitCondition():findConditionWithType(value1) ~= nil then

        return value + value2;
    end
    return value;
end

--特定の状態異常かつクリティカル
function id_133(unit,other,condition,value,value1,value2,value3)
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if other:getTeamUnitCondition():findConditionWithType(value1) ~= nil and critical then
        return value;
    end
    return 0;
end

--自分以外かつHP消費
function id_134(unit,other,condition,value,value1,value2,value3)
    return value;
end


 --特定ユニットかつ対象がvalue2属
function id_135(unit,other,condition,value,value1,value2,value3)
    if unit:getBaseID3() == value1 and other:getRaceType() == value2 then
        return value;
    end
    return 0;
end

--自分が特定の状態異常かつ特定の属性
function id_136(unit,other,condition,value,value1,value2,value3)
    if unit:getTeamUnitCondition():findConditionWithType(value1) ~= nil and other:getElementType() == value2 then
        return value;
    end
    return 0;
end

--指定したバフが自身にかかっていれば
function id_138(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = unit:getTeamUnitCondition():findConditionValue(value1);
    local cond2 = unit:getTeamUnitCondition():findConditionValue(value2);
    local cond3 = unit:getTeamUnitCondition():findConditionValue(value3);
    local cond4 = unit:getTeamUnitCondition():findConditionValue(value4);

    if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 and unit:getElementType() == value5 then
        return value;
    end
    return 0;
end

function id_1381(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = unit:getTeamUnitCondition():findConditionValue(value1);
    local cond2 = unit:getTeamUnitCondition():findConditionValue(value2);
    local cond3 = unit:getTeamUnitCondition():findConditionValue(value3);
    local cond4 = unit:getTeamUnitCondition():findConditionValue(value4);
    local cond5 = unit:getTeamUnitCondition():findConditionValue(value5);

    if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and cond5 > 0 and unit:getElementType() == 1 then
        return value;
    end
    return 0;
end

function id_1382(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = unit:getTeamUnitCondition():findConditionValue(value1);
    local cond2 = unit:getTeamUnitCondition():findConditionValue(value2);
    local cond3 = unit:getTeamUnitCondition():findConditionValue(value3);
    local cond4 = unit:getTeamUnitCondition():findConditionValue(value4);
    local cond5 = unit:getTeamUnitCondition():findConditionValue(value5);

    if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and cond5 > 0 and unit:getElementType() == 2 then
        return value;
    end
    return 0;
end

function id_1383(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = unit:getTeamUnitCondition():findConditionValue(value1);
    local cond2 = unit:getTeamUnitCondition():findConditionValue(value2);
    local cond3 = unit:getTeamUnitCondition():findConditionValue(value3);
    local cond4 = unit:getTeamUnitCondition():findConditionValue(value4);
    local cond5 = unit:getTeamUnitCondition():findConditionValue(value5);

    if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and cond5 > 0 and unit:getElementType() == 3 then
        return value;
    end
    return 0;
end

function id_1384(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = unit:getTeamUnitCondition():findConditionValue(value1);
    local cond2 = unit:getTeamUnitCondition():findConditionValue(value2);
    local cond3 = unit:getTeamUnitCondition():findConditionValue(value3);
    local cond4 = unit:getTeamUnitCondition():findConditionValue(value4);
    local cond5 = unit:getTeamUnitCondition():findConditionValue(value5);

    if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and cond5 > 0 and unit:getElementType() == 4 then
        return value;
    end
    return 0;
end

function id_1385(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = unit:getTeamUnitCondition():findConditionValue(value1);
    local cond2 = unit:getTeamUnitCondition():findConditionValue(value2);
    local cond3 = unit:getTeamUnitCondition():findConditionValue(value3);
    local cond4 = unit:getTeamUnitCondition():findConditionValue(value4);
    local cond5 = unit:getTeamUnitCondition():findConditionValue(value5);

    if cond1 > 0 and cond2 > 0 and cond3 > 0 and cond4 > 0 and cond5 > 0 and unit:getElementType() == 5 then
        return value;
    end
    return 0;
end

--対象のHP消費
function id_139(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_140(unit,other,condition,value,value1,value2,value3)
    if other:getSize() ~= 3 then
        return 0;
    end
    return value
end

--自分のHPが◯％〜◯％かつ奥義の時かつ行動終了時に削除
function id_141(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    condition:setRemoveOnResetState(true);
    if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 and  type == 2 then
        return value;
    end

    return 0;
end

--自分のHPが◯％〜◯％　付与時に弾くバージョン
function id_142(unit,other,condition,value,value1,value2,value3)

    return value;
end

--自分のHPが◯％〜◯％かつクリティカル
function id_143(unit,other,condition,value,value1,value2,value3)
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 and  critical then
        return value;
    end

    return 0;
end

--攻撃相手もしくは、攻撃してきた相手が有利属性(付与時に属性判定)かつvalue1の効果が自身にかかっている場合のみ発動
function id_144(unit,other,condition,value,value1,value2,value3)
    local element = unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType;
    local cond = unit:getTeamUnitCondition():findConditionWithID(value1);

    if cond == nil then
         return 0;
    end

    if unit:getElementType() == 1 and element == 3 then
        return value;
    end

    if unit:getElementType() == 2 and element == 1 then
        return value;
    end

    if unit:getElementType() == 3 and element == 2 then
        return value;
    end

    if unit:getElementType() == 4 and element == 5 then
        return value;
    end

    if unit:getElementType() == 5 and element == 4 then
        return value;
    end

    return 0;
end

--value1属性のユニットに対して付与　HP回復量アップを強制適用
function id_145(unit,other,condition,value,value1,value2,value3)
    local rate = 1 + unit:getTeamUnitCondition():findConditionValue(110) / 100;
    value = value * rate

    if unit:getHP() >= 1 then
        return value;
    end

    return 0;
end


--セティス専用
function id_146(unit,other,condition,value,value1,value2,value3)
    return value;
end

--段階的に効果アップ(アイコンの数字も変わる版)
function id_147(unit,other,condition,value,value1,value2,value3)

    return value;
end

--パーティに特定のユニットかつ奥義中かつクリティカル
function id_148(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    if skill:getSkillType() == 2 then
        return 0;
    end

    if unit:getUnitState() ~= kUnitState_skill then
        return 0;
    end

    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical == false then
        return 0;
    end

    for i = 0 , 6 do
        teamunit = unit:getTeam():getTeamUnit(i);
        if teamunit ~= nil then
            if teamunit:getBaseID3() == value1 or teamunit:getBaseID3() == value2 or teamunit:getBaseID3() == value3 then
                return value;
            end
        end
    end

    return 0;
end


--１回だけ発動
function id_149(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();

    if skill == nil then
        return 0
    elseif value1 == 1 then
        if skill:getSkillType() ~= 1 then
            return 0
        end
    elseif value1 == 2 then
        if skill:getSkillType() ~= 2 then
            return 0
        end
    elseif value1 == 7 then
        if not skill:isBurst2() then
            return 0
        end
    elseif value1 == 8 then
        if not skill:isPhantomBulletAny() then
            return 0
        end
    elseif value1 == 9 then
        if not skill:isBurst3() then
            return 0
        end
    elseif value1 == 10 then
        if not skill:isBurst2() and not skill:isBurst3() then
            return 0
        end
    end

    condition:setRemoveOnResetState(true);
    return value;
end

--ボスブレイク中　かつ特定のユニット
function id_150(unit,other,condition,value,value1,value2,value3)
    local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
    if boss ~= nil and boss:getBreakPoint() <= 0 then
        return value;
    end

    return 0;
end


--value1属性のみに付与　受けるダメージが魔法のとき
function id_151(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 2 then
        return value;
    end
    return 0;
end

--value１属性にのみ付与　装備攻撃
function id_152(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 3 or type == 6 then
        return value;
    end

    return 0;
end

--ボスの奥義ゲージ
function id_153(unit,other,condition,value,value1,value2,value3)
    local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
    if boss == nil then
        return 0;
    end
    local rate = boss:getBurstPoint() * 100 / boss:getNeedSP();

    if boss:getBurstState() == kBurstState_active then
        rate = 100;
    end

    local rank = rate/value1;
    return value * math.floor(rank);
end


--受けたダメージに対する割合
function id_154(unit,other,condition,value,value1,value2,value3)
    -- if other:getInvincibleTime() > 0 then
    --     return 0;
    -- end

    -- if unit:getBurstState() ~= kBurstState_active then
    --     return 0;
    -- end
    local power = other:getCalcPower();
    local skill  = other:getActiveBattleSkill();
    local animRate = other:getAnimationDamageRateSum();
    if animRate > 50 then
        animRate = 50;
    end
    local dealdamage = 0;
    local cond = other:getTeamUnitCondition():findConditionValue(17);
    if cond ~= 0 then
        dealdamage = (cond / 100);
    end

    if skill ~= nil then
        power = skill:getDamageRate() * power;
    end
    if dealdamage > 0 then
        power =  power + (power * dealdamage);
    end
    power = power / animRate;

    local isarena = megast.Battle:getInstance():isArena();
    if isarena then
        return (value + (power * value1 / 100))/100;
    end

    return value + (power * value1 / 100)
end


function id_155(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_156(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_157(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_158(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

--自分のHPが◯％〜◯％の時
function id_160(unit,other,condition,value,value1,value2,value3)
    if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 then
        return value;
    end
    return 0;
end

function id_161(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_162(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_163(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_164(unit,other,condition,value,value1,value2,value3,value4,value5)

    local team = megast.Battle:getInstance():getTeam(other:getisPlayer());
	if megast.Battle:getInstance():isPvp() then
       	team = megast.Battle:getInstance():getTeam(other:getisPvpPlayer());
	end
    local isTarget = false;
    for i = 0,7 do
         local teamUnit = team:getTeamUnit(i);
         if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond ~= nil then
                    if cond:getProtectTarget() == other:getIndex() then
                        isTarget = true;
                    end
                end
         end
    end

    if isTarget then
        return value;
    end

    return 0;
end

--自分のパーティの誰かがValue1~3族のいずれかのとき付与
function id_165(unit,other,condition,value,value1,value2,value3)
    return value;
end

--対象のHPが〇〇ほど効果上昇 value1[最小効果量%] value2[最大効果量%] value3[固定追加量] 真奥義限定
function id_166(unit,other,condition,value,value1,value2,value3)
    if other == null then
        return value;
    end

    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    if skill:getSkillType() ~= 2 or skill:isBurst2() == false then
        return 0;
    end

    if unit:getUnitState() ~= kUnitState_skill then
        return 0;
    end

    condition:setRemoveOnResetState(true);

    local per =  other:getHPPercent() * 100;
    local _per = per - value1;
    local rate = _per / (value2 - value1);
    if rate > 1 then
        rate = 1;
    end
       print(per);
       print(rate);
    if rate < 0 then
        rate = 0;
    end

    value = value * rate + value3;
    return value;
end

--受けるダメージが物理のとき
function id_167(unit,other,condition,value,value1,value2,value3,value4)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == value4 then
        return value;
    end

    return 0;
end

--本来単体の効果を全体化する
function id_168(unit,other,condition,value,value1,value2,value3,value4)

    return value;
end

--value1 属性に対して付与　value2属性に対して発動　物理か魔法か全部か選べる
function id_169(unit,other,condition,value,value1,value2,value3,value4)
    if other:getElementType() ~= value2 then
        return 0;
    end
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value3 and value3 ~= 0 then
        return 0;
    end

    return value;
end

function id_170(unit,other,condition,value,value1,value2,value3,value4)

    local cond = unit:getTeamUnitCondition():findConditionWithGroupID(value1);
    if cond ~= nil then
        return value;
    end
    return 0;

end

function id_1702(unit,other,condition,value,value1,value2,value3,value4)
    return value;
end

function id_1703(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value3 == 0 then
        local ancestor = getAncestorUnit(other);
        if value1 == 1 then
            ancestor = getAncestorUnit(unit);
        end

        local cond = ancestor:getTeamUnitCondition():findConditionWithGroupID(value2);
        if cond ~= nil then
            return value;
        end
        return 0;
    end
    return value;
end

function id_171(unit,other,condition,value,value1,value2,value3,value4)
    local val = unit:getTeamUnitCondition():findConditionValue(value3);

    local cond = unit:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil then
        return val;
    end

    if value2 == 0 then
        return 0;
    end
    local cond2 = unit:getTeamUnitCondition():findConditionWithType(value2);
    if cond2 ~= nil then
        return val;
    end

    return 0;

end

--段階的効果上昇　決定版
function id_173(unit,other,condition,value,value1,value2,value3,value4)

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value4 and value4 ~= 0 then
        return 0;
    end

    --unitがなければエラーを避けるためにこの時点でもうOKしちゃう
    if unit == nil then
        return value;
    end

    local skill = unit:getActiveBattleSkill();
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value3 ~= 0 and value3 ~= type and value3 ~= 7 then
        return 0;
    end

    if skill == nil and value3 == 7 then
        return 0;
    end

    if value3 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end


    return value;
end

--段階的効果上昇　決定版
function id_1732(unit,other,condition,value,value1,value2,value3,value4)

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value4 and value4 ~= 0 then
        return 0;
    end

    --unitがなければエラーを避けるためにこの時点でもうOKしちゃう
    if unit == nil then
        return value;
    end

    local skill = unit:getActiveBattleSkill();
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value3 ~= 0 and value3 ~= type and value3 ~= 7 then
        return 0;
    end

    if skill == nil and value3 == 7 then
        return 0;
    end

    if value3 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end


    return value;
end

function id_172(unit,other,condition,value,value1,value2,value3,value4)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == value2 then
        return value;
    end

    return 0;

end

 --時間で効果上昇
function id_174(unit,other,condition,value,value1,value2,value3)
    local time = BattleControl:get():getTime();
    if time > value1 then
        time = value1;
    end
    value = value * time / value1;
    local stage = math.floor(value3 * time/value1);
    if stage == 0 then
         return value;
    end

    if stage > value1 then
        stage = value1;
    end
    if stage == value3 then
        condition:setNumber(10);
    else
        condition:setNumber(stage);
    end

    megast.Battle:getInstance():updateConditionView();

    return value;
end

--特定の種族がいるとき　物理・魔法に対して発動
function id_175(unit,other,condition,value,value1,value2,value3,value4)

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value4 and value4 ~= 0 then
        return 0;
    end


    return value;
end


--特定の属性（相手）
function id_1469 (unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();

    if other:getElementType() == value1 then
        return value;
    end
    return 0;
end


--対象が特定の種族かつ物理・魔法判断
function id_176(unit,other,condition,value,value1,value2,value3,value4)

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value2 and value2 ~= 0 then
        return 0;
    end


    return value;
end


--発動者が特定の種族かつ属性ダメージ
function id_177(unit,other,condition,value,value1,value2,value3)
    if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType == value2 then
        return value;
    end

    return 0;
end


function id_178(unit,other,condition,value,value1,value2,value3)

    return value;
end


--敵を撃破した時にSP回復　ただしluaと併用する前提なので単体では機能せず
function id_179(unit,other,condition,value,value1,value2,value3)
    local index = unit:getIndex();
    local keyStr = "lastAttackChecker"
    local keyStr2 = "index"

    local parentUnit = other:getParentTeamUnit();

    local attackerIndex = parentUnit ~= nil and parentUnit:getIndex() or other:getIndex();


    local paramName = keyStr..value1..keyStr2..index;

    local buffParent = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(value1,true);
	if megast.Battle:getInstance():isPvp() then
    	buffParent = megast.Battle:getInstance():getTeam(not unit:getisPvpPlayer()):getTeamUnit(value1,true);
	end

    if buffParent == nil then
        return 0;
    end

    buffParent:setParameter(paramName,attackerIndex);


    return 0;
end

--相手が状態異常のとき
function id_180(unit,other,condition,value,value1,value2,value3)

    return value;
end


function id_181(unit,other,condition,value,value1,value2,value3)

    return value;
end

function id_182(unit,other,condition,value,value1,value2,value3)

    return value;
end

function id_183(unit,other,condition,value,value1,value2,value3)
    if other:getSize() ~= value1 then
        return 0;
    end
    return value
end

function id_184(unit,other,condition,value,value1,value2,value3)

    return value * value3;
end

function id_185(unit,other,condition,value,value1,value2,value3)

    return value;
end

function id_186(unit,other,condition,value,value1,value2,value3)

    return value;
end

function id_1862(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == 2 then
        return value;
    end
    return 0;
end

function id_187(unit,other,condition,value,value1,value2,value3)
    if condition:getValue5() ~= megast.Battle:getInstance().m_wave then
        unit:getTeamUnitCondition():removeCondition(condition);
        return 0;
    end

    local team = megast.Battle:getInstance():getTeam(not unit:getisPlayer());
    if megast.Battle:getInstance():isPvp() then
        if megast.Battle:getInstance():isPvpHost() then
            team = megast.Battle:getInstance():getTeam(not unit:getisPvpPlayer());
        else
            team = megast.Battle:getInstance():getTeam(unit:getisPvpPlayer());
        end
    end


    for i = 0 , team:getIndexMax() do
       local target = team:getTeamUnit(i);
       if target ~= nil then
           local buff = target:getTeamUnitCondition():findConditionWithID(condition:getValue3());
           if buff ~= nil then
                unit:getTeamUnitCondition():removeCondition(condition);
                return 0;
           end
       end
    end


    local buffid = condition:getID();
    local duration = condition:getValue2();
    unit:getTeamUnitCondition():removeCondition(condition);
    unit:getTeamUnitCondition():addCondition(buffid,89,100,duration,79)
    -- BattleControl:get():pushEnemyInfomation(""..duration,100,100,100,1);
    return 0;
end

function id_1872(unit,other,condition,value,value1,value2,value3)
    if condition:getValue5() ~= megast.Battle:getInstance().m_wave then
        unit:getTeamUnitCondition():removeCondition(condition);
        return 0;
    end

    local team = megast.Battle:getInstance():getTeam(not unit:getisPlayer());
    if megast.Battle:getInstance():isPvp() then
        team = megast.Battle:getInstance():getTeam(not unit:getisPvpPlayer());
    end


    for i = 0 , team:getIndexMax() do
        local target = team:getTeamUnit(i);
        if target ~= nil then
            local buff = target:getTeamUnitCondition():findConditionWithID(condition:getValue3());
            if buff ~= nil then
                unit:getTeamUnitCondition():removeCondition(condition);
                return 0;
            end
        end
    end


    local buffid = condition:getID();
    local duration = condition:getValue2();
    unit:getTeamUnitCondition():removeCondition(condition);
    unit:getTeamUnitCondition():addCondition(buffid,condition:getValue4(),100,duration,condition:getValue1())
    -- BattleControl:get():pushEnemyInfomation(""..duration,100,100,100,1);
    return 0;
end

function id_188(unit,other,condition,value,value1,value2,value3)
    if value1 ~= 0 then
        local rate = 1 + unit:getTeamUnitCondition():findConditionValue(110) / 100;
        value = value * rate

        if unit:getHP() >= 1 then
            return value;
        end
        return 0;
    end
    return value;
end

function id_189(unit,other,condition,value,value1,value2,value3,value4)
    local num = value4
    if num == nil then
        num = 0
    end
    return moveType(unit,value,num);
end


function id_190(unit,other,condition,value,value1,value2,value3)
    return value;
end

--発動者がvalue1属性　かつvalue2の攻撃タイプに対して
function id_191(unit,other,condition,value,value1,value2,value3,value4)

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value2 and value2 ~= 0 then
        return 0;
    end

    return value;
end


function id_192(unit,other,condition,value,value1,value2,value3,value4)

    if other:getRaceType() == value1 then
        return value;
    end

    if other:getParentTeamUnit() ~= nil then
        if other:getParentTeamUnit():getRaceType() == value1 then
            return value;
        end
    end

    return 0;

end

function id_193(unit,other,condition,value,value1,value2,value3,value4)
    return value;
end

--発動者がvalue1の種族　かつvalue2の攻撃タイプに対して
function id_194(unit,other,condition,value,value1,value2,value3,value4)

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value2 and value2 ~= 0 then
        return 0;
    end

    return value;
end



--相手の残ブレイク割合が少なければ少ないほど
function id_195(unit,other,condition,value,value1,value2,value3,value4)

    local per = 1 - other:getBreakPoint() / other:getBaseBreakCapacity();

    if per > 1 then
        per = 1;
    end

    if per < 0 then
        per = 0;
    end

    local width = value2 - value1;


    return value1 + width * per;
end

--指定したバフが自身にかかっていれば 付与判定なし版
function id_196(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = nil;
    local cond2 = nil;
    local cond3 = nil;
    local cond4 = nil;
    if value1 ~= 0 then
        cond1 = unit:getTeamUnitCondition():findConditionWithID(value1);
    end
    if value2 ~= 0 then
        cond2 = unit:getTeamUnitCondition():findConditionWithID(value2);
    end
    if value3 ~= 0 then
        cond3 = unit:getTeamUnitCondition():findConditionWithID(value3);
    end
    if value4 ~= 0 then
        cond4 = unit:getTeamUnitCondition():findConditionWithID(value4);
    end
    if cond1 ~= nil or cond2 ~= nil or cond3 ~= nil or cond4 ~= nil then
        return value;
    end
    return 0;
end

--自分のHPが◯％〜◯％の時
function id_197(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 and attribute == value3 then
        return value;
    end

    return 0;
end

--自分のHPが◯％〜◯％の時
function id_198(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_199(unit,other,condition,value,value1,value2,value3)
    return value;
end


function id_200(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_201(unit,other,condition,value,value1,value2,value3)
    local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
    if value1 == 1 and other ~= boss then
        return 0;
    end

    if value1 == 2 and other == boss then
        return 0;
    end


    local skill = unit:getActiveBattleSkill();
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if skill == nil and value2 == 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end
    return value;
end

function id_202(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 3 or type == 6 then
        return value;
    end
    return 0;
end

function id_203(unit,other,condition,value,value1,value2,value3)
    return value;
end


function id_204(unit,other,condition,value,value1,value2,value3)
    return value;
end


--対象との距離によって効果変更　value1だけ離れている場合効果最大　最大で等倍
function id_205(unit,other,condition,value,value1,value2,value3)

    if other:getParentTeamUnit() ~= nil then
        other = other:getParentTeamUnit();
    end
    local distance = unit:getAnimationPositionX() - other:getAnimationPositionX();

    distance = math.abs(distance);
    if distance > value1 then
        distance = value1;
    end

    distance = distance - value2;


    if distance < 0 then
        distance = 0;
    end

    return distance/(value1 - value2) * value;
end



function id_206(unit,other,condition,value,value1,value2,value3)
    local v2 = condition:getValue2();
    if v2 == 1 then
        return 0;
    end
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        local pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(8,1);
        unit:addSP(value1 * pvpCorrectionValue);
        condition:setValue2(1);
    end
    return 0;
end

function id_207(unit,other,condition,value,value1,value2,value3,value4,value5)
    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end

    if skill:getSkillType() ~= 2 then
        return 0;
    end


    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        if other ~= nil then
            local cond = other:getTeamUnitCondition():findConditionWithGroupID(value2);
            if cond ~= nil then
                if cond:getPriority() <= condition:getPriority() then
                    other:getTeamUnitCondition():removeCondition(cond);
                    local buff = other:getTeamUnitCondition():addCondition(value1,17,value3,value4,value5);
                    buff:setGroupID(value2);
                    buff:setPriority(condition:getPriority());
                end
            else
                local buff = other:getTeamUnitCondition():addCondition(value1,17,value3,value4,value5);
                buff:setGroupID(value2);
                buff:setPriority(condition:getPriority());
            end
        end
    end
    return 0;
end

function id_208(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_209(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_210(unit,other,condition,value,value1,value2,value3,value4)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if value4 == 0 then
        return value;
    end
    if attribute == value4 then
        return value;
    end
    return 0;
end

function id_211(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_212(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_213(unit,other,condition,value,value1,value2,value3)
    return value;
end

 --制限時間付きパッシヴ
function id_214(unit,other,condition,value,value1,value2,value3)
    local time = BattleControl:get():getTime();
    if time > value1 then
        return 0;
    end
    return value;
end

function id_215(unit,other,condition,value,value1,value2,value3)
    if other:getTeamUnitCondition():getDamageAffectInfo().skillElementType == value1 then
        return value;
    end

    return 0;
end

function id_216(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_217(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = unit:getTeamUnitCondition():findConditionValue(value1);
    local cond2 = unit:getTeamUnitCondition():findConditionValue(value2);
    local cond3 = unit:getTeamUnitCondition():findConditionValue(value3);

    if cond1 > 0 and cond2 > 0 and cond3 > 0 then
        return value;
    end
    return 0;
end

function id_218(unit,other,condition,value,value1,value2,value3,value4,value5)
   if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType == value3 then
        return value;
   end
        return 0;
end


--HP回復量アップを強制適用　属性判定付き
function id_219(unit,other,condition,value,value1,value2,value3)
    local rate = 1 + unit:getTeamUnitCondition():findConditionValue(110) / 100;
    value = value * rate

    if unit:getHP() >= 1 then
        return value;
    end

    return 0;
end

function id_220(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_221(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_222(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond = other:getTeamUnitCondition():findConditionWithGroupID(value1);
    if cond ~= nil and cond:getValue() >= value2 then
        return value;
    end
    return 0;
end

function id_223(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

--出血専用
function id_224(unit,other,condition,value,value1,value2,value3,value4)

    return value;
end

--出血専用
function id_2242(unit,other,condition,value,value1,value2,value3,value4)

    return value;
end

--『ゼロ＝リコーダ』奥義ゲージUP
function id_225(unit,other,condition,value,value1,value2,value3,value4,value5)
    local count = condition:getValue2();
    local nowWave = megast.Battle:getInstance().m_wave;
    local beforeWave = condition:getValue5();
    if nowWave ~= beforeWave then
        count = 1;
        condition:setValue2(count);
        condition:setTime(10000);
        condition:setValue5(nowWave);
    end

    if condition:getIsPassive() == true then
        condition:setIsPassive(false);
    end


    if condition:getTime() <= 10000 - (count) * value and unit:isMyunit() then
        unit:setBurstPoint(unit:getBurstPoint() + value1);
        local dist = 10000 - condition:getTime();
        count =  math.ceil(dist/value);
        condition:setValue2(count);
    end

    return 0;

end

--奥義ゲージUP
function id_2252(unit,other,condition,value,value1,value2,value3,value4,value5)
    return 0;
end

 --制限時間付きパッシヴ(属性)
function id_226(unit,other,condition,value,value1,value2,value3)
    if condition:getIsPassive() == true then
        condition:setIsPassive(false);
    end
    if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType ~= value1 and value1 ~= 0 then
        return 0;
    end

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value2 and value2 ~= 0 then
        return 0;
    end

    return value;
end

--制限時間付きパッシヴ(種族)
function id_2262(unit,other,condition,value,value1,value2,value3)
    if condition:getIsPassive() == true then
        condition:setIsPassive(false);
    end

    if unit:getRaceType() ~= value1 then
        return 0;
    end

    return value;
end

--制限時間付きパッシヴ(超神具)
function id_2263(unit,other,condition,value,value1,value2,value3)
    local time = BattleControl:get():getTime();
    if time > condition:getValue3() then
        return 0;
    end

    if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType ~= value1 and value1 ~= 0 then
        return 0;
    end

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value2 and value2 ~= 0 then
        return 0;
    end

    return value;
end

function id_227(unit,other,condition,value,value1,value2,value3)
    local count = 0;
    for i = 0,7 do
        local teamUnit = unit:getTeam():getTeamUnit(i);
        if teamUnit ~= nil then
            if teamUnit:getRaceType() == value1 then
                count = count + 1;
            end
        end
    end
    value = value * count;
    return value;
end


function id_228(unit,other,condition,value,value1,value2,value3)
    if value1 ~= 0 then
        local time = BattleControl:get():getTime();
        if time > value1 then
            return 0;
        end
    end
    local damage = unit:getCalcHPMAX() * value / 100;

    --せっかく計算した割合ダメージだけど、敵の場合や味方の場合、アリーナの場合などで様々な補正が入るためそれを打ち消すための倍率
    local rate = 1;

    local isarena = megast.Battle:getInstance():isArena();

    if unit:getisPlayer() then
        rate = 10;
    end

    if not unit:getisPlayer() and isarena then
        rate = 10;
    end

	if megast.Battle:getInstance():isPvp() then
        rate = 10;
	end

    if unit:getHP() -  math.ceil(damage/5) <= 0 then
        unit:setHP(1);
        return 0;
    end

    return damage * rate;
end

--受けたダメージに対する割合　モーションが終わると削除版
function id_229(unit,other,condition,value,value1,value2,value3)
    condition:setRemoveOnResetState(true);
    local power = other:getCalcPower();
    local skill  = other:getActiveBattleSkill();
    local animRate = other:getAnimationDamageRateSum();
    if animRate > 50 then
        animRate = 50;
    end
    local dealdamage = 0;
    local cond = other:getTeamUnitCondition():findConditionValue(17);
    if cond ~= 0 then
        dealdamage = (cond / 100);
    end

    if skill ~= nil then
        power = skill:getDamageRate() * power;
    end
    if dealdamage > 0 then
        power =  power + (power * dealdamage);
    end
    power = power / animRate;

    local isarena = megast.Battle:getInstance():isArena();
    if isarena then
        return (value + (power * value1 / 100))/100;
    end

    return value + (power * value1 / 100)
end



--奥義ゲージが任意の数値以上の時に適用
function id_230(unit,other,condition,value,value1,value2,value3)
    if unit:getBurstPoint() >= value1 then
        return value;
    end

    return 0;
end

function id_2302(unit,other,condition,value,value1,value2,value3)
    return value;
end

--HP回復量アップを強制適用
function id_231(unit,other,condition,value,value1,value2,value3)

    local element = other:getTeamUnitCondition():getDamageAffectInfo().skillElementType;

    if element ~= value1 then
        return 0;
    end

    local rate = 1 + unit:getTeamUnitCondition():findConditionValue(110) / 100;
    value = value * rate

    if unit:getHP() >= 1 then
        return value;
    end

    return 0;
end


--楔専用
function id_232(unit,other,condition,value,value1,value2,value3,value4)

    return value;
end


function id_233(unit,other,condition,value,value1,value2,value3,value4)
    local skill = unit:getActiveBattleSkill();
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if skill == nil and value2 == 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end


    local rate = 0;
    local targetCond = other:getTeamUnitCondition():findConditionWithID(value1);

    if targetCond ~= nil then
        rate = targetCond:getValue5();

        --バフを見つけたけれど、上昇段階が１段階目の時はvalue5に何も入ってないのでその場合１を入れる。
        if rate == 0 then
            rate = 1;
        end
    end

    return value * rate;
end

function id_234(unit,other,condition,value,value1,value2,value3,value4)

    return value;
end

function id_235(unit,other,condition,value,value1,value2,value3,value4,value5)


    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value3 and value3 ~= 0 then

        return 0;
    end


    if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType ~= value4 and value4 ~= 0 then

        return 0;
    end

    local skill = unit:getActiveBattleSkill();
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value5 ~= 0 and value5 ~= type and value5 ~= 7 then
        return 0;
    end

    if skill == nil and value5 == 7 then
        return 0;
    end

    if value5 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end


    return value;
end

function id_236(unit,other,condition,value,value1,value2,value3,value4,value5)


    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value3 and value3 ~= 0 then

        return 0;
    end


    if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType ~= value4 and value4 ~= 0 then

        return 0;
    end

    local skill = unit:getActiveBattleSkill();
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value5 ~= 0 and value5 ~= type and value5 ~= 7 then
        return 0;
    end

    if skill == nil and value5 == 7 then
        return 0;
    end

    if value5 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end


    return value;
end

function id_237(unit,other,condition,value,value1,value2,value3,value4,value5)


    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value3 and value3 ~= 0 then

        return 0;
    end


    if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType ~= value4 and value4 ~= 0 then

        return 0;
    end

    local skill = unit:getActiveBattleSkill();
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value5 ~= 0 and value5 ~= type and value5 ~= 7 then
        return 0;
    end

    if skill == nil and value5 == 7 then
        return 0;
    end

    if value5 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end


    return value;
end


function id_238(unit,other,condition,value,value1,value2,value3)
    local heal = unit:getCalcHPMAX() * value / 100;
    local rate = 1;

    -- if unit:getisPlayer() then
    --     rate = 10;
    -- end

    -- if unit:getHP() -  math.ceil(heal/5) <= 0 then
    --     unit:setHP(1);
    --     return 0;
    -- end
    condition:setValue4(2004349)
    return heal * rate;
end

function id_239(unit,other,condition,value,value1,value2,value3,value4)

    return value;
end


function id_240(unit,other,condition,value,value1,value2,value3,value4)

    return value;
end



function id_241(unit,other,condition,value,value1,value2,value3)
    local cnt = 0;
    local badStatusList = {
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        129,
        131,
        135
    }

    for k,v in pairs(badStatusList) do
        if other:getTeamUnitCondition():findConditionValue(v) > 0 then
            cnt = cnt + 1;
        end
    end


    return value * cnt;
end

function id_242(unit,other,condition,value,value1,value2,value3)
    local cnt = 0;
    local badStatusList = {
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        129,
        131,
        135
    }

    for k,v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return value;
        end
    end


    return 0;
end

function id_2422(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    local badStatusList = {
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        129,
        131,
        135,
        201,
        202,
        203,
        204,
        205,
        206,
        207,
        208,
        233,
        234
    }
    for _,v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return value;
        end
    end
    return 0;
end

function id_243(unit,other,condition,value,value1,value2,value3,value4)

    return value;
end


--受けたダメージに対する割合　奥義・真奥義中のみ　
function id_244(unit,other,condition,value,value1,value2,value3)
    -- if other:getInvincibleTime() > 0 then
    --     return 0;
    -- end

    -- if unit:getBurstState() ~= kBurstState_active then
    --     return 0;
    -- end

    local power = other:getCalcPower();
    local skill  = other:getActiveBattleSkill();
    local animRate = other:getAnimationDamageRateSum();
    if animRate > 50 then
        animRate = 50;
    end
    local dealdamage = 0;
    local cond = other:getTeamUnitCondition():findConditionValue(17);
    if cond ~= 0 then
        dealdamage = (cond / 100);
    end

    if skill ~= nil then
        power = skill:getDamageRate() * power;
    end
    if dealdamage > 0 then
        power =  power + (power * dealdamage);
    end
    power = power / animRate;

    local isarena = megast.Battle:getInstance():isArena();
    if isarena then
        return (value + (power * value1 / 100))/100;
    end

    return value + (power * value1 / 100)
end

function id_245(unit,other,condition,value,value1,value2,value3,value4)

    return value;
end

function id_246(unit,other,condition,value,value1,value2,value3,value4)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value3 and value3 ~= 0 then

        return 0;
    end


    if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType ~= value4 and value4 ~= 0 then

        return 0;
    end

    local skill = unit:getActiveBattleSkill();
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if skill == nil and value2 == 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    return value;
end

function id_247(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_249(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_250(unit,other,condition,value,value1,value2,value3)
    condition:setValue4(2004349)
    if unit:getElementType() ~= value1 then
        return 0;
    end

    local heal = unit:getCalcHPMAX() * value / 100;
    local rate = 1;

    return heal * rate;
end

--相手が◯状態だったら オービット
function id_251(unit,other,condition,value,value1,value2,value3)
    ---リーゼ回復モード対応
    if value1 == 7 then
        ---自然回復全取得
        local conditionSize = other:getTeamUnitCondition():getAllConditionsSize();
        local condCount = 0
        local isTarget = false
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = other:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getConditionTypeAsInt() == 7 then
                    ---リーゼ回復モードがあるかチェック
                    if cond:getID() == -120 then
                        isTarget = true
                    end
                    condCount = condCount + 1
                end
            end
        end
        ---リーゼ回復モードだけの場合return0
        if isTarget and condCount < 2 then
            return 0
        end
    end

    local parent = other:getParentTeamUnit();
    if parent ~= nil then
        other = parent;
    end


    local cond = other:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil then
        return value;
    end
    if value2 == 0 then
        return 0;
    end
    local cond2 = other:getTeamUnitCondition():findConditionWithType(value2);
    if cond2 ~= nil then
        return value;
    end

    return 0;
end

--相手が状態異常のとき 物理、魔法判別
function id_252(unit,other,condition,value,value1,value2,value3)

    if value1 == 0 then return value end

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if attribute ~= value1 then return 0 end

    return value;
end

--特定のユニット + 装備攻撃
function id_253(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type ~= 3 and type ~= 6 then
        return 0;
    end

    if unit:getBaseID3() == value1  or unit:getBaseID3() == value2  or unit:getBaseID3() == value3 then
        return value;
    end
    return 0;
end

function id_254(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == value3 or value3 == 0 then
        return value;
    end
    return 0;
end

function id_255(unit,other,condition,value,value1,value2,value3)
    if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType == value1 then
        return value;
    end

    return 0;
end

function id_256(unit,other,condition,value,value1,value2,value3)
    return value;
end

-- 出血レベル
function id_257(unit,other,condition,value,value1,value2,value3)
    local buff = other:getTeamUnitCondition():findConditionWithGroupID(21011)
    if buff ~= nil and buff:getValue5() >= value1 then
        return value
    end
    return 0;
end

-- カウントダウン
function id_258(unit,other,condition,value,value1,value2,value3)
    if condition:getNumber() <= 1 and condition:getTime() > 0.01 then
        condition:setTime(0.01)
    end
    if condition:getNumber() > 0 then
        condition:setNumber(condition:getNumber() - 1)
        megast.Battle:getInstance():updateConditionView()
        return value
    else
        return 0
    end
end


--クリティカルじゃないとき
function id_259(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();
    if value1 == 1 then
        return value;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if skill == nil and value2 == 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if not critical then
        return value;
    end

    return 0;
end

function id_260(unit,other,condition,value,value1,value2,value3)

    if value2 ~= 0 then
        if value3 ~= 0 then
            local time = BattleControl:get():getTime();
            if time > value3 then
                return 0;
            end
        end
        local damage = unit:getCalcHPMAX() * value / 100;

        --せっかく計算した割合ダメージだけど、敵の場合や味方の場合、アリーナの場合などで様々な補正が入るためそれを打ち消すための倍率
        local rate = 1;

        local isarena = megast.Battle:getInstance():isArena();

        if unit:getisPlayer() then
            rate = 10;
        end

        if not unit:getisPlayer() and isarena then
            rate = 10;
        end

        if megast.Battle:getInstance():isPvp() then
            rate = 10;
        end

        if unit:getHP() -  math.ceil(damage/5) <= 0 then
            unit:setHP(1);
            return 0;
        end

        return damage * rate;
    end
    return value;
end

--状態異常ではない
function id_261(unit,other,condition,value,value1,value2,value3)
    for _,v in pairs(getBadStatusList()) do
        if v ~= value3 and unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return 0;
        end
    end

    if value2 == 0 then
        ---判定なし
        return value
    elseif value2 == 1 then
        ---物理判定
        local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 1 then
            return value;
        end
    elseif value2 == 2 then
        ---魔法判定
        local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 2 then
            return value;
        end
    elseif value2 == 3 then
        ---クリティカル判定
        local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
        if critical then
            return value;
        end
    end
    return 0;
end

--クリティカル判定
function id_262(unit,other,condition,value,value1,value2,value3)
    local skill = unit:getActiveBattleSkill();
    if value1 == 1 then
        return value;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value2 ~= 0 and value2 ~= type and value2 ~= 7 then
        return 0;
    end

    if skill == nil and value2 == 7 then
        return 0;
    end

    if value2 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        return value;
    end

    return 0;
end

--１回だけ発動
function id_265(unit,other,condition,value,value1,value2,value3,value4)
    local skill = unit:getActiveBattleSkill();

    --value4がある場合は動く
    if value4 ~= 0 then
        local cond = unit:getTeamUnitCondition():findConditionWithID(value4)
        if cond ~= nil then
            if value1 == 7 then
                if skill ~= nil then
                    if skill:isBurst2() then
                        return 0
                    else
                        cond:setTime(0)
                    end
                end
            else
                return 0
            end
        end
    end

    if skill == nil then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value1 ~= 0 and value1 ~= type and value1 ~= 7 then
        return 0;
    end

    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    condition:setRemoveOnResetState(true);
    if unit:getElementType() == value2 then
        value = value3
    end

    return value;
end

function id_266(unit,other,condition,value,value1,value2,value3,value4)

    return value;
end

function id_267(unit,other,condition,value,value1,value2,value3,value4,value5)
    local team = megast.Battle:getInstance():getTeam(unit:getisPlayer());
    if megast.Battle:getInstance():isPvp() then
        team = megast.Battle:getInstance():getTeam(unit:getisPvpPlayer());
    end
    local isTarget = false;
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                if cond:getProtectTarget() == unit:getIndex() then
                    isTarget = true;
                end
            end
        end
    end
    if isTarget then
        return value;
    end
    return 0;
end

--value3時のみ/自分が◯状態だったら
function id_268(unit,other,condition,value,value1,value2,value3)
    --value3時のみ
    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    end
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value3 ~= 0 and value3 ~= type and value3 ~= 7 then
        return 0;
    end
    if value3 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    --自分が◯状態だったら
    local cond = unit:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil then
        return value;
    end
    if value2 == 0 then
        return 0;
    end
    local cond2 = unit:getTeamUnitCondition():findConditionWithType(value2);
    if cond2 ~= nil then
        return value;
    end

    return 0;
end

--自分が特定の状態異常かつ特定の属性攻撃
function id_269(unit,other,condition,value,value1,value2,value3)
    if unit:getTeamUnitCondition():findConditionWithType(value1) ~= nil and other:getTeamUnitCondition():getDamageAffectInfo().skillElementType == value2 then
        return value;
    end
    return 0;
end

--変身中有効
function id_270(unit,other,condition,value,value1,value2,value3)
    if unit:getIsChangeUnit() then
        return value;
    end
    return 0;
end

--自身が状態異常でない,かつスキル・奥義中のみ
function id_271(unit,other,condition,value,value1,value2,value3)

    if value2 == 0 then
        for _,v in pairs(getBadStatusList()) do
            if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
                return 0;
            end
        end
    end

    local skill = unit:getActiveBattleSkill();

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value1 ~= 0 and value1 ~= type and value1 ~= 7 then
        return 0;
    end

    if skill == nil and value1 == 7 then
        return 0;
    end

    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end
    return value;
end

function id_274(unit,other,condition,value,value1,value2,value3)
    local buff  = nil
    buff = other:getTeamUnitCondition():addCondition(274,21,value1,30,0)
    buff:setScriptID(267)
    local cond = nil
    cond = unit:getTeamUnitCondition():addCondition(274,240,0,30,0)
    cond:setScriptID(274)
    return 0
end

--１回だけ発動
function id_275(unit,other,condition,value,value1,value2,value3,value4)
    local skill = unit:getActiveBattleSkill();

    --value4がある場合は動く
    if value4 ~= 0 then
        local cond = unit:getTeamUnitCondition():findConditionWithID(value4)
        if cond ~= nil then
            if value1 == 7 then
                if skill ~= nil then
                    if skill:getIndex() == 4 then
                        cond:setRemoveOnResetState(true);
                        return 0
                    elseif skill:isBurst2() then
                        return 0
                    else
                        cond:setTime(0)
                    end
                end
            else
                return 0
            end
        end
    end

    if skill == nil then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value1 ~= 0 and value1 ~= type and value1 ~= 7 then
        return 0;
    end

    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then
        ---PBでもない場合
        if skill:getIndex() ~= 4 then
            return 0;
        end
    end
    condition:setRemoveOnResetState(true);

    return value;
end

--１回だけ発動
function id_276(unit,other,condition,value,value1,value2,value3,value4)
    local skill = unit:getActiveBattleSkill();

    --value4がある場合は動く
    if value4 ~= 0 then
        local cond = unit:getTeamUnitCondition():findConditionWithID(value4)
        if cond ~= nil then
            if value1 == 7 then
                if skill ~= nil then
                    if skill:getIndex() == 4 then
                        cond:setRemoveOnResetState(true);
                        return 0
                    elseif skill:isBurst2() then
                        return 0
                    else
                        cond:setTime(0)
                    end
                end
            else
                return 0
            end
        end
    end

    if skill == nil then
        return 0;
    end

    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value1 ~= 0 and value1 ~= type and value1 ~= 7 then
        return 0;
    end

    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then
        ---PBでもない場合
        if skill:getIndex() ~= 4 then
            return 0;
        end
    end
    condition:setRemoveOnResetState(true);

    return value;
end

function id_277(unit,other,condition,value,value1,value2,value3)
    local buff  = nil
    buff = other:getTeamUnitCondition():addCondition(277,21,value1,30,0)
    buff:setScriptID(279)
    buff:setValue1(value2)

    local cond = nil
    cond = unit:getTeamUnitCondition():addCondition(277,240,0,30,0)
    cond:setScriptID(277)
    return 0
end

function id_278(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

--自分が◯状態だったら
function id_279(unit,other,condition,value,value1,value2,value3)
    ---リーゼ回復モード対応
    if value1 == 7 then
        ---自然回復全取得
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        local condCount = 0
        local isTarget = false
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getConditionTypeAsInt() == 7 then
                    ---リーゼ回復モードがあるかチェック
                    if cond:getID() == -120 then
                        isTarget = true
                    end
                    condCount = condCount + 1
                end
            end
        end
        ---リーゼ回復モードだけの場合return0
        if isTarget and condCount < 2 then
            return 0
        end
    end

    ---自分が◯状態だったら
    local cond = unit:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil then
        return value;
    end

    if value2 == 0 then
        return 0;
    end
    local cond2 = unit:getTeamUnitCondition():findConditionWithType(value2);
    if cond2 ~= nil then
        return value;
    end

    return 0;
end

---受けるダメージがvalue3のとき
function id_280(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if attribute == value3 then
        return value;
    end
    return 0;
end

function id_281(unit,other,condition,value,value1,value2,value3)
    value = unit:getCalcHPMAX() * value * 0.01
    value = math.floor(value)
    return value
end

---HP回復量アップを強制適用+script62
function id_282(unit,other,condition,value,value1,value2,value3)
    if condition:getIsPassive() == true then
        condition:setIsPassive(false);
    end
    ---HP回復量アップを強制適用
    local rate = 1 + unit:getTeamUnitCondition():findConditionValue(110) / 100;
    value = value * rate
    if unit:getHP() >= 1 then
        return value;
    end
    return 0;
end

---X族キラー
function id_283(unit,other,condition,value,value1,value2,value3)
    local buff  = nil
    local ID = 283
    if value3 ~= 0 then
        ID = value3
    end
    buff = other:getTeamUnitCondition():addCondition(ID,21,value1,30,0)
    buff:setScriptID(16)
    buff:setValue1(value2)

    local cond = nil
    cond = unit:getTeamUnitCondition():addCondition(ID,240,0,30,0)
    cond:setScriptID(283)
    return 0
end

---script62+時間後強制的に効果0
function id_284(unit,other,condition,value,value1,value2,value3)
    if condition:getIsPassive() == true then
        condition:setIsPassive(false);
    end
    if condition:getTime() > 0 then
        return value;
    end
    return 0;
end

function id_285(unit,other,condition,value,value1,value2,value3)

    return value;
end

function id_286(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value2 ~= 0 then
        return moveType(unit,value,value2)
    elseif value4 ~= 0 then
        return elementType(unit,value,value4)
    elseif value5 ~= 0 then
        return raceType(unit,value,value5)
    end
    return value
end

function id_287(unit,other,condition,value,value1,value2,value3)

    return value;
end

function id_288(unit,other,condition,value,value1,value2,value3)
    if value2 ~= 1 then
        local count = 0;
        for i = 0,7 do
            local teamUnit = unit:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getRaceType() == value1 then
                    count = count + 1;
                end
            end
        end
        value = value * count;
    end
    return value;
end

function id_289(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_290(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    if skill == nil then
        return value
    end
    if skill:getBattleItem():getItemTypeAsInt() == value1 then
        return value
    else
        return 0
    end
end

function id_291(unit,other,condition,value,value1,value2,value3)
    return value;
end

--効果対象がvalue1族かつvalue2攻撃のみ
function id_292(unit,other,condition,value,value1,value2,value3)
    if unit:getRaceType() == value1 then
        return moveType(unit,value,value2)
    end
    return 0;
end

function id_293(unit,other,condition,value,value1,value2,value3)
    value = value * summoner.Utility.getUnitHealthRate(unit)
    return moveType(unit,value,value1)
end

function id_294(unit,other,condition,value,value1,value2,value3)
    return value
end

function id_295(unit,other,condition,value,value1,value2,value3)
    for _,v in pairs(getBadStatus89to97()) do
        local cond = other:getTeamUnitCondition():findConditionWithType(v);
        if cond ~= nil then
            return value
        end
    end
    return 0
end

function id_296(unit,other,condition,value,value1,value2,value3)
    local buff = unit:getTeamUnitCondition():addCondition(297,30,0,99999,0)
    buff:setScriptID(297)
    buff:setValue1(value1)
    return value
end

function id_297(unit,other,condition,value,value1,value2,value3)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getHP() == myTeamUnit:getCalcHPMAX() then
                myTeamUnit:addSPWithPvpCorrection(value1)
            end
        end
    end
    unit:getTeamUnitCondition():removeCondition(condition)
    return value
end

--自分のHPが◯％〜◯％の時
function id_299(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value5 == 1 then
        return value
    end
    local elementType = unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType
    if value4 == 1 then elementType = unit:getElementType() end

    if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 and elementType == value3 then
        return value;
    end

    return 0;
end

function id_300(unit,other,condition,value,value1,value2,value3)
    return value
end

function id_301(unit,other,condition,value,value1,value2,value3)
    return value
end

function id_302(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_303(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_304(unit,other,condition,value,value1,value2,value3,value4,value5)
    if elementType(other,1,value2) == 0 then
        return 0
    end
    return moveType(unit,value,value1)
end

function id_305(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value
end

---X属性キラー
function id_306(unit,other,condition,value,value1,value2,value3)
    local buff  = nil
    local ID = 306
    if value3 ~= 0 then
        ID = value3
    end
    buff = other:getTeamUnitCondition():addCondition(ID,21,value1,30,0)
    buff:setScriptID(12)
    buff:setValue1(value2)

    local cond = nil
    cond = unit:getTeamUnitCondition():addCondition(ID,240,0,30,0)
    cond:setScriptID(306)
    return 0
end

function id_307(unit,other,condition,value,value1,value2,value3)
    if value2 == 0 then
        local count = 0;
        for i = 0,7 do
            local teamUnit = unit:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getElementType() == value1 then
                    count = count + 1;
                end
            end
        end
        value = value * count;
    end
    return moveType(unit,value,value3);
end

function id_308(unit,other,condition,value,value1,value2,value3)
    -- 属性指定がなければそのまま
    if value2 == 0 or value2 == nil then
        return moveType(unit,value,value1)
    end
    local element = other:getTeamUnitCondition():getDamageAffectInfo().skillElementType;
    -- 属性指定があればその属性であれば返す
    if element == value2 then
        return moveType(unit,value,value1)
    end
    return 0
end

function id_309(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value1)
end

function id_310(unit,other,condition,value,value1,value2,value3)

    if value1 == 0 then
        return value;
    end

    local skill = unit:getActiveBattleSkill();
    local type = 0;
    if skill ~= nil then
        type = skill:getSkillType();
    end


    if value1 ~= 0 and value1 ~= type and value1 ~= 7 and value1 ~= 8 then

        return 0;
    end

    if skill == nil and value1 == 7 then

        return 0;
    end

    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then

        return 0;
    end

    return value;
end

function id_311(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_312(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value2)
end

function id_313(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value2)
end

function id_314(unit,other,condition,value,value1,value2,value3)
    local heal = unit:getCalcHPMAX() * value / 100;
    local rate = 1;

    return heal * rate;
end

function id_315(unit,other,condition,value,value1,value2,value3)
    return value
end

--特定の属性以外(相手)
function id_316(unit,other,condition,value,value1,value2,value3)
    if other:getElementType() ~= value1 then
        return value;
    end
    return 0;
end

--特定の属性以外(使用者)
function id_317(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value2);
end

--value１属性以外に付与　装備攻撃
function id_318(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type == 3 or type == 6 then
        return value;
    end
    return 0;
end

function id_319(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_320(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_321(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_322(unit,other,condition,value,value1,value2,value3,value4)
    return moveType(unit,value,value4);
end

function id_323(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

--発動者がvalue1の種族　かつvalue2の攻撃タイプに対して
function id_324(unit,other,condition,value,value1,value2,value3,value4)

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute ~= value2 and value2 ~= 0 then
        return 0;
    end

    return value;
end

--スキル・奥義中のみかつ相手が◯状態だったら
function id_325(unit,other,condition,value,value1,value2,value3)
    local returnFLG = false
    --相手が◯状態だったら
    local cond = other:getTeamUnitCondition():findConditionWithType(value2);
    if cond ~= nil then
        returnFLG = true
    end
    if value3 == nil then
        return 0;
    end

    local cond2 = unit:getTeamUnitCondition():findConditionWithType(value3);
    if cond2 ~= nil then
        returnFLG = true
    end

    --スキル・奥義中のみ
    local skill = unit:getActiveBattleSkill();
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if value1 ~= 0 and value1 ~= type and value1 ~= 7 and value1 ~= 8 then
        return 0;
    end

    if skill == nil and value1 == 7 then
        return 0;
    end

    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    if not returnFLG then
        return 0
    end

    return value;
end

function id_326(unit,other,condition,value,value1,value2,value3)
    if value2 == 1 then
        local heal = unit:getCalcHPMAX() * value / 100;
        local rate = 1;
        return heal * rate;
    end
    return value
end

function id_327(unit,other,condition,value,value1,value2,value3,value4,value5)
    return moveType(unit,value,value3)
end

function id_328(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value
end

function id_329(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value
end

function id_330(unit,other,condition,value,value1,value2,value3)
    if other:getSize() == 3 then
        return 0;
    end
    return value
end

--特定のユニット、自分のHPが◯％〜◯％かつクリティカル
function id_331(unit,other,condition,value,value1,value2,value3,value4,value5)
    if unit:getBaseID3() == value1  or unit:getBaseID3() == value2  or unit:getBaseID3() == value3 then
        local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
        if (unit:getHPPercent() * 100) >= value4 and (unit:getHPPercent() * 100) <= value5 and  critical then
            return value;
        end
    end
    return 0;
end

function id_332(unit,other,condition,value,value1,value2,value3)
    local v2 = condition:getValue2();
    if v2 == 1 then
        return 0;
    end
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        local pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(8,1);
        unit:addSP(value1 * pvpCorrectionValue);
        condition:setValue2(1);
    end
    return 0;
end

--対象(value1) のHPがvalue4%以上、value3に数値ありで「より大きく」or「より小さく」
function id_333(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value5 == 1 then
        return value;
    end

    local targetUnit = nil
    if value1 == 0 then
        targetUnit = unit
    else
        targetUnit = other
    end

    local unit = getAncestorUnit(targetUnit)
    local per =  unit:getHPPercent() * 100;
    if value2 == 0 then
        if value3 == 0 then
            if per >= value4 then
                return value;
            end
        else
            if per > value4 then
                return value;
            end
        end
    else
        if value3 == 0 then
            if per <= value4 then
                return value;
            end
        else
            if per < value4 then
                return value;
            end
        end
    end
    return 0;
end

--１回だけ発動
function id_334(unit,other,condition,value,value1,value2,value3,value4)
    local skill = unit:getActiveBattleSkill();

    --value4がある場合は動く
    if value4 ~= 0 then
        local cond = unit:getTeamUnitCondition():findConditionWithID(value4)
        if cond ~= nil then
            ---連続使用時特別対応
            if cond:getValue2() == 1 then
                if elementType(unit,value3,value2) ~= 0 then
                    value = value3
                end
                cond:setRemoveOnResetState(true);
                return value
            end
            return 0
        end
    end

    ---奥義タイプ判定
    if skill == nil then
        return 0;
    else
        if value1 == 1 then
            ---スキル
            if skill:getSkillType() ~= 1 then
                return 0
            end
        elseif value1 == 2 then
            ---奥義系全て
            if skill:getSkillType() ~= 2 then
                return 0
            end
        elseif value1 == 7 then
            ---真奥義
            if not skill:isBurst2() then
                return 0
            end
        elseif value1 == 8 then
            ---ファントムバレット
            if not skill:isPhantomBulletAny() then
                return 0
            end
        elseif value1 == 9 then
            ---超奥義
            if not skill:isBurst3() then
                return 0
            end
        elseif value1 == 10 then
            ---真奥義&超奥義
            if not skill:isBurst2() and not skill:isBurst3() then
                return 0
            end
        end
    end
    if elementType(unit,value3,value2) ~= 0 then
        value = value3
    end
    condition:setRemoveOnResetState(true);
    return value;
end

function id_336(unit,other,condition,value,value1,value2,value3)
    return value
end

function id_337(unit,other,condition,value,value1,value2,value3)
    return value
end

function id_338(unit,other,condition,value,value1,value2,value3)
    unit:addSPWithPvpCorrection(value1)
    return 0
end

--１回だけ発動
function id_339(unit,other,condition,value,value1,value2,value3,value4,value5)
    local skill = unit:getActiveBattleSkill();

    --value4がある場合は動く
    if value4 ~= 0 then
        local cond = unit:getTeamUnitCondition():findConditionWithID(value4)
        if cond ~= nil then
            ---連続使用時特別対応
            if cond:getValue2() == 1 then
                cond:setRemoveOnResetState(true);
                return value
            end
            return 0
        end
    end

    ---奥義タイプ判定
    if skill == nil then
        return 0;
    else
        if value1 == 1 then
            ---スキル
            if skill:getSkillType() ~= 1 then
                return 0
            end
        elseif value1 == 2 then
            ---奥義系全て
            if skill:getSkillType() ~= 2 then
                return 0
            end
        elseif value1 == 7 then
            ---真奥義
            if not skill:isBurst2() then
                return 0
            end
        elseif value1 == 8 then
            ---ファントムバレット
            if not skill:isPhantomBulletAny() then
                return 0
            end
        elseif value1 == 9 then
            ---超奥義
            if not skill:isBurst3() then
                return 0
            end
        elseif value1 == 10 then
            ---真奥義&超奥義
            if not skill:isBurst2() and not skill:isBurst3() then
                return 0
            end
        end
    end
    condition:setRemoveOnResetState(true);

    return value;
end

function id_340(unit,other,condition,value,value1,value2,value3)
    local heal = unit:getCalcHPMAX() * value / 100;
    local rate = 1;
    return heal * rate;
end

function id_341(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_342(unit,other,condition,value,value1,value2,value3)
    if value2 == 1 then
        condition:setRemoveOnResetState(true);
    end

    local skill = unit:getActiveBattleSkill();
    ---奥義タイプ判定
    if skill == nil then
        return 0;
    else
        if value1 == 1 then
            ---スキル
            if skill:getSkillType() ~= 1 then
                return 0
            end
        elseif value1 == 2 then
            ---奥義系全て
            if skill:getSkillType() ~= 2 then
                return 0
            end
        elseif value1 == 7 then
            ---真奥義
            if not skill:isBurst2() then
                return 0
            end
        elseif value1 == 8 then
            ---ファントムバレット
            if not skill:isPhantomBulletAny() then
                return 0
            end
        elseif value1 == 9 then
            ---超奥義
            if not skill:isBurst3() then
                return 0
            end
        end
    end
    return value
end

function id_343(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value3);
end

--効果発動者がリーダーかつ効果対象がX族
function id_344(unit,other,condition,value,value1,value2,value3)
    if unit:getIsLeader() then
        return value;
    end

    local value = id_16(unit,other,condition,value,value1,value2,value3);
    if value == 0 then
        return 0;
    end
    return value;
end

--効果発動者が状態異常でない
function id_345(unit,other,condition,value,value1,value2,value3)
    local targetUnit = unit
    if value3 ~= 0 then
        targetUnit = other
    end

    if value1 ~= 1 then
        for k,v in pairs(getBadStatusList()) do
            if targetUnit:getTeamUnitCondition():findConditionValue(v) > 0 then
                return 0;
            end
        end
    end
    return moveType(unit,value,value2)
end

function id_346(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = unit:getTeamUnitCondition():findConditionValue(value1);
    local cond2 = unit:getTeamUnitCondition():findConditionValue(value2);
    local cond3 = unit:getTeamUnitCondition():findConditionValue(value3);

    if cond1 > 0 and cond2 > 0 and cond3 > 0 then
        return moveType(unit,value,value4)
    end
    return 0;
end

--１回だけ発動
function id_347(unit,other,condition,value,value1,value2,value3,value4,value5)
    local skill = unit:getActiveBattleSkill();

    --value4がある場合は動く
    if value4 ~= 0 then
        local cond = unit:getTeamUnitCondition():findConditionWithID(value4)
        if cond ~= nil then
            ---連続使用時特別対応
            if cond:getValue2() == 1 then
                cond:setRemoveOnResetState(true);
                return value
            end
            return 0
        end
    end

    ---奥義タイプ判定
    if skill == nil then
        return 0;
    else
        if value1 == 1 then
            ---スキル
            if skill:getSkillType() ~= 1 then
                return 0
            end
        elseif value1 == 2 then
            ---奥義系全て
            if skill:getSkillType() ~= 2 then
                return 0
            end
        elseif value1 == 7 then
            ---真奥義
            if not skill:isBurst2() then
                return 0
            end
        elseif value1 == 8 then
            ---ファントムバレット
            if not skill:isPhantomBulletAny() then
                return 0
            end
        elseif value1 == 9 then
            ---超奥義
            if not skill:isBurst3() then
                return 0
            end
        elseif value1 == 10 then
            ---真奥義&超奥義
            if not skill:isBurst2() and not skill:isBurst3() then
                return 0
            end
        end
    end
    condition:setRemoveOnResetState(true);

    return value;
end

--発動者が特定の種族かつ属性ダメージ
function id_348(unit,other,condition,value,value1,value2,value3)
    if unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType == value2 then
        return value;
    end

    return 0;
end

function id_349(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    value = unit:getCalcAttack() * (value * 0.01)
    return value
end

function id_350(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    condition:setRemoveOnResetState(true);
    local skill = unit:getActiveBattleSkill();
    local type = 0;
    if skill ~= nil then
        type = skill:getSkillType();
    end

    if value1 ~= 0 and value1 ~= type and value1 ~= 7 and value1 ~= 8 then
        return 0;
    end

    if skill == nil and value1 == 7 then
        return 0;
    end

    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if attribute == value2 or value2 == 0 then
        return value;
    end
    return 0;
end

function id_351(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    if condition:getTemporaryBuffTypeAsInt() == 6 then
        --summoner.Utility.messageByEnemy("isHpReg"..condition:getTemporaryBuffTypeAsInt())
        local itemValue = unit:getTeamUnitCondition():findConditionValueWithItemType(7,0,value1)
        local allValue = unit:getTeamUnitCondition():findConditionValue(7)
        local fixValue = value * itemValue / allValue
        unit:addTemporaryHealBuffValue(fixValue,value,value1);
        return fixValue
    elseif condition:getTemporaryBuffTypeAsInt() == value1 then
        --summoner.Utility.messageByEnemy("isItem"..condition:getTemporaryBuffTypeAsInt())
        return value
    end
    return 0
end

function id_352(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = unit:getTeamUnitCondition():findConditionValue(value1);
    local cond2 = unit:getTeamUnitCondition():findConditionValue(value2);
    local cond3 = unit:getTeamUnitCondition():findConditionValue(value3);
    local cond4 = unit:getTeamUnitCondition():findConditionValue(value4);

    if (cond1 > 0 or cond2 > 0 or cond3 > 0) and cond4 > 0 then
        return moveType(unit,value,value5)
    end
    return 0;
end

--value1属性に対して付与、かつ有利属性に対して発動
function id_353(unit,other,condition,value,value1,value2,value3)
    local element = other:getTeamUnitCondition():getDamageAffectInfo().skillElementType;

    if other:getElementType() == 1 and element == 2 then
        return value;
    end

    if other:getElementType() == 2 and element == 3 then
        return value;
    end

    if other:getElementType() == 3 and element == 1 then
        return value;
    end

    if other:getElementType() == 4 and element == 5 then
        return value;
    end

    if other:getElementType() == 5 and element == 4 then
        return value;
    end

    return 0;
end

function id_354(unit,other,condition,value,value1,value2,value3)
    local heal = unit:getCalcHPMAX() * value / 100;
    local rate = 1;

    return heal * rate;
end

function id_355(unit,other,condition,value,value1,value2,value3)
    return value
end

function id_356(unit,other,condition,value,value1,value2,value3)
    return value
end

--自分のHPが◯％〜◯％の時
function id_357(unit,other,condition,value,value1,value2,value3)
    if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 then
        return value;
    end
    return 0;
end

function id_359(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_360(unit,other,condition,value,value1,value2,value3)
    if value2 == 0 then
        local raceBox = {}
        for i = 0,7 do
            local teamUnit = unit:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then
                raceBox[teamUnit:getRaceType()] = true
            end
        end
        local count = 0;
        for i,flg in pairs(raceBox) do
            if flg then
                count = count + 1
            end
        end
        value = value * count;
    end
    return moveType(unit,value,value1)
end

function id_361(unit,other,condition,value,value1,value2,value3,value4)
    condition:setRemoveOnResetState(true);
    local skill = unit:getActiveBattleSkill();
    local type = 0;
    if skill ~= nil then
        type = skill:getSkillType();
    end
    if value1 ~= 0 and value1 ~= type and value1 ~= 7 and value1 ~= 8 then
        return 0;
    end
    if skill == nil and value1 == 7 then
        return 0;
    end
    if value1 == 7 and (skill:isBurst2() == false or type ~= 2) then
        return 0;
    end

    local targetUnit = unit
    if value2 == 1 then
        targetUnit = other
    end
    if value4 == 1 then
        if targetUnit:getElementType() ~= value3 then
            return value;
        end
    else
        if targetUnit:getElementType() == value3 then
            return value;
        end
    end
    return 0;
end

function id_362(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    if skill == nil then
        return value
    end

    for k,v in pairs(getBadStatusList()) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return 0
        end
    end

    if value1 == 0 then
        for i = 1,5 do
            if skill:getBattleItem():getItemTypeAsInt() == i then
                return value
            end
        end
    end

    if skill:getBattleItem():getItemTypeAsInt() == value1 then
        return value
    else
        return 0
    end
    return 0
end

function id_363(unit,other,condition,value,value1,value2,value3,value4,value5)
    if unit:getRaceType() ~= value1 then
        return value;
    end
    return 0;
end

--制限時間付きパッシヴ
function id_364(unit,other,condition,value,value1,value2,value3)
    if condition:getIsPassive() == true then
        condition:setIsPassive(false);
        if megast.Battle:getInstance():isPvp() then
            condition:setValue(condition:getValue() / 3)
        end
    end
    --summoner.Utility.messageByEnemy("get"..condition:getValue())
    return value;
end

function id_365(unit,other,condition,value,value1,value2,value3,value4)
    local cond = unit:getTeamUnitCondition():findConditionWithGroupID(value1);
    if cond ~= nil then
        if megast.Battle:getInstance():isPvp() then
            value = value * 2
        end
        return value;
    end
    return 0;
end

function id_366(unit,other,condition,value,value1,value2,value3,value4)
    return value;
end

function id_367(unit,other,condition,value,value1,value2,value3,value4,value5)
    local teamUnit = other
    if value3 == 1 then
        if (teamUnit:getHPPercent() * 100) >= value1 and (teamUnit:getHPPercent() * 100) < value2 then
            value = value + value4
        end
        return attackElementType(unit,value,value5);
    else
        if (teamUnit:getHPPercent() * 100) >= value1 and (teamUnit:getHPPercent() * 100) <= value2 then
            value = value + value4
        end
        return attackElementType(unit,value,value5);
    end
end

--攻撃力と防御力の合計value1につきvalue2%UP
function id_368(unit,other,condition,value,value1,value2,value3,value4,value5)
    value = ((unit:getCalcAttack() + unit:getCalcDefence()) / value1 ) * value2
    return value;
end

--相手が◯状態だったら オービット
function id_369(unit,other,condition,value,value1,value2,value3,value4)
    ---リーゼ回復モード対応
    if value1 == 7 then
        ---自然回復全取得
        local conditionSize = other:getTeamUnitCondition():getAllConditionsSize();
        local condCount = 0
        local isTarget = false
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = other:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getConditionTypeAsInt() == 7 then
                    ---リーゼ回復モードがあるかチェック
                    if cond:getID() == -120 then
                        isTarget = true
                    end
                    condCount = condCount + 1
                end
            end
        end
        ---リーゼ回復モードだけの場合return0
        if isTarget and condCount < 2 then
            return 0
        end
    end

    local parent = other:getParentTeamUnit();
    if parent ~= nil then
        other = parent;
    end

    local cond = other:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil then
        return value;
    end

    if value2 == 0 then
        return 0;
    end

    local cond2 = other:getTeamUnitCondition():findConditionWithType(value2);
    if cond2 ~= nil then
        return value;
    end

    if value3 == 0 then
        return 0;
    end

    local cond3 = other:getTeamUnitCondition():findConditionWithType(value3);
    if cond3 ~= nil then
        return value;
    end

    if value4 == 0 then
        return 0;
    end

    local cond4 = other:getTeamUnitCondition():findConditionWithType(value4);
    if cond4 ~= nil then
        return value;
    end
    return 0;
end

--発動者がvalue1属性以外かつvalue2の攻撃タイプに対して
function id_370(unit,other,condition,value,value1,value2,value3,value4)
    local targetUnit = getAncestorUnit(unit)
    local attribute = targetUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if attribute ~= value2 and value2 ~= 0 then
        return 0;
    end
    return value;
end

function id_371(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_372(unit,other,condition,value,value1,value2,value3,value4,value5)
    local targetUnit = getAncestorUnit(unit)
    return moveType(targetUnit,value,value2)
end

function id_373(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_374(unit,other,condition,value,value1,value2,value3)
    if unit:getElementType() == value1 then
        return value;
    end
    return value2;
end

function id_375(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_376(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_377(unit,other,condition,value,value1,value2,value3,value4,value5)
    return value;
end

function id_378(unit,other,condition,value,value1,value2,value3)
    if value1 == 1 then
        return value
    end

    local targetUnit = getAncestorUnit(unit)
    for _,v in pairs(getBadStatusList()) do
        if v ~= value3 and targetUnit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return 0;
        end
    end

    if value2 == 0 then
        ---判定なし
        return value
    elseif value2 == 1 then
        ---物理判定
        local attribute = targetUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 1 then
            return value;
        end
    elseif value2 == 2 then
        ---魔法判定
        local attribute = targetUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 2 then
            return value;
        end
    elseif value2 == 3 then
        ---クリティカル判定
        local critical = targetUnit:getTeamUnitCondition():getDamageAffectInfo().critical;
        if critical then
            return value;
        end
    end
    return 0;
end

function id_379(unit,other,condition,value,value1,value2,value3)
    if value1 == 0 then
        return value;
    end

    ---奥義タイプ判定
    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    else
        if value1 == 1 then
            ---スキル
            if skill:getSkillType() ~= 1 then
                return 0
            end
        elseif value1 == 2 then
            ---奥義系全て
            if skill:getSkillType() ~= 2 then
                return 0
            end
        elseif value1 == 7 then
            ---真奥義
            if not skill:isBurst2() then
                return 0
            end
        elseif value1 == 8 then
            ---ファントムバレット
            if not skill:isPhantomBulletAny() then
                return 0
            end
        elseif value1 == 9 then
            ---超奥義
            if not skill:isBurst3() then
                return 0
            end
        end
    end
    return value;
end

function id_380(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value2);
end

function id_381(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_382(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_383(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_384(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_385(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_386(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_387(unit,other,condition,value,value1,value2,value3)
    return value;
end

--出血レベル毎に効果を変更する
function id_388(unit,other,condition,value,value1,value2,value3)
    return value
end

function id_389(unit,other,condition,value,value1,value2,value3)
    if value2 == 1 then
        value = unit:getCalcHPMAX() * value / 100;
    end
    return value;
end

function id_390(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_391(unit,other,condition,value,value1,value2,value3)
    if unit:getHP() == unit:getCalcHPMAX() then
        value = value + value1
    end
    return value;
end

function id_392(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_393(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_394(unit,other,condition,value,value1,value2,value3,value4)
    return moveType(unit,value,value4);
end

--相手が奥義発動中
function id_395(unit,other,condition,value,value1,value2,value3)
    local team = megast.Battle:getInstance():getTeam(not unit:getisPlayer());
    if megast.Battle:getInstance():isPvp() then
        team = megast.Battle:getInstance():getTeam(not unit:getisPvpPlayer());
    end
    condition:setRemoveOnResetState(true);

    for i = 0 , team:getIndexMax() do
        local target = team:getTeamUnit(i);
        if target ~= nil then
            if target:getBurstState() == kBurstState_active then
                local fixValue = value + value1
                return fixValue;
            end
        end
    end

    return value;
end

function id_396(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_397(unit,other,condition,value,value1,value2,value3,value4)
    return moveType(unit,value,value4)
end

function id_398(unit,other,condition,value,value1,value2,value3)
    local cnt = 0
    for _,v in pairs(getBadStatusListOut129()) do
        if other:getTeamUnitCondition():findConditionValue(v) > 0 then
            cnt = cnt + 1;
        end
    end
    if cnt == 0 then
        return 0;
    end

    return value;
end

function id_399(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_400(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value3 ~= 0 then
        return moveType(unit,value,value3);
    elseif value4 ~= 0 then
        return elementType(unit,value,value4);
    elseif value5 ~= 0 then
        return attackElementType(unit,value,value5);
    end
    return value;
end

--奥義ゲージが任意の数値以下の時に適用
function id_401(unit,other,condition,value,value1,value2,value3)
    if value2 == 0 then
        if unit:getBurstPoint() <= value1 then
            return value;
        end
        return 0;
    end
    return value;
end

function id_402(unit,other,condition,value,value1,value2,value3,value4,value5)
    local per =  unit:getHPPercent() * 100;
    local num = math.floor(per * (value3 * 0.1))
    value = num
    if num >= value1 then
        value = value1
    elseif num <= value2 then
        value = value2
    end
    return value
end

function id_403(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_404(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_405(unit,other,condition,value,value1,value2,value3)
    local rate = 1;
    local isarena = megast.Battle:getInstance():isArena();
    if unit:getisPlayer() then
        rate = 10;
    end
    if not unit:getisPlayer() and isarena then
        rate = 10;
    end
    if megast.Battle:getInstance():isPvp() then
        rate = 10;
    end
    value = (unit:getCalcHPMAX() * (0.01 * value1) + value2) * rate;
    return value;
end

function id_406(unit,other,condition,value,value1,value2,value3)
    local gb = megast.Battle:getInstance():isGrandBattle()
    if gb then
        value = value + value1
    end
    return value;
end

--ブレイクブースト
function id_407(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    value = (unit:getCalcAttack() / value1) * value2
    return value
end

--(相手を見るScriptIdを介してvalue1バフの効果量を取得 * value2)の効果量で返す
function id_408(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    if other then
        value = unit:getTeamUnitCondition():findConditionValueWithOther(value1,other) * value2;
    end
    return value
end

--相手にvalue1バフがある時発動/奥義,スキル終了時に外れる
function id_409(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    condition:setRemoveOnResetState(true);
    local cond = other:getTeamUnitCondition():findConditionWithType(value1);
    if cond == nil then
        return 0;
    end
    return value
end

function id_410(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value2 == 0 then
        local count = 0;
        for i = 0,7 do
            local teamUnit = unit:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getElementType() == value1 then
                    count = count + 1;
                end
            end
        end
        local rate = megast.Battle:getInstance():getPvpCorrectionValue(condition:getConditionTypeAsInt(),1);
        value = value4 * count * rate;
        condition:setValue(value)
        condition:setPriority(math.abs(value))
    end
    return moveType(unit,value,value3);
end

function id_411(unit,other,condition,value,value1,value2,value3,value4,value5)
    local targetUnit = unit
    if value3 ~= 0 then
        targetUnit = other
    end

    local floor = megast.Battle:getInstance():getCurrentMineFloor();
    local num = targetUnit:getCalcHPMAX() * ((value1 * 0.01) + floor * (value2 * 0.01)) / 100
    value = math.floor(num)
    return value
end

--HP回復量アップを強制適用　相手の種族判定付き
function id_412(unit,other,condition,value,value1,value2,value3,value4,value5)
    local enemyUnit = other
    if other:getParentTeamUnit() ~= nil then
        enemyUnit = other:getParentTeamUnit()
    end
    local flg = false
    local raceTable = {
        [1] = value1,
        [2] = value2,
        [3] = value3,
        [4] = value4,
        [5] = value5,
    }
    for i,v in ipairs(raceTable) do
        if enemyUnit:getRaceType() == v then
            flg = true
        end
    end
    return value
end

--状態異常ではない(ミゼット用)
function id_413(unit,other,condition,value,value1,value2,value3)
    for _,v in pairs(getBadStatusList()) do
        if v ~= value3 and unit:countConditionIgnoreAboutToRemoveCondition(v) > 0 then
            return 0;
        end
    end

    if value2 == 0 then
        ---判定なし
        return value
    elseif value2 == 1 then
        ---物理判定
        local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 1 then
            return value;
        end
    elseif value2 == 2 then
        ---魔法判定
        local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 2 then
            return value;
        end
    elseif value2 == 3 then
        ---クリティカル判定
        local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
        if critical then
            return value;
        end
    end
    return 0;
end

function id_414(unit,other,condition,value,value1,value2,value3)
    if value3 == 0 then
        return value;
    end

    ---奥義タイプ判定
    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    else
        if value3 == 1 then
            ---スキル
            if skill:getSkillType() ~= 1 then
                return 0
            end
        elseif value3 == 2 then
            ---奥義系全て
            if skill:getSkillType() ~= 2 then
                return 0
            end
        elseif value3 == 7 then
            ---真奥義
            if not skill:isBurst2() then
                return 0
            end
        elseif value3 == 8 then
            ---ファントムバレット
            if not skill:isPhantomBulletAny() then
                return 0
            end
        elseif value3 == 9 then
            ---超奥義
            if not skill:isBurst3() then
                return 0
            end
        end
    end
    return value;
end

function id_415(unit,other,condition,value,value1,value2,value3)
    if value1 == 1 then
        return value
    end

    local flg = false
    local targetUnit = getAncestorUnit(unit)
    for _,v in pairs(getBadStatusList()) do
        if v ~= value3 and targetUnit:getTeamUnitCondition():findConditionValue(v) > 0 then
            flg = true
        end
    end

    if flg then
        if value2 == 0 then
            ---判定なし
            return value
        elseif value2 == 1 then
            ---物理判定
            local attribute = targetUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
            if attribute == 1 then
                return value;
            end
        elseif value2 == 2 then
            ---魔法判定
            local attribute = targetUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
            if attribute == 2 then
                return value;
            end
        elseif value2 == 3 then
            ---クリティカル判定
            local critical = targetUnit:getTeamUnitCondition():getDamageAffectInfo().critical;
            if critical then
                return value;
            end
        end
    end
    return 0;
end

function id_416(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_417(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_418(unit,other,condition,value,value1,value2,value3,value4)
    local gb = megast.Battle:getInstance():isGrandBattle()
    if gb then
        local fl = megast.Battle:getInstance():getCurrentGrandBattleFloor();
        -- 100分の1
        local dec = value1 / 100;
        local num = math.atan(fl*dec) * value2 / math.pi * value3;
        --summoner.Utility.messageByEnemy(num,5);

        if value4 == 0 then
            -- 切り捨て
            value = math.floor(num)
        else
            -- 第二位切り捨て
            value = math.floor(num * value4) / value4
        end
    end
    return value;
end

function id_419(unit,other,condition,value,value1,value2,value3)
    if value3 >= 6 then
        return moveType(unit,value,value3 - 5);
    end
    return value
end

function id_420(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value3);
end

function id_421(unit,other,condition,value,value1,value2,value3,value4,value5)
    local flg = false
    local targetUnit = getAncestorUnit(other)
    for _,v in pairs(getBadStatusList()) do
        if v ~= value4 and targetUnit:getTeamUnitCondition():findConditionValue(v) > 0 then
            flg = true
            if v == value3 then
                value = value1
            end
        end
    end

    if flg then
        return moveType(unit,value,value2);
    end
    return 0
end

function id_422(unit,other,condition,value,value1,value2,value3,value4)
    local gb = megast.Battle:getInstance():isGrandBattle()
    if gb then
        local num4 = value4 or 1;
        local area = megast.Battle:getInstance():getCurrentGrandBattleFloor();
        local percent = math.floor((math.atan(area * value1 / 100) * 2 / math.pi * value2 + value3 / 100) * num4) / num4;
        --summoner.Utility.messageByEnemy(percent,5);

        value = math.floor((unit:getCalcHPMAX() * percent) / 100);
    end
    return value;
end

function id_423(unit,other,condition,value,value1,value2,value3,value4)
    local gb = megast.Battle:getInstance():isGrandBattle()
    if gb then
        local floor = megast.Battle:getInstance():getCurrentGrandBattleFloor();
        local num1 = value1 * 0.01;
        local num2 = value2 * 0.01;
        local calc = (floor * num1) + num2
        local damage = unit:getCalcHPMAX() * calc / 100

        local rate = 1
        if unit:getisPlayer() then
            rate = 10;
        end
        ---継続ダメージ専用処理
        if condition:getConditionTypeAsInt() == 129 then
            if unit:getHP() -  math.ceil(damage/5) <= 0 then
                unit:setHP(1);
                return 0;
            end
        end
        value = damage * rate
    end
    return value;
end

function id_424(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value1);
end

function id_425(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_426(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value3);
end

function id_427(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value3);
end

function id_428(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value3);
end

function id_429(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value1);
end

function id_430(unit,other,condition,value,value1,value2,value3)
    return moveType(unit,value,value2);
end

function id_431(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_432(unit,other,condition,value,value1,value2,value3)
    local returnFLG = false
    --相手が◯状態だったら
    local cond = other:getTeamUnitCondition():findConditionWithType(value2);
    if cond ~= nil then
        returnFLG = true
    end
    if value3 == nil then
        return 0;
    end

    local cond2 = unit:getTeamUnitCondition():findConditionWithType(value3);
    if cond2 ~= nil then
        returnFLG = true
    end

    --奥義タイプ判定
    local skill = unit:getActiveBattleSkill();
    if skill == nil then
        return 0;
    else
        if value1 == 1 then
            ---スキル
            if skill:getSkillType() ~= 1 then
                return 0
            end
        elseif value1 == 2 then
            ---奥義系全て
            if skill:getSkillType() ~= 2 then
                return 0
            end
        elseif value1 == 7 then
            ---真奥義
            if not skill:isBurst2() then
                return 0
            end
        elseif value1 == 8 then
            ---ファントムバレット
            if not skill:isPhantomBulletAny() then
                return 0
            end
        elseif value1 == 9 then
            ---超奥義
            if not skill:isBurst3() then
                return 0
            end
        elseif value1 == 10 then
            ---真奥義&超奥義
            if not skill:isBurst2() and not skill:isBurst3() then
                return 0
            end
        end
    end

    if not returnFLG then
        return 0
    end

    condition:setRemoveOnResetState(true);
    return value;
end

function id_433(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    return value;
end

function id_434(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    if skill == nil then
        return value;
    end
    if skill:getBattleItem():getItemTypeAsInt() == value1 then
        return value;
    else
        return 0;
    end
end

function id_442(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_445(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_444(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if unit:getBaseID3() == value1 and attribute == value2 then
        return value;
    end

    return 0;
end

function id_446(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == value2 then
        return value;
    end

    return 0;
end

function id_447(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_448(unit,other,condition,value,value1,value2,value3,value4,value5,skill)
    return value;
end

function id_449(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_450(unit,other,condition,value,value1,value2,value3)
    if value2 ~= 1 then
        local count = 0;
        for i = 0,7 do
            local teamUnit = unit:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getRaceType() == value1 then
                    count = count + 1;
                end
            end
        end
        value = value * count;
    end
    return value;
end

function id_451(unit,other,condition,value,value1,value2,value3)

    local cond = other:getTeamUnitCondition():findConditionWithType(value1);
    if cond ~= nil then
        if value2 == 1 then
            return 0;
        else
            return value;
        end
    end

    if value2 == 1 then
        return value;
    else
        return 0;
    end

end

--装備攻撃(初回時のみ)
function id_452(unit,other,condition,value,value1,value2,value3)
    local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if type == 3 or type == 6 then
        return value;
    end

    return 0;
end

--自身の次に使用する奥義系統の付与重複回数判定(該当の系列使用時に解除)
function id_453(unit,other,condition,value,value1,value2,value3)

    if value1 > 0 then
        local skill = unit:getActiveBattleSkill();

        if skill == nil then
            return 0
        elseif value1 == 1 then
            if skill:getSkillType() ~= 1 then
                return 0
            end
        elseif value1 == 2 then
            if skill:getSkillType() ~= 2 then
                return 0
            end
        elseif value1 == 7 then
            if not skill:isBurst2() then
                return 0
            end
        elseif value1 == 8 then
            if not skill:isPhantomBulletAny() then
                return 0
            end
        elseif value1 == 9 then
            if not skill:isBurst3() then
                return 0
            end
        elseif value1 == 10 then
            if not skill:isBurst2() and not skill:isBurst3() then
                return 0
            end
        end
        condition:setRemoveOnResetState(true);
    end
    return value;
end

function id_454(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_455(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_456(unit,other,condition,value,value1,value2,value3)
    local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;

    if attribute == value2 or value2 == 0 then
        return value;
    end
    return 0;
end

--対象者のHPが◯％〜◯％の時に付与
function id_457(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_458(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_459(unit,other,condition,value,value1,value2,value3,value4)
    local targetUnit = getAncestorUnit(unit)
    local attribute = targetUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if attribute == value1 or value1 == 0 then
        return value;
    end
    return 0;
end

function id_461(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_462(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_463(unit,other,condition,value,value1,value2,value3,value4,value5)
    local buff = unit:getTeamUnitCondition():addCondition(463,30,0,99999,0)
    buff:setScriptID(464)
    buff:setValue1(value1)
    buff:setValue2(value2)
    buff:setValue3(value3)
    buff:setValue4(value4)
    buff:setValue5(value5)
    return value
end

function id_464(unit,other,condition,value,value1,value2,value3,value4,value5)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getHP() == myTeamUnit:getCalcHPMAX() then
                local cond = myTeamUnit:getTeamUnitCondition():findConditionWithGroupID(value4);
                if cond == nil then
                    myTeamUnit:getTeamUnitCondition():removeCondition(cond);
                    local buff = myTeamUnit:getTeamUnitCondition():addCondition(464,17,value1,value2,value3);
                    buff:setGroupID(value4);
                    buff:setPriority(value1);
                    if value5 == 1 then
                        buff:setScriptID(4);
                    elseif value5 == 2 then
                        buff:setScriptID(5);
                    end
                elseif cond ~= nil and cond:getPriority() <= value1 then
                    myTeamUnit:getTeamUnitCondition():removeCondition(cond);
                    local buff = myTeamUnit:getTeamUnitCondition():addCondition(464,17,value1,value2,value3);
                    buff:setGroupID(value4);
                    buff:setPriority(value1);
                    if value5 == 1 then
                        buff:setScriptID(4);
                    elseif value5 == 2 then
                        buff:setScriptID(5);
                    end
                elseif cond ~= nil and cond:getPriority() > value1 then
                    --何もしない
                end
            end
        end
    end
    unit:getTeamUnitCondition():removeCondition(condition)
    return 0
end

function id_465(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value2 ~= 0 then
        return moveType(unit,value,value2)
    elseif value4 ~= 0 then
        return elementType(unit,value,value4)
    end
    return value
end

function id_466(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_467(unit,other,condition,value,value1,value2,value3)
    return value;
end

--クリティカル発動時(該当の系列使用時に解除)
function id_468(unit,other,condition,value,value1,value2,value3)

    condition:setRemoveOnResetState(true);

    if value1 > 0 then
        local skill = unit:getActiveBattleSkill();

        if skill == nil then
            return 0
        elseif value1 == 1 then
            if skill:getSkillType() ~= 1 then
                return 0
            end
        elseif value1 == 2 then
            if skill:getSkillType() ~= 2 then
                return 0
            end
        elseif value1 == 7 then
            if not skill:isBurst2() then
                return 0
            end
        elseif value1 == 8 then
            if not skill:isPhantomBulletAny() then
                return 0
            end
        elseif value1 == 9 then
            if not skill:isBurst3() then
                return 0
            end
        elseif value1 == 10 then
            if not skill:isBurst2() and not skill:isBurst3() then
                return 0
            end
        end
    end

    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        return value;
    end

    return 0
end

--ボスのHPがvalue4%以上、value3に数値ありで「より大きく」or「より小さく」
function id_469(unit,other,condition,value,value1,value2,value3,value4,value5)
    local tar = unit
    if value1 == 1 then
        tar = other
    elseif value1 == 2 then
        tar = other
        if tar:getTeam():getBoss() == tar then
            return moveType(tar,value,value5);
        end
    end

    local targetUnit = getAncestorUnit(tar)
    return moveType(targetUnit,value,value5);
end

function id_470(unit,other,condition,value,value1,value2,value3,value4)
    local targetUnit = getAncestorUnit(unit)
    local attribute = targetUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if attribute == value1 or value1 == 0 then
        return value;
    end
    return 0;
end

function id_471(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value1 > 0 then
        local skill = unit:getActiveBattleSkill();
        if skill == nil then
            return 0;
        elseif value1 == 1 then
            if skill:getSkillType() ~= 1 then
                return 0;
            end
        elseif value1 == 2 then
            if skill:getSkillType() ~= 2 then
                return 0;
            end
        elseif value1 == 7 then
            if not skill:isBurst2() then
                return 0;
            end
        elseif value1 == 8 then
            if not skill:isPhantomBulletAny() then
                return 0;
            end
        elseif value1 == 9 then
            if not skill:isBurst3() then
                return 0;
            end
        elseif value1 == 10 then
            if not skill:isBurst2() and not skill:isBurst3() then
                return 0;
            end
        end
    end

    if value2 ~= 0 then
        return moveType(unit,value,value2);
    elseif value3 ~= 0 then
        return elementType(unit,value,value3);
    elseif value4 ~= 0 then
        return attackElementType(unit,value,value4);
    elseif value5 ~= 0 then
        return raceType(unit,value,value5);
    end
    return value;
end

function id_472(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value2 ~= 0 then
        return moveType(unit,value,value2);
    elseif value3 ~= 0 then
        return elementType(unit,value,value3);
    elseif value4 ~= 0 then
        return attackElementType(unit,value,value4);
    elseif value5 ~= 0 then
        return raceType(unit,value,value5);
    end
    return value;
end

function id_473(unit,other,condition,value,value1,value2,value3,value4,value5)
    local units = getAncestorUnit(unit);
    if value4 == 0 then
        if value3 == 0 then
            --付与したフラグ用バフを見て判定
            local buffFlg = units:getTeamUnitCondition():findConditionWithID(47301);
            if buffFlg ~= nil then
                condition:setThumbnailID(0);
                megast.Battle:getInstance():updateConditionView();
                return 0;
            end
        else
            --死亡時処理用バフタイプ：240付与
            units:getTeamUnitCondition():addCondition(47302,240,0,999999,0);
            local deadFlg = units:getTeamUnitCondition():findConditionWithID(47302);
            if deadFlg ~= nil then
                deadFlg:setScriptID(473);
                deadFlg:setValue3(value3);
                deadFlg:setValue4(value1);
                deadFlg:setValue5(condition:getID());
            end

            --付与したフラグ用パラメータを見て判定
            local key = "scriptID:473".."c"..units:getIndex().."Flg";
            if units:getParameter(key) == "True" then
                condition:setThumbnailID(0);
                megast.Battle:getInstance():updateConditionView();
                return 0;
            end
        end

        --瀕死判定
        if summoner.Utility.getUnitHealthRate(units) < 0.4 then
            if value3 == 0 then
                units:getTeamUnitCondition():addCondition(47301,0,0,999999,0);
            else
                local key = "scriptID:473".."c"..units:getIndex().."Flg";
                if units:getParameter(key) == "" then
                    units:setParameter(key,"True");
                end
            end
            return 0;
        end
    end

    if value2 >= 6 then
        return moveType(unit,value,value2 - 5);
    else
        return elementType(other,value,value2);
    end
    return value
end

function id_475(unit,other,condition,value,value1,value2,value3,value4,value5)
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if unitTeam == megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end

    local cntFlg = false;
    local count = 0;
    for i = 0,7 do
        local myTeamUnit = targetTeam:getTeamUnit(i,true);
        if myTeamUnit ~= nil then
            if value4 == 0 then
                if myTeamUnit:getRaceType() == value1 then
                    count = count + 1;
                elseif myTeamUnit:getRaceType() == value2 then
                    count = count + 1;
                elseif myTeamUnit:getRaceType() == value3 then
                    count = count + 1;
                end
            else
                cntFlg = true;
                if myTeamUnit:getRaceType() == value1 then
                    cntFlg = false;
                elseif myTeamUnit:getRaceType() == value2 then
                    cntFlg = false;
                elseif myTeamUnit:getRaceType() == value3 then
                    cntFlg = false;
                end

                if cntFlg then
                    count = count + 1;
                end
            end
        end
    end
    return value * count;
end

function id_476(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value4 ~= 0 then
        --装備攻撃は除く
        local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if type == 3 or type == 6 then
            return 0;
        end

        local skill = unit:getActiveBattleSkill();
        if skill == nil then
            return 0;
        elseif value4 == 1 then
            if skill:getSkillType() ~= 1 then
                return 0;
            end
        elseif value4 == 2 then
            if skill:getSkillType() ~= 2 then
                return 0;
            end
        elseif value4 == 7 then
            if not skill:isBurst2() then
                return 0;
            end
        elseif value4 == 8 then
            if not skill:isPhantomBulletAny() then
                return 0;
            end
        elseif value4 == 9 then
            if not skill:isBurst3() then
                return 0;
            end
        elseif value4 == 10 then
            if not skill:isBurst2() and not skill:isBurst3() then
                return 0;
            end
        end
    elseif value5 ~= 0 then
        local type = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if type == 3 or type == 6 then
            return value;
        end
        return 0;
    end
    return value;
end

function id_478(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_479(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_480(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_481(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_482(unit,other,condition,value,value1,value2,value3)
    if value3 >= 6 then
        return moveType(unit,value,value3 - 5);
    end
    return value
end

function id_483(unit,other,condition,value,value1,value2,value3)
    return value
end

function id_484(unit,other,condition,value,value1,value2,value3)
    for k,v in pairs(getBadStatusList()) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return 0;
        end
    end
    return value;
end

function id_485(unit,other,condition,value,value1,value2,value3)
    return value;
end

function id_486(unit,other,condition,value,value1,value2,value3,value4,value5)
    local cond1 = unit:getTeamUnitCondition():findConditionValue(value1);
    local cond2 = unit:getTeamUnitCondition():findConditionValue(value2);
    local cond3 = unit:getTeamUnitCondition():findConditionValue(value3);
    local cnt = 0

    if cond1 > 0 then
        cnt = cnt + 1
    end
    if cond2 > 0 then
        cnt = cnt + 1
    end
    if cond3 > 0 then
        cnt = cnt + 1
    end

    if cnt >= 2 then
        return moveType(unit,value,value4)
    end
    return 0;
end

function id_487(unit,other,condition,value,value1,value2,value3)
    return value
end

function id_488(unit,other,condition,value,value1,value2,value3,value4,value5)
    local ID = 48800 + (unit:getIndex() * 10);
    local cond = unit:getTeamUnitCondition():findConditionWithID(ID);
    if cond == nil then
        local buff = unit:getTeamUnitCondition():addCondition(ID,238,0,999999,0);
        buff:setScriptID(488);
        buff:setValue1(value1);
        buff:setValue2(value2);
    end
    return value;
end

function id_490(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value4 == 1 then
        local targetUnit = getAncestorUnit(other);
        if value1 == 1 then
            targetUnit = getAncestorUnit(unit);
        end

        if targetUnit == nil then
            return value;
        end

        --自分PTからみて敵PTを取る
        local unitTeam = targetUnit:getTeam();
        local targetTeam = nil;
        if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(true);
        else
            targetTeam = megast.Battle:getInstance():getTeam(false);
        end

        local minPar = 101;
        for i = 0,8 do
            local myTeamUnit = targetTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                local per =  myTeamUnit:getHPPercent() * 100;
                if per <= minPar then
                    minPar = per;
                end
            end
        end

        local hpRatio = minPar / 100;
        local inverseRatio = 1 - hpRatio;
        local calculatedValue = inverseRatio * value2;
        value = value * calculatedValue + value3;
        return value;
    end
    return value;
end

function id_491(unit,other,condition,value,value1,value2,value3,value4,value5)
    if value4 == 1 then
        local targetUnit = getAncestorUnit(other);
        if value1 == 1 then
            targetUnit = getAncestorUnit(unit);
        end

        if targetUnit == nil then
            return value;
        end

        local per =  targetUnit:getHPPercent() * 100;
        local hpRatio = per / 100;
        local inverseRatio = 1 - hpRatio;
        local calculatedValue = inverseRatio * value2;
        value = value * calculatedValue + value3;
    end
    return value;
end

function id_492(unit,other,condition,value,value1,value2,value3,value4,value5)
    local targetUnit = getAncestorUnit(unit);
    if value1 == 1 then
        targetUnit = getAncestorUnit(other);
    end
    return moveType(targetUnit,value,value4);
end

function id_493(unit,other,condition,value,value1,value2,value3,value4,value5)
    local ancestorUnit = getAncestorUnit(unit)
    local ancestorOther = getAncestorUnit(other)
    if value1 == 0 then
        if ancestorUnit:getElementType() == ancestorOther:getElementType() then
            return 0;
        end
    elseif value1 == 1 then
        if ancestorUnit:getElementType() ~= ancestorOther:getElementType() then
            return 0;
        end
    elseif value1 == 2 then
        if ancestorUnit:getRaceType() == ancestorOther:getRaceType()then
            return 0;
        end
    elseif value1 == 3 then
        if ancestorUnit:getRaceType() ~= ancestorOther:getRaceType()then
            return 0;
        end
    end

    if value2 ~= 0 then
        return moveType(unit,value,value2);
    elseif value3 ~= 0 then
        local skill = unit:getActiveBattleSkill();
        if skill == nil then
            return 0;
        elseif value3 == 1 then
            if skill:getSkillType() ~= 1 then
                return 0;
            end
        elseif value3 == 2 then
            if skill:getSkillType() ~= 2 then
                return 0;
            end
        elseif value3 == 7 then
            if not skill:isBurst2() then
                return 0;
            end
        elseif value3 == 8 then
            if not skill:isPhantomBulletAny() then
                return 0;
            end
        elseif value3 == 9 then
            if not skill:isBurst3() then
                return 0;
            end
        elseif value3 == 10 then
            if not skill:isBurst2() and not skill:isBurst3() then
                return 0;
            end
        end
    end
end

function id_494(unit,other,condition,value,value1,value2,value3,value4,value5)
    -- 必要種類数
    local needNum = 1

    -- 発動時判定チェックをする
    if value5 == 1 then
        return value
    end

    ---value1~4の装備がneedNum種類あるか確認
    if findBaseWeaponId(unit, value1, value2, value3, value4, needNum) then
        return value
    end

    return 0;
end

function id_495(unit,other,condition,value,value1,value2,value3,value4,value5)
    -- 必要種類数
    local needNum = 2

    -- 発動時判定チェックをする
    if value5 == 1 then
        return value
    end

    ---value1~4の装備がneedNum種類あるか確認
    if findBaseWeaponId(unit, value1, value2, value3, value4, needNum) then
        return value
    end

    return 0;
end

function id_496(unit,other,condition,value,value1,value2,value3,value4,value5)
    -- 必要種類数
    local needNum = 1

    ---value1~4の装備がneedNum種類あるか確認
    if findBaseWeaponId(unit, value1, value2, value3, value4, needNum) then
        return moveType(unit,value,value5)
    end

    return 0;
end

function id_497(unit,other,condition,value,value1,value2,value3,value4,value5)
    -- 必要種類数
    local needNum = 2

    ---value1~4の装備がneedNum種類あるか確認
    if findBaseWeaponId(unit, value1, value2, value3, value4, needNum) then
        return moveType(unit,value,value5)
    end

    return 0;
end

function id_498(unit,other,condition,value,value1,value2,value3)
    return value
end

function id_499(unit,other,condition,value,value1,value2,value3)
    return value

end

function id_506(unit,other,condition,value,value1,value2,value3)
    return value;
end

-- 毒
function id_601(unit,other,condition,value,value1,value2,value3)
    if value1 > 0 and value2 > 0 then
        local a = value1;
        local s = value2;
        local t = condition:getTimeMax() - condition:getTime();
        local v = value + a * ((t / s) * (t / s));
        return v;
    end
    return value;
end

-- 燃焼
function id_602(unit,other,condition,value,value1,value2,value3)
    if value1 > 0 and value2 > 0 then
        local a = value1;
        local s = value2;
        local t = condition:getTimeMax() - condition:getTime();
        local v = value + a * ((t / s) * (t / s));
        return v;
    end
    return value;
end

-- 麻痺、氷結
function id_605(unit,other,condition,value,value1,value2,value3)
    return value;
end

-- 後遺症
function id_603(unit,other,condition,value,value1,value2,value3)
    return value * condition:getNumber();
end

-- 後遺症回復
function id_604(unit,other,condition,value,value1,value2,value3,value4,value5)
    return 1;
end

--自分が◯族だったら
function id_272(unit,other,condition,value,value1,value2,value3)
    if unit:getRaceType() ~= value1 then
        return value;
    end
    return 0;
end

--相手の種族がvalue1~3のいずれかのとき
function id_273(unit,other,condition,value,value1,value2,value3)
    if other:getRaceType() == value1 or other:getRaceType() == value2 or other:getRaceType() == value3 then
        return value;
    end

    return 0;
end

---特定の効果タイプ(238)の時に毎フレーム呼ばれます。
function updateCondition(unit, condition, type, dt, value, value1, value2, value3, value4, value5)
    if condition:getScriptID() == 337 then
        ---死亡時用のバフをセット
        if value2 == 0 then
            condition:setValue2(1)
            local FLG = false
            local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize ~= 0 then
                for i = 0,(conditionSize - 1) do
                    local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                    if cond ~= nil then
                        if cond:getConditionTypeAsInt() == 240 and cond:getScriptID() == 337 and cond:getValue1() == value1 then
                            FLG = true
                        end
                    end
                end
            end
            if not FLG then
                local newCond = unit:getTeamUnitCondition():addCondition(0,240,0,99999,0);
                newCond:setScriptID(337)
                newCond:setValue1(value1)
                local newCond2 = unit:getTeamUnitCondition():addCondition(0,238,0,99999,0);
                newCond2:setScriptID(358)
                newCond2:setValue1(value1)
                newCond2:setValue2(condition:getID())
            end
        end
        ---メイン処理
        local cond = unit:getTeamUnitCondition():findConditionWithID(value1);
        if cond ~= nil then
            local myTeam = unit:getTeam()
            ---味方チームチェック
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    local oldBuff = myTeamUnit:getTeamUnitCondition():findConditionWithID(value1);
                    if oldBuff == nil then
                        ---バフをコピー
                        local newBuff = myTeamUnit:getTeamUnitCondition():addCondition(value1,cond:getConditionTypeAsInt(),cond:getValue(),99999,cond:getThumbnailID());
                        newBuff:setScriptID(cond:getScriptID())
                        newBuff:setValue1(cond:getValue1())
                        newBuff:setValue2(cond:getValue2())
                        newBuff:setValue3(cond:getValue3())
                        newBuff:setValue4(cond:getValue4())
                        newBuff:setValue5(cond:getValue5())
                        if cond:getCasterByLua() == unit then
                            newBuff:setCasterByLua(unit)
                            if megast.Battle:getInstance():isPvp() or myTeamUnit:getisPlayer() then
                                newBuff:setIsCasterPlayer(true)
                            end
                        end
                    end
                end
            end
        end
    end

    if condition:getScriptID() == 358 then
        local cond = unit:getTeamUnitCondition():findConditionWithID(value2)
        if cond == nil and condition:getValue3() == 0 then
            condition:setValue3(1)
            local myTeam = unit:getTeam()
            ---味方チームチェック
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    ---自身は除外
                    if myTeamUnit ~= unit then
                        if myTeamUnit:getTeamUnitCondition():findConditionWithID(value2) ~= nil then
                            return 0
                        end
                    end
                end
            end
            ---特定のバフを味方チームから削除
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeConditionWithID(value1)
                end
            end
        elseif cond ~= nil and condition:getValue3() == 1 then
            condition:setValue3(0)
        end
    end

    ---ジャック専用
    if condition:getScriptID() == 366 then
        local FLG = false
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil then
                    if cond:getID() == condition:getValue1() and cond:getConditionTypeAsInt() == 135 then
                        FLG = true
                    end
                end
            end
        end
        if not FLG then
            local breakEffect = nil
            if condition:getValue1() == 20203600 or condition:getValue1() == 20203500 then
                breakEffect = unit:addOrbitSystemWithFile("10203ef","treasure_chest_EF1")
            elseif condition:getValue1() == 20203700 then
                breakEffect = unit:addOrbitSystemWithFile("10203ef","treasure_chest_EF2")
            end
            if breakEffect ~= nil then
                if unit:getSize() == 3 then
                    breakEffect:setScale(2,2)
                end
                breakEffect:setPosition(unit:getAnimationPositionX(),unit:getAnimationPositionY())
            end
            condition:setTime(0)
        end
    end

    ---value秒に一度value1奥義ゲージアップ
    if condition:getScriptID() == 2252 then
        local nowWave = megast.Battle:getInstance().m_wave;
        local beforeWave = condition:getValue5();
        if nowWave ~= beforeWave then
            condition:setTime(10000);
            condition:setValue5(nowWave);
        end

        if condition:getIsPassive() then
            condition:setIsPassive(false);
        end

        if condition:getTime() <= 10000 - value and unit:isMyunit() then
            local rate = 1
            if megast.Battle:getInstance():isPvp() then
                rate = megast.Battle:getInstance():getPvpCorrectionValue(10,1);
            end
            unit:setBurstPoint(unit:getBurstPoint() + (value1 * rate));
            condition:setTime(10000)
        end
    end

    if condition:getScriptID() == 393 then
        --summoner.Utility.messageByEnemy("初回付与済み判定")
        local key = "scriptID"..condition:getScriptID().."c"..unit:getIndex().."i"..condition:getValue1();
        local str = unit:getParameter(key);
        if str ~= "0" then
            unit:setParameter(key,"1");
        end
        unit:getTeamUnitCondition():removeCondition(condition);
    end

    if condition:getScriptID() == 443 then
        ---wave数が更新されたら動く
        if condition:getValue5() < megast.Battle:getInstance():getWaveNum() and megast.Battle:getInstance():getBattleState() == kBattleState_active then
            condition:setValue5(megast.Battle:getInstance():getWaveNum())
            unit:addSPWithPvpCorrection(value)
            local battleSkill = nil
            for i = 0,2 do
                battleSkill = unit:getItemSkill(i)
                if battleSkill ~= nil then
                    --summoner.Utility.messageByEnemy(battleSkill:getBattleItem():getBaseItemNo())
                    if battleSkill:getBattleItem():getBaseItemNo() == value1 then
                        battleSkill:setCoolTimer(0)
                    end
                end
            end
        end
    end

    if condition:getScriptID() == 459 then
        --summoner.Utility.messageByEnemy("初回付与済み判定")
        local key = "scriptID"..condition:getScriptID().."c"..unit:getIndex().."i"..condition:getValue1();
        local str = unit:getParameter(key);
        if str ~= "0" then
            unit:setParameter(key,"1");
        end
        unit:getTeamUnitCondition():removeCondition(condition);
    end

    if condition:getScriptID() == 470 then
        --summoner.Utility.messageByEnemy("初回付与済み判定")
        local key = "scriptID"..condition:getScriptID().."c"..unit:getIndex().."i"..condition:getValue1();
        local str = unit:getParameter(key);
        if str ~= "0" then
            unit:setParameter(key,"1");
        end
        unit:getTeamUnitCondition():removeCondition(condition);
    end

    if condition:getScriptID() == 477 then
        local time = unit:getNormalSkill():getCoolTimer()
        if time > condition:getValue() then
            unit:addSPWithPvpCorrection(value1);
        end
        condition:setValue(time)
    end

    if condition:getScriptID() == 487 then
        if condition:getValue5() ~= 9999 then
            local cond1 = unit:getTeamUnitCondition():findConditionWithType(value1);
            local cond2 = unit:getTeamUnitCondition():findConditionWithType(value2);
            local cond3 = unit:getTeamUnitCondition():findConditionWithType(value3);
            local cnt = 0

            if cond1 ~= nil then
                cnt = cnt + 1
            end
            if cond2 ~= nil then
                cnt = cnt + 1
            end
            if cond3 ~= nil then
                cnt = cnt + 1
            end

            if cnt >= value4 then
                unit:addSPWithPvpCorrection(value);
            end
            condition:setValue5(9999)
        end
    end

    if condition:getScriptID() == 484 then
        --summoner.Utility.messageByEnemy("初回付与済み判定")
        local key = "scriptID"..condition:getScriptID().."c"..unit:getIndex().."i"..condition:getValue1();
        local str = unit:getParameter(key);
        if str ~= "0" then
            unit:setParameter(key,"1");
        end
        unit:getTeamUnitCondition():removeCondition(condition);
    end

    if condition:getScriptID() == 488 then
        local raceTbl = {};
        for i = 0,8 do raceTbl[i] = false; end
        local unitTeam = unit:getTeam();
        local targetTeam = nil
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(true);
        else
            targetTeam = megast.Battle:getInstance():getTeam(false);
        end

        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                raceTbl[myTeamUnit:getRaceType()] = true;
            end
        end

        local count = 0;
        for i = 0,8 do
            if raceTbl[i] then
                count = count + 1;
            end
        end

        local cond = unit:getTeamUnitCondition():findConditionWithID(value1);
        if cond ~= nil then
            local rate = 1;
            if cond:getConditionTypeAsInt() == 8 or cond:getConditionTypeAsInt() == 9 or cond:getConditionTypeAsInt() == 10 then
                rate = megast.Battle:getInstance():getPvpCorrectionValue(cond:getConditionTypeAsInt(),1);
            end
            cond:setValue(count * value2 * rate);
        end
    end

    if condition:getScriptID() == 498 then
        if condition:getValue5() ~= 9999 then
            -- 必要種類数
            local needNum = 1
            ---value1~4の装備がneedNum種類あるか確認
            if findBaseWeaponId(unit, value1, value2, value3, value4, needNum) then
                unit:addSPWithPvpCorrection(value);
            end
            condition:setValue5(9999)
        end
    end

    if condition:getScriptID() == 499 then
        if condition:getValue5() ~= 9999 then
            -- 必要種類数
            local needNum = 2
            ---value1~4の装備がneedNum種類あるか確認
            if findBaseWeaponId(unit, value1, value2, value3, value4, needNum) then
                unit:addSPWithPvpCorrection(value);
            end
            condition:setValue5(9999)
        end
    end

    return 0
end

---特定の効果タイプ(240)を持つユニット死亡時に呼ばれます。
function teamUnitOut(unit, condition, type, dt, value, value1, value2, value3, value4, value5)
    if condition:getScriptID() == 337 then
        local myTeam = unit:getTeam()
        ---味方チームチェック
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                ---自身は除外
                if myTeamUnit ~= unit then
                    local conditionSize = myTeamUnit:getTeamUnitCondition():getAllConditionsSize();
                    if conditionSize ~= 0 then
                        for i = 0,(conditionSize - 1) do
                            local cond = myTeamUnit:getTeamUnitCondition():getAllConditionsAt(i);
                            if cond ~= nil then
                                if cond:getConditionTypeAsInt() == 240 and cond:getScriptID() == 337 and cond:getValue1() == value1 then
                                    ---他に同じバフを持つユニットがいる場合はreturn
                                    return 0
                                end
                            end
                        end
                    end
                end
            end
        end
        ---特定のバフを味方チームから削除
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:getTeamUnitCondition():removeConditionWithID(value1)
            end
        end
    end

    if condition:getScriptID() == 473 then
        if value3 == 1 then
            local unitTeam = unit:getTeam()
            local targetTeam = nil
            if unitTeam == megast.Battle:getInstance():getTeam(true) then
                targetTeam = megast.Battle:getInstance():getTeam(true)
            else
                targetTeam = megast.Battle:getInstance():getTeam(false)
            end

            for i = 0,6 do
                local myTeamUnit = targetTeam:getTeamUnit(i,true);
                if myTeamUnit ~= nil then
                    local key = "scriptID:473".."c"..unit:getIndex().."Flg";
                    myTeamUnit:setParameter(key,"True");
                end
            end
        end
    end

    if condition:getScriptID() == 474 then
        unit:setDeadSkillCount(value1)
    end

    if condition:getScriptID() == 492 then
        local key = "scriptID:492".."c"..unit:getIndex().."Count"..condition:getValue3();
        unit:setParameter(key,"0");
    end

    ---ボス死亡時にプレイヤー側から特定バフを削除
    local deleteIdBox = {274,277,283,306}
    for _,v in ipairs(deleteIdBox) do
        if condition:getScriptID() == v then
            local unitTeam = unit:getTeam()
            local targetTeam = nil
            if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
                targetTeam = megast.Battle:getInstance():getTeam(true)
            else
                targetTeam = megast.Battle:getInstance():getTeam(false)
            end
            for i = 0,6 do
                local myTeamUnit = targetTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeConditionWithID(condition:getID())
                end
            end
        end
    end
    return 0
end

function entirelyConditionValue(unit, target, type, value, scriptID, value1, value2, value3, value4, value5)
    if scriptID == 343 then
        if target:getElementType() == value1 then
            value = value2
        end
        return value
    end

    if scriptID == 419 then
        if value4 ~= 0 and findWeapon(unit,value4) then
            value1 = value5
        end
        if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 then
            if value3 <= 5 then
                return elementType(target,value,value3);
            end
            return value
        end
        return 0
    end

    if scriptID == 420 then
        if value4 ~= 0 and findWeapon(unit,value4) then
            value1 = value5
        end
        local tIndex = target:getIndex()
        ---両隣かチェック
        if tIndex == unit:getIndex() + 1 or tIndex == unit:getIndex() - 1 then
            ---体力チェック
            if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 then
                return value;
            end
        end
        return 0
    end

    if scriptID == 424 then
        if target:getIsLeader() then
            return value;
        end
        return 0
    end

    if scriptID == 425 then
        if value4 ~= 0 and findWeapon(unit,value4) then
            value1 = value5
        end
        if (unit:getHPPercent() * 100) > value1 and (unit:getHPPercent() * 100) < value2 then
            return elementType(target,value,value3);
        end
        return 0
    end

    if scriptID == 426 then
        if value4 ~= 0 and findWeapon(unit,value4) then
            value1 = value5
        end
        local tIndex = target:getIndex()
        ---自分と右隣チェック
        if tIndex == unit:getIndex() + 1 or tIndex == unit:getIndex() then
            ---体力チェック
            if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 then
                return value;
            end
        end
        return 0
    end

    if scriptID == 427 then
        if value4 ~= 0 and findWeapon(unit,value4) then
            value1 = value5
        end
        local tIndex = target:getIndex()
        ---左隣チェック
        if tIndex == unit:getIndex() - 1 then
            ---体力チェック
            if (unit:getHPPercent() * 100) >= value1 and (unit:getHPPercent() * 100) <= value2 then
                return value;
            end
        end
        return 0
    end

    if scriptID == 428 then
        if unit:getIsLeader() then
            value = value2
        end
        return elementType(target,value,value1);
    end

    if scriptID == 429 then
        if unit:getIsLeader() then
            return value
        end
        return 0
    end

    if scriptID == 430 then
        return elementType(target,unit:getRP() * value * 0.01,value1);
    end

    if scriptID == 433 then
        local count = 0
        local myTeam = unit:getTeam();
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getElementType() == value1 then
                    count = count + 1;
                end
            end
        end
        return value * count
    end

    if scriptID == 448 then
        for _,v in pairs(getBadStatusListOut129()) do
            if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
                return 0;
            end
        end
        return elementType(target,value,value1);
    end

    if scriptID == 473 then
        if value3 == 0 then
            local buffFlg = unit:getTeamUnitCondition():findConditionWithID(47301);
            if buffFlg ~= nil then
                return 0;
            end
        else
            --死亡時処理用バフタイプ：240付与
            unit:getTeamUnitCondition():addCondition(47302,240,0,999999,0);
            local deadFlg = unit:getTeamUnitCondition():findConditionWithID(47302);
            if deadFlg ~= nil then
                deadFlg:setScriptID(473);
                deadFlg:setValue3(value3);
                deadFlg:setValue4(value1);
            end

            --付与したフラグ用バフを見て判定
            local key = "scriptID:473".."c"..unit:getIndex().."Flg";
            if unit:getParameter(key) == "True" then
                return 0;
            end
        end

        --瀕死判定
        if summoner.Utility.getUnitHealthRate(unit) < 0.4 then
            if value3 == 0 then
                unit:getTeamUnitCondition():addCondition(47301,0,0,999999,0);
            else
                local key = "scriptID:473".."c"..unit:getIndex().."Flg";
                if unit:getParameter(key) == "" then
                    unit:setParameter(key,"True");
                end
            end
            return 0;
        end
        return elementType(target,value,value2);
    end

    if scriptID == 482 then
        if value4 ~= 0 and findWeapon(unit,value4) then
            value1 = value5
        end
        if (target:getHPPercent() * 100) >= value1 and (target:getHPPercent() * 100) <= value2 then
            if value3 <= 5 then
                return elementType(target,value,value3);
            end
            return value
        end
        return 0
    end

    return value
end

function checkAiDropView(unit,key)
    if megast.Battle:getInstance():getAiLearningLuaKey() == key then
        megast.Battle:getInstance():addAiLearningDropItem(unit)
    end
end

function getBadStatusList()
    local badStatusList = {
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        129,
        131,
        135,
        201,
        202,
        203,
        204,
        205,
        206,
        207,
        208,
        233,
        234
    }
    return badStatusList
end

function getUnitBadStatusList()
    local badStatusList = {
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97
    }
    return badStatusList
end

function getBadStatus89to97()
    local badStatusList = {
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97
    }
    return badStatusList
end

function getBadStatusListOut129()
    local badStatusList = {
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        --129,
        131,
        135,
        201,
        202,
        203,
        204,
        205,
        206,
        207,
        208,
        233,
        234
    }
    return badStatusList
end

function moveType(unit,value,num)
    if num == 0 then
        ---判定なし
        return value
    elseif num == 1 then
        ---物理判定
        local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 1 then
            return value;
        end
    elseif num == 2 then
        ---魔法判定
        local attribute = unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 2 then
            return value;
        end
    elseif num == 3 then
        ---クリティカル判定
        local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
        if critical then
            return value;
        end
    end
    return 0;
end

function elementType(unit,value,num)
    if num == 0 then
        ---判定なし
        return value
    elseif num == 6 then
        ---無属性判定
        if unit:getElementType() == 0 then
            return value
        end
    else
        ---5属性判定
        if unit:getElementType() == num then
            return value
        end
    end
    return 0;
end

function attackElementType(unit,value,num)
    local element = unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType;
    if num == 0 then
        ---判定なし
        return value
    elseif num == 6 then
        ---無属性判定
        if element == 0 then
            return value
        end
    else
        ---5属性判定
        if element == num then
            return value
        end
    end
    return 0;
end

function raceType(unit,value,num)
    ---種族判定
    if unit:getRaceType() == num then
        return value
    end
    return 0;
end

function autoDamageFix(unit,damage)
    if unit:getHP() -  math.ceil(damage/5) <= 0 then
        unit:setHP(1);
        return 0;
    end
    return damage
end

function getGroupID(buffID,value1,value2,value3)
    local groupID = 0

    return groupID
end

function findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

function setDisPriority(value, con)
    local rtn = value
    local type = con:getConditionTypeAsInt()
    local time = con:getTime()
    local gid = con:getGroupID()
    -- HP自然回復
    if type == 7 then
        if gid == 1048 then
            rtn = value * time
        end
        if gid == 1007 then
            rtn = value
        end
    end
    -- 奥義ゲージ自然上昇
    if type == 10 then
        rtn = value * time
    end
    -- 気絶、麻痺、沈黙、氷結
    if type == 89 or type == 91 or type == 92 or type == 96 then
        rtn = time
    end
    -- 毒
    if type == 90 then
        rtn = value * time/100
    end
    -- 燃焼
    if type == 97 then
        rtn = time * 10000 + value
    end
    return math.abs(rtn)
end

function findBaseWeaponId(caster, value1, value2, value3, value4, num)
    local parent = caster:getParentTeamUnit();
    if parent ~= nil then
        caster = parent;
    end
    ---テーブルを用意
    local itemTable = {}
    itemTable = {
        [value1] = false,
        [value2] = false,
        [value3] = false,
        [value4] = false
    }

    ---value1~4の装備があるか確認
    for i = 0,6 do
        local myTeamUnit = caster:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            for n = 0,2 do
                local item = myTeamUnit:getItemSkill(n)
                if item ~= nil then
                    local baseItemNo = item:getBattleItem():getBaseItemNo()
                    print("itemNo"..baseItemNo)
                    if itemTable[baseItemNo] ~= nil then
                        itemTable[baseItemNo] = true;
                    end
                end
            end
        end
    end

    local ecnt = 0
    ---装備種類数を格納
    for k,v in pairs(itemTable) do
        if v then
            ecnt = ecnt + 1
        end
    end
    -- num種類以上あれば適用
    if ecnt >= num then
        return true;
    end
    return false;
end