local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="ゴル猫ビッグ", version=1.3, id="501531413"});



class.RAGE_BUFF_ARGS = {
  {
        ID = 40078,
        EFID = 21,         --被ダメアップ
        VALUE = 500,        --効果量
        DURATION = 9999999,
        ICON = 139
    }
}

class.RAGE_BUFF_ARGS_FOR_PLAYER = {
    {
        ID = 40076,
        EFID = 17,         --ダメアップ
        VALUE = 500,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}



class.BUFF_VALUE = 30;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    event.unit:setSkillInvocationWeight(0);
    self.hitStopReduceRate = 0;


   self.endTimer = 0;

    self.HP_TRIGGERS = {


    }

    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "味方の与ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE3 or "敵ユニットの被ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 15
        }
    }

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end



function class:update(event)
    self:countDown(event.unit,event.deltaTime);
    return 1;
end
--===============================================================================================================================================

function class:countDown(unit,deltaTime)
    local beforTimer = self.endTimer;
    self.endTimer = self.endTimer + deltaTime;

    if self.endTimer > 300 and beforTimer <= 300 then
        for i=0,4 do
            local targetUnit = Battle:getInstance():getTeam(true):getTeamUnit(i);
            if targetUnit ~= nil then
                self:addBuffs(targetUnit,self.RAGE_BUFF_ARGS_FOR_PLAYER);
            end
        end
        self:addBuffs(unit,self.RAGE_BUFF_ARGS);
        self:showMessage(self.RAGE_MESSAGES);
    end
end

function class:setReduceHitStop(unit)
    unit:setReduceHitStop(2, self.hitStopReduceRate);
end

--===============================================================================================================================================



--===================================================================================================================
-- メッセージ表示系
--[[
showMessage(<table> messageBoxList,<number> index)
   messageBoxList : 
      必須。以下のようなメッセージ表示用のテーブルを用意して投げる
      TEKITOUNA_MESSAGES = [
         [0] = [
            <String> MESSAGE = 本文,
            <Color> COLOR = 色,
            <number> DURATION = 表示期間(秒)]

         ],
         [1] = ...
      ]
   index : 
      任意。messageBoxList[index]の内容を表示する。
      この引数がない場合、messageBoxListの全ての内容を表示する。
]]
function class:showMessage(messageBoxList,index)
   if index == nil then 
      self:showMessageRange(messageBoxList,0,table.maxn(messageBoxList))
   return
   end
   self:execShowMessage(messageBoxList[index])
end

--[[
showMessageRange(<table> messageBoxList,<number> start,<number> last)
   messageBoxList : 
      必須。
   start,last : 
      必須。messageBoxList[start]からmessageBoxList[last]の内容を表示する。
      この引数がない場合、何も表示しない。
]]
function class:showMessageRange(messageBoxList,start,last)
   for i = start,last do
      self:execShowMessage(messageBoxList[i])
   end
end

--[[
showMessageRange(<table> messageBox)
   敵側のメッセージ欄にmessageBoxの内容を表示する
]]
function class:execShowMessage(messageBox)
   summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end

--===================================================================================================================
-- バフ、デバフ追加系
--[[
addBuffs(<event.unit> unit,<table> buffs)
   unit :
      必須。バフを与える対象
   buffs :
      必須。以下のようなバフ用の配列を用意して投げる
      RAGE_BUFFS = {
         {
            <number> ID = 必須。一意のID
            <number> EFID = 必須。バフの効果ID。IDの一覧はDBテーブル定義.スキル効果マスタ参照
            <number> VALUE = 必須。バフ効果量
            <number> DURATION = 必須。持続時間
            <number> ICON = 必須。アイコンID。IDの一覧は企画*多部署連携用シート.バフ・デバフアイコン参照
            <number> EFFECT = 任意。エフェクトID。IDの一覧は企画*多部署連携用シート.スキル効果アニメーション参照
            <number> SCRIPT = 任意。skill_effect内の関数用ID。IDの一覧はDBテーブル定義.スキル効果マスタ参照
            <number> SCRIPTVALUE1 = 任意。skill_effectの第一引数の値
         }
      }
]]
function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

function class:addBuff(unit,args)
    local buff  = nil;
    if args.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
    if args.SCRIPT ~= nil then
        buff:setScriptID(args.SCRIPT);
    end
    if args.SCRIPTVALUE1 ~= nil then
        buff:setValue1(args.SCRIPTVALUE1);
    end

end



--=====================================================================================================================================


function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;