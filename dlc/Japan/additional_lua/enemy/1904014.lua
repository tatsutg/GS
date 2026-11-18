local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="19章闇リヴィエラ", version=1.3, id=1904014});
class:inheritFromEnemy("1904025");

function class:setMessageBoxList()

    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "…いいわ。特別に眷族にしてあげる",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "ファフニール：クリティカルダメージ無効"
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "ファフニール：状態異常のとき被ダメージ・BE量アップ"
        })
    }

    self.HP80_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP80_MESSAGE1 or "これは私だけに託された使命",
            COLOR = Color.magenta
        })
    }

    self.HP60_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP60_MESSAGE1 or "お姫ちゃん……ずっと側にいるからね",
            COLOR = Color.magenta
        })
    }

    self.HP40_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "我らが王に誓う",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE2 or "紅き血をもって大義をなさん",
            COLOR = Color.magenta
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE3 or "奥義上昇量アップ"
        })
    }

    self.HP20_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "紅き血に、誰よりも深く――",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE2 or "奥義上昇量アップ"
        })
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "お姫ちゃん……もう怖くないよ",
            COLOR = Color.magenta
        })
    }

    self.BP_REVERSE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.BP_REVERSE_BUFF_MESSAGE1 or "奥義ゲージ自然上昇効果反転",
            COLOR=Color.red
        })
    }

    self.SUMMON_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "ファフニールが加勢した",
            COLOR=Color.white
        })
    }

end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 30;---addSPの量
    event.unit:setAttackDelay(9);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

    self.breakSkip = false

    self.hpSkill = 0

    self.saveSP = 0

    self.MD = false
    self.MD2 = false

    self.friendID = 1904013
    return 1
end

function class:setAura(unit)
    if self.aura ~= nil then
        if not self.MD2 then
            self.aura:takeAnimation(0,"MD_in",true);
        else
            self.aura:takeAnimation(0,"MD_in2",true);
        end
        return
    end
    self.aura = unit:addOrbitSystemWithFile("MD_5","MD_in");
    self.aura:takeAnimation(0,"MD_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false
end

function class:BPReverse(unit)
    return 0
end

function class:takeDamageValue(event)
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

class:publish();

return class;