------
-- 英語の定数群
------
local _NAME = "summoner.locale.en_us"
local _M = {}
local _G = _G

_M.UNITS = {
    [100616112] = {
        mess1 = "Emperor Flames"
    },
    --エスト
    [101144211] = {
        mess1 = "Intimidation Effect Activated"
    },
    [101145211] = {
        mess1 = "Intimidation Effect Activated"
    },
    [101146211] = {
        mess1 = "Intimidation Effect Activated"
    },

    --レム
    [101164511] = {
        mess1 = "VS Fire Elemental Bonus",
        mess2 = "VS Water Elemental Bonus",
        mess3 = "VS Earth Elemental Bonus",
        mess4 = "VS Light Elemental Bonus",
        mess5 = "VS Dark Elemental Bonus",
        mess6 = "No Elemental Bonus",
        mess7 = "Astrology: ",
        mess8 = "％"
    },

    [101165511] = {
        mess1 = "VS Fire Elemental Bonus",
        mess2 = "VS Water Elemental Bonus",
        mess3 = "VS Earth Elemental Bonus",
        mess4 = "VS Light Elemental Bonus",
        mess5 = "VS Dark Elemental Bonus",
        mess6 = "No Elemental Bonus",
        mess7 = "Astrology: ",
        mess8 = "％"
    },

    [102275112] = {
        mess1 = "Radiant Flora Itto-Ryu"
    },

    [102276112] = {
        mess1 = "Radiant Flora Itto-Ryu"
    },

    [102486112] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "EX Procyon Blast"
    },

    [102496312] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Giga Grand Slam"
    },

    [102506212] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Great Atem"
    },

    [102666112] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Arcana: Sonic Flame Vortex"
    },

    [102676212] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Raging Blaster"
    },

    [102525512] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Absolute Culling",
        MESSAGE1 = "Intimidation Effect Activated"
    },

    [102526512] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Absolute Culling",
        MESSAGE1 = "Intimidation Effect Activated"
    },

    [103446312] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Stardust Halation"
    },

    [102686412] = {
        BEFORE_MD = "Demonic True Eclipse",
        AFTER_MD = "Crimson Blood"
    },
    
    [102826212] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Starfall Impact \"Seiri-usan\""
    },
    [102836512] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Nirvana \"Udonge-setsu\""
    },
    [102846412] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Hand of the Creator \"Tenchi Kaibyaku\""
    },
    [102856512] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Phoenix Claw \"Osho Reppa\""
    },
    [102866412] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Fleeting Life \"Tamayura\""
    },
    [102886312] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Spider Lily Web \"Higanbana\""
    },
    [102876112] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Meteor Dance \"Seika Ryogen\""
    },

    [102516212] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Arcana: Sonic Polar Vortex"
    },

    [103226412] = {
        BEFORE_MD = "Demonic True Eclipse",
        AFTER_MD = "Schwarzdorn Aufstand"
    },

    [103506511] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Ultimate Technique \"Nehan\"",
        BEFORE_MD2 = "True Third Eye"
    },

    [103516312] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Dazzling Flash \"Kaju Ginka\"",
        BEFORE_MD2 = "True Third Eye"
    },

    [103526112] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Unique Dance \"Shonetsu Jigoku\"",
        BEFORE_MD2 = "True Third Eye"
    },
    [103527112] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Unique Dance \"Shonetsu Jigoku\"",
        BEFORE_MD2 = "True Third Eye"
    },

    [103496212] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Ultimate Heaven \"Suiten Hofutsu\"",
        BEFORE_MD2 = "True Third Eye"
    },

    [103546412] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Accelerated Variant \"Genkai\"",
        BEFORE_MD2 = "True Third Eye"
    },
    [103547412] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Accelerated Variant \"Genkai\"",
        BEFORE_MD2 = "True Third Eye"
    },

    [103566311] = {
        BEFORE_MD = "Third Eye",
        AFTER_MD = "Forbidden Technique #9 \"Nozuchi Garan\"",
        BEFORE_MD2 = "True Third Eye"
    },

    [103576512] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Blood into Blood"
    },

    [103586412] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Kongou Finisher: Musou Rengokujin"
    },

    [103636112] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Quick Draw: Vermilion Flash"
    },
    [103637112] = {
        BEFORE_MD = "Magia Drive",
        AFTER_MD = "Quick Draw: Vermilion Flash"
    },

    [107246112] = {
        mess1 = "I'm not gonna back down!"
    },

    [104046412] = {
        MESSAGE1 = "Intimidation Effect Activated"
    },
    [104047412] = {
        MESSAGE1 = "Intimidation Effect Activated"
    },

    --フレイダル
    [500081213] = {
        messageWind1 = "Storm Mode: Evasion Rate UP",
        messageWind2 = "Storm Mode: Arts Gauge Increase Speed UP",
        messageWindEnd = "Clear Storm Mode"
    },

    --フレイダルコラボ用
    [501221213] = {
        messageWind1 = "Storm Mode: Evasion Rate UP",
        messageWind2 = "Storm Mode: Arts Gauge Increase Speed UP",
        messageWindEnd = "Clear Storm Mode",
        messageCritical = "Critical when Freeze"
    },

    --緑命龍エルプネウマス
    [500133313] = {
        mess1 = "Rage Status: HP regen",
        mess2 = "Rage Status: Break Gauge regen",
        mess3 = "Rage Status: Burning Resistance DOWN",
        mess4 = "Clear Angry Status",
        mess5 = "Resume regen",
        mess6 = "Stop regen"
    },

    --フォスラディウス
    [500144413] = {
        mess1 = "Physical Damage Negated",
        mess2 = "Arts Gauge Boost UP",
        mess3 = "Break Gauge Restored"
    },

    --マヴロスキア
    [500155513] = {
        mess1 = "Rage Status: Break Power UP",
        mess2 = "Clear Angry Status"
    },

    -- 猛餓獣樹ゴロンドーラ
    [500201313] = {
        RAGE = "Rage Status"
    },

    --ミラ
    [500362193] = {
        mess1 = "Demon Killer",
        mess2 = "Earth Elemental Killer",
        mess3 = "Guts EX: Damage Inflicted UP",
        mess4 = "Guts EX: Movement Speed UP",
        mess5 = "Burning Critical",
        mess6 = "Phoenix EX: Won't fall & regen",
        mess7 = "Phoenix EX: Arts Gauge Speed UP",
        mess8 = "Phoenix EX: HP regen",
        mess9 = "Clear Phoenix Status"
    },

    --フェン
    [500382393] = {
        mess1 = "Ice Magic Sword \"Almas\"",
        mess2 = "Drakkeus Bolt",
        mess3 = "Underking Spear \"Hellfire\"",
        mess4 = "Demonsickle Evilscythe",
        mess5 = "Conquering Dragon Sword \"Gelmed\"",
        mess6 = "Relic「Force Keratos」",
        mess7 = "Heals Status Ailment",
        mess8 = "Sacred Crown「Raaz」EX",
        mess9 = "Status Ailment Resistance UP",
        mess10 = "Ru「I won't let you!!!」",
        mess11 = "Cruze's Pocket Watch EX",
        mess12 = "Enemy's Skill CT Speed DOWN",
        mess13 = "Monster Summon Stone EX",
        mess14 = "Inflict Paralyze & HP regenerates",
        mess15 = "Divine Glowing Arrow Cycnus",
        talk1 = "Rayas「I'm going all in, Fen!」",
        talk2 = "Fen「Hmph, as if you'd stand a chance.」",
        talk3 = "Rayas「I'll show you my powers!」"
    },

    --ゼイオルグ
    [500402493] = {
        mess1 = "Reduces Damage Taken by 50%",
        mess2 = "Damage 50% UP & Attack Speed UP",
        mess3 = "Last Stand"
    },

    --ガナン
    [500431193] = {
        mess1 = "Arts gauge fills even FASTER!",
        mess2 = "Attack frequency UP!",
        mess3 = "DMG from enemy 50% UP!",
        mess4 = "DMG to enemy 50% UP!",
        mess5 = "Negates Paralyze & Freeze",
        mess6 = "Arts gauge fills at double speed",
        mess7 = "CRI rate UP!",
        mess8 = "Attack frequency UP!"
    },

    [500442193] = {
        mess1 = "Arts gauge fills even FASTER!",
        mess2 = "Attack frequency UP!",
        mess3 = "DMG from enemy 50% UP!",
        mess4 = "DMG to enemy 50% UP!",
        mess5 = "Negates Paralyze & Freeze",
        mess6 = "Arts gauge fills at double speed",
        mess7 = "CRI rate UP!",
        mess8 = "Attack frequency UP!"
    },

    --ギリアム
    [500451393] = {
        mess1 = "Equipment Takes 3x Damage",
        mess2 = "Attack Speed UP",
        mess3 = "Activated Item for Giliam",
        mess4 = "Arts Damage"
    },

    [500462393] = {
        mess1 = "Equipment Takes 3x Damage",
        mess2 = "Attack Speed UP",
        mess3 = "Activated Item for Giliam",
        mess4 = "Arts Damage"
    },

    --イフリート
    [500641113] = {
        mess1 = "Water Elemental Magic Damage x2",
        mess2 = "Burning: Attack Speed UP",
        mess3 = "Clear Attack Speed UP"
    },

    --パルラミシア
    [500651213] = {
        mess1 = "Earth Elemental Resistance -40%",
        mess2 = "Protective Water Stance",
        mess3 = "Heavenly Water Stance",
        mess4 = "HP regen",
        mess5 = "HP regen amount UP"
    },

    --焔神官カロン
    [500681113] = {
        mess1 = "You must protect me!"
    },

    --黒ヴァル
    [500711513] = {
        mess1 = "Negates Status Ailment",
        mess2 = "Shadow Lightning Stance"
    },

    --CODE XTF : ERASER
    [500721013] = {
        mess1 = "Attack mode: Attack Speed UP",
        mess2 = "Normal mode: Stores Elemental Damage",
        mess3 = "Significant Decrease of DEF",
        mess4 = "Finis Machina Activated",
        mess5 = "Fire Elemental Energy",
        mess6 = "Water Elemental Energy",
        mess7 = "Earth Elemental Energy",
        mess8 = "Light Elemental Energy",
        mess9 = "Dark Elemental Energy",
        mess10 = "No Elemental Energy",
        mess11 = "Fire Elemental Resistance UP",
        mess12 = "Water Elemental Resistance UP",
        mess13 = "Earth Elemental Resistance UP",
        mess14 = "Light Elemental Resistance UP",
        mess15 = "Dark Elemental Resistance UP",
        mess16 = "Clear Elemental Resistance",
        mess17 = "％"
    },

    --ラグシェルムファントム
    [500731513] = {
        mess1 = "Damage towards Target UP",
        mess2 = "True Nightmare Stance",
        mess3 = "Sureshot"
    },

    --絶望ラグシェルムファントム
    [500741513] = {
        mess1 = "Damage towards Target UP",
        mess2 = "True Nightmare Stance",
        mess3 = "Sureshot"
    },

    --被験体β
    [500771013] = {
        mess1 = "Attack Speed UP",
        mess2 = "Negates Magic Damage",
        mess3 = "Damage Inflicted UP",
        mess4 = "Critical Rate UP"
    },

    [500821513] = {
        mess1 = "Break Resistance UP",
        mess2 = "DMG UP"
    },

    --クオン
    [500871413] = {
        mess1 = "3x DMG during Break"
    },

    [500872413] = {
        mess1 = "3x DMG during Break"
    },

    [500861413] = {
        START_MESSAGE = "ATK & Accuracy UP",
        BUFF_MESSAGE = "DMG UP",
        CHARGE_MESSAGE = "The space-time continuum is beginning to warp!",
        REVERCE_MESSAGE1 = "Space and time themselves are at my beck and call!",
        REVERCE_MESSAGE2 = "Wander aimlessly for all eternity!"
    },
    [500841013] = {
        START_MESSAGE1 = "ATK & Accuracy UP",
        START_MESSAGE2 = "Shield Killer",
        RAGE_MESSAGE1 = "Action speed UP",
        RAGE_MESSAGE2 = "DMG UP",
        RACE1 = "Human",
        RACE2 = "Beast",
        RACE3 = "Spirit",
        RACE4 = "Giant",
        RACE5 = "Machine",
        RACE6 = "Dragon",
        RACE7 = "God",
        RACE8 = "Demon",
        SPECLAI1 = "'s Arts gauge filling speed DOWN",
        SPECLAI2 = "s' Skill CT speed DOWN"
    },

    --エスト
    [500912213] = {
        mess1 = "Critical Rate 100%",
        mess2 = "Movement Speed UP",
        mess3 = "Arts Gauge regen",
        mess4 = "Movement Speed UP",
        mess5 = "50% less Damage"
    },

    --トニトゥルス（樹怪鳥）
    [500921313] = {
        messageWind1 = "Storm Mode: Accuracy rate UP",
        messageWind2 = "Storm Mode: HP Auto-recovery",
        messageWindEnd = "Storm Mode CANCELED"
    },

    --銀ヴァル
    [500931513] = {
        mess1 = "Shadow Lightning Stance [Evolved]",
        mess2 = "Damage Resistance DOWN",
        mess3 = "Fallen Cells Reactivated",
        mess4 = "Boss has targeted you!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Targeted by Boss!",
        telop4 = "Boss has powered up!",
        telop5 = "When your unit falls, replace them and fight!",
        telop6 = "Rewards will vary according to your ranking."
    },

    --エドラム
    [500961412] = {
        mess1 = "Charge Speed UP",
        mess2 = "Damage x3 during Freezing"
    },

    [500962412] = {
        mess1 = "Charge Speed UP",
        mess2 = "Damage x3 during Freezing"
    },

    [501005213] = {
        mess1 = "Earth Damage x3"
    },

    [101715211] = {
        mess1 = "Negates Certain Damage"
    },

    --魔獣レイド用
    [501021113] = {
        mess1 = "Targeted by Boss!",
        mess2 = "+%d pt",
        mess3 = "Rage mode",
        mess4 = " defeated %d enemies",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Targeted by Boss!",
        telop4 = "Boss has powered up!",
        telop5 = "When your unit falls, replace them and fight!",
        telop6 = "Rewards will vary according to your ranking."
    },
  
    [500122213] = {
        mess1 = "Rage mode: Continous Damage",
        mess2 = "Clear Angry Status",
        mess3 = "Damage Resistance during Freeze",
        mess4 = "Break Damage Resistance during Freeze",
        mess5 = "HP regen during Freeze",
        mess6 = "Dragonic Cocytus",
        mess7 = "Physical Resistance"
    },

    --リシュリー
    [101846112] = {
        mess1 = "All Status UP"
    },

    --グロール
    [101825412] = {
        mess1 = "CRI rate %d％"
    },
    [101826412] = {
        mess1 = "CRI rate %d％"
    },

    [101945312] = {
        mess1 = "Critical%d％"
    },
    [101946312] = {
        mess1 = "Critical%d％"
    },

    [102176312] = {
        mess1 = "奥義ゲージアップ"
    },

    --メリア
    [101074511] = {
        text1 = "Skill Usable\nBE frequency UP",
        text2 = "Auto-barrier"
    },

    [101075511] = {
        text1 = "Skill Usable\nBE frequency UP",
        text2 = "Auto-barrier"
    },

    [101076511] = {
        text1 = "Skill Usable\nBE frequency UP",
        text2 = "Auto-barrier"
    },

    [101205412] = {
        text1 = "Reduces Damage",
    },

    --ミレニア
    [101725112] = {
        text1 = "Evasion Rate UP",
        text2 = "Critical%s",
        text3 = "Combo"
    },

    [101724112] = {
        text1 = "Evasion Rate UP",
        text2 = "Critical%s",
        text3 = "Combo"
    },

    --グランブレイブ
    [101754111] = {
        text1 = "Skill Recovery Speed UP"
    },
    [101755111] = {
        text1 = "Skill Recovery Speed UP"
    },

    --ナンバーツー
    [101785512] = {
        text1 = "Arts Gauge Absorb",
        text2 = "Blood Rage LV"
    },
    [101786512] = {
        text1 = "Arts Gauge Absorb",
        text2 = "Blood Rage LV",
        text3 = "God Rage LV"
    },

    --リアン
    [101796112] = {
        text1 = "Arts Damage UP",
        text2 = "Skill Recovery Speed UP"
    },
    [101795112] = {
        text1 = "Arts Damage UP",
        text2 = "Skill Recovery Speed UP"
    },

    --XTF CODE:SEEKER
    [500161013] = {
        text1 = "Attack Mode",
        text2 = "Barrier Mode"
    },

    --レグルス　ユニットボス
    [500941513] = {
        mess1 = "Critical Rate 100%",
    },

    [500971513] = {
        mess1 = "Damage towards Target UP",
        mess2 = "Halloween Nightmare",
        mess3 = "Sureshot"
    },

    [500981313] = {
        RAGE = "Rage Mode",
        ANTIDAMAGE = "Halves All DMG (except CRI DMG)",
        ANTICRITICAL = "Halves All DMG (except while Burning)",
        ANTIWATER = "Drain Water DMG",
        BARRIEREND = "Cancel DMG Negating",
        REGENATION = "HP Auto-recovery",
        BURN = "Stop Auto-recovery",
        RESTART = "Restart Auto-recovery",
        ANTIBURN = "Burn Resistance",
        TALK1 = "Welcome! Get ready!",
        TALK2 = "Not bad... But I ain't gonna lose!",
        TALK3 = "No, no way... Here's my last hope!",
        TALK4 = "NO WAAAAAAAAAAAAY!",
        mess1 = "Negates Physical DMG",
        mess2 = "Demon Killer"
    },

    [501061113] = {
        mess1 = "ボスに狙われている！",
        telop1 = "ボスに狙われると被ダメージが増加します。",
        telop2 = "ユニットが倒れた時は、入れ替えて戦いましょう。",
        telop3 = "ボスに狙われています！",
        telop4 = "ランキングの結果によって、撃破時の報酬の個数が変化します。",
        telop5 = "ユニットが倒れた時は、入れ替えて戦いましょう。",
        telop6 = "ランキングの結果によって、撃破時の報酬の個数が変化します。"
    },

    [501071113] = {
        mess1 = "ボスに狙われている！",
        telop1 = "ボスに狙われると被ダメージが増加します。",
        telop2 = "ユニットが倒れた時は、入れ替えて戦いましょう。",
        telop3 = "ボスに狙われています！",
        telop4 = "ランキングの結果によって、撃破時の報酬の個数が変化します。",
        telop5 = "ユニットが倒れた時は、入れ替えて戦いましょう。",
        telop6 = "ランキングの結果によって、撃破時の報酬の個数が変化します。"
    },

    [501081113] = {
        mess1 = "ボスに狙われている！",
        telop1 = "ボスに狙われると被ダメージが増加します。",
        telop2 = "ユニットが倒れた時は、入れ替えて戦いましょう。",
        telop3 = "ボスに狙われています！",
        telop4 = "ランキングの結果によって、撃破時の報酬の個数が変化します。",
        telop5 = "ユニットが倒れた時は、入れ替えて戦いましょう。",
        telop6 = "ランキングの結果によって、撃破時の報酬の個数が変化します。"
    },

    [501091113] = {
        mess1 = "ボスに狙われている！",
        telop1 = "ボスに狙われると被ダメージが増加します。",
        telop2 = "ユニットが倒れた時は、入れ替えて戦いましょう。",
        telop3 = "ボスに狙われています！",
        telop4 = "ランキングの結果によって、撃破時の報酬の個数が変化します。",
        telop5 = "ユニットが倒れた時は、入れ替えて戦いましょう。",
        telop6 = "ランキングの結果によって、撃破時の報酬の個数が変化します。"
    },

    [501101513] = {
        mess1 = "ボスに狙われている！",
        telop1 = "ボスに狙われると被ダメージが増加します。",
        telop2 = "ユニットが倒れた時は、入れ替えて戦いましょう。",
        telop3 = "ボスに狙われています！",
        telop4 = "ランキングの結果によって、撃破時の報酬の個数が変化します。",
        telop5 = "ユニットが倒れた時は、入れ替えて戦いましょう。",
        telop6 = "ランキングの結果によって、撃破時の報酬の個数が変化します。"
    },

    [500071113] = {
        messageWind1 = "Storm Mode: Evasion Rate UP",
        messageWindEnd = "Clear Storm Mode",
        burn = "HP Auto-recovery when burning",
        burn2 = "Increases DMG while burning",
        burnEnd = "HP Auto-recovery ends",
        critical = "Negates Critical"
    },
    [101885512] = {
        mess1 = "Insta-Kill"
    },
    [101886512] = {
        mess1 = "Insta-Kill"
    },

    --オージュレイド用
    [501111413] = {
        mess1 = "Targeted by Boss!",
        mess2 = "Fallen Cells Activated.",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Targeted by Boss!",
        telop4 = "Boss has powered up!",
        telop5 = "When your unit falls, replace them and fight!",
        telop6 = "Rewards will vary according to your ranking."
    },

    [101905412] = {
        mess1 = "Future Vision"
    },

    [101906412] = {
        mess1 = "Future Vision"
    },

    [501171513] = {
        mess1 = "Dark Elemental Resistance"
    },

    [501181313] = {
        mess1 = "Attack Speed UP",
        mess2 = "Negates Magic Damage",
        mess3 = "Damage Inflicted UP",
        mess4 = "Critical Rate UP",
        mess5 = "Earth Elemental Resistance",
        mess6 = "DEF UP during Break"
    },

    [501191413] = {
        mess1 = "Negates all DMG except Fire & Non-Elemental",
        mess2 = "HP Auto-recovery",
        mess3 = "Negates all DMG except Water & Non-Elemental",
        mess4 = "CRI rate UP",
        mess5 = "Negates all DMG except Earth & Non-Elemental",
        mess6 = "Freeze Attack",
        mess7 = "Negates DMG"
    },
    [501121513] = {
        mess1 = "Hgyuuu... Hngaah...",
        mess2 = "Greeegh... Gyuugh...",
        mess3 = "Skraaa... Skaaaargh..."
    },
    [501131513] = {
        mess1 = "Hgyuuu... Hngaah...",
        mess2 = "Greeegh... Gyuugh...",
        mess3 = "Skraaa... Skaaaargh..."
    },
    [501141513] = {
        mess1 = "Hgyuuu... Hngaah...",
        mess2 = "Greeegh... Gyuugh...",
        mess3 = "Skraaa... Skaaaargh..."
    },
    [501151513] = {
        mess1 = "Hgyuuu... Hngaah...",
        mess2 = "Greeegh... Gyuugh...",
        mess3 = "Skraaa... Skaaaargh..."
    },
    [501161513] = {
        mess1 = "Hgyuuu... Hngaah...",
        mess2 = "Greeegh... Gyuugh...",
        mess3 = "Skraaa... Skaaaargh..."
    },
    [103056511] = {
        MESSAGE1 = "I'll show you I can bear this pain."
    },
    [103055511] = {
        MESSAGE1 = "I'll show you I can bear this pain."
    },
    [103053511] = {
        MESSAGE1 = "I'll show you I can bear this pain."
    },
    [107116112]={
        mess1 = "Sugimoto the Immortal"
    },

    [107295212]={
        MESSAGE1 = "I didn't die for nothing!"
    },
    [107296212]={
        MESSAGE1 = "I didn't die for nothing!"
    },

    [501251513] = {
        START_MESSAGE1 = "CRI rate UP to Poisoned enemy",
        START_MESSAGE2 = "CRI DMG UP to Blinded enemy",
        START_MESSAGE3 = "Accuracy rate UP",
        RAGE_MESSAGE1 = "Anger mode : CRI rate UP",
        DEAD_MESSAGE1 = "Villakurz' Praise",
        ATTACK4 = "Prize Mist"
    },
    [501311413] = {
        HP_REDUCE_MESSAGE = "MAX HP DOWN",
        START_MESSAGE = "Negate Light Unit DMG & Break",
        BUFF_MESSAGE1 = "Negate DMG end",
        BUFF_MESSAGE2 = "DMG UP",
        BUFF_MESSAGE3 = "CRI Rate UP"
    },
    [501461513] = {
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Rewards will vary according to your ranking."
    },
    [501471113] = {
        DEAD_MESSAGE1 = "Red Pumpkin defeated+%dpt"
    },
    [501471213] = {
        DEAD_MESSAGE1 = "Blue Pumpkin defeated+%dpt"
    },
    [501471313] = {
        DEAD_MESSAGE1 = "Green Pumpkin defeated+%dpt"
    },
    [501471413] = {
        DEAD_MESSAGE1 = "Yellow Pumpkin defeated+%dpt"
    },
    [501471513] = {
        DEAD_MESSAGE1 = "Purple Pumpkin defeated+%dpt"
    },
    [501472413] = {
        DEAD_MESSAGE1 = "Lucky Pumpkin defeated+%dpt"
    },
    [501472013] = {
        DEAD_MESSAGE1 = "Skull Pumpkin defeated+%dpt"
    },
    [501611113] = {
        DEAD_MESSAGE1 = "Truly...a glorious battle.",
        SKILL_MESSAGE1 = "Do you hear the stars' fury?",
        SKILL_MESSAGE2 = "My flames are building...",
        SKILL_MESSAGE3 = "You will never approach me.",
        START_MESSAGE1 = "CRI rate UP to Burning enemys",
        START_MESSAGE2 = "Negates Fire DMG",
        START_MESSAGE3 = "Physical Evasion rate UP",
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Rewards will vary according to your ranking."
    },
    [501651513] = {
        mess1 = "Shadow Lightning Stance [Evolved]",
        mess2 = "Damage Resistance DOWN",
        mess3 = "Fallen Cells Reactivated",
        mess4 = "Targeted by Boss!",
        mess5 = "Boss's DEF down over time.",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Targeted by Boss!",
        telop4 = "Boss has powered up!",
        telop5 = "When your unit falls, replace them and fight!",
        telop6 = "Rewards will vary according to your ranking."
    },
    [501771313] = {
        DEAD_MESSAGE1 = "This must be...a cruel joke.",
        HP20_MESSAGE1 = "Arts gauge filling speed, DMG & CRI RES. UP",
        SKILL3T_MESSAGE2 = "Targets unit with highest Arts gauge",
        SKILL3_MESSAGE1 = "Yes, you will die here!",
        START_MESSAGE1 = "Are we ready to begin?",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Shield & HP Auto-recovery Killer",
        START_MESSAGE4 = "DMG from Demons &",
        START_MESSAGE5 = "DMG taken during Status Ailment DOWN"
    },
    [501591013] = {
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Rewards will vary according to your ranking.",
        START_MESSAGE1 = "Water Killer",
        START_MESSAGE2 = "Shield Canceled with Break DMG",
        ARTS_MESSAGE1 = "λ μα Δ Яωt",
        ARTS_MESSAGE2 = "βνη εε ЯπμZ αΣ ζДη χ",
        BREAK_MESSAGE1 = "Shield destroyed:DMG taken UP",
        HP_TRIGGER_MESSAGE1 = "Action speed UP"
    },
    [501541013] = {
        DEAD = "Finis Machina Activated",
        DECAY_MESSAGE1 = "Consumes Element energy: Finis Machina power decay",
        ELEMENT_AQUA = "Water energy",
        ELEMENT_BUFF_AQUA = "Water resistance UP",
        ELEMENT_BUFF_DARK = "Dark resistance UP",
        ELEMENT_BUFF_EARTH = "Earth resistance UP",
        ELEMENT_BUFF_FIRE = "Fire resistance UP",
        ELEMENT_BUFF_LIGHT = "Light resistance UP",
        ELEMENT_DARK = "Dark energy",
        ELEMENT_EARTH = "Earth energy",
        ELEMENT_FIRE = "Fire energy",
        ELEMENT_KILLER_AQUA = "Water Killer",
        ELEMENT_KILLER_DARK = "Dark Killer",
        ELEMENT_KILLER_EARTH = "Earth Killer",
        ELEMENT_KILLER_FIRE = "Fire Killer",
        ELEMENT_KILLER_LIGHT = "Light Killer",
        ELEMENT_LIGHT = "Light energy",
        START_MESSAGE1 = "Element changes for certain amount of DMG",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },

}

_M.ENEMIES = {
    --クランチロール姫
    [200410014] = {
        START_MESSAGE1 = "I'm not gonna back down!"
    },

    --緑命龍エルプネウマス
    [49923] = {
        mess1 = "Rage Status: HP regen",
        mess2 = "Rage Status: Break Gauge regen",
        mess3 = "Rage Status: Burning Resistance DOWN",
        mess4 = "Clear Angry Status",
        mess5 = "Resume regen",
        mess6 = "Stop regen"
    },

    [2000592] = {
        mess1 = "Rage Status: HP regen",
        mess2 = "Rage Status: Break Gauge regen",
        mess3 = "Rage Status: Burning Resistance DOWN",
        mess4 = "Clear Angry Status",
        mess5 = "Resume regen",
        mess6 = "Stop regen"
    },

    [500133905] = {
        mess1 = "Rage Status: HP regen",
        mess2 = "Rage Status: Break Gauge regen",
        mess3 = "Rage Status: Burning Resistance DOWN",
        mess4 = "Clear Angry Status",
        mess5 = "Resume regen",
        mess6 = "Stop regen"
    },

    [500133915] = {
        mess1 = "Rage Status: HP regen",
        mess2 = "Rage Status: Break Gauge regen",
        mess3 = "Rage Status: Burning Resistance DOWN",
        mess4 = "Clear Angry Status",
        mess5 = "Resume regen",
        mess6 = "Stop regen"
    },

    [500133925] = {
        mess1 = "Rage Status: HP regen",
        mess2 = "Rage Status: Break Gauge regen",
        mess3 = "Rage Status: Burning Resistance DOWN",
        mess4 = "Clear Angry Status",
        mess5 = "Resume regen",
        mess6 = "Stop regen"
    },

    --黒ヴァル覚醒級
    [50023] = {
        mess1 = "Shadow Lightning Stance",
        mess2 = "Invincible Status",
        mess3 = "Status Ailment Negated"
    },

    --黒ヴァル
    [500711109] = {
        mess1 = "Shadow Lightning Stance"
    },

    [500711209] = {
        mess1 = "Shadow Lightning Stance"
    },

    --黒ヴァル超級
    [500711409] = {
        mess1 = "Negates Status Ailment",
        mess2 = "Shadow Lightning Stance",
        mess3 = "Status Ailment Negated"
    },

    --フォスラディウス覚醒級
    [50123] = {
        mess1 = "Physical Damage Negated",
        mess2 = "Arts Gauge Boost UP",
        mess3 = "Negates Critical Damage"
    },


    --フォスラディウス
    [500144109] = {
        mess1 = "Physical Damage Negated",
        mess2 = "Arts Gauge Boost UP"
    },

    [500144209] = {
        mess1 = "Physical Damage Negated",
        mess2 = "Arts Gauge Boost UP"
    },

    [500144409] = {
        mess1 = "Physical Damage Negated",
        mess2 = "Arts Gauge Boost UP"
    },

    --ラ＝リズ魔導研究所のフェン
    [70614] = {
        mess1 = "Fen: Human Killer",
        mess2 = "Fen: Freezing Resistance"
    },

    --ラ＝リズ魔導研究所のゼイオルグ
    [70615] = {
        mess1 = "Zeorg: Stun Resistance",
        mess2 = "Zeorg: Damage inflicted UP",
        mess3 = "Zeorg: Attack Speed UP",
        mess4 = "Zeorg: Critical Rate UP"
    },

    --焔神官カロン
    [1001089] = {
        mess1 = "You must protect me!"
    },

    [1001094] = {
        mess1 = "You must protect me!"
    },

    [100616] = {
        START_MESSAGE = "ATK & Accuracy UP",
        BUFF_MESSAGE = "DMG UP",
        CHARGE_MESSAGE = "The space-time continuum is beginning to warp!",
        REVERCE_MESSAGE1 = "Space and time themselves are at my beck and call!",
        REVERCE_MESSAGE2 = "Wander aimlessly for all eternity!"
    },

    [100711] = {
        START_MESSAGE1 = "I have nothing else to say.",
        START_MESSAGE2 = "ATK & Accuracy UP",
        HP50_MESSAGE1 = "Know the sublime might of the Ancients.",
        HP50_MESSAGE2 = "Action speed UP",
        HP25_MESSAGE1 = "Perish, you foolish inferiors."
    },
    [100714] = {
        START_MESSAGE1 = "I have nothing else to say.",
        START_MESSAGE2 = "ATK & Accuracy UP",
        HP50_MESSAGE1 = "Know the sublime might of the Ancients.",
        HP50_MESSAGE2 = "Action speed UP",
        HP25_MESSAGE1 = "Perish, you foolish inferiors."
    },

    [500681509] = {
        mess1 = "You must protect me!"
    },

    [500681539] = {
        mess1 = "You must protect me!"
    },

    [1105009] = {
        START_MESSAGE1 = "Dark & CRI resistance",
        START_MESSAGE2 = "DMG taken UP during Break",
        HP65_MESSAGE1 = "ATK & DMG UP",
        HP35_MESSAGE1 = "Action speed & Break resistance UP"
    },
    [1105015] = {
        START_MESSAGE1 = "Dark & CRI resistance",
        START_MESSAGE2 = "DMG taken UP during Break",
        HP65_MESSAGE1 = "ATK & DMG UP",
        HP35_MESSAGE1 = "Action speed & Break resistance UP"
    },
    [1105018] = {
        START_MESSAGE1 = "Let me wake up first, OK?",
        HP50_MESSAGE1 = "Fully charged."
    },
    [1105021] = {
        START_MESSAGE1 = "Let me wake up first, OK?",
        HP50_MESSAGE1 = "Fully charged."
    },
    [1105024] = {
        START_MESSAGE1 = "Dark & CRI resistance",
        START_MESSAGE2 = "DMG taken UP during Break",
        HP65_MESSAGE1 = "ATK & DMG UP",
        HP35_MESSAGE1 = "Action speed & Break resistance UP"
    },

    [1203009] = {
        HP35_MESSAGE1 = "Action speed & Break resistance UP ",
        HP65_MESSAGE1 = "ATK & DMG UP ",
        START_MESSAGE1 = "Dark & CRI resistance ",
        START_MESSAGE2 = "DMG taken UP during Break ",
    },
    [1203015] = {
        HP35_MESSAGE1 = "Action speed & Break resistance UP ",
        HP65_MESSAGE1 = "ATK & DMG UP ",
        START_MESSAGE1 = "Dark & CRI resistance ",
        START_MESSAGE2 = "DMG taken UP during Break "
    },
    [1203015] = {
        DEAD_MESSAGE1 = "Darkness...is eternal... ",
        RAGE2_MESSAGE1 = "Perish in despair... ",
        RAGE2_MESSAGE2 = "ATK, DMG & Action speed UP ",
        RAGE_MESSAGE1 = "Blasphemy...must be punished. ",
        START_MESSAGE1 = "Dark resistance ",
        START_MESSAGE2 = "Negates ATK from Demons ",
        START_MESSAGE3 = "Gods & Humans Killer"
    },
    [1205018] = {
        START_MESSAGE1 = "Let's get started." ,
        HP50_MESSAGE = "Is that all you've got?" ,
        HP30_MESSAGE = "Evasion rate UP" ,
        DEAD_MESSAGE = "Not bad, but next round is mine."
    },
    [1205021] = {
        START_MESSAGE1 = "Let's get started." ,
        HP50_MESSAGE = "Is that all you've got?" ,
        HP30_MESSAGE = "Evasion rate UP" ,
        DEAD_MESSAGE = "Not bad, but next round is mine." ,
    },
    [1205024] = {
        START1 = "Dark Killer",
        START2 = "Demon Killer",
        START3 = "CRI resistance",
        mess1 = "DEF UP",
        mess2 = "Evasion rate UP",
        mess3 = "ATK UP"
    },

    [1305015] = {
        BREAK_MESSAGE1 = "Power-up cancelled by Break! ",
        DEAD_MESSAGE1 = "Is this...the end? ",
        HP30_MESSAGE1 = "I don't care anymore. I'll crush everything. ",
        HP30_MESSAGE2 = "ATK & Arts gauge filling speed UP ",
        POWERUP1_MESSAGE1 = "DMG taken DOWN & Anti-DMG Negation",
        POWERUP1_MESSAGE2 = "cancelled by Faint/Break",
        POWERUP2_MESSAGE1 = "CRI rate UP cancelled by Faint/Break ",
        SKILL1_MESSAGE1 = "Your power is mine. ",
        SKILL2_MESSAGE1 = "Perish. ",
        STAN_MESSAGE1 = "Power-up cancelled by Faint! ",
        START_MESSAGE1 = "So, you defy me? ",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
    },
    [1305018] = {
        DEAD_MESSAGE1 = "This'll mean a lot of paperwork... ",
        HP50_MESSAGE1 = "You're wide open. ",
        START_MESSAGE1 = "Commencing mission. ",
    },
    [1305021] = {
        DEAD_MESSAGE1 = "This'll mean a lot of paperwork... ",
        HP50_MESSAGE1 = "You're wide open. ",
        START_MESSAGE1 = "Commencing mission. ",
    },
    [1305024] = {
        BREAK_MESSAGE1 = "Power-up cancelled by Break! ",
        DEAD_MESSAGE1 = "Is this...the end? ",
        FREEZE_MESSAGE1 = "Power-up cancelled by Freeze! ",
        HP20_MESSAGE1 = "I don't care anymore. I'll crush everything. ",
        HP20_MESSAGE2 = "ATK & Arts gauge filling speed UP ",
        PARALYZE_MESSAGE1 = "Power-up cancelled by Paralysis! ",
        POWERUP1_MESSAGE1 = "Converts Arts gauge to DMG UP",
        POWERUP1_MESSAGE2 = "cancelled by Paralysis/Freeze/Faint/Break ",
        SKILL1_MESSAGE1 = "Your power is mine. ",
        SKILL2_MESSAGE1 = "Perish. ",
        STAN_MESSAGE1 = "Power-up cancelled by Faint! ",
        START_MESSAGE1 = "So, you defy me? ",
        START_MESSAGE2 = "Negates Magic DMG & DMG taken DOWN during Arts "
    },
    [1305025] = {
        BREAK_MESSAGE1 = "Power-up cancelled by Break! ",
        DEAD_MESSAGE1 = "Is this...the end? ",
        HP30_MESSAGE1 = "I don't care anymore. I'll crush everything. ",
        HP30_MESSAGE2 = "ATK & Arts gauge filling speed UP ",
        POWERUP1_MESSAGE1 = "DMG taken DOWN & Anti-DMG Negation",
        POWERUP1_MESSAGE2 = "cancelled by Faint/Break",
        POWERUP2_MESSAGE1 = "CRI rate UP cancelled by Faint/Break ",
        SKILL1_MESSAGE1 = "Your power is mine. ",
        SKILL2_MESSAGE1 = "Perish. ",
        STAN_MESSAGE1 = "Power-up cancelled by Faint! ",
        START_MESSAGE1 = "So, you defy me? ",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES. "
    },

    [1404015] = {
        DEAD_MESSAGE1 = "Is this...the end? ",
        HP10_MESSAGE1 = "Arts gauge filling speed & Action speed UP ",
        HP30_MESSAGE1 = "CRI resistance & DEF UP ",
        HP50_MESSAGE1 = "I don't care anymore. I'll crush everything. ",
        HP50_MESSAGE2 = "DMG UP ",
        HP70_MESSAGE1 = "CRI resistance UP ",
        HP90_MESSAGE1 = "DMG UP ",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "DMG taken UP during disease state & Shield Killer ",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG ",
        START_MESSAGE4 = "CRI rate UP to a target ",
    },
    [1404016] = {
        DEAD_MESSAGE1 = "Is this...the end? ",
        HP10_MESSAGE1 = "Arts gauge filling speed & Action speed UP ",
        HP30_MESSAGE1 = "CRI resistance & DEF UP ",
        HP50_MESSAGE1 = "I don't care anymore. I'll crush everything. ",
        HP50_MESSAGE2 = "DMG UP ",
        HP70_MESSAGE1 = "CRI resistance UP ",
        HP90_MESSAGE1 = "DMG UP ",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "DMG taken UP during disease state ",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG ",
        START_MESSAGE4 = "CRI rate UP to a target ",
    },
    [1405018] = {
        DEAD_MESSAGE1 = "I refuse...to admit... ",
        HP50_MESSAGE1 = "So, you defy me? ",
        START_MESSAGE1 = "Fall beneath my heel. "
    },
    [1405021] = {
        DEAD_MESSAGE1 = "I refuse...to admit... ",
        HP50_MESSAGE1 = "So, you defy me? ",
        START_MESSAGE1 = "Fall beneath my heel. "
    },
    [1405024] = {
        DEAD_MESSAGE1 = "No, I can't lose... ",
        HP10_MESSAGE1 = "This'll finish you off. ",
        HP10_MESSAGE2 = "Negation cancelled & DMG taken DOWN during Arts ",
        HP30_MESSAGE1 = "I'm done playing around. ",
        HP30_MESSAGE2 = "DMG UP & Arts gauge filling speed UP ",
        HP60_MESSAGE1 = "Calm yourselves. ",
        START_MESSAGE1 = "You actually want to oppose me? ",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resistance ",
        START_MESSAGE3 = "Shield Killer ",
        START_MESSAGE4 = "DMG UP to Blinded units ",
        text1 = "Skill Usable BE frequency UP ",
        text2 = "Auto-barrier "
    },

    [1504016] = {
        DEAD_MESSAGE1 = "This must be...a cruel joke.",
        HP20_MESSAGE1 = "Arts gauge filling speed, DMG & CRI RES. UP",
        SKILL3T_MESSAGE2 = "Targets unit with highest Arts gauge",
        SKILL3_MESSAGE1 = "Yes, you will die here!",
        START_MESSAGE1 = "Are we ready to begin?",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE4 = "DMG from Demons &",
        START_MESSAGE5 = "DMG taken during Status Ailment DOWN"
    },
    [1505018] = {
        DEAD_MESSAGE1 = "What? But...why?",
        HP50_MESSAGE1 = "I'm beginning to enjoy myself.",
        START_MESSAGE1 = "Do you mind if I kill you now?"
    },
    [1505021] = {
        DEAD_MESSAGE1 = "What? But...why?",
        HP50_MESSAGE1 = "I'm beginning to enjoy myself.",
        START_MESSAGE1 = "Do you mind if I kill you now?"
    },
    [1505024] = {
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG from Earth UP",
        START_MESSAGE3 = "DMG UP to Poisoned units"
    },

    [1604016] = {
        ANTI_PROTECTION_MESSAGE1 = "Faint & DMG taken UP to shielding unit",
        DEAD_MESSAGE1 = "I won't accept this!",
        HP1_MESSAGE1 = "This is a dead end.",
        HP40_MESSAGE1 = "This is pain.",
        HP40_MESSAGE2 = "Arts gauge filling speed & DMG UP",
        START_MESSAGE1 = "Are you sure you're ready?",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Magic resistance"
    },
    [1604015] = {
        ANTI_PROTECTION_MESSAGE1 = "Faint & DMG taken UP to shielding unit",
        DEAD_MESSAGE1 = "I won't accept this!",
        HP1_MESSAGE1 = "This is a dead end.",
        HP40_MESSAGE1 = "This is pain.",
        HP40_MESSAGE2 = "Arts gauge filling speed & DMG UP",
        START_MESSAGE1 = "Are you sure you're ready?",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Magic resistance"
    },
    [1605015] = {
        BREAK_MESSAGE1 = "I must've slipped up...",
        BREAK_MESSAGE2 = "Impregnable mode canceled during Break",
        DEAD_FALSE_MESSAGE1 = "That was incredible...",
        DEAD_TRUE_MESSAGE1 = "So, this is the Kingdom Blade's power...?",
        FALSE_MESSAGE1 = "Sin will never be undone.",
        HP25_MESSAGE1 = "To me, Sword of Conquest!",
        HP25_MESSAGE2 = "Arts gauge filling speed & CRI resistance UP",
        HP50_MESSAGE1 = "To me, Sword of Control!",
        HP50_MESSAGE2 = "Arts gauge filling speed & DEF UP",
        HP75_MESSAGE1 = "To me, Sword of Coruscation!",
        HP75_MESSAGE2 = "Arts gauge filling speed & DMG UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Shield Killer",
        START_MESSAGE3 = "Impregnable mode: canceled by Break",
        TARGET_MESSAGE1 = "Break resistance UP",
        TARGET_MESSAGE2 = "Targeting the unit inflicts the greatest DMG",
        TARGET_MESSAGE3 = "CRI rate UP to a target",
        TRUE_MESSAGE1 = "Are you prepared, Rayas?",
        WEAPON_MESSAGE1 = "Sky Light: Gods' Arts gauge DOWN",
        WEAPON_MESSAGE2 = "Terra Master: Humans' Arts gauge DOWN",
        WEAPON_MESSAGE3 = "Dark Bringer: Demons' Arts gauge DOWN",
        WEAPON_MESSAGE4 = "　All allies' Accuracy DOWN",
        WEAPON_MESSAGE5 = "　All allies' DMG taken UP",
        WEAPON_MESSAGE6 = "　Continuous DMG to all allies",
    },
    [1605018] = {
        DEAD_MESSAGE1 = "Wait, I still haven't...",
        HP50_MESSAGE1 = "I will extinguish your flame.",
        START_MESSAGE1 = "Are you my enemy?"
    },
    [1605021] = {
        DEAD_MESSAGE1 = "It can't end like this...",
        HP50_MESSAGE1 = "You're just a victim of hatred.",
        START_MESSAGE1 = "Are you sure you're ready?"
    },
    [1605024] = {
        HP1_MESSAGE1 = "Bestow your blessing, Imperial Blades.",
        HP50_MESSAGE1 = "Boss' DEF UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG from Light UP",
        START_MESSAGE3 = "CRI resistance & Shield Killer"
    },
    [1605025] = {
        BREAK_MESSAGE1 = "I must've slipped up...",
        BREAK_MESSAGE2 = "Impregnable mode canceled during Break",
        DEAD_FALSE_MESSAGE1 = "That was incredible...",
        DEAD_TRUE_MESSAGE1 = "So, this is the Kingdom Blade's power...?",
        FALSE_MESSAGE1 = "Sin will never be undone.",
        HP25_MESSAGE1 = "To me, Sword of Conquest!",
        HP25_MESSAGE2 = "Arts gauge filling speed & CRI resistance UP",
        HP50_MESSAGE1 = "To me, Sword of Control!",
        HP50_MESSAGE2 = "Arts gauge filling speed & DEF UP",
        HP75_MESSAGE1 = "To me, Sword of Coruscation!",
        HP75_MESSAGE2 = "Arts gauge filling speed & DMG UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Impregnable mode: canceled by Break",
        TARGET_MESSAGE1 = "Break resistance UP",
        TARGET_MESSAGE2 = "Targeting the unit inflicts the greatest DMG",
        TARGET_MESSAGE3 = "CRI rate UP to a target",
        TRUE_MESSAGE1 = "Are you prepared, Rayas?",
        WEAPON_MESSAGE1 = "Sky Light: Gods' Arts gauge DOWN",
        WEAPON_MESSAGE2 = "Terra Master: Humans' Arts gauge DOWN",
        WEAPON_MESSAGE3 = "Dark Bringer: Demons' Arts gauge DOWN",
        WEAPON_MESSAGE4 = "　All allies' Accuracy DOWN",
        WEAPON_MESSAGE5 = "　All allies' DMG taken UP",
        WEAPON_MESSAGE6 = "　Continuous DMG to all allies",
    },

    [1704015] = {
        BREAK_MESSAGE1 = "Rage mode Cancelled",
        HP30_MESSAGE1 = "Physical resistance UP",
        HP30_MESSAGE2 = "Units' Freezing resistance DOWN",
        HP50_MESSAGE1 = "Physical resistance UP",
        HP70_MESSAGE1 = "Rage mode: DEF UP",
        HP70_MESSAGE2 = "Physical resistance UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG from Earth UP"
    },
    [1705018] = {
        DEAD_MESSAGE1 = "You actually know how to fight...",
        HP50_MESSAGE1 = "I won't stop for anything.",
        START_MESSAGE1 = "Get ready to get whipped!"
    },
    [1705021] = {
        DEAD_MESSAGE1 = "You actually know how to fight...",
        HP50_MESSAGE1 = "I won't stop for anything.",
        START_MESSAGE1 = "Get ready to get whipped!"
    },
    [1705024] = {
        BREAK_MESSAGE1 = "Rage mode Cancelled",
        HP30_MESSAGE1 = "Physical resistance UP",
        HP30_MESSAGE2 = "Units' Freezing resistance DOWN",
        HP50_MESSAGE1 = "Physical resistance UP",
        HP70_MESSAGE1 = "Rage mode: DEF UP",
        HP70_MESSAGE2 = "Physical resistance UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG from Earth UP"
    },
    [1705027] = {
        BREAK_MESSAGE1 = "Rage mode Cancelled",
        HP30_MESSAGE1 = "Physical resistance UP",
        HP30_MESSAGE2 = "Units' Freezing resistance DOWN",
        HP50_MESSAGE1 = "Physical resistance UP",
        HP70_MESSAGE1 = "Rage mode: DEF UP",
        HP70_MESSAGE2 = "Physical resistance UP",
        SKILL_MESSAGE1 = "ATK DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG from Earth UP",
        START_MESSAGE3 = "Earth units' Break power UP"
    },

    [1803003] = {
        HP50_MESSAGE1 = "Physical resistance UP",
        HP_MESSAGE1 = "Physical & Magic resistance UP",
        HP_MESSAGE2 = "DMG from Equipment's Skill UP",
        START_MESSAGE1 = "DMG from Fire & Light UP",
        START_MESSAGE2 = "DMG from Equipment's Skill UP"
    },
    [1803014] = {
        DEAD_MESSAGE1 = "No way...",
        HP40_MESSAGE1 = "Our pledge to our ruler!",
        HP40_MESSAGE2 = "The call to justice running deep in our crimson blood!",
        HP40_MESSAGE3 = "Arts gauge filling speed UP & Magic DMG DOWN",
        HP60_MESSAGE1 = "Now I'm mad!",
        HP80_MESSAGE1 = "Time to get serious!",
        START_MESSAGE1 = "Rosetta, magician supreme, is here!",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE3 = "CRI rate UP to the unit with 50% or more HP",
        START_MESSAGE4 = "DMG taken UP during Faint",
        AFTER_MD = "Raging Blaster",
        BEFORE_MD = "Magia Drive",
    },
    [1803015] = {
        DEAD_MESSAGE1 = "Leone, everyone...I'm sorry...",
        HP20_MESSAGE1 = "Deeper into the abyss of blood.",
        HP20_MESSAGE2 = "Arts gauge filling speed & CRI resistance UP",
        HP40_MESSAGE1 = "Our pledge to our ruler!",
        HP40_MESSAGE2 = "The call to justice running deep in our crimson blood!",
        HP40_MESSAGE3 = "Arts gauge filling speed UP & Physical DMG DOWN",
        HP60_MESSAGE1 = "The brilliance of the cosmos!",
        HP80_MESSAGE1 = "The power of language!",
        SKILL2_MESSAGE1 = "DMG: %d％ of MAX HP",
        SKILL3_MESSAGE1 = "DMG negation cancelled",
        START_MESSAGE1 = "Tougher, stronger, slightly more grown-up!",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "CRI rate UP to the unit with 50% or more HP",
        START_MESSAGE4 = "DMG taken UP during Blind",
        START_MESSAGE5 = "Water Killer"
    },
    [1803016] = {
        DEAD_MESSAGE1 = "No way...",
        HP40_MESSAGE1 = "Our pledge to our ruler!",
        HP40_MESSAGE2 = "The call to justice running deep in our crimson blood!",
        HP40_MESSAGE3 = "Arts gauge filling speed UP & Magic DMG DOWN",
        HP60_MESSAGE1 = "Now I'm mad!",
        HP80_MESSAGE1 = "Time to get serious!",
        START_MESSAGE1 = "Rosetta, magician supreme, is here!",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE3 = "CRI rate UP to the unit with 50% or more HP",
        START_MESSAGE4 = "DMG taken UP during Faint",
        AFTER_MD = "Raging Blaster",
        BEFORE_MD = "Magia Drive"
    },
    [1803017] = {
        DEAD_MESSAGE1 = "Leone, everyone...I'm sorry...",
        HP20_MESSAGE1 = "Deeper into the abyss of blood.",
        HP20_MESSAGE2 = "Arts gauge filling speed & CRI resistance UP",
        HP40_MESSAGE1 = "Our pledge to our ruler!",
        HP40_MESSAGE2 = "The call to justice running deep in our crimson blood!",
        HP40_MESSAGE3 = "Arts gauge filling speed UP & Physical DMG DOWN",
        HP60_MESSAGE1 = "The brilliance of the cosmos!",
        HP80_MESSAGE1 = "The power of language!",
        SKILL2_MESSAGE1 = "DMG: %d％ of MAX HP",
        SKILL3_MESSAGE1 = "DMG negation cancelled",
        START_MESSAGE1 = "Tougher, stronger, slightly more grown-up!",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "CRI rate UP to the unit with 50% or more HP",
        START_MESSAGE4 = "DMG taken UP during Blind",
        START_MESSAGE5 = "Water Killer"
    },
    [1805018] = {
        DEAD_MESSAGE1 = "Too strong...!",
        HP50_MESSAGE1 = "Go, Lance of Anointing Stardust!",
        START_MESSAGE1 = "May victory be ours."
    },
    [1805021] = {
        DEAD_MESSAGE1 = "I messed up!",
        HP50_MESSAGE1 = "Burn bright, Gramlude!",
        START_MESSAGE1 = "I'll clear the way."
    },
    [1805024] = {
        HP50_MESSAGE1 = "Physical resistance UP",
        HP_MESSAGE1 = "Physical resistance UP",
        HP_MESSAGE2 = "DMG from Equipment's Skill UP",
        START_MESSAGE1 = "DMG from Fire & Light UP",
        START_MESSAGE2 = "DMG from Equipment's Skill UP"
    },
    [1805027] = {
        HP50_MESSAGE1 = "Physical resistance UP",
        HP_MESSAGE1 = "Physical resistance UP",
        HP_MESSAGE2 = "DMG from Equipment's Skill UP",
        START_MESSAGE1 = "DMG from Fire & Light UP",
        START_MESSAGE2 = "DMG from Equipment's Skill UP",
        START_MESSAGE3 = "DMG from Water, Earth, & Dark DOWN",
        START_MESSAGE4 = "Boss's DMG increases every 10s"
    },

    [1904013] = {
        START_MESSAGE1 = "Fafnir: Negates CRI DMG",
        START_MESSAGE2 = "Fafnir: DMG taken & BE Output UP during Status Ailmemt"
    },
    [1904014] = {
        BP_REVERSE_BUFF_MESSAGE1 = "Reverse Arts gauge Auto-fill",
        DEAD_MESSAGE1 = "Don't be afraid anymore, Little Lady...",
        HP20_MESSAGE1 = "Deeper than anyone...",
        HP20_MESSAGE2 = "Arts gauge filling speed UP",
        HP40_MESSAGE1 = "Our pledge to our ruler!",
        HP40_MESSAGE2 = "The call to justice running deep in our crimson blood!",
        HP40_MESSAGE3 = "Arts gauge filling speed UP",
        HP60_MESSAGE1 = "I know you're with me, Little Lady.",
        HP80_MESSAGE1 = "This is something only I can do.",
        START_MESSAGE1 = "Fine, I'll make you my servant.",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Fafnir: Negates CRI DMG",
        START_MESSAGE4 = "Fafnir: DMG taken & BE Output UP during Status Ailmemt",
        SUMMON_MESSAGE1 = "Fafnir joins the battle"
    },
    [1904015] = {
        START_MESSAGE1 = "Fafnir: Negates CRI DMG",
        START_MESSAGE2 = "Fafnir: DMG taken & BE Output UP during Status Ailmemt"
    },
    [1904025] = {
        BP_REVERSE_BUFF_MESSAGE1 = "Reverse Arts gauge Auto-fill",
        DEAD_MESSAGE1 = "Don't be afraid anymore, Little Lady...",
        HP20_MESSAGE1 = "Deeper than anyone...",
        HP20_MESSAGE2 = "Arts gauge filling speed UP & Cancels DMG Negation",
        HP40_MESSAGE1 = "Our pledge to our ruler!",
        HP40_MESSAGE2 = "The call to justice running deep in our crimson blood!",
        HP40_MESSAGE3 = "Arts gauge filling speed UP & Cancels regular DMG",
        HP60_MESSAGE1 = "I know you're with me, Little Lady.",
        HP80_MESSAGE1 = "This is something only I can do.",
        START_MESSAGE1 = "Fine, I'll make you my servant.",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Fafnir: Negates CRI DMG",
        START_MESSAGE4 = "Fafnir: DMG taken & BE Output UP during Status Ailmemt",
        SUMMON_MESSAGE1 = "Fafnir joins the battle"
    },

    [1904013] = {
        START_MESSAGE1 = "Fafnir: Negates CRI DMG",
        START_MESSAGE2 = "Fafnir: DMG taken & BE Output UP during Status Ailmemt"
    },
    [1904014] = {
        BP_REVERSE_BUFF_MESSAGE1 = "Reverse Arts gauge Auto-fill",
        DEAD_MESSAGE1 = "Don't be afraid anymore, Little Lady...",
        HP20_MESSAGE1 = "Deeper than anyone...",
        HP20_MESSAGE2 = "Arts gauge filling speed UP",
        HP40_MESSAGE1 = "Our pledge to our ruler!",
        HP40_MESSAGE2 = "The call to justice running deep in our crimson blood!",
        HP40_MESSAGE3 = "Arts gauge filling speed UP",
        HP60_MESSAGE1 = "I know you're with me, Little Lady.",
        HP80_MESSAGE1 = "This is something only I can do.",
        START_MESSAGE1 = "Fine, I'll make you my servant.",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Fafnir: Negates CRI DMG",
        START_MESSAGE4 = "Fafnir: DMG taken & BE Output UP during Status Ailmemt",
        SUMMON_MESSAGE1 = "Fafnir joins the battle"
    },
    [1904015] = {
        START_MESSAGE1 = "Fafnir: Negates CRI DMG",
        START_MESSAGE2 = "Fafnir: DMG taken & BE Output UP during Status Ailmemt"
    },
    [1904025] = {
        BP_REVERSE_BUFF_MESSAGE1 = "Reverse Arts gauge Auto-fill",
        DEAD_MESSAGE1 = "Don't be afraid anymore, Little Lady...",
        HP20_MESSAGE1 = "Deeper than anyone...",
        HP20_MESSAGE2 = "Arts gauge filling speed UP & Cancels DMG Negation",
        HP40_MESSAGE1 = "Our pledge to our ruler!",
        HP40_MESSAGE2 = "The call to justice running deep in our crimson blood!",
        HP40_MESSAGE3 = "Arts gauge filling speed UP & Cancels regular DMG",
        HP60_MESSAGE1 = "I know you're with me, Little Lady.",
        HP80_MESSAGE1 = "This is something only I can do.",
        START_MESSAGE1 = "Fine, I'll make you my servant.",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Fafnir: Negates CRI DMG",
        START_MESSAGE4 = "Fafnir: DMG taken & BE Output UP during Status Ailmemt",
        SUMMON_MESSAGE1 = "Fafnir joins the battle"
    },
    [1905018] = {
        START_MESSAGE1 = "Here I come!",
        HP50_MESSAGE1 = "That won't stop me!",
        DEAD_MESSAGE1 = "Riv...iera..."
    },
    [1905021] = {
        START_MESSAGE1 = "You'll regret this.",
        HP50_MESSAGE1 = "Stay out of my way.",
        DEAD_MESSAGE1 = "Little Lady..."
    },
    [1905024] = {
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG from Dark & Light UP"
    },

    --修行の間　ヨミ
    [1001507] = {
        mess1 = "ATK UP"
    },

    --修行の間　ゾルダス
    [1001508] = {
        mess1 = "Magic Resistance UP"
    },


	-- 猛餓獣樹ゴロンドーラ ルゥイベント真Ex
    [200320048] = {
        RAGE = "Rage Status",
        REGENATION = "HP regen",
        BURN = "Stop regen",
        RESTART = "Resume regen"
    },

    --CODE XTF : ERASER
    [2000569] = {
        mess1 = "Attack mode: Attack Speed UP",
        mess2 = "Normal mode: Stores Elemental Damage",
        mess3 = "Significant Decrease of DEF",
        mess4 = "Finis Machina Activated",
        mess5 = "Fire Elemental Energy",
        mess6 = "Water Elemental Energy",
        mess7 = "Earth Elemental Energy",
        mess8 = "Light Elemental Energy",
        mess9 = "Dark Elemental Energy",
        mess10 = "No Elemental Energy",
        mess11 = "Fire Elemental Resistance UP",
        mess12 = "Water Elemental Resistance UP",
        mess13 = "Earth Elemental Resistance UP",
        mess14 = "Light Elemental Resistance UP",
        mess15 = "Dark Elemental Resistance UP",
        mess16 = "Clear Elemental Resistance",
        mess17 = "％"
    },

    [500080123] = {
        mess1 = "Attack mode: Attack Speed UP",
        mess2 = "Normal mode: Stores Elemental Damage",
        mess3 = "Significant Decrease of DEF",
        mess4 = "Finis Machina Activated",
        mess5 = "Fire Elemental Energy",
        mess6 = "Water Elemental Energy",
        mess7 = "Earth Elemental Energy",
        mess8 = "Light Elemental Energy",
        mess9 = "Dark Elemental Energy",
        mess10 = "No Elemental Energy",
        mess11 = "Fire Elemental Resistance UP",
        mess12 = "Water Elemental Resistance UP",
        mess13 = "Earth Elemental Resistance UP",
        mess14 = "Light Elemental Resistance UP",
        mess15 = "Dark Elemental Resistance UP",
        mess16 = "Clear Elemental Resistance",
        mess17 = "％"
    },

    [500721935] = {
        mess1 = "Attack mode: Attack Speed UP",
        mess2 = "Normal mode: Stores Elemental Damage",
        mess3 = "Significant Decrease of DEF",
        mess4 = "Finis Machina Activated",
        mess5 = "Fire Elemental Energy",
        mess6 = "Water Elemental Energy",
        mess7 = "Earth Elemental Energy",
        mess8 = "Light Elemental Energy",
        mess9 = "Dark Elemental Energy",
        mess10 = "No Elemental Energy",
        mess11 = "Fire Elemental Resistance UP",
        mess12 = "Water Elemental Resistance UP",
        mess13 = "Earth Elemental Resistance UP",
        mess14 = "Light Elemental Resistance UP",
        mess15 = "Dark Elemental Resistance UP",
        mess16 = "Clear Elemental Resistance",
        mess17 = "％"
    },

    [500721945] = {
        mess1 = "Attack mode: Attack Speed UP",
        mess2 = "Normal mode: Stores Elemental Damage",
        mess3 = "Significant Decrease of DEF",
        mess4 = "Finis Machina Activated",
        mess5 = "Fire Elemental Energy",
        mess6 = "Water Elemental Energy",
        mess7 = "Earth Elemental Energy",
        mess8 = "Light Elemental Energy",
        mess9 = "Dark Elemental Energy",
        mess10 = "No Elemental Energy",
        mess11 = "Fire Elemental Resistance UP",
        mess12 = "Water Elemental Resistance UP",
        mess13 = "Earth Elemental Resistance UP",
        mess14 = "Light Elemental Resistance UP",
        mess15 = "Dark Elemental Resistance UP",
        mess16 = "Clear Elemental Resistance",
        mess17 = "％"
    },

    [500721955] = {
        mess1 = "Attack Mode: Attack Speed UP",
        mess2 = "Normal Mode: Stores Elemental Damage",
        mess3 = "Major DEF DOWN",
        mess4 = "Finis Machina Activated",
        mess5 = "Fire Energy",
        mess6 = "Water Energy",
        mess7 = "Earth Energy",
        mess8 = "Light Energy",
        mess9 = "Dark Energy",
        mess10 = "No Elemental Energy",
        mess11 = "Fire resistance UP",
        mess12 = "Water resistance UP",
        mess13 = "Earth resistance UP",
        mess14 = "Light resistance UP",
        mess15 = "Dark resistance UP",
        mess16 = "Elemental resistance End",
        mess17 = "％"
    },

    [200210071] = {
        mess1 = "Attack Mode: Attack Speed UP",
        mess2 = "Normal Mode: Stores Elemental Damage",
        mess3 = "Major DEF DOWN",
        mess4 = "Finis Machina Activated",
        mess5 = "Fire Energy",
        mess6 = "Water Energy",
        mess7 = "Earth Energy",
        mess8 = "Light Energy",
        mess9 = "Dark Energy",
        mess10 = "No Elemental Energy",
        mess11 = "Fire resistance UP",
        mess12 = "Water resistance UP",
        mess13 = "Earth resistance UP",
        mess14 = "Light resistance UP",
        mess15 = "Dark resistance UP",
        mess16 = "Elemental resistance End",
        mess17 = "％"
    },

    --ミラ
    [2000617] = {
        mess1 = "Demon Killer",
        mess2 = "Earth Elemental Killer",
        mess3 = "Guts EX: Damage Inflicted UP",
        mess4 = "Guts EX: Movement Speed UP",
        mess5 = "Burning Critical",
        mess6 = "Phoenix EX: Won't fall & regen",
        mess7 = "Phoenix EX: Arts Gauge Speed UP",
        mess8 = "Phoenix EX: HP regen",
        mess9 = "Clear Phoenix Status"
    },

    [100151201] = {
        START_MESSAGE1 = "Super-recovery",
        START_MESSAGE2 = "Train for 180 seconds"
    },

    [200020027] = {
        BREAK_END_MESSAGE1 = "Break resistance UP",
        BREAK_MESSAGE1 = "Break! DMG taken UP!",
        DEAD_MESSAGE1 = "I see you've made progress...",
        HP0_MESSAGE1 = "Watch when a pro gets serious!",
        HP0_MESSAGE2 = "Break resistance & Arts gauge filling speed UP",
        HP20_MESSAGE1 = "I'm nowhere near through yet.",
        HP20_MESSAGE2 = "Paralysis resistance & Evasion rate UP",
        HP60_MESSAGE1 = "Is that really everything?",
        HP60_MESSAGE2 = "Paralysis & CRI resistance UP",
        HP80_MESSAGE1 = "Surely you can handle this much.",
        HP80_MESSAGE2 = "Evasion rate UP",
        SKILL1_MESSAGE1 = "MAX HP DOWN",
        SKILL2_MESSAGE1 = "DMG Negation canceled & Faints the Leader",
        START_MESSAGE1 = "Bring everything you have!",
        START_MESSAGE2 = "Physical, Reflection, & Arts gauge DOWN RES.",
        START_MESSAGE3 = "DMG taken UP during Break and/or Paralyzed"
    },

    [200020903] = {
        START_MESSAGE1 = "So, you decided to show up?",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE3 = "Negates Magic DMG taken & Light killer",
        START_MESSAGE4 = "DMG taken UP when in Status Ailments",
        HP30_MESSAGE1 = "I'll see if you're well-done!",
        HP30_MESSAGE2 = "DMG & Arts Gauge Speed UP",
        DEAD_MESSAGE1 = "Not bad at all..."
    },
    [200020904] = {
        START_MESSAGE1 = "I won't hold back.",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE3 = "Negates Physical DMG taken & Shield killer",
        START_MESSAGE4 = "DMG taken UP during Break",
        HP30_MESSAGE1 = "I'm not burned out yet!",
        HP30_MESSAGE2 = "DMG & Arts Gauge Speed UP",
        DEAD_MESSAGE1 = "That was pretty good..."
    },
    [200020905] = {
        START_MESSAGE1 = "Can you cut the mustard?",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES",
        START_MESSAGE3 = "Cancels DMG negation",
        HP60_MESSAGE1 = "You know your way around a knife!",
        HP60_MESSAGE2 = "DMG & Arts Gauge Speed UP",
        HP20_MESSAGE1 = "I'm master of the kitchen!",
        HP20_MESSAGE2 = "CRI rate & Arts Gauge Speed UP",
        DEAD_MESSAGE1 = "There's no doubt...you've got skill."
    },

    [200030036] = {
        mess1 = "Demon Killer",
        mess2 = "Earth Elemental Killer",
        mess3 = "Guts EX: Damage Inflicted UP",
        mess4 = "Guts EX: Movement Speed UP",
        mess5 = "Burning Critical",
        mess6 = "Phoenix EX: Won't fall & regen",
        mess7 = "Phoenix EX: Arts Gauge Speed UP",
        mess8 = "Phoenix EX: HP regen",
        mess9 = "Clear Phoenix Status"
    },

    [200030073] = {
        mess1 = "Demon Killer",
        mess2 = "Earth Killer",
        mess3 = "Guts EX: DMG UP",
        mess4 = "Guts EX: Action speed UP",
        mess5 = "Burn Critical",
        mess6 = "Phoenix EX: won't fall & HP Auto-recovery",
        mess7 = "Phoenix EX: Arts gauge DOWN",
        mess8 = "Phoenix EX: HP Auto-recovery",
        mess9 = "Phoenix Status CANCELED"
    },

    [200030075] = {
        mess1 = "Demon Killer",
        mess2 = "Earth Killer",
        mess3 = "Guts EX: DMG UP",
        mess4 = "Guts EX: Action speed UP",
        mess5 = "Burn Critical",
        mess6 = "Phoenix EX: won't fall & HP Auto-recovery",
        mess7 = "Phoenix EX: Arts gauge DOWN",
        mess8 = "Phoenix EX: HP Auto-recovery",
        mess9 = "Phoenix Status CANCELED"
    },

    --ソフィ
    [2000622] = {
        mess1 = "Special Butter Brioche",
        mess2 = "HP regen",
        mess3 = "Special Dragon Steak",
        mess4 = "Damage inflicted 30% UP",
        mess5 = "Special Hot Dog",
        mess6 = "Attack Speed UP",
        mess7 = "Special Paella",
        mess8 = "Arts Gauge Speed UP",
        mess9 = "I'll show you my passionate cooking!"
    },
    [500511005] = {
        mess1 = "Special Butter Brioche",
        mess2 = "HP regen",
        mess3 = "Special Dragon Steak",
        mess4 = "Damage inflicted 30% UP",
        mess5 = "Special Hot Dog",
        mess6 = "Attack Speed UP",
        mess7 = "Special Paella",
        mess8 = "Arts Gauge Speed UP",
        mess9 = "I'll show you my passionate cooking!"
    },
    [500522015] = {
        mess1 = "Special Butter Brioche",
        mess2 = "HP regen",
        mess3 = "Special Dragon Steak",
        mess4 = "Damage inflicted 30% UP",
        mess5 = "Special Hot Dog",
        mess6 = "Attack Speed UP",
        mess7 = "Special Paella",
        mess8 = "Arts Gauge Speed UP",
        mess9 = "I'll show you my passionate cooking!"
    },
    [500522025] = {
        mess1 = "Special Butter Brioche",
        mess2 = "HP regen",
        mess3 = "Special Dragon Steak",
        mess4 = "Damage inflicted 30% UP",
        mess5 = "Special Hot Dog",
        mess6 = "Attack Speed UP",
        mess7 = "Special Paella",
        mess8 = "Arts Gauge Speed UP",
        mess9 = "I'll show you my passionate cooking!"
    },
    [500522035] = {
        mess1 = "Special Butter Brioche",
        mess2 = "HP regen",
        mess3 = "Special Dragon Steak",
        mess4 = "Damage inflicted 30% UP",
        mess5 = "Special Hot Dog",
        mess6 = "Attack Speed UP",
        mess7 = "Special Paella",
        mess8 = "Arts Gauge Speed UP",
        mess9 = "I'll show you my passionate cooking!"
    },
    [500522045] = {
        mess1 = "Special Butter Brioche",
        mess2 = "HP regen",
        mess3 = "Special Dragon Steak",
        mess4 = "Damage inflicted 30% UP",
        mess5 = "Special Hot Dog",
        mess6 = "Attack Speed UP",
        mess7 = "Special Paella",
        mess8 = "Arts Gauge Speed UP",
        mess9 = "I'll show you my passionate cooking!"
    },

    --ガナン
    [2000630] = {
        mess1 = "Arts gauge fills even FASTER!",
        mess2 = "Attack frequency UP!",
        mess3 = "DMG from enemy 50% UP!",
        mess4 = "DMG to enemy 50% UP!",
        mess5 = "Negates Paralyze & Freeze",
        mess6 = "Arts gauge fills at double speed",
        mess7 = "CRI rate UP!",
        mess8 = "Attack frequency UP!"
    },
    [500431100] = {
        mess1 = "Arts gauge fills even FASTER!",
        mess2 = "Attack frequency UP!",
        mess3 = "DMG from enemy 50% UP!",
        mess4 = "DMG to enemy 50% UP!",
        mess5 = "Negates Paralyze & Freeze",
        mess6 = "Arts gauge fills at double speed",
        mess7 = "CRI rate UP!",
        mess8 = "Attack frequency UP!"
    },
    [500442100] = {
        mess1 = "Arts gauge fills even FASTER!",
        mess2 = "Attack frequency UP!",
        mess3 = "DMG from enemy 50% UP!",
        mess4 = "DMG to enemy 50% UP!",
        mess5 = "Negates Paralyze & Freeze",
        mess6 = "Arts gauge fills at double speed",
        mess7 = "CRI rate UP!",
        mess8 = "Attack frequency UP!"
    },
    [500442200] = {
        mess1 = "Arts gauge fills even FASTER!",
        mess2 = "Attack frequency UP!",
        mess3 = "DMG from enemy 50% UP!",
        mess4 = "DMG to enemy 50% UP!",
        mess5 = "Negates Paralyze & Freeze",
        mess6 = "Arts gauge fills at double speed",
        mess7 = "CRI rate UP!",
        mess8 = "Attack frequency UP!"
    },
    [500442300] = {
        mess1 = "Arts gauge fills even FASTER!",
        mess2 = "Attack frequency UP!",
        mess3 = "DMG from enemy 50% UP!",
        mess4 = "DMG to enemy 50% UP!",
        mess5 = "Negates Paralyze & Freeze",
        mess6 = "Arts gauge fills at double speed",
        mess7 = "CRI rate UP!",
        mess8 = "Attack frequency UP!"
    },
    [500442400] = {
        mess1 = "Arts gauge fills even FASTER!",
        mess2 = "Attack frequency UP!",
        mess3 = "DMG from enemy 50% UP!",
        mess4 = "DMG to enemy 50% UP!",
        mess5 = "Negates Paralyze & Freeze",
        mess6 = "Arts gauge fills at double speed",
        mess7 = "CRI rate UP!",
        mess8 = "Attack frequency UP!"
    },

    --グラード
    [2000631] = {
        mess1 = "Damage against Roy increases",
        mess2 = "Damage Inflicted UP",
        mess3 = "Arts Gauge Increase Speed UP",
        mess4 = "Increases Roy's Damage",
        mess5 = "Lifesteal",
        mess6 = "Attack Speed UP",
        mess7 = "Summon Evil Death Wings",
        mess8 = "Light & Dark Elemental Killer",
        talk1 = "Roy...I'm gonna be the one who defeats you!",
        talk2 = "Go ahead and try if you think you can beat me.",
        talk3 = "Yeah...I will...I'll do it!",
        talk4 = "Today's the day we end this.",
        talk5 = "Sorry, but I just don't sense that I'll lose.",
        talk6 = "Tsk...That attitute...",
        talk7 = "I can't stand you!",
        talk8 = "Well...Let's have some fun then!",
        talk9 = "I have no time to waste with you.",
        talk10 = "Ha! I'll make you regret it soon!"
    },

    [200040028] = {
        mess1 = "Damage against Roy increases",
        mess2 = "Damage Inflicted UP",
        mess3 = "Arts Gauge Increase Speed UP",
        mess4 = "Increases Roy's Damage",
        mess5 = "Lifesteal",
        mess6 = "Attack Speed UP",
        mess7 = "Summon Evil Death Wings",
        mess8 = "Light & Dark Elemental Killer",
        talk1 = "Roy...I'm gonna be the one who defeats you!",
        talk2 = "Go ahead and try if you think you can beat me.",
        talk3 = "Yeah...I will...I'll do it!",
        talk4 = "Today's the day we end this.",
        talk5 = "Sorry, but I just don't sense that I'll lose.",
        talk6 = "Tsk...That attitute...",
        talk7 = "I can't stand you!",
        talk8 = "Well...Let's have some fun then!",
        talk9 = "I have no time to waste with you.",
        talk10 = "Ha! I'll make you regret it soon!"
    },
    [200040024] = {
        mess1 = "Damage against Roy increases",
        mess2 = "Damage Inflicted UP",
        mess3 = "Arts Gauge Increase Speed UP",
        mess4 = "Increases Roy's Damage",
        mess5 = "Lifesteal",
        mess6 = "Attack Speed UP",
        mess7 = "Summon Evil Death Wings",
        mess8 = "Light & Dark Elemental Killer",
        talk1 = "Roy...I'm gonna be the one who defeats you!",
        talk2 = "Go ahead and try if you think you can beat me.",
        talk3 = "Yeah...I will...I'll do it!",
        talk4 = "Today's the day we end this.",
        talk5 = "Sorry, but I just don't sense that I'll lose.",
        talk6 = "Tsk...That attitute...",
        talk7 = "I can't stand you!",
        talk8 = "Well...Let's have some fun then!",
        talk9 = "I have no time to waste with you.",
        talk10 = "Ha! I'll make you regret it soon!"
    },
    [200040020] = {
        mess1 = "Damage against Roy increases",
        mess2 = "Damage Inflicted UP",
        mess3 = "Arts Gauge Increase Speed UP",
        mess4 = "Increases Roy's Damage",
        mess5 = "Lifesteal",
        mess6 = "Attack Speed UP",
        mess7 = "Summon Evil Death Wings",
        mess8 = "Light & Dark Elemental Killer",
        talk1 = "Roy...I'm gonna be the one who defeats you!",
        talk2 = "Go ahead and try if you think you can beat me.",
        talk3 = "Yeah...I will...I'll do it!",
        talk4 = "Today's the day we end this.",
        talk5 = "Sorry, but I just don't sense that I'll lose.",
        talk6 = "Tsk...That attitute...",
        talk7 = "I can't stand you!",
        talk8 = "Well...Let's have some fun then!",
        talk9 = "I have no time to waste with you.",
        talk10 = "Ha! I'll make you regret it soon!"
    },
    [200040000] = {
        mess1 = "Damage against Roy increases",
        mess2 = "Human Killer",
        mess3 = "Arts Gauge  Speed UP",
        mess4 = "Increases Roy's Damage"
    },
    [200040006] = {
        mess1 = "Damage against Roy increases",
        mess2 = "Human Killer",
        mess3 = "Arts Gauge  Speed UP",
        mess4 = "Increases Roy's Damage"
    },
    [200040012] = {
        mess1 = "Damage against Roy increases",
        mess2 = "Human Killer",
        mess3 = "Arts Gauge  Speed UP",
        mess4 = "Increases Roy's Damage"
    },
    [200040018] = {
        mess1 = "Damage against Roy increases",
        mess2 = "Human Killer",
        mess3 = "Arts Gauge  Speed UP",
        mess4 = "Increases Roy's Damage"
    },

    --試練の回廊　オグナード
    [2000638] = {
        mess1 = "Heheh...",
        mess2 = "It's time that I show you the results of my research.",
        mess3 = "You continue to amuse me.",
        mess4 = "I shall completely take you in!",
        mess5 = "Dark Elemental Resistance",
        mess6 = "Burn Resistance",
        mess7 = "Paralyze Resistance",
        mess8 = "Freeze Resistance"
    },

    --ラグシェルムファントム
    [2000645] = {
        mess1 = "Damage towards Target UP",
        mess2 = "True Nightmare Stance",
        mess3 = "Sureshot"
    },

    [200070036] = {
        mess1 = "Damage towards Target UP",
        mess2 = "True Nightmare Stance"
    },

    [200070069] = {
        mess1 = "Damage towards Target UP"
    },

    [200070073] = {
        mess1 = "Damage towards Target UP",
        mess2 = "True Nightmare Stance"
    },

    [200070075] = {
        mess1 = "Damage towards Target UP",
        mess2 = "True Nightmare Stance"
    },

    [49201] = {
        mess1 = "Damage towards Target UP",
        mess2 = "True Nightmare Stance",
        mess3 = "Sure Shot",
        mess4 = "Reduce DMG",
        mess5 = "Clear Reduced DMG"
    },

    --試練の回廊の被験体
    [2000646] = {
        mess1 = "Human Killer",
        mess2 = "Gods Killer",
        mess3 = "Negates Status Ailment",
        mess4 = "DMG UP",
        mess5 = "Reduces DMG",
        mess6 = "Attack Speed UP"
    },

    --試練の回廊　ゴル猫ゴッド
    [2000648] = {
        mess1 = "Cat-cha later♪"
    },

    --ギリアム
    [200080019] = {
        mess1 = "Equipment Takes 3x Damage",
        mess2 = "Attack Speed UP",
        mess3 = "Activated Item for Giliam",
        mess4 = "Arts Damage"
    },

    [200080020] = {
        mess1 = "Equipment Takes 3x Damage",
        mess2 = "Attack Speed UP",
        mess3 = "Activated Item for Giliam",
        mess4 = "Arts Damage"
    },

    [200080024] = {
        mess1 = "Equipment Takes 3x Damage",
        mess2 = "Attack Speed UP",
        mess3 = "Activated Item for Giliam",
        mess4 = "Arts Damage"
    },

    [200080028] = {
        mess1 = "Equipment Takes 3x Damage",
        mess2 = "Attack Speed UP",
        mess3 = "Activated Item for Giliam",
        mess4 = "Arts Damage"
    },
    [200080902] = {
        DEAD_MESSAGE1 = "Huh? Did the battery die?",
        HP30_MESSAGE1 = "Override all limits! Full power!",
        HP30_MESSAGE2 = "DEF & Arts gauge filling speed UP",
        HP30_TEAM_MESSAGE1 = "SX-602 Limited Power-up",
        HP60_MESSAGE1 = "No problems so far. Moving to Phase 2.",
        HP60_MESSAGE2 = "DMG UP",
        HP60_TEAM_MESSAGE1 = "SX-602 Limited Power-up",
        START_MESSAGE1 = "Let me wake up first, OK?",
        START_MESSAGE2 = "Reflection, Arts gauge DOWN & CRI resistance",
        START_MESSAGE3 = "Model SX-602：Negates Arts DMG & Human Killer"
    },
    [200080903] = {
        DEAD_MESSAGE1 = "A perfect...shine!",
        HP20_MESSAGE1 = "My soul goes into every blow!",
        HP20_MESSAGE2 = "ATK speed & Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Put some oomph into it!",
        HP50_MESSAGE2 = "DMG taken DOWN & Arts gauge filling speed UP",
        START_MESSAGE1 = "Strike while the iron is hot!",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE3 = "Shield Killer"
    },
    [200080904] = {
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG Negation canceled",
        START_MESSAGE3 = "DMG taken UP during Burning & Disease",
        START_MESSAGE4 = "Targets the unit inflicts highest DMG",
        START_MESSAGE5 = "CRI rate UP to a target",
        SKILL1_MESSAGE1 = "Faints a target",
        SKILL2_MESSAGE1 = "Target's Equip CT speed DOWN",
        HP80_MESSAGE1 = "What, afraid of a little bruising?!",
        HP80_MESSAGE2 = "Physical resistance UP",
        HP60_MESSAGE1 = "Come at me full force!",
        HP60_MESSAGE2 = "CRI resistance UP",
        HP40_MESSAGE1 = "You gotta strike harder than that!",
        HP40_MESSAGE2 = "Physical resistance UP",
        HP20_MESSAGE1 = "Now it's my turn!",
        HP20_MESSAGE2 = "Arts gauge filling speed UP",
        DEAD_MESSAGE1 = "Solid work there."
    },

    [200110089] = {
        RAGE_MESSAGE1 = "Earth DMG UP",
        RAGE_MESSAGE2 = "Water DMG UP",
        RAGE_MESSAGE3 = "Fire DMG UP",
        RAGE_MESSAGE4 = "DMG to enemy UP",
        RAGE_MESSAGE5 = "CRI rate UP",
        RAGE_MESSAGE6 = "Negating attack CANCELED",
        RAGE_MESSAGE7 = "Accuracy rate UP",
        RAGE_MESSAGE8 = "Status Ailment Attack"
    },

    --ゼイオルグ
    [200140036] = {
        mess1 = "Reduces Damage Taken by 50%",
        mess2 = "Damage 50% UP & Attack Speed UP",
        mess3 = "Last Stand"
    },

    [200140073] = {
        mess1 = "Reduces Damage Taken by 50%",
        mess2 = "Damage 50% UP & Attack Speed UP",
        mess3 = "Last Stand"
    },

    [200140076] = {
        mess1 = "Reduces Damage Taken by 50%",
        mess2 = "Damage 50% UP & Attack Speed UP",
        mess3 = "Last Stand"
    },

    --闇ドラ
    [200140083] = {
        mess1 = "Remnants of Relic「End Times Ring」",
        mess2 = "Gods Killer",
        mess3 = "Remnants of Relic「Volkans」",
        mess4 = "Attack Speed UP during Burning",
        mess5 = "Remnants of Relic「Force Keratos」",
        mess6 = "Status Ailment Resistance",
        mess7 = "Remnants of Magic Armor「Geshpenst」",
        mess8 = "Critical against Target",
        mess9 = "Light Elemental Resistance DOWN",
        mess10 = "Remanants of Treasure Sword「Lyude Magus」",
        mess11 = "Inflicts Faint",
        mess12 = "Clear Attack Speed UP",
        mess13 = "Remnants of Relic「White Holy Wings」",
        mess14 = "Reduces Damage taken on Equipment & Arts",
        mess15 = "Slaying dragons is an honor for us warriors! Let's go!",
        mess16 = "Zeorg Extreme Enhancement",
        mess17 = "Reduces MAX HP",
        mess18 = "Rage Status: Break Power UP",
        mess19 = "Clear Angry Status"
    },

    [200140093] = {
        mess1 = "Rage Status: Break Power UP",
        mess2 = "Clear Angry Status",
        mess3 = "Gods Killer",
        mess4 = "Faint Evasion Rate DOWN"
    },

    [500110040] = {
        mess1 = "Rage Status: Break Power UP",
        mess2 = "Clear Angry Status",
        mess3 = "Gods Killer",
        mess4 = "Faint Evasion Rate DOWN"
    },

    [500110020] = {
        mess1 = "Rage Status: Break Power UP",
        mess2 = "Clear Angry Status",
        mess3 = "Gods Killer",
        mess4 = "Faint Evasion Rate DOWN"
    },

    [500110000] = {
        mess1 = "Rage Status: Break Power UP",
        mess2 = "Clear Angry Status",
        mess3 = "Gods Killer",
        mess4 = "Faint Evasion Rate DOWN"
    },


    --フェン
    [200210037] = {
        mess1="Ice Magic Sword \"Almas\"",
        mess2="Drakkeus Bolt",
        mess3="Underking Spear \"Hellfire\"",
        mess4="Demonsickle Evilscythe",
        mess5="Conquering Dragon Sword \"Gelmed\"",
        mess6="Relic \"Force Keratos\"",
        mess7="Heals Status Ailments",
        mess8="Sacred Crown \"Raaz\" EX",
        mess9="Status Ailments Resistance UP",
        mess10="Ru「I won't let you!!!」",
        mess11="Cruze's Pocket Watch EX",
        mess12="Enemy's Skill CT UP",
        mess13="Monster Summon Stone EX",
        mess14="Inflict Paralyze & HP Auto-recovery",
        mess15="God Flicker Bow Kyuknoth",
        talk1="Rayas「I'm going all in, Fen!」",
        talk2="Fen「Hmph, as if you'd stand a chance.」",
        talk3="Rayas「I'll show you my power!」"
    },
    [200210075] = {
        mess1="Ice Magic Sword \"Almas\"",
        mess2="Drakkeus Bolt",
        mess3="Underking Spear \"Hellfire\"",
        mess4="Demonsickle Evilscythe",
        mess5="Conquering Dragon Sword \"Gelmed\"",
        mess6="Relic \"Force Keratos\"",
        mess7="Heals Status Ailments",
        mess8="Sacred Crown \"Raaz\" EX",
        mess9="Status Ailments Resistance UP",
        mess10="Ru「I won't let you!!!」",
        mess11="Cruze's Pocket Watch EX",
        mess12="Enemy's Skill CT UP",
        mess13="Monster Summon Stone EX",
        mess14="Inflict Paralyze & HP Auto-recovery",
        mess15="God Flicker Bow Kyuknoth",
        talk1="Rayas「I'm going all in, Fen!」",
        talk2="Fen「Hmph, as if you'd stand a chance.」",
        talk3="Rayas「I'll show you my power!」"
    },
    [200210080] = {
        mess1="Ice Magic Sword \"Almas\"",
        mess2="Drakkeus Bolt",
        mess3="Underking Spear \"Hellfire\"",
        mess4="Demonsickle Evilscythe",
        mess5="Conquering Dragon Sword \"Gelmed\"",
        mess6="Relic \"Force Keratos\"",
        mess7="Heals Status Ailments",
        mess8="Sacred Crown \"Raaz\" EX",
        mess9="Status Ailments Resistance UP",
        mess10="Ru「I won't let you!!!」",
        mess11="Cruze's Pocket Watch EX",
        mess12="Enemy's Skill CT UP",
        mess13="Monster Summon Stone EX",
        mess14="Inflict Paralyze & HP Auto-recovery",
        mess15="God Flicker Bow Kyuknoth",
        talk1="Rayas「I'm going all in, Fen!」",
        talk2="Fen「Hmph, as if you'd stand a chance.」",
        talk3="Rayas「I'll show you my power!」"
    },

    --ニーア
    [200260022] = {
        mess1 = "Negates Critical",
        mess2 = "Light Elemental Resistance -50%",
        mess3 = "Attack Speed UP",
        mess4 = "Poison & Sick Attack",
        mess5 = "Arts Gauge Absorb Attack",
        mess6 = "Magic Resistance -50%"
    },

    [200260023] = {
        mess1 = "Negates Critical",
        mess2 = "Light Elemental Resistance -50%",
        mess3 = "Attack Speed UP",
        mess4 = "Poison & Sick Attack",
        mess5 = "Arts Gauge Absorb Attack",
        mess6 = "Magic Resistance -50%"
    },

    [200260024] = {
        mess1 = "Negates Critical",
        mess2 = "Light Elemental Resistance -50%",
        mess3 = "Attack Speed UP",
        mess4 = "Poison & Sick Attack",
        mess5 = "Arts Gauge Absorb Attack",
        mess6 = "Magic Resistance -50%"
    },

    [200260029] = {
        mess1 = "Negates Critical",
        mess2 = "Light Elemental Resistance -50%",
        mess3 = "Attack Speed UP",
        mess4 = "Poison & Sick Attack",
        mess5 = "Arts Gauge Absorb Attack",
        mess6 = "Magic Resistance -50%"
    },

    --エスト
    [200280037] = {
        mess1 = "Critical Rate 100%",
        mess2 = "Movement Speed UP",
        mess3 = "Arts Gauge regen",
        mess4 = "Movement Speed UP",
        mess5 = "50% less Damage"
    },

    [200280080] = {
        mess1 = "Reduces Damage taken from Gods"
    },

    [200310008] = {
        mess1 = "Charge Speed UP",
        mess2 = "Damage x3 during Freezing"
    },
    [200310012] = {
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        SKILL1_MESSAGE1 = "Party DMG taken UP",
        SKILL3_MESSAGE1 = "Party ATK DOWN",
        CHARGE_MESSAGE1 = "Charge mode: Canceled by Paralysis, Freeze, & Break",
        PARALYZE_MESSAGE1 = "Paralysis! Charge mode canceled!",
        PARALYZE_MESSAGE2 = "Edram's Paralysis resistance UP",
        FREEZE_MESSAGE1 = "Freeze! Charge mode canceled!",
        FREEZE_MESSAGE2 = "Edram's Freeze resistance UP",
        BREAK_MESSAGE1 = "Break! Charge mode canceled!",
        HP60_MESSAGE1 = "Charge time reduction",
        HP30_MESSAGE1 = "Charge time reduction & CRI resistance UP"
    },

    --モルドーラ
    [200320013] = {
        mess1 = "Rage Status"
    },

    [200320028] = {
        mess1 = "Rage Status"
    },

    [200320033] = {
        mess1 = "Rage Status"
    },

    [200320039] = {
        mess1 = "Rage Status"
    },

    [200320045] = {
        mess1 = "Rage Status"
    },

    --パルラミシア
    [49501] = {
        mess1 = "Earth Elemental Resistance -40%",
        mess2 = "Protective Water Stance",
        mess3 = "Heavenly Water Stance",
        mess4 = "HP regen",
        mess5 = "HP regen amount UP"
    },


    [500200000] = {
        mess1 = "Earth Elemental Resistance -40%",
        mess2 = "Protective Water Stance",
        mess3 = "Heavenly Water Stance",
        mess4 = "HP regen",
        mess5 = "HP regen amount UP"
    },

    [500200020] = {
        mess1 = "Earth Elemental Resistance -40%",
        mess2 = "Protective Water Stance",
        mess3 = "Heavenly Water Stance",
        mess4 = "HP regen",
        mess5 = "HP regen amount UP"
    },

    [500200041] = {
        mess1 = "Earth Elemental Resistance -40%",
        mess2 = "Protective Water Stance",
        mess3 = "Heavenly Water Stance",
        mess4 = "HP regen",
        mess5 = "HP regen amount UP"
    },

    --ロイ
    [500342865] = {
        mess1 = "Lightning Fast: Movement Speed UP",
        mess2 = "Lightning Fast: Arts Gauge Increase Speed UP",
        mess3 = "Blue Dragon Sword「Alternative」Stance"
    },

    [500342885] = {
        mess1 = "Clear Impregnable Status",
        mess2 = "Wolf Stance: Movement Speed UP",
        mess3 = "Wolf Stance: DMG to enemy 50% UP!",
        mess4 = "Lightning Fast: Movement Speed UP",
        mess5 = "Lightning Fast: Arts Gauge Increase Speed UP",
        mess6 = "Impregnable: Significant decrease of Damage inflicted",
        mess7 = "Impregnable: Break Resistance DOWN",
        mess8 = "Blue Dragon Sword「Alternative」Stance"
    },

    [500342895] = {
        mess1 = "Clear Impregnable Status",
        mess2 = "Wolf Stance: Movement Speed UP",
        mess3 = "Wolf Stance: DMG to enemy 50% UP!",
        mess4 = "Lightning Fast: Movement Speed UP",
        mess5 = "Lightning Fast: Arts Gauge Increase Speed UP",
        mess6 = "Impregnable: Significant decrease of Damage inflicted",
        mess7 = "Impregnable: Break Resistance DOWN",
        mess8 = "Blue Dragon Sword「Alternative」Stance"
    },

    [2000626] = {
        mess1 = "Clear Impregnable Status",
        mess2 = "Wolf Stance: Movement Speed UP",
        mess3 = "Wolf Stance: DMG to enemy 50% UP!",
        mess4 = "Lightning Fast: Movement Speed UP",
        mess5 = "Lightning Fast: Arts Gauge Increase Speed UP",
        mess6 = "Impregnable: Significant decrease of Damage inflicted",
        mess7 = "Impregnable: Break Resistance DOWN",
        mess8 = "Blue Dragon Sword「Alternative」Stance"
    },

    -- 試練の回廊 ２０階/霹翠トニトゥルス
    [2000659] = {
        START_MESSAGE1 = "Light Killer",
        START_MESSAGE2 = "Negates Light DMG",
        START_MESSAGE3 = "Negates Status Ailments",
        START_MESSAGE4 = "Negates Critical",
        BUFF_MESSAGE1 = "DMG UP",
        BUFF_MESSAGE2 = "Attack Speed UP",
    },

    -- 試練の回廊 ２０階/猛餓獣樹ゴロンドーラ
    [2000660] = {
        START_MESSAGE1 = "Dark Killer",
        START_MESSAGE2 = "Negates Dark DMG",
        START_MESSAGE3 = "Negates Status Ailments",
        START_MESSAGE4 = "Negates Critical",
        BUFF_MESSAGE1 = "Lifesteal amount UP",
        BUFF_MESSAGE2 = "Attack Speed UP",
    },

    -- 試練の回廊 23階/冥蟲姫ラドアクネ
    [2000666] = {
        SKILL_MESSAGE1 = "Oh, Creature of Darkness... Ah... Destruction...",
        SKILL_MESSAGE2 = "The living shall die, the dead shall go on...",
        SKILL_MESSAGE3 = "Like a candle flickering in the wind...",
        SUMMON_MESSAGE1 = "Oh, my darlings... I love you so...",
        START_MESSAGE1 = "Beast & Human Killer",
        START_MESSAGE2 = "Critical Resistance",
        START_MESSAGE3 = "HP Auto-recovery",
        RAGE_MESSAGE1 = "DMG UP",
        RAGE_MESSAGE2 = "Movement Speed UP",
        RAGE_MESSAGE3 = "Negates Hit Stop",
        RAGE_MESSAGE4 = "Break Resistance DOWN"
    },

    [2000682] = {
        START_MESSAGE = "Negates DMG: Reduces HP with Break DMG",
        BUFF_MESSAGE1 = "Come to me, radiant light...",
        BUFF_MESSAGE2 = "ATK & Accuracy UP",
        BUFF_MESSAGE3 = "I must become brighter...",
        BUFF_MESSAGE4 = "Break Res & DMG UP",
        BUFF_MESSAGE5 = "Be purged in the light.",
        BUFF_MESSAGE6 = "Arts gauge fills at double speed",
        BREAK_MESSAGE1 = "HP reduction amount doubles during Break",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },

    [2000683] = {
        START_MESSAGE1 = "Shield Killer",
        START_MESSAGE2 = "Arts activated during DEF penetrating ATK",
        START_MESSAGE3 = "Arts activated during CRI ATK",
        START_MESSAGE4 = "Each activation Endless' force UP",
        HP15_MESSAGE = "Return to eternal shadows.",
        HP30_MESSAGE = "A brief advantage falls to true might.",
        OGI_HA_MESSAGE1 = "The void punishes elusive blades.",
        OGI_KYOKU_MESSAGE1 = "Divine power ever refines itself."
    },

    --闇ドラ覚醒級
    [500110063] = {
        mess1 = "Remnants of Relic \"End Times Ring\"",
        mess2 = "Gods Killer",
        mess3 = "Remnants of Relic \"Volkans\"",
        mess4 = "ATK Speed UP while Burning",
        mess5 = "Remnants of Relic \"Force Keratos\"",
        mess6 = "Altered State Resistance",
        mess7 = "Remnants of Magic Sword \"Geshpenst\"",
        mess8 = "Critical DMG towards Target",
        mess9 = "Light Elemental Resistance DOWN",
        mess10 = "Remnants of Treasure Blade \"Ryude Magus\"",
        mess11 = "Adds Faint Effect",
        mess12 = "Clear ATK Speed UP",
        mess13 = "Remnants of Holy Shield of Wings",
        mess14 = "Reduce Equipment/Arts DMG",
        mess15 = "Defeating a dragon is a warrior's honor! Here I go!",
        mess16 = "All Elemental Resistance (except Light)",
        mess17 = "MAX HP DOWN",
        mess18 = "Rage mode：Break Power UP",
        mess19 = "Clear Rage mode"
    },

    --ラグ外伝ヴァルザン
    [604037] = {
        mess1 = "Arts gauge regeneration"
    },

    --銀ヴァル
    [600000002] = {
        mess1 = "Shadow Lightning Stance V",
        mess2 = "Damage Resistance DOWN",
        mess3 = "Fallen Cells Reactivated",
        mess4 = "Boss has targeted you!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Targeted by Boss!",
        telop4 = "Boss has powered up!",
        telop5 = "When your unit falls, replace them and fight!",
        telop6 = "Rewards will vary according to your ranking."
    },

    --レグルスフィーナイベ　フィーナ
    [200370046] = {
        mess1 = "Arts gauge increase UP",
        mess2 = "Damage Inflicted UP"
    },

    --レグルスフィーナイベ　レグルス
    [200370043] = {
        mess1 = "Arts gauge increase UP",
        mess2 = "Damage Inflicted UP"
    },

    --大型イベント用メリア
    [200380033] = {
        mess1 = "Auto-barrier",
        mess2 = "Arts Gauge Increase Speed UP"
    },
    [200380039] = {
        mess1 = "Auto-barrier",
        mess2 = "Arts Gauge Increase Speed UP"
    },
    [200380047] = {
        mess1 = "Auto-barrier",
        mess2 = "Arts Gauge Increase Speed UP"
    },

    [200430034] = {
        ITEM1 = "Coercion of the Guardian",
        ITEM2 = "Blue Dragon Blade",
        ITEM3 = "Wrath of the Guardian",
        SUMMON1 = "I never expected one to arrive here...",
        SUMMON2 = "It is my duty to protect this place...",
        SUMMON3 = "What is it that you seek...?",
        SUMMON4 = "Just how...committed are you?!"
    },
    [2004336] = {
        START_MESSAGE1 = "Please show me what you can do.",
        START_MESSAGE2 = "Break resistance UP (Except when Burning)",
        FINISH_MESSAGE1 = "Play time is over."
    },
    [2004433] = {
        START_MESSAGE1 = "Show me what you've got.",
        START_MESSAGE2 = "Break resistance UP (Except when Frozen)",
        START_MESSAGE3 = "CRI resistance",
        FINISH_MESSAGE1 = "Let's get serious!"
    },
    [200440031] = {
        ITEM1 = "Coercion of the Guardian",
        ITEM2 = "Green Dragon Blade",
        ITEM3 = "Wrath of the Guardian",
        SUMMON1 = "You who threaten this land...",
        SUMMON2 = "Leave here at once...",
        SUMMON3 = "Your arrogance will one day destroy you...",
        SUMMON4 = "You cannot withstand the powers of the Earth!"
    },
    [200450031] = {
        ITEM1 = "Coercion of the Guardian",
        ITEM2 = "Blaze Dragon Blade",
        ITEM3 = "Wrath of the Guardian",
        SUMMON1 = "Hmm... It’s been a while since I had a visitor...",
        SUMMON2 = "So you wish to be reduced to ashes, too...",
        SUMMON3 = "You do not yet know true fear...",
        SUMMON4 = "Very well, be reduced to ashes!"
    },
    [2004533] = {
        START_MESSAGE1 = "Show me what you've got.",
        START_MESSAGE2 = "Break resistance UP (Except when Poisoned)",
        START_MESSAGE3 = "CRI resistance",
        FINISH_MESSAGE1 = "Let's rock'n roll."
    },
    [2005432] = {
        ITEM1 = "Guardian's Coercion",
        ITEM2 = "Shadow Dragon Blade",
        ITEM3 = "Imperial Wrath",
        SUMMON1 = "Are you... the one... challenging me...?",
        SUMMON2 = "Are... you the one... who wanders the shadows...?",
        SUMMON3 = "Should you... be the one... to recive... the power of Light...?",
        SUMMON4 = "SHOW ME YOUR STRENGTH!"
    },
    [2005053] = {
        START_MESSAGE1 = "Negates HitStop & Arts gauge DOWN",
        START_MESSAGE2 = " Negates DEF penetration & Reflection",
        HP50_MESSAGE1 = " DMG taken resistance UP",
        HP50_MESSAGE2 = " Earth Units' Physical DMG UP"
    },
    [2005532] = {
        ITEM1 = "Guardian's Coercion",
        ITEM2 = "Luminous Dragon Blade",
        ITEM3 = "Imperial Wrath",
        SUMMON1 = "Do you... wish for... power...?",
        SUMMON2 = "Let me measure your values...",
        SUMMON3 = "What sleeps here... is beyond human strength...",
        SUMMON4 = "Prove that you are worthy enough to possess this relic!"
    },

    [2005536] = {
        START_MESSAGE = "Negate DMG except Blinded state",
        START_MESSAGE2 = "CRI resistance",
        BUFF_MESSAGE1 = "CRI rate UP",
        BUFF_MESSAGE2 = "CRI DMG UP",
        BUFF_MESSAGE3 = "Arts gauge fills at double speed",
        BUFF_MESSAGE3_2 = "CRI rate UP",
        BUFF_MESSAGE3_3 = "CRI DMG UP"
    },

    [2005439] = {
        START_MESSAGE1 = "The miasma fills the area",
        START_MESSAGE2 = "Reflection, Arts gauge DOWN & Physical RES.",
        HOLD_MESSAGE1 = "Holds a unit with the lowest HP",
        HP50_MESSAGE1 = "DMG & Arts gauge filling speed UP",
        HP25_MESSAGE1 = "ATK, DEF & Arts gauge filling speed UP"
    },
    [2005540] = {
        START_MESSAGE1 = "The miasma fills the area",
        START_MESSAGE2 = "Arts gauge DOWN RES. & Human Killer",
        START_MESSAGE3 = "DMG taken UP for Every Break",
        BREAK_MESSAGE1 = "Breaking! DMG taken UP!",
        BREAK_END_MESSAGE1 = "Break resistance UP",
        HP30_MESSAGE1 = "Feel the stars' wrath...",
        HP30_MESSAGE2 = "CRI rate & Arts gauge filling speed UP"
    },
    [2005541] = {
        AVOID_MESSAGE1 = "DEF UP Canceled",
        AVOID_MESSAGE2 = "Evasion rate UP",
        DEFENCE_MESSAGE1 = "Evasion rate UP Canceled",
        DEFENCE_MESSAGE2 = "DEF UP",
        HP20_MESSAGE1 = "DEF UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Negates CRI DMG",
        START_MESSAGE3 = "DEF UP",
        WIND_MESSAGE1 = "Storm Status: DMG UP every 20s"
    },

    [2005441] = {
        HP20_MESSAGE1 = "*pant pant* I have no other choice...",
        HP20_MESSAGE2 = "DMG, Evasion rate, & Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Not bad! But can you handle this?",
        HP50_MESSAGE2 = "Evasion rate & Faint resistance UP",
        SKILL_MESSAGE1 = "Recovery rate DOWN",
        SKILL_MESSAGE2 = "Death Messiah: Cancels DMG Negation",
        START_MESSAGE1 = "I'll be your playmate!",
        START_MESSAGE2 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        mess3 = "Cancels Attack speed UP"
    },
    [2005442] = {
        DEAD_MESSAGE1 = "This has to be a lie..",
        HP0_MESSAGE1 = "I don't care anymore. I'll crush everything.",
        HP0_MESSAGE2 = "Physical resistance UP",
        HP0_MESSAGE3 = "Magic resistance UP",
        HP0_MESSAGE4 = "CRI resistance & Arts gauge filling speed UP",
        HP30_MESSAGE1 = "Ahahaha! Dieeeeee!",
        HP30_MESSAGE2 = "DMG & DEF UP",
        HP50_MESSAGE1 = "Nothing can beat me!",
        HP50_MESSAGE2 = "DMG & CRI resistance UP",
        SKILL_MESSAGE1 = "Vital Extraction: Arts gauge DOWN",
        SKILL_MESSAGE2 = "Canceles DMG Negation",
        SKILL_MESSAGE3 = "Faints target & Arts gauge DOWN",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Targets the unit inflicts highest DMG",
        START_MESSAGE3 = "CRI rate UP after being targeted",
        START_MESSAGE4 = "Stacks DMG",
        RESULT_MESSAGE1 = "Total",
        RESULT_MESSAGE2 = " DMG!",
        DAMAGE_MESSAGE1 = " %d0000",
        DAMAGE_MESSAGE2 = " %d",
        DAMAGE_MESSAGE3 = " DMG!",
        DAMAGE_MESSAGE4 = " Single-hit:",
        DAMAGE_MESSAGE5 = " DMG!",
        DAMAGE_MESSAGE6 = " Physical",
        DAMAGE_MESSAGE7 = " Magic"
    },
    [2005443] = {
        SKILL_MESSAGE1 = "Party's Arts gauge filling speed UP",
        SKILL_MESSAGE2 = "Party's Status ailment resistance DOWN",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG taken UP during Status Ailment"
    },
    [2005444] = {
        SKILL_MESSAGE1 = "Locks ",
        SKILL_MESSAGE2 = "’s lock",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "CRI rate UP to Blinded enemy"
    },
    [2005542] = {
        HP30_MESSAGE1 = "Been a while since I went all out!",
        HP30_MESSAGE2 = "Evasion rate UP",
        HP50_MESSAGE1 = "Can you cross swords with me?",
        HP50_MESSAGE2 = "CRI resistance UP",
        SKILL2_1_MESSAGE1 = "DMG & Arts gauge filling speed UP",
        SKILL2_2_MESSAGE1 = "DMG UP",
        START_MESSAGE1 = "A fair and square match, eh?",
        START_MESSAGE2 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Canceles DMG Negation ",
        START_MESSAGE4 = "Elsa: CRI resistance",
        START_MESSAGE5 = "Leader: DMG resistance (except Skill DMG)",
        START_MESSAGE6 = "More helpers increases Boss DMG resistance",
        SUMMON1_MESSAGE1 = "Leader joined",
        SUMMON1_MESSAGE2 = "Elsa: CRI resistance",
        SUMMON2_MESSAGE1 = "Leader joined",
        SUMMON2_MESSAGE2 = "Leader: DMG resistance (except Skill DMG)"
    },
    [2005545] = {
        HP100_MESSAGE1 = "CRI DMG resistance UP",
        HP20_MESSAGE1 = "Cancels DMG Negation",
        HP20_MESSAGE2 = "DEF, CRI DMG resistance, & Arts gauge filling speed UP",
        HP50_MESSAGE1 = "DMG, CRI, & CRI DMG resistance UP",
        HP70_MESSAGE1 = "CRI & CRI DMG resistance UP",
        SKILL2_MESSAGE1 = "Target's Accuracy DOWN",
        SKILL2_MESSAGE2 = "Recovery rate DOWN",
        SKILL4_MESSAGE1 = "Space and time are at my beck and call!",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Targets the unit inflicts highest DMG",
        START_MESSAGE3 = "CRI rate to target UP",
        START_MESSAGE4 = "The higher unit's HP, the more DMG dealt"
    },
    [2005546] = {
        HP20_MESSAGE1 = "Evasion rate & CRI DMG UP",
        HP50_MESSAGE1 = "Evasion rate UP",
        HP80_MESSAGE1 = "Evasion rate UP",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "CRI rate UP to Pralyzed enemy"
    },
    [2005547] = {
        HP0_MESSAGE1 = "HP auto-recovery",
        HP0_MESSAGE2 = "Impregnable canceled by Break",
        HP0_MESSAGE3 = "Arts gauge filling speed UP",
        HP20_MESSAGE1 = "CRI rate & Arts gauge filling speed UP",
        HP50_MESSAGE1 = "CRI rate UP",
        HP80_MESSAGE1 = "CRI rate UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG taken UP during Disease"
    },

    [2005645] = {
        mess1 = "Demon Killer",
        mess2 = "Break resistance",
        mess3 = "Negates CRI",
        mess4 = "Guess I better get serious!",
        mess5 = "Fen: Why did you wait until now?!",
        mess6 = "Transforming into a Giant Machine form"
    },

    [2005954] = {
        GRAB_MESSAGE1 = "Holding high HP unit",
        HP30_MESSAGE1 = "Ailment recovery, DMG, DEF & Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection, Arts gauge Down & Earth resistance",
        START_MESSAGE2 = "DMG Negation Canceled",
        START_MESSAGE3 = "BE output UP when Burning.",
        START_MESSAGE4 = "ATK DOWN when poisoned"
    },

    [2005957] = {
        START_MESSAGE1 = "Sure, I'll play with you." ,
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES." ,
        START_MESSAGE3 = "Equipment DMG taken DOWN, Human Killer" ,
        HP70_MESSAGE1 = "You're more skilled than I expected." ,
        HP70_MESSAGE2 = "Reverses Status UP effects" ,
        HP40_MESSAGE1 = "Play with my darling puppets." ,
        HP40_MESSAGE2 = "Reverses Status UP effects" ,
        HP10_MESSAGE1 = "I want to see you au naturel." ,
        HP10_MESSAGE2 = "Reverses Status UP effects" ,
        DEAD_MESSAGE1 = "I hate you, I hate you, I hate you!" ,
    },
    [2005990] = {
        START_MESSAGE1 = "Super-recovery" ,
        START_MESSAGE2 = "KILL la KILL units' DMG UP"
    },
    [2005995] = {
        BUFF93_MESSAGE_MESSAGE1 = "Evasion rate DOWN",
        BUFF93_MESSAGE_MESSAGE2 = "Evasion rate UP",
        DEAD_MESSAGE1 = "Gaaaaaah!",
        EXGAGEBROKEN_MESSAGE_MESSAGE1 = "Charging mode canceled!",
        EXGAGESKILL_MESSAGE_MESSAGE1 = "Fall with the Blade Regalia's exposure!: DMG Negation canceled!",
        EXGAGESTART_MESSAGE_MESSAGE1 = "This'll finish you.",
        EXGAGESTART_MESSAGE_MESSAGE2 = "Uzu is charging: DMG taken DOWN & Arts gauge filling speed UP",
        EXGAGESTART_MESSAGE_MESSAGE3 = "Canceled with enough DMG",
        HP0_MESSAGE1 = "Shingantsu: Evasion rate UP",
        HP50_MESSAGE1 = "Huh, you got skills.",
        HP50_MESSAGE2 = "Shingantsu: Evasion rate UP",
        HP50_MESSAGE3 = "Arts gauge filling speed UP",
        HP50_MESSAGE4 = "Blind resistance UP",
        HP80_MESSAGE1 = "I can read you like a book!",
        HP80_MESSAGE2 = "Shingantsu: Evasion rate UP",
        HP80_MESSAGE3 = "Arts gauge filling speed UP",
        HP80_MESSAGE4 = "Blind resistance UP",
        START_MESSAGE1 = "I'll pierce my way through anything!",
        START_MESSAGE2 = "Reflection, Lifesteal, Arts gauge DOWN, & Physical RES.",
        START_MESSAGE3 = "DMG from Human units UP",
        START_MESSAGE4 = "Evasion rate DOWN during Blind"
    },

    [2005975] = {
        BREAK_MESSAGE1 = "ATK & DEF UP Canceled!",
        BREAK_MESSAGE2 = "CRI resistance UP Canceled!",
        BREAK_MESSAGE3 = "DMG taken DOWN (except from Human units) Canceled!",
        DEAD_MESSAGE1 = "What...?",
        HP0_MESSAGE1 = "For I know that my actions are utterly pure!",
        HP100_MESSAGE1 = "Boss' Buffs Canceled by Break",
        HP100_MESSAGE2 = "Can you withstand the blood purge?",
        HP50_MESSAGE1 = "Victory is ours.",
        START_MESSAGE1 = "Reflection resistance, ATK UP, & DEF UP",
        START_MESSAGE2 = "CRI resistance UP",
        START_MESSAGE3 = "DMG taken DOWN (Except from Human units)",
    },

    [200460032] = {
        mess1 = "Negates Critical Damage",
        mess2 = "Arts Gauge Increase Speed UP"
    },
    [200460043] = {
        mess1 = "Lapleh：Negates Critical Damage",
        mess2 = "Arts Gauge Increase Speed UP"
    },
    [200460038] = {
        mess1 = "All Status UP",
        mess2 = "Arts Gauge Increase Speed UP"
    },
    [200460046] = {
        mess1 = "All Status UP",
        mess2 = "Arts Gauge Increase Speed UP"
    },

    [200510048] = {
        mess1 = "All Status UP",
        mess2 = "Arts gauge increase speed UP"
    },
    [200510045] = {
        mess1 = "CRI rate %d％",
        mess2 = "Arts gauge increase speed UP"
    },

    [2005339] = {
        mess1 = "Dark Resistance５０％"
    },
    [2005344] = {
        mess1 = "Dark Resistance８０％"
    },

    --回廊ギリアム
    [1001510] = {
        mess1 = "Equipment Takes 3x Damage"
    },

    [200100007] = {
        mess1 = "Damage towards Target UP",
        mess2 = "True Nightmare Stance",
        mess3 = "Sureshot"
    },

    [200210086] = {
        mess1 = "Ice Magic Sword \"Almas\"",
        mess2 = "Drakkeus Bolt",
        mess3 = "Underking Spear \"Hellfire\"",
        mess4 = "Demonsickle Evilscythe",
        mess5 = "Conquering Dragon Sword \"Gelmed\"",
        mess6 = "Relic「Force Keratos」",
        mess7 = "Heals Status Ailment",
        mess8 = "Sacred Crown「Raaz」EX",
        mess9 = "Status Ailment Resistance UP",
        mess10 = "Ru「I won't let you!!!」",
        mess11 = "Cruze's Pocket Watch EX",
        mess12 = "Enemy's Skill CT Speed DOWN",
        mess13 = "Monster Summon Stone EX",
        mess14 = "Inflict Paralyze & HP regenerates",
        mess15 = "Head of General Staff",
        mess16 = "The Lone Tactician",
        mess17 = "Human Killer",
        mess18 = "The Beast within",
        mess19 = "Arts gauge regeneration",
        mess20 = "Divine Glowing Arrow Cycnus",
        talk1 = "Rayas「I'm going all in, Fen!」",
        talk2 = "Fen「Hmph, as if you'd stand a chance.」",
        talk3 = "Rayas「I'll show you my powers!」"
    },
    [200490047] = {
        mess1 = "Luminous Barrier"
    },
    [2005243] = {
        mess1 = "Mirage Sword Stance"
    },
    [2005248] = {
        mess1 = "Mirage Sword Stance"
    },
    [2005249] = {
        mess1 = "Mirage Sword Stance",
        DEAD_MESSAGE = "Great skills!"
    },
    [2005250] = {
        START_MESSAGE1 = "It’s SHOWTIME!",
        START_MESSAGE2 = "Negates CRI",
        START_MESSAGE3 = "Invincible Alma",
        DEAD_MESSAGE = "Off into the wild blue yonder!"
    },

    --ロスト覚醒級
    [200570009] = {
        mess1 = "Light Resistance DOWN during Break"
    },
    --ロスト覚醒級のジェラルド
    [200570013] = {
        mess1 = "Gerald \"I will support you!\""
    },

    --神殿女神　初級
    [4000117] = {
        BARRIER_MESSAGE1 = "Wyrm's Shell: Negate certain DMG % Evasion rate UP",
        RAGE_MESSAGE1 = "DMG UP & ATK Speed UP",
        SKILL_MESSAGE = "Be covered in Light... and disappear...",
        SKILL_MESSAGE2 = "Be embraced by Darkness... and vanish..."
    },
    --神殿女神　中級
    [4000127] = {
        BARRIER_MESSAGE1 = "Wyrm's Shell: Negate certain DMG % Evasion rate UP",
        RAGE_MESSAGE1 = "DMG UP & ATK Speed UP",
        SKILL_MESSAGE = "Be covered in Light... and disappear...",
        SKILL_MESSAGE2 = "Be embraced by Darkness... and vanish..."
    },
    --神殿女神　上級
    [4000137] = {
        BARRIER_MESSAGE1 = "Wyrm's Shell: Negate certain DMG % Evasion rate UP",
        RAGE_MESSAGE1 = "DMG UP & ATK Speed UP",
        SKILL_MESSAGE = "Be covered in Light... and disappear...",
        SKILL_MESSAGE2 = "Be embraced by Darkness... and vanish..."
    },
    --神殿女神　超級
    [4000147] = {
        BARRIER_MESSAGE1 = "Wyrm's Shell: Negate certain DMG % Evasion rate UP",
        RAGE_MESSAGE1 = "DMG UP & ATK Speed UP",
        SKILL_MESSAGE = "Be covered in Light... and disappear...",
        SKILL_MESSAGE2 = "Be embraced by Darkness... and vanish..."
    },

    --紋章宮月曜リリー
    [4000213] = {
        mess1 = "Give death... to those who live...",
        mess2 = "The lights of Life... will not... disappear..."
    },
    [4000223] = {
        mess1 = "Give death... to those who live...",
        mess2 = "The lights of Life... will not... disappear..."
    },
    [4000233] = {
        mess1 = "Give death... to those who live...",
        mess2 = "The lights of Life... will not... disappear..."
    },
    [4000243] = {
        mess1 = "Give death... to those who live...",
        mess2 = "The lights of Life... will not... disappear..."
    },
    --紋章宮月曜アルシェ
    [4000214] = {
        mess1 = "Oh no... we have a problem!",
        mess2 = "To cure a bad illness, you'll need lots of healing♪"
    },
    [4000224] = {
        mess1 = "Oh no... we have a problem!",
        mess2 = "To cure a bad illness, you'll need lots of healing♪"
    },
    [4000234] = {
        mess1 = "Oh no... we have a problem!",
        mess2 = "To cure a bad illness, you'll need lots of healing♪"
    },
    [4000244] = {
        mess1 = "Oh no... we have a problem!",
        mess2 = "To cure a bad illness, you'll need lots of healing♪"
    },

    --紋章宮月曜死神
    [4000217] = {
        mess1 = "Carve... death...",
        mess2 = "Do not struggle...",
        mess3 = "Light Killer",
        mess4 = "Dark Resistance",
        mess5 = "Break Resistance"
    },
    [4000227] = {
        mess1 = "Carve... death...",
        mess2 = "Do not struggle...",
        mess3 = "Light Killer",
        mess4 = "Dark Resistance",
        mess5 = "Break Resistance"
    },
    [4000237] = {
        mess1 = "Carve... death...",
        mess2 = "Do not struggle...",
        mess3 = "Light Killer",
        mess4 = "Dark Resistance",
        mess5 = "Break Resistance"
    },
    [4000247] = {
        mess1 = "Carve... death...",
        mess2 = "Do not struggle...",
        mess3 = "Light Killer",
        mess4 = "Dark Resistance",
        mess5 = "Break Resistance"
    },


    [2004335] = {
        mess1 = "Rage mode: Continous Damage",
        mess2 = "Clear Angry Status",
        mess3 = "Damage Resistance during Freeze",
        mess4 = "Break Damage Resistance during Freeze",
        mess5 = "HP regen during Freeze",
        mess6 = "Dragonic Cocytus",
        mess7 = "Physical Resistance",
        mess8 = "DMG Invaild (Except during Burn)"
    },
    [2004432] = {
        mess1 = "DMG Invaild (Except during Freeze)"
    },
    [2004532] = {
        mess1 = "DMG Invaild (Except during Poison)"
    },

    [2006133] = {
        mess1 = "Human Killer",
        mess2 = "Demon Killer"
    },

    [2006139] = {
        mess1 = "Human Killer",
        mess2 = "Demon Killer"
    },

    [2006144] = {
        mess1 = "Human Killer",
        mess2 = "Demon Killer",
        mess3 = "You really ticked me off...!",
        mess4 = "Arts gauge fills at double speed",
        mess5 = "Apologize by dying...!"
    },

    [2006305] = {
        mess1 = "Reduce DMG",
        mess2 = "Cancel Reduce DMG",
        mess3 = "Metal Chicken: Reduce DMG (Except CRI)"
    },

    [2006309] = {
        mess1 = "Reduce DMG",
        mess2 = "Cancel Reduce DMG",
        mess3 = "Metal Chicken: Reduce DMG (Except CRI)"
    },

    --紋章植物
    [4000317] = {
        mess1 = "Guys! Go get them!",
        mess2 = "You're doing better than I thought!",
        mess3 = "Arrrgh! Come on! You guys can do better!",
        mess4 = "I'm gonna eat you!",
        mess5 = "You're nothing!",
        mess6 = "DMG UP",
        mess7 = "Reduce DMG"
    },
    [4000327] = {
        mess1 = "Guys! Go get them!",
        mess2 = "You're doing better than I thought!",
        mess3 = "Arrrgh! Come on! You guys can do better!",
        mess4 = "I'm gonna eat you!",
        mess5 = "You're nothing!",
        mess6 = "DMG UP",
        mess7 = "Reduce DMG"

    },
    [4000338] = {
        mess1 = "Guys! Go get them!",
        mess2 = "You're doing better than I thought!",
        mess3 = "Arrrgh! Come on! You guys can do better!",
        mess4 = "I'm gonna eat you!",
        mess5 = "You're nothing!",
        mess6 = "DMG UP",
        mess7 = "Reduce DMG"
    },
    [4000352] = {
        mess1 = "Guys! Go get them!",
        mess2 = "You're doing better than I thought!",
        mess3 = "Arrrgh! Come on! You guys can do better!",
        mess4 = "I'm gonna eat you!",
        mess5 = "You're nothing!",
        mess6 = "DMG UP",
        mess7 = "Reduce DMG"
    },
    [2000661] = {
        START_MESSAGE1 = "Physical resistance"
    },
    [2000662] = {
        START_MESSAGE1 = "Physical resistance",
        mess1 = "DMG UP",
        mess2 = "ATK SPEED UP"
    },
    [2006531] = {
        mess1 = "Human Killer"
    },
    [2006537] = {
        mess1 = "Human Killer"
    },

    [2006543] = {
        mess1 = "Human & God Killer",
        mess2 = "Water resistance DOWN",
        mess3 = "DMG DOWN from enemy (Except during Break) ",
        mess4 = "Negates CRI attacks (Except during Break)",
        mess5 = "That's more like it!",
        mess6 = "DMG UP"
    },

    [2006731] = {
        mess1 = "Aren't you gorgeous!",
        mess2 = "DMG from Women units 20% UP"
    },
    [2006737] = {
        mess1 = "奥義ダメージ軽減",
        mess2 = "装備被ダメージアップ"
    },
    [2006744] = {
        mess1 = "ロッズ「いい女じゃねぇか！」",
        mess2 = "ロッズ：女性からのダメージ20％アップ",
        mess3 = "ロッズ：防御力ダウン",
        mess4 = "ロッズ：攻撃力ダウン"
    },
    [2006743] = {
        mess1 = "タリス：奥義ダメージ軽減",
        mess2 = "タリス：装備被ダメージアップ"
    },
    [2000688] = {
        HP30_MESSAGE1 = "Removing limiters!",
        HP30_MESSAGE2 = "Evasion rate & Arts gauge filling speed UP",
        HP60_MESSAGE1 = "The flame of resolve engulfs me.",
        HP60_MESSAGE2 = "Evasion rate & Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG Negation cancelled & Earth Killer",
        START_MESSAGE3 = "CRI rate UP to Burning enemy",
        START_MESSAGE4 = "DMG taken UP during Break"
    },
    [2000689] = {
        CHANGE_MESSAGE1 = "Come forth, eternal serpent.",
        CHANGE_MESSAGE2 = "Recovers Status Ailment",
        DEAD_MESSAGE1 = "Do not leave me...serpent...",
        EXTRA_END_MESSAGE1 = "Serpent mode canceled!",
        EXTRA_MESSAGE1 = "Serpent mode: DMG taken DOWN & Arts gauge filling speed UP",
        EXTRA_MESSAGE2 = "Serpent mode canceled with enough DMG",
        HP30_MESSAGE1 = "Perish... Perish... Perish...",
        HP30_MESSAGE2 = "DMG & Action speed UP, DMG Negation canceled",
        HP80_MESSAGE1 = "Sink into the void.",
        HP80_MESSAGE2 = "Action Speed UP",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Shield Killer & DMG from Demons DOWN",
        START_MESSAGE3 = "Recovery amount DOWN for units not in Status Ailment"
    },
    [2006905] = {
        mess1 = "God Killer",
        mess2 = "Reduce Physical DMG",
        mess3 = "Weapons are with battle...",
        mess4 = "Movement Speed UP"
    },
    [2006909] = {
        mess1 = "God Killer",
        mess2 = "Reduce Physical DMG",
        mess3 = "Weapons are with battle...",
        mess4 = "Movement Speed UP"
    },

    --マヴロスキア
    [2012430] = {
        mess1 = "RageStatus:BreakPowerUP",
        mess2 = "ClearAngryStatus",
        mess3 = "Paralyze & Faint Valid",
        mess4 = "God Killer"
    },
    --マヴロスキア
    [2012436] = {
        mess1 = "RageStatus:BreakPowerUP",
        mess2 = "ClearAngryStatus",
        mess3 = "Paralyze & Faint Valid",
        mess4 = "God Killer"
    },

    --マヴロスキア
    [2012442] = {
        mess1 = "RageStatus:BreakPowerUP",
        mess2 = "ClearAngryStatus",
        mess3 = "Paralyze & Faint Valid",
        mess4 = "God Killer"
    },

    [2013131] = {
        START_MESSAGE1 = "Action Speed UP, CRI resistance UP",
        START_MESSAGE2 = "Light & Dark resistance",
        HP40_MESSAGE1 = "Extra Action Speed UP"
    },
    [2013137] = {
        START_MESSAGE1 = "Action Speed UP, CRI resistance UP",
        START_MESSAGE2 = "Light & Dark resistance",
        HP40_MESSAGE1 = "Extra Action Speed UP"
    },
    [2013143] = {
        START_MESSAGE1 = "Action Speed UP, CRI resistance UP",
        START_MESSAGE2 = "Light & Dark resistance",
        HP40_MESSAGE1 = "Extra Action Speed UP"
    },
    [2013149] = {
        START_MESSAGE1 = "Magic DMG resistance",
        START_MESSAGE2 = "Light & Dark resistance",
        START_MESSAGE3 = "earth Killer & Accuracy UP",
        HP60_MESSAGE1 = "Magia Drive!",
        HP60_MESSAGE2 = "Action Speed UP",
        HP40_MESSAGE1 = "You're good...",
        HP20_MESSAGE1 = "Action Speed DMG UP"
    },

    [2013429] = {
        START_MESSAGE1 = "Action speed UP",
        RAGE_MESSAGES1_1 = "Negates 300000 DMG",
        RAGE_MESSAGES1_2 = "DMG UP during DMG negation",
        RAGE_MESSAGES2_1 = "ATK UP",
        RAGE_MESSAGES2_2 = "Action speed UP"
    },

    [2013431] = {
        START_MESSAGE1 = "Action speed UP",
        RAGE_MESSAGES1_1 = "Negates 300000 DMG",
        RAGE_MESSAGES1_2 = "DMG UP during DMG negation",
        RAGE_MESSAGES2_1 = "ATK UP",
        RAGE_MESSAGES2_2 = "Action speed UP"
    },

    [2013437] = {
        START_MESSAGE1 = "Action speed UP",
        RAGE_MESSAGES1_1 = "Negates 300000 DMG",
        RAGE_MESSAGES1_2 = "DMG UP during DMG negation",
        RAGE_MESSAGES2_1 = "ATK UP",
        RAGE_MESSAGES2_2 = "Action speed UP"
    },

    [2013443] = {
        START_MESSAGE1 = "Action speed UP",
        RAGE_MESSAGES1_1 = "Negates 300000 DMG",
        RAGE_MESSAGES1_2 = "DMG UP during DMG negation",
        RAGE_MESSAGES2_1 = "ATK UP",
        RAGE_MESSAGES2_2 = "Action speed UP"
    },
    [2013449] = {
        START_MESSAGE1 = "See what I can do!",
        HP70_MESSAGE1 = "Magia Drive!",
        HP70_MESSAGE2 = "Arts gauge recovery speed UP ",
        HP30_MESSAGE1 = "This is my true strength!",
        HP30_MESSAGE2 = "Action speed UP"
    },

    [2013643] = {
        SPEED_UP_MESSAGE1 = "Action speed UP",
        RAGE_MESSAGE1 = "The Titan has lost all self-control!",
        RAGE_MESSAGE2 = "Arts gauge fills at double speed"
    },

    [2013649] = {
        START_MESSAGE1 = "Entertain me, weakling.",
        HP50_MESSAGE1 = "Playtime is over!!",
        HP20_MESSAGE1 = "You'll regret crossing me..."
    },

    [2013701] = {
        START_MESSAGE1 = "DMG from enemy DOWN & Accuracy rate UP",
        START_MESSAGE2 = "Negates Water DMG",
        START_MESSAGE3 = "CRI rate UP to enemy with Status Ailments",
        HP70_MESSAGE1 = "Let's have some fun!",
        HP70_MESSAGE2 = "DMG UP",
        HP50_MESSAGE1 = "This will teach you how powerless you are!",
        HP50_MESSAGE2 = "ATK UP & enemy's Heal amount DOWN",
        HP30_MESSAGE1 = "Let me show you my true powers!",
        HP30_MESSAGE2 = "Arts gauge & action speed & DMG UP",
        LAST_MESSAGE1 = "Good... but can you handle this?",
        LAST_MESSAGE2 = "Negates protection to allies & DMG reduction",
        END_MESSAGE1 = "Well done...",
        TIMEUP_MESSAGE1 = "I will end this!"
    },

    [2013931] = {
        START_MESSAGE1 = "Accuracy rate UP"
    },
    [2013937] = {
        START_MESSAGE1 = "Accuracy rate UP"
    },
    [2013943] = {
        START_MESSAGE1 = "Accuracy rate UP",
        HP50_MESSAGE1 = "Action speed UP",
        HP30_MESSAGE1 = "Arts gauge fills at double speed"
    },
    [2013949] = {
        START_MESSAGE1 = "Let's do this thing!",
        HP70_MESSAGE1 = "How about I spice things up a bit?",
        HP70_MESSAGE2 = "DMG UP to enemy",
        HP50_MESSAGE1 = "Let's finish this!",
        HP50_MESSAGE2 = "DMG & Action speed BOOSTED!",
        HP30_MESSAGE1 = "Time to give everything I've got!",
        HP30_MESSAGE2 = "DMG UP & Arts gauge fills even FASTER!"
    },

    [4000417] = {
        mess1 = "DMG Drain for a certain period",
        mess2 = "Protective Water Stance",
        mess3 = "Heavenly Water Stance",
        mess4 = "HP Auto-recovery",
        mess5 = "HP Auto-recovery Amount UP",
        mess6 = "Counter Arts against CRI DMG",
        mess7 = "Invincible Mode",
        mess8 = "Human & God Killer"
    },
    [4000427] = {
        mess1 = "DMG Drain for a certain period",
        mess2 = "Protective Water Stance",
        mess3 = "Heavenly Water Stance",
        mess4 = "HP Auto-recovery",
        mess5 = "HP Auto-recovery Amount UP",
        mess6 = "Counter Arts against CRI DMG",
        mess7 = "Invincible Mode",
        mess8 = "Human & God Killer"
    },
    [4000437] = {
        mess1 = "DMG Drain for a certain period",
        mess2 = "Protective Water Stance",
        mess3 = "Heavenly Water Stance",
        mess4 = "HP Auto-recovery",
        mess5 = "HP Auto-recovery Amount UP",
        mess6 = "Counter Arts against CRI DMG",
        mess7 = "Invincible Mode",
        mess8 = "Human & God Killer"
    },
    [4000447] = {
        mess1 = "DMG Drain for a certain period",
        mess2 = "Protective Water Stance",
        mess3 = "Heavenly Water Stance",
        mess4 = "HP Auto-recovery",
        mess5 = "HP Auto-recovery Amount UP",
        mess6 = "Counter Arts against CRI DMG",
        mess7 = "Invincible Mode",
        mess8 = "Human & God Killer"
    },

    --イフリート
    [4000517] = {
        mess1 = "Spirits & Machines Killer ",
        mess2 = "ATK Speed UP during Burn",
        mess3 = "Burn end. ATK Speed UP end.",
        mess4 = "DMG DOWN during Burn",
        mess5 = "Burn end. Water DEF DOWN.",
        mess6 = "Arts gauge Auto-fill Speed UP during Burn"
    },
     [4000527] = {
        mess1 = "Spirits & Machines Killer ",
        mess2 = "ATK Speed UP during Burn",
        mess3 = "Burn end. ATK Speed UP end.",
        mess4 = "DMG DOWN during Burn",
        mess5 = "Burn end. Water DEF DOWN.",
        mess6 = "Arts gauge Auto-fill Speed UP during Burn"
    },
     [4000537] = {
        mess1 = "Spirits & Machines Killer ",
        mess2 = "ATK Speed UP during Burn",
        mess3 = "Burn end. ATK Speed UP end.",
        mess4 = "DMG DOWN during Burn",
        mess5 = "Burn end. Water DEF DOWN.",
        mess6 = "Arts gauge Auto-fill Speed UP during Burn"
    },
     [4000547] = {
        mess1 = "Spirits & Machines Killer ",
        mess2 = "ATK Speed UP during Burn",
        mess3 = "Burn end. ATK Speed UP end.",
        mess4 = "DMG DOWN during Burn",
        mess5 = "Burn end. Water DEF DOWN.",
        mess6 = "Arts gauge Auto-fill Speed UP during Burn",
        mess7 = "Water DEF UP during Burn"
    },
    [2007042] = {
        mess1 = "People are... tough...",
        mess2 = "Accuracy rate UP",
        mess3 = "HP Auto-recovery",
        mess4 = "Arts DMG UP"
    },
    [2000663] = {
        mess1 = "God Killer",
        mess2 = "Demon Killer",
        mess3 = "CRI DMG UP",
        mess4 = "CRI DMG (except when Burn)",
        mess5 = "DMG Invalid (except CRI DMG)",
        mess6_1 = "CRI DMG Invalid",
        mess6_2 = "Isn't that impressive to have the courage to defend you allies.",
        mess6_3 = "I'm fighting with my full strength from now!",
        mess7 = "DMG UP"
    },
    [4910024] = {
        RAGE = "Rage Mode",
        ANTIDAMAGE = "Negates All DMG (except CRI DMG)",
        ANTICRITICAL = "Negates All DMG (except while Burning)",
        ANTIWATER = "Drain Water DMG",
        BARRIEREND = "Cancel DMG Negating",
        REGENATION = "HP Auto-recovery",
        BURN = "Stop Auto-recovery",
        RESTART = "Restart Auto-recovery",
        ANTIBURN = "Burn Resistance",
        BURNDOWN = "Burning Resistance DOWN",
        TALK1 = "Welcome! Get ready!",
        TALK2 = "Not bad... But I ain't gonna lose!",
        TALK3 = "No, no way... Here's my last hope!",
        TALK4 = "NO WAAAAAAAAAAAAY!"
    },

    [49101] = {
        RAGE = "Rage Mode",
        ANTIDAMAGE = "Negates All DMG (except CRI DMG)",
        ANTICRITICAL = "Negates All DMG (except while Burning)",
        ANTIWATER = "Drain Water DMG",
        BARRIEREND = "Cancel DMG Negating",
        REGENATION = "HP Auto-recovery",
        BURN = "Stop Auto-recovery",
        RESTART = "Restart Auto-recovery",
        ANTIBURN = "Burn Resistance",
        BURNDOWN = "Burning Resistance DOWN",
        TALK1 = "Welcome! Get ready!",
        TALK2 = "Not bad... But I ain't gonna lose!",
        TALK3 = "No, no way... Here's my last hope!",
        TALK4 = "NO WAAAAAAAAAAAAY!"
    },

    [5040900] = {
        HP50_MESSAGE1 = "Evasion rate UP",
        START_MESSAGE1 = "Physical DMG taken DOWN"
    },
    [5040905] = {
        HP20_MESSAGE1 = "ATK UP",
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        SKILL13_MESSAGE1 = "Protective Water Stance",
        SKILL14_MESSAGE1 = "Heavenly Water Stance",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "DMG from Machine & Spirit UP",
        START_MESSAGE3 = "DMG from Poisoned unit DOWN"
    },
    [5040910] = {
        DEAD_MESSAGE1 = "Whyyyyy?!",
        FIXED_DAMAGE_MESSAGE1 = "3000 DMG",
        FIXED_DAMAGE_MESSAGE2 = "6000 DMG for Poisoned Unit",
        HP30_MESSAGE1 = "I ain't done yet!",
        HP30_MESSAGE2 = "CRI resistance UP",
        HP50_MESSAGE1 = "Time to get my vines dirty!",
        HP50_MESSAGE2 = "Poison resistance UP",
        START_MESSAGE1 = "I'mma strangle you good!",
        START_MESSAGE2 = "Earth, Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Shield Killer",
        START_MESSAGE4 = "CRI DMG taken UP",
        START_MESSAGE5 = "DMG taken UP during Poisoned"
    },
    [5040912] = {
        WAVE1_MESSAGE1 = "Corogran: CRI resistance",
        WAVE1_MESSAGE2 = "Mohldora: CRI resistance",
        WAVE2_MESSAGE1 = "Mohldora: CRI resistance"
    },
    [5040915] = {
        HP30_MESSAGE1 = "ATK speed & Arts gauge filling speed UP",
        HP30_MESSAGE2 = "DMG: 2000 x Number of Poison inflicted",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "HP Auto-recovery Killer",
        START_MESSAGE3 = "DMG taken UP for each Poison instance",
        START_MESSAGE4 = "Gernorse: Negates CRI DMG",
        START_MESSAGE5 = "Blue Skeleton: Negates DMG except Poison",
        SUMMON1_MESSAGE1 = "Gernorse joined",
        SUMMON2_MESSAGE1 = "Blue Skeleton joined"
    },
    [5040916] = {
        START_MESSAGE1 = "Gernorse: Negates CRI DMG",
        START_MESSAGE2 = "Blue Skeleton: Negates DMG except Poison"
    },
    [5040917] = {
        START_MESSAGE1 = "Gernorse: Negates CRI DMG",
        START_MESSAGE2 = "Blue Skeleton: Negates DMG except Poison"
    },
    [5040918] = {
        HP30_MESSAGE1 = "Awaken, might of the sea dragon.",
        HP70_MESSAGE1 = "Know the fury of the boundless ocean.",
        START_MESSAGE1 = "Your blood will coat my spear.",
        START_MESSAGE2 = "Water & Reflection resistance",
        START_MESSAGE3 = "Cancel DMG negation"
    },
    [5040920] = {
        HP20_MESSAGE1 = "Smogdragon: Arts gauge filling speed UP",
        HP20_MESSAGE2 = "Allies' ATK DOWN sharply",
        HP90_MESSAGE1 = "A lethal mist rises...",
        SKILL1_MESSAGE1 = "Smogdragon: DMG UP",
        SKILL2_MESSAGE1 = "Smogdragon: HP recovery",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "Cancel DMG negation, Spirits Killer",
        START_MESSAGE3 = "Dark Coroc: Negates CRI DMG",
        START_MESSAGE4 = "Dark Coroc: DMG taken & BE Output UP during Poison",
        SUMMON1_MESSAGE1 = "Dulah joined",
        SUMMON2_MESSAGE1 = "Dark Coroc joined"
    },
    [5040922] = {
        START_MESSAGE1 = "Dark Coroc: Negates CRI DMG",
        START_MESSAGE2 = "Dark Coroc: DMG taken & BE Output UP during Poison"
    },

    [5041000] = {
        HP30_MESSAGE1 = "ATK UP",
        START_MESSAGE1 = "Magic DMG resistance"
    },
    [5041005] = {
        BREAK_MESSAGE1 = "Break! Storm mode cancelled",
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        SKILL3_MESSAGE1 = "Storm mode cancelled",
        START_MESSAGE1 = "Magic, Reflection, & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "DMG DOWN during Burn",
        WIND_MESSAGE1 = "Storm mode: Evasion Rate UP cancelled by Break"
    },
    [5041010] = {
        BREAK_MESSAGE1 = "Break! DMG taken UP during Break!",
        START_MESSAGE1 = "Magic, Reflection, Lifesteal, & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "DMG taken from Burning units DOWN",
        START_MESSAGE3 = "Break DMG UP during Freezing",
        START_MESSAGE4 = "DMG taken UP during Break"
    },
    [5041015] = {
        BREAK_MESSAGE1 = "Break! DMG taken UP!",
        HP30_MESSAGE1 = "Evasion rate, ATK speed, & Arts gauge filling speed UP",
        HP80_MESSAGE1 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "Magic, Reflection, Lifesteal, & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "Demon Killer",
        START_MESSAGE3 = "More Break, more DMG taken",
        START_MESSAGE4 = "Break DMG DOWN from Burning units",
        SUMMON1_MESSAGE1 = "Samarro joined",
        SUMMON2_MESSAGE1 = "Grovogg joined"
    },
    [5041016] = {
        START_MESSAGE1 = "Samarro: DMG taken UP during Freezing",
        START_MESSAGE2 = "Grovogg: DMG taken UP during Freezing"
    },
    [5041017] = {
        START_MESSAGE1 = "Samarro: DMG taken UP during Freezing",
        START_MESSAGE2 = "Grovogg: DMG taken UP during Freezing"
    },
    [5041018] = {
        START_MESSAGE1 = "Fire & Reflection resistance",
        START_MESSAGE2 = "Cancel DMG Negation"
    },
    [5041020] = {
        BREAK_MESSAGE1 = "Break! DMG taken UP during Break!",
        DEAD_MESSAGE1 = "We shall soon meet again...",
        HP0_MESSAGE1 = "I devour life itself.",
        HP40_MESSAGE1 = "My name shall be scarred into your soul.",
        HP40_MESSAGE2 = "Left unit disabled!",
        HP70_MESSAGE1 = "I bestow ruination upon you.",
        HP70_MESSAGE2 = "Right unit disabled!",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Magic resistance & Shield Killer",
        START_MESSAGE3 = "More Break, more DMG taken",
        START_MESSAGE4 = "Targeting the unit inflicts the highest DMG",
        START_MESSAGE5 = "CRI rate UP to a target"
    },
    [5041021] = {
        DEAD_MESSAGE1 = "Go, ravagers...",
        HP0_MESSAGE1 = "The time has come.",
        HP30_MESSAGE1 = "Let the seething rapids flow.",
        HP60_MESSAGE1 = "I will burn you to ashes.",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "CRI resistance",
        START_MESSAGE3 = "Shield & Earth Killer",
        START_MESSAGE4 = "DMG taken from Burning enemy DOWN"
    },

    [5041100] = {
        HP50_MESSAGE1 = "Evasion rate UP"
    },
    [5041105] = {
        BREAK_MESSAGE1 = "Threat Lv.A CONFIRMED, EXECUTING",
        BREAK_MESSAGE2 = "Break! DMG taken UP!",
        BREAK_MESSAGE3 = "Attack Mode Shifted: DMG taken DOWN Cancelled, Action speed UP",
        HP0_MESSAGE1 = "Self-Destruct Sequence Active",
        HP0_MESSAGE2 = "Finis Machina Activated",
        HP30_MESSAGE1 = "Removing all the Limiters",
        HP30_MESSAGE2 = "ATK UP",
        START_MESSAGE1 = "WARNING: INTRUDER ALERT",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE3 = "Shield mode: All DMG taken DOWN cancelled by Break"
    },
    [5041110] = {
        HP30_MESSAGE1 = "Arts gauge filling speed & CRI resistance UP",
        HP70_MESSAGE1 = "Arts gauge filling speed & CRI resistance UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "CRI rate UP to Humans & Spirits"
    },
    [5041115] = {
        BREAK_AFTER_MESSAGE1 = "Dark Coroc: DMG taken UP during Blinded",
        BREAK_AFTER_MESSAGE2 = "Light Coroc: DMG taken UP during Paralysis",
        BREAK_AFTER_MESSAGE3 = "The more Dark ＆ Light Corocs, the less DMG Boss takes",
        BREAK_MESSAGE1 = "Break! Blessing of Bright Sphere Spirit cancelled",
        HP20_MESSAGE1 = "DEF & Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        HP50_MESSAGE2 = "CRI resistance DOWN",
        HP80_MESSAGE1 = "DMG UP",
        SKILL1_MESSAGE1 = "MAX HP DOWN",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Shield Killer",
        START_MESSAGE3 = "Blessing of Bright Sphere Spirit cancelled by Break",
        SUMMON1_MESSAGE1 = "Dark Coroc Joined",
        SUMMON2_MESSAGE1 = "Light Coroc Joined"
    },
    [5041116] = {
        START_MESSAGE1 = "Dark Coroc: DMG taken UP during Blinded"
    },
    [5041117] = {
        START_MESSAGE1 = "Light Coroc: DMG taken UP during Paralysis"
    },
    [5041120] = {
        HP20_MESSAGE1 = "DEF UP",
        HP40_MESSAGE1 = "DMG UP",
        HP60_MESSAGE1 = "CRI resistance UP",
        SKILL2_MESSAGE1 = "Target's Accuracy DOWN",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Auto recovery killer & DMG Negation cancelled",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG",
        START_MESSAGE4 = "CRI rate UP to a target",
        START_MESSAGE5 = "Mirza: CRI DMG taken UP",
        SUMMON1_MESSAGE1 = "Mirza Joined"
    },
    [5041122] = {
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "DEF & Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "CRI resistance",
        START_MESSAGE3 = "The lower unit's HP, the more DMG dealt",
        START_MESSAGE4 = "Mirza: CRI DMG taken UP"
    },

    [5041200] = {
        BREAK_MESSAGE1 = "Break! DMG taken DOWN cancelled",
        HP50_MESSAGE1 = "ATK UP",
        START_MESSAGE1 = "DMG taken DOWN cancelled by Break"
    },
    [5041205] = {
        BREAK_MESSAGE1 = "Gah! Shape up, weaklings!",
        BREAK_MESSAGE2 = "Break! Magic barrier cancelled",
        DEAD_MESSAGE1 = "Why me?!",
        HP50_MESSAGE1 = "You asked for it!",
        HP50_MESSAGE2 = "CRI resistance & Arts gauge filling speed UP",
        START_MESSAGE1 = "You won't lay a finger on me.",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN RES. ",
        START_MESSAGE3 = "Magic Barrier: DMG resistance cancelled by Break",
        START_MESSAGE4 = "ATK & CRI rate UP over time",
        SUMMON_MESSAGE1 = "Megarock Dohmal joined",
        SUMMON_MESSAGE2 = "Gronus joined",
        SUMMON_MESSAGE3 = "Beast Fighter Wald joined"
    },
    [5041210] = {
        BREAK_MESSAGE1 = "Break! DMG taken UP during Break",
        START_MESSAGE1 = "CRI, Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG taken UP during Status ailment",
        START_MESSAGE3 = "DMG taken UP during Break"
    },
    [5041215] = {
        HP20_MESSAGE1 = "Break resistance UP",
        HP50_MESSAGE1 = "CRI resistance UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Shield Killer",
        START_MESSAGE3 = "DMG taken UP during Break"
    },
    [5041216] = {
        HP50_MESSAGE1 = "Reveal your inner essence!",
        HP50_MESSAGE2 = "Arts gauge filling speed UP",
        SKILL2_MESSAGE1 = "Skill CT speed DOWN",
        START_MESSAGE1 = "I shall test your strength.",
        START_MESSAGE2 = "Targets the unit inflicts highest DMG",
        START_MESSAGE3 = "CRI rate UP to a target"
    },
    [5041220] = {
        DEAD_MESSAGE1 = "Darkness...is everlasting...",
        HP0_MESSAGE1 = "Come forth, eternal serpent.",
        HP0_MESSAGE2 = "Magic resistance UP",
        HP0_MESSAGE3 = "Unit's Status Ailment resistance DOWN",
        HP30_MESSAGE1 = "Sink into the void.",
        HP30_MESSAGE2 = "Arts gauge filling speed UP",
        HP60_MESSAGE1 = "Perish.",
        HP60_MESSAGE2 = "CRI resistance UP",
        START_MESSAGE1 = "The sin of blasphemy is great...",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Dark resistance & Shield Killer",
        START_MESSAGE4 = "Bloodybat: Lifesteal RES. & CRI DMG taken DOWN",
        SUMMON_MESSAGE1 = "Bloodybat Joined"
    },
    [5041221] = {
        SKILL_MESSAGE1 = "Horrid Wave: Arts gauge DOWN to Half",
        START_MESSAGE1 = "Bloodybat: Lifesteal RES. & CRI DMG taken DOWN"
    },
    [5041222] = {
        HP30_MESSAGE1 = "Madness is always close at hand.",
        HP30_MESSAGE2 = "Evasion rate & Arts gauge filling speed UP",
        HP30_MESSAGE3 = "Bloodybat Joined",
        HP70_MESSAGE1 = "I will devour your souls.",
        HP70_MESSAGE2 = "Evasion rate & Arts gauge filling speed UP",
        START_MESSAGE1 = "I see all.",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Light Killer",
        START_MESSAGE4 = "DMG taken UP during Status Ailment",
        START_MESSAGE5 = "Bloodybat: Lifesteal RES. & CRI DMG taken DOWN"
    },

    [5041300] = {
        GRAD_MESSAGE1 = "Holds a unit with the highest HP",
        RAGE_MESSAGE1 = "Rage mode: Arts gauge filling speed UP"
    },
    [5041305] = {
        GRAD_MESSAGE1 = "Holds a unit with the highest HP",
        RAGE_MESSAGE1 = "Rage mode: Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG taken DOWN except Water DMG",
        START_MESSAGE3 = "DMG UP to Burning enemy"
    },
    [5041310] = {
        HP20_MESSAGE1 = "CRI rate & Arts gauge filling speed UP",
        HP40_MESSAGE1 = "DMG from Demons DOWN",
        HP60_MESSAGE1 = "DMG from Gods DOWN",
        HP80_MESSAGE1 = "DMG from Humans DOWN",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Light Killer"
    },
    [5041315] = {
        HP20_MESSAGE1 = "DMG & CRI rate UP",
        HP30_MESSAGE1 = "DMG & Arts gauge filling speed UP",
        HP40_MESSAGE1 = "DMG & CRI rate UP",
        HP50_MESSAGE1 = "DMG UP",
        SKILL1_MESSAGE1 = "MAX HP DOWN",
        SKILL2_MESSAGE1 = "Hellfrost: DMG negation cancelled",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG taken UP during Disease"
    },
    [5041317] = {
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        HP70_MESSAGE1 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG taken DOWN except Earth DMG"
    },
    [5041320] = {
        HP30_MESSAGE1 = "HP auto-recovery",
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        HP70_MESSAGE1 = "CRI resistance UP",
        SKILL1_MESSAGE1 = "Freeze resistance DOWN",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Weakness: Fire",
        START_MESSAGE3 = "DMG taken UP during Disease",
        START_MESSAGE4 = "Scylla: Magic DMG taken UP",
        SUMMON_MESSAGE1 = "Scylla joined"
    },
    [5041321] = {
        START_MESSAGE1 = "Scylla: Magic DMG taken UP"
    },
    [5041322] = {
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "CRI rate UP to Frozen enemy",
        START_MESSAGE3 = "DMG UP to Diseased enemy",
        START_MESSAGE4 = "Scylla: Magic DMG taken UP"
    },

    [5041400] = {
        HP50_MESSAGE1 = "ATK UP",
        START_MESSAGE1 = "DMG UP to Blinded enemy",
        START_MESSAGE2 = "DMG taken UP by # of units' Elements in party"
    },
    [5041405] = {
        FALL_MESSAGE1 = "Freeze! Flying mode canceled!",
        FLY_MESSAGE1 = "Flying mode: Evasion rate UP, Canceled by Freeze",
        HP50_MESSAGE1 = "CRI resistance UP",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG taken UP by # of units' Elements in party",
        START_MESSAGE3 = "Flying mode: Evasion rate UP, Canceled by Freeze",
        START_MESSAGE4 = "Freeze resistance UP by # of monsters in battle",
        SUMMON_MESSAGE1 = "Kilmbat joined",
        SUMMON_MESSAGE2 = "Phoenix joined",
        SUMMON_MESSAGE3 = "Fraid joined"
    },
    [5041410] = {
        HP30_MESSAGE1 = "HP auto-recovery",
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG taken UP by # of units' Elements in party",
        START_MESSAGE3 = "DMG UP by # of Wyrms' Elements in battle",
        START_MESSAGE4 = "DMG from enemy with Status ailment UP",
        SUMMON_MESSAGE1 = "Inferno Wyrm joined",
        SUMMON_MESSAGE2 = "Aqua Wyrm joined",
        SUMMON_MESSAGE3 = "Gaia Wyrm joined",
        SUMMON_MESSAGE4 = "Gold Wyrm joined",
        SUMMON_MESSAGE5 = "Violet Wyrm joined"
    },
    [5041416] = {
        ELEMENT0 = "Non-Elemental",
        ELEMENT1 = "Fire",
        ELEMENT2 = "Water",
        ELEMENT3 = "Earth",
        ELEMENT4 = "Light",
        ELEMENT5 = "Dark",
        BREAK_HEAL_MESSAGE1 = "Break DMG from { } Element DOWN",
        HP0_MESSAGE1 = "Evil Edge: Cancels DMG Negation",
        HP50_MESSAGE1 = "CRI resistance UP",
        HP50_MESSAGE2 = "Evil Edge: Cancels DMG Negation",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG taken UP by # of units' Elements in party",
        START_MESSAGE3 = "DMG taken UP during Break"
    },
    [5041417] = {
        HP30_MESSAGE1 = "I won't let it end like this!",
        HP30_MESSAGE2 = "Evasion rate UP",
        HP30_MESSAGE3 = "Blind resistance DOWN",
        HP70_MESSAGE1 = "Prepare yourselves!",
        HP70_MESSAGE2 = "Blind resistance DOWN",
        SKILL_MESSAGE1 = "Skill CT speed DOWN",
        START_MESSAGE1 = "Your journey ends here.",
        START_MESSAGE2 = "DMG & CRI rate UP to Blinded enemy"
    },
    [5041420] = {
        BREAK_MESSAGE1 = "Break! Impregnable mode canceled!",
        BURN_MESSAGE1 = "Burn resistance DOWN",
        FREEZE_MESSAGE1 = "Freeze resistance DOWN",
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Magic resistance UP",
        HP70_MESSAGE1 = "Arts gauge filling speed UP",
        POISON_MESSAGE1 = "Poison resistance DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG taken UP by # of units' Elements in party",
        START_MESSAGE3 = "Impregnable mode canceled by Break",
        START_MESSAGE4 = "Targets the unit inflicts highest DMG",
        START_MESSAGE5 = "Target: DMG taken UP by DMG inflicting"
    },
    [5041422] = {
        HP20_MESSAGE1 = "What amazing power. I must control it.",
        HP20_MESSAGE2 = "Evasion rate & Arts gauge filling speed UP",
        HP50_MESSAGE1 = "You've exceeded my expectations!",
        HP50_MESSAGE2 = "Evasion rate & Arts gauge filling speed UP",
        HP70_MESSAGE1 = "How about this?",
        HP70_MESSAGE2 = "Evasion rate UP",
        SKILL2_MESSAGE1 = "Recovery amount DOWN",
        START_MESSAGE1 = "Face punishment for bringing disorder.",
        START_MESSAGE2 = "Light, Dark, & Reflection resistance",
        START_MESSAGE3 = "DMG Negation canceled",
        START_MESSAGE4 = "More Max HP, more DMG"
    },

    [2007705] = {
        START_MESSAGE1 = "Dark & Fire Elemental Killer",
        START_MESSAGE2 = "CRI Resistance",
        START_MESSAGE3 = "Resistance against all Status Ailment"
    },

    [2007709] = {
        START_MESSAGE1 = "Dark & Fire Elemental Killer",
        START_MESSAGE2 = "CRI Resistance",
        START_MESSAGE3 = "Resistance against all Status Ailment",
        RAGE_MESSAGE1 = "The moment I promised...",
        RAGE_MESSAGE2 = "Slash... its existance!",
        RAGE_MESSAGE3 = "I haven't slashed it yet..."
    },

    [4000617] = {
        START_MESSAGE1 = "DMG DOWN except Light",
        START_MESSAGE2 = "Negates CRI BUFF",
        START_MESSAGE3 = "Fire, Water, Earth Killer",
        RAGE_MESSAGE1 = "DMG DOWN except Dark",
        RAGE_MESSAGE2 = "ATK speed UP",
        RAGE_MESSAGE3 = "DMG UP",
        RAGE_MESSAGE4 = "When the judgement will come...",
        RAGE_MESSAGE5 = "the verdict will be accomplished!"
    },
    [4000627] = {
        START_MESSAGE1 = "DMG DOWN except Light",
        START_MESSAGE2 = "Negates CRI BUFF",
        START_MESSAGE3 = "Fire, Water, Earth Killer",
        RAGE_MESSAGE1 = "DMG DOWN except Dark",
        RAGE_MESSAGE2 = "ATK speed UP",
        RAGE_MESSAGE3 = "DMG UP",
        RAGE_MESSAGE4 = "When the judgement will come...",
        RAGE_MESSAGE5 = "the verdict will be accomplished!"
    },
    [4000637] = {
        START_MESSAGE1 = "DMG DOWN except Light",
        START_MESSAGE2 = "Negates CRI BUFF",
        START_MESSAGE3 = "Fire, Water, Earth Killer",
        RAGE_MESSAGE1 = "DMG DOWN except Dark",
        RAGE_MESSAGE2 = "ATK speed UP",
        RAGE_MESSAGE3 = "DMG UP",
        RAGE_MESSAGE4 = "When the judgement will come...",
        RAGE_MESSAGE5 = "the verdict will be accomplished!"
    },
    [4000647] = {
        START_MESSAGE1 = "DMG DOWN except Light",
        START_MESSAGE2 = "Negates CRI BUFF",
        START_MESSAGE3 = "Fire, Water, Earth Killer",
        RAGE_MESSAGE1 = "DMG DOWN except Dark",
        RAGE_MESSAGE2 = "ATK speed UP",
        RAGE_MESSAGE3 = "DMG UP",
        RAGE_MESSAGE4 = "When the judgement will come...",
        RAGE_MESSAGE5 = "the verdict will be accomplished!"
    },
    [4000717] = {
        START_MESSAGE1 = "Break resist",
        START_MESSAGE2 = "Negate DMG except poisoned state",
        START_MESSAGE3 = "Water Killer"
    },
    [4000727] = {
        START_MESSAGE1 = "Break resist",
        START_MESSAGE2 = "Negate DMG except poisoned state",
        START_MESSAGE3 = "Water Killer"
    },
    [4000737] = {
        START_MESSAGE1 = "Break resist",
        START_MESSAGE2 = "Negate DMG except poisoned state",
        START_MESSAGE3 = "Water Killer"
    },
    [4000747] = {
        START_MESSAGE1 = "Break resist",
        START_MESSAGE2 = "Negate DMG except poisoned state",
        START_MESSAGE3 = "Water Killer"
    },
    [2007631] = {
        START_MESSAGE1 = "Light resistance",
        START_MESSAGE2 = "Break resistance DOWN during Disease",
        RAGE_MESSAGE1 = "I'll show you my power...",
        RAGE_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE3 = "Reduce DMG",
        RAGE_MESSAGE4 = "Now this is interesting...",
        TALK1_1 = "I'm going to win once and for all.",
        TALK1_2 = "Show me what you've learned!",
        TALK2_1 = "You think you can beat me, Corsair?",
        TALK2_2 = "Yes--I will win!",
        TALK2_3 = "In the name of the Ice Sword!",
        TALK3_1 = "I've never thought I'd meet you here.",
        TALK3_2 = "Show me what you've got!",
        TALK3_3 = "Hehe... Fine then. Bring it on!",
        TALK4_1 = "CORSAIR!!!!!!!!!!!!!!!!!!!",
        TALK4_2 = "Sister!? You have dark powers!?",
        TALK4_3 = "Nope, just kidding♪",
        TALK5_1 = "Those eyes... You're serious, aren't you?",
        TALK5_2 = "If you don't come with all your might...",
        TALK5_3 = "You won't get away unscathed!"
    },
    [2007637] = {
        START_MESSAGE1 = "Light resistance",
        START_MESSAGE2 = "Break resistance DOWN during Disease",
        RAGE_MESSAGE1 = "I'll show you my power...",
        RAGE_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE3 = "Reduce DMG",
        RAGE_MESSAGE4 = "Now this is interesting...",
        TALK1_1 = "I'm going to win once and for all.",
        TALK1_2 = "Show me what you've learned!",
        TALK2_1 = "You think you can beat me, Corsair?",
        TALK2_2 = "Yes--I will win!",
        TALK2_3 = "In the name of the Ice Sword!",
        TALK3_1 = "I've never thought I'd meet you here.",
        TALK3_2 = "Show me what you've got!",
        TALK3_3 = "Hehe... Fine then. Bring it on!",
        TALK4_1 = "CORSAIR!!!!!!!!!!!!!!!!!!!",
        TALK4_2 = "Sister!? You have dark powers!?",
        TALK4_3 = "Nope, just kidding♪",
        TALK5_1 = "Those eyes... You're serious, aren't you?",
        TALK5_2 = "If you don't come with all your might...",
        TALK5_3 = "You won't get away unscathed!"
    },
    [2007643] = {
        START_MESSAGE1 = "Light resistance",
        START_MESSAGE2 = "Break resistance DOWN during Disease",
        RAGE_MESSAGE1 = "I'll show you my power...",
        RAGE_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE3 = "Reduce DMG",
        RAGE_MESSAGE4 = "Now this is interesting...",
        TALK1_1 = "I'm going to win once and for all.",
        TALK1_2 = "Show me what you've learned!",
        TALK2_1 = "You think you can beat me, Corsair?",
        TALK2_2 = "Yes--I will win!",
        TALK2_3 = "In the name of the Ice Sword!",
        TALK3_1 = "I've never thought I'd meet you here.",
        TALK3_2 = "Show me what you've got!",
        TALK3_3 = "Hehe... Fine then. Bring it on!",
        TALK4_1 = "CORSAIR!!!!!!!!!!!!!!!!!!!",
        TALK4_2 = "Sister!? You have dark powers!?",
        TALK4_3 = "Nope, just kidding♪",
        TALK5_1 = "Those eyes... You're serious, aren't you?",
        TALK5_2 = "If you don't come with all your might...",
        TALK5_3 = "You won't get away unscathed!"
    },
    [2007931] = {
        START_MESSAGE1 = "You wish to challenge me...",
        DEAD_MESSAGE1 = "It was a pleasure... fighting you..."
    },
    [2007937] = {
        START_MESSAGE1 = "Well then...",
        START_MESSAGE2 = "Reduce Light & Dark DMG",
        DEAD_MESSAGE1 = "Your skills... How!",
        SUMMARY = "Reduce Arts gauge"
    },
    [2007943] = {
        START_MESSAGE1 = "You wish to challenge me...",
        START_MESSAGE2 = "Reduce Light & Dark DMG",
        DEAD_MESSAGE1 = "It was a pleasure... fighting you..."
    },
    [2007944] = {
        START_MESSAGE1 = "Well then...",
        START_MESSAGE2 = "Reduce Light & Dark DMG",
        DEAD_MESSAGE1 = "Your skills... How!",
        SUMMARY = "Reduce Arts gauge"
    },
    [2008243] = {
        START_MESSAGE1 = "Dark Resistance",
        FALL_GOBU_MESSAGE1 = "Gobbie...",
        FALL_GOBU_MESSAGE2 = "DMG to enemy UP!",
        FALL_GOBU_MESSAGE3 = "Defence DOWN"
    },

    [2008443] = {
        START_MESSAGE1 = "CRI resistance",
        FALL_MEO_MESSAGE1 = "Meo...",
        FALL_MEO_MESSAGE2 = "DMG UP",
        FALL_MEO_MESSAGE3 = "Light resistance DOWN"
    },

    [2008843] = {
        START_MESSAGE1 = "Sakura Itto-Ryu Mira, here I come!",
        DEAD_MESSAGE1 = "I'm sorry... Sakura...",
        DESTROY_YOMI_MESSAGE1 = "How dare you treat Yomi like that!",
        DESTROY_YOMI_MESSAGE2 = "DMG UP"
    },
    [2009043] = {
        START_MESSAGE1 = "This is perfect for practice.",
        RAGE_MESSAGE1 = "Brace yourself... There's no way out.",
        RAGE_MESSAGE2 = "Action speed & CRI resistance UP"
    },
    [2009405] = {
        START_MESSAGE1 = "BREAK resistance UP",
        START_MESSAGE2 = "Light & Earth Killer",
        START_MESSAGE3 = "Critical when Burn",
        RAGE_MESSAGE1 = "I shall unleash my power...!",
        RAGE_MESSAGE2 = "Action Speed & DMG UP",
        BREAK_MESSAGE = "CRI DMG from enemy UP"
    },
    [2009409] = {
        START_MESSAGE1 = "BREAK resistance UP",
        START_MESSAGE2 = "Light & Earth Killer",
        START_MESSAGE3 = "Critical when Burn",
        RAGE_MESSAGE1 = "I shall unleash my power...!",
        RAGE_MESSAGE2 = "Action Speed & DMG UP",
        BREAK_MESSAGE = "CRI DMG from enemy UP"
    },
    [2009843] = {
        START_MESSAGE1 = "You want practice? I won't go easy on you!",
        START_MESSAGE2 = "DMG UP (Except Dark & Light)",
        START_MESSAGE3 = "Evasion rate UP",
        DEAD_ZENON_MESSAGE = "DMG UP",
        DEAD_LILY_MESSAGE = "Arts gauge Auto-fill Speed UP",
        RAGE_MESSAGE = "I haven't even used half of my powers!"
    },
    --属性回廊闇のフォスラディウス
    [2005533] = {
        mess1 = "Negates DMG (Except when Blind)",
        mess2 = "Arts Gauge Boost UP",
        mess3 = "Break Gauge Restored"
    },
    [2005534] = {
        START_MESSAGE1 = "Show me your full power! ",
        START_MESSAGE2 = "Break resist UP except when Blind",
        START_MESSAGE3 = "CRI resist",
        FINISH_MESSAGE1 = "From here, is the true battle!!"
    },
    --属性回廊光のマヴロスキア
    [2005433] = {
        mess1 = "Rage Status: Break Power UP",
        mess2 = "Clear Angry Status",
        mess3 = "Negates DMG (Except when Paralyze)"
    },

    [2005434] = {
        START_MESSAGE1 = "You're going to have to show your full power!",
        START_MESSAGE2 = "Break resist UP except when Paralyzed",
        START_MESSAGE3 = "CRI resist",
        FINISH_MESSAGE1 = "Time to go full throttle!!"
    },
    [2005440] = {
        KILL2_MESSAGE1 = "instant kill ATK",
        KILL_MESSAGE1 = "Instant kill ATK on units with 80% or more HP",
        START_MESSAGE1 = "Reflection, Arts gauge DOWN & CRI resistance",
        START_MESSAGE2 = "DMG UP when not in burn, poison, or Blind"
    },

    [200200000] = {
        UNIT_NAME = "Giant Dakyuon",
        START_MESSAGE = "MAX DMG 999"
    },
    [200200001] = {
        UNIT_NAME = "Giant Dakyuon",
        START_MESSAGE = "MAX DMG 999"
    },
    [200200002] = {
        UNIT_NAME = "Giant Dakyuon",
        START_MESSAGE = "MAX DMG 999"
    },
    [200200003] = {
        UNIT_NAME = "Giant Dakyuon",
        START_MESSAGE = "MAX DMG 999"
    },
    [200200004] = {
        UNIT_NAME = "Giant Dakyuon",
        START_MESSAGE = "MAX DMG 999"
    },
    [200200005] = {
        UNIT_NAME = "Giant Dakyuon",
        START_MESSAGE = "MAX DMG 999"
    },
    [4000817] = {
        mess1 = "Accuracy rate UP",
        mess2 = "All elemental resistance UP",
        mess3 = "Action speed & DMG UP"
    },
    [4000827] = {
        mess1 = "Accuracy rate UP",
        mess2 = "All elemental resistance UP",
        mess3 = "Action speed & DMG UP"
    },
    [4000837] = {
        mess1 = "Accuracy rate UP",
        mess2 = "All elemental resistance UP",
        mess3 = "Action speed & DMG UP"
    },
    [4000847] = {
        mess1 = "Accuracy rate UP",
        mess2 = "All elemental resistance UP",
        mess3 = "Action speed & DMG UP"
    },

    [4001017] = {
        BUFF_MESSAGE = "Storm Mode: Evasion Rate UP & Break Negated",
        BUFF_MESSAGE2 = "Ultra Storm Mode: Evasion Rate Boosted & Break Negated",
        BUFF_MESSAGE3 = "Storm Mode cancelled by certain status ailment DMG",
        BUFF_MESSAGE4 = "Ultra Storm Mode cancelled by certain status ailment DMG",
        REMOVE_BUFF_MESSAGE = "Storm Mode cancelled",
        START_MESSAGE = "ATK & CRI DMG UP",
        RAGE_MESSAGE1 = "Action speed UP",
        RAGE_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE3 = "Arts gauge fills at double speed",
        RAGE_MESSAGE4 = "DMG taken UP"
    },

    [600000014] = {
        mess1 = "Boss has targeted you!",
        mess2 = "Fallen Cells Reactivated",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Targeted by Boss!",
        telop4 = "Boss has powered up!",
        telop5 = "When your unit falls, replace them and fight!",
        telop6 = "Rewards will vary according to your ranking.",
        mess3 = "Until End of the World:",
        min = " minutes",
        sec = " seconds"
    },
    [600000015] = {
        mess1 = "Boss has targeted you!",
        mess2 = "Fallen Cells Reactivated",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Targeted by Boss!",
        telop4 = "Boss has powered up!",
        telop5 = "When your unit falls, replace them and fight!",
        telop6 = "Rewards will vary according to your ranking.",
        mess3 = "Until End of the World:",
        min = " minutes",
        sec = " seconds"
    },
    [2008605] = {
        mess1 = "I tear you apart!!",
        mess2 = "Demons are abominable!",
        mess3 = "Demon Killer",
        mess4 = "Dark Resistance",
        mess5 = "Negates CRI DMG",
        mess6 = "Further... Mightier!"
    },
    [2008609] = {
        mess1 = "I tear you apart!!",
        mess2 = "Demons are abominable!",
        mess3 = "Demon Killer",
        mess4 = "Dark Resistance",
        mess5 = "Negates CRI DMG",
        mess6 = "Further... Mightier!",
        mess7 = "Break Res UP",
        mess8 = "Get lost!!",
        mess9 = "CRI rate UP",
        mess10 = "The girl...!!!"
    },
    [2000670] = {
        START_MESSAGE1 = "Accuracy Rate UP",
        MIST_MESSAGE1 = "Start DMG Stock",
        RAGE_MESSAGE1 = "Movement Speed UP",
        RAGE_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE3 = "Break Resistance UP",
        LAST_MESSAGE1 = "Cannot defeat until Gauge Break"
    },
    [2000674] = {
        messageStart1 = "Reduce DMG to Blinded enemy",
        messageStart2 = "Reduce DMG to Poisoned enemy",
        messageStart3 = "Accuracy rate UP",
        messageWind1 = "Storm mode:Break Resistance UP",
        messageWind2 = "Storm mode:Evasion rate UP",
        messageWindEnd = "Storm mode End",
        messageRage = "Anger mode:DMG UP",
        messageHeat1 = "Heat up:Break Resistance DOWN",
        messageHeat2 = "Heat up:Evasion rate DOWN",
        messageHeat3 = "Heat up:DMG UP"
    },

    [2000675] = {
        START_MESSAGE1 = "Negates DMG (Except Arts DMG)"
    },

    [2000676] = {
        START_MESSAGE = "ATK & Evasion rate & CRI DMG UP",
        START_MESSAGE1 = "Negates DMG (Except Arts DMG)",
        START_MESSAGE2 = "CRI rate UP when enemy is Burning",
        START_MESSAGE3 = "HP Auto-recovery UP & Freeze resistance DOWN when Burn",
        ARTS_MESSAGE = "Arts gauge UP (Only once)",
        LAST_ATTACK_MESSAGE1 = "The Dungeon of Trials is distorted by the flames...!",
        LAST_ATTACK_MESSAGE2 = "The heat source is in the sky!",
        BUFF_MESSAGE1 = "Arts gauge fills at double speed when Burn",
        BUFF_MESSAGE2 = "Counter rate UP when Burn",
        BUFF_MESSAGE2_2 = "Action speed UP",
        BUFF_MESSAGE3 = "DMG from enemy DOWN when Burn",
        BUFF_MESSAGE3_2 = "DMG UP"
    },

    [2000677] = {
        START_MESSAGE1 = "Shield Unit Killer",
        START_MESSAGE2 = "Heals DMG from enemy",
        HP80_MESSAGE1 = "Constantly reduces Arts gauge",
        HP70_MESSAGE1 = "Heal amount of DMG from enemy UP!",
        HP60_MESSAGE1 = "DMG UP!",
        HP50_MESSAGE1 = "Arts gauge fills at double speed",
        HP40_MESSAGE1 = "CRI rate UP!",
        HP40_MESSAGE2 = "CRI DMG UP!",
        HP30_MESSAGE1 = "Action speed BOOSTED!",
        COUNTER_MESSAGE_A = "Heavenly Aqua Barrier Stance",
        COUNTER_MESSAGE_B = "Heavenly Aqua Slash Stance"
    },
    [2000684] = {
        ELEMENT0 = "Non-Elemental",
        ELEMENT1 = "Fire",
        ELEMENT2 = "Water",
        ELEMENT3 = "Earth",
        ELEMENT4 = "Light",
        ELEMENT5 = "Dark",
        ELEMENT_MESSAGE1 = " DMG taken DOWN",
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN Res. ",
        START_MESSAGE2 = "Shield & HP Auto-recovery Killer",
        START_MESSAGE3 = "Targeting the unit inflicts the greatest DMG",
        START_MESSAGE4 = "CRI rate UP to a target"
    },
    [2000687] = {
        HP30_MESSAGE1 = "You and I are the same.",
        HP30_MESSAGE2 = "ATK & Physical Evasion rate UP",
        HP60_MESSAGE1 = "I've lost something else inside me.",
        HP60_MESSAGE2 = "ATK & Physical Evasion rate UP",
        HP90_MESSAGE1 = "I hear the whispers of Death.",
        HP90_MESSAGE2 = "ATK & Physical Evasion rate UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN Res. ",
        START_MESSAGE2 = "Ignores DMG Negation",
        START_MESSAGE3 = "DMG from Demons DOWN"
    },

    [200330022] = {
        mess1 = "Damage towards Target UP",
        mess2 = "Halloween Nightmare",
        mess3 = "Sureshot",
        mess4 = "Earth Resistance",
        mess5 = "Water Resistance",
        mess6 = "Light Resistance"
    },
    [200350013] = {
        BREAK_BARRIER_MESSAGE1 = "DMG Negation cancelled",
        BREAK_END_MESSAGE1 = "Break resistance UP",
        BREAK_MESSAGE1 = "Break! DMG taken UP!",
        HP40_MESSAGE1 = " CRI resistance UP more",
        HP70_MESSAGE1 = "CRI resistance UP",
        SKILL2_MESSAGE1 = "DMG UP",
        SKILL3_MESSAGE1 = "DEF doubled & Recovery UP during Negation Shield",
        START_MESSAGE1 = "Negates Arts gauge DOWN & Reflection",
        START_MESSAGE2 = "CRI resistance",
        START_MESSAGE3 = "Shield & Gods Killer",
        START_MESSAGE4 = "More Break, more DMG taken"
    },
    [200350014] = {
        START_MESSAGE1 = "God Killer"
    },

    [2010005] = {
        START_MESSAGE1 = "A vessel like this...!",
        START_MESSAGE2 = "Magic resistance and Evasion UP",
        START_MESSAGE3 = "If Burning, Arts DMG DOWN",
        BREAK_IN_MESSAGE = "Physical DMG from enemy UP!",
        BREAK_OUT_MESSAGE = "Break resistance UP",
        RAGE_MESSAG1 = "You're amazing... unbelievably, amazing...!",
        RAGE_MESSAGE2 = "Arts gauge generation UP"
    },
    [2010009] = {
        START_MESSAGE1 = "A vessel like this...!",
        START_MESSAGE2 = "Magic resistance and Evasion UP",
        START_MESSAGE3 = "If Burning, Arts DMG DOWN",
        BREAK_IN_MESSAGE = "Physical DMG from enemy UP!",
        BREAK_OUT_MESSAGE = "Break resistance UP",
        RAGE_MESSAG1 = "You're amazing... unbelievably, amazing...!",
        RAGE_MESSAGE2 = "Arts gauge generation UP"
    },

    [2010143] = {
        START_MESSAGE1 = "Evasion rate & CRI rate UP",
        START_MESSAGE2 = "CRI DMG UP",
        RAGE_MESSAGE1 = "Don't you think you can win!",
        LAST_MESSAGE1 = "You had your chance"
    },
    [2010144] = {
        START_MESSAGE1 = "How was my surprise attack?"
    },

        --氷ドラゴン EX
    [2010431] = {
        START_MESSAGE1 = "Burn to stop Rage mode",
        START_MESSAGE2 = "Magic Resistance DOWN",
        RAGE_MESSAGE1 = "Rage mode: Damage over time",
        RAGE_END_MESSAGE1 = "Rage mode end",
        FREEZE_MESSAGE1 = "HP Auto-recovery during Freeze",
        DAMAGE_UP_MESSAGE1 = "DMG UP"
    },
    --氷ドラゴン EX2
    [2010437] = {
        START_MESSAGE1 = "Burn to stop Rage mode",
        START_MESSAGE2 = "Magic Resistance DOWN",
        RAGE_MESSAGE1 = "Rage mode: Damage over time",
        RAGE_END_MESSAGE1 = "Rage mode end",
        FREEZE_MESSAGE1 = "HP Auto-recovery during Freeze",
        DAMAGE_UP_MESSAGE1 = "DMG UP"
    },
    --氷ドラゴン 真EX
    [2010443] = {
        START_MESSAGE1 = "Burn to stop Rage mode",
        START_MESSAGE2 = "Magic Resistance DOWN",
        RAGE_MESSAGE1 = "Rage mode: Damage over time",
        RAGE_END_MESSAGE1 = "Rage mode end",
        FREEZE_MESSAGE1 = "HP Auto-recovery during Freeze",
        DAMAGE_UP_MESSAGE1 = "DMG UP"
    },

    --氷ドラゴン 限定EX

    [2010449] = {
        START_MESSAGE1 = "DMG UP to Earth units",
        RAGE_MESSAGE1 = "I'll show you my power...",
        RAGE_MESSAGE2 = "Magia Drive",
        RAGE_MESSAGE3 = "Arts gauge Auto-fill amount UP",
        RAGE_MESSAGE4 = "DMG UP",
        LAST_MESSAGE1 = "This is the end!"
    },

    [2010731] = {
        START_MESSAGE1 = "Earth Resistance DOWN",
        START_MESSAGE2 = "CRI rate & CRI DMG UP",
        START_MESSAGE3 = "Action speed UP",
        RAGE_MESSAGE = "Action speed & DMG UP",
    },
    [2010737] = {
        START_MESSAGE1 = "Earth Resistance DOWN",
        START_MESSAGE2 = "CRI rate & CRI DMG UP",
        START_MESSAGE3 = "Action speed UP",
        RAGE_MESSAGE = "Action speed & DMG UP",
    },
    [2010743] = {
        START_MESSAGE1 = "Earth Resistance DOWN",
        START_MESSAGE2 = "CRI rate & CRI DMG UP",
        START_MESSAGE3 = "Action speed UP",
        RAGE_MESSAGE = "Action speed & DMG UP",
    },
    [2010749] = {
        START_MESSAGE1 = "Here's my Extra Large Attack!",
        START_MESSAGE2 = "DMG UP to Water units",
        SKILL3_1_MESSAGE1 = "I'm pumped up!",
        SKILL3_1_MESSAGE2 = "Magia Drive",
        SKILL3_1_MESSAGE3 = "Movment Speed & CRI rate UP",
        SKILL3_2_MESSAGE1 = "I'll show you my full power!"
    },
    [2011231] = {
        RAGE_MESSAGE1 = "DMG UP",
        RAGE_MESSAGE2 = "Action Speed UP",
        START_MESSAGE1 = "CRI Resistance"
    },
    [2011237] = {
        RAGE_MESSAGE1 = "DMG UP",
        RAGE_MESSAGE2 = "Action Speed UP",
        START_MESSAGE1 = "CRI Resistance"
    },
    [2011243] = {
        RAGE_MESSAGE1 = "DMG UP",
        RAGE_MESSAGE2 = "Action Speed UP",
        START_MESSAGE1 = "CRI Resistance"
    },
    [2011249] = {
        START_MESSAGE1 = "Can you keep up with me?",
        START_MESSAGE2 = "Evasion rate UP",
        START_MESSAGE3 = "Evasion rate DOWN at BREAK",
        RAGE_MESSAGE1 = "My senses are getting sharper",
        RAGE_MESSAGE2 = "DMG & Action Speed UP",
        RAGE_MESSAGE3 = "You can't run away from me!",
        RAGE_MESSAGE4 = "Evasion rate & Action Speed UP"
    },
    [2011643] = {
        RAGE_MESSAGE1 = "Victory to the Gods!",
        RAGE_MESSAGE2 = "Movement Speed UP",
        LAST_MESSAGE1 = "May the name of the Gods be carved in history!"
    },

    [2011649] = {
        START_MESSAGE1 = "I've got something I'd like to protect, too!",
        START_MESSAGE2 = "CRI Resistance",
        START_MESSAGE3 = "Fire Resistance",
        HP50_MESSAGE1 = "Our pledge to our ruler!",
        HP30_MESSAGE1 = "Body and soul...!",
        HP30_MESSAGE2 = "DMG & Movement Speed UP"
    },

    [2011801] = {
        START_MESSAGE1 = "Arts DMG reduction",
        START_MESSAGE2 = "Fire resistance, Fire Killer",
        START_MESSAGE3 = "Accuracy rate & Break resistance UP",
        HP50_MESSAGE1 = "Shut up!",
        HP50_MESSAGE2 = "Arts gauge increase amount UP",
        HP20_MESSAGE1 = "I'll never forgive you!",
        HP20_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE1 = "As if you can win without me!",
        RAGE_MESSAGE2 = "Get out of my way!",
        RAGE_MESSAGE3 = "Negate CRI",
        RAGE_MESSAGE4 = "Arts gauge increase amount UP",
        BREAK_MESSAGE1 = "Arts DMG reduction ends",
        TIMEUP_MESSAGE1 = "I'm bored."
    },

    [2012043] = {
        START_MESSAGE1 = "Fire Resistance & Fire Killer",
        START_MESSAGE2 = "Auto-recovery",
        RAGE_MESSAGE1 = "Take this!",
        LAST_MESSAGE1 = "Pierce the Azure Sky!"
    },
    [2012049] = {
        START_MESSAGE1 = "God Killer",
        START_MESSAGE2 = "Let's get started!",
        TIME50_MESSAGE1 = "The Pledge to our Ruler!",
        TIME50_MESSAGE2 = "Speed & CRI Rate UP",
        TIME80_MESSAGE1 = "DMG UP",
        TIME110_MESSAGE1 = "Hold on a little more!",
        TIME120_MESSAGE1 = "Good Job!",
        TALK1_MESSAGE1 = "I'll give you all I have!",
        TALK1_MESSAGE2 = "Show me all your strength!",
        TALK2_MESSAGE1 = "Hey, can you ease up a bit?",
        TALK2_MESSAGE2 = "This is a serious match!",
        TALK3_MESSAGE1 = "There's no choice... here I come!",
        TALK3_MESSAGE2 = "Don't be too hard on me. "
    },

    [2014142] = {
        START_MESSAGE1 = "GYAGYUGAAA！",
        START_MESSAGE2 = "DMG DOWN (END after BREAK)",
        BREAK_MESSAGE1 = "GOBUUGAGA…！！",
        BREAK_MESSAGE2 = "DMG DOWN END",
        RAGE_MESSAGE1 = "GYAGORRRAAAAA！！",
        RAGE_MESSAGE2 = "DMG UP"
    },

    [2014643] = {
        HP50_MESSAGE1 = "Backup's here!",
        HP50_MESSAGE2 = "Platina evades DMG while Parlot joins battle",
        HP30_MESSAGE1 = "The gate of Judgement has been opened."
    },
    [2014649] = {
        START_MESSAGE1 = "Completely evades DMG",
        HP30_MESSAGE1 = "Arts gauge Speed UP",
        TALK1_MESSAGE1 = "I'll protect you.",
        TALK2_MESSAGE1 = "Little Lady, wait for me!",
        TALK3_MESSAGE1 = "Princess Leone, hang in there! ",
        TALK4_MESSAGE1 = "I'll protect you.",
        TALK5_MESSAGE1 = "Leone! I'm here to save you!"
    },

    [2014831] = {
        mess1 = "This is the rage of the Stars!",
        mess2 = "DMG received DOWN (ends after BREAK)",
        mess3 = "DMG received DOWN END"
    },
    [2014837] = {
        mess1 = "This is the rage of the Stars!",
        mess2 = "DMG received DOWN (ends after BREAK)",
        mess3 = "DMG received DOWN END"
    },
    [2014843] = {
        mess1 = "This is the rage of the Stars!",
        mess2 = "DMG received DOWN (ends after BREAK)",
        mess3 = "DMG received DOWN END"
    },
    [2014849] = {
        START_MESSAGE1 = "Defeat all the Templars within 250s!",
        START_MESSAGE2 = "Riviera, leave the defense to me!",
        START_MESSAGE3 = "Let's begin!",
        START_MESSAGE4 = "Riviera negates DMG while Thetis is there"
    },
    [2014851] = {
        START_MESSAGE1 = "Next is my turn!",
        START_MESSAGE2 = "Negates Magic DMG"
    },
    [2014852] = {
        START_MESSAGE1 = "Swordsman Berwick is here!",
        START_MESSAGE2 = "Negates Physical DMG"
    },
    [2014853] = {
        START_MESSAGE1 = "You came this far, but now try to defeat me!"
    },

    [2015031] = {
        HP50_MESSAGE1 = "Action speed & ATK UP, Arts gauge fills at double speed"
    },
    [2015037] = {
        HP50_MESSAGE1 = "Action speed & ATK UP, Arts gauge fills at double speed"
    },
    [2015043] = {
        START_MESSAGE1 = "DEF & CRI resistance UP",
        HP50_MESSAGE1 = "Action speed & ATK UP, Arts gauge fills at double speed"
    },
    [2015049] = {
        HP70_MESSAGE1 = "DMG UP to Fire enemy",
        HP50_MESSAGE1 = "Arts gauge fills even FASTER!"
    },
    [2015050] = {
        HP60_MESSAGE1 = "Ignore enemy's DEF"
    },
    [2015231] = {
        START_MESSAGE1 = "DEF & Magic Accuracy rate UP",
        HP40_MESSAGE1 = "Action speed UP"
    },
    [2015237] = {
        START_MESSAGE1 = "DEF & Magic Accuracy rate UP",
        HP40_MESSAGE1 = "Action speed UP"
    },
    [2015243] = {
        START_MESSAGE1 = "DEF & Magic Accuracy rate UP",
        HP40_MESSAGE1 = "Action speed UP"
    },
    [2015249] = {
        HP70_MESSAGE1 = "ATK UP",
        HP50_MESSAGE1 = "Arts gauge fills at double speed & ATK UP"
    },

    [2015250] = {
        HP80_MESSAGE1 = "DMG UP to Water units",
        HP50_MESSAGE1 = "All allies' Water resistance & Freeze resistance UP"
    },

    [487100000] = {
        HP_REDUCE_MESSAGE = "MAX HP DOWN",
        START_MESSAGE = "Negate Light Unit DMG & Break",
        BUFF_MESSAGE1 = "Negate DMG end",
        BUFF_MESSAGE2 = "DMG UP",
        BUFF_MESSAGE3 = "CRI Rate UP"
    },
    [487100020] = {
        HP_REDUCE_MESSAGE = "MAX HP DOWN",
        START_MESSAGE = "Negate Light Unit DMG & Break",
        BUFF_MESSAGE1 = "Negate DMG end",
        BUFF_MESSAGE2 = "DMG UP",
        BUFF_MESSAGE3 = "CRI Rate UP"
    },
    [487100041] = {
        HP_REDUCE_MESSAGE = "MAX HP DOWN",
        START_MESSAGE = "Negate Light Unit DMG & Break",
        BUFF_MESSAGE1 = "Negate DMG end",
        BUFF_MESSAGE2 = "DMG UP",
        BUFF_MESSAGE3 = "CRI Rate UP"
    },
    [2015429] = {
        SHOADOW = "Shadow Lightning Stance"
    },
    [2015430] = {
        START_MESSAGE1 = "DMG UP when Paralyzed",
        START_MESSAGE2 = "DMG UP when Freezed",
        HP30_MESSAGE1 = "Action Speed UP",
        SHOADOW = "Shadow Lightning Stance"
    },
    [2015436] = {
        START_MESSAGE1 = "DMG UP when Paralyzed",
        START_MESSAGE2 = "DMG UP when Freezed",
        HP30_MESSAGE1 = "Action Speed UP",
        SHOADOW = "Shadow Lightning Stance"
    },
    [2015442] = {
        START_MESSAGE1 = "DMG UP when Paralyzed",
        START_MESSAGE2 = "DMG UP when Freezed",
        HP30_MESSAGE1 = "Action Speed UP",
        SHOADOW = "Shadow Lightning Stance"
    },
    [2015449] = {
        RESULT_MESSAGE1 = " TOT",
        RESULT_MESSAGE2 = " DMG!!",
        RESULT_MESSAGE3 = "MAX HIT DMG ",
        DAMAGE_MESSAGE1 = ",000",
        DAMAGE_MESSAGE2 = "%d億",
        DAMAGE_MESSAGE3 = " DMG!!",
        DAMAGE_MESSAGE4 = " HIT",
        DAMAGE_MESSAGE5 = " DMG!!",
        START_MESSAGE1 = "Super-recovery",
        START_MESSAGE3 = "Negate BREAK DMG",
        START_MESSAGE2 = "Allies' DMG UP",
        START_MESSAGE4 = "100,000,000 DMG in 120s CLEAR!!",
        LOSE_MESSAGE1 = "You couldn't reach 100,000,000 DMG...",
        LOSE_MESSAGE2 = "Arts gauge Recovery Speed UP"
    },

    [2015452] = {
        START_MESSAGE1 = "Time to conduct evil",
        HP50_MESSAGE1 = "Not too bad",
        HP50_MESSAGE2 = "DMG UP",
        HP10_MESSAGE1 = "I still have more in me!",
        HP10_MESSAGE2 = "ATK UP",
        HP0_MESSAGE1 = "messed up..."
    },

    [2020261] = {
        START_MESSAGE1 = "DMG taken UP for Water/Earth/Light",
        START_MESSAGE2 = "DMG taken UP when Burning",
        HP70_MESSAGE1 = "DMG UP",
        HP20_MESSAGE1 = "Action Speed UP",
        HP20_MESSAGE2 = "Unnegatable and unreducible fixed damage"
    },

    [2000678] = {
        START_MESSAGE1 = "Negates Physical DMG",
        START_MESSAGE2 = "Blessed when defeating enemy before Arts activation",
        DEAD_MESSAGE1 = "Fire Blessing: Max HP UP"
    },
    [2000679] = {
        START_MESSAGE1 = "Negates Magic DMG",
        START_MESSAGE2 = "Blessed when defeating enemy before Arts activation",
        DEAD_MESSAGE1 = "Water Blessing: Max HP UP"
    },
    [2000680] = {
        START_MESSAGE1 = "Negates DMG from Demons",
        START_MESSAGE2 = "Blessed when defeating enemy before Arts activation",
        DEAD_MESSAGE1 = "Earth Blessing: Max HP UP"
    },
    [2000681] = {
        START_MESSAGE1 = "Action speed/Accuracy/ATK UP",
        HP80_MESSAGE1 = "Action speed UP",
        HP60_MESSAGE1 = "DMG UP",
        HP40_MESSAGE1 = "DMG/Action speed UP",
        HP30_MESSAGE1 = "Arts gauge fills at double speed"
    },

    [501261413] = {
        mess1 = "Targeted by Boss!",
        mess2 = "Fallen Cells Reactivated",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Targeted by Boss!",
        telop4 = "Boss has powered up!",
        telop5 = "When your unit falls, replace them and fight!",
        telop6 = "Rewards will vary according to your ranking.",
        START_MESSAGE1 = "Every 2 min Elemental Killer changes",
        START_MESSAGE2 = "Killer effect reduced with Burn, Blind, Poison",
        START_MESSAGE3 = "Accuracy rate UP",
        RAGE_MESSAGE = "Action speed UP",
        BREAK_MESSAGE = "DMG UP during BREAK"
    },

    [501281113] = {
        BUFF_MESSAGE1 = "Negates DEF penetration",
        BUFF_MESSAGE2 = "HP auto-recovery",
        BUFF_MESSAGE3 = "DMG UP",
        START_MESSAGE = "Negates DMG & Break from Fire units"
    },

    [600000016] = {
        mess1 = "Targeted by Boss!",
        mess2 = "Fallen Cells Reactivated",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Targeted by Boss!",
        telop4 = "Boss has powered up!",
        telop5 = "When your unit falls, replace them and fight!",
        telop6 = "Rewards will vary according to your ranking.",
        START_MESSAGE1 = "Every 2 min Elemental Killer changes",
        START_MESSAGE2 = "Killer effect reduced with Burn, Blind, Poison",
        START_MESSAGE3 = "Accuracy rate UP",
        RAGE_MESSAGE = "Action speed UP",
        BREAK_MESSAGE = "DMG UP during BREAK"
    },

    [600000018] = {
        mess1 = "EeegGaAaga... EEgaGAaa...",
        mess2 = "ReEEee... REeeeEEE...",
        mess3 = "BwWeEaHH... BwwWeaHH...",
        DEAD1 = "DMG UP to Fire units",
        DEAD2 = "If Boss has Burn / Blind / Poison, DMG DOWN to Fire units"
    },
    [600000019] = {
        mess1 = "EeegGaAaga... EEgaGAaa...",
        mess2 = "ReEEee... REeeeEEE...",
        mess3 = "BwWeEaHH... BwwWeaHH...",
        DEAD1 = "DMG UP to Water units",
        DEAD2 = "If Boss has Burn / Blind / Poison, DMG DOWN to Water units"
    },
    [600000020] = {
        mess1 = "EeegGaAaga... EEgaGAaa...",
        mess2 = "ReEEee... REeeeEEE...",
        mess3 = "BwWeEaHH... BwwWeaHH...",
        DEAD1 = "DMG UP to Earth units",
        DEAD2 = "If Boss has Burn / Blind / Poison, DMG DOWN to Earth units"
    },
    [600000021] = {
        mess1 = "EeegGaAaga... EEgaGAaa...",
        mess2 = "ReEEee... REeeeEEE...",
        mess3 = "BwWeEaHH... BwwWeaHH...",
        DEAD1 = "DMG UP to Light units",
        DEAD2 = "If Boss has Burn / Blind / Poison, DMG DOWN to Light units"
    },

    [600000022] = {
        mess1 = "EeegGaAaga... EEgaGAaa...",
        mess2 = "ReEEee... REeeeEEE...",
        mess3 = "BwWeEaHH... BwwWeaHH...",
        DEAD1 = "DMG UP to Dark units",
        DEAD2 = "If Boss has Burn / Blind / Poison, DMG DOWN to Dark units"
    },

    [600000023] = {
        mess1 = "EeegGaAaga... EEgaGAaa...",
        mess2 = "ReEEee... REeeeEEE...",
        mess3 = "BwWeEaHH... BwwWeaHH...",
        DEAD1 = "DMG UP to Fire units",
        DEAD2 = "If Boss has Burn / Blind / Poison, DMG DOWN to Fire units"
    },

    [600000024] = {
        mess1 = "EeegGaAaga... EEgaGAaa...",
        mess2 = "ReEEee... REeeeEEE...",
        mess3 = "BwWeEaHH... BwwWeaHH...",
        DEAD1 = "DMG UP to Water units",
        DEAD2 = "If Boss has Burn / Blind / Poison, DMG DOWN to Water units"
    },

    [600000025] = {
        mess1 = "EeegGaAaga... EEgaGAaa...",
        mess2 = "ReEEee... REeeeEEE...",
        mess3 = "BwWeEaHH... BwwWeaHH...",
        DEAD1 = "DMG UP to Earth units",
        DEAD2 = "If Boss has Burn / Blind / Poison, DMG DOWN to Earth units"
    },

    [600000026] = {
        mess1 = "EeegGaAaga... EEgaGAaa...",
        mess2 = "ReEEee... REeeeEEE...",
        mess3 = "BwWeEaHH... BwwWeaHH...",
        DEAD1 = "DMG UP to Light units",
        DEAD2 = "If Boss has Burn / Blind / Poison, DMG DOWN to Light units"
    },

    [600000027] = {
        mess1 = "EeegGaAaga... EEgaGAaa...",
        mess2 = "ReEEee... REeeeEEE...",
        mess3 = "BwWeEaHH... BwwWeaHH...",
        DEAD1 = "DMG UP to Dark units",
        DEAD2 = "If Boss has Burn / Blind / Poison, DMG DOWN to Dark units"
    },

    [600000028] = {
        TARGET = "Targeted by Boss!",
        START_MESSAGE1 = "Enemy's Heal amount DOWN!",
        START_MESSAGE2 = "The more Break DMG, the more DMG from enemy",
        START_MESSAGE3 = "Evasion rate UP",
        HP50_MESSAGE1 = "DMG UP",
        HP30_MESSAGE1 = "Arts gauge fills at double speed"
    },
    [600000029] = {
        TARGET = "Targeted by Boss!",
        START_MESSAGE1 = "Enemy's Heal amount DOWN!",
        START_MESSAGE2 = "The more Break DMG, the more DMG from enemy",
        START_MESSAGE3 = "Evasion rate UP",
        HP50_MESSAGE1 = "DMG UP",
        HP50_MESSAGE2 = "DMG Negation CANCELED",
        HP30_MESSAGE1 = "Arts gauge fills at double speed"
    },
    [600000058] = {
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Rewards will vary according to your ranking.",
        START_MESSAGE1 = "Water Killer",
        START_MESSAGE2 = "Shield Canceled with Break DMG",
        ARTS_MESSAGE1 = "λ μα Δ Яωt",
        ARTS_MESSAGE2 = "βνη εε ЯπμZ αΣ ζДη χ",
        BREAK_MESSAGE1 = "Shield destroyed:DMG taken UP",
        HP_TRIGGER_MESSAGE1 = "Action speed UP"
    },
    [600000060] = {
        DEAD_MESSAGE1 = "Truly...a glorious battle.",
        SKILL_MESSAGE1 = "Do you hear the stars' fury?",
        SKILL_MESSAGE2 = "My flames are building...",
        SKILL_MESSAGE3 = "You will never approach me.",
        START_MESSAGE1 = "CRI rate UP to Burning enemys",
        START_MESSAGE2 = "Negates Fire DMG",
        START_MESSAGE3 = "Physical Evasion rate UP",
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Rewards will vary according to your ranking."
    },
    [600000061] = {
        DEAD_MESSAGE1 = "Truly...a glorious battle.",
        SKILL_MESSAGE1 = "Do you hear the stars' fury?",
        SKILL_MESSAGE2 = "My flames are building...",
        SKILL_MESSAGE3 = "You will never approach me.",
        START_MESSAGE1 = "CRI rate UP to Burning enemys",
        START_MESSAGE2 = "Negates Fire DMG",
        START_MESSAGE3 = "Physical Evasion rate UP",
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "Rewards will vary according to your ranking."
    },
    [600000068] = {
        CRT_MESSAGE_PARTS1 = "gave",
        CRT_MESSAGE_PARTS2 = "CRI HIT!",
        CRT_MESSAGE2 = "CRI HIT! Boss's Break gauge DOWN",
        HIT_MESSAGE1 = "CRI HIT",
        START_MESSAGE1 = "Negates Fire DMG",
        HP_MESSAGE1 = "ATK UP",
        HP_MESSAGE2 = "Evasion rate UP",
        HP_MESSAGE3 = "DMG UP",
        HP_MESSAGE4 = "ATK speed UP",
        HP_MESSAGE5 = "HP Auto-recovery",
        FREEZE_MESSAGE1 = "When Frozen, ATK & DEF DOWN!",
        FREEZE_MESSAGE2 = "froze! ATK & DEF DOWN!",
        POINT_MESSAGE = "+%d0000 pt",
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!.",
        telop3 = "The reward changes depending on the rankings results."
    },
    [600000069] = {
        CRT_MESSAGE_PARTS1 = "gave",
        CRT_MESSAGE_PARTS2 = "CRI HIT!",
        CRT_MESSAGE2 = "CRI HIT! Boss's Break gauge DOWN",
        HIT_MESSAGE1 = "CRI HIT",
        START_MESSAGE1 = "Negates Fire DMG",
        HP_MESSAGE1 = "ATK UP",
        HP_MESSAGE2 = "Evasion rate UP",
        HP_MESSAGE3 = "DMG UP",
        HP_MESSAGE4 = "ATK speed UP",
        HP_MESSAGE5 = "HP Auto-recovery",
        FREEZE_MESSAGE1 = "When Frozen, ATK & DEF DOWN!",
        FREEZE_MESSAGE2 = "froze! ATK & DEF DOWN!",
        POINT_MESSAGE = "+%d0000 pt",
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!.",
        telop3 = "The reward changes depending on the rankings results."
    },
    [600000074] = {
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG to the highest MAX HP UP",
        START_MESSAGE3 = "DMG taken DOWN during Arts",
        START_MESSAGE4 = "DMG DOWN during Blinded",
        RAGE_MESSAGE = "ATK speed, Accuracy, & CRI resistance UP",
        FURY_MESSAGE = "ATK speed, Evasion rate, & CRI rate UP",
        telop0 = "DMG from enemy increases when targeted.",
        telop1 = "When your unit falls, replace them and fight!.",
        telop2 = "The reward changes depending on the rankings results."
    },
    [600000075] = {
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG to the highest MAX HP UP",
        START_MESSAGE3 = "DMG taken DOWN during Arts",
        START_MESSAGE4 = "DMG DOWN during Blinded",
        RAGE_MESSAGE = "ATK speed, Accuracy, & CRI resistance UP",
        FURY_MESSAGE = "ATK speed, Evasion rate, & CRI rate UP",
        telop0 = "DMG from enemy increases when targeted.",
        telop1 = "When your unit falls, replace them and fight!.",
        telop2 = "The reward changes depending on the rankings results."
    },
    [600000076] = {
        START_MESSAGE1 = "Reflection, Arts gauge DOWN, & Light RES." ,
        START_MESSAGE2 = "DMG taken UP during Poisoned" ,
        START_MESSAGE3 = "Poison & Paralyze Boss simultaneously for bonus pts (max 5x)" ,
        SKILL7_MESSAGE1 = "DMG UP" ,
        SKILL7_MESSAGE2 = "Negates Blind resistance" ,
        SKILL8_MESSAGE1 = "DMG UP to units of most common Element",
        SKILL8_MESSAGE2 = "DMG negation canceled",
        POINT_MESSAGE1 = "300k pt bonus!",
        DOWN_MESSAGE1 = " Poisoned & Paralyzed the Boss! ATK DOWN!" ,
        telop2 = "When your unit falls, replace them and fight!" ,
        telop3 = "The reward changes with ranking results." ,
    },
    [600000077] = {
        START_MESSAGE1 = "Reflection, Arts gauge DOWN, & Light RES." ,
        START_MESSAGE2 = "DMG taken UP during Poisoned" ,
        START_MESSAGE3 = "Poison & Paralyze Boss simultaneously for bonus pts (max 5x)" ,
        SKILL7_MESSAGE1 = "DMG UP" ,
        SKILL7_MESSAGE2 = "Negates Blind resistance" ,
        SKILL8_MESSAGE1 = "DMG UP to units of most common Element",
        SKILL8_MESSAGE2 = "DMG negation canceled",
        POINT_MESSAGE1 = "1.5m pt bonus!",
        DOWN_MESSAGE1 = " Poisoned & Paralyzed the Boss! ATK DOWN!" ,
        telop2 = "When your unit falls, replace them and fight!" ,
        telop3 = "The reward changes with ranking results." ,
    },
    [600000078] = {
        ADVANCED_MESSAGE1 = "I don't care anymore. I'll crush everything.",
        ADVANCED_MESSAGE2 = "CRI resistance UP",
        ADVANCED_MESSAGE3 = "Poison, Desease, & Freeze RES. UP",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Dark resistance",
        START_MESSAGE3 = "DMG taken UP during Poisoning, Disease, & Freezing",
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "The reward changes with ranking results."
    },
    [600000079] = {
        ADVANCED_MESSAGE1 = "I don't care anymore. I'll crush everything.",
        ADVANCED_MESSAGE2 = "CRI resistance UP",
        ADVANCED_MESSAGE3 = "Poison, Desease, & Freeze RES. UP",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES",
        START_MESSAGE2 = "Dark resistance",
        START_MESSAGE3 = "DMG taken UP during Poisoning, Disease, & Freezing",
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "The reward changes with ranking results."
    },
    [600000080] = {
        LANDING_MESSAGE1 = "Fainted! Flying mode canceled!",
        LANDING_MESSAGE2 = "Paralized! Flying mode canceled!",
        LANDING_MESSAGE3 = "Frozen! Flying mode canceled!",
        SKILL3_MESSAGE1 = "Scorching wind!",
        START_MESSAGE1 = "Reflection, Life steal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG from Burning unit DOWN",
        TAKEOFF_MESSAGE1 = "Flying mode: Canceled by Faint, Paralysis, or Freeze",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "The reward changes with ranking results."
    },
    [600000081] = {
        LANDING_MESSAGE1 = "Fainted! Flying mode canceled!",
        LANDING_MESSAGE2 = "Paralized! Flying mode canceled!",
        LANDING_MESSAGE3 = "Frozen! Flying mode canceled!",
        SKILL3_MESSAGE1 = "Scorching wind!",
        START_MESSAGE1 = "Reflection, Life steal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG from Burning unit DOWN",
        TAKEOFF_MESSAGE1 = "Flying mode: Canceled by Faint, Paralysis, or Freeze",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "The reward changes with ranking results."
    },

    [100020904] = {
        ATTACK331 = "You'll regret if you don't stop me now!",
        ATTACK321 = "Can you stand this?",
        SKILL321 = "Ready for this?",
        SKILL341 = "Can you stand this?",
        UPDATE91 = "Accuracy rate & ATK UP",
        UPDATE92 = "CRI resistance UP",
        UPDATE11 = "Action speed UP",
        UPDATE81 = "Arts gauge fills at double speed",
        UPDATE21 = "DMG to enemy UP",
        UPDATE31 = "Bwahahaha! Now I'm fired up!",
        UPDATE312 = "DMG from enemy DOWN",
        UPDATE313 = "CRI rate UP",
        UPDATE41 = "CRI DMG UP",
        UPDATE51 = "Any last words?",
        UPDATE61 = "CRI DMG UP",
        UPDATE71 = "Hey, here's your souvenir!"
    },

    [100021002] = {
        DEAD_MESSAGE1 = "Alright, you pass... ",
        HP0_MESSAGE1 = "And you call yourself the Guildmaster? ",
        HP0_MESSAGE2 = "Shut your trap! ",
        HP0_MESSAGE3 = "Arts gauge & CRI DMG UP ",
        HP30_MESSAGE1 = "It ain't over 'til it's over. ",
        HP30_MESSAGE2 = "Arts gauge & Freeze resistance UP ",
        HP50_MESSAGE4 = "CRI rate UP to the units with 50% or less HP ",
        HP80_MESSAGE1 = "Now I'm warmed up! ",
        HP80_MESSAGE2 = "Arts gauge & Freeze resistance UP ",
        START_MESSAGE1 = "Show me what you got. ",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resistance ",
        START_MESSAGE3 = "DMG taken UP during Break or Freeze "
    },

    [2020231] = {
        START_MESSAGE1 = "DMG UP when Burning",
        HP70_MESSAGE1 = "DMG UP",
        HP20_MESSAGE1 = "Action speed UP"
    },

    [2020237] = {
        START_MESSAGE1 = "DMG UP when Burning",
        HP70_MESSAGE1 = "DMG UP",
        HP20_MESSAGE1 = "Action speed UP"
    },

    [2020243] = {
        START_MESSAGE1 = "DMG UP when Burning",
        HP70_MESSAGE1 = "DMG UP",
        HP20_MESSAGE1 = "Action speed UP"
    },

    [2020249] = {
        START_MESSAGE1 = "You survived for more than 1m30s!!",
        START_MESSAGE2 = "Negates Break",
        START_MESSAGE3 = "ATK & Accuracy rate UP",
        TIME_MESSAGE1 = "Survived for: %dm%ds",
        END_MESSAGE1 = "You survived %dm%ds!!",
        BOOST_MESSAGE1 = "ATK UP",
        BOOST_MESSAGE2 = "DMG UP",
        SPECIAL_ARTS_MESSAGE = "DMG UP ATK",
        SUMMON_MESSAGE = "Mikyu Mikyu!!",
        BORDER1_MESSAGE = "You couldn't survive 1m30s...",
        BORDER2_MESSAGE = "Your endurance level: Pearl",
        BORDER3_MESSAGE = "Your endurance level: Coral",
        BORDER4_MESSAGE = "Your endurance level: Obsidian",
        BORDER5_MESSAGE = "Your endurance level: Titanium",
        BORDER6_MESSAGE = "Your endurance level: Turquoise",
        BORDER7_MESSAGE = "Your endurance level: Garnet",
        BORDER8_MESSAGE = "Your endurance level: Amethyst",
        BORDER9_MESSAGE = "Your endurance level: Emerald",
        BORDER10_MESSAGE = "Your endurance level: Ruby",
        BORDER11_MESSAGE = "Your endurance level: Diamond"
    },

    [2016043] = {
        START_MESSAGE1 = "Skelton Soldier: Negates Magic DMG",
        START_MESSAGE2 = "Dead Spirit Warrior: DMG DOWN",
        RAGE_MESSAGE1 = "DMG UP to enemy",
        RAGE_MESSAGE2 = "Action speed UP"
    },

    [2016049] = {
        HP70_MESSAGE1 = "DMG UP",
        HP40_MESSAGE1 = "The path of demons starts here..."
    },

    [2016051] = {
        START_MESSAGE1 = "Dead Spirit Soldier: Negates all DMG (Except CRI)"
    },

    [2016052] = {
        START_MESSAGE1 = "Dead Spirit Soldier: Negates all DMG (Except CRI)"
    },

    [501441311] = {
        WAVE1_MESSAGE1 = "Mokyuon:Negates Physical DMG",
        WAVE1_MESSAGE2 = "Shield killer",
        WAVE1_MESSAGE3 = "Max DMG 9999",
        WAVE2_MESSAGE1 = "Alma:Negates Magic DMG",
        WAVE2_MESSAGE2 = "Mokyuon:Negates Physical DMG",
        WAVE2_MESSAGE3 = "Shield killer",
        WAVE2_MESSAGE4 = "Max DMG 9999"
    },
    [20163201] = {
        INIT_MESSAGE1 = "Max DMG 9999",
        HASTE1_MESSAGE1 = "Here I come!",
        HASTE1_MESSAGE2 = "Mokyuon:forward velocity UP",
        HASTE2_MESSAGE1 = "Alma:Negates Magic DMG",
        WAVE2_MESSAGE2 = "I can't lose to a Mokyuon!",
        HASTE2_MESSAGE1 = "Mokyuon:forward velocity UP",
        HPDOWN_MESSAGE1 = "MAX HP reduced"
    },


    [2016229] = {
        START_MESSAGE1 = "Attack Element changes every BREAK (Fire, Dark)",
        START_MESSAGE2 = "ATK & Accuracy rate UP"
    },
    [2016231] = {
        START_MESSAGE1 = "Attack Element changes every BREAK (Fire, Dark)",
        START_MESSAGE2 = "ATK & Accuracy rate UP"
    },
    [2016237] = {
        START_MESSAGE1 = "Attack Element changes every BREAK (Fire, Dark)",
        START_MESSAGE2 = "ATK & Accuracy rate UP"
    },
    [2016243] = {
        START_MESSAGE1 = "Attack Element changes every BREAK (Fire, Dark)",
        START_MESSAGE2 = "ATK & Accuracy rate UP",
        HP75_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "Action speed UP",
        HP25_MESSAGE1 = "DMG UP"
    },
    [2016249] = {
        START_MESSAGE1 = "Attack Element changes every BREAK (Fire, Dark)",
        START_MESSAGE2 = "ATK & Accuracy rate UP",
        HP75_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "Action speed UP",
        HP25_MESSAGE1 = "DMG UP"
    },
    [2016258] = {
        START_MESSAGE1 = "What a beautiful moon tonight...",
        HP70_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "DMG UP",
        HP30_MESSAGE1 = "I commend your efforts",
        DEAD_MESSAGE1 = "The moon... I can see the moon..."
    },
    [2016259] = {
        START_MESSAGE1 = "Honor my name, the name of the Demon Fox Ugetsu!",
        START_MESSAGE2 = "Attack Element changes every BREAK (Fire, Dark)",
        START_MESSAGE3 = "ATK & Accuracy rate UP",
        HP75_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "Action speed UP",
        HP25_MESSAGE1 = "DMG UP",
        HP10_MESSAGE1 = "I'll destroy you!"
    },

    [2016931] = {
        START_MESSAGE1 = "Arts gauge speed UP & Magic resistance UP",
        HP60_MESSAGE1 = "Arts gauge speed Down & DMG taken UP",
        HP30_MESSAGE1 = "Action speed UP"
    },
    [2016937] = {
        START_MESSAGE1 = "Arts gauge speed UP & Magic resistance UP",
        HP60_MESSAGE1 = "Arts gauge speed Down & DMG taken UP",
        HP30_MESSAGE1 = "Action speed UP"
    },
    [2016943] = {
        START_MESSAGE1 = "Arts gauge speed UP & Magic resistance UP",
        HP60_MESSAGE1 = "Arts gauge speed Down & DMG taken UP",
        HP30_MESSAGE1 = "Action speed UP"
    },
    [2016949] = {
        START_MESSAGE1 = "Roy: CRI resistance",
        START_MESSAGE2 = "Roy: CRI DMG UP",
        START_MESSAGE3 = "Roy: Break resistance",
        START_MESSAGE4 = "Roy: HP Auto-recovery",
        RAGE_MESSAGE1 = "Impregnable mode: DEF UP drastically",
        RAGE_MESSAGE2 = "Impregnable mode canceled during Break",
        BREAK_MESSAGE1 = "Impregnable mode canceled",
        ARTS_MESSAGE1 = "Azure God Supremacy Sword \"Barrier\" Stance",
        LAST_MESSAGE1 = "Roy: ATK UP",
        LAST_MESSAGE2 = "Roy: DMG UP"
    },
    [2016955] = {
        START_MESSAGE1 = "Roy: CRI resistance",
        START_MESSAGE2 = "Roy: CRI DMG UP",
        START_MESSAGE3 = "Roy: Break resistance",
        START_MESSAGE4 = "Roy: HP Auto-recovery",
        RAGE_MESSAGE1 = "Impregnable mode: DEF UP drastically",
        RAGE_MESSAGE2 = "Impregnable mode canceled during Break",
        BREAK_MESSAGE1 = "Impregnable mode canceled",
        ARTS_MESSAGE1 = "Azure God Supremacy Sword \"Barrier\" Stance",
        LAST_MESSAGE1 = "Roy: ATK UP",
        LAST_MESSAGE2 = "Roy: DMG UP"
    },
    [2016956] = {
        START_MESSAGE1 = "Rayas: Gods & Demons Killer",
    },
    [2016957] = {
        START_MESSAGE1 = "Roy: CRI resistance",
        START_MESSAGE2 = "Roy: CRI DMG UP",
        START_MESSAGE3 = "Roy: Break resistance",
        START_MESSAGE4 = "Roy: HP Auto-recovery",
        RAGE_MESSAGE1 = "Impregnable mode: DEF UP drastically",
        RAGE_MESSAGE2 = "Impregnable mode canceled during Break",
        BREAK_MESSAGE1 = "Impregnable mode canceled",
        ARTS_MESSAGE1 = "Azure God Supremacy Sword \"Barrier\" Stance",
        LAST_MESSAGE1 = "Roy: ATK UP",
        LAST_MESSAGE2 = "Roy: DMG UP"
    },


    [2018131] = {
        START_MESSAGE1 = "Magic RES UP & Physical RES DOWN",
        START_MESSAGE2 = "Negates Critical DMG",
        HP70_MESSAGE1 = "Action Speed UP",
        HP50_MESSAGE1 = "DMG UP",
        HP30_MESSAGE1 = "Action Speed UP"
    },
    [2018137] = {
        START_MESSAGE1 = "Magic RES UP & Physical RES DOWN",
        START_MESSAGE2 = "Negates Critical DMG",
        HP70_MESSAGE1 = "Action Speed UP",
        HP50_MESSAGE1 = "DMG UP",
        HP30_MESSAGE1 = "Action Speed UP"
    },
    [2018143] = {
        START_MESSAGE1 = "Magic RES UP & Physical RES DOWN",
        START_MESSAGE2 = "Negates Critical DMG & Status Ailments",
        HP70_MESSAGE1 = "Action Speed UP",
        HP50_MESSAGE1 = "DMG UP",
        HP30_MESSAGE1 = "Action Speed UP"
    },

    [2018149] = {
        RESULT_MESSAGE1 = "Total",
        RESULT_MESSAGE2 = "DMG!!!",
        RESULT_MESSAGE3 = "Last blow DMG:",
        DAMAGE_MESSAGE1 = "%d0000",
        DAMAGE_MESSAGE2 = "%d00000000",
        DAMAGE_MESSAGE3 = "DMG!!!",
        DAMAGE_MESSAGE4 = "With one blow!",
        DAMAGE_MESSAGE5 = "DMG!!!",
        LOSE_MESSAGE1 = "You couldn't reach 3000000 DMG!",
        LOSE_MESSAGE2 = "Arts gauge fills at double speed",
        START_MESSAGE4 = "You cleared 30000000 DMG within 120s!",
        START_MESSAGE5 = "Negates Magic DMG"
    },

    [2018429] = {
        START_MESSAGE1 = "Phys resist UP and Magic resist DOWN!",
        START_MESSAGE2 = "If Frozen, Magic resist DOWN!",
        HP_MESSAGE1 = "Action Speed UP!",
        HP_MESSAGE2 = "If Burning, CRI RATE UP!",
        HP_MESSAGE3 = "DMG UP!",
        HP_MESSAGE4 = "CRI DMG UP!",
        FREEZE_MESSAGE1 = "When Frozen, Magic resist DOWN!",
        FREEZE_MESSAGE2 = "froze! Attack DMG and Defense DOWN!"
    },

    [2018431] = {
        START_MESSAGE1 = "Phys resist UP and Magic resist DOWN!",
        START_MESSAGE2 = "If Frozen, Magic resist DOWN!",
        HP_MESSAGE1 = "Action Speed UP!",
        HP_MESSAGE2 = "If Burning, CRI RATE UP!",
        HP_MESSAGE3 = "DMG UP!",
        HP_MESSAGE4 = "CRI DMG UP!",
        FREEZE_MESSAGE1 = "When Frozen, Magic resist DOWN!",
        FREEZE_MESSAGE2 = "froze! Attack DMG and Defense DOWN!"
    },

    [2018437] = {
        START_MESSAGE1 = "Phys resist UP and Magic resist DOWN!",
        START_MESSAGE2 = "If Frozen, Magic resist DOWN!",
        HP_MESSAGE1 = "Action Speed UP!",
        HP_MESSAGE2 = "If Burning, CRI RATE UP!",
        HP_MESSAGE3 = "DMG UP!",
        HP_MESSAGE4 = "CRI DMG UP!",
        FREEZE_MESSAGE1 = "When Frozen, Magic resist DOWN!",
        FREEZE_MESSAGE2 = "froze! Attack DMG and Defense DOWN!"
    },

    [2018443] = {
        START_MESSAGE1 = "Phys resist UP and Magic resist DOWN!",
        START_MESSAGE2 = "If Frozen, Magic resist DOWN!",
        HP_MESSAGE1 = "Action Speed UP!",
        HP_MESSAGE2 = "If Burning, CRI RATE UP!",
        HP_MESSAGE3 = "DMG UP!",
        HP_MESSAGE4 = "CRI DMG UP!",
        FREEZE_MESSAGE1 = "When Frozen, Magic resist DOWN!",
        FREEZE_MESSAGE2 = "froze! Attack DMG and Defense DOWN!"
    },

    [2018449] = {
        START_MESSAGE1 = "The party begins, Cygnet.",
        START_MESSAGE2 = "Liza, be on your guard.",
        START_MESSAGE3 = "Cygnet: CRI rate UP!",
        HP70_MESSAGE1 = "Liza: Arts gauge fills at double speed",
        HP70_MESSAGE2 = "Cygnet: CRI rate UP!",
        HP60_MESSAGE1 = "Cygnet! Crank it up!",
        HP60_MESSAGE2 = "Zee, you are quite a slave driver.",
        HP50_MESSAGE1 = "Cygnet: CRI rate UP!",
        HP40_MESSAGE1 = "Ace in the hole... Let's do it.",
        HP40_MESSAGE2 = "Understood!",
        HP30_MESSAGE1 = "Liza & Cygnet: Arts gauge fills at double speed",
        HP30_MESSAGE2 = "Cygnet: CRI rate UP!",
        DEAD_MESSAGE1 = "No... Cygnet? Noooooooooooooo!!"
    },
    [2018450] = {
        DEAD_MESSAGE1 = "You'll remember this...!!!"
    },

    [2018931] = {
        START_MESSAGE1 = "When break Dark resist UP",
        HP70_MESSAGE1 = "Hmph, let's round them up men...",
        HP70_MESSAGE2 = "Hahah! The main performance has begun...!?",
        HP70_MESSAGE3 = "Evasion rate UP",
        HP50_MESSAGE1 = "DMG UP!",
        HP30_MESSAGE1 = "Arts gauge fills at double speed"
    },
    [2018949] = {
        HP70_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "That's all you got?",
        HP30_MESSAGE1 = "DMG UP!"
    },

    [2018937] = {
        START_MESSAGE1 = "When break Dark resist UP",
        HP70_MESSAGE1 = "Hmph, let's round them up men...",
        HP70_MESSAGE2 = "Hahah! The main performance has begun...!?",
        HP70_MESSAGE3 = "Evasion rate UP",
        HP50_MESSAGE1 = "DMG UP!",
        HP30_MESSAGE1 = "Arts gauge fills at double speed"
    },

    [2018943] = {
        START_MESSAGE1 = "When break Dark resist UP",
        HP70_MESSAGE1 = "Hmph, let's round them up men...",
        HP70_MESSAGE2 = "Hahah! The main performance has begun...!?",
        HP70_MESSAGE3 = "Evasion rate UP",
        HP50_MESSAGE1 = "DMG UP!",
        HP30_MESSAGE1 = "Arts gauge fills at double speed"
    },


    [2019431] = {
        START_MESSAGE1 = "It's settled... you're all done for!",
        HP50_MESSAGE1 = "DMG BOOSTED!",
        HP50_MESSAGE2 = "There's no return from here onwards!",
        HP20_MESSAGE1 = "Here I come! You think you can hold up?",
        HP20_MESSAGE2 = "Arts gauge fills at double speed"
    },

    [2019437] = {
        START_MESSAGE1 = "It's settled... you're all done for!",
        HP50_MESSAGE1 = "DMG BOOSTED!",
        HP50_MESSAGE2 = "There's no return from here onwards!",
        HP20_MESSAGE1 = "Here I come! You think you can hold up?",
        HP20_MESSAGE2 = "Arts gauge fills at double speed"
    },

    [2019443] = {
        START_MESSAGE1 = "It's settled... you're all done for!",
        HP50_MESSAGE1 = "DMG BOOSTED!",
        HP50_MESSAGE2 = "There's no return from here onwards!",
        HP20_MESSAGE1 = "Here I come! You think you can hold up?",
        HP20_MESSAGE2 = "Arts gauge fills at double speed"
    },

    [2019449] = {
        HPFLG_MESSAGE1 = "Come at me with everything you got.",
        HPFLG_MESSAGE2 = "There's no stopping this blow of mine. ",
        HPFLG_MESSAGE3 = "I'll show you the power of the rightful ruler of Light!"
    },

    [2019301] = {
        START_MESSAGE1 = "Let me see if you truly have what it is to be a king",
        START_MESSAGE2 = "Water killer & Negates Water DMG",
        START_MESSAGE3 = "Negates Critical DMG & Guard killer",
        START_MESSAGE4 = "ATK BOOSTED upon Arts or True Arts activation ",
        HP80_MESSAGE1 = "Action speed & DEF BOOSTED!",
        HP70_MESSAGE1 = "Arts gauge filling speed & DEF BOOSTED!",
        HP50_MESSAGE1 = "Witness the power of a Dragon's pride",
        HP50_MESSAGE2 = "DEF BOOSTED!",
        HP30_MESSAGE1 = "My scales are steel, never to break",
        HP30_MESSAGE2 = "Arts gauge filling speed & DEF BOOSTED!",
        HP30_MESSAGE3 = "HP Auto-recovery",
        HP1_MESSAGE1 = "Show me your will and what makes you king"
    },
    [2019305] = {
        START_MESSAGE1 = "Let me see if you truly have what it is to be a king",
        START_MESSAGE2 = "Water killer & Negates Water DMG",
        START_MESSAGE3 = "Negates Critical DMG & Guard killer",
        START_MESSAGE4 = "ATK BOOSTED upon Arts or True Arts activation ",
        HP80_MESSAGE1 = "Action speed & DEF BOOSTED!",
        HP70_MESSAGE1 = "Arts gauge filling speed & DEF BOOSTED!",
        HP50_MESSAGE1 = "Witness the power of a Dragon's pride",
        HP50_MESSAGE2 = "DEF BOOSTED!",
        HP30_MESSAGE1 = "My scales are steel, never to break",
        HP30_MESSAGE2 = "Arts gauge filling speed & DEF BOOSTED!",
        HP30_MESSAGE3 = "HP Auto-recovery",
        HP1_MESSAGE1 = "Show me your will and what makes you king"
    },

    [2019531] ={
        START_MESSAGE1 = "Burning: ATK UP・DMG Taken UP",
        START_MESSAGE2 = "Burn resistance UP",
        HP70_MESSAGE1 = "Action speed BOOSTED!",
        HP50_MESSAGE1 = "Degilmagna's wrath sets the surroundings ablaze",
        HP50_MESSAGE2 = "All attacks apply Burning and increase Arts gauge",
        HP30_MESSAGE1 = "DMG UP"
    },
    [2019537] ={
        START_MESSAGE1 = "Burning: ATK UP・DMG Taken UP",
        START_MESSAGE2 = "Burn resistance UP",
        HP70_MESSAGE1 = "Action speed BOOSTED!",
        HP50_MESSAGE1 = "Degilmagna's wrath sets the surroundings ablaze",
        HP50_MESSAGE2 = "All attacks apply Burning and increase Arts gauge",
        HP30_MESSAGE1 = "DMG UP"
    },
    [2019543] ={
        START_MESSAGE1 = "Burning: ATK UP・DMG Taken UP",
        START_MESSAGE2 = "Burn resistance UP",
        HP70_MESSAGE1 = "Action speed BOOSTED!",
        HP50_MESSAGE1 = "Degilmagna's wrath sets the surroundings ablaze",
        HP50_MESSAGE2 = "All attacks apply Burning and increase Arts gauge",
        HP30_MESSAGE1 = "DMG UP"
    },

    [2019549] = {
        HP100_MESSAGE1 = "Accuracy UP",
        HP100_MESSAGE2 = "CRI DMG UP to Blinded ",
        HP80_MESSAGE1 = "Action speed BOOSTED!",
        HP60_MESSAGE1 = "DMG UP",
        HP60_MESSAGE2 = "Arts gauge fills at double speed.",
        HP40_MESSAGE1 = "DMG UP",
        HP40_MESSAGE2 = "Reduce Arts gauge on ATK",
        HP20_MESSAGE1 = "Action speed BOOSTED!",
        HP20_MESSAGE2 = "Arts gauge fills at double speed."
    },

    [2019554] = {
        START_MESSAGE1 = "Tap to Jump!",
        START_MESSAGE2 = "Tap & hold to Jump higher!"
    },

    [2020266] = {
        HP50_MESSAGE1 = "Fitoria: I'll heal your wounds." ,
        HP20_MESSAGE1 = "Fitoria: I won't let you interfere." ,
    },
    [2020267] = {
        START_MESSAGE1 = "Reflection Arts gauge DOWN resistance" ,
        START_MESSAGE2 = "Filo: Dragon killer & DMG taken UP during Break" ,
        START_MESSAGE3 = "Fitoria: CRI resistance" ,
        BLAKE_MESSAGE1 = "Break! DMG taken UP!!" ,
        HP60_MESSAGE1 = "Fitoria: Hold still." ,
        HP60_MESSAGE2 = "Filo: I'm tougher now!" ,
        HP20_MESSAGE1 = "Filo: High Quick!" ,
        DEAD_MESSAGE1 = "Fitoria: Fall back." ,
    },

    [2021331] = {
        START_MESSAGE1 = "Let's get this over with!",
        START_MESSAGE2 = "Bring it on!"
    },

    [2021337] = {
        START_MESSAGE1 = "This is the power of the Black Dragon!",
        START_MESSAGE2 = "I'll make it easy for you"
    },

    [2021338] = {
        START_MESSAGE1 = "I can't stand just sitting around",
        START_MESSAGE2 = "Come on, let's do this!"
    },

    [2021343] = {
        START_MESSAGE1 = "Fear my Jagan Eye!",
        START_MESSAGE2 = "Roses still bloom from a villain's blood"
    },

    [2021344] = {
        START_MESSAGE1 = "Give it a go!",
        START_MESSAGE2 = "Come at me anytime!"
    },


    [2023031] = {
        START_MESSAGE1 = "Let's get started!",
        HP70_MESSAGE1 = "Enshroud this forest, Crimson Blood!",
        HP70_MESSAGE2 = "ATK, DEF & EVA UP",
        HP30_MESSAGE1 = "Feel the wrath of my blood!",
        HP0_MESSAGE1 = "You're strong, aren't you?"
    },

    [2023037] = {
        START_MESSAGE1 = "Negates \"Nageting DMG\"",
        START_MESSAGE2 = "Targeting low HP units",
        HAND_MESSAGE1 = "Force into big hands",
        RAGE_MESSAGE1 = "ATK & Action Speed UP"
    },

    [2023043] = {
        START_MESSAGE1 = "Negates \"Nageting DMG\"",
        START_MESSAGE2 = "Targeting low HP units",
        HAND_MESSAGE1 = "Force into big hands",
        RAGE_MESSAGE1 = "ATK & Action Speed UP"
    },

    [2023049] = {
        START_MESSAGE1 = "Negates \"Nageting DMG\"",
        START_MESSAGE2 = "Targeting low HP units",
        HAND_MESSAGE1 = "Force into big hands",
        RAGE_MESSAGE1 = "ATK & Action Speed UP"
    },

    [2023061] = {
        START_MESSAGE1 = "Negates \"Nageting DMG\"",
        START_MESSAGE2 = "Targeting low HP units",
        HAND_MESSAGE1 = "Force into big hands",
        RAGE_MESSAGE1 = "ATK & Action Speed UP"
    },

    [2025449] = {
        START_MESSAGE1 = "Recovers from Blind & Arts gauge UP"
    },

    [2025461] = {
        START_MESSAGE1 = "Recovers from Blind & Arts gauge UP"
    },

    [2025437] = {
        START_MESSAGE1 = "I feel like showing off today!",
        START_MESSAGE2 = "Enshroud this forest, Crimson Blood!",
        HP50_MESSAGE = "Feel the wrath of my blood",
        HP20_MESSAGE = "Oh no, I messed up!",
        DEAD_MESSAGE = "I won't go down so easy next time!"
    },
    [2025443] = {
        START_MESSAGE1 = "I feel like showing off today!",
        START_MESSAGE2 = "Enshroud this forest, Crimson Blood!",
        HP50_MESSAGE = "Feel the wrath of my blood",
        HP20_MESSAGE = "Oh no, I messed up!",
        DEAD_MESSAGE = "I won't go down so easy next time!"
    },

    [2025842] = {
        START_MESSAGE = "Reduces DMG taken from Light units",
        HP50_MESSAGE = "See how ya like this!",
        HP30_MESSAGE = "I'mma chew you up good!"
    },
    [2025854] = {
        START_MESSAGE = "Reduces DMG taken from Light units",
        HP50_MESSAGE = "See how ya like this!",
        HP30_MESSAGE = "I'mma chew you up good!"
    },
    [2025829] = {
        START_MESSAGE = "Reduces DMG taken from Light units",
        HP50_MESSAGE = "Shield!",
        HP30_MESSAGE = "ATK UP"
    },
    [2025830] = {
        START_MESSAGE1 = "Evidence is everything! Prove yourself!",
        HP50_MESSAGE1 = "Time to use my trump card!",
        HP0_MESSAGE1 = "I'm sorry, Granny..."
    },
    [2025836] = {
        START_MESSAGE1 = "Evidence is everything! Prove yourself!",
        HP50_MESSAGE1 = "Time to use my trump card!",
        HP0_MESSAGE1 = "I'm sorry, Granny..."
    },

    [2021349] = {
        START_MESSAGE1 = "I'm looking forward to it...",
        START_MESSAGE2 = "Unbreakable Mode: most DMG DOWN",
        START_MESSAGE3 = "Unbreakable Mode CANCELED with BREAK",
        HP60_MESSAGE1 = "REAL power goes beyond talent!",
        HP60_MESSAGE2 = "ATK & DMG UP to enemy",
        HP30_MESSAGE1 = "You're no match for me!",
        HP30_MESSAGE2 = "Accuracy rate & DEF UP",
        BREAK_MESSAGE1 = "Well...",
        BREAK_MESSAGE2 = "Unbreakable Mode CANCELED"
    },

    [2025231] = {
        START_MESSAGE = "Don't let down your guard, Roy",
        START_MESSAGE2 = "Heh...Right back at you",
        HP50_MESSAGE = "It's time for the counterattack!",
        DEAD_MESSAGE = "Not too shabby..."
    },
    [2025232] = {
        HP50_MESSAGE = "Don't get ahead of yourselves",
        DEAD_MESSAGE = "Unbelievable..."
    },
    [2025235] = {
        START_MESSAGE1 = "DMG UP to Boss during BREAK"
    },
    [2025238] = {
        START_MESSAGE1 = "DMG UP to Boss during BREAK"
    },
    [2025243] = {
        START_MESSAGE1 = "I hear the sound of your souls...",
        START_MESSAGE2 = "If Blind, CRI rate UP",
        START_MESSAGE3 = "Fire & Light resist",
        HP70_MESSAGE1 = "Fear my Scythe...",
        HP50_MESSAGE1 = "Crush...",
        HP10_MESSAGE1 = "Everything fall to ruin..."
    },

    [2025249] = {
        START_MESSAGE1 = "I hear the sound of your souls...",
        START_MESSAGE2 = "If Blind, CRI rate UP",
        START_MESSAGE3 = "Fire & Light resist",
        HP70_MESSAGE1 = "Fear my Scythe...",
        HP50_MESSAGE1 = "Crush...",
        HP10_MESSAGE1 = "Everything fall to ruin..."
    },
    [2004337] = {
        START_MESSAGE1 = "Break resistance & Evasion rate UP",
        START_MESSAGE2 = "When Burning, Break resistance & Evasion rate DOWN",
        START_MESSAGE3 = "CRI resistance"
    },
    [2004434] = {
        START_MESSAGE1 = "Break resistance & Evasion rate UP",
        START_MESSAGE2 = "When Frozen, Break resistance & Evasion rate DOWN"
    },
    [2004534] = {
        START_MESSAGE1 = "Break resistance & Evasion rate UP",
        START_MESSAGE2 = "When Poisoned, Break resistance & Evasion rate DOWN",
        START_MESSAGE3 = "Negate DMG end"
    },

    [2005435] = {
        HP50_MESSAGE1 = "Break resistance",
        HP50_MESSAGE2 = "Reduces DMG"
    },

    [2005535] = {
        mess1 = "Action Speed UP",
        mess2 = "ATK UP"
    },

    [2028230] = {
        START_MESSAGE1 = "Now it's my turn.",
        HP50_MESSAGE = "I'm just getting warmed up.",
        DEAD_MESSAGE ="Yikes..."
    },
    [2028236] = {
        START_MESSAGE1 = "C'mon, let's start already!",
        START_MESSAGE2 = "Earth Resistance",
        START_MESSAGE3 = "Light Resistance",
        HP50_MESSAGE = "You haven't seen anything yet.",
        DEAD_MESSAGE ="This isn't fun anymore."
    },
    [2028242] = {
        START_MESSAGE1 = "Now it's my turn.",
        START_MESSAGE2 = "C'mon, let's start already!",
        START_MESSAGE3 = "You can count on me!",
        HP50_MESSAGE1 = "Time to get serious.",
        DEAD_MESSAGE1 ="I used too many magicules..."
    },
    [2028243] = {
        START_MESSAGE1 = "C'mon, let's start already!",
        HP50_MESSAGE1 = "You haven't seen anything yet.",
        DEAD_MESSAGE1 ="This isn't fun anymore."
    },
    [2028244] = {
        START_MESSAGE1 = "You can count on me!",
        HP50_MESSAGE1 = "Take this!",
        DEAD_MESSAGE1 ="Lord Rimuru..."
    },
    [2028254] = {
        START_MESSAGE1 = "Now it's my turn.",
        START_MESSAGE2 = "C'mon, let's start already!",
        START_MESSAGE3 = "You can count on me!",
        HP50_MESSAGE1 = "I'm just getting warmed up.",
        HP30_MESSAGE1 = "I've been saving this one.",
        HP30_MESSAGE2 = "Rimuru's ATK Up",
        DEAD_MESSAGE1 ="I used too many magicules..."
    },
    [2028255] = {
        START_MESSAGE1 = "C'mon, let's start already!",
        HP50_MESSAGE1 = "You haven't seen anything yet.",
        DEAD_MESSAGE1 ="This isn't fun anymore."
    },
    [2028256] = {
        START_MESSAGE1 = "You can count on me!",
        HP50_MESSAGE1 = "Take this!",
        DEAD_MESSAGE1 ="Lord Rimuru..."
    },
    [2028293] = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN Res",
        START_MESSAGE2 = "Light & Shield Killer",
        CHARGE_MESSAGE1 = "Shadow Lightning Stance",
        CHARGE_MESSAGE2 = "Takes more damage, becomes less force",
        SUB_HP0_MESSAGE1 = "Canceling Shadow Lightning with damage!"
    },

    [4000714] = {
        START_MESSAGE1 = "Go get 'em!"
    },
    [4000724] = {
        START_MESSAGE1 = "Go get 'em!"
    },
    [4000734] = {
        START_MESSAGE1 = "Go get 'em!"
    },
    [4000744] = {
        START_MESSAGE1 = "Go get 'em!"
    },
    [2020631] = {
        START_MESSAGE1 = "Bow your heads and repent!",
        HP50_MESSAGE1 = "Hate, hate, hate, hate, haaaaaaate!",
        HP20_MESSAGE1 = "Action speed UP"
    },
    [2020637] = {
        START_MESSAGE1 = "When Burning, DMG & Action speed UP",
        START_MESSAGE2 = "When Burning, HP Auto-recovery",
        HP75_MESSAGE1 = "DMG UP",
        HP50_MESSAGE1 = "Arts Gauge Speed UP",
        HP25_MESSAGE1 = "HP regen amount UP",
        FREEZE_MESSAGE1 = "When Freezing, ATK & DEF DOWN!"
    },
    [2020643] = {
        START_MESSAGE1 = "When Burning, DMG & Action speed UP",
        START_MESSAGE2 = "When Burning, HP Auto-recovery",
        HP75_MESSAGE1 = "DMG UP",
        HP50_MESSAGE1 = "Arts Gauge Speed UP",
        HP25_MESSAGE1 = "HP regen amount UP",
        FREEZE_MESSAGE1 = "When Freezing, ATK & DEF DOWN!"
    },
    [2020649] = {
        START_MESSAGE1 = "When Burning, DMG & Action speed UP",
        START_MESSAGE2 = "When Burning, HP Auto-recovery",
        HP75_MESSAGE1 = "DMG UP",
        HP50_MESSAGE1 = "Arts Gauge Speed UP",
        HP25_MESSAGE1 = "HP regen amount UP",
        FREEZE_MESSAGE1 = "When Freezing, ATK & DEF DOWN!"
    },
    [2020661] = {
        START_MESSAGE1 = "When Burning, DMG & Action speed UP",
        START_MESSAGE2 = "When Burning, HP Auto-recovery",
        HP75_MESSAGE1 = "DMG & HP regen amount UP",
        HP50_MESSAGE1 = "Arts Gauge Speed UP & HP regen amount UP",
        HP25_MESSAGE1 = "HP regen amount UP",
        FREEZE_MESSAGE1 = "When Freezing, ATK & DEF DOWN!"
    },
    [2004440] = {
        START_MESSAGE1 = "Recovers DMG taken",
        START_MESSAGE2 = "CRI DMG UP",
        START_MESSAGE3 = "ATK & Accuracy UP",
        HP80_MESSAGE1 = "Action speed UP",
        HP60_MESSAGE1 = "DMG UP",
        HP40_MESSAGE1 = "Evasion rate UP",
        HP20_MESSAGE1 = "Arts gauge up SPD ＆ Disease escape % UP",
        TIMEUP_MESSAGE1 = "DMG & ATK UP",
        TIMEUP_MESSAGE2 = "Allies' DMG taken UP"
    },
    [2004538] = {
        START_MESSAGE1 = "ATK UP",
        HP80_MESSAGE = "DMG UP",
        HP60_MESSAGE = "Recovery amount UP",
        HP40_MESSAGE = "Action speed UP",
        HP20_MESSAGE = "Arts gauge fills at double speed",
        TIMEUP_MESSAGE1 = "DMG & ATK UP",
        TIMEUP_MESSAGE2 = "Allies' DMG taken UP"
    },

    [2020731] = {
        START_MESSAGE1 = "Gahaha! Looks like this isn't your day!",
        HP50_MESSAGE1 = "I'm hungry... Let me taste your screams!",
        HP20_MESSAGE1 = "Not yet... Playtime is far from over!",
        HP20_MESSAGE2 = "Action speed UP"
    },
    [2020737] = {
        START_MESSAGE1 = "Light resist & Light Killer",
        HP70_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "Arts gauge fills at double speed",
        HP25_MESSAGE1 = "DMG UP"
    },
    [2020743] = {
        START_MESSAGE1 = "Light resist & Light Killer",
        HP70_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "Arts gauge fills at double speed",
        HP25_MESSAGE1 = "DMG UP"
    },
    [2020749] = {
        START_MESSAGE1 = "Light resist & Light Killer",
        HP70_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "Arts gauge fills at double speed",
        HP25_MESSAGE1 = "DMG UP"
    },
    [2020761] = {
        START_MESSAGE1 = "Light resist & Light Killer",
        HP70_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "Arts gauge fills at double speed",
        HP25_MESSAGE1 = "DMG & Faint resistance UP"
    },
    [2028430] = {
        START_MESSAGE1 = "I'll give you a taste of my true skill.",
        HP50_MESSAGE = "Watch closely now.",
        DEAD_MESSAGE ="This is it, huh...?"
    },
    [2028436] = {
        START_MESSAGE1 = "You really want to fight me?!",
        HP50_MESSAGE = "Time for some punishment!",
        DEAD_MESSAGE ="I'm sleepy..."
    },
    [2028442] = {
        START_MESSAGE1 = "I'll give you a taste of my true skill.",
        START_MESSAGE2 = "You really want to fight me?!",
        START_MESSAGE3 = "DMG DOWN for non-Demons until Break",
        START_MESSAGE4 = "2x DMG for Boss during Break",
        BREAK_MESSAGE1 = "Clear Reduced DMG",
        HP50_MESSAGE = "Watch closely now.",
        DEAD_MESSAGE ="This is it, huh...?"
    },
    [2028444] = {
        HP50_MESSAGE = "Time for some punishment!",
        DEAD_MESSAGE ="I'm sleepy..."
    },
    [2028454] = {
        START_MESSAGE1 = "I'll give you a taste of my true skill.",
        START_MESSAGE2 = "You really want to fight me?!",
        START_MESSAGE3 = "DMG DOWN for non-Demons until Break",
        START_MESSAGE4 = "2x DMG for Boss during Break",
        START_MESSAGE5 = "Increases damage over time",
        BREAK_MESSAGE1 = "Clear Reduced DMG",
        HP50_MESSAGE1 = "Watch closely now.",
        DEAD_MESSAGE1 ="This is it, huh...?"
    },
    [2028455] = {
        HP50_MESSAGE1 = "Time for some punishment!",
        DEAD_MESSAGE1 ="I'm sleepy..."
    },
    [2028456] = {
        HP50_MESSAGE1 = "Your courage is praiseworthy.",
        DEAD_MESSAGE1 ="If I just had more power..."
    },

    [2021731] = {
        START_MESSAGE1 = "Who shall I destroy?",
        HP50_MESSAGE1 = "Now, let me hear your screams.",
        HP0_MESSAGE1 = "I bid you good day♪"
    },
    [2021737] = {
        HP70_MESSAGE1 = "DEF UP",
        HP50_MESSAGE1 = "ATK speed UP",
        HP30_MESSAGE1 = "ATK UP"
    },
    [2021743] = {
        HP70_MESSAGE1 = "DEF UP",
        HP50_MESSAGE1 = "ATK speed UP",
        HP30_MESSAGE1 = "ATK UP"
    },
    [2021749] = {
        HP70_MESSAGE1 = "DEF UP",
        HP50_MESSAGE1 = "ATK speed UP",
        HP30_MESSAGE1 = "ATK UP"
    },
    [2021761] = {
        HP70_MESSAGE1 = "DEF UP",
        HP50_MESSAGE1 = "ATK speed UP",
        HP50_MESSAGE2 = "ATK UP",
        HP30_MESSAGE1 = "ATK UP"
    },

    [2028493] = {
        START_MESSAGE1 = "Auto-reduces Blinded units' HP",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN RES."
    },

    [2029530] = {
        START_MESSAGE1 = "When we're together...",
        START_MESSAGE2 = "We've nothing to fear!",
        HP50_MESSAGE1 = "I'll show you my true spirit!",
        DEAD_MESSAGE1 = "Your Majesty! I've failed yoooou!"
    },
    [2029531] = {
        HP50_MESSAGE1 = "I see I must rely on my special technique!",
        DEAD_MESSAGE1 = "How dare you harm my friend?!"
    },
    [2029536] = {
        START_MESSAGE1 = "Feel the rhythm!",
        HP50_MESSAGE1 = "Sing along now!",
        DEAD_MESSAGE1 = "See you next show!"
    },
    [2029542] = {
        START_MESSAGE1 = "Let's have fun!",
        HP50_MESSAGE1 = "Listen with your heart...",
        DEAD_MESSAGE1 = "Until next time, everyone!"
    },
    [2029548] = {
        START_MESSAGE1 = "DMG from Boss x1.5 during Blind",
        START_MESSAGE2 = "Water & Earth DMG UP"
    },
    [2029553] = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG taken from Machines UP",
        START_MESSAGE3 = "DMG taken UP during Status Ailment",
        START_MESSAGE4 = "More Break Higher DMG",
        BREAK_MESSAGE1 = "Entering Break! DMG taken UP!",
        BREAK_END_MESSAGE1 = "Break resistance UP",
        HP50_MESSAGE1 = "Evasion rate UP",
        HP20_MESSAGE1 = "ATK speed UP"
    },
    [2005436] = {
        START_MESSAGE1 = "Negates Paralyze, Freeze & Seal",
        START_MESSAGE2 = "DMG taken UP when Status Ailment",
        HP30_MESSAGE1 = "Action speed UP"
    },

    [2029554] = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG taken UP when Burning",
        START_MESSAGE3 = "More Crimson Knight Mirzas, the less DMG taken",
        START_MESSAGE4 = "Crimson Knight Mirza：Negates Fire DMG & Evasion rate UP",
        SUMMON_MESSAGE1 = "I shall protect you.",
        HP60_MESSAGE1 = "Your hideousness is stunning...",
        HP40_MESSAGE1 = "Feel the grip of despair...",
        HP20_MESSAGE1 = "Get away from me!",
        HP20_MESSAGE2 = "Arts gauge fills even FASTER!",
        DEAD_MESSAGE1 = "Outrageous..."
    },
    [2029556] = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG Negation Killer",
        START_MESSAGE3 = "Takes Less DMG during Arts",
        SKILL8_MESSAGE1 = "Arts gauge fills FASTER!"
    },

    [2029592] = {
        START_MESSAGE1 = "DMG taken UP from Water unit",
        START_MESSAGE2 = "DEF DOWN by HIT count",
        START_MESSAGE3 = "Negates CRI & Reflection DMG",
        START_MESSAGE4 = "DMG increases with duration"
    },

    [2029830] = {
        START_MESSAGE1 = "OK, I'm all warmed up!",
        HP50_MESSAGE1 = "Concentrate...",
        DEAD_MESSAGE1 = "I'm sorry...Hart..."
    },
    [2029836] = {
        START_MESSAGE1 = "OK, I'm all warmed up!",
        HP50_MESSAGE1 = "Concentrate...",
        DEAD_MESSAGE1 = "I'm sorry...Hart..."
    },
    [2029842] = {
        START_MESSAGE1 = "Fire DMG UP",
        START_MESSAGE2 = "Boss' ATK & DMG taken UP by # of inflicted Burning",
        BURN_MESSAGE1 = "ATK & DMG taken UP"
    },
    [2029854] = {
        START_MESSAGE1 = "Fire DMG UP",
        START_MESSAGE2 = "Boss' ATK & DMG taken UP by # of inflicted Burning",
        TRIGGER_MESSAGE1 = "CRI DMG taken UP",
        BURN_MESSAGE1 = "ATK & DMG taken UP"
    },

    [2030130] = {
        DEAD_MESSAGE1 = "This can't be real...",
        HP50_MESSAGE1 = "You'll pay with your life.",
        START_MESSAGE1 = "Have you said your prayers?"
    },
    [2030136] = {
        DEAD_MESSAGE1 = "This can't be real...",
        HP50_MESSAGE1 = "Beg for forgiveness.",
        START_MESSAGE1 = "Have you said your prayers?"
    },
    [2030142] = {
        START_MESSAGE1 = "Evasion rate UP"
    },
    [2030154] = {
        START_MESSAGE1 = "Reflection, Arts gauge DOWN & CRI resistance",
        START_MESSAGE2 = "Evasion rate UP & Light Killer",
        START_MESSAGE3 = "DEF UP every time Arts is used"
    },
    [2030330] = {
        DEAD_MESSAGE1 = "Stop, I give! ",
        HP50_MESSAGE1 = "My blade will put you to rest. ",
        START_MESSAGE1 = "Ready when you are! "
    },
    [2030336] = {
        DEAD_MESSAGE1 = "Stop, I give! ",
        HP50_MESSAGE1 = "My blade will put you to rest. ",
        START_MESSAGE1 = "Ready when you are! "
    },
    [2030342] = {
        HP50_MESSAGE1 = "BOSS: ATK UP ",
        HP50_MESSAGE2 = "BOSS: DEF DOWN ",
        START_MESSAGE1 = "DMG from Earth UP "
    },
    [2030354] = {
        HP50_MESSAGE1 = "BOSS: ATK UP ",
        HP50_MESSAGE2 = "BOSS: DEF DOWN ",
        START_MESSAGE1 = "DMG from Earth UP ",
        START_MESSAGE2 = "DMG UP to Water Light & Dark per HP drop "
    },
    [2030930] = {
        DEAD_MESSAGE1 = "It can't end...like this...",
        HP50_MESSAGE1 = "I hope you're ready.",
        START_MESSAGE1 = "Get out of my way."
    },
    [2030936] = {
        DEAD_MESSAGE1 = "It can't end...like this...",
        HP50_MESSAGE1 = "I hope you're ready.",
        START_MESSAGE1 = "Get out of my way."
    },
    [2030942] = {
        START_MESSAGE1 = "Poisoned units' DMG UP",
        START_MESSAGE2 = "Boss’ DEF DOWN for each time it Blinded"
    },
    [2030954] = {
        HP30_MESSAGE1 = "Avoiding heavy DMG by Blinding enemy",
        START_MESSAGE1 = "Poisoned units' DMG UP",
        START_MESSAGE2 = "Boss’ DEF DOWN for each time it Blinded",
        START_MESSAGE3 = "Reflection, Arts gauge DOWN & CRI RES."
    },

    [2021831] = {
        START_MESSAGE1 = "Human, God & Demon Killer",
        START_MESSAGE2 = "CRI rate UP to Enemys with  Status Ailment",
        TIME_UP_MESSAGE1 = "Time-up"
    },
    [2021837] = {
        START_MESSAGE1 = "I become stronger to survive.",
        HP70_MESSAGE1 = "Another has broken.",
        HP70_MESSAGE2 = "ATK & ATK speed UP",
        HP30_MESSAGE1 = "Perhaps I, too, will become..."
    },
    [2021843] = {
        START_MESSAGE1 = "I become stronger to survive.",
        HP70_MESSAGE1 = "Another has broken.",
        HP70_MESSAGE2 = "ATK & ATK speed UP",
        HP30_MESSAGE1 = "Perhaps I, too, will become..."
    },
    [2021849] = {
        START_MESSAGE1 = "I become stronger to survive.",
        HP70_MESSAGE1 = "Another has broken.",
        HP70_MESSAGE2 = "ATK & ATK speed UP",
        HP30_MESSAGE1 = "Perhaps I, too, will become..."
    },
    [2021861] = {
        START_MESSAGE1 = "Human, God & Demon Killer",
        START_MESSAGE2 = "CRI rate UP to Enemys with  Status Ailment",
        TIME_UP_MESSAGE1 = "Time-up"
    },

    [2022101] = {
        START_MESSAGE1 = "Are you ready for this?",
        START_MESSAGE2 = "Human killer",
        FIRST_RIZ_MESSAGE1 = "I will endure the pain.",
        FIRST_RIZ_MESSAGE2 = "ATK & DEF UP",
        SECOND_RIZ_MESSAGE1 = "I will get up... over and over again.",
        SECOND_RIZ_MESSAGE2 = "Evasion rate & DMG UP",
        THIRD_RIZ_MESSAGE1 = "Only once more, give me... strength!",
        THIRD_RIZ_MESSAGE2 = "Evasion rate & CRI rate UP",
        DEAD_MESSAGE1 = "Well done, sir."
    },
    [2022105] = {
        START_MESSAGE1 = "Are you ready for this?",
        START_MESSAGE2 = "Human killer",
        FIRST_RIZ_MESSAGE1 = "I will endure the pain.",
        FIRST_RIZ_MESSAGE2 = "ATK & DEF UP",
        SECOND_RIZ_MESSAGE1 = "I will get up... over and over again.",
        SECOND_RIZ_MESSAGE2 = "Evasion rate & DMG UP",
        THIRD_RIZ_MESSAGE1 = "Only once more, give me... strength!",
        THIRD_RIZ_MESSAGE2 = "Evasion rate & CRI rate UP",
        DEAD_MESSAGE1 = "Well done, sir."
    },
    [4000917] = {
        START_MESSAGE = "Negates DMG & Break from Fire Units.",
        BUFF_MESSAGE1 = "Negates DEF",
        BUFF_MESSAGE2 = "HP Auto-Recovery",
        BUFF_MESSAGE3 = "DMG UP"
    },
    [2004339] = {
        SPEED_UP_MESSAGE1 = "Arts gauge fills at double speed",
        RAGE_MESSAGE2 = "All allies' Earth resistance DOWN",
        START_MESSAGE = "Absorbs magic DMG",
        START_MESSAGE2 = "Negates All DMG (except Burning)"
    },
    [2004341] = {
        START_MESSAGE1 = "ATK & Accuracy UP",
        START_MESSAGE2 = "DMG DOWN when Blinded",
        HP80_MESSAGE1 = "Action speed UP",
        HP60_MESSAGE1 = "Break Res UP",
        HP40_MESSAGE1 = "Arts gauge fills at double speed",
        HP20_MESSAGE1 = "DMG UP",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },

    [2004342] = {
        START_MESSAGE1 = "The miasma fills the area.",
        START_MESSAGE2 = "Reflection, Lifesteal and Arts gauge DOWN RES",
        START_MESSAGE3 = "CRI resistance",
        HOLD_MESSAGE1 = "Holds a unit with the highest Arts gauge",
        HP60_MESSAGE1 = "Evasion rate & Arts gauge filling speed UP",
        HP30_MESSAGE1 = "Evasion rate & Arts gauge filling speed UP"
    },

    [2004343] = {
        DEAD_MESSAGE1 = "Mimosa",
        DEAD_MESSAGE2 = "Defeated!",
        START_MESSAGE1 = "Magic & CRI resistance"
    },
    [2004344] = {
        HP20_MESSAGE1 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "ATK UP",
        START_MESSAGE1 = "Reflection, Arts gauge DOWN & Magic RES.",
        START_MESSAGE2 = "CRI DMG resistance",
        START_MESSAGE3 = "DMG taken UP depends on the # of Mimosas defeated"
    },
    [2004443] = {
        HP20_MESSAGE1 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "DEF UP",
        HP70_MESSAGE1 = "ATK UP",
        START_MESSAGE1 = "CRI DMG resistance",
        START_MESSAGE2 = "Demon Killer",
        SUMMON_MESSAGE1 = "Grovogg jumped in!",
        mess1 = "Negates Physical DMG",
        mess2 = "Arts gauge filling speed UP",
        mess3 = "Break gauge recovered"
    },
    [2004444] = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Obtains BE when defeated during Freezing"
    },
    [2004542] = {
        GRAVITY_MESSAGE1 = "has vanished into spacetime continuum",
        HP20_MESSAGE1 = "Arts gauge filling speed UP",
        HP40_MESSAGE1 = "ATK UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES, Human Killer",
        START_MESSAGE2 = "DMG taken UP during Status Ailment",
        START_MESSAGE3 = "Targets the unit took high DMG",
        START_MESSAGE4 = "DMG UP to targeted unit",
        mess1 = "Rage Status: Break Power UP",
        mess2 = "Clear Angry Status"
    },

    [2004441] = {
        START_MESSAGE1 = "The miasma fills the area.",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN RES, Shield Killer",
        START_MESSAGE3 = "DMG to the highest MAX HP unit UP",
        START_MESSAGE4 = "Big Fraid: Negates DMG taken except during Freezing",
        HP70_MESSAGE1 = "Both heads give a furious roar.",
        HP70_MESSAGE2 = "DMG UP",
        HP50_MESSAGE1 = "Both heads give a furious roar.",
        HP50_MESSAGE2 = "CRI rate UP",
        HP30_MESSAGE1 = "Both heads give a furious roar.",
        HP30_MESSAGE2 = "CRI resistance & Arts gauge filling speed UP"
    },
    [2004541] = {
        START_MESSAGE1 = "The miasma fills the area.",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN RES",
        START_MESSAGE3 = "Cancels DMG Negation",
        SKILL1_MESSAGE1 = "Let the land be stained in my glory.",
        SKILL1_MESSAGE2 = "DMG & Earth resistance UP",
        SKILL2_MESSAGE1 = "The dark moon rises. I shall eat my fill.",
        SKILL2_MESSAGE2 = "DMG & Magic resistance UP",
        HP30_MESSAGE1 = "Hear the name of Ugetsu and tremble!",
        HP30_MESSAGE2 = "CRI resistance & Arts gauge filling speed UP"
    },

    [2004436] = {
        SPEED_UP_MESSAGE1 = "Arts gauge fills at double speed",
        RAGE_MESSAGE2 = "All allies' Fire resistance DOWN",
        START_MESSAGE1 = "Demon Killer",
        START_MESSAGE2 = "Absorbs CRI DMG",
        START_MESSAGE3 = "Action speed UP while Burning",
        START_MESSAGE4 = "CRI Arts to Burning enemy"
    },
    [2004536] = {
        SPEED_UP_MESSAGE1 = "Arts gauge fills at double speed",
        RAGE_MESSAGE1 = "HP auto-recovery",
        RAGE_MESSAGE2 = "All allies' Water resistance DOWN",
        START_MESSAGE1 = "Negates All DMG (except Poison)",
        START_MESSAGE2 = "Accuracy UP",
        START_MESSAGE3 = "DMG taken UP During Blind",
        START_MESSAGE4 = "Humans & Machines Faint"
    },
    [2005437] = {
        START_MESSAGE1 = "Break Res. UP",
        ARTS_MESSAGE1 = "Light Res. UP",
        BREAK_MESSAGE1 = "Light Res. DOWN during Break",
        HP80_MESSAGE1 = "Action speed UP",
        HP60_MESSAGE1 = "DMG UP",
        HP50_MESSAGE1 = "Arts gauge UP",
        HP40_MESSAGE1 = "Action speed UP",
        HP20_MESSAGE1 = "Action speed UP",
        RAGE_MESSAGE1 = "ATK UP",
        RAGE_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE3 = "Allies' DMG taken UP"
    },
    [200040804] = {
        START_MESSAGE1 = "Roy... I'm gonna crush you!",
        START_MESSAGE2 = "I'd like to see you try.",
        START_MESSAGE3 = "Oh, I'll do way more than just \"try\"!",
        START_MESSAGE21 = "This ends now.",
        START_MESSAGE22 = "Sorry, I don't feel like losing today.",
        START_MESSAGE23 = "Tsk, again with that cocky attitude...",
        START_MESSAGE24 = "Now I'm REALLY ticked!",
        START_MESSAGE31 = "C'mon, let's party!",
        START_MESSAGE32 = "I don't have time to mess with you.",
        START_MESSAGE33 = "Heh, talk trash while you still can!",
        START_MESSAGE41 = "What's wrong? You look scared to death!",
        START_MESSAGE42 = "Accuracy & ATK UP",
        HP80_MESSAGE1 = "Action speed UP",
        HP65_MESSAGE1 = "Arts gauge fills at double speed",
        HP50_MESSAGE1 = "I can see you beat into a bloody pulp already!",
        HP50_MESSAGE2 = "DMG UP",
        HP45_MESSAGE1 = "Action speed UP",
        HP30_MESSAGE1 = "Heh, is that all you got?",
        HP30_MESSAGE2 = "Can't be killed：CANCELED during Break",
        HP30_MESSAGE3 = "Heals DMG taken：CANCELED during Break",
        HP10_MESSAGE1 = "This one's just for you. Now die.",
        HP10_MESSAGE2 = "DMG UP",
        ITEM_MESSAGE1 = "Summon Winged Corpse",
        DOOM_MESSAGE1 = "What's wrong? You look scared to death!",
        INFO_MESSAGE1 = "Heals DMG taken：CANCELED during Break",
        INFO_MESSAGE21 = "DMG to Roy UP",
        INFO_MESSAGE22 = "Roy's DMG taken UP",
        DEAD_MESSAGE1 = "Me? Lose?! How...?",
        DEAD_MESSAGE21 = "Ugh, you make me wanna puke...",
        OUGI_MESSAGE1 = "DMG Absorption UP",
        SINOUGI_MESSAGE1 = "Why so scared? Loosen up and have some fun!",
        SINOUGI_MESSAGE2 = "DMG Absorption UP more!",
        SINOUGI_MESSAGE21 = "Hehehe... Hahaha... Gaaahaha!",
        SINOUGI_MESSAGE22 = "DMG Absorption UP more!"
    },

    [200040901] = {
        DEAD_MESSAGE1 = "Curse...you...",
        HP0_MESSAGE1 = "No one but NO ONE is stronger than ME!",
        HP0_MESSAGE2 = "Arts gauge filling speed UP",
        HP30_MESSAGE1 = "Hahaha! I live for this!",
        HP30_MESSAGE2 = "Evasion rate & CRI/Physical resistance UP",
        HP30_MESSAGE3 = "Recovery amount DOWN",
        HP70_MESSAGE1 = "You got nothing, wimp!",
        HP70_MESSAGE2 = "Arts gauge filling speed UP",
        HP70_MESSAGE3 = "Recovery amount DOWN",
        ITEM_MESSAGE_LIST = "Summon Winged Corpse: HP DOWN to Half",
        SKILL3_MESSAGE1 = "Faints a target",
        SKILL3_MESSAGE2 = "I'm gonna turn you into a bloody mess.",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG taken UP when Blinded",
        START_MESSAGE3 = "Accuracy DOWN if the units' HP is 50% or under",
        START_MESSAGE4 = "Targets the unit inflicts highest DMG",
        START_MESSAGE5 = "CRI rate to a target UP"
    },

    [4001217] = {
        START_MESSAGE1 = "Gods & Demons Killer",
        START_MESSAGE2 = "Reflection resistance & Arts gauge DOWN resistance",
        START_MESSAGE3 = "More Breaks, takes more DMG",
        START_MESSAGE4 = "Break DMG UP from Fire units",
        BREAK_MESSAGE1 = "Entering Break! DMG taken UP!",
        BREAK_END_MESSAGE1 = "Break resistance UP",
        HOLD_MESSAGE1 = "Hold the highest Arts gauge unit",
        HP50_MESSAGE1 = "CRI rate UP",
        HP25_MESSAGE1 = "CRI rate & ATK speed UP"
    },
    [4001312] = {
        SKILL_MESSAGE1 = "Feel my whole of my might!",
        START_MESSAGE1 = "Grangarrod: DMG taken UP during Burning"
    },
    [4001313] = {
        SKILL_MESSAGE1 = "Bwahahaha!",
        START_MESSAGE1 = "Cyclops: DMG taken UP during Blind"
    },
    [4001317] = {
        HP0_MESSAGE1 = "Shadow Lightning Stance",
        HP30_MESSAGE1 = "Arts gauge filling & Action speed UP",
        HP70_MESSAGE1 = "DMG ＆ ATK speed UP ",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "CRI resistance"
    },

    [4001416] = {
        BREAK2_MESSAGE1 = "DMG taken UP during Break ",
        BREAK_MESSAGE1 = "Lock mode canceled during Break ",
        LOCK_MESSAGE1 = "Locks : Cancelled during Break ",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "CRI resistance & Gods Killer ",
        START_MESSAGE3 = "Locks 3 rightmost units "
    },

    [4001514] = {
        BREAK_MESSAGE1 = "Break! DMG taken UP! ",
        BREAK_MESSAGE2 = "Break resistance UP ",
        HP50_MESSAGE1 = "DMG UP ",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "More Break, more DMG taken ",
    },
    [4001516] = {
        HP50_MESSAGE1 = "DMG UP ",
        SKILL_MESSAGE1 = "Finale Spada: Cancels DMG Negation ",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "Demon Killer ",
    },
    [4001517] = {
        ATTACK_MESSAGE1 = "Targets unit with Highest HP ",
        HP50_MESSAGE1 = "CRI resistance UP ",
        SKILL_MESSAGE1 = "Recovery amount DOWN ",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES. "
    },

    [4001601] = {
        HP20_MESSAGE1 = "CRI DMG UP ",
        HP50_MESSAGE1 = "CRI resistance UP ",
        HP80_MESSAGE1 = "Arts gauge filling speed UP ",
        SKILL3_MESSAGE1 = "Units' Paralysis resistance DOWN ",
        START_MESSAGE1 = "Reflection resistance ",
        START_MESSAGE2 = "CRI rate UP to Paralyzed enemy ",
        START_MESSAGE3 = "DMG taken UP with Bleed, Vector, Nightmare, or Treasure Box states ",
    },
    [4001600] = {
        BREAK_MESSAGE1 = "Break! Impregnable mode canceled! ",
        HP0_MESSAGE1 = "Arts gauge filling speed UP ",
        HP50_MESSAGE1 = "Impregnable mode canceled by Break ",
        HP70_MESSAGE1 = "CRI resistance UP ",
        START_MESSAGE1 = "Reflection, Lifesteal, and Arts gauge DOWN res. ",
        START_MESSAGE2 = "DMG from Human units DOWN ",
        START_MESSAGE3 = "Break DMG from God units DOWN "
    },
    [4001700] = {
        BREAK_MESSAGE1 = "DMG taken UP during Break ",
        HP0_MESSAGE1 = "DMG UP ",
        HP50_MESSAGE1 = "DMG & Arts gauge filling speed UP ",
        SKILL6_MESSAGE1 = "Heat Wave: fixed damage 3000 ",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "HP auto-recovery Killer ",
        START_MESSAGE3 = "DMG taken UP during Break ",
    },
    [4001701] = {
        HP25_MESSAGE1 = "My body feels like it's burning up! ",
        HP25_MESSAGE2 = "CRI DMG UP ",
        HP50_MESSAGE1 = "It's burning out of control! ",
        HP50_MESSAGE2 = "CRI DMG UP ",
        HP75_MESSAGE1 = "Show me how strong you are! ",
        HP75_MESSAGE2 = "CRI DMG UP ",
        START_MESSAGE1 = "Refrection resistance, Earth/Shield Killer ",
        START_MESSAGE2 = "Targets the unit inflicts highest DMG ",
        START_MESSAGE3 = "CRI rate UP to a target "
    },

    [2022201] = {
        START_MESSAGE1 = "Shield Killer",
        RAGE_MESSAGE1 = "Rage Mode: Cancelled by Break or Freezing",
        RAGE_MESSAGE2 = "CRI rate UP",
        RAGE_MESSAGE3 = "Attack Speed UP",
        RAGE_MESSAGE4 = "DMG DOWN",
        END_RAGE_MESSAGE1 = "Rage Mode CANCELED",
        TIMEUP_MESSAGE1 = "Time's UP",
        TIMEUP_MESSAGE2 = "Arts gauge fills at double speed"
    },
    [2022301] = {
        START_MESSAGE1 = "CRI resistance",
        START_MESSAGE2 = "Physical resistance",
        TIMEUP_MESSAGE1 = "Time's UP",
        TIMEUP_MESSAGE2 = "Arts gauge fills at double speed"
    },
    [2022401] = {
        mess1 = "Rage Status: HP regen ",
        mess2 = "Rage Status: Break Gauge regen ",
        mess3 = "Rage Status: Burning Resistance DOWN ",
        mess4 = "Clear Angry Status ",
        mess5 = "Resume regen ",
        mess6 = "Stop regen ",
        START_MESSAGE1 = "Break resistance" ,
        START_MESSAGE2 = "Negates Water ATK" ,
        START_MESSAGE3 = "DMG taken DOWN (can be cancelled by Break)" ,
        BREAK_MESSAGE1 = "Break resistance UP" ,
        END_RAGE_MESSAGE1 = "Cancels DMG taken reduction" ,
        TIMEUP_MESSAGE1 = "Time's up!" ,
        TIMEUP_MESSAGE2 = "Arts gauge filling speed UP" ,
    },
    [2022501] = {
        START_MESSAGE1 = "Dark killer" ,
        START_MESSAGE2 = "ATK & CRI rate UP over time" ,
        START_MESSAGE3 = "DMG taken UP over time" ,
        START_MESSAGE4 = "CRI resistance UP" ,
        TIME_UP_MESSAGE1 = "Time's up!" ,
        TIME_UP_MESSAGE2 = "Arts gauge filling speed UP" ,
    },

    [200260903] = {
        START_MESSAGE1 = "Reflection & Arts gauge DOWN, Lifesteal resistant.",
        START_MESSAGE2 = "Negates CRI & Shield Killer",
        START_MESSAGE3 = "I don't mind tormenting the weak.",
        HP60_MESSAGE = "You're better than I thought.",
        HP20_MESSAGE = "You deserve a reward.",
        DEAD_MESSAGE = "You disgust me."
    },
    [200260904] = {
        START_MESSAGE1 = "Reflection & Arts gauge DOWN, Lifesteal resistant.",
        START_MESSAGE2 = "Negates CRI & Shield Killer",
        START_MESSAGE3 = "This will be your grave.",
        HP50_MESSAGE1 = "Let me see you grovel.",
        REVERSAL_MESSAGE1 = "Arts gauge Auto-fill Inversion",
        LINK_MESSAGE1 = "You call that defense?",
        LINK_MESSAGE2 = "I'll crush you!",
        DEAD_MESSAGE1 = "Now you've done it.",
        END_MESSAGE1 = "It can't end like this..."
    },
    [200260905] = {
        DEAD_MESSAGE1 = "Unforgivable...",
        END_MESSAGE1 = "Curse you..."
    },

    [2024601] = {
        START_MESSAGE1 = "Intruders Detected. Commence Elimination.",
        START_MESSAGE2 = "All Elemental resistance",
        START_MESSAGE3 = "All Elemental resistance DOWN with every Break.",
        ARTS1_MESSAGE1 = "Main Cannon Online. Commence Magic Charge.",
        ARTS2_MESSAGE1 = "Shields Active. Artillery to Maximum Output.",
        ARTS2_MESSAGE2 = "All Elemental resistance UP",
        BREAK_MESSAGE1 = "Shield strength DOWN",
        BREAK_MESSAGE2 = "All Elemental resistance DOWN",
        HP0_MESSAGE1 = "Self-Destruct Sequence Active"
    },
    [2024701] = {
        START_MESSAGE1 = "Water Killer",
        START_MESSAGE2 = "Fire Weakness",
        START_MESSAGE3 = "Fire resistance DOWN with every Break.",
        START_MESSAGE4 = "Mel-Vaala：Negates Magic",
        REMOVE_BUFF_MESSAGE1 = "Fire resistance DOWN",
        SKILL3_MESSAGE1 = "Winds tear mercilessly into armor and flesh."
    },
    [2024801] = {
        START_MESSAGE1 = "Dark resistance/Light Killer",
        START_MESSAGE2 = "Negates DMG Negation",
        START_MESSAGE3 = "CRI rate UP to Cursed enemy",
        ARTS1_MESSAGE1 = "The darkness will take your souls.",
        ARTS2_MESSAGE1 = "Hear the wail of despair, cursed ones."
    },
    [4001116] = {
        START_MESSAGE_1 = "Rekikiki!",
        START_MESSAGE_2 = "Rrrroooo!",
        START_MESSAGE_3 = "Shekikiki!",
        SKILL_MESSAGE = "Keeheeheeeee!",
        DEAD_MESSAGE = "Kraaaaaah!"
    },
    [4001117] = {
        START_MESSAGE1 = "Negates Magic DMG/Water DMG",
        START_MESSAGE2 = "DMG taken UP when Burning",
        HP70_MESSAGE1 = "CRI rate UP",
        HP70_MESSAGE2 = "HP auto Recovery amount UP",
        HP50_MESSAGE1 = "CRI rate UP",
        HP50_MESSAGE2 = "HP auto Recovery amount UP",
        HP30_MESSAGE1 = "Action speed UP",
        HP30_MESSAGE2 = "HP auto Recovery amount UP",
        SKILL_MESSAGE = "It begins storing power..."
    },

    [2017901] = {
        START_MESSAGE1 = "Dark Killer/Dark Res. UP",
        HP70_MESSAGE1 = "I-I've come to help!",
        HP50_MESSAGE1 = "DMG UP"
    },
    [2017905] = {
        START_MESSAGE1 = "Dark Killer/Dark Res. UP",
        HP80_MESSAGE1 = "Action speed UP",
        HP70_MESSAGE1 = "I-I've come to help!",
        HP50_MESSAGE1 = "DMG UP",
        HP40_MESSAGE1 = "CRI rate & HP Recovery amount UP",
        HP20_MESSAGE1 = "Action speed UP"
    },
    [2017909] = {
        START_MESSAGE1 = "Dark Killer/Dark Res. UP",
        START_MESSAGE2 = "Evasion rate UP",
        HP80_MESSAGE1 = "Action speed UP",
        HP70_MESSAGE1 = "I-I've come to help!",
        HP50_MESSAGE1 = "DMG UP",
        HP40_MESSAGE1 = "CRI rate & HP Recovery amount UP",
        HP20_MESSAGE1 = "Action speed UP"
    },
    [2005537]={
        START_MESSAGE1 = "Negates CRl Damage",
        START_MESSAGE2 = "Arts gauge constantly decreases",
        HP80_MESSAGE1 = "Action speed UP",
        HP60_MESSAGE1 = "DMG UP",
        HP40_MESSAGE1 = "Action speed UP",
        HP20_MESSAGE1 = "Arts gauge fills at double speed",
        RAGE_MESSAGE1 = "ATK UP",
        RAGE_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE3 = "Allies' DMG taken UP"
    },
    [2027430] = {
        START_MESSAGE1 = "I won't hold back.",
        START_MESSAGE2 = "Water & Magic Res.",
        HP50_MESSAGE1 = "I'm not losing this one!",
        DEAD_MESSAGE1 = "Am I not strong enough...?"
    },
    [2027436] = {
        START_MESSAGE1 = "I won't hold back.",
        START_MESSAGE2 = "Water & Magic Res.",
        HP50_MESSAGE1 = "I'm not losing this one!",
        DEAD_MESSAGE1 = "Am I not strong enough...?"
    },
    [2027442] = {
        START_MESSAGE1 = "Reflection & Arts gauge Down Res.",
        START_MESSAGE2 = "HP Auto-recovery",
        HP70_MESSAGE1 = "DMG & CRI rate UP",
        HP30_MESSAGE1 = "DMG & CRI rate UP"
    },
    [2027454] = {
        START_MESSAGE1 = "Reflection & Arts gauge Down Res.",
        START_MESSAGE2 = "HP Auto-recovery",
        HP70_MESSAGE1 = "DMG & CRI rate UP",
        HP30_MESSAGE1 = "DMG & CRI rate UP"
    },
    [2027455] = {
        START_MESSAGE1 = "Reflection Res & Negates Physical DMG taken",
        START_MESSAGE2 = "Negates DMG taken during Arts",
        START_MESSAGE3 = "Defeat within the time limit!",
        HP80_MESSAGE1 = "DMG taken reduction rate UP!",
        HP60_MESSAGE1 = "DMG taken reduction rate UP!",
        HP40_MESSAGE1 = "DMG taken reduction rate UP!",
        HP20_MESSAGE1 = "DMG taken reduction rate UP!"
    },
    [2018455] = {
        START_MESSAGE1 = "Eliminate the foes",
        START_MESSAGE2 = "Light Killer",
        HP70_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "I'll tear you apart! Full power!",
        HP30_MESSAGE1 = "Time to end this. Doom Blade Mode!",
        DEAD_MESSAGE1 = "I admit your talent..."
    },
    [2018155] = {
        START_MESSAGE1 = "Let our bout begin.",
        START_MESSAGE2 = "Earth Killer",
        HP70_MESSAGE1 = "Aaaaooooh!",
        HP50_MESSAGE1 = "Observe well my technique!",
        HP30_MESSAGE1 = "Can you withstand my flames?",
        HP30_MESSAGE2 = "Action speed UP",
        HP30_MESSAGE3 = "Shield Killer",
        HP0_MESSAGE1 = "What power..."
    },
    [2004340] = {
        START_MESSAGE1 = "Negates CRI DMG & DEF UP",
        START_MESSAGE2 = "Burn DMG UP during Break",
        RAGE_MESSAGE1 = "ATK UP",
        RAGE_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE3 = "Allies' DMG taken UP",
        HP_80_MESSAGE1 = "Hammer destroyed with Break",
        HP_80_MESSAGE2 = "Arts DMG UP when Hammer's Equiped",
        HP_60_MESSAGE1 = "DMG UP",
        HP_50_MESSAGE1 = "Action speed UP",
        HP_20_MESSAGE1 = "Arts gauge Boosted"
    },
    [2004437] = {
        START_MESSAGE1 = "CRI res. UP",
        START_MESSAGE2 = "Negates any DMG except for CRI",
        START_MESSAGE3 = "Shield Killer/Physical res. UP",
        HP80_MESSAGE1 = "DMG UP",
        HP60_MESSAGE1 = "Action speed UP",
        HP40_MESSAGE1 = "CRI res. UP",
        HP20_MESSAGE1 = "Action speed UP",
        RAGE_MESSAGE1 = "ATK UP",
        RAGE_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE3 = "Allies' DMG taken UP"
    },
    [2004537] = {
        START_MESSAGE1 = "Accuracy UP",
        HP80_MESSAGE1 = "Break res. UP",
        HP60_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "Scorching Heat Blows",
        HP40_MESSAGE1 = "Action speed UP",
        HP20_MESSAGE1 = "Break res. UP",
        RAGE_MESSAGE1 = "ATK UP",
        RAGE_MESSAGE2 = "DMG UP",
        RAGE_MESSAGE3 = "Allies' DMG taken UP"
    },
    [2004345] = {
        HP10_MESSAGE1 = "I am one with the forest...",
        HP10_MESSAGE2 = "DMG & Arts gauge filling speed UP",
        HP30_MESSAGE1 = "My will is forever loyal.",
        HP30_MESSAGE2 = "DMG UP",
        HP50_MESSAGE1 = "I only serve the forest.",
        HP50_MESSAGE2 = "DMG UP",
        SKILL_MESSAGE1 = "Evergreen: DMG Negation cancelled",
        START_MESSAGE1 = "I am master of the ancient forest.",
        START_MESSAGE2 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE3 = "More Max HP, more DMG"
    },
    [2004346] = {
        DEAD_MESSAGE1 = "This must be...a cruel joke.",
        HP20_MESSAGE1 = "DMG & Arts gauge filling speed UP",
        SKILL_MESSAGE1 = "Yes, you will die here!",
        SKILL_MESSAGE2 = "Target the unit with highest HP",
        SKILL_MESSAGE3 = "DMG Negation cancelled",
        START_MESSAGE1 = "Are we ready to begin?",
        START_MESSAGE2 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Physical resistance"
    },
    [2004348] = {
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "Party's Arts gauge Auto-fill UP with each kind of Status Ailment inflicted",
        HP60_MESSAGE1 = "Status Ailment resistance UP",
        HP40_MESSAGE1 = "Status Ailment resistance UP",
        HP20_MESSAGE1 = "Arts gauge filling speed UP",
        BAD_CONDITION_MESSAGE1 = "Status Ailment! Party's Arts gauge Auto-filling amount UP ",
        BAD_CONDITION89="Fainted ",
        BAD_CONDITION90="Poisoned ",
        BAD_CONDITION91="Paralyzed ",
        BAD_CONDITION92="Sealed ",
        BAD_CONDITION93="Blinded ",
        BAD_CONDITION94="Diseased ",
        BAD_CONDITION95="Cursed ",
        BAD_CONDITION96="Frozen ",
        BAD_CONDITION97="Burned "
    },
    [2004349] = {
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG taken UP during Break",
        START_MESSAGE3 = "Grovogg: Negates Earth DMG",
        START_MESSAGE4 = "More Grovogg increases Boss Break resistance",
        BREAK_MESSAGE1 = "Break! DMG taken UP during Break",
        SUMMON_MESSAGE1 = "Grovogg: Negates Earth DMG",
        SKILL1_MESSAGE1 = "Inferno Charge: DMG Negation canceled",
        REVERSE_MESSAGE1 = "Reverse HP auto-recovery",
        HP50_MESSAGE1 = "CRI resistance & Arts gauge filling speed UP",
        HP0_MESSAGE1 = "Inferno Charge: DMG Negation canceled"
    },
    [2004445] = {
        BREAK_END_MESSAGE1 = "Break resistance UP",
        BREAK_MESSAGE1 = "Break! DMG taken UP!",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Physical resistance & Human Killer",
        START_MESSAGE3 = "More Break, more DMG taken",
        START_MESSAGE4 = "CRI rate UP to Burning units"
    },
    [2004446] = {
        FALL_MESSAGE1 = "Freeze! Flying mode cancelled!",
        FLY_MESSAGE1 = "Flying mode - evasion rate UP: Cancelled by Freeze",
        HP30_MESSAGE1 = "Freeze resistance & CRI resistance UP",
        HP60_MESSAGE1 = "Freeze resistance UP",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Magic resistance & Shield Killer"
    },
    [2004447] = {
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "Targets the unit inflicts highest DMG",
        START_MESSAGE3 = "DMG UP to a target",
        HP60_MESSAGE1 = "Target's CRI resistance DOWN",
        HP40_MESSAGE1 = "Target's CRI resistance DOWN",
        HP20_MESSAGE1 = "Target's CRI resistance massively DOWN"
    },
    [2004448] = {
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG Negation canceled",
        START_MESSAGE3 = "Negates DMG: HP DOWN by Break DMG",
        START_MESSAGE4 = "HP DOWN amount UP during Blinded or Disease",
        SKILL_MESSAGE1 = "Arts gauge DOWN",
        BREAK_MESSAGE1 = "HP DOWN amount UP during Break",
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        HP20_MESSAGE1 = "HP auto-recovery"
    },
    [2004543] = {
        HP20_MESSAGE1 = "Finally good and loosened up!",
        HP20_MESSAGE2 = "Evasion rate UP",
        HP50_MESSAGE1 = "You got guts, I'll give you that!",
        HP50_MESSAGE2 = "Evasion rate UP",
        SKILL_MESSAGE1 = "CRI rate & CRI DMG UP",
        START_MESSAGE1 = "Show me what you got!",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN RES.",
        START_MESSAGE3 = "DMG DOWN during Status ailment"
    },
    [2004544] = {
        HP20_MESSAGE1 = "CRI resistance & Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        HP70_MESSAGE1 = "CRI DMG UP",
        SKILL13_MESSAGE1 = "Heavenly Aqua Barrier: Faints a target & makes its Arts gauge DOWN",
        SKILL14_MESSAGE1 = "Heavenly Aqua Slash: Faints a target & makes its Arts gauge DOWN",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Shield Killer",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG",
        START_MESSAGE4 = "CRI rate UP to a target"
    },
    [2004545] = {
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG & CRI rate UP to Frozen enemy",
        START_MESSAGE3 = "Party's MAX HP UP every time of Break",
        BREAK_MESSAGE1 = "Party's Max HP UP!",
        SKILL2_MESSAGE1 = "Recovery amount DOWN",
        HP50_MESSAGE1 = "Arts gauge filling speed UP"
    },
    [2004546] = {
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Shield Killer",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG",
        START_MESSAGE4 = "CRI rate UP to a target",
        SKILL5_MESSAGE1 = "HP DOWN to half & ATK DOWN",
        HP70_MESSAGE1 = "Faints Party except a target & Boss's Evasion rate UP",
        HP50_MESSAGE1 = "Faints Party except a target & Boss's CRI resistance UP",
        HP30_MESSAGE1 = "Faints Party except a target & Boss's Evasion rate UP"
    },
    [2004547] = {
        HP20_MESSAGE1 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "DMG UP",
        HP80_MESSAGE1 = "CRI resistance UP",
        SKILL1_MESSAGE1 = "ATK DOWN",
        SKILL2_MESSAGE1 = "Cancels DMG Negation",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG from Burn & Sealed units UP"
    },
    [2004548] = {
        ATTACK4_MESSAGE1 = "Targets the unit with highest HP",
        HP20_MESSAGE1 = "This is the power of creation.",
        HP20_MESSAGE2 = "DEF & Arts gauge filling speed UP",
        HP50_MESSAGE1 = "I shall mete out punishment.",
        HP50_MESSAGE2 = "Physical resistance UP",
        HP70_MESSAGE1 = "Know your weakness.",
        HP70_MESSAGE2 = "CRI resistance UP",
        SKILL1_MESSAGE1 = "DMG from %s units DOWN",
        START_MESSAGE1 = "You shall perish for my ideal.",
        START_MESSAGE2 = "Reflection, Lifesteal, & Arts gauge DOWN resistance",
        START_MESSAGE3 = "HP auto-recovery Killer",
        START_MESSAGE4 = "Targets the unit inflicts highest DMG",
        START_MESSAGE5 = "CRI rate UP to a target",
        RACE1 = "Human",
        RACE2 = "Beast",
        RACE3 = "Spirit",
        RACE4 = "Giant",
        RACE5 = "Machine",
        RACE6 = "Dragon",
        RACE7 = "God",
        RACE8 = "Demon"
    },

    [2011501] = {
        START_MESSAGE2 = "Fire Res UP",
        START_MESSAGE3 = "Earth/Physical Res DOWN",
        START_MESSAGE4 = "HP-steal when enemy is Frozen",
        HP30_MESSAGE2 = "DMG UP"
    },
    [2011505] = {
        START_MESSAGE1 = "Get ready!",
        START_MESSAGE2 = "Fire Res UP",
        START_MESSAGE3 = "Earth/Physical Res DOWN",
        START_MESSAGE4 = "HP-steal when enemy is Frozen",
        HP50_MESSAGE1 = "Hear my howling rage!",
        HP30_MESSAGE2 = "DMG UP"
    },
    [2011509] = {
        START_MESSAGE1 = "Get ready!",
        START_MESSAGE2 = "Fire Res UP",
        START_MESSAGE3 = "Earth/Physical Res DOWN",
        START_MESSAGE4 = "HP-steal when enemy is Frozen",
        HP70_MESSAGE1 = "Action speed UP",
        HP50_MESSAGE1 = "Hear my howling rage!",
        HP50_MESSAGE2 = "CRI DMG U",
        HP30_MESSAGE1 = "I am losing control... Graaaah!",
        HP30_MESSAGE2 = "DMG UP/ DMG taken DOWN"
    },
    [2031330] = {
        START_MESSAGE1 = "Could you get out of my way?",
        HP50_MESSAGE1 = "It's time to finish this.",
        DEAD_MESSAGE1 = "I can't believe it..."
    },
    [2031336] = {
        START_MESSAGE1 = "C'mon, Amidamaru!",
        HP50_MESSAGE1 = "I'm pulling out all the stops.",
        DEAD_MESSAGE1 = "That was pathetic..."
    },
    [2031342] = {
        HP50_MESSAGE1 = "Can you keep me entertained?",
        DEAD_MESSAGE1 = "You'll pay for that!",
        DEAD_MESSAGE2 = "Asakura Yoh:ATK UP",
        ANOTHER_DEAD_MESSAGE1 = "I can't believe it..."
    },
    [2031344] = {
        START_MESSAGE1 = "Let's go!",
        START_MESSAGE2 = "What a pain.",
        START_MESSAGE3 = "DMG taken from Fire & Earth UP",
        HP50_MESSAGE1 = "I'm pulling out all the stops.",
        DEAD_MESSAGE1 = "You've got guts, huh?",
        DEAD_MESSAGE2 = "Kyoyama Anna:HP Auto-recovery",
        ANOTHER_DEAD_MESSAGE1 = "That was pathetic..."
    },
    [2031354] = {
        START_MESSAGE1 = "Reflection Res & Fire weakness",
        START_MESSAGE2 = "CRI Res",
        START_MESSAGE3 = "DEF & ATK speed DOWN when Burning",
        HP60_MESSAGE1 = "DMG UP",
        HP30_MESSAGE1 = "Recovers from Burning & CRI rate UP",
        BURN_MESSAGE1 = "Burning:DEF & ATK speed DOWN",
        FIRE_MESSAGE1 = "Ahh! I hate fire!",
        SKILL3_MESSAGE1 = "Lifesteal 5000 HP"
    },

    [2031530] = {
        START_MESSAGE1 = "Destroy them, Bason.",
        HP50_MESSAGE1 = "Behold your doom!",
        DEAD_MESSAGE1 = "Ridiculous..."
    },
    [2031536] = {
        START_MESSAGE1 = "This should be fun.",
        HP50_MESSAGE1 = "Don't get hasty.",
        DEAD_MESSAGE1 = "Not bad."
    },
    [2031542] = {
        START_MESSAGE1 = "Come get some.",
        START_MESSAGE2 = "DMG taken from Dark & Fire UP",
        HP100_MESSAGE1 = "Hahaha...",
        HP50_MESSAGE1 = "I'll crush you.",
        HP30_MESSAGE1 = "DMG to Burning units UP",
        DEAD_MESSAGE1 = "Interesting..."
    },
    [2031550] = {
        RESULT_MESSAGE1 = "Total:",
        RESULT_MESSAGE2 = " DMG!!",
        RESULT_MESSAGE3 = "Most single-hit:",
        DAMAGE_MESSAGE1 = "%d0000",
        DAMAGE_MESSAGE2 = "%d",
        DAMAGE_MESSAGE3 = " DMG!",
        DAMAGE_MESSAGE4 = "Single-hit:",
        DAMAGE_MESSAGE5 = " DMG!",
        LOSE_MESSAGE1 = "Failed to reach cumulative DMG of 200 million",
        LOSE_MESSAGE2 = "Arts gauge fills at double speed",

        START_MESSAGE1 = "Super-recovery",
        START_MESSAGE2 = "Allies' DMG UP",
        START_MESSAGE3 = "Negates Break DMG",
        START_MESSAGE4 = "To clear:Deal 200 million DMG in less than 180s!"
    },
    [2031554] = {
        START_MESSAGE1 = "Reflection & Arts gauge DOWN Res",
        START_MESSAGE2 = "DMG taken form Demons DOWN",
        START_MESSAGE3 = "ATK DOWN when Blinded",
        HP50_MESSAGE1 = "Praise the name of Ugetsu.",
        HP50_MESSAGE2 = "Recovers from Status Ailment & Accuracy UP",
        HP20_MESSAGE1 = "I grant you ruination.",
        HP20_MESSAGE2 = "Recovers from Status Ailment",
        HP20_MESSAGE3 = "DMG UP & Arts gauge increasing amount UP",
        BLIND_MESSAGE1 = "Blinded & ATK DOWN"
    },

    [2031830] = {
        DEAD_MESSAGE1 = "I apologize! ",
        HP50_MESSAGE1 = "Face my storm of bullets! ",
        START_MESSAGE1 = "Exterminate the enemy. ",
    },
    [2031836] = {
        DEAD_MESSAGE1 = "I apologize! ",
        HP50_MESSAGE1 = "Face my storm of bullets! ",
        START_MESSAGE1 = "Exterminate the enemy. ",
    },
    [2031842] = {
        BREAK_MESSAGE1 = "DEF & CRI resistance DOWN ",
        HP15_MESSAGE1 = "DEF & CRI resistance UP ",
        START_MESSAGE1 = "Reflection, Arts gauge DOWN & CRI resistance ",
        START_MESSAGE2 = "DMG from Light & CRI DMG UP ",
        START_MESSAGE3 = "DEF & CRI resistance cancelled during Break ",
        START_MESSAGE4 = "Break power doubles during enemy's Arts ",
    },
    [2031854] = {
        BREAK2_MESSAGE1 = "DEF & CRI resistance cancelled ",
        BREAK_MESSAGE1 = "DEF & CRI resistance DOWN ",
        HP30_MESSAGE1 = "DEF & CRI resistance UP ",
        START_MESSAGE1 = "Reflection, Arts gauge DOWN & CRI resistance ",
        START_MESSAGE2 = "DMG from Light & CRI DMG UP ",
        START_MESSAGE3 = "DEF & CRI resistance DOWN during Break ",
        START_MESSAGE4 = "Break power doubles during enemy's Arts "
    },

    [2032830] = {
        DEAD_MESSAGE1 = "I think I'm a little tired...",
        HP50_MESSAGE1 = "This is hot.",
        START_MESSAGE1 = "Let's begin."
    },
    [2032836] = {
        DEAD_MESSAGE1 = "I think I'm a little tired...",
        HP50_MESSAGE1 = "This is hot.",
        START_MESSAGE1 = "Let's begin."
    },
    [2032842] = {
        HP30_MESSAGE1 = "Action speed & Burn resistance UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance UP",
        START_MESSAGE2 = "DMG from Fire UP during Burn",
        START_MESSAGE3 = "Boss' Arts DMG DOWN during Burn",
        START_MESSAGE4 = "Paralysis & Faint resistance DOWN during Burn"
    },
    [2032854] = {
        HP30_MESSAGE1 = "Action speed & Burn resistance UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance UP",
        START_MESSAGE2 = "DMG from Fire UP during Burn",
        START_MESSAGE3 = "Boss' Arts DMG DOWN during Burn"
    },

    [2028530] = {
        START_MESSAGE1 = "Have you done your warm-ups?",
        HP50_MESSAGE1 = "I'm still the Ranger Captain!",
        DEAD_MESSAGE1 ="Never too old to learn, huh?"
    },
    [2028536] = {
        START_MESSAGE1 = "Have you done your warm-ups?",
        HP50_MESSAGE1 = "I'm still the Ranger Captain!",
        DEAD_MESSAGE1 ="Never too old to learn, huh?"
    },
    [2028542] = {
        START_MESSAGE1 = "Res UP (Except Light Res) when HP is low."
    },
    [2028554] = {
        START_MESSAGE1 = "Res UP (Except Light Res) when HP is low.",
        START_MESSAGE2 = "No Negation: Boss's DMG UP",
        START_MESSAGE3 = "Res for Reflection & Arts gauge DOWN"
    },

    [200330028] = {
        START_MESSAGE1 = "Shield Killer",
        START_MESSAGE2 = "DMG from Demons DOWN",
        RUSH_MESSAGE = "The Feast of Doom begins."
    },

    [2005438] = {
        START_MESSAGE1 = "HP-recovery DOWN when taking DMG",
        START_MESSAGE2 = "Less then Half HP:Reduces Arts gauge",
        START_MESSAGE3 = "Negates CRI",
        HP80_MESSAGE1 = "Feel terror carving into your soul...",
        HP50_MESSAGE1 = "Do you see the shadow of ruin?",
        HP30_MESSAGE1 = "I will grant you a worthy death."
    },

    [2005539] = {
        TEXTHP80_MESSAGE1 = "The edge of my scythe never dulls.",
        TEXTHP15_MESSAGE1 = "I will cast your souls into oblivion."
    },

    [2033030] = {
        DEAD_MESSAGE1 = "No way...",
        HP50_MESSAGE1 = "I've been saving this one.",
        START_MESSAGE1 = "Alright, let's get it on."
    },
    [2033036] = {
        DEAD_MESSAGE1 = "No way...",
        HP50_MESSAGE1 = "I've been saving this one.",
        START_MESSAGE1 = "Alright, let's get it on."
    },
    [2033042] = {
        BURST_MESSAGE1 = "Boss' DMG UP",
        DEAD_MESSAGE1 = "It can't end like this...",
        HP30_MESSAGE1 = "Action speed UP",
        HP30_MESSAGE2 = "Arts frequency UP",
        HP50_MESSAGE1 = "I'll guide you to salvation.",
        START_MESSAGE1 = "DMG taken from Water unit UP",
        START_MESSAGE2 = "CRI resistance",
        START_MESSAGE3 = "I hope you're ready."
    },
    [2033054] = {
        BURST_MESSAGE1 = "Boss' DMG UP",
        DEAD_MESSAGE1 = "It can't end like this...",
        DEFENCE_MESSAGE1 = "DEF UP",
        HP30_MESSAGE1 = "Action speed UP",
        HP30_MESSAGE2 = "Arts frequency UP",
        HP50_MESSAGE1 = "I'll guide you to salvation.",
        START_MESSAGE1 = "DMG taken from Water unit UP",
        START_MESSAGE2 = "Reflection, Arts gauge DOWN & CRI RES.",
        START_MESSAGE3 = "I hope you're ready."
    },
    [2033630] = {
        START_MESSAGE1 = "Here I come!",
        HP50_MESSAGE1 = "This'll stop you!",
        DEAD_MESSAGE1 = "I messed up..."
    },
    [2033636] = {
        START_MESSAGE1 = "The test begins now!",
        HP50_MESSAGE1 = "There's no escape!",
        DEAD_MESSAGE1 = "Ugh, you're quite skilled..."
    },
    [2033642] = {
        HP30_MESSAGE1 = "Roxy:Arts DMG Boosted",
        HP50_MESSAGE1 = "Now!",
        DEAD_MESSAGE1 = "Ahhhh!"
    },
    [2033644] = {
        START_MESSAGE1 = "I'm all set!",
        START_MESSAGE2 = "Let's start.",
        START_MESSAGE3 = "Reflection & Arts gauge DOWN Res",
        START_MESSAGE4 = "DMG taken from Earth & Water UP",
        HP50_MESSAGE1 = "Here's my chance!",
        HP30_MESSAGE1 = "Rudeus:Action Speed Boosted",
        DEAD_MESSAGE1 = "Nooooo!"
    },
    [2033654] = {
        START_MESSAGE1 = "Reflection, Physical & Arts gauge DOWN Res",
        START_MESSAGE2 = "DMG taken UP when Burning",
        HP60_MESSAGE1 = "Recover from Status ailment",
        BURN_MESSAGE1 = "Burning Mode:DMG taken UP"
    },
    [2012493] = {
        START_MESSAGE1 = "Reflection, Physical & Arts gauge DOWN Res",
        START_MESSAGE2 = "DMG taken UP when Burning",
        HP60_MESSAGE1 = "Recover from Status ailment",
        BURN_MESSAGE1 = "Burning Mode:DMG taken UP"
    },

    [2033930] = {
        START_MESSAGE1 = "I have to fight!",
        HP50_MESSAGE1 = "This is it!",
        DEAD_MESSAGE1 = "I can't...keep going..."
    },
    [2033936] = {
        START_MESSAGE1 = "I've been waiting for this!",
        HP50_MESSAGE1 = "I'll make you regret that!",
        DEAD_MESSAGE1 = "Urgh..."
    },
    [2033942] = {
        START_MESSAGE1 = "Let's get right to it.",
        START_MESSAGE2 = "Tormenting the weak can be fun.",
        START_MESSAGE3 = "Reflection & Arts gauge DOWN Res",
        START_MESSAGE4 = "DMG taken UP from Fire units",
        HP50_MESSAGE1 = "Gahahaha! Now we're talking!",
        HP50_MESSAGE2 = "Here's your reward!",
        DEAD_MESSAGE1 = "How could this happen?!"
    },
    [2033944] = {
        REBORN_MESSAGE1 = "You haven't won yet!",
        DEAD_MESSAGE1 = "Why did I...?!"
    },
    [2033953] = {
        RESULT_MESSAGE1 = "Total:",
        RESULT_MESSAGE2 = " DMG!",
        RESULT_MESSAGE3 = "Most single-hit:",
        DAMAGE_MESSAGE1 = "%d0000",
        DAMAGE_MESSAGE2 = "%d",
        DAMAGE_MESSAGE3 = " DMG!",
        DAMAGE_MESSAGE4 = "Single-hit:",
        DAMAGE_MESSAGE5 = " DMG!",
        LOSE_MESSAGE1 = "Failed to reach cumulative DMG of 200 million",
        LOSE_MESSAGE2 = "Arts gauge fills at double speed",
        START_MESSAGE1 = "Super-recovery",
        START_MESSAGE2 = "Negates Break DMG",
        START_MESSAGE3 = "Dark & Physical Resistance",
        START_MESSAGE4 = "Allies' DMG UP",
        START_MESSAGE5 = "To clear:Deal 200 million DMG in less than 180s!"
    },
    [2033954] = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN Res",
        START_MESSAGE2 = "Light & Shield Killer",
        CHARGE_MESSAGE1 = "Shadow Lightning Stance",
        CHARGE_MESSAGE2 = "Takes more damage, becomes less force",
        SUB_HP0_MESSAGE1 = "Canceling Shadow Lightning with damage!"
    },

    [2034430] = {
        DEAD_MESSAGE1 = "Wait, I still haven't...",
        HP50_MESSAGE1 = "I will extinguish your flame.",
        START_MESSAGE1 = "Don't interfere."
    },
    [2034436] = {
        DEAD_MESSAGE1 = "Wait, I still haven't...",
        HP50_MESSAGE1 = "Throw away your fears.",
        START_MESSAGE1 = "Don't interfere."
    },
    [2034442] = {
        ATTACK1_MESSAGE1 = "DMG UP",
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        SKILL2_MESSAGE1 = "Allies' ATK DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN Res. ",
        START_MESSAGE2 = "Allies' DMG taken UP over time",
        START_MESSAGE3 = "DMG taken from Water units UP",
        START_MESSAGE4 = "Physical DMG taken UP"
    },
    [2034454] = {
        ATTACK1_MESSAGE1 = "DMG UP",
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Burn effect to all",
        SKILL2_MESSAGE1 = "Allies' ATK DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN Res. ",
        START_MESSAGE2 = "Allies' DMG taken UP over time",
        START_MESSAGE3 = "DMG taken from Water units UP",
        START_MESSAGE4 = "Physical DMG taken UP"
    },

    [2035030] = {
        DEAD_MESSAGE1 = "This isn't...fair!",
        HP50_MESSAGE1 = "Your reign of terror ends here.",
        START_MESSAGE1 = "Get out of my face."
    },
    [2035036] = {
        DEAD_MESSAGE1 = "This isn't...fair!",
        HP50_MESSAGE1 = "I am judgment itself.",
        START_MESSAGE1 = "Get out of my face."
    },
    [2035042] = {
        HP50_MESSAGE1 = "Boss's DMG UP",
        HUMMER_MESSAGE1 = "Units' DMG taken UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Allies' DMG taken UP over time",
        START_MESSAGE3 = "DMG from Earth UP"
    },
    [2035054] = {
        HP30_MESSAGE1 = "The Giant's hammer is unstoppable",
        HP80_MESSAGE1 = "Boss's DMG UP",
        HUMMER_MESSAGE1 = "Units' DMG taken UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Allies' DMG taken UP over time",
        START_MESSAGE3 = "DMG from Earth UP"
    },

    [2035901] = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES." ,
        START_MESSAGE2 = "DMG taken UP during Status Ailment" ,
        START_MESSAGE3 = "Zoldes: CRI & Magic resistance" ,
        START_MESSAGE4 = "Olgeth: CRI & Physical resistance" ,
        GRAB_MESSAGE1 = "Holds a unit with the highest HP" ,
        HUMMER_MESSAGE1 = "Rage mode: Cancelled by certain CRI DMG" ,
        HUMMER_LOST_MESSAGE1 = "Rage mode Cancelled!" ,
    },
    [2036010] = {
        START_MESSAGE1 = " Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = " CRI resistance & Human Killer",
        START_MESSAGE3 = " Gronus: Fire resistance",
        START_MESSAGE4 = " Phonos: Light resistance",
        CHARGE_MESSAGE1 = " Shadow Lightning Stance",
        CHARGE_MESSAGE2 = " More power reduction with more DMG inflicting",
        SKILL2_MESSAGE1 = " Roar: DMG (50％ of MAX HP) & Status ailment RES. DOWN ",
        SUMMON_FIRE_MESSAGE1 = " Gronus has appeared!",
        SUMMON_LIGHT_MESSAGE1 = " Phonos appeared!",
        SUB_HP0_MESSAGE1 = " Shadow Lightning Stance cancelled by DMG taken! "
    },

    [2037130] = {
        DEAD_MESSAGE1 = "Ow...",
        HP50_MESSAGE1 = "Don't forget I'm a dragon slayer!",
        START_MESSAGE1 = "C'mon, let's rumble."
    },
    [2037136] = {
        DEAD_MESSAGE1 = "Aaagh!",
        HP50_MESSAGE1 = "If that's how it is...",
        START_MESSAGE1 = "Come at me!"
    },
    [2037142] = {
        DEAD_MESSAGE1 = "Take care...of the rest.",
        HP50_MESSAGE1 = "If that's how it is...",
        HP50_MESSAGE2 = "Lucy: DEF UP"
    },
    [2037144] = {
        DEAD_MESSAGE1 = "Shoot, I screwed up!",
        HP20_MESSAGE1 = "Can you handle the heat?!",
        HP20_MESSAGE2 = "Natsu's serious!",
        HP50_MESSAGE1 = "Don't forget I'm a dragon slayer!",
        HP50_MESSAGE2 = "Natsu: DEF UP",
        START_MESSAGE1 = "C'mon, let's rumble.",
        START_MESSAGE2 = "I won't give up.",
        START_MESSAGE3 = "DMG taken from Fire & Light units UP "
    },
    [2037154] = {
        DEAD_MESSAGE1 = "Take care...of the rest.",
        HP50_MESSAGE1 = "If that's how it is...",
        HP50_MESSAGE2 = "Lucy: DEF UP"
    },
    [2037155] = {
        DEAD_MESSAGE1 = "Shoot, I screwed up!",
        HP50_MESSAGE1 = "Can you handle the heat?!",
        HP50_MESSAGE2 = "Natsu's serious!",
        HP50_MESSAGE3 = "Natsu: DEF UP",
        START_MESSAGE1 = "C'mon, let's rumble.",
        START_MESSAGE2 = "I won't give up.",
        START_MESSAGE3 = "DMG taken from Fire & Light units UP "
    },
    [2037430] = {
        DEAD_MESSAGE1 = "That hurts...",
        HP50_MESSAGE1 = "Get a taste of this!",
        START_MESSAGE1 = "This'll be good."
    },
    [2037436] = {
        DEAD_MESSAGE1 = "Retreat!",
        HP50_MESSAGE1 = "Requip!",
        START_MESSAGE1 = "Let's get started."
    },
    [2037442] = {
        DEAD_MESSAGE1 = "Ugh...",
        HP50_MESSAGE1 = "Get a taste of this!",
        POWER_UP_MESSAGE = "Gray: Power UP"
    },
    [2037444] = {
        DEAD_GRAY_MESSAGE1 = "You'll pay for that.",
        DEAD_MESSAGE1 = "Forgive me.",
        HP50_MESSAGE1 = "Requip!",
        START_MESSAGE1 = "This'll be good.",
        START_MESSAGE2 = "Let's get started.",
        START_MESSAGE3 = "DMG taken from Water & Light units UP ",
        START_MESSAGE4 = "Erza: Counters the Arts ATK"
    },
    [2037454] = {
        DEAD_MESSAGE1 = "Ugh...",
        HP50_MESSAGE1 = "Get a taste of this!",
        HP50_MESSAGE2 = "Gray: DEF & CRI resistance UP",
        HP80_MESSAGE1 = "Gray: DEF UP"
    },
    [2037455] = {
        DEAD_GRAY_MESSAGE1 = "You'll pay for that.",
        DEAD_GRAY_MESSAGE2 = "Erza: ATK UP",
        DEAD_MESSAGE1 = "Forgive me.",
        HP50_MESSAGE1 = "Requip!",
        HP50_MESSAGE2 = "Erza: DEF & CRI resistance UP",
        HP80_MESSAGE1 = "Erza: DEF UP",
        POWER_UP2_MESSAGE = "Erza: ATK & DEF UP",
        POWER_UP_MESSAGE = "Gray, Erza: ATK & DEF UP",
        START_MESSAGE1 = "This'll be good.",
        START_MESSAGE2 = "Let's get started.",
        START_MESSAGE3 = "DMG taken from Fire, Water & Light units UP ",
        START_MESSAGE4 = "Dark & Earth Killer",
        START_MESSAGE5 = "Erza: Counters the Arts ATK"
    },

    [2037751] = {
        DEAD_MESSAGE1 = "Waaaaaah!",
        HP50_MESSAGE1 = "I refuse to lose!",
        START_MESSAGE1 = "Let's get to it!"
    },
    [2037761] = {
        DEAD_MESSAGE1 = "Waaaaaah!",
        HP50_MESSAGE1 = "I refuse to lose!",
        START_MESSAGE1 = "Let's get to it!"
    },
    [2037771] = {
        HP50_MESSAGE1 = "Powerful magic reaction detected!",
        START_MESSAGE1 = "DMG taken from Fire UP",
        START_MESSAGE2 = "DMG taken UP during Status Ailment"
    },
    [2037781] = {
        DEAD_MESSAGE1 = "I'm sorry, Gramps...",
        HP50_MESSAGE1 = "I refuse to lose!",
        START_MESSAGE1 = "Let's go, Gramps!",
        START_MESSAGE2 = "Yes, let's!"
    },
    [2037782] = {
        DEAD_MESSAGE1 = "Forgive me...Charlotte...",
        HP50_MESSAGE1 = "Ready to begin?"
    },

    [2037801] = {
        DEAD_MESSAGE1 = "",
        HP30_MESSAGE1 = "Third Eye: ATK UP",
        START_MESSAGE1 = "... ... ...",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Light Killer"
    },
    [2037802] = {
        DEAD_MESSAGE1 = "Defeated the Shinobi shadow!"
    },
    [2037803] = {
        DEAD_MESSAGE1 = "Defeated the Shinobi shadow!"
    },
    [2037804] = {
        HP20_MESSAGE1 = "Third Eye: Arts gauge filling faster",
        HP20_MESSAGE2 = "& Cancel DMG Negation",
        HP40_MESSAGE1 = "... ... ... ",
        HP40_MESSAGE2 = "The Shinobi shadow tests your 2 rightmost units!",
        HP70_MESSAGE1 = "... ... ... ",
        HP70_MESSAGE2 = "The Shinobi shadow tests your 2 leftmost units!",
        START_MESSAGE1 = "... ... ... ",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Light Killer"
    },
    [2037805] = {
        DEAD_MESSAGE1 = "",
        HP30_MESSAGE1 = "Third Eye: ATK UP",
        START_MESSAGE1 = "... ... ...",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Light Killer"
    },
    [2037806] = {
        DEAD_MESSAGE1 = "Defeated the Shinobi shadow!"
    },
    [2037807] = {
        DEAD_MESSAGE1 = "Defeated the Shinobi shadow!"
    },
    [2037808] = {
        HP20_MESSAGE1 = "Third Eye: Arts gauge filling faster",
        HP20_MESSAGE2 = "& Cancel DMG Negation",
        HP40_MESSAGE1 = "... ... ...",
        HP40_MESSAGE2 = "The Shinobi shadow tests your 2 rightmost units!",
        HP70_MESSAGE1 = "... ... ...",
        HP70_MESSAGE2 = "The Shinobi shadow tests your 2 leftmost units!",
        START_MESSAGE1 = "... ... ...",
        START_MESSAGE2 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Light Killer"
    },

    [2038651] = {
        DEAD_MESSAGE1 = "I'm still not ready...",
        HP100_MESSAGE1 = "I carry the hopes of Imari!",
        HP50_MESSAGE1 = "Seventh Heaven!",
        START_MESSAGE1 = "Prepared for combat!",
    },
    [2038661] = {
        DEAD_MESSAGE1 = "I'm still not ready...",
        HP100_MESSAGE1 = "I carry the hopes of Imari!",
        HP50_MESSAGE1 = "Seventh Heaven!",
        START_MESSAGE1 = "Prepared for combat!"
    },
    [2038671] = {
        START_MESSAGE1 = "DMG from Water UP",
        START_MESSAGE2 = "DMG taken UP when Phantom Beast is defeated",
        START_MESSAGE3 = "ATK DOWN when Phantom Beast is Blinded"
    },
    [2038681] = {
        START_MESSAGE1 = "DMG from Water UP",
        START_MESSAGE2 = "DMG taken UP when Phantom Beast is defeated",
        START_MESSAGE3 = "ATK DOWN when Phantom Beast is Blinded",
        START_MESSAGE4 = "Reflection & Arts gauge DOWN RES."
    },

    [2039551] = {
        DEAD_MESSAGE1 = "That was lame...",
        HP50_MESSAGE1 = "Don't tangle with Toman!",
        START_MESSAGE1 = "You asked for it."
    },
    [2039556] = {
        DEAD_MESSAGE1 = "Not half bad.",
        HP50_MESSAGE1 = "This fight's over.",
        START_MESSAGE1 = "You wanna die that bad?"
    },
    [2039561] = {
        START_MESSAGE1 = "ATK DOWN when units' are hit by Arts",
        START_MESSAGE2 = "ATK DOWN cancelled by Break",
        START_MESSAGE3 = "DMG taken from Human UP "
    },
    [2039571] = {
        START_MESSAGE1 = "ATK DOWN when units' are hit by Arts",
        START_MESSAGE2 = "ATK DOWN cancelled by Break",
        START_MESSAGE3 = "DMG taken from Human UP "
    },
    [2039581] = {
        START_MESSAGE1 = "ATK DOWN when units' are hit by enemy ATK",
        START_MESSAGE2 = "ATK DOWN cancelled by Break",
        START_MESSAGE3 = "DMG taken from Human UP "
    },
    [2039591] = {
        BREAK_MESSAGE1 = "Break! DMG taken UP!",
        DEAD_MESSAGE1 = "Speed Challenge Succeeded!",
        END_MESSAGE1 = "Speed Challenge failed...",
        START_MESSAGE1 = "Defeat it within 300s!",
        START_MESSAGE2 = "Magic resistance & DMG taken UP during Break"
    },

    [2039951] = {
        DEAD_MESSAGE1 = "Man, they're tough...",
        HP50_MESSAGE1 = "I'm nowhere near Baji-san's level yet!",
        START_MESSAGE1 = "Oh, we gonna brawl?"
    },
    [2039956] = {
        DEAD_MESSAGE1 = "That's too much...",
        HP50_MESSAGE1 = "Here it comes!",
        START_MESSAGE1 = "OK, you're on."
    },
    [2039961] = {
        HP_TRIGGER_MESSAGE1 = "CRI resistance DOWN",
        HP_TRIGGER_MESSAGE2 = "ATK UP",
        START_MESSAGE1 = "CRI resistance",
        START_MESSAGE2 = "DMG taken from Human UP "
    },
    [2039971] = {
        HP_TRIGGER_MESSAGE1 = "CRI resistance DOWN",
        HP_TRIGGER_MESSAGE2 = "ATK UP",
        START_MESSAGE1 = "CRI resistance",
        START_MESSAGE2 = "DMG taken from Human UP "
    },
    [2039981] = {
        HP_TRIGGER_MESSAGE1 = "CRI resistance DOWN",
        HP_TRIGGER_MESSAGE2 = "ATK UP",
        START_MESSAGE1 = "CRI resistance",
        START_MESSAGE2 = "DMG taken from Human UP "
    },
    [2039991] = {
        DEAD_MESSAGE1 = "Speed Challenge Succeeded!",
        END_MESSAGE1 = "Speed Challenge failed...",
        START_MESSAGE1 = "Burn, Freeze & Faint resistance",
        START_MESSAGE2 = "BE Output & DMG taken UP during Status Ailment",
        mess1 = "Damage towards Target UP",
        mess2 = "True Nightmare Stance",
        mess3 = "Sureshot"
    },
    [2039992] = {
        END_MESSAGE1 = "Speed Challenge failed...",
        START_MESSAGE1 = "Defeat it within 300s!",
        START_MESSAGE2 = "BE Output UP during Status Ailment"
    },
    [2039993] = {
        END_MESSAGE1 = "Speed Challenge failed...",
        HP30_MESSAGE1 = "I just don't like you!",
        START_MESSAGE1 = "Hehe, I'll teach you a lesson.",
        START_MESSAGE2 = "Burn, Freeze & Faint resistance",
        START_MESSAGE3 = "BE Output UP during Status Ailment"
    },
    [2039994] = {
        END_MESSAGE1 = "Speed Challenge failed...",
        HP30_MESSAGE1 = "Anyone here scared?!",
        START_MESSAGE1 = "Better not mess around!",
        START_MESSAGE2 = "Burn, Freeze & Faint resistance",
        START_MESSAGE3 = "BE Output UP during Status Ailment"
    },
    [2040260] = {
        DEAD_MESSAGE1 = "How regretful...",
        HP50_MESSAGE1 = "Prepare yourself!",
        SKILL_MESSAGE1 = "Witness the essence of Imari!",
        START_MESSAGE1 = ""
    },
    [2040265] = {
        DEAD_MESSAGE1 = "How regretful...",
        HP50_MESSAGE1 = "Prepare yourself!",
        SKILL_MESSAGE1 = "This is the Third Eye's ideal form!",
        START_MESSAGE1 = ""
    },
    [2040270] = {
        DEAD_MESSAGE1 = "",
        HP50_MESSAGE1 = "",
        START_MESSAGE1 = "DMG from Earth UP"
    },
    [2040275] = {
        DEAD_MESSAGE1 = "How regretful...",
        HP30_MESSAGE1 = "Prepare yourself!",
        SKILL_MESSAGE1 = "This is the Third Eye's ideal form!",
        START_MESSAGE1 = ""
    },

    [2040701] = {
        HP20_MESSAGE1 = "Physical resistance UP ",
        HP40_MESSAGE1 = "Arts gauge filling speed UP ",
        HP70_MESSAGE1 = "Arts gauge filling speed UP ",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "DMG Negation Canceled ",
        START_MESSAGE3 = "DMG & Evasion rate UP with the number of Grovogg/Cyclops ",
        SUMMON_MESSAGE1 = "Grovogg Joined! DMG taken UP if Poisoned ",
        SUMMON_MESSAGE2 = "Cyclops Joined! DMG taken UP if Diseased ",
    },
    [2040702] = {
        START_MESSAGE1 = "Grovogg: DMG taken & BE Output UP during Poison ",
    },
    [2040703] = {
        START_MESSAGE1 = "Cyclops: DMG taken & BE Output UP during Disease "
    },

    [2040960] = {
        START_MESSAGE1 = "DMG taken from Machines UP"
    },
    [2040965] = {
        START_MESSAGE1 = "DMG taken from Machines UP"
    },
    [2040970] = {
        START_MESSAGE1 = "DMG taken from Machines UP",
        START_MESSAGE2 = "Arts gauge UP every time unit uses Arts or True Arts"
    },
    [2040975] = {
        BREAK_MESSAGE1 = "DMG DOWN Cancelled DMG taken UP",
        CHANGE_MESSAGE1 = "Threat Lv.A CONFIRMED, EXECUTING",
        CHANGE_MESSAGE2 = "BREAK resistance UP",
        CHANGE_MESSAGE3 = "Attack mode: Attack Speed UP",
        HP0_MESSAGE1 = "Self-Destruct Sequence Active",
        HP0_MESSAGE2 = "Finis =Finis Machina Activated",
        HP20_MESSAGE1 = "Reinforcing armor for peculiar attacks",
        HP20_MESSAGE2 = "CRI resistance UP",
        HP50_MESSAGE0 = "No Elemental Energy",
        HP50_MESSAGE1 = "Fire Elemental Resistance UP",
        HP50_MESSAGE2 = "Water Elemental Resistance UP",
        HP50_MESSAGE3 = "Earth Elemental Resistance UP",
        HP50_MESSAGE4 = "Light Elemental Resistance UP",
        HP50_MESSAGE5 = "Dark Elemental Resistance UP",
        HP50_MESSAGE6 = "Analysis completed: Specialized armor deployed",
        START_MESSAGE1 = "WARNING: INTRUDER ALERT",
        START_MESSAGE2 = "DMG taken from Machines UP",
        START_MESSAGE3 = "Shield mode: DMG taken DOWN",
        START_MESSAGE4 = "Shield mode: Stacks Elemental DMG",
        START_MESSAGE5 = "DMG taken DOWN Cancelled during Break"
    },

    [2041460] = {
        DEAD_MESSAGE1 = "I can't keep going...",
        HP50_MESSAGE1 = "Never say never!",
        START_MESSAGE1 = "I win because I fight."
    },
    [2041465] = {
        DEAD_MESSAGE1 = "I can't keep going...",
        HP50_MESSAGE1 = "Never say never!",
        START_MESSAGE1 = "I win because I fight."
    },
    [2041470] = {
        START_MESSAGE1 = "Physical DMG from Water UP",
        START_MESSAGE2 = "Magic resistance UP when HP is Low"
    },
    [2041475] = {
        START_MESSAGE1 = "Physical DMG from Water UP",
        START_MESSAGE2 = "Magic resistance UP when HP is Low",
        START_MESSAGE3 = "Arts gauge DOWN & CRI resistance"
    },

    [2043414] = {
        DEAD_MESSAGE1 = "",
        HP0_MESSAGE1 = "My soul yet burns...",
        HP0_MESSAGE2 = "DMG UP",
        HP10_MESSAGE1 = "Even as my end nears...",
        HP10_MESSAGE2 = "DMG UP",
        HP20_MESSAGE1 = "I desire only the shinobi's true form.",
        HP20_MESSAGE2 = "DMG UP",
        HP30_MESSAGE1 = "Your life is mine for the taking.",
        HP30_MESSAGE2 = "DMG UP",
        HP50_MESSAGE1 = "I bear the long history of the shinobi.",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "CRI resistance & Demon Killer",
        START_MESSAGE3 = "CRI rate UP with more Shinobi",
        START_MESSAGE4 = "Shinobi: Light Killer & HP auto-recovery",
        START_MESSAGE5 = "Shinobi: DMG taken UP during Disease",
        SUMMON_MESSAGE1 = "Shinobi joined"
    },
    [2043416] = {
        START_MESSAGE1 = "Shinobi: Light Killer & HP auto-recovery",
        START_MESSAGE2 = "Shinobi: DMG taken UP during Disease",
        AFTER_MD = "Nirvana \"Udonge-setsu\"",
        BEFORE_MD = "Third Eye"
    },
    [2043417] = {
        START_MESSAGE1 = "Shinobi: Light Killer & HP auto-recovery",
        START_MESSAGE2 = "Shinobi: DMG taken UP during Disease",
        AFTER_MD = "Nirvana \"Udonge-setsu\"",
        BEFORE_MD = "Third Eye"
    },
    [2043418] = {
        DEAD_MESSAGE1 = "",
        HP0_MESSAGE1 = "My soul yet burns...",
        HP0_MESSAGE2 = "DMG UP",
        HP10_MESSAGE1 = "Even as my end nears...",
        HP10_MESSAGE2 = "DMG UP",
        HP20_MESSAGE1 = "I desire only the shinobi's true form.",
        HP20_MESSAGE2 = "DMG UP",
        HP30_MESSAGE1 = "Your life is mine for the taking.",
        HP30_MESSAGE2 = "DMG UP",
        HP50_MESSAGE1 = "I bear the long history of the shinobi.",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "CRI resistance & Demon Killer",
        START_MESSAGE3 = "CRI rate UP with more Shinobi",
        START_MESSAGE4 = "Shinobi: Light Killer & HP auto-recovery",
        START_MESSAGE5 = "Shinobi: DMG taken UP during Disease",
        SUMMON_MESSAGE1 = "Shinobi joined"
    },
    [2043420] = {
        START_MESSAGE1 = "Shinobi: Light Killer & HP auto-recovery",
        START_MESSAGE2 = "Shinobi: DMG taken UP during Disease",
        AFTER_MD = "Nirvana \"Udonge-setsu\"",
        BEFORE_MD = "Third Eye"
    },
    [2043421] = {
        START_MESSAGE1 = "Shinobi: Light Killer & HP auto-recovery",
        START_MESSAGE2 = "Shinobi: DMG taken UP during Disease",
        AFTER_MD = "Nirvana \"Udonge-setsu\"",
        BEFORE_MD = "Third Eye"
    },
    [2043670] = {
        START_MESSAGE1 = "Physical DMG from Fire UP"
    },
    [2043675] = {
        START_MESSAGE1 = "Evasion rate UP (Decreasing gradually)"
    },

    [2044270] = {
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Light units UP ",
        START_MESSAGE3 = "Physical DMG taken UP"
    },
    [2044275] = {
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Light units UP ",
        START_MESSAGE3 = "Physical DMG taken UP"
    },

    [2045170] = {
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Light & Dark UP"
    },
    [2045175] = {
        LOSE_MESSAGE1 = "Failed to reach cumulative DMG of 200 million",
        START_MESSAGE1 = "Super-recovery",
        START_MESSAGE2 = "Negates Reflection",
        START_MESSAGE3 = "Fire, Water, and Earth resistance",
        START_MESSAGE4 = "To clear:Deal 200 million DMG in less than 150s!",
        RESULT_MESSAGE1 = "Total:",
        RESULT_MESSAGE2 = " DMG!!",
        RESULT_MESSAGE3 = "Most single-hit:",
        DAMAGE_MESSAGE1 = "%d0000",
        DAMAGE_MESSAGE2 = "%d",
        DAMAGE_MESSAGE3 = " DMG!",
        DAMAGE_MESSAGE4 = "Single-hit:",
        DAMAGE_MESSAGE5 = " DMG!",
    },
    [2045570] = {
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Light & Dark UP",
        START_MESSAGE3 = "ATK & DEF UP over time"
    },
    [2045575] = {
        LOSE_MESSAGE1 = "Failed to reach cumulative DMG of 200 million",
        START_MESSAGE1 = "Super-recovery",
        START_MESSAGE2 = "Negates Reflection",
        START_MESSAGE3 = "Fire, Water, and Earth resistance",
        START_MESSAGE4 = "DMG taken UP during Break",
        START_MESSAGE5 = "To clear:Deal 200 million DMG in less than 150s!",
        RESULT_MESSAGE1 = "Total:",
        RESULT_MESSAGE2 = " DMG!!",
        RESULT_MESSAGE3 = "Most single-hit:",
        DAMAGE_MESSAGE1 = "%d0000",
        DAMAGE_MESSAGE2 = "%d",
        DAMAGE_MESSAGE3 = " DMG!",
        DAMAGE_MESSAGE4 = "Single-hit:",
        DAMAGE_MESSAGE5 = " DMG!"
    },

    [2045960] = {
        DEAD_MESSAGE1 = "Surely you aren't through yet.",
        HP50_MESSAGE1 = "I'm tired of this.",
        START_MESSAGE1 = "It's so hard to hold back."
    },
    [2045965] = {
        DEAD_MESSAGE1 = "Surely you aren't through yet.",
        HP50_MESSAGE1 = "Open the door to darkness.",
        START_MESSAGE1 = "It's so hard to hold back."
    },
    [2045970] = {
        DEAD_MESSAGE1 = "And right when I was enjoying myself...",
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "I'm tired of this.",
        HP70_MESSAGE1 = "Target's DMG taken UP",
        HP70_MESSAGE2 = "Open the door to darkness.",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "DMG UP to the unit inflicts highest DMG",
        START_MESSAGE4 = "It's so hard to hold back."
    },
    [2045975] = {
        DEAD_MESSAGE1 = "Is this...defeat?",
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Target's DMG taken UP",
        HP50_MESSAGE2 = "Open the door to darkness.",
        HP70_MESSAGE1 = "Target's DMG taken UP",
        HP70_MESSAGE2 = "Open the door to darkness.",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "DMG UP to the unit inflicts highest DMG",
        START_MESSAGE4 = "It's so hard to hold back."
    },

    [2046260] = {
        DEAD_MESSAGE1 = "But I never gave you my chocolate...",
        HP50_MESSAGE1 = "More hustle!",
        START_MESSAGE1 = "I hope you like it!"
    },
    [2046265] = {
        DEAD_MESSAGE1 = "Why are you running away?",
        HP50_MESSAGE1 = "More hustle!",
        START_MESSAGE1 = "Don't be shy now!"
    },
    [2046270] = {
        DEAD_MESSAGE1 = "I still have...more...",
        DEFENCE_MESSAGE1 = "DEF UP",
        HP50_MESSAGE1 = "Can you accept my feelings?",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Fire & Light units UP",
        START_MESSAGE4 = "Don't worry, it'll be OK."
    },
    [2046275] = {
        DEAD_MESSAGE1 = "Goodness me...",
        START_MESSAGE1 = "Hehe, do you know what today is?"
    },

    [2046360] = {
        DEAD_MESSAGE1 = "Eeeeek!",
        HP50_MESSAGE1 = "Today is special!",
        START_MESSAGE1 = "Here I go!"
    },
    [2046365] = {
        DEAD_MESSAGE1 = "But my rehearsal was flawless...",
        HP50_MESSAGE1 = "I'm not beaten yet!",
        START_MESSAGE1 = "Wait, let me take a deep breath!"
    },
    [2046370] = {
        DEAD_MESSAGE1 = "That's all I can do today...!",
        HP50_MESSAGE1 = "I'm not beaten yet!",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Fire & Light units UP ",
        START_MESSAGE4 = "Today is a special day!"
    },
    [2046375] = {
        DEAD_MESSAGE1 = "No...way...",
        START_MESSAGE1 = "DMG from Human units UP",
        START_MESSAGE2 = "Ahh, I'm starting to get nervous!"
    },

    [2046970] = {
        BREAK_MESSAGE1 = "Break! DMG taken DOWN canceled",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Spirit units UP",
        START_MESSAGE3 = "DMG from Water units UP",
        START_MESSAGE4 = "DMG taken DOWN canceled by Break"
    },
    [2046975] = {
        START_MESSAGE1 = "DMG from Spirit units UP"
    },

    [2047260] = {
        WEATHER_MESSAGE1 = "Field effects changing",
        WEATHER_TYPE_MESSAGE1_1 = "Thunderstorm: Unit's MAX HP 5% DOWN",
        WEATHER_TYPE_MESSAGE3_1 = "Acid Rain: Units' DEF 15% DOWN",
        WEATHER_TYPE_MESSAGE4_1 = "Thunderstorm: Unit's MAX HP & ATK 10% DOWN",
        WEATHER_TYPE_MESSAGE5_1 = "Gale: Units' Accuracy 15% DOWN",
        WEATHER_TYPE_MESSAGE5_2 = "Gale: Units' DMG 70% DOWN (Except Fire units)"
    },
    [2047265] = {
        WEATHER_MESSAGE1 = "Field effects changing",
        WEATHER_TYPE_MESSAGE1_1 = "Thunderstorm: Unit's MAX HP 5% DOWN",
        WEATHER_TYPE_MESSAGE3_1 = "Acid Rain: Units' DEF 15% DOWN",
        WEATHER_TYPE_MESSAGE4_1 = "Thunderstorm: Unit's MAX HP & ATK 10% DOWN",
        WEATHER_TYPE_MESSAGE5_1 = "Gale: Units' Accuracy 15% DOWN",
        WEATHER_TYPE_MESSAGE5_2 = "Gale: Units' DMG 70% DOWN (Except Fire units)"
    },
    [2047270] = {
        HP10_MESSAGE1 = "My scales are steeped in miasma...in madness.",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "DMG from Fire units UP",
        START_MESSAGE4 = "Physical resistance UP",
        WEATHER_MESSAGE1 = "Field effects changing",
        WEATHER_TYPE_MESSAGE1_1 = "Thunderstorm: Unit's MAX HP 5% DOWN",
        WEATHER_TYPE_MESSAGE3_1 = "Acid Rain: Units' DEF 15% DOWN",
        WEATHER_TYPE_MESSAGE4_1 = "Thunderstorm: Unit's MAX HP & ATK 10% DOWN",
        WEATHER_TYPE_MESSAGE5_1 = "Gale: Units' Accuracy 15% DOWN",
        WEATHER_TYPE_MESSAGE5_2 = "Gale: Units' DMG 70% DOWN (Except Fire units)"
    },
    [2047275] = {
        DEAD_MESSAGE1 = "I'm no good...",
        HP50_MESSAGE1 = "I must fight.",
        START_MESSAGE1 = "DMG from Demon units UP",
        START_MESSAGE2 = "It's finally my turn!"
    },

    [2047660] = {
        DEAD_MESSAGE1 = "What...?",
        HP50_MESSAGE1 = "Sword of the Black Knight.",
        START_MESSAGE1 = "Offer up your blood."
    },
    [2047670] = {
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Demons UP",
        START_MESSAGE3 = "DMG from Dark units UP",
        START_MESSAGE4 = "DMG UP every time Arts is used"
    },
    [2047680] = {
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Demon & Dark units UP",
        START_MESSAGE3 = "Magic resistance UP",
        START_MESSAGE4 = "DMG UP every time Arts is used"
    },

    [2047960] = {
        HP_TRIGGER_MESSAGE1 = "Evasion rate UP",
        HP_TRIGGER_MESSAGE2 = "DMG UP",
        START_MESSAGE1 = "The lower HP, the Evasion rate & DMG UP"
    },
    [2047965] = {
        HP_TRIGGER_MESSAGE1 = "Evasion rate UP",
        HP_TRIGGER_MESSAGE2 = "DMG UP",
        START_MESSAGE1 = "The lower HP, the Evasion rate & DMG UP"
    },
    [2047970] = {
        HP_TRIGGER_MESSAGE1 = "Evasion rate UP",
        HP_TRIGGER_MESSAGE2 = "DMG UP",
        SKILL_MESSAGE1 = "Powerful Megido Flame incoming!",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Water units UP",
        START_MESSAGE4 = "The lower HP, the Evasion rate & DMG UP"
    },
    [2047975] = {
        DEAD_MESSAGE1 = "You actually got...skills...",
        HP50_MESSAGE1 = "Time to let loose!",
        START_MESSAGE1 = "DMG from Human units UP",
        START_MESSAGE2 = "Sure, I'm game."
    },

    [2048260] = {
        START_MESSAGE1 = "Get ready for a big bang!",
        HP50_MESSAGE1 = "I'll use everything I got!",
        DEAD_MESSAGE1 = "...Good-bye. *whump*"
    },
    [2048270] = {
        START_MESSAGE1 = "DMG from Poisoned units DOWN",
        START_MESSAGE2 = "Negates Reflection",
        START_MESSAGE3 = "DMG from Human units UP",
        START_MESSAGE4 = "DMG from Light & Fire units UP"
    },
    [2048280] = {
        START_MESSAGE1 = "DMG from Poisoned units DOWN",
        START_MESSAGE2 = "Negates Reflection",
        START_MESSAGE3 = "DMG from Human units UP",
        START_MESSAGE4 = "DMG from Light & Fire units UP",
        HP25_MESSAGE1 = "Caution! Huge DMG to Poisoned enemy!"
    },

    [2048660] = {
        DEAD_MESSAGE1 = "No, this can't be real...",
        HP50_MESSAGE1 = "Class Card Lancer: Install.",
        START_MESSAGE1 = "Let's go, Sapphire."
    },
    [2048665] = {
        DEAD_MESSAGE1 = "Not here... Not now...",
        HP50_MESSAGE1 = "I'll blow you away.",
        START_MESSAGE1 = "Do you have the resolve, Hero of Justice?"
    },
    [2048670] = {
        DEAD_MESSAGE1 = "Not here... Not now...",
        HP50_MESSAGE1 = "I'll blow you away.",
        START_MESSAGE1 = "DMG from Human units UP",
        START_MESSAGE2 = "DMG from Dark & Water units UP",
        START_MESSAGE3 = "Do you have the resolve, Hero of Justice?"
    },
    [2048680] = {
        DEAD_MESSAGE1 = "Did I...make the wrong choice?",
        HP20_MESSAGE1 = "I'll fight...",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Dark & Water units UP",
        START_MESSAGE4 = "I am the bone of my sword."
    },
    [2048960] = {
        DEAD_MESSAGE1 = "Wahhhhh!",
        HP50_MESSAGE1 = "How about this?",
        START_MESSAGE1 = "I'll kill you real quick!"
    },
    [2048970] = {
        START_MESSAGE1 = "DMG from Human units UP",
        START_MESSAGE2 = "DMG from Fire & Dark units UP"
    },
    [2048980] = {
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Fire & Dark units UP"
    },

    [2050260] = {
        DEAD_MESSAGE1 = "Wipe out...",
        HP50_MESSAGE1 = "I won't let this one get away.",
        START_MESSAGE1 = "Can you hang with me?"
    },
    [2050265] = {
        DEAD_MESSAGE1 = "Wipe out...",
        HP50_MESSAGE1 = "I won't let this one get away.",
        START_MESSAGE1 = "Can you hang with me?"
    },
    [2050270] = {
        DEAD_MESSAGE1 = "Wipe out...",
        HP50_MESSAGE1 = "This is the wave I've been waiting for!",
        SKILL_MESSAGE1 = "DMG & ATK UP by # of active Mikyuons",
        SKILL_MESSAGE2 = "Defeat Mikyuons with # of hits",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Water units UP",
        START_MESSAGE4 = "Can you hang with me?"
    },
    [2050280] = {
        DEAD_MESSAGE1 = "Wipe out...",
        HP50_MESSAGE1 = "This is the wave I've been waiting for!",
        SKILL_MESSAGE1 = "DMG & ATK UP by # of active Mikyuons",
        SKILL_MESSAGE2 = "Defeat Mikyuons with # of hits",
        START_MESSAGE1 = "CRI resistance & negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Water units UP",
        START_MESSAGE4 = "Can you hang with me?"
    },

    [2050460] = {
        DEAD_MESSAGE1 = "I'm tired...",
        HP50_MESSAGE1 = "Bring it over, Rolly!",
        SKILL_MESSAGE1 = "ATK UP",
        START_MESSAGE1 = "I'm so excited!"
    },
    [2050465] = {
        DEAD_MESSAGE1 = "I'm tired...",
        HP50_MESSAGE1 = "Bring it over, Rolly!",
        SKILL_MESSAGE1 = "ATK UP",
        START_MESSAGE1 = "I'm so excited!"
    },
    [2050470] = {
        DEAD_MESSAGE1 = "I'm turning red!",
        HP50_MESSAGE1 = "This one's special!",
        SKILL_MESSAGE1 = "ATK UP",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from God units UP",
        START_MESSAGE3 = "DMG from Fire units UP",
        START_MESSAGE4 = "I'm so excited!"
    },
    [2050480] = {
        DEAD_MESSAGE1 = "I'm turning red!",
        HP50_MESSAGE1 = "This one's special!",
        SKILL_MESSAGE1 = "ATK UP",
        SKILL_MESSAGE2 = "DEF UP",
        START_MESSAGE1 = "Negates Reflection & CRI resistance",
        START_MESSAGE2 = "DMG from God units UP",
        START_MESSAGE3 = "DMG from Fire Units UP",
        START_MESSAGE4 = "Iris's DEF UP depends on # of Burning units",
        START_MESSAGE5 = "I'm so excited!"
    },

    [2050660] = {
        AFTER_MD = "Meteor Dance \"Seika Ryogen\"",
        BEFORE_MD = "Third Eye",
        START_MESSAGE1 = "I, Kisaragi, will face you.",
        DEAD_MESSAGE1 = "How could I be so careless?",
        HP50_MESSAGE1 = "Soar through the air..."
    },
    [2050665] = {
        DEAD_MESSAGE1 = "How could I be so careless?",
        HP50_MESSAGE1 = "Soar through the air...",
        START_MESSAGE1 = "I, Kisaragi, will face you.",
        AFTER_MD = "Meteor Dance \"Seika Ryogen\"",
        BEFORE_MD = "Third Eye"
    },
    [2050670] = {
        AFTER_MD = "Meteor Dance \"Seika Ryogen\"",
        BEFORE_MD = "Third Eye",
        DEAD_MESSAGE1 = "How could I be so careless?",
        HP50_MESSAGE1 = "Soar through the air...",
        SKILL_MESSAGE1 = "Kisaragi: ATK UP when near death from this Arts",
        SKILL_MESSAGE2 = "ATK UP",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Humans UP",
        START_MESSAGE3 = "DMG from Fire & Earth units UP",
        START_MESSAGE4 = "I, Kisaragi, will face you.",
        START_WAVE_MESSAGE1 = "My powers awaken..."
    },
    [2050675] = {
        DEAD_MESSAGE1 = "How could I be so careless?",
        HP50_MESSAGE1 = "Soar through the air...",
        SKILL_MESSAGE1 = "Kisaragi: ATK UP when near death from this Arts",
        SKILL_MESSAGE2 = "ATK UP",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Humans UP",
        START_MESSAGE3 = "DMG from Fire & Earth units UP",
        START_MESSAGE4 = "I, Kisaragi, will face you.",
        START_WAVE_MESSAGE1 = "My powers awaken...",
        AFTER_MD = "Meteor Dance \"Seika Ryogen\"",
        BEFORE_MD = "Third Eye"
    },

    [2050960] = {
        DEAD_MESSAGE1 = "What? Impossible...",
        HP50_MESSAGE1 = "I hope you're prepared.",
        START_MESSAGE1 = "Observe the Demons' might."
    },
    [2050965] = {
        DEAD_MESSAGE1 = "What? Impossible...",
        HP50_MESSAGE1 = "I hope you're prepared.",
        START_MESSAGE1 = "Observe the Demons' might."
    },
    [2050970] = {
        DEAD_MESSAGE1 = "This is absurd! Absurrrrrrrd!",
        HP50_MESSAGE1 = "I hope you're prepared.",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Humans UP",
        START_MESSAGE3 = "DMG from Dark & Light units UP",
        START_MESSAGE4 = "DMG taken DOWN canceled by Break",
        START_MESSAGE5 = "Bwahaha! Let's begin the execution!"
    },
    [2050975] = {
        DEAD_MESSAGE1 = "This is absurd! Absurrrrrrrd!",
        HP25_MESSAGE1 = "You inferior creatures haven't won yet!",
        HP50_MESSAGE1 = "I hope you're prepared.",
        START_MESSAGE1 = "Negates Reflection & CRI resistance",
        START_MESSAGE2 = "DMG from Humans UP",
        START_MESSAGE3 = "DMG from Dark & Light units UP",
        START_MESSAGE4 = "DMG taken DOWN canceled by Break",
        START_MESSAGE5 = "Bwahaha! Let's begin the execution!"
    },

    [2060060] = {
        DEAD_MESSAGE1 = "Yay, violence...",
        HP50_MESSAGE1 = "Yeah, yeah, yeah! Summer vacation is here!",
        START_MESSAGE1 = "Ready, set, dive in!"
    },
    [2060065] = {
        DEAD_MESSAGE1 = "You're terrible, Senpai...",
        HP50_MESSAGE1 = "The only one who can kill Senpai is me.",
        START_MESSAGE1 = "The Holy Grail War begins."
    },
    [2060070] = {
        DEAD_MESSAGE1 = "Priiiiiyaaaaa...",
        HP50_MESSAGE1 = "Pri-pri-pri!",
        HP5_MESSAGE1 = "Pri-pri-pri-pri!",
        HP5_MESSAGE2 = "Major heat levels detected!",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Water & Dark units UP",
        START_MESSAGE4 = "Priiiiyaaaa!"
    },
    [2060080] = {
        DEAD_MESSAGE1 = "Priiiiiyaaaaa...",
        HP50_MESSAGE1 = "ATK UP every 10s",
        HP50_MESSAGE2 = "Pri-pri-pri!",
        HP5_MESSAGE1 = "Pri-pri-pri-pri!",
        HP5_MESSAGE2 = "Major heat levels detected!",
        START_MESSAGE1 = "Reflection resistance & Shield Killer",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Water & Dark units UP",
        START_MESSAGE4 = "Priiiiyaaaa!"
    },

    [2062260] = {
        DEAD_MESSAGE1 = "*whimper* I'm sowwy!",
        HP50_MESSAGE1 = "So many snacks! One, two...lots!",
        START_MESSAGE1 = "I'll join the hunt!"
    },
    [2062265] = {
        DEAD_MESSAGE1 = "*whimper* I'm sowwy!",
        HP50_MESSAGE1 = "Boss Man will give me a treat if I win!",
        START_MESSAGE1 = "I'm on a secret mission!"
    },
    [2062270] = {
        DEAD_MESSAGE1 = "Forgive me, Shadow.",
        HP20_MESSAGE2 = "DMG taken DOWN during Super Arts",
        HP50_MESSAGE2 = "DMG taken DOWN during Arts",
        START_MESSAGE1 = "Criminals must be punished.",
        START_MESSAGE2 = "DMG from Beast & Sprit units UP",
        START_MESSAGE3 = "DMG from Fire & Light units UP",
        START_MESSAGE4 = "Arts gauge Down & Reflection resistance",
        hp20_MESSAGE1 = "Your suffering ends here.",
        hp50_MESSAGE1 = "I won't kill you."
    },
    [2062290] = {
        START_MESSAGE1 = "Super recovery",
        START_MESSAGE2 = "DMG taken UP for The Eminence in Shadow crossover units"

    },

    [2063900] = {
        HP50_MESSAGE1 = "Arts gauge filling speed UP"
    },
    [2063905] = {
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "DMG taken UP during Blind",
        START_MESSAGE2 = "Physical resistance"
    },
    [2063910] = {
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "Canceles DMG Negation"
    },
    [2063915] = {
        HP40_MESSAGE1 = "CRI resistance & Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "ATK & DMG UP over time"
    },
    [2063920] = {
        BREAK_MESSAGE1 = "Break! Shield canceled!",
        HP20_MESSAGE1 = "Arts gauge filling speed UP",
        HP20_MESSAGE2 = "Shield deployed: canceled by Break",
        HP80_MESSAGE1 = "Arts gauge filling speed UP",
        HP80_MESSAGE2 = "Shield deployed: canceled by Break",
        SKILL_MESSAGE1 = "Boss' DMG UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance"
    },
    [2063925] = {
        BREAK_MESSAGE1 = "Break! Shield canceled!",
        HP20_MESSAGE1 = "Arts gauge filling speed UP",
        HP20_MESSAGE2 = "Shield deployed: canceled by Break",
        HP80_MESSAGE1 = "Arts gauge filling speed UP",
        HP80_MESSAGE2 = "Shield deployed: canceled by Break",
        SKILL_MESSAGE1 = "Boss' DMG UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance"
    },
    [2063926] = {
        HP20_MESSAGE1 = "Arts gauge filling speed UP",
        HP60_MESSAGE1 = "Arts gauge filling speed UP"
    },

    [2061060] = {
        DEAD_MESSAGE1 = "That worked up quite a sweat.",
        HP50_MESSAGE1 = "I invite you to paradise.",
        START_MESSAGE1 = "Whenever you are ready."
    },
    [2061065] = {
        DEAD_MESSAGE1 = "That worked up quite a sweat.",
        HP50_MESSAGE1 = "The flame of glory will guide you.",
        START_MESSAGE1 = "Whenever you are ready."
    },
    [2061070] = {
        DEAD_MESSAGE1 = "I think...I played too much...",
        HP100_MESSAGE1 = "The flame of glory will guide you.",
        HP50_MESSAGE1 = "The flame of glory will guide you.",
        START_MESSAGE1 = "Whenever you are ready.",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Water & Dark units UP",
        START_MESSAGE4 = "Arts gauge DOWN & Reflection resistance "
    },
    [2061075] = {
        DEAD_MESSAGE1 = "I'm parched...",
        HP_MESSAGE1 = "Evasion rate UP",
        START_MESSAGE1 = "I'll quench that thirst of yours.",
        START_MESSAGE2 = "Evasion rate UP every time HP trigger point reached"
    },

    [2061100] = {
        EXTRA_CANCEL_MESSAGE1 = "Charge mode canceled!",
        EXTRA_CANCEL_MESSAGE2 = "Gradis is Flinching!",
        EXTRA_MESSAGE1 = "Charge mode: DMG taken DOWN & Arts gauge filling speed UP",
        EXTRA_MESSAGE2 = "Charge mode canceled with enough DMG",
        EXTRA_TIMEUP_MESSAGE1 = "Failed to cancel Charge mode: Huge DMG to Player units!",
        HP10_MESSAGE1 = "Physical & Magic resistance UP"
    },
    [2061105] = {
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "DMG taken UP during Burn & Freeze",
        START_MESSAGE2 = "Physical resistance"
    },
    [2061110] = {
        START_MESSAGE1 = "Cancels DMG Negation",
        HP50_MESSAGE1 = "ATK UP",
        HP20_MESSAGE1 = "Arts gauge filling speed UP"
    },
    [2061115] = {
        BREAK_MESSAGE1 = "Break! DMG taken UP!",
        BREAK_MESSAGE2 = "Break resistance UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "More Break, more DMG taken"
    },
    [2061120] = {
        BREAK1_MESSAGE1 = "Break! Status Ailment resistance canceled!",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Status Ailment resistance: Canceled by Break",
        START_MESSAGE3 = "DMG taken UP during Burn & Freeze"
    },
    [2061125] = {
        BREAK1_MESSAGE1 = "Break! Status Ailment resistance canceled!",
        BREAK2_MESSAGE2 = "Break resistance UP",
        HP40_MESSAGE1 = "CRI resistance UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Status Ailment resistance: Canceled by Break",
        START_MESSAGE3 = "DMG taken UP during Burn & Freeze"
    },
    [2061126] = {
        START_MESSAGE1 = "Reflection & Water resistance",
        SKILL_MESSAGE1 = "Party MAX HP DOWN"
    },
    [2061135] = {
        HP0_MESSAGE1 = "CRI rate UP",
        HP50_MESSAGE1 = "Dark mode: Fire, Watere, & Earth resistance",
        SKILL_MESSAGE1 = "Party MAX HP DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "CRI resistance",
        START_MESSAGE3 = "Light mode: Light & Dark resistance"
    },
    [2061136] = {
        HP30_MESSAGE1 = "Physical resistance & Arts gauge filling speed UP",
        HP70_MESSAGE1 = "Physical ressistance UP",
        SKILL_MESSAGE1 = "Party ATK DOWN",
        START_MESSAGE1 = "Reflection resistance & Earth Killer"
    },
    [2061140] = {
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        BUFF_MESSAGE1 = "Ignores DEF",
        BUFF_MESSAGE2 = "HP auto-recovery",
        BUFF_MESSAGE3 = "DMG UP",
        START_MESSAGE = "Negates DMG & Break from Fire units"
    },
    [2061145] = {
        HP50_MESSAGE1 = "CRI & Freeze resistance",
        HP50_MESSAGE2 = "Arts gauge filling speed UP",
        ICE_MESSAGE1 = "Freeze resistance UP",
        SKILL_MESSAGE1 = "Blazing inpact",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG taken UP during Freeza & CRI",
        START_MESSAGE3 = "HP degeneration",
        SUMMON_DEAD_MESSAGE1 = "Flame spirits Freeze RES. DOWN when Corogran defeted",
        SUMMON_MESSAGE1 = "Corogran: Physical resistance",
        BUFF_MESSAGE1 = "Negates DEF",
        BUFF_MESSAGE2 = "HP auto-recovery",
        BUFF_MESSAGE3 = "DMG UP",
        START_MESSAGE = "Negates DMG & Break from Fire units "
    },
    [2061160] = {
        HP60_MESSAGE1 = "CRI resistance UP",
        HP80_MESSAGE1 = "Physical resistance UP",
        START_MESSAGE1 = "Reflection, Lifesteal, and Arts gauge DOWN RES."
    },
    [2061165] = {
        ATTACK4_MESSAGE1 = "Arts gauge DOWN",
        HP30_MESSAGE1 = "Arts gauge filling speed UP & DMG Negation canceled",
        HP60_MESSAGE1 = "CRI resistance UP",
        HP80_MESSAGE1 = "Physical resistance UP",
        START_MESSAGE1 = "Arts gauge filling speed UP & DMG Negation canceled",
        START_MESSAGE2 = "Targets the unit inflicts highest DMG",
        START_MESSAGE3 = "CRI rate UP to a target",
        START_MESSAGE4 = "DMG taken UP by # of units' Elements in party"
    },
    [2061166] = {
        HP30_MESSAGE1 = "Arts gauge filling speed & DEF UP",
        HP60_MESSAGE1 = "Arts gauge filling speed & CRI resistance UP",
        SKILL3_MESSAGE1 = "Party Status Ailment resistance DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN reistance ",
        START_MESSAGE2 = "Evasion rate UP from Poisoned enemy",
        START_MESSAGE3 = "DMG taken DOWN (Except Fire units) "
    },
    [2061170] = {
        EXGAGE_MESSAGE1 = "DMG DOWN canceled by Magic DMG",
        EXGAGE_MESSAGE2 = "DMG DOWN canceled by Physical DMG",
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        HP30_MESSAGE2 = "DMG UP to the unit covers another unit",
        HP60_MESSAGE1 = "Action speed UP",
        HP60_MESSAGE2 = "DMG UP to the unit covers another unit",
        SKILL9_MESSAGE1 = "Absorbs Wyrms and Arts gauge UP",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Arts DMG UP to Sealed enemy"
    },
    [2061177] = {
        DEAD_MESSAGE1 = "Charging power by defeating 4 or more Wyrm: Party all Status UP",
        DEAD_MESSAGE2 = "Charging power by defeating 4 or more Wyrm: Leader DEF UP",
        DEAD_MESSAGE3 = "Charging power by defeating 3 Wyrm: Party all Status UP",
        DEAD_MESSAGE4 = "Charging power by defeating 2 Wyrm: Party ATK UP",
        DEAD_MESSAGE5 = "Acid Spray by 4 Wyms: Party DMG taken UP",
        SKILL_MESSAGE1 = "Catastrophic Spray by 5 Wyms",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Arts activated after certain period of time",
        START_MESSAGE3 = "States UP by defeating 2 or more Wyms"
    },
    [2061180] = {
        EXGAGE_MESSAGE1 = "DMG DOWN canceled by Magic DMG",
        EXGAGE_MESSAGE2 = "DMG DOWN canceled by Physical DMG",
        EXGAGE_MESSAGE3 = "Party ATK DOWN after certain period of time",
        EXGAGE_MESSAGE4 = "DMG DOWN canceled: DOWN amount reduced to half",
        HP0_MESSAGE1 = "I'll drag you down with me...!",
        HP0_MESSAGE2 = "Shield Killer",
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        HP30_MESSAGE2 = "DMG UP to the unit covers another unit",
        HP60_MESSAGE1 = "Action speed UP",
        HP60_MESSAGE2 = "DMG UP to the unit covers another unit",
        SKILL9_MESSAGE1 = "Absorbs Wyrms and Arts gauge UP",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Arts DMG UP to Sealed enemy",
        SUMMON_MESSAGE1 = "Gold Wyrm: Negates CRI DMG taken",
        SUMMON_MESSAGE2 = "Gold Wyrm: DEF UP"
    },
    [2061187] = {
        DEAD_MESSAGE1 = "Charging power by defeating 4 or more Wyrm: Party all Status UP",
        DEAD_MESSAGE2 = "Charging power by defeating 4 or more Wyrm: Leader DEF UP",
        DEAD_MESSAGE3 = "Charging power by defeating 3 Wyrm: Party all Status UP",
        DEAD_MESSAGE4 = "Charging power by defeating 2 Wyrm: Party ATK UP",
        DEAD_MESSAGE5 = "Acid Spray by 4 Wyms: Party DMG taken UP",
        SKILL_MESSAGE1 = "Catastrophic Spray by 5 Wyms",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Arts activated after certain period of time",
        START_MESSAGE3 = "States UP by defeating 2 or more Wyms"
    },
    
    [2061860] = {
        DEAD_MESSAGE1 = "I'm sorry, Master Shadow...",
        HP50_MESSAGE1 = "I'm the only one charming enough to take this role.",
        START_MESSAGE1 = "A world of darkness, most suitable for us."
    },
    [2061865] = {
        DEAD_MESSAGE1 = "I'm sorry, Master Shadow...",
        HP50_MESSAGE1 = "All I owe to the wisdom of shadows.",
        START_MESSAGE1 = "A world of darkness, most suitable for us."
    },
    [2061870] = {
        DEAD_MESSAGE1 = "Hmph, that was embarrassing.",
        HP50_MESSAGE1 = "How do you survive a nuke? Become the nuke.",
        HP50_MESSAGE2 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "The time has come. This night is a world of shadow.",
        START_MESSAGE2 = "DMG from Human & Spirit units UP",
        START_MESSAGE3 = "DMG from Water & Dark units UP",
        START_MESSAGE4 = "Arts gauge Down & Reflection resistance"
    },
    [2061880] = {
        DEAD_MESSAGE1 = "Hmph, that was embarrassing.",
        HP20_MESSAGE1 = "I am atomic.",
        HP20_MESSAGE2 = "Arts gauge filling speed UP",
        HP20_MESSAGE3 = "DEF UP",
        HP50_MESSAGE1 = "How do you survive a nuke? Become the nuke.",
        HP50_MESSAGE2 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "The time has come. This night is a world of shadow.",
        START_MESSAGE2 = "DMG from Human & Spirit units UP",
        START_MESSAGE3 = "DMG from Water & Dark units UP",
        START_MESSAGE4 = "Arts gauge Down & Reflection resistance"
    },

    [2064460] = {
        DEAD_MESSAGE1 = "Crap, you're too much...",
        HP50_MESSAGE1 = "Your fist isn't pure enough!",
        START_MESSAGE1 = "Sure, let's see you try."
    },
    [2064465] = {
        DEAD_MESSAGE1 = "Crap, you're too much...",
        HP50_MESSAGE1 = "You better not forget my name!",
        START_MESSAGE1 = "Sure, let's see you try."
    },
    [2064470] = {
        DEAD_MESSAGE1 = "Why...you...!",
        HP50_MESSAGE1 = "Units' Arts gauge DOWN",
        HP50_MESSAGE2 = "You better not forget my name!",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Spirit units UP",
        START_MESSAGE3 = "DMG from Fire units UP",
        START_MESSAGE4 = "Do you know who I am?"
    },
    [2064490] = {
        START_MESSAGE1 = "Super recovery",
        START_MESSAGE2 = "Fire DMG taken UP"
    },

    [2064960] = {
        DEAD_MESSAGE1 = "No...",
        HP50_MESSAGE1 = "Let us pray.",
        START_MESSAGE1 = "Here I come!"
    },
    [2064965] = {
        DEAD_MESSAGE1 = "Lord Rimuru...",
        HP50_MESSAGE1 = "Overdrive...",
        START_MESSAGE1 = "Here I come!"
    },
    [2064970] = {
        DEAD_MESSAGE1 = "I knew I held back too much...",
        HP50_MESSAGE1 = "It's about time to end this.",
        HP50_MESSAGE2 = "HP auto-recovery!",
        START_MESSAGE1 = "Let's get started.",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "DMG from Light & Dark units UP",
        START_MESSAGE4 = "Arts gauge DOWN & Reflection resistance"
    },
    [2064980] = {
        DEAD_MESSAGE1 = "You're pretty good!",
        HP40_MESSAGE1 = "It's about time to end this.",
        HP40_MESSAGE2 = "DMG UP!",
        HP60_MESSAGE1 = "Beelze-Graffiti!",
        HP60_MESSAGE2 = "DMG DOWN!",
        HP80_MESSAGE1 = "Beelze-Graffiti!",
        HP80_MESSAGE2 = "HP auto-recovery!",
        START_MESSAGE1 = "Let's get started.",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "DMG from Light & Dark units UP",
        START_MESSAGE4 = "Arts gauge DOWN & Reflection resistance"
    },

    [2065460] = {
        DEAD_MESSAGE1 = "But I gave my all...",
        HP50_MESSAGE1 = "Flames, gather.",
        START_MESSAGE1 = "Are you prepared?"
    },
    [2065465] = {
        DEAD_MESSAGE1 = "I failed again...",
        HP50_MESSAGE1 = "I can't hold it back...",
        START_MESSAGE1 = "Are you prepared?"
    },
    [2065470] = {
        DEAD_MESSAGE1 = "Kwahaha! I let my guard down!",
        SKILL5_MESSAGE1 = "Let my true form freeze you with terror!",
        SKILL5_MESSAGE2 = "DMG DOWN except from Human, Demon, or Dragon units!",
        START_MESSAGE1 = "Come at me with all your might!",
        START_MESSAGE2 = "DMG from Human & Dragon units UP",
        START_MESSAGE3 = "DMG from Fire & Earth units UP",
        START_MESSAGE4 = "Arts gauge DOWN & Reflection resistance"
    },
    [2065490] = {
        START_MESSAGE1 = "Super recovery",
        START_MESSAGE2 = "Ten-Sura Crossover units' DMG UP"
    },

    [2051360] = {
        DEAD_MESSAGE1 = "I got sloppy!",
        HP50_MESSAGE1 = "Alright, time to get serious for once!",
        START_MESSAGE1 = "Get ready to walk the plank!",
    },
    [2051365] = {
        DEAD_MESSAGE1 = "I got sloppy!",
        HP50_MESSAGE1 = "Alright, time to get serious for once!",
        START_MESSAGE1 = "Get ready to walk the plank!",
    },
    [2051370] = {
        DEAD_MESSAGE1 = "Still not enough...?",
        HP50_MESSAGE1 = "This won't fail!",
        HP_MESSAGE1 = "CRI rate UP",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "DMG from Dark & Fire units UP",
        START_MESSAGE4 = "No holding back.",
        START_WAVE_MESSAGE1 = "Our pledge to our ruler!"
    },

    [2051560] = {
        DEAD_MESSAGE1 = "Ouch, I overheated!",
        HP50_MESSAGE1 = "I won't hold anything back!",
        START_MESSAGE1 = "Rosetta Arm, activate!"
    },
    [2051565] = {
        DEAD_MESSAGE1 = "Ouch, I overheated!",
        HP50_MESSAGE1 = "I won't hold anything back!",
        START_MESSAGE1 = "Rosetta Arm, activate!"
    },
    [2051570] = {
        HP_MESSAGE1 = "Physical resistance UP",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "DMG from Fire & Dark units UP"
    },

    [2051860] = {
        DEAD_MESSAGE1 = "I won't lose...again...",
        HP50_MESSAGE1 = "No hard feelings.",
        START_MESSAGE1 = "The hunt begins!"
    },
    [2051865] = {
        DEAD_MESSAGE1 = "I won't lose...again...",
        HP50_MESSAGE1 = "No hard feelings.",
        START_MESSAGE1 = "The hunt begins!"
    },
    [2051870] = {
        HP30_MESSAGE1 = "CRI rate UP",
        HP50_MESSAGE1 = "Yikes, what a scary-looking mug!",
        HP70_MESSAGE1 = "Magic resistance UP",
        START_MESSAGE1 = "I'll wrap this up tout suite!",
        START_MESSAGE2 = "Light, Dark, & Reflection resistance",
        START_MESSAGE3 = "DMG from Human units UP",
        dead_MESSAGE1 = "Hahaha, I flubbed that one."
    },
    [2051875] = {
        DEAD_MESSAGE1 = "I won't lose...again...",
        HP50_MESSAGE1 = "No hard feelings.",
        START_MESSAGE1 = "The hunt begins!"
    },
    [2067360] = {
        DEAD_MESSAGE1 = "Guh...hah...",
        HP50_MESSAGE1 = "As if in flight! As if in flight!",
        START_MESSAGE1 = "I came...to pick a fight."
    },
    [2067365] = {
        DEAD_MESSAGE1 = "Guh...hah...",
        HP50_MESSAGE1 = "Mastery of Two Layers!",
        START_MESSAGE1 = "I came...to pick a fight."
    },
    [2067370] = {
        DEAD_MESSAGE1 = "Kahaa?!",
        HP50_MESSAGE1 = "Hiten Mitsurugi-ryu, Kuzuryuusen!",
        KILL_MESSAGE1 = "Target's ATK DOWN",
        START_MESSAGE1 = "This one is your opponent.",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Water & Light units UP",
        START_MESSAGE4 = "Arts gauge DOWN & Reflection resistance",
        START_MESSAGE5 = "Targets the unit inflicts highest DMG"
    },
    [2067380] = {
        DEAD_MESSAGE1 = "Kahaa?!",
        HP0_MESSAGE1 = "I can't die. I can't...even think to die yet!",
        HP20_MESSAGE1 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "CRI resistance UP",
        HP50_MESSAGE2 = "Hiten Mitsurugi-ryu--",
        HP80_MESSAGE1 = "DEF UP",
        KILL_MESSAGE1 = "Target's ATK DOWN",
        START_MESSAGE1 = "This one is your opponent.",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Water & Light units UP",
        START_MESSAGE4 = "Arts gauge DOWN & Reflection resistance",
        START_MESSAGE5 = "Targets the unit inflicts highest DMG"
    },

    [2067660] = {
        DEAD_MESSAGE1 = "Hmph, just when I was enjoying myself...",
        HP50_MESSAGE1 = "My Gatotsu has no blind spots.",
        START_MESSAGE1 = "Swift death to evil."
    },
    [2067665] = {
        DEAD_MESSAGE1 = "Hmph, just when I was enjoying myself...",
        HP50_MESSAGE1 = "My Gatotsu has no blind spots.",
        START_MESSAGE1 = "Swift death to evil."
    },
    [2067670] = {
        DEAD_MESSAGE1 = "I'm not allowed to die just yet.",
        HP30_MESSAGE1 = "The true Gatotsu! There will be no holding back!",
        HP30_MESSAGE2 = "DEF UP",
        HP60_MESSAGE1 = "My Gatotsu has no blind spots.",
        HP60_MESSAGE2 = "ATK UP",
        START_MESSAGE1 = "Come, I will deny everything that you are.",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Fire & Dark units UP",
        START_MESSAGE4 = "Arts gauge DOWN & Reflection resistance",
        START_MESSAGE5 = "DMG from Burning units UP"
    },
    [2067690] = {
        START_MESSAGE1 = "Super recovery",
        START_MESSAGE2 = "Rurouni Kenshin Crossover units' DMG UP"
    },

    [2068860] = {
        DEAD_MESSAGE1 = "Will this...be my grave?",
        HP50_MESSAGE1 = "I'll give up all I have now.",
        START_MESSAGE1 = "I'll eliminate you."
    },
    [2068865] = {
        DEAD_MESSAGE1 = "Will this...be my grave?",
        HP50_MESSAGE1 = "I'll give up all I have now.",
        START_MESSAGE1 = "I'll eliminate you."
    },
    [2068870] = {
        DEAD_MESSAGE1 = "Killer Move: Serious Series...",
        HP20_MESSAGE1 = "Serious Punch.",
        HP20_MESSAGE2 = "ATK UP",
        HP50_MESSAGE1 = "I'll fight you seriously.",
        HP50_MESSAGE2 = "DEF UP",
        START_MESSAGE1 = "Bring it on.",
        START_MESSAGE2 = "Arts gauge DOWN, Reflection, & Physical RES.",
        START_MESSAGE3 = "DMG from Human units UP",
        START_MESSAGE4 = "DMG from Light & Dark uits UP"
    },
    [2068885] = {
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG resistance except CRI",
        HP70_MESSAGE1 = "Evasion rate UP",
        HP50_MESSAGE1 = "CRI DMG resistance",
        HP50_MESSAGE2 = "Arts gauge filling speed UP",
        GRAB_MESSAGE1 = "Targets the unit inflicts highest DMG",
        GRAB_MESSAGE2 = "Target's Arts gauge DOWN"
    },
    [2068890] = {
        START_MESSAGE1 = "Super recovery",
        START_MESSAGE2 = "DMG UP for OPM units"
    },
    
    [2069245] = {
        CRT_MESSAGE1 = " is ",
        CRT_MESSAGE2 = "Hits CRI! Boss's Break gause DOWN!",
        FREEZE_MESSAGE1 = "ATK & DEF DOWN by Freeze",
        FREEZE_MESSAGE2 = " froze the enemy: enemy's ATK & DEF DOWN",
        HIT_MESSAGE1 = "Critical HIT!",
        HP_MESSAGE1 = "ATK UP",
        HP_MESSAGE2 = "Evasion rate UP",
        HP_MESSAGE3 = "DMG UP",
        HP_MESSAGE4 = "ATK speed UP",
        HP_MESSAGE5 = "HP Auto recovery",
        START_MESSAGE1 = "Negates Fire DMG",
        mess1 = "Targeted by Boss!",
        telop1 = "DMG from enemy increases when targeted.",
        telop2 = "When your unit falls, replace them and fight!",
        telop3 = "The reward changes with ranking results."
    },
    [2069260] = {
        DEAD_MESSAGE1 = "Your...Majesty...",
        HP50_MESSAGE1 = "You won't be forgiven.",
        START_MESSAGE1 = "Resist. and I'll attack.",
        START_MESSAGE2 = "Arts gauge DOWN resistance",
    },
    [2069270] = {
        DEAD_MESSAGE1 = "Your...Majesty...",
        HP50_MESSAGE1 = "You won't be forgiven.",
        START_MESSAGE1 = "Resist. and I'll attack.",
        START_MESSAGE2 = "Arts gauge DOWN resistance",
    },
    [2069280] = {
        DEAD_MESSAGE1 = "The skies...are blue...",
        HP30_MESSAGE1 = "Power, will, come to me.",
        HP30_MESSAGE2 = "DMG UP",
        HP70_MESSAGE1 = "Sorcery seals, removed.",
        HP70_MESSAGE2 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "I am one with Isliid.",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE3 = "Dark resisitance",
        START_MESSAGE4 = "DMG from Human & Light unis UP"
    },
    [2069290] = {
        DEAD_MESSAGE1 = "The skies...are blue...",
        HP50_MESSAGE1 = "Karma removed.",
        HP50_MESSAGE2 = "Magic DMG taken DOWN",
        HP50_MESSAGE3 = "Physical DMG taken UP",
        HP90_MESSAGE1 = "Power, will, come to me.",
        SKILL5_MESSAGE1 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "I am one with Isliid.",
        START_MESSAGE2 = "Reflection, Arts gauge DOWN, & Dark resistance",
        START_MESSAGE3 = "Physical DMG taken DOWN",
        START_MESSAGE4 = "DMG from Human & Light units UP"
    },

    [2069560] = {
        DEAD_MESSAGE1 = "What rotten luck!",
        HP30_MESSAGE1 = 'Grit your teeth, "Strongest!"',
        HP30_MESSAGE2 = "Supernatural Shattering: DMG Negation Canceled",
        START_MESSAGE1 = "Let's get started.",
        START_MESSAGE2 = "Arts gauge DOWN resistance"
    },
    [2069570] = {
        DEAD_MESSAGE1 = "What rotten luck!",
        HP30_MESSAGE1 = 'Grit your teeth, "Strongest!"',
        HP30_MESSAGE2 = "Supernatural Shattering: DMG Negation Canceled",
        START_MESSAGE1 = "Let's get started.",
        START_MESSAGE2 = "Arts gauge DOWN resistance"
    },
    [2069580] = {
        DEAD_MESSAGE1 = "N-no...",
        HP35_MESSAGE1 = "This is my full power!",
        HP35_MESSAGE2 = "Arts gauge filling speed UP",
        HP80_MESSAGE1 = "I thought I told you to stay out of my way!",
        HP80_MESSAGE2 = "DMG UP to Paralyzed enemy",
        START_MESSAGE1 = "Come on, let's go.",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resisstance",
        START_MESSAGE3 = "DMG from Human, Water, & Light units UP"
    },
    [2069590] = {
        DEAD_MESSAGE1 = "N-no...",
        HP0_MESSAGE1 = "This is my full power!",
        HP0_MESSAGE2 = "Railgun: DMG Negation Canceled",
        HP30_MESSAGE1 = "I thought I told you to stay out of my way!",
        HP30_MESSAGE2 = "DMG taken DOWN & Arts gauge filling speed UP",
        HP60_MESSAGE1 = "You're getting on my nerves.",
        HP60_MESSAGE2 = "DMG taken DOWN & DMG UP",
        START_MESSAGE1 = "Come on, let's go.",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resisstance",
        START_MESSAGE3 = "CRI rate UP to Paralyzed enemy",
        START_MESSAGE4 = "DMG from Water & Light units UP"
    },
    
    [2069860] = {
        DEAD_MESSAGE1 = "Touma...",
        HP30_MESSAGE1 = "Destroying intruder.",
        START_MESSAGE1 = "I can fight whether or not Touma is here!",
        START_MESSAGE2 = "Arts gauge DOWN resistance"
    },
    [2069870] = {
        DEAD_MESSAGE1 = "Touma...",
        HP30_MESSAGE1 = "Destroying intruder.",
        START_MESSAGE1 = "I can fight whether or not Touma is here!",
        START_MESSAGE2 = "Arts gauge DOWN resistance"
    },
    [2069880] = {
        DEAD_MESSAGE1 = "N-no way...",
        HP30_MESSAGE1 = "From here on, it's a one-way road!",
        HP30_MESSAGE2 = "Black Wings: Reflection Effect",
        HP80_MESSAGE1 = "You're, like, a hundred years behind me!",
        SKILL2_MESSAGE1 = "Ground Wave: ATK UP",
        SKILL4_MESSAGE1 = "Rupturing Tremor: DMG to enemy UP",
        START_MESSAGE1 = "Are you ready to die?",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE3 = "DMG from Light & Dark units UP",
        START_MESSAGE4 = "DMG taken UP during Break"
    },
    [2069890] = {
        START_MESSAGE1 = "Super recovery",
        START_MESSAGE2 = "A Certain Magical Index Crossover units' DMG UP",
        START_MESSAGE3 = "DMG UP for units with Shield user"
    },

    [2070660] = {
        DEAD_MESSAGE1 = "Have I fallen down?",
        HP50_MESSAGE1 = "I feel stupid for being scared.",
        START_MESSAGE1 = "Right, let's get down to it.",
        START_MESSAGE2 = "Arts gauge DOWN resistance"
    },
    [2070670] = {
        DEAD_MESSAGE1 = "Have I fallen down?",
        HP50_MESSAGE1 = "I feel stupid for being scared.",
        START_MESSAGE1 = "Right, let's get down to it.",
        START_MESSAGE2 = "Arts gauge DOWN resistance"
    },
    [2070680] = {
        DEAD_MESSAGE1 = "I used my secret cache...",
        HP20_MESSAGE1 = "It's time to bring this to an end.",
        HP50_MESSAGE1 = "It's about time to finish things.",
        HP50_MESSAGE2 = "CRI resistance UP",
        SKILL4_MESSAGE1 = "Vollzanbel: Party ATK DOWN",
        START_MESSAGE1 = "I'm the mage Frieren. Nice to meet you.",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Fire & Light units UP",
        START_MESSAGE4 = "Demon Killer",
        START_MESSAGE5 = "Arts gauge DOWN, Reflection, & Magic RES."
    },
    [2070690] = {
        CHARGE_MESSAGE1 = "Charging Ordinary Offensive Magic",
        CHARGE_MESSAGE2 = "Canceled by Blind, Disease, Treasure Box, or Break",
        CHARGE_MESSAGE3 = "Activation avoidance succeeded!",
        CHARGE_MESSAGE4 = "Blind resistance UP",
        CHARGE_MESSAGE5 = "Disease resistance UP",
        CHARGE_MESSAGE6 = "Faint resistance UP",
        DEAD_MESSAGE1 = "Urgh...",
        HP20_MESSAGE1 = "Good, that's the way a mage acts.",
        HP20_MESSAGE2 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Nice, now I'm interested.",
        HP50_MESSAGE2 = "Evasion rate UP",
        HP80_MESSAGE1 = "Alright, what about now?",
        HP80_MESSAGE2 = "CRI resistance UP",
        SKILL4_MESSAGE1 = "Vollzanbel: Party ATK DOWN",
        SKILL5_MESSAGE1 = "Well then, it's time to bring this to an end.",
        START_MESSAGE1 = "This mana...might be from a grimoire.",
        START_MESSAGE2 = "DMG from Human, Fire, & Light units UP",
        START_MESSAGE3 = "Arts gauge DOWN, Reflection, & Magic RES.",
        START_MESSAGE4 = "Demon Killer",
        START_MESSAGE5 = "DMG Negation Canceled"
    },

    [2070860] = {
        DEAD_MESSAGE1 = "Hmm, does it end here?",
        HP30_MESSAGE1 = "Reelseiden!",
        START_MESSAGE1 = "OK, let's get started.",
        START_MESSAGE2 = "Arts gauge DOWN resistance"
    },
    [2070870] = {
        DEAD_MESSAGE1 = "Hmm, does it end here?",
        HP30_MESSAGE1 = "Reelseiden!",
        START_MESSAGE1 = "OK, let's get started.",
        START_MESSAGE2 = "Arts gauge DOWN resistance"
    },
    [2070880] = {
        DEAD_MESSAGE1 = "Oh no...",
        HP30_MESSAGE1 = "Zoltraak!",
        HP30_MESSAGE2 = "Arts gauge filling speed UP & Physical resistance",
        HP60_MESSAGE1 = "I can blow out your heart at this close distance.",
        HP60_MESSAGE2 = "Arts gauge filling speed UP & Physical resistance",
        START_MESSAGE1 = "Let's begin.",
        START_MESSAGE2 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE3 = "Demon Killer",
        START_MESSAGE4 = "DMG from Water & Earth UP"
    },
    [2070890] = {
        START_MESSAGE1 = "Super recovery",
        START_MESSAGE2 = "Frieren crossover units' DMG UP"
    },

    [2070895] = {
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human & Spirit units UP",
        SKILL_MESSAGE1 = "Party Accuracy DOWN",
        PERFECT_MESSAGE1 = "Perfect Bonus!",
        PERFECT_MESSAGE2 = "Arts gauge MAX"
    },
    [2070896] = {
        START_MESSAGE1 = "Jump: Tap the screen",
        START_MESSAGE2 = "High jump: Tap & hold screen",
        START_MESSAGE3 = "Boss CRI DMG resistance UP by hits taken",
        SUMMARY_MESSAGE1 = "% DMG",
        SUMMARY_MESSAGE2 = "% Recovery",
        SUMMARY_MESSAGE3 = "DMG",
        SUMMARY_MESSAGE4 = "%",
        SUMMARY_MESSAGE5 = "DOWN",
        SUMMARY_MESSAGE6 = "UP",
        BOX_GET_MESSAGE1 = "Mimic! DMG DOWN 30% ",
        BOX_GET_MESSAGE2 = "Got a Treasure BOX! DMG UP 150%",
        BOX_MESSAGE1 = "Oops! Lost a Treasure Box"
    },

    [2072560] = {
        START_MESSAGE1 = "Let's make it a challenge!",
        START_MESSAGE2 = "Arts gauge DOWN resistance",
        HP30_MESSAGE1 = "The winner of this fight is me!",
        DEAD_MESSAGE1 = "Oh man, I think I'm done for..."
    },
    [2072570] = {
        START_MESSAGE1 = "Let's make it a challenge!",
        START_MESSAGE2 = "Arts gauge DOWN resistance",
        HP30_MESSAGE1 = "The winner of this fight is me!",
        DEAD_MESSAGE1 = "Oh man, I think I'm done for..."
    },
    [2072580] = {
        START_MESSAGE1 = "What a drag.",
        START_MESSAGE2 = "DMG from Human, Water, & Earth units UP",
        START_MESSAGE3 = "Arts gauge DOWN & Reflection resistance",
        START_MESSAGE4 = "Rapid mode: Evasion rate UP & DMG taken DOWN",
        START_MESSAGE5 = "Rapid mode canceled by Burn, Blind, Paralysis, & Freeze",
        HISPEEDMODE_MESSAGE1 = "Rapid mode canceled by Burn",
        HISPEEDMODE_MESSAGE2 = "Rapid mode canceled by Blind",
        HISPEEDMODE_MESSAGE3 = "Rapid mode canceled by Paralysis",
        HISPEEDMODE_MESSAGE4 = "Rapid mode canceled by Freeze",
        HISPEEDMODE_MESSAGE5 = "Rapid mode: Evasion rate UP & DMG taken DOWN",
        HISPEEDMODE_MESSAGE6 = "Burn resistance UP",
        HISPEEDMODE_MESSAGE7 = "Blind resistance UP",
        HISPEEDMODE_MESSAGE8 = "Paralysis resistance UP",
        HISPEEDMODE_MESSAGE9 = "Freeze resistance UP",
        HP50_MESSAGE1 = "So this is the power of Turbo Granny, huh?",
        DEAD_MESSAGE1 = "Ugh, I screwed up."
    },
    [2072590] = {
        START_MESSAGE1 = "You pissed me off.",
        START_MESSAGE2 = "DMG from Human, Water, & Earth units UP",
        START_MESSAGE3 = "Arts gauge DOWN & Reflection resistance",
        START_MESSAGE4 = "Rapid mode: Evasion rate UP & DMG taken DOWN",
        START_MESSAGE5 = "Rapid mode canceled by Burn, Blind, Paralysis, & Freeze",
        HISPEEDMODE_MESSAGE1 = "Rapid mode canceled by Burn",
        HISPEEDMODE_MESSAGE2 = "Rapid mode canceled by Blind",
        HISPEEDMODE_MESSAGE3 = "Rapid mode canceled by Paralysis",
        HISPEEDMODE_MESSAGE4 = "Rapid mode canceled by Freeze",
        HISPEEDMODE_MESSAGE5 = "Rapid mode: Evasion rate UP & DMG taken DOWN",
        HISPEEDMODE_MESSAGE6 = "Burn resistance UP",
        HISPEEDMODE_MESSAGE7 = "Blind resistance UP",
        HISPEEDMODE_MESSAGE8 = "Paralysis resistance UP",
        HISPEEDMODE_MESSAGE9 = "Freeze resistance UP",
        HP60_MESSAGE1 = "I'm so bummed out.",
        HP60_MESSAGE2 = "CRI resistance UP",
        HP30_MESSAGE1 = "What a drag.",
        HP30_MESSAGE2 = "Arts gauge filling speed UP",
        HP0_MESSAGE1 = "What a draaaaag!",
        DEAD_MESSAGE1 = "Ugh, I screwed up."
    },
    [2072596] = {
        START_MESSAGE1 = "Super recovery",
        START_MESSAGE2 = "DAN DA DAN Crossover units' DMG UP"
    },

    [2072860] = {
        DEAD_MESSAGE1 = "I am a chosen one...",
        HP30_MESSAGE1 = "I'll give you lots of chances.",
        START_MESSAGE1 = "Let us fight.",
        START_MESSAGE2 = "Arts gauge DOWN resistance"
    },
    [2072870] = {
        DEAD_MESSAGE1 = "I am a chosen one...",
        HP30_MESSAGE1 = "I'll give you lots of chances.",
        START_MESSAGE1 = "Let us fight.",
        START_MESSAGE2 = "Arts gauge DOWN resistance"
    },
    [2072880] = {
        DEAD_MESSAGE1 = "How disappointing. This game's over already?",
        HP20_MESSAGE1 = "Come on, more! Let's do more!",
        HP20_MESSAGE2 = "CRI resistance UP",
        HP60_MESSAGE1 = "I'm going to show you what true Hell is like.",
        HP60_MESSAGE2 = "Physical resistance UP",
        SKILL5_MESSAGE1 = "Cursed Ball: Arts gauge DOWN",
        START_MESSAGE1 = "I will kill all humans.",
        START_MESSAGE2 = "Arts gauge DOWN & Reflection resistance",
        START_MESSAGE3 = "DMG from Fire & Dark units UP",
        START_MESSAGE4 = "DMG from Spirit & Demon units UP",
        START_MESSAGE5 = "Targets the unit inflicts highest DMG",
        TG_MESSAGE1 = "Faints a target: canceled with enough DMG",
        TG_MESSAGE2 = "K.O.s %s after time limit",
        TG_MESSAGE3 = "Faint canceled!"
    },
    [2072890] = {
        DEAD_MESSAGE1 = "How disappointing. This game's over already?",
        HP20_MESSAGE1 = "This lingering resentment will never go away.",
        HP20_MESSAGE2 = "Arts gauge filling speed UP",
        HP60_MESSAGE1 = "Come on, more! Let's do more!",
        HP60_MESSAGE2 = "CRI & Break resistance UP",
        HP90_MESSAGE1 = "I'm going to show you what true Hell is like.",
        HP90_MESSAGE2 = "Physical resistance UP",
        SKILL5_MESSAGE1 = "Cursed Ball: DMG Negation canceled",
        SKILL5_MESSAGE2 = "Cursed Ball: DMG Negation canceled & Arts gauge DOWN",
        START_MESSAGE1 = "I will kill all humans.",
        START_MESSAGE2 = "Arts gauge DOWN & Reflection resistance",
        START_MESSAGE3 = "DMG from Fire, Dark, sprit, & Demon units UP",
        START_MESSAGE4 = "Targets the unit inflicts highest DMG",
        START_MESSAGE5 = "CRI rate UP to a target",
        TG_MESSAGE1 = "Faints a target: canceled with enough DMG",
        TG_MESSAGE2 = "K.O.s %s after time limit",
        TG_MESSAGE3 = "Faint canceled!"
    },
    [2072896] = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG UP by # of Wyrms in battle",
        START_MESSAGE3 = "DMG taken DOWN by # of Wyrms' Elements in battle",
        HP40_MESSAGE1 = "HP auto-recovery",
        HP40_MESSAGE2 = "Arts gauge filling speed UP",
        HP20_MESSAGE1 = "Physical resistance & Arts gauge filling speed UP",
        SUMMON_MESSAGE1 = "Inferno Wyrm joined",
        SUMMON_MESSAGE2 = "Aqua Wyrm joined",
        SUMMON_MESSAGE3 = "Gaia Wyrm joined",
        SUMMON_MESSAGE4 = "Gold Wyrm joined",
        SUMMON_MESSAGE5 = "Violet Wyrm joined"
    },

    [2052200] = {
        BREAKE_MESSAGE1 = "Break! DMG taken UP!",
        BREAKE_MESSAGE2 = "Break resistance UP",
        HP0_MESSAGE1 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "More Break, more DMG taken"
    },
    [2052205] = {
        BREAK_MESSAGE1 = "Arts DMG UP after Break recovery! Entering Ground mode",
        BREAK_MESSAGE2 = "Invincible during Break",
        HP50_MESSAGE1 = "All attacks inflict Burn (stacks)",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG taken DOWN (Except Demon Units)",
        START_MESSAGE3 = "While flying, fight with boosted Accuracy"
    },

    [2052960] = {
        DEAD_MESSAGE1 = "Awooooouch!",
        HP50_MESSAGE1 = "I'm gonna eat'cha!",
        START_MESSAGE1 = "Charwolflotte is here!"
    },
    [2052965] = {
        DEAD_MESSAGE1 = "Lizalee... Give me...strength...",
        HP50_MESSAGE1 = "I'll slice you apart!",
        START_MESSAGE1 = "I'll prove my magical might!"
    },
    [2052970] = {
        SKILL_MESSAGE1 = "2000 DMG",
        SKILL_MESSAGE2 = "DMG UP to low HP units",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP"
    },
    [2052975] = {
        DEAD_MESSAGE1 = "I knew this body wouldn't...",
        HP50_MESSAGE1 = "This is the end.",
        START_MESSAGE1 = "Trick ready to deploy!"
    },

    [2053560] = {
        DEAD_MESSAGE1 = "No...way...",
        HP50_MESSAGE1 = "Can you tell who is the real me?",
        START_MESSAGE1 = "Come, I'm right here."
    },
    [2053565] = {
        DEAD_MESSAGE1 = "But why...?",
        HP50_MESSAGE1 = "Can you accept all of myself?",
        START_MESSAGE1 = "Come, I'm right here."
    },
    [2053570] = {
        DEBUFF_CLEAR_MESSAGE1 = "ATK & DMG taken DOWN",
        DEBUFF_MESSAGE1 = "ATK & DMG taken UP",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "ATK & DMG taken UP during Poison"
    },
    [2053580] = {
        DEBUFF_CLEAR_MESSAGE1 = "ATK & DMG taken DOWN",
        DEBUFF_CLEAR_MESSAGE2 = "CRI resistance UP",
        DEBUFF_MESSAGE1 = "ATK & DMG taken UP",
        DEBUFF_MESSAGE2 = "CRI resistance DOWN",
        HP1_MESSAGE1 = "Negates DMG (except Poisoned) for 13s",
        START_MESSAGE1 = "Reflection & CRI resistance",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "ATK & DMG taken UP during Poison"
    },

    [2054270] = {
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP ",
        START_MESSAGE3 = "DMG from Fire & Light units UP ",
        START_MESSAGE4 = "DMG from Poisoned units DOWN"
    },
    [2054275] = {
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG taken UP from first Break",
        START_MESSAGE4 = "DMG taken UP during Break",
        SKILL2_MESSAGE1 = "Party's ATK DOWN",
        PERFECT_MESSAGE1 = "Perfect Bonus!",
        PERFECT_MESSAGE2 = "Start with Break!",
        TIMER_MESSAGE1 = "Boss's DMG taken UP over time"
    },
    [2054276] = {
        START_MESSAGE1 = "Jump: Tap the screen",
        START_MESSAGE2 = "High jump: Tap & hold screen",
        START_MESSAGE3 = "Break resistance UP by hits taken",
        SUMMARY_MESSAGE1 = "% DMG",
        SUMMARY_MESSAGE2 = "% Recovery"
    },
    [2054277] = {
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG taken UP from first Break",
        START_MESSAGE4 = "DMG taken UP during Break",
        SKILL2_MESSAGE1 = "Party's ATK DOWN",
        PERFECT_MESSAGE1 = "Perfect Bonus!",
        PERFECT_MESSAGE2 = "Start with Break!",
        TIMER_MESSAGE1 = "Boss's DMG taken UP over time"
    },
    [2054278] = {
        START_MESSAGE1 = "Jump: Tap the screen",
        START_MESSAGE2 = "High jump: Tap & hold screen",
        START_MESSAGE3 = "Break resistance UP by hits taken",
        SUMMARY_MESSAGE1 = "% DMG",
        SUMMARY_MESSAGE2 = "% Recovery"
    },

    [2054635] = {
        BUFF_MESSAGE1 = "DMG Negation canceled",
        BUFF_MESSAGE2 = "DMG UP",
        BUFF_MESSAGE3 = "CRI rate UP",
        HP_REDUCE_MESSAGE = "MAX HP DOWN",
        START_MESSAGE = "Negates DMG & Break from Light units",
        BUFF_MESSAGE1 = "DMG Negation canceled",
        BUFF_MESSAGE2 = "DMG UP",
        BUFF_MESSAGE3 = "CRI rate UP",
        HP_REDUCE_MESSAGE = "MAX HP DOWN",
        START_MESSAGE = "Negates DMG & Break from Light units"
    },
    [2054660] = {
        BUFF_MESSAGE1 = "DMG Negation canceled",
        BUFF_MESSAGE2 = "DMG UP",
        BUFF_MESSAGE3 = "CRI rate UP",
        HP_REDUCE_MESSAGE = "MAX HP DOWN",
        START_MESSAGE = "Negates DMG & Break from Light units"
    },
    [2054665] = {
        BUFF_MESSAGE1 = "DMG Negation canceled",
        BUFF_MESSAGE2 = "DMG UP",
        BUFF_MESSAGE3 = "CRI rate UP",
        HP_REDUCE_MESSAGE = "MAX HP DOWN",
        START_MESSAGE = "Negates DMG & Break from Light units"
    },
    [2054670] = {
        BREAK_MESSAGE1 = "Break! Boss: DMG UP Canceled",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Fire & Dark units UP",
        START_MESSAGE4 = "DMG UP for Every Action",
        START_MESSAGE5 = "DMG UP canceled by Break"
    },
    [2054675] = {
        START_MESSAGE1 = "Super-recovery",
        START_MESSAGE2 = "Fire DMG taken UP"
    },

    [2055160] = {
        DEAD_MESSAGE1 = "It's time I excused myself.",
        HP50_MESSAGE1 = "Consider this as special.",
        START_MESSAGE1 = "Are we prepared?"
    },
    [2055165] = {
        DEAD_MESSAGE1 = "It's time I excused myself.",
        HP50_MESSAGE1 = "Listen to this performance.",
        START_MESSAGE1 = "Are we prepared?"
    },
    [2055170] = {
        DEAD_MESSAGE1 = "I am...furious...",
        HP50_MESSAGE1 = "Listen to this performance.",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Light units UP",
        START_MESSAGE4 = "I'll blast a new hole in your head!"
    },
    [2055180] = {
        START_MESSAGE1 = "Super Recovery",
        START_MESSAGE2 = "Light DMG taken UP"
    },

    [2055560] = {
        DEAD_MESSAGE1 = "I screwed up!",
        HP50_MESSAGE1 = "Let it fly!",
        START_MESSAGE1 = "Stay calm, don't get jumpy..."
    },
    [2055565] = {
        DEAD_MESSAGE1 = "I screwed up!",
        HP50_MESSAGE1 = "Let it fly!",
        START_MESSAGE1 = "Stay calm, don't get jumpy..."
    },
    [2055570] = {
        DEAD_MESSAGE1 = "Hmm, room for improvement...",
        HP50_MESSAGE1 = "Now take this!",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from God units UP",
        START_MESSAGE3 = "DMG from Water & Earth units UP",
        START_MESSAGE4 = "All eyes on me!"
    },
    [2055575] = {
        DEAD_MESSAGE1 = "Back to the cutting board...",
        HP50_MESSAGE1 = "Special! Heartfelt!",
        SKILL_MESSAGE1 = "MAX HP UP",
        START_MESSAGE1 = "Time to show my stuff!"
    },

    [2056460] = {
        DEAD_MESSAGE1 = "I can't win against this foe...",
        HP50_MESSAGE1 = "Lesson 1: You are weaker than me.",
        START_MESSAGE1 = "My name is Evileye, the one who will defeat you!"
    },
    [2056465] = {
        DEAD_MESSAGE1 = "I can't win against this foe...",
        HP50_MESSAGE1 = "Maximize Magic...",
        START_MESSAGE1 = "My name is Evileye, the one who will defeat you!"
    },
    [2056470] = {
        DEAD_MESSAGE1 = "Huh, this might be a little...",
        HP20_MESSAGE1 = "DEF UP",
        HP50_MESSAGE1 = "This is kinda fun.",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "I refuse to take you seriously."
    },
    [2056480] = {
        DEAD_MESSAGE1 = "Huh, this might be a little...",
        HP20_MESSAGE1 = "This is kinda fun.",
        HP50_MESSAGE1 = "You put me in a bad mood.",
        HP80_MESSAGE1 = "Frost Pain Modified!",
        SKILL_MESSAGE1 = "Prepare your defenses!",
        SKILL_MESSAGE2 = "DMG taken DOWN",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "I refuse to take you seriously."
    },

    [2056560] = {
        DEAD_MESSAGE1 = "Inconceivable!",
        HP50_MESSAGE1 = "I shall wrap you in flames.",
        START_MESSAGE1 = "Shall we begin?"
    },
    [2056565] = {
        DEAD_MESSAGE1 = "Inconceivable!",
        HP50_MESSAGE1 = "Parting with a farewell is etiquette.",
        START_MESSAGE1 = "Shall we begin?"
    },
    [2056570] = {
        DEAD_MESSAGE1 = "What a disgrace to Lord Ainz...",
        HP50_MESSAGE1 = "Parting with a farewell is etiquette.",
        SKILL_MESSAGE1 = "DMG taken DOWN",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG taken from Demon units UP",
        START_MESSAGE3 = "Counters Super Arts!",
        START_MESSAGE4 = "Shall we begin?"
    },
    [2056590] = {
        START_MESSAGE1 = "Super-recovery",
        START_MESSAGE2 = "Dark DMG taken UP"
    },

    [2057060] = {
        DEAD_MESSAGE1 = "...You're decent.",
        HP50_MESSAGE1 = "Entei-Ryu Fourth Stance, Cleaving Torch.",
        START_MESSAGE1 = "I'll cut you down."
    },
    [2057065] = {
        DEAD_MESSAGE1 = "...You're decent.",
        HP50_MESSAGE1 = "Entei-Ryu, Spontaneous Combustion.",
        START_MESSAGE1 = "I'll cut you down."
    },
    [2057070] = {
        DEAD_MESSAGE1 = "You're better than I thought.",
        HP50_MESSAGE1 = "Entei-Ryu, Spontaneous Combustion.",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Fire units UP",
        START_MESSAGE4 = "I'll show you the essence of the blade."
    },
    [2057075] = {
        SKILL_MESSAGE1 = "DEF DOWN"
    },

    [2057660] = {
        DEAD_MESSAGE1 = "Now it's time for study hall.",
        HP50_MESSAGE1 = "Naughty kids get extra lessons!",
        START_MESSAGE1 = "Today's class will now begin."
    },
    [2057665] = {
        DEAD_MESSAGE1 = "Now it's time for study hall.",
        HP50_MESSAGE1 = "I'll teach you what time travel is like.",
        HP50_MESSAGE2 = "DMG UP",
        START_MESSAGE1 = "Today's class will now begin."
    },
    [2057670] = {
        DEAD_MESSAGE1 = "You're a real handful.",
        HP100_MESSAGE1 = "Today's class will now begin.",
        HP100_MESSAGE2 = "Skill CT speed DOWN (Except Earth units)",
        HP50_MESSAGE1 = "I'll teach you what time travel is like.",
        HP50_MESSAGE2 = "Skill CT speed DOWN (Except Earth units)",
        START_MESSAGE1 = "Reflection resisitance",
        START_MESSAGE2 = "DMG from Demon units UP",
        START_MESSAGE3 = "DMG from Earth units UP",
        START_MESSAGE4 = "Be careful to use Non-Earth units"
    },
    [2057675] = {
        HP20_MESSAGE1 = "Physical resistance & ATK UP"
    },

    [2059360] = {
        DEAD_MESSAGE1 = "Ungh, I lost...",
        HP50_MESSAGE1 = "Do you like fireworks?",
        START_MESSAGE1 = "Oh, you wanna play with me?"
    },
    [2059365] = {
        DEAD_MESSAGE1 = "Sorry, give me some mana...",
        HP50_MESSAGE1 = "Let's shoot one off.",
        START_MESSAGE1 = "Oh, you wanna play with me?"
    },
    [2059370] = {
        BURST_CHARGE_MESSAGE1 = "Uses Super Arts when Arts gauge is full!",
        BURST_CHARGE_MESSAGE2 = "Magic DMG taken DOWN",
        DEAD_MESSAGE1 = "I need more...energy...",
        HP25_MESSAGE1 = "Fragarach!",
        HP50_MESSAGE1 = "Defense! Attack! Speed! Synergy!",
        HP90_MESSAGE1 = "Then I won't hold back.",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Light & Water units UP",
        START_MESSAGE4 = "Ice pops! Ice-cold ice pops for sale!"
    },
    [2059390] = {
        START_MESSAGE1 = "Super-recovery",
        START_MESSAGE2 = "PRISMA☆ILLYA units' DMG UP"
    },

    [2059760] = {
        DEAD_MESSAGE1 = "I-Illya... I'm sorry...",
        HP50_MESSAGE1 = "Class Card: Berserker!",
        START_MESSAGE1 = "Don't ruin my summer with Illya."
    },
    [2059765] = {
        DEAD_MESSAGE1 = "I wanted more...Illya in a swimsuit...",
        HP50_MESSAGE1 = "I won't hold back.",
        START_MESSAGE1 = "Don't ruin my summer with Illya."
    },
    [2059770] = {
        BREAK_MESSAGE1 = "Break! DMG taken DOWN canceled",
        DEAD_MESSAGE1 = "R: Ngyah! Don't fumble the block!",
        HP20_MESSAGE1 = "L: You are in my personal arsenal.",
        HP50_MESSAGE1 = "R: Let's go, Luvia! - L: Come at me!",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Fire & Earth units UP",
        START_MESSAGE4 = "DMG taken DOWN canceled by Break",
        START_MESSAGE5 = "L: Are you prepared? - R: Naturally!"
    },
    [2059785] = {
        DEAD_MESSAGE1 = "Priya...",
        EXTRA_MESSAGE1 = "Boss: HP auto-recovery canceled with enough DMG",
        HP0_MESSAGE1 = "Pri-pri! Priyaaaa!",
        HP0_MESSAGE2 = "Arts gauge filling speed & CRI rate UP",
        HP30_MESSAGE1 = "Pri-pri! Priyaaaa!",
        HP30_MESSAGE2 = "CRI rate UP",
        HP60_MESSAGE1 = "Pri-priya!",
        HP60_MESSAGE2 = "Party's ATK DOWN",
        START_MESSAGE1 = "Priiiiiyaaaa!",
        START_MESSAGE2 = "Reflection & Water resistance "
    },
    [2059786] = {
        START_MESSAGE1 = "King Pikyuon: Magic resistance"
    },
    
    [2104014] = {
        EXTRA_GAUGE_MESSAGE1 = "Lock mode canceled by Physical DMG",
        EXTRA_GAUGE_MESSAGE2 = "Lock mode canceled by accumulated Physical DMG",
        HP_MESSAGE_LIST1 = "This darkness has no end.",
        HP_MESSAGE_LIST2 = "Arts gauge filling speed & CRI resistance UP",
        HP_MESSAGE_LIST3 = "My night...is over.",
        LOCK_MESSAGE1 = "Locks ",
        SKILL_MESSAGE1 = "Magna Lance: Cancells DMG Negation",
        START_MESSAGE1 = "This evening, you will join the Sacrifice.",
        START_MESSAGE2 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG ",
        START_MESSAGE4 = "CRI rate UP to a target",
        RACE1 = "Human",
        RACE2 = "Beast",
        RACE3 = "Spirit",
        RACE4 = "Giant",
        RACE5 = "Machine",
        RACE6 = "Dragon",
        RACE7 = "God",
        RACE8 = "Demon"
    },
    [2104015] = {
        EXTRA_GAUGE_MESSAGE1 = "Lock mode canceled by Physical DMG",
        EXTRA_GAUGE_MESSAGE2 = "Lock mode canceled by accumulated Physical DMG",
        HP_MESSAGE_LIST1 = "This darkness has no end.",
        HP_MESSAGE_LIST2 = "Arts gauge filling speed & CRI resistance UP",
        HP_MESSAGE_LIST3 = "My night...is over.",
        LOCK_MESSAGE1 = "Locks ",
        SKILL_MESSAGE1 = "Magna Lance: Cancells DMG Negation",
        START_MESSAGE1 = "This evening, you will join the Sacrifice.",
        START_MESSAGE2 = "Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG ",
        START_MESSAGE4 = "CRI rate UP to a target",
        RACE1 = "Human",
        RACE2 = "Beast",
        RACE3 = "Spirit",
        RACE4 = "Giant",
        RACE5 = "Machine",
        RACE6 = "Dragon",
        RACE7 = "God",
        RACE8 = "Demon"
    },
    [2105053] = {
        START_MESSAGE1 = "Fire DMG taken UP",
        START_MESSAGE2 = "Physical DMG taken UP",
        START_MESSAGE3 = "CRI resistance"
    },

    [2205022] = {
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Light UP",
        START_MESSAGE3 = "DMG from Equip Skill UP"
    },

    [2305020] = {
        DEAD_MESSAGE1 = "My strength is still...insufficient...",
        HP50_MESSAGE1 = "I shall mete out punishment.",
        START_MESSAGE1 = "Know your place."
    },
    [2305021] = {
        DEAD_MESSAGE1 = "My strength is still...insufficient...",
        HP50_MESSAGE1 = "I shall mete out punishment.",
        START_MESSAGE1 = "Know your place."
    },
    [2305022] = {
        DEAD_MESSAGE1 = "I must surpass...everything...",
        HP30_MESSAGE1 = "This is the power of creation.",
        HP50_MESSAGE1 = "You shall be judged.",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Fire units UP",
        START_MESSAGE4 = "The new world is at hand."
    },

    [2404003] = {
        START_MESSAGE1 = "Reflection, Arts gauge DOWN, & CRI resistance",
        START_MESSAGE2 = "DMG taken UP when Poisoned",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG",
        START_MESSAGE4 = "CRI rate UP to a target",
        SKILL2_MESSAGE1 = "HP DOWN to half & DMG taken UP",
        SKILL3_MESSAGE1 = "Faints a target"
    },
    [2404013] = {
        START_MESSAGE1 = "Reflection, Arts gauge DOWN, & CRI resistance",
        START_MESSAGE2 = "DMG taken UP when Poisoned",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG",
        START_MESSAGE4 = "CRI rate UP to a target",
        SKILL2_MESSAGE1 = "HP DOWN to half & DMG taken UP",
        SKILL3_MESSAGE1 = "Faints a target"
    },
    [2405020] = {
        DEAD_MESSAGE1 = "I need...to rest...",
        HP50_MESSAGE1 = "A great power fills me.",
        START_MESSAGE1 = "OK, I'll kill you."
    },
    [2405021] = {
        DEAD_MESSAGE1 = "I need...to rest...",
        HP50_MESSAGE1 = "A great power fills me.",
        START_MESSAGE1 = "OK, I'll kill you."
    },
    [2405022] = {
        DEAD_MESSAGE1 = "Ahhhhhhhh!",
        HP50_MESSAGE1 = "The white void opens.",
        SKILL_MESSAGE1 = "Faints least DMG unit",
        START_MESSAGE1 = "Negates Reflection",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Light units UP",
        START_MESSAGE4 = "Faints least DMG inflicting unit",
        START_MESSAGE5 = "OK, I'll kill you."
    },

    [2504003] = {
        HP40_MESSAGE1 = "Lock duration depends on inflicted DMG",
        HP40_MESSAGE2 = "Heals Disease & Bleeding",
        HP40_MESSAGE3 = "Arts gauge filling speed UP",
        HP70_MESSAGE1 = "Lock duration depends on inflicted DMG",
        HP70_MESSAGE2 = "Heals Disease & Bleeding",
        HP70_MESSAGE3 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance ",
        START_MESSAGE2 = "DMG taken UP during Disease & Bleeding"
    },
    [2504013] = {
        HP40_MESSAGE1 = "Lock duration depends on inflicted DMG",
        HP40_MESSAGE2 = "Heals Disease & Bleeding",
        HP40_MESSAGE3 = "Arts gauge filling speed UP",
        HP70_MESSAGE1 = "Lock duration depends on inflicted DMG",
        HP70_MESSAGE2 = "Heals Disease & Bleeding",
        HP70_MESSAGE3 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance ",
        START_MESSAGE2 = "DMG taken UP during Disease & Bleeding"
    },
    [2505020] = {
        DEAD_MESSAGE1 = "How...stubborn!",
        HP50_MESSAGE1 = "Come, my servants.",
        START_MESSAGE1 = "Yield the path."
    },
    [2505021] = {
        DEAD_MESSAGE1 = "How...stubborn!",
        HP50_MESSAGE1 = "Come, my servants.",
        START_MESSAGE1 = "Yield the path."
    },
    [2505022] = {
        DEAD_MESSAGE1 = "I...failed!",
        HP100_MESSAGE1 = "Come, my servants.",
        HP1_MESSAGE1 = "I swear upon my blade.",
        HP50_MESSAGE1 = "Come, my servants.",
        START_MESSAGE1 = "Yield the path.",
        START_MESSAGE2 = "Reflection resistance",
        START_MESSAGE3 = "DMG from Human units UP"
    },

    [2604003] = {
        ATTACK_MESSAGE1 = "Sky Light: Faints God units",
        ATTACK_MESSAGE2 = "Terra Master: Faints Human units",
        ATTACK_MESSAGE3 = "Dark Bringer: Faints Demon units",
        BARRIER_MESSAGE1 = "Break! Impregnable mode canceled!",
        BREAK_MESSAGE1 = "Break resistance DOWN",
        DEAD_FALSE_MESSAGE1 = "I accept this pain.",
        DEAD_TRUE_MESSAGE1 = "I expected you'd be the last to obstruct me.",
        FALSE_MESSAGE1 = "This world is mine to command.",
        HP0_MESSAGE1 = "I'll surpass destiny itself...",
        HP0_MESSAGE2 = "Together with Rune Sovereign.",
        HP0_MESSAGE3 = "HP auto-recovery & Arts gauge filling speed UP",
        HP0_MESSAGE4 = "Impregnable mode canceled by Break",
        HP25_MESSAGE1 = "This is Nirshanal's Orb.",
        HP25_MESSAGE2 = "I've finally mastered its use.",
        HP25_MESSAGE3 = "Evasion rate UP",
        HP50_MESSAGE1 = "Mighty will, reside in me.",
        HP50_MESSAGE2 = "Arts gauge filling speed & DEF UP",
        HP75_MESSAGE1 = "Hear the pulse of the new world.",
        HP75_MESSAGE2 = "Magic resistance UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG",
        START_MESSAGE4 = "CRI rate UP to a target",
        TRUE_MESSAGE1 = "Come, Rayas. Take up arms."
    },
    [2604013] = {
        ATTACK_MESSAGE1 = "Sky Light: Faints God units & Arts gauge DOWN",
        ATTACK_MESSAGE2 = "Terra Master: Faints Human units & Arts gauge DOWN",
        ATTACK_MESSAGE3 = "Dark Bringer: Faints Demon units & Arts gauge DOWN",
        BARRIER_MESSAGE1 = "Break! Impregnable mode canceled!",
        BREAK_MESSAGE1 = "Break resistance DOWN",
        DEAD_FALSE_MESSAGE1 = "I accept this pain.",
        DEAD_TRUE_MESSAGE1 = "I expected you'd be the last to obstruct me.",
        FALSE_MESSAGE1 = "This world is mine to command.",
        HP0_MESSAGE1 = "I'll surpass destiny itself...",
        HP0_MESSAGE2 = "Together with Rune Sovereign.",
        HP0_MESSAGE3 = "HP auto-recovery & Arts gauge filling speed UP",
        HP0_MESSAGE4 = "Impregnable mode canceled by Break",
        HP25_MESSAGE1 = "This is Nirshanal's Orb.",
        HP25_MESSAGE2 = "I've finally mastered its use.",
        HP25_MESSAGE3 = "Evasion rate UP",
        HP50_MESSAGE1 = "Mighty will, reside in me.",
        HP50_MESSAGE2 = "Arts gauge filling speed & DEF UP",
        HP75_MESSAGE1 = "Hear the pulse of the new world.",
        HP75_MESSAGE2 = "Magic resistance UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "Shield Killer & CRI resistance",
        START_MESSAGE3 = "Targets the unit inflicts highest DMG",
        START_MESSAGE4 = "CRI rate UP to a target",
        TRUE_MESSAGE1 = "Come, Rayas. Take up arms."
    },
    [2605022] = {
        HP30_MESSAGE1 = "Units' DMG taken UP (Except Light units)",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP"
    },

    [2704003] = {
        FALSE_DEAD_MESSAGE1 = "I was one step away...",
        FALSE_HP80_MESSAGE1 = "Sainted Sword Gladius!",
        FALSE_MESSAGE1 = "It can finally begin.",
        HP0_MESSAGE1 = "Now, expose your sins.",
        HP0_MESSAGE2 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Your attacks are predictable.",
        HP50_MESSAGE2 = "Impregnable mode: canceled by Break",
        HP80_MESSAGE1 = "DMG & Physical Evasion rate UP",
        SKILL3_MESSAGE1 = "Freeze resistance DOWN",
        START_MESSAGE1 = "Reflection resistance",
        TRUE2_MESSAGE1 = "Targeting Rayas",
        TRUE2_MESSAGE2 = "CRI rate UP to a target",
        TRUE_DEAD_MESSAGE1 = "Rayas, become the True...",
        TRUE_HP80_MESSAGE1 = "Come at me with all you've got, Rayas!",
        TRUE_MESSAGE1 = "Rayas, you are the final piece."
    },
    [2704013] = {
        FALSE_DEAD_MESSAGE1 = "I was one step away...",
        FALSE_HP80_MESSAGE1 = "Sainted Sword Gladius!",
        FALSE_MESSAGE1 = "It can finally begin.",
        HP0_MESSAGE1 = "Now, expose your sins.",
        HP0_MESSAGE2 = "Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Your attacks are predictable.",
        HP50_MESSAGE2 = "Impregnable mode: canceled by Break",
        HP80_MESSAGE1 = "DMG & Physical Evasion rate UP",
        SKILL3_MESSAGE1 = "Freeze resistance DOWN",
        START_MESSAGE1 = "Reflection & CRI resistance",
        TRUE2_MESSAGE1 = "Targeting Rayas",
        TRUE2_MESSAGE2 = "CRI rate UP to a target",
        TRUE_DEAD_MESSAGE1 = "Rayas, become the True...",
        TRUE_HP80_MESSAGE1 = "Come at me with all you've got, Rayas!",
        TRUE_MESSAGE1 = "Rayas, you are the final piece."
    },
    [2705022] = {
        BREAKE_MESSAGE1 = "CRI resistance DOWN",
        BREAKE_MESSAGE2 = "DMG taken UP",
        ICE_MESSAGE1 = "CRI resistance DOWN",
        ICE_MESSAGE2 = "DMG taken UP",
        START_MESSAGE1 = "Reflection & CRI resistance",
        START_MESSAGE2 = "DMG from Water units UP",
        START_MESSAGE3 = "DMG UP by Freeze, Ultimate Freeze, or Break",
        START_MESSAGE4 = "Counters Status Ailment except Freeze & Ultimate Freeze"
    },
    [2705029] = {
        START_MESSAGE1 = "Super-recovery",
        START_MESSAGE2 = "Water DMG taken UP"
    },

    [2804013] = {
        DEAD_MESSAGE1 = "Rayas, I...",
        START_MESSAGE1 = "I'll prove the difference in our might.",
        START_MESSAGE5 = "DMG from Light units UP",
        DEAD_MESSAGE1 = "Rayas, I...",
        HP20_MESSAGE1 = "Turn to ashes! Grooooooagh!",
        HP20_MESSAGE2 = "DEF & Arts gauge filling speed UP",
        HP40_MESSAGE1 = "Feel the wrath of the cosmos!",
        HP40_MESSAGE2 = "Faint resistance & Arts gauge filling speed UP",
        HP60_MESSAGE1 = "Giant star, ignite!",
        HP60_MESSAGE2 = "Faint resistance & DMG UP",
        HP80_MESSAGE1 = "Foolish...",
        HP80_MESSAGE2 = "Faint & Magic resistance UP",
        SKILL1_1_MESSAGE1 = "CRI rate UP",
        SKILL1_2_MESSAGE1 = "DMG UP",
        START_MESSAGE1 = "I'll prove the difference in our might.",
        START_MESSAGE2 = "Reflection & CRI resistance",
        START_MESSAGE3 = "CRI resistance DOWN during Faint",
        START_MESSAGE4 = "Negates ATK by Water units",
        START_MESSAGE5 = "DMG from Light units UP"
    },
    [2804014] = {
        DEAD_MESSAGE1 = "Rayas, I...",
        HP20_MESSAGE1 = "Turn to ashes! Grooooooagh!",
        HP20_MESSAGE2 = "DEF & Arts gauge filling speed UP",
        HP40_MESSAGE1 = "Feel the wrath of the cosmos!",
        HP40_MESSAGE2 = "Faint resistance & Arts gauge filling speed UP",
        HP60_MESSAGE1 = "Giant star, ignite!",
        HP60_MESSAGE2 = "Faint resistance & DMG UP",
        HP80_MESSAGE1 = "Foolish...",
        HP80_MESSAGE2 = "Faint & Magic resistance UP",
        SKILL1_1_MESSAGE1 = "CRI rate UP",
        SKILL1_2_MESSAGE1 = "DMG UP",
        START_MESSAGE1 = "I'll prove the difference in our might.",
        START_MESSAGE2 = "Reflection & CRI resistance",
        START_MESSAGE3 = "CRI rate DOWN during Faint",
        START_MESSAGE4 = "Negates ATK by Water units",
        START_MESSAGE5 = "DMG from Light units UP"
    },
    [2805020] = {
        DEAD_MESSAGE1 = "This is...unacceptable...",
        HP50_MESSAGE1 = "Fill this body of mine.",
        TRUE_MESSAGE1 = "Come at me, Guardian.",
        START_MESSAGE1 = "Here I come."
    },
    [2805023] = {
        DEAD_MESSAGE1 = "This is...unacceptable...",
        HP50_MESSAGE1 = "Sin will never be erased.",
        TRUE_MESSAGE1 = "Come at me, Guardian.",
        START_MESSAGE1 ="Here I come."
    },
    [2805026] = {
        DEAD_MESSAGE1 = "This is...unacceptable...",
        HP30_MESSAGE1 = "Sin will never be erased.",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Dark units UP",
        TRUE_MESSAGE1 = "Come at me, Guardian.",
        START_WAVE_MESSAGE1 = "Here I come."
    },
    [2805029] = {
        DEAD_MESSAGE1 = "This is...unacceptable...",
        HP10_MESSAGE1 = "Sin will never be erased.",
        HP30_MESSAGE1 = "Sin will never be erased.",
        SKILL_MESSAGE1 = "ATK DOWN canceled by Break!",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Dark units UP",
        TRUE_MESSAGE1 = "Come at me, Guardian.",
        START_WAVE_MESSAGE1 = "Here I come."
    },

    [2903013] = {
        DEAD_MESSAGE1 = "All is for a greater will...",
        START_MESSAGE1 = "Let the feast commence."
    },
    [2903014] = {
        DEAD_MESSAGE1 = "Urgh... The Moonchilld...",
        HP0_MESSAGE1 = "Even I shall be consumed by red...",
        HP0_MESSAGE2 = "CRI rate UP",
        HP25_MESSAGE1 = "Look with awe, admiration, and acceptance.",
        HP25_MESSAGE2 = "Faint resistance & DMG UP",
        HP50_MESSAGE1 = "All is for a greater will...",
        HP50_MESSAGE2 = "Arts gauge filling speed UP & DEF UP",
        HP75_MESSAGE1 = "I shall redeem thy soul.",
        HP75_MESSAGE2 = "Arts gauge filling speed UP & CRI rate UP",
        SKILL3_MESSAGE1 = "Hrng... Such artifice!",
        SKILL3_MESSAGE2 = "Fainting %s ＆ ATK DOWN",
        SKILL5_MESSAGE1 = "Do not interfere!",
        SKILL5_MESSAGE2 = "Continuous DMG to Party",
        START_MESSAGE1 = "Let the feast commence.",
        START_MESSAGE2 = "Reflection, Arts gauge DOWN, & CRI RES.",
        START_MESSAGE3 = "DMG Negation canceled",
        START_MESSAGE4 = "DMG taken UP during Fainted"
    },
    [2905020] = {
        DEAD_MESSAGE1 = "I'm so weak...",
        HP50_MESSAGE1 = "I'll show you.",
        START_MESSAGE1 = "Time to get serious."
    },
    [2905023] = {
        DEAD_MESSAGE1 = "I'm so weak...",
        HP50_MESSAGE1 = "This is everything I got!",
        START_MESSAGE1 = "Time to get serious."
    },
    [2905026] = {
        SKILL_MESSAGE1 = "All status UP (Stacks)",
        SKILL_MESSAGE2 = "Magic & CRI resistance UP",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Water units UP"
    },
    [2905029] = {
        SKILL_MESSAGE1 = "All status UP (Stacks)",
        SKILL_MESSAGE2 = "Magic & CRI resistance UP",
        START_MESSAGE1 = "Reflection resistance",
        START_MESSAGE2 = "DMG from Human units UP",
        START_MESSAGE3 = "DMG from Water units UP"
    },

    [3005013] = {
        START_MESSAGE1 = "Water resistance",
        START_MESSAGE2 = "DMG taken UP during Poison or Burn",
        ATTACK6_MESSAGE1 = "A freezing wind blows."
    },
    [3005014] = {
        START_MESSAGE1 = "Reflection & Water resistance",
        START_MESSAGE2 = "DMG taken UP during Poison or Burn",
        START_MESSAGE3 = "Evasion rate DOWN every time Arts is interrupted by Paralysis or Faint",
        PARALYZE_MESSAGE1 = "Arts interrupted by Paralysis! Evasion rate DOWN",
        STUN_MESSAGE1 = "Arts interrupted by Faint! Evasion rate DOWN",
        ATTACK6_MESSAGE1 = "A freezing wind blows.",
        HP70_MESSAGE1 = "CRI rate UP",
        HP30_MESSAGE1 = "DEF UP",
        HP0_MESSAGE1 = "Paralysis & Faint resistance UP",
        HP0_MESSAGE2 = "Arts gauge filling speed & Evasion rate UP"
    },
    [3005020] = {
        DEAD_MESSAGE1 = "Why...did I...?",
        HP50_MESSAGE1 = "White Dragon...",
        START_MESSAGE1 = "If I must..."
    },
    [3005023] = {
        DEAD_MESSAGE1 = "Why...did I...?",
        HP50_MESSAGE1 = "Ama-no-Yuraragi!",
        START_MESSAGE1 = "If I must..."
    },
    [3005026] = {
        DEAD_MESSAGE1 = "Chloe...",
        HP50_MESSAGE1 = "Ama-no-Yuraragi!",
        START_MESSAGE1 = "If I must...",
        START_MESSAGE2 = "DMG to enemy UP by # of Races in party",
        START_MESSAGE3 = "DMG from Dark units UP",
        START_MESSAGE4 = "Arts gauge DOWN & Reflection resistance"
    },
    [3005029] = {
        BREAK_MESSAGE1 = "DMG taken DOWN Canceled",
        DEAD_MESSAGE1 = "Lord...Luahn...",
        HP50_MESSAGE1 = "Prepare yourself!",
        START_MESSAGE1 = "Here I come.",
        START_MESSAGE2 = "DMG taken DOWN",
        START_MESSAGE3 = "DMG taken DOWN canceled by Break",
        MESSAGE1 = "I'll show you I can bear this pain."
    },

    [3104013] = {
        DEAD_MESSAGE1 = "Why...?",
        START_MESSAGE1 = "I will become one with the blade.",
        START_MESSAGE2 = "Reflection resistance"
    },
    [3104014] = {
        DEAD_MESSAGE1 = "Why...?",
        ELEMENT_MESSAGE0 = "None",
        ELEMENT_MESSAGE1 = "Fire",
        ELEMENT_MESSAGE2 = "Water",
        ELEMENT_MESSAGE3 = "Earth",
        ELEMENT_MESSAGE4 = "Light",
        ELEMENT_MESSAGE5 = "Dark",
        HP0_MESSAGE1 = "O holy blade. give me strength.",
        HP0_MESSAGE2 = "Arts gauge filling speed UP",
        HP10_MESSAGE1 = "Sword of salvation, light up the void.",
        HP10_MESSAGE2 = "CRI rate UP",
        HP50_MESSAGE1 = "I see your next move.",
        HP50_MESSAGE2 = "Element DMG taken significantly reduced",
        HP50_MESSAGE3 = "CRI rate UP",
        SKILL_MESSAGE1 = "Party DMG taken UP",
        START_MESSAGE1 = "I will become one with the blade.",
        START_MESSAGE2 = "Reflection resistance",
        START_MESSAGE3 = "Reduces DMG taken from the Element cause the most DMG"
    },
    [3105020] = {
        DEAD_MESSAGE1 = "You...pierced it?",
        HP50_MESSAGE1 = "Let me show you how to use a shield.",
        START_MESSAGE1 = "Defense is the greatest offense!"
    },
    [3105023] = {
        DEAD_MESSAGE1 = "You...pierced it?",
        HP50_MESSAGE1 = "The Invincible Shield turns aside every blade!",
        START_MESSAGE1 = "Defense is the greatest offense!"
    },
    [3105026] = {
        BREAK_MESSAGE1 = "DMG taken DOWN canceled",
        BREAK_MESSAGE2 = "CRI resistance DOWN",
        BREAK_MESSAGE3 = "CRI resistance UP",
        HP30_MESSAGE1 = "Defend against the powerful strike!",
        START_MESSAGE1 = "CRI resistance DOWN during Break",
        START_MESSAGE2 = "DMG taken DOWN canceled by Break",
        START_MESSAGE3 = "DMG from God units UP",
        START_MESSAGE4 = "DMG from Light units UP",
        START_MESSAGE5 = "Arts gauge DOWN & Reflection resistance",
        },
    [3105029] = {
        BREAK_MESSAGE1 = "DMG taken DOWN canceled",
        BREAK_MESSAGE2 = "CRI resistance DOWN",
        BREAK_MESSAGE3 = "CRI resistance UP",
        BREAK_MESSAGE4 = "The final blow DMG DOWN",
        HP30_MESSAGE1 = "Defend against the powerful strike!",
        START_MESSAGE1 = "CRI resistance DOWN during Break",
        START_MESSAGE2 = "DMG taken DOWN canceled by Break",
        START_MESSAGE3 = "DMG from God units UP",
        START_MESSAGE4 = "DMG from Light units UP",
        START_MESSAGE5 = "Arts gauge DOWN & Reflection resistance"
    },

    mine_10034 = {
        START_MESSAGE1 = "Who wants this shining gold?",
        DEAD_MESSAGE1 = "Bye bye meow♪"
    },

    mine_10035 = {
        START_MESSAGE1 = "It's dangerous ahead!",
        DEAD_MESSAGE1 = "You can do this!"
    },

    mine_10036 = {
        DEAD_MESSAGE1 ="Good Luck!"
    },

    mine_50001 = {
        START_MESSAGE1 = "CRI rate UP",
        START_MESSAGE2 = "CRI DMG UP",
        BOOST_MESSAGE1 = "ATK UP",
        BOOST_MESSAGE2 = "DMG to enemy UP",
        BOOST_MESSAGE3 = "Own DMG from enemy DOWN",
        BOOST_MESSAGE4 = "Break resistance UP",
        RAGE_MESSAGE1 = "Rage mode"
    },

    mine_50002 = {
        START_MESSAGE1 = "DMG from enemy UP when Paralyzed",
        BOOST_MESSAGE1 = "ATK UP",
        BOOST_MESSAGE2 = "DMG to enemy UP",
        BOOST_MESSAGE3 = "Own DMG from enemy DOWN",
        BOOST_MESSAGE4 = "Break resistance UP"
    },

    mine_50003 = {
        BUFF_MESSAGE = "Storm Mode: evasion rate UP & Break resistance UP",
        REMOVE_BUFF_MESSAGE = "Storm Mode CANCELED",
        TIMEUP_BUFF_MESSAGE1 = "Own DMG from enemy DOWN",
        TIMEUP_BUFF_MESSAGE2 = "Break resistance UP",
        TIMEUP_BUFF_MESSAGE3 = "ATK UP",
        TIMEUP_BUFF_MESSAGE4 = "DMG UP"
    },

    mine_50004 = {
        START_MESSAGE1 = "Physical resistance UP",
        BOOST_MESSAGE1 = "ATK UP",
        BOOST_MESSAGE2 = "DMG to enemy UP",
        BOOST_MESSAGE3 = "Own DMG from enemy DOWN",
        BOOST_MESSAGE4 = "Break resistance UP"
    },

    mine_50005 = {
        START_MESSAGE1 = "Light & Dark killer",
        START_MESSAGE2 = "Fire, Water & Earth resistance",
        BOOST_MESSAGE1 = "ATK UP",
        BOOST_MESSAGE2 = "DMG to enemy UP",
        BOOST_MESSAGE3 = "Own DMG from enemy DOWN",
        BOOST_MESSAGE4 = "Break resistance UP"
    },

    mine_50006 = {
        START_MESSAGE1 = "Arts DMG DOWN",
        BOOST_MESSAGE1 = "ATK UP",
        BOOST_MESSAGE2 = "DMG UP"
    },
    mine_50007 = {
        BUFF_MESSAGE1 = "Burning Mode:Action Speed Boosted",
        BUFF_MESSAGE2 = "Magic Res UP",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_50008 = {
        START_MESSAGE2 = "CRI rate UP",
        START_MESSAGE3 = "CRI DMG UP",
        START_MESSAGE4 = "Negates CRI DMG",
        HP50_MESSAGE1 = "ATK Action speed UP",
        KABAU_MESSAGE1 = "DMG taken UP"
    },
    mine_50009 = {
        START_MESSAGE = "CRI DMG UP",
        HP_REDUCE_MESSAGE = "DMG taken UP when Burning",
        KABAU_MESSAGE1 = "Shield Killer",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5010 = {
        DEAD = "Finis Machina Activated",
        DECAY_MESSAGE1 = "Consumes Element energy: Finis Machina power decay",
        ELEMENT_AQUA = "Water energy",
        ELEMENT_BUFF_AQUA = "Water resistance UP",
        ELEMENT_BUFF_DARK = "Dark resistance UP",
        ELEMENT_BUFF_EARTH = "Earth resistance UP",
        ELEMENT_BUFF_FIRE = "Fire resistance UP",
        ELEMENT_BUFF_LIGHT = "Light resistance UP",
        ELEMENT_DARK = "Dark Energy",
        ELEMENT_EARTH = "Earth Energy",
        ELEMENT_FIRE = "Fire Energy",
        ELEMENT_KILLER_AQUA = "Water Killer",
        ELEMENT_KILLER_DARK = "Dark Killer",
        ELEMENT_KILLER_EARTH = "Earth Killer",
        ELEMENT_KILLER_FIRE = "Fire Killer",
        ELEMENT_KILLER_LIGHT = "Light Killer",
        ELEMENT_LIGHT = "Light energy",
        START_MESSAGE1 = "Element changes for certain amount of DMG",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5011 = {
        START_MESSAGE1 = "Single Blow",
        START_MESSAGE2 = "0,000 DMG for Weakening",
        DAMAGE_1 = "0,000",
        DAMAGE_2 = "DMG taken & weakened!",
        DAMAGE_3 = "Single Blow",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5012 = {
        START_MESSAGE2 = "You shall fear the name of Ugetsu!",
        START_MESSAGE1 = "DMG taken UP when diseased or Freeze",
        HP70_MESSAGE2 = "The moon fills me with power.",
        HP70_MESSAGE1 = "ATK UP",
        HP50_MESSAGE2 = "Redder... deeper... darker...",
        HP50_MESSAGE1 = "DMG UP",
        HP25_MESSAGE2 = "The blood moon rises, and I will feast.",
        HP25_MESSAGE1 = "CRI rate UP",
        FIRE_MESSAGE = "Negates Fire ATK",
        DARK_MESSAGE = "Negates Dark ATK",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP",
        SICK_MESSAGE = "*cough* You...defiled my blood?",
        FREEZE_MESSAGE = "You impertinent worms!",
        DEAD_MESSAGE = "The moon is...gone...?"
    },
    mine_5013 = {
        START_MESSAGE1 = "Shield Killer, Reflex Res & Arts gauge DOWN Res",
        SUMMON_MESSAGE1 = "Boss: DMG UP for # of Mohldoras",
        SUMMON_MESSAGE2 = "Mohldora: Negates DMG except Poison or Burn",
        HP50_MESSAGE1 = "Immitigable Fixed DMG ATK",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5014 = {
        HP30_MESSAGE1 = "DMG & CRI rate UP",
        HP30_MESSAGE2 = "Arts gauge UP when activating Arts",
        START_MESSAGE1 = "DMG UP to Blinded units",
        START_MESSAGE2 = "Poisoned units DMG UP",
        START_MESSAGE3 = "Reflection & Arts gauge DOWN RES",
        START_MESSAGE4 = "Status Ailment resistance penetrating ATK",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5016 = {
        BURN_MESSAGE1 = "Evasion UP Cancelled by Burn!",
        SKILL3_MESSAGE1 = "A freezing gust sweeps the area",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "Water resistance",
        START_MESSAGE3 = "Evasion rate UP Cancelled during Burn",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5017 = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Earth resistance",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5018 = {
        BP_REVERSE_BUFF_MESSAGE1 = "Cancels Arts gauge Auto-fill",
        HP30_MESSAGE1 = "DMG UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG taken UP when Blinded",
        START_MESSAGE3 = "DMG from Humans DOWN",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5019 = {
        GRAB_MESSAGE1 = "Holds a unit with the highest HP",
        HUMMER_MESSAGE1 = "Rage Status: CRI rate & Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "Humans, Gods & Demons Killer",
        START_MESSAGE3 = "DMG taken from Humans, Gods & Demons DOWN",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5021 = {
        BREAK_END_MESSAGE1 = "Break resistance UP",
        BREAK_MESSAGE1 = "Break! DMG taken UP!",
        HP50_MESSAGE1 = "Arts gauge filling speed & CRI resistance UP",
        SKILL4_MESSAGE1 = "%d DMG",
        START_MESSAGE1 = "Fire, Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "More Freezed enemy, DMG taken DOWN",
        START_MESSAGE3 = "Break DMG UP During Burn or Disease",
        START_MESSAGE4 = "More Break, more DMG",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5022 = {
        PILE_DESTROY_MESSAGE1 = "Grásiða destroyed!",
        PILE_DESTROY_MESSAGE2 = "Boss’s Arts gauge filling speed DOWN up until Arts activation",
        PILE_SET_MESSAGE1 = "%s Locked: Destroy Grásiða to cancel",
        PILE_SET_MESSAGE2 = "Grásiða: DMG taken UP during Paralysys",
        PILE_SET_MESSAGE3 = "Boss: Evasion rate UP, DMG taken DOWN, and HP auto-recovery",
        SKILL1_MESSAGE1 = "DMG UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "CRI resistance",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_5023 = {
        ATTACK_MESSAGE1 = "HP DOWN to half ",
        HP50_MESSAGE1 = "Evasion rate & Arts gauge filling speed UP",
        SKILL_MESSAGE1 = "ATK DOWN",
        SKILL_MESSAGE2 = "Freeze resistance DOWN",
        SKILL_MESSAGE3 = "CRI resistance UP",
        SKILL_MESSAGE4 = "Endless: Cancels DMG Negation",
        START_MESSAGE1 = "Light, Dark, Reflection, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Impregnable mode canceled by Break",
        START_MESSAGE3 = "DMG from Lowest HP unit UP",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },

    mine_60001 = {
        START_MESSAGE1 = "DMG from enemy UP when Paralyzed",
        BOOST_MESSAGE1 = "ATK UP",
        BOOST_MESSAGE2 = "DMG to enemy UP",
        BOOST_MESSAGE3 = "Own DMG from enemy DOWN",
        BOOST_MESSAGE4 = "Break resistance UP"
    },
    mine_60002 = {
        START_MESSAGE1 = "Negates Physical DMG",
        BOOST_MESSAGE1 = "ATK UP",
        BOOST_MESSAGE2 = "DMG to enemy UP",
        BOOST_MESSAGE3 = "Own DMG from enemy DOWN",
        BOOST_MESSAGE4 = "Break resistance UP"
    },
    mine_60003 = {
        BUFF_MESSAGE = "Storm Mode: evasion rate UP & Break resistance UP",
        REMOVE_BUFF_MESSAGE = "Storm Mode CANCELED",
        TIMEUP_BUFF_MESSAGE1 = "Own DMG from enemy DOWN",
        TIMEUP_BUFF_MESSAGE2 = "Break resistance UP",
        TIMEUP_BUFF_MESSAGE3 = "ATK UP",
        TIMEUP_BUFF_MESSAGE4 = "DMG UP"
    },
    mine_60004 = {
        BUFF_MESSAGE1 = "Burning Mode:Action Speed Boosted",
        BUFF_MESSAGE2 = "Negates Magic DMG",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_60005 = {
        START_MESSAGE1 = "DEF UP",
        START_MESSAGE2 = "CRI rate UP",
        START_MESSAGE3 = "CRI DMG UP",
        START_MESSAGE4 = "Negates CRI DMG",
        HP50_MESSAGE1 = "ATK Action speed UP",
        KABAU_MESSAGE1 = "DMG taken UP",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_60006 = {
        START_MESSAGE = "CRI DMG UP",
        HP_REDUCE_MESSAGE = "DMG taken UP when Burning",
        KABAU_MESSAGE1 = "Shield Killer",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_6007 = {
        DEAD = "Finis Machina Activated",
        DECAY_MESSAGE1 = "Consumes Element energy: Finis Machina power decay",
        ELEMENT_AQUA = "Water energy",
        ELEMENT_BUFF_AQUA = "Water resistance UP",
        ELEMENT_BUFF_DARK = "Dark resistance UP",
        ELEMENT_BUFF_EARTH = "Earth resistance UP",
        ELEMENT_BUFF_FIRE = "Fire resistance UP",
        ELEMENT_BUFF_LIGHT = "Light resistance UP",
        ELEMENT_DARK = "Dark energy",
        ELEMENT_EARTH = "Earth energy",
        ELEMENT_FIRE = "Fire energy",
        ELEMENT_KILLER_AQUA = "Water Killer",
        ELEMENT_KILLER_DARK = "Dark Killer",
        ELEMENT_KILLER_EARTH = "Earth Killer",
        ELEMENT_KILLER_FIRE = "Fire Killer",
        ELEMENT_KILLER_LIGHT = "Light Killer",
        ELEMENT_LIGHT = "Light energy",
        START_MESSAGE1 = "Element changes for certain amount of DMG",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"

    },
    mine_6008 = {
        START_MESSAGE1 = "Single Blow",
        START_MESSAGE2 = "0,000 DMG for Weakening",
        DAMAGE_1 = "0,000",
        DAMAGE_2 = "DMG taken & weakened!",
        DAMAGE_3 = "Single Blow",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP",
        ELEMENT1 = "Negates Non-Elemental DMG for a duration of time",
        ELEMENT2 = "Negates Fire DMG for a duration of time",
        ELEMENT3 = "Negates Water DMG for a duration of time",
        ELEMENT4 = "Negates Earth DMG for a duration of time",
        ELEMENT5 = "Negates Light DMG for a duration of time",
        ELEMENT6 = "Negates Dark DMG for a duration of time"
    },
    mine_6009 = {
        START_MESSAGE2 = "You shall fear the name of Ugetsu!",
        START_MESSAGE1 = "DMG taken UP when diseased or Freeze",
        START_MESSAGE3 = "Lifesteal for amount of DMG inflicting",
        HP70_MESSAGE2 = "The moon fills me with power.",
        HP70_MESSAGE1 = "ATK UP",
        HP50_MESSAGE2 = "Redder... deeper... darker...",
        HP50_MESSAGE1 = "DMG UP",
        HP25_MESSAGE2 = "The blood moon rises, and I will feast.",
        HP25_MESSAGE1 = "CRI rate UP",
        FIRE_MESSAGE = "Negates Fire ATK",
        DARK_MESSAGE = "Negates Dark ATK",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP",
        SICK_MESSAGE = "*cough* You...defiled my blood?",
        FREEZE_MESSAGE = "You impertinent worms!",
        DEAD_MESSAGE = "The moon is...gone...?"
    },
    mine_6010 = {
        START_MESSAGE1 = "Shield Killer, Reflex Res & Arts gauge DOWN Res",
        SUMMON_MESSAGE1 = "Boss: DMG UP for # of Mohldoras",
        SUMMON_MESSAGE2 = "Mohldora: Negates DMG except Poison or Burn",
        SUMMON_MESSAGE3 = "Boss: Resistance to All Elements UP for # of Ragvelothes",
        SUMMON_MESSAGE4 = "Ragveloth: DEF is very High!",
        HP50_MESSAGE1 = "Immitigable Fixed DMG ATK",
        HP30_MESSAGE1 = "It called minions in desperation!",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_6011 = {
        HP30_MESSAGE1 = "DMG & CRI rate UP",
        HP30_MESSAGE2 = "Arts gauge UP when activating Arts",
        START_MESSAGE1 = "DMG & CRI rate UP to Blinded units",
        START_MESSAGE2 = "Negates DMG except Poisoned units",
        START_MESSAGE3 = "Reflection & Arts gauge DOWN RES",
        START_MESSAGE4 = "Status Ailment resistance penetrating ATK",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_60012 = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN Res",
        START_MESSAGE2 = "Shield Killer",
        HP70_MESSAGE1 = "Aaaaah!",
        HP20_MESSAGE1 = "Eeyaaaah!",
        HP20_MESSAGE2 = "Action speed & Arts gauge increase amount UP",
        HOLD_MESSAGE1 = "Helds lowest MAX HP & DMG Negation CANCELED",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_6014 = {
        BURN_MESSAGE1 = "Evasion UP Cancelled by Burn!",
        SKILL3_MESSAGE1 = "A freezing gust sweeps the area",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "Water resistance & Shield Killer",
        START_MESSAGE3 = "Evasion rate UP Cancelled during Burn",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_6015 = {
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Earth resistance",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_6016 = {
        BREAK_END_MESSAGE1 = "Break resisitance UP",
        BREAK_MESSAGE1 = "Break! DMG taken UP!",
        BURN_MESSAGE1 = "CRI rate UP during Burn",
        HP30_MESSAGE1 = "Arts gauge filling speed UP & DMG Negation canceled",
        START_MESSAGE1 = "Reflection, Lifesteal, & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Negates Earth DMG ",
        START_MESSAGE3 = "CRI rate UP When Burning",
        START_MESSAGE4 = "More Break, more DMG taken",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_6017 = {
        BP_REVERSE_BUFF_MESSAGE1 = "Reverse Arts gauge Auto-fill",
        HP30_MESSAGE1 = "DMG & CRI resistance UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG taken UP when Blinded",
        START_MESSAGE3 = "DMG from Humans DOWN",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_6018 = {
        GRAB_MESSAGE1 = "Holds a unit with the highest HP",
        HUMMER_MESSAGE1 = "Rage Status: CRI rate & Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection, Lifesteal & Arts gauge DOWN RES. ",
        START_MESSAGE2 = "Humans, Gods & Demons Killer",
        START_MESSAGE3 = "DMG taken from Humans, Gods & Demons DOWN",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_6020 = {
        BREAK_END_MESSAGE1 = "Break resistance UP",
        BREAK_MESSAGE1 = "Break! DMG taken UP!",
        HP50_MESSAGE1 = "Arts gauge filling speed & CRI resistance UP",
        SKILL4_MESSAGE1 = "%d DMG",
        START_MESSAGE1 = "Fire, Reflection, Lifesteal, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "DMG UP to Freezing enemy",
        START_MESSAGE3 = "More Freezed enemy, DMG taken DOWN",
        START_MESSAGE4 = "Break DMG UP During Burn or Disease",
        START_MESSAGE5 = "More Break, more DMG",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_6021 = {
        PILE_DESTROY_MESSAGE1 = "Grásiða destroyed!",
        PILE_DESTROY_MESSAGE2 = "Boss’s Arts gauge filling speed DOWN up until Arts activation",
        PILE_SET_MESSAGE1 = "%s Locked: Destroy Grásiða to cancel",
        PILE_SET_MESSAGE2 = "Grásiða: DMG taken UP during Paralysys",
        PILE_SET_MESSAGE3 = "Boss: Evasion rate UP, DMG taken DOWN, and HP auto-recovery",
        PILE_SET_MESSAGE4 = "CRI DMG UP",
        SKILL1_MESSAGE1 = "DMG UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "CRI resistance",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },
    mine_6022 = {
        ATTACK_MESSAGE1 = "HP DOWN to half ",
        HP50_MESSAGE1 = "Evasion rate & Arts gauge filling speed UP",
        SKILL_MESSAGE1 = "ATK DOWN",
        SKILL_MESSAGE2 = "Freeze resistance DOWN",
        SKILL_MESSAGE3 = "CRI resistance UP",
        SKILL_MESSAGE4 = "Endless: Cancels DMG Negation",
        START_MESSAGE1 = "Light, Dark, Reflection, & Arts gauge DOWN RES.",
        START_MESSAGE2 = "Impregnable mode canceled by Break",
        START_MESSAGE3 = "DMG from Lowest HP unit UP",
        START_MESSAGE4 = "DMG UP to Poisoned, Freezed, & Burning enemy",
        TIMEUP_BUFF_MESSAGE1 = "ATK UP",
        TIMEUP_BUFF_MESSAGE2 = "DMG UP"
    },

    gb_101601 = {
        CHARGE_END_MESSAGE1 = "Charging mode canceled!",
        CHARGE_MESSAGE1 = "Charging...",
        CHARGE_MESSAGE2 = "Canceled by Paralysis, Freeze or Break",
        SKILL1_MESSAGE1 = "Evasion rate UP for certain period of time",
        SKILL2_MESSAGE1 = "Party ATK DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Evasion rate UP",
        START_MESSAGE3 = "DMG to the unit inflicts highest DMG UP "
    },
    gb_102601 = {
        HP30_MESSAGE1 = "CRI resistance & Arts gauge filling speed UP",
        HP60_MESSAGE1 = "Physical resistance UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Evasion rate UP",
        START_MESSAGE3 = "DMG to the unit inflicts highest DMG UP ",
        START_MESSAGE4 = "DMG taken UP during Disease"
    },
    gb_103601 = {
        BARRIER_BREAK_MESSAGE1 = "Penetrated the shield!",
        BARRIER_MESSAGE1 = "Shield deployed: DMG taken DOWN",
        BARRIER_MESSAGE2 = "CRI DMG taken significantly reduced",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Evasion rate UP",
        START_MESSAGE3 = "DMG to the unit inflicts highest DMG UP "
    },
    gb_104601 = {
        HP30_MESSAGE1 = "CRI resistance & Arts gauge filling speed UP",
        HP60_MESSAGE1 = "Magic resistance UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Evasion rate UP! / Weakened when Freezed",
        START_MESSAGE3 = "DMG to the unit inflicts highest DMG UP ",
        START_MESSAGE4 = "CRI rate UP to Burning enemy"
    },
    gb_105601 = {
        HP_MESSAGE1 = "Freezes ",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Evasion rate UP",
        START_MESSAGE3 = "DMG to the unit inflicts highest DMG UP "
    },
    gb_301601 = {
        GRAD_MESSAGE1 = "Holds the unit inflicts highest DMG",
        HP40_MESSAGE1 = "Arts gauge filling speed UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG to the unit inflicts highest DMG UP",
        START_MESSAGE3 = "DMG from Poisoned & Blinded units DOWN",
        START_MESSAGE4 = "Shield Killer",
        START_MESSAGE5 = "Intimidate: units' ATK DOWN"
    },
    gb_302601 = {
        BARRIER_BREAK_MESSAGE1 = "Penetrated the sield!",
        BARRIER_MESSAGE1 = "Shield deployed: DMG taken DOWN",
        BARRIER_MESSAGE2 = "Faints the unit inflicts highest DMG & Reduce Arts gauge",
        BARRIER_MESSAGE3 = "Magic DMG taken significantly reduced",
        START_BUFF_MESSAGE1 = "Swamp Venom Creeps",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "Intimidate: units' ATK DOWN",
        START_MESSAGE3 = "DMG to the unit inflicts highest DMG UP "
    },
    gb_303601 = {
        HP20_MESSAGE1 = "CRI resistance & Arts gauge filling speed UP",
        HP50_MESSAGE1 = "CRI rate UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG to the unit inflicts highest DMG UP ",
        START_MESSAGE3 = "DMG taken UP when Poisoned",
        START_MESSAGE4 = "Intimidate: units' ATK DOWN"
    },
    gb_304601 = {
        CHARGE_MESSAGE1 = "Charging...",
        CHARGE_MESSAGE2 = "Canceled by Faint & Break",
        CHARGE_OFF_MESSAGE1 = "Charging mode canceled!",
        SKILL_MESSAGE1 = "Party Accuracy DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG to the unit inflicts highest DMG UP",
        START_MESSAGE3 = "Intimidate: units' ATK DOWN"
    },
    gb_305601 = {
        HP30_MESSAGE1 = "Arts gauge filling speed UP",
        HP70_MESSAGE1 = "Physical resistance UP",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG to the unit inflicts highest DMG UP",
        START_MESSAGE3 = "Cancels DMG Negation",
        START_MESSAGE4 = "DMG from Poisoned & Diseased units UP",
        START_MESSAGE5 = "Intimidate: units' ATK DOWN"
    },

    gb_901000011 = {
        BREAK_MESSAGE1 = "Break! Flying mode cancelled! CRI RES. DOWN",
        BREAK_MESSAGE2 = "Fire units' Arts gauge UP",
        BREAK_REPAIR_MESSAGE1 = "Fire units' Arts gauge UP",
        HP0_MESSAGE1 = "HP recovery amount & Arts gauge filling speed UP",
        HP50_MESSAGE1 = "Arts gauge filling speed UP",
        PRAYER_MESSAGE1 = "Negates Arts gauge UP",
        PRAYER_MESSAGE2 = "Taking DMG: A. gauge UP",
        START2_MESSAGE1 = "DMG from Water units DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG to highest DMG unit UP ",
        START_MESSAGE3 = "Flying: CRI RES. UP, canc. by Break"
    },
    gb_900080011 = {
        CHILL_MESSAGE1 = "Calmed the giant's wrath",
        HP0_MESSAGE1 = "HP recovery & Arts gauge filling speed UP",
        HP20_MESSAGE1 = "CRI resistance UP",
        HP60_MESSAGE1 = "Arts gauge filling speed UP",
        PRAYER_MESSAGE1 = "Negates Arts gauge UP",
        PRAYER_MESSAGE2 = "Taking DMG: A. gauge UP",
        RAGE_MESSAGE1 = "Rage mode: Canceled by Paralysis, Faint, or Break",
        SKILL_MESSAGE1 = "Party MAX HP DOWN",
        START2_MESSAGE1 = "DMG from Dark units DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG to the unit inflicts highest DMG UP"
    },
    gb_900130011 = {
        CHILL_MESSAGE1 = "Calmed the giant's wrath",
        HP0_MESSAGE1 = "HP recovery & Arts gauge filling speed UP",
        HP20_MESSAGE1 = "CRI resistance UP",
        HP60_MESSAGE1 = "Arts gauge filling speed UP",
        PRAYER_MESSAGE1 = "Negates Arts gauge UP",
        PRAYER_MESSAGE2 = "Taking DMG: A. gauge UP",
        RAGE_MESSAGE1 = "Rage mode: Canceled by Paralysis, Faint, or Break",
        SKILL_MESSAGE1 = "Party MAX HP DOWN",
        START2_MESSAGE1 = "DMG from Dark units DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG to the unit inflicts highest DMG UP"
    },
    gb_900230011 = {
        CHILL_MESSAGE1 = "Calmed the giant's wrath",
        HP0_MESSAGE1 = "HP recovery & Arts gauge filling speed UP",
        HP20_MESSAGE1 = "CRI resistance UP",
        HP60_MESSAGE1 = "Arts gauge filling speed UP",
        PRAYER_MESSAGE1 = "Negates Arts gauge UP",
        PRAYER_MESSAGE2 = "Taking DMG: A. gauge UP",
        RAGE_MESSAGE1 = "Rage mode: Canceled by Paralysis, Faint, or Break",
        SKILL_MESSAGE1 = "Party MAX HP DOWN",
        START2_MESSAGE1 = "DMG from Dark units DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG to the unit inflicts highest DMG UP"
    },
    gb_900530011 = {
        CHILL_MESSAGE1 = "Calmed the giant's wrath",
        HP0_MESSAGE1 = "HP recovery & Arts gauge filling speed UP",
        HP20_MESSAGE1 = "CRI resistance UP",
        HP60_MESSAGE1 = "Arts gauge filling speed UP",
        PRAYER_MESSAGE1 = "Negates Arts gauge UP",
        PRAYER_MESSAGE2 = "Taking DMG: A. gauge UP",
        RAGE_MESSAGE1 = "Rage mode: Canceled by Paralysis, Faint, or Break",
        SKILL_MESSAGE1 = "Party MAX HP DOWN",
        START2_MESSAGE1 = "DMG from Dark units DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG to the unit inflicts highest DMG UP"
    },
    gb_901030011 = {
        CHILL_MESSAGE1 = "Calmed the giant's wrath",
        HP0_MESSAGE1 = "HP recovery & Arts gauge filling speed UP",
        HP20_MESSAGE1 = "CRI resistance UP",
        HP60_MESSAGE1 = "Arts gauge filling speed UP",
        PRAYER_MESSAGE1 = "Negates Arts gauge UP",
        PRAYER_MESSAGE2 = "Taking DMG: A. gauge UP",
        RAGE_MESSAGE1 = "Rage mode: Canceled by Paralysis, Faint, or Break",
        SKILL_MESSAGE1 = "Party MAX HP DOWN",
        START2_MESSAGE1 = "DMG from Dark units DOWN",
        START_MESSAGE1 = "Reflection & Arts gauge DOWN resistance",
        START_MESSAGE2 = "DMG to the unit inflicts highest DMG UP"
    },

    gbBossBase = {
        START_MESSAGE1 = "DMG taken UP during Poisoned",
        START_MESSAGE2 = "DMG taken UP during Diseased",
        START_MESSAGE3 = "DMG taken UP during Fainted",
        START_MESSAGE4 = "DMG taken UP during Frozen",
        START_MESSAGE5 = "DMG taken UP during Burnt"
    }
    
}


_M.QUESTS = {
    --タスモン強襲
    [1001402] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },
    [1001401] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },

    --ゴルネコ強襲
    [1001302] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },
    [1001301] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },

    --ミキュオン強襲
    [1001201] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },

    --コロック強襲
    [1001101] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },

    --フレイド強襲
    [1000901] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },

    --ミキュオン強襲
    [1000801] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },

    --コロック強襲
    [1000701] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },

    --フレイド強襲
    [1000601] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },

    --メタチキ強襲
    [1001701] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },

    --メタチキ強襲
    [1001702] = {
        DEAD_ENEMY_TEXT = "Defeated",
    },

    [4000301] = {
        mess1 = "What's with this guys! Gotta tell the Boss!"
    },
    [4000302] = {
        mess1 = "What's with this guys! Gotta tell the Boss!"
    },
    [4000303] = {
        mess1 = "What's with this guys! Gotta tell the Boss!"
    },
    [4000304] = {
        mess1 = "What's with this guys! Gotta tell the Boss!"
    },
    [2014814] = {
        TALK_1 = "Out of time, I see.",
        TALK_2 = "See ya later, alligator!",
        TALK_3 = "Aw, too bad...!",
        TALK_4 = "I guess this is where it ends.",
        TALK_5 = "It was a close fight..."
    },
    [2037414] = {
        START_MESSAGE1 = "Clear to defeat 10 foes within the time limit!",
        START_MESSAGE2 = "Orochi: Evasion rate UP",
        START_MESSAGE3 = "Fiana: Arts DMG taken DOWN",
        START_MESSAGE4 = "Rizer: CRI resistance",
        DEAD_MESSAGE1 = "%d Defeated",
        END_MESSAGE1 = "Orochi %d",
        END_MESSAGE2 = "Fiana %d",
        END_MESSAGE3 = "Rizer %d"
    },
    [2039916] = {
        END_MESSAGE1 = "Speed Challenge failed..."
    },
    [2000531] = {
        START_MESSAGE1 = "CRI resistance",
        START_MESSAGE2 = "Status UP by # of defeated foes within a set period",
        DEAD_MESSAGE0 = "All allies' HP UP",
        DEAD_MESSAGE1 = "All allies' ATK UP"
    }

}

_M.MAP_THEME = {
    [7] = {
        TIMER_MESSAGE1 = "Swamp Venom Creeps"
    }
}

_G.package.loaded[_NAME] = _M
return _M
