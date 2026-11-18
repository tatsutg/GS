local class = summoner.Bootstrap.createUnitClass({label="ラダック", version=1.3, id=102996112});

-- function class:takeSkill(event)--応急処置　ホストから呼ばれた時に危険なので必ず０
-- 	if event.index == 3 then
-- 		event.unit:setBurstPoint(0);
-- 	end
-- 	return 1;
-- end

-- function class:run(event)
--    if event.spineEvent == "paySP" then
--       event.unit:setBurstPoint(0);
--    end
--    return 1;
-- end


class:publish();

return class;