local class = summoner.Bootstrap.createEnemyClass({label="仮の戦士", version=1.3, id=100112111});

function class:start(event)
    self.log("mine_の LUA が呼ばれた！ 呼ばれた！呼ばれた！呼ばれた！");
    return 1;
end

class:publish();

return class;