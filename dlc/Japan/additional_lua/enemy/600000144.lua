--@additionalEnemy,600000147
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="レイド_HARD_堕天神獣ジオ＝ザグナス", version=2.8, id=600000144});
class:inheritFromEnemy("600000145");

class.SUMMON_ID = 600000147;        ---召喚するブルーゴブル

---足。download_bundle に unit/50103_leg.zip を載せるため、親と同じ addSubSkeleton をこのファイルにも書く
function class:setupLeg(unit)
    unit:addSubSkeleton("50103_leg",-30);
    unit:setSkin("1");
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "全体CRI率・防御無視無効", COLOR = Color.yellow})
    }
    ---レイド共通ヘイト
    self.RAID_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.RAID_MESSAGE1 or "ボスに狙われている！", COLOR = Color.red, DURATION = 10})
    }
    ---レイド共通テロップ
    self.TELOP_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TELOP_MESSAGE1 or "ボスに狙われると被ダメージが増加します。"}),
        self:setMessageInfo({MESSAGE = self.TEXT.TELOP_MESSAGE2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"}),
        self:setMessageInfo({MESSAGE = self.TEXT.TELOP_MESSAGE3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"})
    }
    self.GLAB_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GLAB_MESSAGE1 or "掴み投げ：%dの固定ダメージ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.GLAB_MESSAGE2 or "時間経過でダメージアップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.GLAB_MESSAGE3 or "攻撃力の高いユニットをターゲット", COLOR = Color.red})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "クエックエックエッ！", COLOR = Color.cyan})
    }
    self.FIRST_SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FIRST_SUMMON_MESSAGE1 or "ブルーゴブルの数に応じて被ダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.FIRST_SUMMON_MESSAGE2 or "ブルーゴブル撃破でパーティの奥義ゲージアップ", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.FIRST_SUMMON_MESSAGE3 or "ブルーゴブル：毒・暗闇・病気・燃焼の時：被ダメージアップ", COLOR = Color.white})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "与ダメージアップ", COLOR = Color.yellow})
    }
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "毒状態のユニットに対してダメージアップ", COLOR = Color.yellow})
    }
    ---奥義11のINFOは VERY HARD のみ
    self.SKILL4_MESSAGE_LIST = {
    }
    self.HUMMER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_MESSAGE1 or "ハンマー状態：防御力アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_MESSAGE2 or "一定ダメージまたはブレイクでハンマー破壊", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_MESSAGE3 or "氷結状態の相手に対してハンマー攻撃で即死攻撃", COLOR = Color.yellow})
    }
    self.HUMMER_BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HUMMER_BREAK_MESSAGE1 or "ハンマー破壊成功！ダメージ耐性・防御力アップ：解除！", COLOR = Color.red})
    }
end

---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 25,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 5,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---レイド共通ヘイト（ボスに狙われている！）
        raidTargetRank = 3,         --ルーム内のこの順位以内で狙われる
        raidTargetPoint = 1000000,  --累計バトルポイントがこの値を超えたら狙われる
        raidTargetDmgVal = 30,      --狙われている間のボスの与ダメージアップ%
        telopSpan = 30,             --レイド共通テロップの間隔秒数

        ---掴み投げ（奥義5）
        throwDownBPRate = 1,        --奥義ゲージDOWN量（バトル経過秒数 × この値）
        throwDownBPMax = 300,       --奥義ゲージDOWN量の上限
        throwFixDmgRate = 30,       --固定ダメージ（バトル経過秒数 × この値）

        ---投射物（スキル7 投射物 → スキル8 毒瓶 → 繰り返し）
        grenadeRecast = 8,          --投射の間隔秒数

        ---ハンマー抜刀（奥義11の後）
        hummerHpRate = 0.2,         --エクストラゲージのHP（ボスの最大HPに対する割合）
        hummerDefVal = 500,         --ハンマー状態の防御力アップ%
        hummerStunTime = 5,         --ハンマー破壊時のボスの気絶秒数
        subBarPosYHummer = 25,      --エクストラゲージ（ハンマー）の表示位置（ボス座標からのオフセットY）

        ---ブルーゴブル召喚
        summonRecast = 20,          --召喚の間隔秒数
        summonFirstNum = 4,         --初回の召喚数
        summonMax = 6,              --場に出せる最大数
        summonTwoRate = 40,         --2体召喚する確率%（残りは1体）
        summonDmgCutRate = 0.15,    --ブルーゴブル1体ごとのボスの被ダメージ軽減率

        ---ワンパン対策
        onePunchDmg = 100000000,    --奥義11を強制発動するダメージ量（このバトルでボスに与えたダメージ）
        subBarPosYOnePunch = 0,     --エクストラゲージ（ワンパン対策）の表示位置（ボス座標からのオフセットY）
    };
end


class:publish();

return class;
