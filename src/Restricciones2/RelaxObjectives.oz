%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                            %%
%% Modulo encargado de las relajaciones sobre los objetivos considerados      %%
%% Se implementará un función de relax sobre cada uno de los objetivos        %%
%% donde se determinará el mejor valor posible para el dado el estado actual  %%
%% de las variables que inciden en su calculo.                                %%
%%                                                                            %%
%%                                                                            %%
%%                                                                            %% 
%% Autor: Aldemar Villegas, 0132080                                           %%           
%%                                                                            %%
%%                                                                            %% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

functor
import
   FD
   Misc
%   System
export
   relaxActiveSet:RelaxActiveSet
   relaxInterference:RelaxInterference
   relaxTotalPob:RelaxPobTot
   relaxTraffic:RelaxTraffic
define

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%Función de relajación del active set, funciona así:
   %%Se cuentan las veces que el valor de la variable estando
   %%determinado cae dentro de [Min,Max], paralelo a esto se lleva
   %%la cuenta de las veces que sin estar determinada la variable puede llegar
   %%a cumplir el objetivo, es decir max(dom(var))>=Min y min(dom(var))<=Max, se suma el
   %%cumplimiento actual con el máximo cumplimiento futuro se divide por el número total
   %%de puntos y se convierte en un porcentaje, retorna un valor de tipo float.

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   %%                                                                  %% 
   %%                                                                  %% 
   %% RelaxActiveSet                                                   %%
   %%                                                                  %%
   %%                                                                  %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {RelaxActiveSet Variable Min Max Total}
      CellCntReach = {Cell.new 0}      
   in
     
      for I in 1..{Width Variable} do
	 
	 if {Value.isDet Variable.I } then
	    if {Bool.'and' (Variable.I >=Min) (Variable.I=<Max ) }then
	       {Cell.assign CellCntReach ({Cell.access CellCntReach}+1)}
	    end
	 elseif {Bool.'and' ({FD.reflect.max Variable.I} >= Min)
		 ({FD.reflect.min Variable.I}=<Max)} then
	    {Cell.assign CellCntReach ({Cell.access  CellCntReach}+1)}
	 end
      end
         
      (({Int.toFloat {Cell.access CellCntReach}})/{Int.toFloat Total})*100.0
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%                                                                  %% 
   %%                                                                  %% 
   %% Relax Interference                                               %%
   %%                                                                  %%
   %%                                                                  %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {RelaxInterference Puntos Umbral NumPtos RecAnts RecRbs Offset Conf Param FlgReachInterf}
      
      fun{Linealiza Rec}
	 Rc
      in
	 Rc={MakeTuple 'rc' {Width Rec}}
	 for I in 1..{Width Rec} do	
	    Rc.I = {Number.pow 10.0 ((Rec.I- {Int.toFloat Offset})/10.0)}
	 end
	 Rc
      end
      
      fun{CumpleInterf Signals IndexRB CoCanal Umbral Offset}

	 Suma
	 SumaAux
	 
	 SignalsAux ={MakeTuple 'sign' {Width Signals}}
	 
	 CoCanalAux={MakeTuple 'sign' {Width Signals}}
      in

	 for I in 1..{Width Signals} do	 	    	   	 
	    if I==IndexRB then

	       SignalsAux.I = {Int.toFloat {FD.reflect.max Signals.I}}
	       CoCanalAux.I = 0.0
	    else

	       SignalsAux.I = {Int.toFloat {FD.reflect.min Signals.I}}
	       CoCanalAux.I = {Int.toFloat CoCanal.I}
	    end

	 end

	 SumaAux = {Misc.scalarProduct {Linealiza SignalsAux} CoCanalAux}
	 
	 if SumaAux > 0.0 then

	    Suma = 10.0* ({Float.log SumaAux}/{Float.log 10.0})

	    %{System.show 'SignalAux'#SignalsAux}
	    %{System.show 'CoCanal'#CoCanal #'indice'#IndexRB }
	    %{System.show 'La diferencia'#((SignalsAux.IndexRB - {Int.toFloat Offset})-Suma)}
	    if (((SignalsAux.IndexRB - {Int.toFloat Offset}) - Suma) >= {Int.toFloat Umbral}) then

	       true
	    else

	       false
	    end
	 else

	    true
	 end
      end
      
      fun{DetCumpIte Puntos Umbral Cont IndexPoint RecAnts RecRbs Offset Conf}
	
	 if (IndexPoint >= NumPtos) then
	    Cont
	 elseif {Value.isDet FlgReachInterf.IndexPoint } then
	
	    if FlgReachInterf.IndexPoint == 1 then
	       {DetCumpIte Puntos Umbral (Cont+1) (IndexPoint+1) RecAnts RecRbs Offset Conf}
	    else
	       {DetCumpIte Puntos Umbral Cont (IndexPoint+1) RecAnts RecRbs Offset Conf}
	    end
	 elseif {Bool.'and'
		 ({Width Puntos.IndexPoint.lSignTot} > 1)
		 {Value.isDet Puntos.IndexPoint.indRb}} then
	    
	    if {Value.isDet {Misc.getAntByPoint IndexPoint
			     Puntos.IndexPoint.indRb RecAnts Param}
	       } then
	       if {Bool.'and' {Bool.'and' {Value.isDet Conf.(Puntos.IndexPoint.indRb).1.rang.dom}
			       {Value.isDet Conf.(Puntos.IndexPoint.indRb).2.rang.dom}}
		   {Value.isDet Conf.(Puntos.IndexPoint.indRb).3.rang.dom}
		  } then
		   
		  
		  if {CumpleInterf Puntos.IndexPoint.lSignTot Puntos.IndexPoint.indRb 
		      { Misc.coCanal  Puntos.IndexPoint.indRb
			{Misc.getAntByPoint IndexPoint Puntos.IndexPoint.indRb RecAnts Param}
			RecRbs RecAnts
			Conf IndexPoint
			Param
		      }
		      Umbral
		      Offset
		     }
		  then
		     %%Se incrementa el contador
		     
		     {DetCumpIte Puntos Umbral (Cont+1) (IndexPoint+1) RecAnts RecRbs Offset Conf}
		  else
	
		     {DetCumpIte Puntos Umbral Cont (IndexPoint+1) RecAnts RecRbs Offset Conf}			     
		  end
	       else
		  {DetCumpIte Puntos Umbral Cont (IndexPoint+1) RecAnts RecRbs Offset Conf}
	       end
	    else
	
	       {DetCumpIte Puntos Umbral (Cont+1) (IndexPoint+1) RecAnts RecRbs Offset Conf}
	    end
	 else
	    %%Como no está determinada la radiobase entonces se cuenta como que cumple
	    %%{System.show 'No esta determina la radiobase'}, o solo tiene incidencia de una
	    %%Radiobase se cuenta como que cumple
	    {DetCumpIte Puntos Umbral (Cont+1) (IndexPoint+1) RecAnts RecRbs Offset Conf}
	 end
      end
      CumpTotal 
   in
      
      CumpTotal={DetCumpIte Puntos Umbral 0 1 RecAnts RecRbs Offset Conf}
      
      {Float.ceil ({Int.toFloat CumpTotal}*100.0)/{Int.toFloat NumPtos}}
   end

   fun {RelaxPobTot Cob PobByPnt PobTotal}
      fun{CalcTotalPobIte Cob PobByPnt Index Suma N}
	
	 if Index > N then
	    Suma
	 elseif {Value.isDet Cob.Index} then
	    if (Cob.Index == 1) then
	
	       {CalcTotalPobIte Cob PobByPnt (Index+1) (Suma + PobByPnt.Index) N}
	    else
	       {CalcTotalPobIte Cob PobByPnt (Index+1) Suma N}
	    end	
	 else
	
	    {CalcTotalPobIte Cob PobByPnt (Index+1) (Suma + PobByPnt.Index ) N}
	 end
      end
      fun {CalcTotalPob Cob PobByPnt }
	
	 {CalcTotalPobIte Cob PobByPnt 1 0 {Width Cob}}
      end
      
      TotalPob
   in
      TotalPob={CalcTotalPob Cob PobByPnt }
      %{System.show 'totalPob '#TotalPob#'%'#{Int.toFloat TotalPob }/{Int.toFloat PobTotal}}
      ({Int.toFloat TotalPob }*100.0)/{Int.toFloat PobTotal}
   end

   fun {RelaxTraffic PobRB MinTrafficInt MaxTrafico}
      fun{CalcTrafficIte Index Acum }
	 if Index> {Width PobRB} then
	    Acum
	 elseif {Value.isDet PobRB.Index} then
	    if (({Int.toFloat PobRB.Index} * MinTrafficInt)=< MaxTrafico) then
	       {CalcTrafficIte (Index + 1) (Acum+3) }
	    else
	       %%Al menos una antena está sobre cargada
	       {CalcTrafficIte (Index + 1) (Acum+2) }
	    end
	 elseif (({Int.toFloat {FD.reflect.min PobRB.Index}}* MinTrafficInt)=< MaxTrafico) then
	    {CalcTrafficIte (Index + 1) (Acum+3) }
	 else
	    {CalcTrafficIte (Index + 1) (Acum+2) }
	 end
      end
   in
      ({Int.toFloat ({CalcTrafficIte 1 0 })}/(3.0 *{Int.toFloat {Width PobRB}}))*100.0
   end   
end

%%    Var = {FD.tuple var 10 0#1}
%%    for I in 1..5 do
%%       Var.(I*2)=:1
%%    end
%%    {Browse {RelaxActiveSet Var 1 2 10}}