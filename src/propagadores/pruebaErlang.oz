

declare
FD_PROP
FD_PROP_0

local
   MODMAN = {New Module.manager init}
   FD_PROP_0 = {MODMAN	link(url: '../propagadores/erlang.so{native}' $)}
in   
   FD_PROP = fd(erlang: FD_PROP_0.erlang)   
   fun{PruebaRes}
      proc{$ S}
	 I={FD.int 1#20}
	 L= [1 1 2 6 24 120 1]
      in
	 %{FD.int  L }
	 {FD_PROP.erlang I 2 5 L }
	 S=t(i:I)
	% I=:5
	 {FD.distribute ff [I]}
      end
   end
   {ExploreAll {PruebaRes}}
end