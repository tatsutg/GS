local class = summoner.Bootstrap.createUnitClass({label="リザ", version=1.6, id=103006412});

function class:setItemList(unit)
   self.ITEM_LIST = {}
   for i = 0,3 do
      local items = unit:getItemSkill(i)
      if items ~= nil then
         table.insert(self.ITEM_LIST,i+1,{item=items,count=0,isChecked=false})
      end
   end
end

function class:start(event)
   self:setItemList(event.unit)
   return 1
end

function class:update(event)
   self:watching()
   return 1
end

function class:watching()
   for i,v in ipairs(self.ITEM_LIST) do
      if v.item:getCoolTimer() <= 0.1 then
         v.isChecked = false
      end
      if not v.isChecked and v.item:getCoolTimer() > 0.1 then
         v.isChecked = true
         v.count = v.count >= 6 and 6 or v.count + 1
         v.item:setCoolTimer(v.item:getCoolTimer() * (1 - (v.count * 0.05)))
      end
   end
end

class:publish();

return class;