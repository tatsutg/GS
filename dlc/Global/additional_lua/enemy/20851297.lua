local class = summoner.Bootstrap.createEnemyClass({label="モキュオンチャレンジ_モキュオン(97周目)", version=2.7, id=20851297});
class:inheritFromEnemy("20851211");
---INFOは親(20851211)の ja_jp を使う（子IDごとの登録を不要にする）
class.TEXT = summoner.Text:fetchByEnemyID(20851211);
class:publish();

return class;
