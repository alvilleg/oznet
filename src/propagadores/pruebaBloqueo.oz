declare FD_PROP 

local
   MODMAN = {New Module.manager init}
   FD_PROP_3 = {MODMAN	link(url: 'bloqueo.so{native}' $)}
in

   fun{PruebaRes}
      proc{$ S}
	 CANALES
	 POBLACION
	 INTTRAFENT
	 INTTRAFDEC
	 RBSPUNTO
	 ANTPUNTO
	 SIZEPUNTO
	 OBJETIVO
	 UMBRAL
      in
	 ANTPUNTO   = {FD.tuple dom1 10 0#FD.sup}

	 %antenas  [9]
	 %puntos   [4]
	 %antPunto [10]
	 
	 
	 POBLACION  = [300  100    150  200]
	 RBSPUNTO   = [1 2  1 2 3  2 3  1 2 3]
	%RBSPUNTO   = [0 1  0 1 2  1 2  0 1 2]
        %ANTPUNTO   = [0 0  1 0 1  2 0  1 0 0]
	 SIZEPUNTO  = [2    3      2    3]
	 CANALES    = [24 24 24   24 24 24   24 24 24]
	 INTTRAFENT = [0    0      0    0]
	 INTTRAFDEC = [2    1      1    3]
	 OBJETIVO   = {FD.int 0#FD.sup}
	 UMBRAL     = 20
	
		 
	 ANTPUNTO.1 =: 1
	 ANTPUNTO.2 =: 1
	 ANTPUNTO.3 =: 2
	 ANTPUNTO.4 =: 1
	 ANTPUNTO.5 =: 2
	 ANTPUNTO.6 =: 3
	 ANTPUNTO.7 =: 1
	 ANTPUNTO.8 =: 2
	 ANTPUNTO.9 =: 1
	ANTPUNTO.10 =: 1

	 
	 {FD_PROP_3.bloqueo POBLACION RBSPUNTO ANTPUNTO SIZEPUNTO CANALES INTTRAFENT INTTRAFDEC  OBJETIVO UMBRAL} 
 

	 %{FD.distribute split [OBJETIVO]}	 
	 {Browser.browse OBJETIVO}
      end
   end
   {ExploreOne {PruebaRes}}

end