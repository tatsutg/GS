local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="超襲来マリカ_真EX極_SX-202型・改", version=2.6, id=2084711});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {                                 ---スキル1 -> スキル2 -> 繰り返し
        { ATTACK1 = 100 },
        { ATTACK2 = 100 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {                                 ---奥義3 -> 繰り返し
        { SKILL2 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,                                ---スキル1 通常攻撃    （attack1）
    ATTACK2 = 2,                                ---スキル2 WPN-F100    （skill1）
    SKILL2  = 3,                                ---奥義3  WPN-FEX1001  （skill2）
    SKILL3  = 4                                 ---奥義4  WPN-FEX1111  （skill2を流用／HP50%フラグ専用）
}

class.cutInSkill = {
    ---仕様書にカットイン指定なし
}

---EFアニメーションの接頭辞。同じunit(501941150)を使う mine_1042.lua が "2-skill1" を使用
class.EF_PREFIX = "2-";

---通常攻撃のアニメーション差し替え
---本体spine 501941150 は attack1／skill1／skill2 のみを持つ
class.ATTACK_ANIMATIONS = {
    [2] = "skill1"                              ---スキル2 WPN-F100
}

---奥義のアニメーション差し替え
---本体spineに skill3 が無いため、奥義4 は奥義3と同じ skill2 を流用する
class.SKILL_ANIMATIONS = {
    [3] = "skill2"                              ---奥義4 WPN-FEX1111
}

---真EX・極のみタイマーギミックを持つ（真EXは子ファイルで false にする）
class.USE_START_TIMER = true;

---タイマー1周ごとの被ダメージアップは「アイコンを個別につける」ため周回ごとに一意のIDを使う
class.TG_BUFF_ID_BASE = 2084711000;


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---HP50%：自身のダメージアップ
        [1] = {
            ID = 208471101,
            BUFF_ID = 17,                       ---与ダメージ
            VALUE = self.GD.hp50DmgUpVal,
            DURATION = 999999,
            ICON = 26
        },
        ---討伐報酬：パーティのブレイク力アップ（VALUEは撃破時に上書きする）
        [2] = {
            ID = 208471102,
            BUFF_ID = 25,                       ---ブレイク力（割合）
            VALUE = self.GD.rewardBase,
            DURATION = 999999,
            ICON = 9
        }
    };

    ---タイマー1周ごとにパーティへ被ダメージアップ（重複・アイコンは個別）
    if self.USE_START_TIMER then
        self.TG_BUFF_LIST = {
            [1] = {
                ID = self.TG_BUFF_ID_BASE,      ---付与時に周回数を足して一意にする
                BUFF_ID = 21,                   ---被ダメージ
                VALUE = self.GD.tgBuffVal_21,
                DURATION = 999999,
                ICON = 139
            }
        };
    end
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message;
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {};
    table.insert(self.START_MESSAGE_LIST,self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}));
    table.insert(self.START_MESSAGE_LIST,self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "パーティの種族数が多いほど被ダメージアップ", COLOR = Color.yellow}));
    ---一定時間経過の被ダメージアップは真EX・極のみ
    if self.USE_START_TIMER then
        table.insert(self.START_MESSAGE_LIST,self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "一定時間経過でパーティの被ダメージアップ", COLOR = Color.yellow}));
    end
    table.insert(self.START_MESSAGE_LIST,self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "防衛メカを早く倒すほどパーティのブレイク力アップ", COLOR = Color.yellow}));
    table.insert(self.START_MESSAGE_LIST,self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "庇う無効", COLOR = Color.yellow}));

    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow})
    };

    ---撃破時（ユニット側・白）
    self.REWARD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.REWARD_MESSAGE1 or "パーティのブレイク力%d%%アップ", COLOR = Color.white, isPlayer = true})
    };
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        }
    };
    self.HP_TRIGGERS = {};
    self.hpMarkers = {};
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger;
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01);
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255);
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist");
            end
        end
    end
end

---HP50%：奥義4発動＆addSP=35＆ダメージ50%UP
function class:hp50(status)
    if status == "use3" then
        self:refresh(self.gameUnit);                                ---停止系状態異常除去
        self.hpSkillFLG = true;                                     ---発動から打ち終わるまでブレイク不可
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;                                       ---SKILL3＝奥義4 WPN-FEX1111
            self.saveBP = self.gameUnit:getBurstPoint();            ---奥義ゲージ引き継ぎ
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(self.GD.hpSkillInvincible);
        self.spValue = self.GD.hp50AddSP;                           ---奥義ゲージ上昇量アップ
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1]);      ---ダメージアップ
        self:showMessage(self.HP50_MESSAGE_LIST);
    end
end

---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 5,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効
        sizeScale = 2,              --見た目の倍率（size=2倍）

        ---タイマーギミック（一定時間でパーティへ被ダメージアップ）
        tgTimer = 20,               --1周の秒数
        tgLimit = 99,               --ループ上限
        tgIconNum1 = 139,           --タイマーのアイコン番号（被ダメージアップ）
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        tgBuffVal_21 = 20,          --1周ごとの被ダメージアップ%（アイコンは個別）

        ---ダメージ耐性（パーティの種族数）
        raceCountMax = 4,           --補正が等倍になる種族数（これ以上は打ち止め）
        raceRateBase = 2,           --補正 ×[1/raceRateBase^（raceCountMax-種族数）]

        ---討伐報酬（早く倒すほどパーティのブレイク力アップ）
        rewardBase = 100,           --[rewardBase-経過秒数]%アップ
        rewardMin = 10,             --最低保証%

        ---HP50%フラグ
        hp50AddSP = 35,             --HP50%以降のSP獲得量
        hp50DmgUpVal = 50,          --HP50%以降の自身のダメージアップ%
        hpSkillInvincible = 15,     --HPフラグ奥義中の無敵秒数
    };
end


---ギミックカラムのJSONは値が文字列やnullで入ってくることがあるため数値へ正規化する。
---Json.parse のnullは空テーブルになり、getGimmickJsonData の「jsonData[key] == nil なら既定値」
---判定をすり抜けてそのまま self.GD に載る。放置すると start() が
---「attempt to compare number with table/string」で例外死し、setTriggerList まで到達しないため
---update() の hpTriggersCheck が HP_TRIGGERS(nil) で毎フレーム落ちる。
function class:setUpGimmickData(unit)
    local defaults = self:getGimmickDefault();
    ---JSON自体が壊れている場合 getGimmickJsonData は error を投げる。
    ---そのまま落とすと start() が中断してボスが機能停止するので、既定値で動かす。
    ---（Utility 側が changeErrorMarkColor(2) を呼ぶので赤丸は出たままになる）
    local isSuccess, data = pcall(summoner.Utility.getGimmickJsonData, unit, defaults);
    if not isSuccess then
        summoner.Utility.messageByEnemy("ギミックカラムのJSONが不正です");
        data = defaults;
    end
    local fixed = {};
    for key,def in pairs(defaults) do
        local value = data[key];
        if type(def) == "number" then
            if type(value) == "number" then
                fixed[key] = value;
            elseif type(value) == "string" and tonumber(value) ~= nil then
                fixed[key] = tonumber(value);   ---管理画面が文字列で入れた場合は数値へ
            else
                fixed[key] = def;               ---null・空文字・型違いはLua側の既定値へ戻す
            end
        elseif type(value) == type(def) then
            fixed[key] = value;
        else
            fixed[key] = def;
        end
    end
    ---未宣言キーへのアクセスは元の実装と同じくエラーにする（キー名のタイポ検出用）
    setmetatable(fixed,{__index = function(_,key) error("Key not found: "..tostring(key)) end});
    return fixed;
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = self:setUpGimmickData(event.unit);
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP);---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.addSpSkipFLG = true;   ---奥義直後の通常攻撃ではaddSPしない
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.breakSkip = false;
    self.breakFlg = false;
    self.hpSkill = 0;
    self.saveBP = 0;
    self.hpSkillFLG = false;

    ---size＝2倍（Lua対応で大きくする）
    if self.GD.sizeScale ~= 1 then
        event.unit:getSkeleton():setScale(self.GD.sizeScale);
    end

    ---ダメージ耐性（パーティの種族数は編成時に固定する）
    self.raceCount = 0;

    ---討伐報酬
    self.rewardDone = false;

    ---タイマーギミック（真EX・極のみ）
    ---start() は死亡→復活時にも呼ばれるため、既存のタイマーを消してから作る
    self:removeTimers();
    self.timeSpeed = 1;
    if self.USE_START_TIMER then
        self.timeIndex = megast.Battle:getInstance():createExtraTimer(
            self.GD.tgTimer, self.GD.tgLimit,
            self.GD.tgIconNum1, self.GD.tgIconNum2,
            self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
        self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    end

    ---SX-202型固有のもの（ロックオン弾の制御）
    self.bullets = {};
    self.bulletsIDCounter = 0;
    self.bulletinfo = {
        new = function (_bullet,_targetUnit,_uniqueID)
            return {
                bullet = _bullet,
                targetUnit = _targetUnit,
                uniqueID = _uniqueID,
                frame = 0,
                posx = 0,
                posy = 0,
                limitx = 0,
                limity = 0,
                parent = _bullet:getTeamUnit(),
                yield = true
            }
        end
    };
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    ---種族数は編成時の内容に依存する（死亡でバトルユニットが減っても変化しない）
    self:countRaceTypes();
    return 1;
end

--===================================================================================================================
-- ダメージ耐性（パーティの種族数）
--===================================================================================================================
function class:countRaceTypes()
    local races = {};
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil then
            races[u:getRaceType()] = true;
        end
    end
    local count = 0;
    for _ in pairs(races) do
        count = count + 1;
    end
    self.raceCount = count;
end

---takeDamageValue補正 ×[1/2^（4-種族数）]。種族数は raceCountMax で打ち止め
function class:getRaceDamageRate()
    if self.raceCount < 1 then
        return 1;
    end
    local count = self.raceCount;
    if count > self.GD.raceCountMax then
        count = self.GD.raceCountMax;
    end
    return 1 / math.pow(self.GD.raceRateBase,self.GD.raceCountMax - count);
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    ---タイマーギミック
    self:extraTimerOperation(event.unit);

    ---SX-202型固有のもの（ロックオン弾の制御）
    if table.maxn(self.bullets) > 0 then
        for i = 1,table.maxn(self.bullets) do
            self:bulletControll(self.bullets[i]);
        end
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

--===================================================================================================================
-- タイマーギミック
--===================================================================================================================
---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if self.timeIndex ~= nil and event.index == self.timeIndex then
        ---アイコンは個別につけるので、周回ごとに一意のIDで付与する
        self.TG_BUFF_LIST[1].ID = self.TG_BUFF_ID_BASE + event.count;
        self:unitAddBuff(self.TG_BUFF_LIST[1]);
    end
    return event.count;
end

function class:extraTimerOperation(unit)
    if self.timeIndex == nil then
        return;
    end
    local speed = 1;
    ---ブレイク中・無敵中・HPフラグ奥義中は停止
    if unit:isBreak() or unit:getInvincibleTime() > 0 or self.hpSkillFLG then
        speed = 0;
    end
    if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= speed then
        megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex,speed);
    end
    self.timeSpeed = speed;
end

function class:removeTimers()
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil;
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    ---spine(501941150)に runScript-addSP は無いので addSP は takeAttack 側で行う
    ---SX-202型固有のもの
    if event.spineEvent == "lock" then return self:lock(event.unit); end
    if event.spineEvent == "lockCompleat" then return self:lockCompleat(event.unit); end
    if event.spineEvent == "explosion" then return self:explosion(event.unit); end
    if event.spineEvent == "missile" then return self:missile(event.unit); end
    if event.spineEvent == "onDestroy" then return self:onDestroy(event.unit); end
    return 1;
end

--===================================================================================================================
-- SX-202型固有のもの（ロックオン弾・ミサイル）
--===================================================================================================================
function class:lock(unit)
    local lock = unit:addOrbitSystem("LockOn");
    lock:setHitCountMax(1);
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    lock:setPosition(x-100,y);
    local tama = self.bulletinfo.new(lock,unit:getTargetUnit():getIndex(),0);
    table.insert(self.bullets,tama);
    return 1;
end

function class:lockCompleat(unit)
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            self.bullets[i].yield = false;
        end
    end
    return 1;
end

function class:explosion(unit)
    local atari = 0;
    local x = 0;
    local y = 0;
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            atari = i;
        end
    end

    if atari == 0 then
        return 0;
    end

    local explode = unit:getTeamUnit():addOrbitSystem("Explode");
    x = unit:getPositionX();
    local target = explode:getTargetUnit();
    if target ~= nil then
        y = target:getPositionY();
    end

    explode:setPosition(x,y);
    return 1;
end

function class:missile(unit)
    local atari = 0;
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            atari = i;
        end
    end

    if atari == 0 then
        return 0;
    end

    local parentx = unit:getTeamUnit():getPositionX();
    local parenty = unit:getTeamUnit():getPositionY();
    local thisx = unit:getPositionX();
    local thisy = unit:getPositionY();
    local distance = thisx - parentx;
    local hight = thisy - parenty;
    local miso = nil;
    if not unit:getTeamUnit():getisPlayer() then
        distance = distance * -1;
    end

    if distance >= -128 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile0");
    elseif distance >= -192 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile1");
    elseif distance >= -256 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile2");
    elseif distance >= -320 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile3");
    elseif distance >= -384 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile4");
    elseif distance >= -448 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile5");
    elseif distance >= -512 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile6");
    elseif distance >= -576 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile7");
    elseif distance >= -640 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile8");
    elseif distance >= -704 then
        miso = unit:getTeamUnit():addOrbitSystem("Missile9");
    else
        miso = unit:getTeamUnit():addOrbitSystem("Missile10");
    end

    if not(miso == nil) then
        if unit:getTeamUnit():getisPlayer() then
            miso:setPosition(parentx+distance%64,parenty+hight);
        else
            miso:setPosition(parentx-distance%64,parenty+hight);
        end
    end
    return 1;
end

function class:onDestroy(unit)
    local atari = 1;
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            atari = i;
        end
    end
    table.remove(self.bullets,atari);
    return 1;
end

function class:bulletControll(bulletinstance)
    bulletinstance.frame = bulletinstance.frame + 1;
    local currentbullet = bulletinstance.bullet;
    local xdir = 0;
    local ydir = 0;
    local bullettarget = megast.Battle:getInstance():getTeam(not bulletinstance.bullet:getTeamUnit():getisPlayer()):getTeamUnit(bulletinstance.targetUnit);
    if bullettarget ~= nil and bulletinstance.yield then
        local reversalFLG = bullettarget:getisPlayer();
        local thisx = currentbullet:getPositionX();
        local thisy = currentbullet:getPositionY();
        local targetx = bullettarget:getPositionX();

        --相手ユニットが敵側ならX軸の移動量を反転させる
        if reversalFLG then
            targetx = targetx + bullettarget:getSkeleton():getBoneWorldPositionX("MAIN");
        else
            targetx = targetx + bullettarget:getSkeleton():getBoneWorldPositionX("MAIN") * -1;
        end

        local targety = bullettarget:getPositionY() + bullettarget:getSkeleton():getBoneWorldPositionY("MAIN") + bullettarget:getSkeleton():getPositionY();
        xdir = targetx - thisx;
        ydir = targety - thisy;
        bulletinstance.limitx = bulletinstance.limitx + xdir;
        bulletinstance.limity = bulletinstance.limity + ydir;
    end

    self:moveByFloat(bulletinstance,xdir,ydir);
    return 1;
end

function class:moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end

    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    ---アニメーションの差し替え
    local animation = self.ATTACK_ANIMATIONS[event.index];
    if animation ~= nil then
        event.unit:setNextAnimationName(animation);
        event.unit:setNextAnimationEffectName(self.EF_PREFIX..animation);
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);

    ---ユニットボスは run（spineのrunScript-addSP）を持たないので通常攻撃の成立時にaddSPする
    ---奥義直後の通常攻撃ではaddSPせず、引き継いだ奥義ゲージを戻す
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false;
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.hpSkillFLG = false;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    else
        self:addSP(event.unit);
    end
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時は行動パターンを進めない
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
    end
    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    ---アニメーションの差し替え
    local animation = self.SKILL_ANIMATIONS[event.index];
    if animation ~= nil then
        event.unit:setNextAnimationName(animation);
        event.unit:setNextAnimationEffectName(self.EF_PREFIX..animation);
    end

    self.skillCheckFlg = false;
    self.addSpSkipFLG = true;   ---奥義直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1;
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex();
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill;
        self.hpSkill = 0;
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL);
    end

    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex),self.cutInSkill[skillIndex]);
    else
        unit:takeSkill(tonumber(skillIndex));
    end

    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true;
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index,self.cutInSkill[index]);
    else
        unit:takeSkill(index);
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return event.value;
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return event.value;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---ダメージ耐性（パーティの種族数が多いほどダメージアップ）
    local rate = self:getRaceDamageRate();
    if rate ~= 1 and event.value > 0 then
        event.value = math.max(math.floor(event.value * rate),1);
    end

    ---HPフラグ境界でのダメージ調整（必ず最後）
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（event.enemy を持たないが、種族数の補正は攻撃者に依存しないので同じ補正を入れる）
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    else
        local rate = self:getRaceDamageRate();
        if rate ~= 1 and event.value > 0 then
            event.value = math.max(math.floor(event.value * rate),1);
        end
    end
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value;
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01;
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit); ---停止系状態異常除去(このタイミングでないとたまにバグる)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value);
        end
    end
    return value;
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true;
    return unit:getHP() - border + 1;
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit;
    else
        return self:getAncestorUnit(unit:getParentTeamUnit());
    end
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false;
        return 0;
    end
    ---HPフラグは発動から打ち終わるまでブレイク不可
    if self.hpSkillFLG then
        return 0;
    end
    return event.value;
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01;
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0;
        end
    end
    self.breakFlg = true;
    return 1;
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0);
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:removeTimers();
    ---討伐報酬（経過秒数はホストが計測してゲストへ配る）
    if megast.Battle:getInstance():isHost() then
        local value = self.GD.rewardBase - math.floor(BattleControl:get():getTime());
        if value < self.GD.rewardMin then
            value = self.GD.rewardMin;
        end
        self:applyKillReward(value);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,value);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- receive6（討伐報酬の効果量同期）
---------------------------------------------------------------------------------
function class:receive6(args)
    self:removeTimers();
    self:applyKillReward(args.arg);
    return 1;
end

---パーティのブレイク力アップ（Wave2へ持ち越すので永続）
function class:applyKillReward(value)
    if self.rewardDone then
        return;
    end
    self.rewardDone = true;
    self.BUFF_BOX_LIST[2].VALUE = value;
    self:unitAddBuff(self.BUFF_BOX_LIST[2]);
    self:showFormatMessage(self.REWARD_MESSAGE_LIST[1],value);
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList);
        return
    end
    self:execShowMessage(messageBoxList[index]);
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox);
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i]);
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

function class:showFormatMessage(messageBox,str)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    end
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:hpTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            if not trigger.isEnableSkip then
                ---通常マーカーはブレイク中は発動しない。ブレイクが明けてから発動させる。
                ---isBreak() だけでは足りない：breakPoint が0になったフレームは
                ---m_breaktime がまだ0のため isBreak() が false を返す
                ---（engine は次の update で takeBossBreak する／TeamUnit.cpp:6230）。
                ---そこで発動してしまうと、直後にブレイクへ入って奥義を撃てず
                ---hpSkillFLG が解除されないままボスが停止する。breakPoint も見て待つ。
                ---ブレイクが明けると engine が breakPoint を満タンへ戻すので、その後に発動する。
                if not unit:isBreak() and unit:getBreakPoint() > 0 then
                    self:execTrigger(index);
                end
            else
                ---ブレイクスルー
                self:execTrigger(index);
            end
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return;
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3;
    local action = "use" .. receiveNumber;
    self.TRIGGERS[index].used = true;

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true);
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index);
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP]);
    end

    self.TRIGGERS[index].action(action);
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index);
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true;
    self.TRIGGERS[args.arg].action("use3");
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP]);
    return 1;
end

---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true;
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true);
    end
    return 1;
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

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

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff);
    end
end

-- 全プレイヤーユニットへバフ付与
function class:unitAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
end

function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1;
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1;
        stateBox.setCount = stateBox.setCount + 1;
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1;
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount]);
    end
end

class.STATE_ATTACK = {};
function class:initAttackWeight(...)
    local attackList = {...};
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT);
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex);
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...};
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT);
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex);
end

function class:initState(weightList)
    local state = {};
    state.SET_WEIGHT = weightList;
    state.actCount = 1;
    state.setCount = 1;
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount]);
    return state;
end

---トリガー時停止系状態異常除去（HPギミックが状態異常で発動できないことを防ぐ）---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;
        local count = 0;
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1;
            if count > 100 then
                break;
            end
        end
    end
end


class:publish();

return class;
