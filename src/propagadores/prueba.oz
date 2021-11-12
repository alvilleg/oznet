


declare FD_PROP 

local
   MODMAN = {New Module.manager init}
   FD_PROP_O = {MODMAN	link(url: 'ex_a.so{native}' $)}
   FD_PROP_1 = {MODMAN	link(url: 'tilt.so{native}' $)}
in
%   FD_PROP = fd(init: FD_PROP_O.init add: FD_PROP_O.add)
   FD_PROP = fd(add: FD_PROP_O.add)
   fun{PruebaRes}
      proc{$ S}
	 X
	 Y
	 Z
      in
	 [X Y Z] ::: 0#15	 
	 S= X#Y#Z	 	 
	 {FD_PROP.add X Y Z 2} 

	 %Y <: 5 
         Y \=: 3
	 {FD.distribute ff [X Y Z]}
	 {Browser.browse z#Z}
      end
   end
   {ExploreAll {PruebaRes}}
end



