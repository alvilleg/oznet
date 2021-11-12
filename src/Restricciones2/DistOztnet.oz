%*************************************************************
%Modulo encargado de distribuir las variables,
%
% ************************************************************
% Autor: Aldemar Villegas, 0132080
%      
% ************************************************************
functor
import
   Distribute
   Space
   System
   FD
export
   strategy:Strategy
   strategy2:Strategy2
   strategy3:Strategy3
   strategy4:Strategy4
   strategyForOne:StrategyForOne
define
   %%Recibe una tupla de estaciones base, la estructura es
   %% rb(ind:
   %%    1: ant(az:_ tilt:_ pot:_)
   %%    2: ant(az:_ tilt:_ pot:_)
   %%    3: ant(az:_ tilt:_ pot:_)
   %%    4: rang:_)

   %% La distribuci'on se lleva a cabo de la siguiente manera
   %% se elige la radiobase que en la antena 1 tenga el dominio
   %% de azimuth m'as pequeno  
   %% Luego de las antenas de esa radiobase se determinan los azimuths primero, de esta manera
   %% Las variables que primero obtienen un valor son las de azimuth, tanto para potencia,
   %% azimuth y tilt el valor elegido ser'a la mediana de cada uno de los dominios
   proc{Strategy Data}
      local	 
	 Order= proc {$ V1 V2 Co}		
		   Co=({FD.reflect.size V1.1.az.dom} > {FD.reflect.size V2.1.az.dom})
		end
	 Value= proc{$ El Ind IndAnt R}
		   %{System.show 'Value '#Ind#IndAnt}
		   if El.type ==1 then %tilt
		      %{System.show 'tilt'#Data.radioBases.Ind.antenas.IndAnt.tilt}
		      %R=Data.radioBases.Ind.antenas.IndAnt.tilt
		      R={FD.reflect.mid El.dom}
		   elseif El.type==2 then %az
		      % {System.show 'az'#Data.radioBases.Ind.antenas.IndAnt.azimuth}
		      %R=Data.radioBases.Ind.antenas.IndAnt.azimuth
		      R={FD.reflect.mid El.dom}
		   elseif El.type==3 then %pot
		      %{System.show 'pot'#Data.radioBases.Ind.antenas.IndAnt.pot}
		      %R=Data.radioBases.Ind.antenas.IndAnt.pot
		      R={FD.reflect.mid El.dom}
		   elseif El.type==4 then
		      %R=IndAnt
		      R={FD.reflect.mid El.dom}
		   end			   
		end
	 
	 Filter = fun {$ V}
		     FilterIte = fun {$ I}
				    if (I>3) then
				       false
				    else if ({Bool.'or'
					      {Bool.'or'
					       {Bool.'or'
						({FD.reflect.size V.I.tilt.dom} > 1)
						({FD.reflect.size V.I.az.dom} > 1)}
					       ({FD.reflect.size V.I.pot.dom} > 1)}
					      ({FD.reflect.size V.I.rang.dom} > 1)}
					    )
					 then
					    true
					 else
					    {FilterIte (I+1)}
					 end
				    end				 				    
				 end
		  in
		     {FilterIte 1}
		  end
	 
	 Select = fun {$ V IndAnt}		
		    if {FD.reflect.size V.1.az.dom}>1 then
		       IndAnt =1
		       V.1.az		       
		    elseif {FD.reflect.size V.2.az.dom}>1 then
		       IndAnt =2
		       V.2.az		       
		    elseif {FD.reflect.size V.3.az.dom}>1 then
		       IndAnt =3
		       V.3.az

		    elseif {FD.reflect.size V.1.rang.dom}>1 then
		       IndAnt =1
		       V.1.rang
		    elseif {FD.reflect.size V.3.rang.dom}>1 then
		       IndAnt =3
		       V.3.rang    
		    elseif {FD.reflect.size V.2.rang.dom}>1 then
		       IndAnt =2
		       V.2.rang
		       
		    elseif {FD.reflect.size V.3.pot.dom}>1 then
		       IndAnt =3
		       V.3.pot							 		   		       
		    elseif {FD.reflect.size V.1.pot.dom}>1 then
		       IndAnt =1
		       V.1.pot
		    elseif {FD.reflect.size V.2.pot.dom}>1 then
		       IndAnt =2
		       V.2.pot
		       
		    elseif {FD.reflect.size V.1.tilt.dom}>1 then
		       IndAnt =1
		       V.1.tilt			 		      		       		   
		    elseif {FD.reflect.size V.2.tilt.dom}>1 then
		       IndAnt =2
		       V.2.tilt							       		     		   
		    elseif {FD.reflect.size V.3.tilt.dom}>1 then
		       IndAnt =3
		       V.3.tilt
		    end
		      
		 end
	 
	 
      in
	 Proc=proc {$} {Space.waitStable} skip end
	 EstDist=generic(order:    Order
			 filter:       Filter
			 select:       Select
			 value:        Value
			 procedure:     Proc 
			)
      end
   in
       
      if (Data.useRelax.active == 1) then
	 {System.show 'Estrategia 1'}
	 {Distribute.distribute EstDist Data.conf Data}
      else
	 {System.show 'No relax'}
	 {Distribute.distWithoutRelax EstDist Data.conf Data}
      end
   end

   %%Similar a la primera en el orden de elecci'on de las variables pero los valores a elegir se
   %%toman as'i: Para la potencia el m'inimo del dominio, para el azimuth la mediana y para el
   %%tilt tambi'en, recomendada para disminuci'on de trafico, interferencia y reducci'on de la
   %%potencia de emisi'on
   
   %%Strategy 2
    proc{Strategy2 Data}
      local	 
	 Order= proc {$ V1 V2 Co}		
		   Co=({FD.reflect.size V1.1.az.dom} > {FD.reflect.size V2.1.az.dom})
		end
	 Value= proc{$ El Ind IndAnt R}
		   %{System.show 'Value '#Ind#IndAnt}
		   if El.type ==1 then %tilt		      
		      R={FD.reflect.mid El.dom}
		   elseif El.type==2 then %az
		      R={FD.reflect.mid El.dom}
		   elseif El.type==3 then %pot
		      R={FD.reflect.min El.dom}
		   elseif El.type==4 then
		      R={FD.reflect.min El.dom}
		   end			   
		end
	 
	 Filter = fun {$ V}
		     FilterIte = fun {$ I}
				    if (I>3) then
				       false
				    else if ({Bool.'or'
					      {Bool.'or'
					       {Bool.'or'
						({FD.reflect.size V.I.tilt.dom} > 1)
						({FD.reflect.size V.I.az.dom} > 1)}
					       ({FD.reflect.size V.I.pot.dom} > 1) }
					      ({FD.reflect.size V.I.rang.dom} > 1)}
					    )
					 then
					    true
					 else
					    {FilterIte (I+1)}
					 end
				    end				 				    
				 end
		  in
		     {FilterIte 1}
		  end
	 
	 Select = fun {$ V IndAnt}		
		    if {FD.reflect.size V.1.az.dom}>1 then
		       IndAnt =1
		       V.1.az		       
		    elseif {FD.reflect.size V.2.az.dom}>1 then
		       IndAnt =2
		       V.2.az		       
		    elseif {FD.reflect.size V.3.az.dom}>1 then
		       IndAnt =3
		       V.3.az

		    elseif {FD.reflect.size V.1.rang.dom}>1 then
		       IndAnt =1
		       V.1.rang
		    elseif {FD.reflect.size V.3.rang.dom}>1 then
		       IndAnt =3
		       V.3.rang    
		    elseif {FD.reflect.size V.2.rang.dom}>1 then
		       IndAnt =2
		       V.2.rang
		       
		    elseif {FD.reflect.size V.3.pot.dom}>1 then
		       IndAnt =3
		       V.3.pot							 		   		       
		    elseif {FD.reflect.size V.1.pot.dom}>1 then
		       IndAnt =1
		       V.1.pot
		    elseif {FD.reflect.size V.2.pot.dom}>1 then
		       IndAnt =2
		       V.2.pot		       
		    elseif {FD.reflect.size V.1.tilt.dom}>1 then
		       IndAnt =1
		       V.1.tilt			 		      		       		   
		    elseif {FD.reflect.size V.2.tilt.dom}>1 then
		       IndAnt =2
		       V.2.tilt							       		     		   
		    elseif {FD.reflect.size V.3.tilt.dom}>1 then
		       IndAnt =3
		       V.3.tilt
		    end
		      
		 end
	 
	 
      in
	 {System.show 'Estrategia 2'}
	 Proc=proc {$} {Space.waitStable} skip end
	 EstDist=generic(order:    Order
			 filter:       Filter
			 select:       Select
			 value:        Value
			 procedure:     Proc 
			)
      end
    in
       {System.show 'Estrategia 2'}
       if (Data.useRelax.active == 1) then
	  
	  {Distribute.distribute EstDist Data.conf Data}
       else
	  {System.show 'No relax'}
	  {Distribute.distWithoutRelax EstDist Data.conf Data}
       end
    end


    %%Strategy 3
    %% En esta estrategia a diferencia de las anteriores no se determinan las variables por
    %% bloques, es decir, se permiten intercalaciones entre los tipos de variables
    %% se har'an as'i para cada antena se determina primero su azimuth, luego el tilt y por
    %% 'ultimo la potencia, pero de manera intercalada.
    proc{Strategy3 Data}
       local	 
	  Order= proc {$ V1 V2 Co}		
		   Co=({FD.reflect.size V1.1.az.dom} > {FD.reflect.size V2.1.az.dom})
		 end
	  Value= proc{$ El Ind IndAnt R}		   
		    if El.type ==1 then %tilt		   		   
		       R={FD.reflect.mid El.dom}
		    elseif El.type==2 then %az		      		      
		      R={FD.reflect.mid El.dom}
		    elseif El.type==3 then %pot		      		      
		       R={FD.reflect.min El.dom}
		    elseif El.type==4 then		     
		       R={FD.reflect.min El.dom}
		    end			   
		 end
	  
	  Filter = fun {$ V}
		      FilterIte = fun {$ I}
				     if (I>3) then
					false
				     else if ({Bool.'or'
					       {Bool.'or'
						{Bool.'or'
						 ({FD.reflect.size V.I.tilt.dom} > 1)
						 ({FD.reflect.size V.I.az.dom} > 1)}
						({FD.reflect.size V.I.pot.dom} > 1) }
					       ({FD.reflect.size V.I.rang.dom} > 1)}
					     )
					  then
					     true
					  else
					     {FilterIte (I+1)}
					  end
				     end				 				    
				 end
		   in
		      {FilterIte 1}
		   end
	  
	 Select = fun {$ V IndAnt}		
		     if {FD.reflect.size V.1.az.dom}>1 then
			IndAnt =1
			V.1.az
		     elseif {FD.reflect.size V.1.tilt.dom}>1 then
			IndAnt =1
			V.1.tilt
		     elseif {FD.reflect.size V.1.rang.dom}>1 then
			IndAnt =1
			V.1.rang
		     elseif {FD.reflect.size V.1.pot.dom}>1 then
			IndAnt =1
			V.1.pot
			
			%%V2
		     elseif {FD.reflect.size V.2.az.dom}>1 then
			IndAnt =2
		       V.2.az
		     elseif {FD.reflect.size V.2.rang.dom}>1 then
			IndAnt =2
			V.2.rang			
		     elseif {FD.reflect.size V.2.tilt.dom}>1 then
		       IndAnt =2
			V.2.tilt
		     elseif {FD.reflect.size V.2.pot.dom}>1 then
			IndAnt =2
			V.2.pot

			%%V3
		     elseif {FD.reflect.size V.3.az.dom}>1 then
			IndAnt =3
			V.3.az					    
		     elseif {FD.reflect.size V.3.rang.dom}>1 then
			IndAnt =3
			V.3.rang    						
		     elseif {FD.reflect.size V.3.pot.dom}>1 then
			IndAnt =3
			V.3.pot
		     elseif {FD.reflect.size V.3.tilt.dom}>1 then
			IndAnt =3
			V.3.tilt
		     end		     
		  end
	  
	  
       in
	  Proc=proc {$} {Space.waitStable} skip end
	  EstDist=generic(order:    Order
			  filter:       Filter
			  select:       Select
			  value:        Value
			  procedure:     Proc 
			 )
       end
    in
       {System.show 'Estrategia 3'}
       if (Data.useRelax.active == 1) then
	  {Distribute.distribute EstDist Data.conf Data}
       else
	  {System.show 'No relax'}
	  {Distribute.distWithoutRelax EstDist Data.conf Data}
       end
    end
    
    %%Strategy4
    %% Las variables relacionadas directamente con la interferecia (rango de frecuencias)
    %% y azimuth se determinan al final, permitiendo as'i m'as variaciones al inicio del
    %% backtracking
    proc{Strategy4 Data}
       local	 
	 Order= proc {$ V1 V2 Co}		
		   Co={Bool.'or' {Bool.'or' ({FD.reflect.size V1.1.az.dom} > {FD.reflect.size V2.1.az.dom}) ({FD.reflect.size V1.1.tilt.dom} > {FD.reflect.size V2.1.tilt.dom})}
		       ({FD.reflect.size V1.1.pot.dom} > {FD.reflect.size V2.1.pot.dom})
		      }
		end
	 Value= proc{$ El Ind IndAnt R}
		   %{System.show 'Value '#Ind#IndAnt}
		   if El.type ==1 then %tilt		   
		      R={FD.reflect.min El.dom}
		   elseif El.type==2 then %az		      		      
		      R={FD.reflect.mid El.dom}
		   elseif El.type==3 then %pot		     		     
		      R={FD.reflect.mid El.dom}
		   elseif El.type==4 then		      
		      R={FD.reflect.min El.dom}
		   end			   
		end
	 
	 Filter = fun {$ V}
		     FilterIte = fun {$ I}
				    if (I>3) then
				       false
				    else if ({Bool.'or'
					      {Bool.'or'
					       {Bool.'or'
						({FD.reflect.size V.I.tilt.dom} > 1)
						({FD.reflect.size V.I.az.dom} > 1)
					       }
					       ({FD.reflect.size V.I.pot.dom} > 1)
					      }
					      ({FD.reflect.size V.I.rang.dom} > 1)}
					    )
					 then
					    true
					 else
					    {FilterIte (I+1)}
					 end
				    end				 				    
				 end
		  in
		     {FilterIte 1}
		  end
	 
	  Select = fun {$ V IndAnt}
		      if {FD.reflect.size V.1.az.dom}>1 then
			 IndAnt =1
			 V.1.az		       
		      elseif {FD.reflect.size V.2.az.dom}>1 then
			 IndAnt =2
			 V.2.az		       
		      elseif {FD.reflect.size V.3.az.dom}>1 then
			 IndAnt =3
			 V.3.az		      

		      elseif {FD.reflect.size V.1.rang.dom}>1 then
			 IndAnt =1
			 V.1.rang
		      elseif {FD.reflect.size V.3.rang.dom}>1 then
			 IndAnt =3
			 V.3.rang    
		      elseif {FD.reflect.size V.2.rang.dom}>1 then
			 IndAnt =2
			 V.2.rang			 		       		   

		      elseif {FD.reflect.size V.3.pot.dom}>1 then
			 IndAnt =3
			 V.3.pot			 
		      elseif {FD.reflect.size V.1.pot.dom}>1 then
			 IndAnt =1
			 V.1.pot
		      elseif {FD.reflect.size V.2.pot.dom}>1 then
			 IndAnt =2
			 V.2.pot	
		      elseif {FD.reflect.size V.1.tilt.dom}>1 then
			 IndAnt =1
			 V.1.tilt
		      elseif {FD.reflect.size V.2.tilt.dom}>1 then
			 IndAnt =2
			 V.2.tilt
		      elseif {FD.reflect.size V.3.tilt.dom}>1 then
			 IndAnt =3
			 V.3.tilt			 
		     end
		   end
       in
	  Proc=proc {$} {Space.waitStable} skip end
	  EstDist=generic(order:    Order
			  filter:       Filter
			  select:       Select
			  value:        Value
			  procedure:     Proc 
			 )
       end
    in
       {System.show 'Estrategia 4'}
       if (Data.useRelax.active == 1) then
	  {Distribute.distribute EstDist Data.conf Data}
       else
	  {System.show 'No relax'}
	  {Distribute.distWithoutRelax EstDist Data.conf Data}
       end
    end
    
    
    
    
    proc{StrategyForOne Data}
       local	 
	  Order= proc {$ V1 V2 Co}		
		    Co=({FD.reflect.size V1.1.az.dom} > {FD.reflect.size V2.1.az.dom})
		 end
	  Value= proc{$ El Ind IndAnt R}
		   %{System.show 'Value '#Ind#IndAnt}
		    if El.type ==1 then %tilt
		      %{System.show 'tilt'#Data.radioBases.Ind.antenas.IndAnt.tilt}
		       R=Data.radioBases.Ind.antenas.IndAnt.tilt
%		      R={FD.reflect.min El.dom}
		    elseif El.type==2 then %az
		      % {System.show 'az'#Data.radioBases.Ind.antenas.IndAnt.azimuth}
		       R=Data.radioBases.Ind.antenas.IndAnt.azimuth
		      %R={FD.reflect.mid El.dom}
		   elseif El.type==3 then %pot
		      %{System.show 'pot'#Data.radioBases.Ind.antenas.IndAnt.pot}
		      R=Data.radioBases.Ind.antenas.IndAnt.pot
		      %R={FD.reflect.min El.dom}
		   elseif El.type==4 then
		      R=IndAnt
		      %R={FD.reflect.min El.dom}
		   end			   
		end
	 
	 Filter = fun {$ V}
		     FilterIte = fun {$ I}
				    if (I>3) then
				       false
				    else if ({Bool.'or' {Bool.'or' {Bool.'or' ({FD.reflect.size V.I.tilt.dom} > 1)
								    ({FD.reflect.size V.I.az.dom} > 1)}
							 ({FD.reflect.size V.I.pot.dom} > 1) }
					      ({FD.reflect.size V.I.rang.dom} > 1)})
					 then
					    true
					 else
					    {FilterIte (I+1)}
					 end
				    end				 				    
				 end
		  in
		     {FilterIte 1}
		  end
   
   Select = fun {$ V IndAnt}		
		     if {FD.reflect.size V.1.az.dom}>1 then
			IndAnt =1
			V.1.az		       
		     elseif {FD.reflect.size V.2.az.dom}>1 then
			IndAnt =2
			V.2.az		       
		     elseif {FD.reflect.size V.3.az.dom}>1 then
			IndAnt =3
			V.3.az
		     elseif {FD.reflect.size V.1.rang.dom}>1 then
			IndAnt =1
			V.1.rang
			
		     elseif {FD.reflect.size V.3.rang.dom}>1 then
			IndAnt =3
			V.3.rang    
		     elseif {FD.reflect.size V.2.rang.dom}>1 then
			IndAnt =2
			V.2.rang
			
		     elseif {FD.reflect.size V.3.pot.dom}>1 then
			IndAnt =3
			V.3.pot			 		   		       
		     elseif {FD.reflect.size V.1.pot.dom}>1 then
		       IndAnt =1
			V.1.pot
		     elseif {FD.reflect.size V.2.pot.dom}>1 then
			IndAnt =2
			V.2.pot		       
		     elseif {FD.reflect.size V.1.tilt.dom}>1 then
			IndAnt =1
			V.1.tilt			 		      		       		   
		     elseif {FD.reflect.size V.2.tilt.dom}>1 then
			IndAnt =2
			V.2.tilt							       		     		   
		     elseif {FD.reflect.size V.3.tilt.dom}>1 then
			IndAnt =3
			V.3.tilt
		     end
		     
		 end	 
	 
      in
	 Proc=proc {$} {Space.waitStable} skip end
	 EstDist=generic(order:    Order
			 filter:       Filter
			 select:       Select
			 value:        Value
			 procedure:     Proc 
			)
      end
   in
      {System.show 'paso por la distribución'}
      {Distribute.distWithoutRelax EstDist Data.conf Data}
   end   
end








