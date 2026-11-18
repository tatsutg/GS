local class = summoner.Bootstrap.createEnemyClass({label="モキュオンチャレンジ_閃光の文化部長シャウラ(100周目)", version=2.7, id=20851200});
class:inheritFromEnemy("20851101");
---INFOは親(20851101)の ja_jp を使う（子IDごとの登録を不要にする）
class.TEXT = summoner.Text:fetchByEnemyID(20851101);
class:publish();

return class;
