
declare FD_PROP 

local
   MODMAN = {New Module.manager init}

   FD_PROP_3 = {MODMAN	link(url: 'matElemProp.so{native}' $)}
in

   FD_PROP = fd(domElem:FD_PROP_3.matElem)
   fun{PruebaRes}
      StringP
   in
      proc{$ S}
	 Tilts
	 Azims Signals Gains DistTypes	 
      in

 	
 	 Tilts={FD.tuple 'col' 3 0#2}
	 Azims={FD.tuple 'fila' 3 0#2}
	 Signals={FD.tuple 'sig' 3 0#50}
	 DistTypes = rc(0 1 2)
	 Gains = rc(   5 6 7
		       8 9 10
		       11 12 13

		       14 15 16
		       17 18 19
		       20 21 22

		       23 24 25
		       26 27 28
		       29 30 31		       
		      )

	 
	 
 	 
	 S=Signals#Tilts#Azims
	 {FD_PROP.domElem Signals Tilts Azims DistTypes Gains 3 3 3 }
	 {FD.distribute ff Tilts}
	 {FD.distribute ff Azims}
      end
   end
   {ExploreOne {PruebaRes}}% proc{$ O N } N.obj >: O.obj end }
end